
# ::file::Exit
#
#    Prompt for confirmation then exit.
#
proc ::file::Exit {}  {
  # Check for altered game in all bases except the clipbase:
  set unsavedCount 0
  set savedBase [sc_base current]
  set msg ""
  set nbases [sc_base count total]
  for {set i 1} {$i < [sc_base count total]} {incr i} {
    sc_base switch $i
    if {[sc_base inUse] && [sc_game altered] && ![sc_base isReadOnly]} {
      if {$unsavedCount == 0} {
        append msg $::tr(ExitUnsaved)
        append msg "\n\n"
      }
      incr unsavedCount
      set fname [file tail [sc_base filename]]
      set g [sc_game number]
      append msg "   $fname "
      append msg "($::tr(game) $g)"
      append msg "\n"
    }
  }
  # Switch back to original database:
  sc_base switch $savedBase

  if {$msg != ""} {
    append msg "\n"
  }
  append msg $::tr(ExitDialog)

  # Only ask before exiting if there are unsaved changes:
  if {$unsavedCount > 0} {
    set answer [tk_dialog .unsaved "Scid: Unsaved Changes" $msg question {} "   [tr FileExit]   " [tr Cancel]]
    if {$answer != 0} { return }
  }
  if {$::optionsAutoSave} {
    # restore askToReplaceMoves if necessary
    if {[winfo exists .tacticsWin]} {
      ::tactics::restoreAskToReplaceMoves
    }
    .menu.options invoke [tr OptionsSave]
  }
  ::recentFiles::save
  ::utils::history::Save
  destroy .
}

proc ::file::ExitFast {} {
  if {$::optionsAutoSave} {
    # restore askToReplaceMoves if necessary
    if {[winfo exists .tacticsWin]} {
      ::tactics::restoreAskToReplaceMoves
    }
    .menu.options invoke [tr OptionsSave]
  }
  ::recentFiles::save
  destroy .
}

# ::file::New
#
#   Opens file-save dialog and creates a new database.
#
proc ::file::New {} {
  if {[sc_base count free] == 0} {
    tk_messageBox -title "Scid" -type ok -icon info \
        -message "Too many databases open; close one first"
    return
  }
  set ftype {
    { "Scid databases, EPD files" {".si4" ".epd"} }
    { "Scid databases" {".si4"} }
    { "EPD files" {".epd"} }
  }
  set fName [tk_getSaveFile -initialdir $::initialDir(base) -filetypes $ftype -title "Create a Scid database"]
  if {$fName == {}} {
    return
  } elseif {[file extension $fName] == ".epd"} {
    if {![newEpdWin create $fName]} {
      return
    }
  } else {
    if {[file extension $fName] == ".si4"} {
      set fName [file rootname $fName]
    } 
    if {[catch {sc_base create $fName} result]} {
      tk_messageBox -icon warning -type ok -parent . \
          -title "Scid: error" -message "$result\nCan't create $fName"
      return
    }
    # set default icon
    catch {sc_base type [sc_base current] 1}
    set fName $fName.si4
  }
  ::recentFiles::add $fName
  refreshWindows
}

# ::file::Open
#
#    Opens file-open dialog and opens the selected Scid database.
#
proc ::file::Open {{fName ""} {parent .}} {
  global glstart
  if {[sc_base count free] == 0} {
    tk_messageBox -type ok -icon info -title "Scid" \
        -message "Too many databases are open; close one first" -parent $parent
    return
  }

  if {[sc_info gzip]} {
    set ftype {
      { {All Scid files} {.si4 .si3 .pgn .PGN .pgn.gz .epd .epd.gz .sor} }
      { {Scid databases} {.si4 .si3} }
      { {PGN files} {.pgn .PGN .pgn.gz} }
      { {EPD files} {.epd .EPD .epd.gz} }
    }
  } else {
    set ftype {
      { {All Scid files} {.si4 .si3 .pgn .PGN .epd .sor} }
      { {Scid databases} {.si4 .si3} }
      { {PGN files} {.pgn .PGN} }
      { {EPD files} {.epd .EPD} }
    }
  }
  if {$fName == ""} {
    # under some circumstances, this appears necessary
    if {! [file isdirectory $::initialDir(base)] } {
      set ::initialDir(base) $::env(HOME)
    }
    set fName [tk_getOpenFile -initialdir $::initialDir(base) -filetypes $ftype \
                 -title "Open a Scid file" -parent $parent]
    if {$fName == ""} { return }
  }

  if {[file extension $fName] == ""} {
    set fName "$fName.si4"
  }

  if {[file extension $fName] == ".sor"} {
    if {[catch {::rep::OpenWithFile $fName} err]} {
      tk_messageBox -parent $parent -type ok -icon info -title "Scid" \
          -message "Unable to open \"$fName\": $err"
    }
    return
  }

  if {[file extension $fName] == ".si3" && [file exists $fName]} {
    ::file::Upgrade [file rootname $fName]
    return
  }

  # The ::recentFiles::remove and ::recentFiles::add should probably be 
  # handled when "if {err == 0}"

  set err 0
  busyCursor .
  if {[file extension $fName] == ".si4"} {
    set fName [file rootname $fName]
    if {[catch {openBase $fName} result]} {
      set err 1
      tk_messageBox -icon warning -type ok -parent $parent \
          -title "Scid: Error opening file" -message "$result\nCan't open $fName"
      ::recentFiles::remove "$fName.si4"
    } else {
      set ::initialDir(base) [file dirname $fName]
      ::recentFiles::add "$fName.si4"
    }
  } elseif {[string match "*.epd" [string tolower $fName]]} {
    # EPD file:
    if {[newEpdWin open $fName]} {
      ::recentFiles::add $fName
    } else {
      ::recentFiles::remove $fName
    }
  } else {
    # PGN file:
    if {![file exists $fName]} {
      set err 1
      ::recentFiles::remove $fName
      tk_messageBox -icon warning -type ok -parent $parent \
          -title "Scid: Error opening file" -message "File $fName doesn't exist."
    } else {
      set result "File $fName is not readable."
      if {(![file readable $fName])  || \
	    [catch {sc_base create $fName true} result]} {
	set err 1
	tk_messageBox -icon warning -type ok -parent $parent \
	    -title "Scid: Error opening file" -message $result
      } else {
	doPgnFileImport $fName "Opening [file tail $fName] read-only...\n"
	sc_base type [sc_base current] 3
	::recentFiles::add $fName
	set ::initialDir(base) [file dirname $fName]
	set ::initialDir(file) [file tail $fName]
      }
    }
  }

  if {$err == 0} {
    catch {sc_game load auto}
    flipBoardForPlayerNames $::myPlayerNames
  }
  unbusyCursor .
  set glstart 1

  refreshWindows

  updateBoard -pgn
}

proc refreshWindows {} {
  ::windows::gamelist::Reload
  # done in updateBoard
  # ::tree::refresh
  ::windows::stats::Refresh
  ::crosstab::Refresh
  ::plist::refresh
  ::tourney::refresh
  updateMenuStates
  updateTitle
  updateStatusBar
}

# ::file::Upgrade
#
#   Upgrades an old (version 3) Scid database to version 4.
#
proc ::file::Upgrade {name} {
  if {[file readable "$name.si4"]} {
    set msg [string trim $::tr(ConfirmOpenNew)]
    set res [tk_messageBox -title "Scid" -type yesno -icon info -message $msg]
    if {$res == "no"} { return }
    ::file::Open "$name.si4"
    return
  }

  set msg [string trim $::tr(ConfirmUpgrade)]
  set res [tk_messageBox -title "Scid" -type yesno -icon info -message $msg]
  if {$res == "no"} { return }
  progressWindow "Scid" "$::tr(Upgrading): [file tail $name]..."\
      $::tr(Cancel) "sc_progressBar"
  busyCursor .
  update
  set err [catch {sc_base upgrade $name} res]
  unbusyCursor .
  closeProgressWindow
  if {$err} {
    tk_messageBox -title "Scid" -type ok -icon warning \
        -message "Unable to upgrade the database:\n$res"
    return
  } else  {
    # rename game and name files, delete old .si3
    file rename "$name.sg3"  "$name.sg4"
    file rename "$name.sn3"  "$name.sn4"
    file delete "$name.si3"
  }
  ::file::Open "$name.si4"
}

# openBase:
#    Opens a Scid database, showing a progress bar in a separate window
#    if the database is around 1 Mb or larger in size.
#   ::file::Open should be used if the base is not already in si4 format
proc openBase {name} {
  set bsize 0
  set gfile "[file rootname $name].sg4"
  if {! [catch {file size $gfile} err]} { set bsize $err }
  set showProgress 0
  if {$bsize > 1000000} { set showProgress 1 }
  if {$showProgress} {
    progressWindow "Scid" "$::tr(OpeningTheDatabase): [file tail $name]..."
  }
  set err [catch {sc_base open $name} result]
  if {$showProgress} { closeProgressWindow }
  if {$err} { return -code error $result }
  return $result
}


# ::file::Close:
#   Closes the active base.
#
proc ::file::Close {{base -1}} {
  # Remember the current base
  set current [sc_base current]
  if {$base < 0} { set base $current }
  # Switch to the base which will be closed, and check for changes:
  sc_base switch $base
  if {[sc_base inUse]} {
    if {![::game::ConfirmDiscard]} {
      sc_base switch $current
      return
    }
    sc_base close

    # If closing current base - reset current game and switch to clipbase
    if { $current == $base } {
      setTrialMode 0
      sc_game new
      ::file::SwitchToBase clipbase
    } else {
      ::file::SwitchToBase $current
    }

    # Need these here, as otherwise a db "open base as tree" window won't close. S.A.
    if {[winfo exists .treeWin$base]} { destroy .treeWin$base }
    if {[winfo exists .emailWin]} { destroy .emailWin }
  } else {
    updateMenuStates
    updateStatusBar
    updateTitle
  }
}


proc ::file::SwitchToBase {b} {
  sc_base switch $b

  # Close Tree and Email windows whenever a base is closed/switched:
  if {[winfo exists .treeWin$b]} { destroy .treeWin$b }
  if {[winfo exists .emailWin]} { destroy .emailWin }

  updateBoard -pgn

  refreshWindows
}

################################################################################
proc ::file::openBaseAsTree { { fName "" } } {
  set current [sc_base current]

  if {[sc_base count free] == 0} {
    tk_messageBox -type ok -icon info -title "Scid" \
        -message "Too many databases are open; close one first"
    return
  }

  if {$fName == ""} {
    if {[sc_info gzip]} {
      set ftype {
        { "Scid databases, PGN files" {".si4" ".si3" ".pgn" ".PGN" ".pgn.gz"} }
        { "Scid databases" {".si4" ".si3"} }
        { "PGN files" {".pgn" ".PGN" ".pgn.gz"} }
      }
    } else {
      set ftype {
        { "Scid databases, PGN files" {".si4" ".si3" ".pgn" ".PGN"} }
        { "Scid databases" {".si4" ".si3"} }
        { "PGN files" {".pgn" ".PGN"} }
      }
    }
    set fName [tk_getOpenFile -initialdir $::initialDir(base) -filetypes $ftype -title "Open a Scid file"]
    if {$fName == ""} { return }
    set ::initialDir(base) [file dirname $fName]
    set ::initialDir(file) [file tail $fName]
  }

  if {[file extension $fName] == ""} {
    set fName "$fName.si4"
  }

  if {[file extension $fName] == ".sor"} {
    if {[catch {::rep::OpenWithFile $fName} err]} {
      tk_messageBox -parent . -type ok -icon info -title "Scid" \
          -message "Unable to open \"$fName\": $err"
    }
    return
  }

  if {[file extension $fName] == ".si3" && [file exists $fName]} {
    ::file::Upgrade [file rootname $fName]
    return
  }

  set err 0
  busyCursor .
  if {[file extension $fName] == ".si4"} {
    set fName [file rootname $fName]
    if {[catch {openBase $fName} result]} {
      set err 1
      tk_messageBox -icon warning -type ok -parent . -title "Scid: Error opening file" -message $result
      return
    } else {
      set ::initialDir(base) [file dirname $fName]
      set ::initialDir(file) [file tail $fName]
      ::recentFiles::add "$fName.si4"
    }
  } else {
    # PGN file:
    set result "This file is not readable."
    if {(![file readable $fName])  || \
          [catch {sc_base create $fName true} result]} {
      set err 1
      tk_messageBox -icon warning -type ok -parent . -title "Scid: Error opening file" -message $result
      return
    } else {
      doPgnFileImport $fName "Opening [file tail $fName] read-only...\n"
      sc_base type [sc_base current] 3
      set ::initialDir(base) [file dirname $fName]
      set ::initialDir(file) [file tail $fName]
      ::recentFiles::add $fName
    }
  }

  unbusyCursor .
  ::tree::make [sc_base current]
  .treeWin[sc_base current].buttons.lock invoke
  ::file::SwitchToBase $current
}

