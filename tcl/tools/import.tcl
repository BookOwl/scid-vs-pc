###
### import.tcl: part of Scid.
### Copyright (C) 2000  Shane Hudson.
###

### Import game window

proc importPgnGame {} {
  set w .importWin

  if {[winfo exists $w]} {
    raiseWin $w
    return
  }

  toplevel $w
  wm state $w withdrawn
  wm title $w "Scid: Import PGN game"

  frame $w.b
  pack $w.b -side bottom -pady 6 

  set pane [::utils::pane::Create $w.pane edit err 500 300 0.75]
  pack $pane -side top -expand true -fill both

  set edit $w.pane.edit
  text $edit.text -height 12 -width 80 -wrap word  \
      -yscroll "$edit.ybar set" -xscroll "$edit.xbar set"  -setgrid 1 -undo 1
  # Override tab-binding for this widget:
  bind $edit.text <Key-Tab> "[bind all <Key-Tab>]; break"
  scrollbar $edit.ybar -command "$edit.text yview" -takefocus 0
  scrollbar $edit.xbar -orient horizontal -command "$edit.text xview" -takefocus 0
  grid $edit.text -row 0 -column 0 -sticky nesw
  grid $edit.ybar -row 0 -column 1 -sticky nesw
  grid $edit.xbar -row 1 -column 0 -sticky nesw
  grid rowconfig $edit 0 -weight 1 -minsize 0
  grid columnconfig $edit 0 -weight 1 -minsize 0

  # Right-mouse button cut/copy/paste menu:
  menu $edit.text.rmenu -tearoff 0
  $edit.text.rmenu add command -label "Undo" -command "catch {$edit.text edit undo}"
  $edit.text.rmenu add command -label "Redo" -command "catch {$edit.text edit redo}"
  $edit.text.rmenu add command -label "Cut" -command "tk_textCut $edit.text"
  $edit.text.rmenu add command -label "Copy" -command "tk_textCopy $edit.text"
  $edit.text.rmenu add command -label "Paste" -command "tk_textPaste $edit.text"
  $edit.text.rmenu add command -label "Select all" -command "$edit.text tag add sel 0.0 end-1c"
  bind $edit.text <ButtonPress-3> "tk_popup $edit.text.rmenu %X %Y"

  text $pane.err.text -height 6 -width 75 -wrap word \
      -yscroll "$pane.err.scroll set"
  scrollbar $pane.err.scroll -command "$pane.err.text yview" -takefocus 0
  pack $pane.err.scroll -side right -fill y
  pack $pane.err.text -side left -expand true -fill both

  dialogbutton $w.b.paste -text "$::tr(PasteCurrentGame)" -command {
    .importWin.pane.edit.text insert end [sc_game pgn -width 70]
    .importWin.pane.err.text delete 0.0 end
  }

  dialogbutton $w.b.clear -text "$::tr(Clear)" -command {
    .importWin.pane.edit.text delete 0.0 end
    .importWin.pane.err.text delete 0.0 end
  }

  dialogbutton $w.b.import -text "$::tr(Import)" -command {
    set err \
      [catch {sc_game import [.importWin.pane.edit.text get 0.0 end]} result]
    if {! $err} {
      updateBoard -pgn
      updateTitle
    }
    if {$result == {PGN text imported with no errors or warnings.}} {
      destroy .importWin; focus .
    } else {
      .importWin.pane.err.text delete 0.0 end
      .importWin.pane.err.text insert end $result
    }
  }

  dialogbutton $w.b.cancel -textvar ::tr(Close) -command {
    destroy .importWin; focus .
  }

  frame $w.b.space -width 20
  pack $w.b.paste $w.b.space -side left -padx 10 -pady 2
  pack $w.b.cancel $w.b.import $w.b.clear -side right -padx 10 -pady 2
  # Paste the current selected text automatically:
  if {![catch {set texttopaste [selection get]}]} {
    $w.pane.edit.text insert end $texttopaste
  } 
  # if {![info exists texttopaste] || $texttopaste == {}} 
    $w.pane.err.text insert end $::tr(ImportHelp1)
    # $w.pane.err.text insert end "\n"
    # $w.pane.err.text insert end $::tr(ImportHelp2)

  bind $w <F1> { helpWindow Import }
  bind $w <Escape> { .importWin.b.cancel invoke }
  bind $edit.text <Control-a> "$edit.text tag add sel 0.0 end-1c ; break"
  bind $edit.text <Control-z> "catch {$edit.text edit undo}"
  bind $edit.text <Control-y> "catch {$edit.text edit redo}"
  bind $edit.text <Control-r> "catch {$edit.text edit redo}"

  # The usual Control-c Control-x Control-p bindings work automatically
  # wm minsize $w 50 5
  focus $w.pane.edit.text
  update
  placeWinOverParent $w .
  wm state $w normal
  bind $w.pane.err.text <FocusIn> "focus $w.pane.edit.text"
  bind $w.pane.err.text <Control-z> "catch {$w.pane.edit.text edit undo}"
}


proc importClipboardGame {} {

  importPgnGame

  ### X paste selection is done in importPgnGame
  if {$::windowsOS} {
     catch {event generate .importWin.pane.edit.text <<Paste>>}
  }
}

################################################################################
#
################################################################################
proc importMoveList {line} {
  sc_move start
  sc_move addSan $line
  updateBoard -pgn
}


proc importVar {} {
  # Move formatting doesn't seem to cause any problems
  # (eg 6.Qg4+ Qg6 7.Qd4+ Kg8 8.Qd8+ Kh7+)

   if {[catch {set ::tmp [selection get -selection PRIMARY]} ]} {
    catch {set ::tmp [selection get -selection CLIPBOARD]}
  }

  if {![info exists ::tmp] || $::tmp == {}} {
    tk_messageBox -type ok -icon error -title "Scid: Oops" \
      -message "No text in clipboard."
    return
  }

  # Code reused from addAnalysisVariation

  set addAtStart [expr [sc_pos isAt vstart]  &&  [sc_pos isAt vend]]
  set isAt_end [sc_pos isAt end]
  set isAt_vend [sc_pos isAt vend]

  # Temporarily clear the pre-move command since we want to add a
  # whole line without Scid updating stuff
  sc_info preMoveCmd {}

  if { $isAt_vend} {
    # get the last move of the game
    set lastMove [sc_game info previousMoveUCI]
    # back one move
    sc_move back
  }

  if {!$isAt_vend || $isAt_end} {
    # Add a variation if not already at end of a variation
    # (in which case we append moves to this var)
    sc_var create
    set create_var 1
  } else {
    set create_var 0
  }
  
  if {$isAt_vend} {
    # Add the last move of the game
    sc_move addSan $lastMove
  }

  if {[catch {sc_move addSan $::tmp}]} {
    if {$create_var} {
      sc_var exit
      catch {sc_var delete [sc_var number]}
    }
    updateBoard -pgn
    tk_messageBox -type ok -icon error -title "Scid: Oops" \
      -message "Error adding variation \"$::tmp\""
  } else {
    # Now go back to the previous place
    if {$create_var} {
      sc_var exit
    } else {
      # don't cound the movenumbers (which have a trailing ".") or "..."
      # (eg) Kb4 61. g8=Q Rd2 62. Qe6 Rd1 63. Qe3 Rd7 64. Qe1+ Kc5 65. b4+ Kc6
      sc_move back [expr [llength $::tmp] - [regexp -all {[0-9.]+\.} $::tmp]]
    }

  if {$addAtStart} {
    sc_move start
  } elseif {$isAt_vend && $create_var} {
    ### Automatically goto variation S.A.
    # todo : sould only do this if only a single var exists
    sc_var enter 0
  }
    updateBoard -pgn
  }
  # Restore the pre-move command:
  # todo: wtf does this (from analysis.tcl) do
  sc_info preMoveCmd preMoveCommand
}

################################################################################
#
################################################################################
proc importMoveListTrans {line} {

  set doImport 0

  if { $::askToReplaceMoves } {
    if {[llength [sc_game firstMoves 0 1]] == 0 || $::trialMode } {
      set doImport 1
    } elseif {[tk_messageBox -message [::tr "OverwriteExistingMoves"] -type yesno -icon question ] == yes} {
      set doImport 1
    }
  } else  {
    set doImport 1
  }
  if {$doImport} {
    set line [untrans $line]
    sc_move start
    sc_move addSan $line
    updateBoard -pgn
  }

}

set importPgnErrors ""

### Import file of Pgn games:

proc importPgnFile {} {
  global importPgnErrors

  set err ""
  if {[sc_base isReadOnly]} { set err "Database \"[file tail [sc_base filename]]\" is read-only." }
  if {![sc_base inUse]} { set err "This is not an open database." }
  if {$err != ""} {
    tk_messageBox -type ok -icon error -title "Scid: Error" -message $err
    return
  }
  if {[sc_info gzip]} {
    set ftypes {
      { "Portable Game Notation files" {".pgn" ".PGN" ".pgn.gz"} }
      { "Text files" {".txt" ".TXT"} }
      { "All files" {"*"} }
    }
  } else {
    set ftypes {
      { "Portable Game Notation files" {".pgn" ".PGN"} }
      { "Text files" {".txt" ".TXT"} }
      { "All files" {"*"} }
    }
  }
  set fnames [tk_getOpenFile -multiple 1 -filetypes $ftypes -title "Import from PGN files" ]
  if {$fnames == ""} { return }
  foreach fname $fnames {
    doPgnFileImport $fname "" 1
  }

  refreshWindows
}

proc doPgnFileImport {fname text {multiple 0} } {
  set w .ipgnWin
  if {[winfo exists $w] && ! $multiple } { destroy $w }
  if {! [winfo exists $w]} {
    if {![file exists $fname]} {
      error "File $fname doesn't exist."
    } 

    # This should be centered over Scid main window,
    # but there are issues with focus and grabs

    toplevel $w
    wm title $w "Scid: Importing PGN file"

    canvas $w.progress -width 350 -height 20  -relief solid 
    $w.progress create rectangle 0 0 0 0 -fill rosybrown3 -outline rosybrown3 -tags bar
    $w.progress create text 345 10 -anchor e -font font_Regular -tags time \
        -fill black -text "0:00 / 0:00"

    frame $w.buttons
    pack $w.buttons -side bottom -fill x
    pack $w.progress -side bottom -pady 7

    dialogbutton $w.buttons.stop -textvar ::tr(Stop) -command {sc_progressBar}
    dialogbutton $w.buttons.close -textvar ::tr(Close) -command "focus .; destroy $w"
    pack $w.buttons.close $w.buttons.stop -side right -padx 5 -pady 5

    pack [frame $w.tf] -side top -expand yes -fill both
    text $w.text -height 8 -width 60 -background gray90 \
        -wrap none -cursor watch -setgrid 1 -yscrollcommand "$w.ybar set"
    scrollbar $w.ybar -command "$w.text yview"
    pack $w.ybar -in $w.tf -side right -fill y
    pack $w.text -in $w.tf -side left -fill both -expand yes
  }

  sc_progressBar $w.progress bar 351 21 time
  update
  busyCursor .
  catch {grab $w.buttons.stop}
  bind $w <Escape> "$w.buttons.stop invoke"
  $w.buttons.close configure -state disabled
  $w.text insert end $text
  $w.text insert end "Importing PGN games from [file tail $fname]...\n\n"
  $w.text configure -state disabled

  set importPgnErrors ""
  set err [catch {sc_base import file $fname} result]
  unbusyCursor .

  set warnings ""
  $w.text configure -state normal
  $w.text configure -cursor top_left_arrow
  if {$err} {
    $w.text insert end $result
  } else {
    set nImported [lindex $result 0]
    set warnings [lindex $result 1]
    set str "Imported $nImported "
    if {$nImported == 1} { append str "game" } else { append str "games" }
    if {$warnings == ""} {
      append str " successfully."
    } else {
      append str ".\nPGN errors/warnings:\n$warnings"
    }
    $w.text insert end "$str\n"
    # This needs testing S.A. &&&
    ::recentFiles::add $fname
  }

  $w.text configure -state disabled
  $w.buttons.close configure -state normal
  $w.buttons.stop configure -state disabled
  catch {grab release $w.buttons.stop}
  bind $w <Escape> "$w.buttons.close invoke; break"
  # Auto-close import progress window if there were no errors/warnings?
  if {!$err  &&  $warnings == "" && ! $multiple} { destroy $w }
  updateTitle
  updateMenuStates
  ::windows::switcher::Refresh
  ::maint::Refresh
  update
  return $err
}

###
### End of file: import.tcl
###

