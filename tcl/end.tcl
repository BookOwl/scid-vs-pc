# end.tcl: part of Scid.
# Copyright (C) 2000-2003 Shane Hudson.

### This is broke. S.A.
#
# # detect the case where, under Linux, Scid is used without prior installation
# # the fallback directory is Scid's exec dir
# if {! [file isdirectory $::scidBasesDir] || ! [file isdirectory $::scidBooksDir]} {
#   set scidShareDir $::scidExeDir
#   set scidBasesDir [file nativename [file join $::scidShareDir "bases"]]
#   set scidBooksDir [file nativename [file join $scidShareDir "books"]]
# }

::splash::add "scidShareDir is $scidShareDir"

if {[file isdirectory $::scidBasesDir]} {
  ::splash::add "scidBasesDir is $scidBasesDir"
} else {
  ::splash::add "scidBasesDir $scidBasesDir not found!" error
}

if {[file isdirectory $::scidBooksDir]} {
  ::splash::add "scidBooksDir is $scidBooksDir"
} else {
  ::splash::add "scidBooksDir $scidBooksDir not found!" error
}

############################################################
### Main window title, etc:



############################################################
### Menu/etc Functions:


# findNovelty:
#   Searches the for first position in the current game not
#   found in the selected database.

set noveltyOlder 0

proc findNovelty {} {
  global noveltyBase noveltyOlder
  set noveltyBase [sc_base current]
  set w .noveltyWin
  if {[winfo exists $w]} {
    updateNoveltyWin
    return
  }
  toplevel $w
  wm title $w "Scid: $::tr(FindNovelty)"

  pack [frame $w.help] -side top -fill x
  text $w.help.text -width 1 -height 5 -wrap word \
      -relief ridge -cursor top_left_arrow -yscrollcommand "$w.help.ybar set"
  scrollbar $w.help.ybar -orient vertical -command "$w.help.text yview" \
      -takefocus 0 -width 10
  pack $w.help.ybar -side right -fill y
  pack $w.help.text -side left -fill x -expand yes
  $w.help.text insert end [string trim $::tr(NoveltyHelp)]
  $w.help.text configure -state disabled

  label $w.title -text $::tr(Database:) -font font_Bold
  pack $w.title -side top
  set numBases [sc_base count total]
  for {set i 1} {$i <= $numBases} {incr i} {
    radiobutton $w.b$i -text "" -variable noveltyBase -value $i -underline 5
    pack $w.b$i -side top -anchor w -padx 10
  }
  addHorizontalRule $w

  label $w.which -text $::tr(TwinsWhich:) -font font_Bold
  pack $w.which -side top
  radiobutton $w.all -text $::tr(SelectAllGames) \
      -variable noveltyOlder -value 0
  radiobutton $w.older -text $::tr(SelectOlderGames) \
      -variable noveltyOlder -value 1
  pack $w.all $w.older -side top -anchor w -padx 10

  addHorizontalRule $w

  label $w.status -text "" -width 1 -font font_Small -relief sunken -anchor w
  pack $w.status -side bottom -fill x
  pack [frame $w.b] -side top -fill x
  dialogbutton $w.b.stop -textvar ::tr(Stop) -state disabled \
      -command sc_progressBar
  dialogbutton $w.b.go -text $::tr(FindNovelty) -command {
    .noveltyWin.b.stop configure -state normal
    .noveltyWin.b.go configure -state disabled
    .noveltyWin.b.close configure -state disabled
    busyCursor .
    .noveltyWin.status configure -text " ... "
    update
    grab .noveltyWin.b.stop
    if {$noveltyOlder} {
      set err [catch {sc_game novelty -older -updatelabel .noveltyWin.status $noveltyBase} result]
    } else {
      set err [catch {sc_game novelty -updatelabel .noveltyWin.status $noveltyBase} result]
    }
    grab release .noveltyWin.b.stop
    if {! $err} { set result "$::tr(Novelty): $result" }
    unbusyCursor .
    .noveltyWin.b.stop configure -state disabled
    .noveltyWin.b.go configure -state normal
    .noveltyWin.b.close configure -state normal
    .noveltyWin.status configure -text $result
    updateBoard
  }
  dialogbutton $w.b.close -textvar ::tr(Close) -command {
    catch {destroy .noveltyWin}
  }
  packbuttons right $w.b.close $w.b.go $w.b.stop
  wm resizable $w 0 0
  focus $w.b.go
  bind $w <KeyPress-1> "$w.b1 invoke"
  bind $w <KeyPress-2> "$w.b2 invoke"
  bind $w <KeyPress-3> "$w.b3 invoke"
  bind $w <KeyPress-4> "$w.b4 invoke"
  updateNoveltyWin
}

proc updateNoveltyWin {} {
  set w .noveltyWin
  if {! [winfo exists $w]} { return }
  set numBases [sc_base count total]
  $w.older configure -text "$::tr(SelectOlderGames) (< [sc_game info date])"
  for {set i 1} {$i <= $numBases} {incr i} {
    set name [file tail [sc_base filename $i]]
    set ng [::utils::thousands [sc_base numGames $i]]
    set text "Base $i: $name ($ng $::tr(games))"
    $w.b$i configure -state normal -text $text
    if {$ng == 0} { $w.b$i configure -state disabled }
  }
}

set merge(ply) 40

# mergeGame:
#   Produces a dialog for the user to merge a selected game into
#   the current game.
#
proc mergeGame {{base 0} {gnum 0}} {
  global merge glNumber
  if {$base == 0} {
    if {$glNumber < 1} { return }
    if {$glNumber > [sc_base numGames]} { return }
    set base [sc_base current]
    set gnum $glNumber
  }
  sc_game push copy
  set err [catch {sc_game merge $base $gnum} result]
  sc_game pop
  if {$err} {
    tk_messageBox -title "Scid" -type ok -icon info \
        -message "Unable to merge the selected game:\n$result"
    return
  }
  set merge(base) $base
  set merge(gnum) $gnum
  set w .mergeDialog
  toplevel $w
  wm title $w "Scid: $::tr(MergeGame)"
  bind $w <Escape> "$w.b.cancel invoke"
  bind $w <F1> {helpWindow GameList Browsing}
  label $w.title -text $::tr(Preview:) -font font_Bold
  pack $w.title -side top
  pack [frame $w.b] -side bottom -fill x
  frame $w.f
  text $w.f.text  -wrap word -width 60 -height 20 \
      -font font_Small -yscrollcommand "$w.f.ybar set"
  scrollbar $w.f.ybar -takefocus 0 -command "$w.f.text yview"
  event generate $w.f.text <ButtonRelease-1>
  pack $w.f.ybar -side right -fill y
  pack $w.f.text -side left -fill both -expand yes
  pack $w.f -fill both -expand yes
  set small font_Small
  label $w.b.label -text "Up to move:" -font $small
  pack $w.b.label -side left
  foreach i {5 10 15 20 25 30 35 40} {
    radiobutton $w.b.m$i -text $i -variable merge(ply) -value [expr {$i * 2}] \
        -indicatoron 0 -padx 2 -pady 1 -font $small -command updateMergeGame
    pack $w.b.m$i -side left
  }
  radiobutton $w.b.all -text [::utils::string::Capital $::tr(all)] \
      -variable merge(ply) -value 1000 -indicatoron 0 -padx 2 -pady 1 \
      -font $small -command updateMergeGame
  pack $w.b.all -side left
  dialogbutton $w.b.ok -text "OK" -command {
    sc_game merge $merge(base) $merge(gnum) $merge(ply)
    catch {grab release .mergeDialog}
    destroy .mergeDialog
    updateBoard -pgn
  }
  dialogbutton $w.b.cancel -text $::tr(Cancel) \
      -command "catch {grab release $w}; destroy $w"
  packbuttons right $w.b.cancel $w.b.ok
  grab $w
  updateMergeGame
}

proc updateMergeGame {args} {
  global merge
  set w .mergeDialog
  if {! [winfo exists $w]} { return }
  sc_game push copy
  sc_game merge $merge(base) $merge(gnum) $merge(ply)
  set pgn [sc_game pgn -indentV 1 -short 1 -width 60]
  sc_game pop
  $w.f.text configure -state normal
  $w.f.text tag configure red -foreground darkRed
  $w.f.text tag configure blue -foreground darkBlue
  $w.f.text delete 1.0 end
  foreach line [split $pgn "\n"] {
    if {[string index $line 0] == " "} {
      $w.f.text insert end $line blue
    } else {
      $w.f.text insert end $line
    }
    $w.f.text insert end "\n"
  }
  $w.f.text tag add red 1.0 4.0
  #$w.f.text insert end $pgn
  $w.f.text configure -state disabled
}

# setExportText:
#   Allows the user to modify the text printed at the start and end of a
#   file for a particular export format
#
proc setExportText {exportType} {
  global exportStartFile exportEndFile

  switch -- $exportType {
    "PGN" {
      set title "Set PGN file export text"
    }
    "HTML" {
      set title "Set HTML file export text"
    }
    "LaTeX" {
      set title "Set LaTeX file export text"
    }
    default {
      return
    }
  }

  set w .setExportText$exportType
  if {[winfo exists $w]} { return }
  toplevel $w
  wm title $w "Scid: $title"

  frame $w.buttons
  pack $w.buttons -side bottom -fill x -anchor e

  set pane [::utils::pane::Create $w.pane start end 500 400]
  ::utils::pane::SetRange $w.pane 0.3 0.7
  pack $pane -side top -expand true -fill both
  foreach f [list $pane.start $pane.end] type {start end} {
    label $f.title -font font_Bold -text "Text at $type of $exportType file:"
    text $f.text -wrap none  \
        -yscroll "$f.ybar set" -xscroll "$f.xbar set"
    scrollbar $f.ybar -orient vertical -command "$f.text yview"
    scrollbar $f.xbar -orient horizontal -command "$f.text xview"
    bind $f.text <FocusIn> {%W configure -background lightYellow}
    bind $f.text <FocusOut> {%W configure -background white}
    grid $f.title -row 0 -column 0 -sticky w
    grid $f.text -row 1 -column 0 -sticky nesw
    grid $f.ybar -row 1 -column 1 -sticky nesw
    grid $f.xbar -row 2 -column 0 -sticky nesw
    grid rowconfig $f 1 -weight 1 -minsize 0
    grid columnconfig $f 0 -weight 1 -minsize 0
  }

  $pane.start.text insert end $exportStartFile($exportType)
  $pane.end.text insert end $exportEndFile($exportType)

  button $w.buttons.default -text "Reset to Default" -command "
  $pane.start.text delete 1.0 end
  $pane.start.text insert end \$default_exportStartFile($exportType)
  $pane.end.text delete 1.0 end
  $pane.end.text insert end \$default_exportEndFile($exportType)
  "
  dialogbutton $w.buttons.ok -text "OK" -command "
  set exportStartFile($exportType) \[$pane.start.text get 1.0 end-1c\]
  set exportEndFile($exportType) \[$pane.end.text get 1.0 end-1c\]
  focus .
  destroy $w
  "
  dialogbutton $w.buttons.cancel -text $::tr(Cancel) -command "focus .; destroy $w"
  pack $w.buttons.default -side left -padx 5 -pady 2
  pack $w.buttons.cancel $w.buttons.ok -side right -padx 5 -pady 2
  focus $pane.start.text
}

image create photo htmldiag0 -data {
  R0lGODdhbgBkAIAAAAAAAP///ywAAAAAbgBkAAAC/oyPqcvtD6OctNqLs968+w+G4kiW5omm
  6moAgQu/ckzPdo3fes7vfv5wsYQtBFF2OCqNzCPrs4xEi0mQEyWcApxbqhfpvYa2ZCNZeQ4y
  k122YgqGNs7oMtu+aH9f6XT1vydm5ddCyIenlkB3KAgnePFIJzm5yECkRVmpuPbokflpaLl2
  eKeHCNcRCQo6F3e52qY3Gve04QhbJkvrGYQb+jbrB8sHaJPi25mnGItLvDmRnLwnCpH1luUb
  WGwpLdUsIdaFHLtdHe09bM45Lkw9p4uRXfHKbseFntibnk9fT/4XDR6kb+BKsfrkrFuhc+b2
  OYhh0J+1Z+8U6ltVMGIm/kaTpnnL95DgQzPpMC6RJtCCPArMOmqsNDFjq4YYq5lZGKokxZEc
  Vtok5pIkwl2p0NXsZZDUsmH3fmpIuWxeUKEHy828yo0dT6p5sk3sZrGrP6dWx3kMCRKYykhE
  xcpD1fWpxK1tOX4LK9OtVneuliKjAnEEIqkMA9UrgjctTokCY+4a29fvL6OM2ZabW3co1peH
  rwVb3DmM5lpSRlV2DHryrGPFEidqShrS59azz2Zw/TTyF0e168aG1ps3bRG4bz8pvqmH8h/M
  lztvDj0wVuG7g/sW3Bv48Orbr7Purky3eOpgkMsenxcuX/XHs3NzzzG8NsJQ38EnG2Uq+rWa
  /s7bVrvfRtwBxhIlLHWnEHUCklegfumtpgx5AloHjYHAMTjdahbeB46D+EG4Hoj68YaXh3Sx
  B9IVrADo3TUTHmjVTHA5pFuCR70G4oeSaYZiRTemyGJcw72lIWWj2TckjKLRKN5FKypZHj/B
  iBQZWFS6g2GIVI3Wo15HApljFTMSlKWLP4oyo45L8himkxuq2eJ+nKV0UoUvgvlfhmb2x2FI
  JsL505hPDmjjoDx1qeWWEyK655d6tunMNGbt5N2kaF0Wlop7DejnX9qRJGWj++TnJpMUhVPf
  bJhBOqehWqompmmQgbejT8Bgkup4s8aZ2pU71VGYK4xVp8qqLAJriREXw1LqpaV0xXeoqJ4C
  Uuyuz2g62KvL5tnqmb8uhhS128Imra03iZvtsz2xikU8CFLInXkqvVsavZwyekKZTcArZ5Pt
  6vutvf3GBjC7VrRX1HMKR8fwwg4bo26+/Eq4729FCUyxHEPcO7FpFtvSscC8DJExx9vI+3G/
  JfNK1ncqh4zybyuvLEEBADs=
}

image create photo htmldiag1 -data {
  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
}

# exportOptions:
#   Prompts the user to select exporting options.

proc exportOptions {exportType} {
  global exportFlags

  set w .exportFlagsWin
  set exportFlags(ok) -1
  toplevel $w
  wm title $w "Scid: [tr OptionsExport]"
  wm transient $w .
  wm protocol $w WM_DELETE_WINDOW { }
  bind $w <Escape> "$w.b.cancel invoke"
  bind $w <Return> "$w.b.ok invoke"
  bind $w <F1> {helpWindow Export}

  pack [frame $w.o] -side top -fill x -pady 5 -padx 5
  label $w.o.append -text $::tr(AddToExistingFile)
  radiobutton $w.o.appendYes -text $::tr(Yes) \
      -variable exportFlags(append) -value 1
  radiobutton $w.o.appendNo -text $::tr(No) \
      -variable exportFlags(append) -value 0
  label $w.o.comments -text $::tr(ExportComments)
  radiobutton $w.o.commentsOn -text $::tr(Yes) \
      -variable exportFlags(comments) -value 1
  radiobutton $w.o.commentsOff -text $::tr(No) \
      -variable exportFlags(comments) -value 0
  label $w.o.stripMarks -text $::tr(ExportStripMarks)
  radiobutton $w.o.stripMarksOn -text $::tr(Yes) \
      -variable exportFlags(stripMarks) -value 1
  radiobutton $w.o.stripMarksOff -text $::tr(No) \
      -variable exportFlags(stripMarks) -value 0
  label $w.o.indentc -text $::tr(IndentComments)
  radiobutton $w.o.indentcOn -text $::tr(Yes) \
      -variable exportFlags(indentc) -value 1
  radiobutton $w.o.indentcOff -text $::tr(No) \
      -variable exportFlags(indentc) -value 0
  label $w.o.vars -text $::tr(ExportVariations)
  radiobutton $w.o.varsOn -text $::tr(Yes) -variable exportFlags(vars) -value 1
  radiobutton $w.o.varsOff -text $::tr(No) -variable exportFlags(vars) -value 0
  label $w.o.indentv -text $::tr(IndentVariations)
  radiobutton $w.o.indentvOn -text $::tr(Yes) \
      -variable exportFlags(indentv) -value 1
  radiobutton $w.o.indentvOff -text $::tr(No) \
      -variable exportFlags(indentv) -value 0
  label $w.o.column -text $::tr(ExportColumnStyle)
  radiobutton $w.o.columnOn -text $::tr(Yes) \
      -variable exportFlags(column) -value 1
  radiobutton $w.o.columnOff -text $::tr(No) \
      -variable exportFlags(column) -value 0
  label $w.o.symbols -text $::tr(ExportSymbolStyle)
  radiobutton $w.o.symbolsOn -text "! +=" \
      -variable exportFlags(symbols) -value 1
  radiobutton $w.o.symbolsOff -text {$2 $14} \
      -variable exportFlags(symbols) -value 0
  grid $w.o.append -row 0 -column 0 -sticky w
  grid $w.o.appendYes -row 0 -column 1 -sticky w
  grid $w.o.appendNo -row 0 -column 2 -sticky w
  grid $w.o.comments -row 1 -column 0 -sticky w
  grid $w.o.commentsOn -row 1 -column 1 -sticky w
  grid $w.o.commentsOff -row 1 -column 2 -sticky w
  grid $w.o.stripMarks -row 2 -column 0 -sticky w
  grid $w.o.stripMarksOn -row 2 -column 1 -sticky w
  grid $w.o.stripMarksOff -row 2 -column 2 -sticky w
  grid $w.o.indentc -row 3 -column 0 -sticky w
  grid $w.o.indentcOn -row 3 -column 1 -sticky w
  grid $w.o.indentcOff -row 3 -column 2 -sticky w
  grid $w.o.vars -row 4 -column 0 -sticky w
  grid $w.o.varsOn -row 4 -column 1 -sticky w
  grid $w.o.varsOff -row 4 -column 2 -sticky w
  grid $w.o.indentv -row 5 -column 0 -sticky w
  grid $w.o.indentvOn -row 5 -column 1 -sticky w
  grid $w.o.indentvOff -row 5 -column 2 -sticky w
  grid $w.o.column -row 6 -column 0 -sticky w
  grid $w.o.columnOn -row 6 -column 1 -sticky w
  grid $w.o.columnOff -row 6 -column 2 -sticky w
  grid $w.o.symbols -row 7 -column 0 -sticky w
  grid $w.o.symbolsOn -row 7 -column 1 -sticky w
  grid $w.o.symbolsOff -row 7 -column 2 -sticky w

  # Extra option for PGN format: handling of null moves
  if {$exportType == "PGN"} {
    label $w.o.space -text ""
    grid $w.o.space -row 8 -column 0 -sticky w
    label $w.o.nullMoves -text "Convert null moves to comments"
    radiobutton $w.o.convertNullMoves -text $::tr(Yes) \
        -variable exportFlags(convertNullMoves) -value 1
    radiobutton $w.o.keepNullMoves -text $::tr(No) \
        -variable exportFlags(convertNullMoves) -value 0
    grid $w.o.nullMoves -row 9 -column 0 -sticky w
    grid $w.o.convertNullMoves -row 9 -column 1 -sticky w
    grid $w.o.keepNullMoves -row 9 -column 2 -sticky w
  }

  # Extra option for HTML format: diagram image set
  if {$exportType == "HTML"} {
    label $w.o.space -text ""
    label $w.o.hdiag -text "Diagram"
    radiobutton $w.o.hb0 -text "bitmaps" \
        -variable exportFlags(htmldiag) -value 0
    radiobutton $w.o.hb1 -text "bitmaps2" \
        -variable exportFlags(htmldiag) -value 1
    label $w.o.hl0 -image htmldiag0
    label $w.o.hl1 -image htmldiag1
    grid $w.o.space -row 8 -column 0
    grid $w.o.hdiag -row 9 -column 0 -sticky w
    grid $w.o.hb0 -row 9 -column 1 -sticky w
    grid $w.o.hb1 -row 9 -column 2 -sticky w
    grid $w.o.hl0 -row 10 -column 1
    grid $w.o.hl1 -row 10 -column 2
  }

  addHorizontalRule $w
  pack [frame $w.b] -side top
  dialogbutton $w.b.ok -text "OK" -command {
    set exportFlags(ok) 1
  }
  dialogbutton $w.b.cancel -text $::tr(Cancel) -command {
    set exportFlags(ok) 0
  }
  pack $w.b.ok $w.b.cancel -side left -padx 5 -pady 5

  wm withdraw $w
  update idletasks
  set x [expr {[winfo screenwidth $w]/2 - [winfo reqwidth $w]/2 \
        - [winfo vrootx [winfo parent $w]]}]
  set y [expr {[winfo screenheight $w]/2 - [winfo reqheight $w]/2 \
        - [winfo vrooty [winfo parent $w]]}]
  wm geom $w +$x+$y
  wm deiconify $w

  grab $w
  tkwait variable exportFlags(ok)
  grab release $w
  destroy $w
  return $exportFlags(ok)
}

# exportGames:
#   exports current game or all filtered games to a new PGN, LaTeX or Html file.
#
proc exportGames {selection exportType} {
  global ::pgn::moveNumberSpaces exportStartFile exportEndFile exportFlags
  set exportFilter 0
  if {$selection == "filter"} { set exportFilter 1 }
  if {$exportFilter} {
    # Check that we have some games to export:
    if {![sc_base inUse]} {
      tk_messageBox -title "Scid: Empty database" -type ok -icon info \
          -message "This is an empty database, there are no games to export."
      return
    }
    if {[sc_filter count] == 0} {
      tk_messageBox -title "Scid: Filter empty" -type ok -icon info \
          -message "The filter contains no games."
      return
    }
  }

  if {[exportOptions $exportType] == 0} { return }
  sc_info html $exportFlags(htmldiag)

  switch -- $exportType {
    "PGN" {
      set ftype {
        { "PGN files" {".pgn"} }
        { "All files" {"*"} }
      }
      set title "a PGN file"
      set idir $::initialDir(base)
      set default ".pgn"
    }
    "HTML" {
      set ftype {
        { "HTML files" {".html" ".htm"} }
        { "All files" {"*"} }
      }
      set title "an HTML file"
      set idir $::initialDir(html)
      set default ".html"
    }
    "LaTeX" {
      set ftype {
        { "LaTeX files" {".tex" ".ltx"} }
        { "All files" {"*"} }
      }
      set title "a LaTeX file"
      set idir $::initialDir(tex)
      set default ".tex"
    }
    default { return }
  }

  if {$exportFlags(append)} {
    set getfile tk_getOpenFile
    set title "Add games to $title"
  } else {
    set getfile tk_getSaveFile
    set title "Create $title"
  }
  set fName [$getfile -initialdir $idir -filetypes $ftype \
      -defaultextension $default -title $title]
  if {$fName == ""} { return }

  if {$exportFilter} {
    progressWindow "Scid" "Exporting games..." $::tr(Cancel) "sc_progressBar"
  }
  busyCursor .
  sc_base export $selection $exportType $fName -append $exportFlags(append) \
      -starttext $exportStartFile($exportType) \
      -endtext $exportEndFile($exportType) \
      -comments $exportFlags(comments) -variations $exportFlags(vars) \
      -space $::pgn::moveNumberSpaces -symbols $exportFlags(symbols) \
      -indentC $exportFlags(indentc) -indentV $exportFlags(indentv) \
      -column $exportFlags(column) -noMarkCodes $exportFlags(stripMarks) \
      -convertNullMoves $exportFlags(convertNullMoves)
  unbusyCursor .
  if {$exportFilter} {
    closeProgressWindow
  }
}

proc copyFilter {frombaseNum tobaseNum} {
  ### This proc seems only called from the switcher, so parent all dialogs to .baseWin

  # Check status of source and target bases
  set currentBaseNum [sc_base current]
  sc_base switch $frombaseNum
  set nGamesToCopy [sc_filter count]
  set fromInUse [sc_base inUse]
  set fromName [file tail [sc_base filename]]
  sc_base switch $tobaseNum
  set targetInUse [sc_base inUse]
  set targetName [file tail [sc_base filename]]
  set targetReadOnly [sc_base isReadOnly]
  sc_base switch $currentBaseNum
  set err ""
  if {$nGamesToCopy == 0} {
    set err "$::tr(CopyErrSource) $::tr(CopyErrNoGames)."
  }
  if {$targetReadOnly} {
    set err "$::tr(CopyErrTarget) $::tr(CopyErrReadOnly)."
  }
  if {! $targetInUse} {set err "$::tr(CopyErrTarget) $::tr(CopyErrNotOpen)."}
  if {! $fromInUse} {set err "$::tr(CopyErrSource) $::tr(CopyErrNotOpen)."}
  if {$frombaseNum == $tobaseNum} {
    set err "$::tr(CopyErrSource) == $::tr(CopyErrTarget)."
  }

  if {$err != ""} {
    tk_messageBox -type ok -icon info -title "Scid" \
        -message "$::tr(CopyErr) \nfrom \"$fromName\" to \"$targetName\".\n$err" -parent .baseWin
    return
  }

  # If copying to the clipbase, do not bother asking for confirmation:
  if {$tobaseNum == [sc_info clipbase]} {
    progressWindow "Scid" "$::tr(CopyGames)..." $::tr(Cancel) "sc_progressBar"
    busyCursor .
    set copyErr [catch {sc_filter copy $frombaseNum $tobaseNum} result]
    unbusyCursor .
    closeProgressWindow
    if {$copyErr} {
      tk_messageBox -type ok -icon info -title "Scid" -message $result -parent .baseWin
    }
    return
  }

  set w [toplevel .fcopyWin]
  wm withdraw $w
  wm title $w "Scid: $::tr(CopyGames)"
  label $w.text -text [subst $::tr(CopyConfirm)]
  frame $w.b
  dialogbutton $w.b.go -text $::tr(CopyGames) -command "
    busyCursor .
    $w.b.cancel configure -command \"sc_progressBar\"
    $w.b.cancel configure -text $::tr(Stop)
    sc_progressBar $w.bar bar 301 21 time
    grab $w.b.cancel
    if {\[catch {sc_filter copy $frombaseNum $tobaseNum} result\]} {
      tk_messageBox -type ok -icon info \
	  -title \"Scid\" -message \$result -parent .baseWin
    }
    unbusyCursor .
    focus .
    destroy $w
    updateStatusBar"
  dialogbutton $w.b.cancel -text $::tr(Cancel) -command "focus .; destroy $w"
  canvas $w.bar -width 300 -height 20 -bg white -relief solid -border 1
  $w.bar create rectangle 0 0 0 0 -fill $::progcolor -outline $::progcolor -tags bar
  $w.bar create text 295 10 -anchor e -font font_Regular -tags time \
      -fill black -text "0:00 / 0:00"

  pack $w.text $w.b -side top -pady 5
  pack $w.bar -side bottom
  pack $w.b.go $w.b.cancel -side left -padx 10 -pady 10
  placeWinOverParent $w .baseWin
  wm state $w normal
  grab $w
  bind $w <Return> "$w.b.go invoke"
  bind $w <Escape> "$w.b.cancel invoke"
  focus $w.b.go
}


###########################################################################
### Global variables used in gameSave:
set date 0; set year 0; set month 0; set day 0; set white 0; set black 0
set resultVal 0; set event 0; set site 0; set round 0
set whiteElo 0; set blackElo 0; set eco 0; set extraTags ""
set whiteRType "Elo"; set blackRType "Elo"
set edate 0; set eyear 0; set emonth 0; set eday 0

# Traces on game-save dialog variables to ensure sane values:

trace variable resultVal w  ::utils::validate::Result
trace variable whiteElo w {::utils::validate::Integer [sc_info limit elo] 0}
trace variable blackElo w {::utils::validate::Integer [sc_info limit elo] 0}
trace variable year w {::utils::validate::Integer [sc_info limit year] 1}
trace variable month w {::utils::validate::Integer 12 1}
trace variable day w {::utils::validate::Integer 31 1}
trace variable eyear w {::utils::validate::Integer [sc_info limit year] 1}
trace variable emonth w {::utils::validate::Integer 12 1}
trace variable eday w {::utils::validate::Integer 31 1}

set gsaveNum 0
set i 0; set j 0
set temp 0

array set nameMatches {}
set nameMatchCount 0

# updateMatchList:
#    Called from gameSave to update the matching name list as the user
#    types a player/site/event/round name.

proc updateMatchList { tw nametype maxMatches name el op } {
  global nameMatches nameMatchCount
  global $name editNameType
  if {![winfo exists $tw]} return

  if {$nametype == ""} { set nametype $editNameType }
  if {$nametype == "rating"} { set nametype "player" }
  set val [set $name]
  $tw configure -state normal
  $tw delete 0.0 end
  set matches {}
  catch {set matches [sc_name match $nametype $val $maxMatches]}
  set count [llength $matches]
  set nameMatchCount [expr {$count / 2}]
  for {set i 0} { $i < $count } {incr i 2} {
    set nameMatchCount [expr {($i / 2) + 1}]
    set nameMatches($nameMatchCount) [lindex $matches [expr {$i + 1}]]
    set str "$nameMatchCount:\t[lindex $matches $i]\t$nameMatches($nameMatchCount)\n"
    $tw insert end $str
  }
  $tw configure -state disabled
}

proc clearMatchList { tw } {
  global nameMatches nameMatchCount
  set nameMatchCount 0
  $tw configure -state normal
  $tw delete 0.0 end
  $tw configure -state disabled
}

# Traces to update the match list as names are typed in:

trace variable event w { updateMatchList .save.g.list e 9 }
trace variable site  w { updateMatchList .save.g.list s 9 }
trace variable white w { updateMatchList .save.g.list p 9 }
trace variable black w { updateMatchList .save.g.list p 9 }
trace variable round w { updateMatchList .save.g.list r 9 }

set editName ""
set editNameNew ""
set editNameType "player"
set editNameSelect "all"
set editNameRating ""
set editNameRType "Elo"
set editDate ""
set editDateNew ""

trace variable editNameRating w {::utils::validate::Integer [sc_info limit elo] 0}
trace variable editName w { updateMatchList .nedit.g.list "" 9 }
trace variable editDate w ::utils::validate::Date
trace variable editDateNew w ::utils::validate::Date

proc editNameNewProc { tw nametype maxMatches name el op } {
  global editNameNew
  if {! [winfo exists .nedit]} { return }
  if {[string compare $editNameNew ""]} {
    .nedit.buttons.replace configure -state normal
  } else {
    .nedit.buttons.replace configure -state disabled
  }
  catch {updateMatchList $tw $nametype $maxMatches $name $el $op}
}

trace variable editNameNew w { editNameNewProc .nedit.g.list "" 9 }


set nameEditorWin 0

proc makeNameEditor {} {
  if {! [winfo exists .nedit]} { nameEditor }
}

proc setNameEditorType {type} {
  if {! [winfo exists .nedit]} { return }
  catch {.nedit.typeButtons.$type invoke}
}

proc nameEditor {} {
  global editName editNameType editNameNew nameEditorWin editNameSelect
  global editNameRating editDate editDateNew

  set w .nedit
  if {[winfo exists $w]} {
    destroy $w
    return
  }
  toplevel $w
  wm title $w "Scid: [tr FileMaintNameEditor]"
  set nameEditorWin 1
  setWinLocation $w
  bind $w <Configure> "recordWinSize $w"

  label $w.typeLabel -textvar ::tr(NameEditType:) -font font_Bold
  frame $w.typeButtons
  pack $w.typeLabel $w.typeButtons -side top -pady 5
  foreach i { "Player" "Event" "Site" "Round"} {
    set j [string tolower $i]
    radiobutton $w.typeButtons.$j -textvar ::tr($i) -variable editNameType \
        -value $j -indicatoron false -pady 5 -padx 5 -command {
          grid remove .nedit.g.ratingE
          grid remove .nedit.g.rtype
          grid remove .nedit.g.fromD
          grid remove .nedit.g.toD
          grid .nedit.g.toL -row 1 -column 1 -sticky e
          grid .nedit.g.fromE -row 0 -column 2 -sticky w
          grid .nedit.g.toE -row 1 -column 2 -sticky w
        }
    pack $w.typeButtons.$j -side left -padx 5
  }
  radiobutton $w.typeButtons.rating -textvar ::tr(Rating) -variable editNameType \
      -value rating -indicatoron false -pady 5 -padx 5 -command {
        grid remove .nedit.g.toE
        grid remove .nedit.g.toL
        grid remove .nedit.g.fromD
        grid remove .nedit.g.toD
        grid .nedit.g.fromE -row 0 -column 2 -sticky w
        grid .nedit.g.rtype -row 1 -column 0 -columnspan 2 -sticky e
        grid .nedit.g.ratingE -row 1 -column 2 -sticky w
      }
  radiobutton $w.typeButtons.date -textvar ::tr(Date) -variable editNameType \
      -value date -indicatoron false -pady 5 -padx 5 -command {
        grid remove .nedit.g.toE
        grid remove .nedit.g.fromE
        grid remove .nedit.g.ratingE
        grid remove .nedit.g.rtype
        grid .nedit.g.fromD -row 0 -column 2 -sticky w
        grid .nedit.g.toL -row 1 -column 1 -sticky e
        grid .nedit.g.toD -row 1 -column 2 -sticky w
      }
  radiobutton $w.typeButtons.edate -textvar ::tr(EventDate) \
      -variable editNameType -value edate -indicatoron false -pady 5 -padx 5 \
      -command {
        grid remove .nedit.g.toE
        grid remove .nedit.g.fromE
        grid remove .nedit.g.ratingE
        grid remove .nedit.g.rtype
        grid .nedit.g.fromD -row 0 -column 2 -sticky w
        grid .nedit.g.toL -row 1 -column 1 -sticky e
        grid .nedit.g.toD -row 1 -column 2 -sticky w
      }
  pack $w.typeButtons.rating $w.typeButtons.date $w.typeButtons.edate \
      -side left -padx 5

  addHorizontalRule .nedit

  label $w.selectLabel -textvar ::tr(NameEditSelect) -font font_Bold
  frame $w.selectButtons
  pack $w.selectLabel $w.selectButtons -side top -pady 5
  foreach i {all filter crosstable} row {0 1 2} text {
    SelectAllGames
    SelectFilterGames
    SelectTournamentGames
  } {
    radiobutton $w.selectButtons.$i -textvar ::tr($text) \
        -variable editNameSelect -value $i
    grid $w.selectButtons.$i -row $row -column 0 -sticky w
  }

  addHorizontalRule $w

  pack [frame $w.g] -side top
  label $w.g.space -text "    "
  grid $w.g.space $w.g.space -row 0 -column 0
  label $w.g.fromL -textvar ::tr(NameEditReplace:) -font font_Bold -anchor e
  entry $w.g.fromE -width 40  -relief sunken \
      -textvariable editName
  entry $w.g.fromD -width 15  -relief sunken \
      -textvariable editDate
  grid $w.g.fromL -row 0 -column 1 -sticky e
  grid $w.g.fromE -row 0 -column 2 -sticky we

  label $w.g.toL -textvar ::tr(NameEditWith:) -font font_Bold -anchor e
  entry $w.g.toE -width 40  -relief sunken \
      -textvariable editNameNew
  entry $w.g.toD -width 15  -relief sunken \
      -textvariable editDateNew
  grid $w.g.toL -row 1 -column 1 -sticky e
  grid $w.g.toE -row 1 -column 2 -sticky we

  entry $w.g.ratingE -width 5  -relief sunken \
      -textvariable editNameRating -justify right
  eval tk_optionMenu $w.g.rtype editNameRType [sc_info ratings]
  $w.g.rtype configure -pady 2

  label $w.g.title -textvar ::tr(NameEditMatches) \
      -font font_Bold
  text $w.g.list -height 9 -width 40 -relief sunken \
      -background grey90 -tabs {2c right 2.5c left} -wrap none

  label $w.g.padding -text ""
  grid $w.g.padding -row 2 -column 0

  grid $w.g.title -row 3 -column 1 -columnspan 2 -sticky n
  grid $w.g.list -row 4 -column 1 -rowspan 9 -columnspan 2 -sticky n

  updateMatchList $w.g.list "" 9 editName "" w

  foreach i {fromE toE ratingE fromD toD} {
    bind $w.g.$i <FocusIn> { %W configure -background lightYellow }
    bind $w.g.$i <FocusOut> { %W configure -background white }
  }
  foreach {i j} {.nedit.g.fromE "editName"  .nedit.g.toE "editNameNew" } {
    for {set z 1} {$z <= 9} {incr z} {
      bind $i [format "<Control-Key-%d>" $z] \
          [format "eval {if {\$nameMatchCount >= %d} { \
              set %s \$nameMatches(%d)}}; break" $z $j $z ]
    }
  }

  addHorizontalRule $w

  frame $w.buttons
  button $w.buttons.replace -textvar ::tr(NameEditReplace) -command {
    if {$editNameType == "rating"} {
      set err [catch {sc_name edit $editNameType $editNameSelect $editName $editNameRating $editNameRType} result]
    } elseif {$editNameType == "date"  ||  $editNameType == "edate"} {
      set err [catch {sc_name edit $editNameType $editNameSelect $editDate $editDateNew} result]
    } else {
      set err [catch {sc_name edit $editNameType $editNameSelect $editName $editNameNew} result]
    }
    if {$err} {
      tk_messageBox -type ok -icon info -parent .nedit -title "Scid" \
          -message $result
    } else {
      .nedit.status configure -text $result
    }
    sc_game tags reload
    updateBoard -pgn
    ::windows::gamelist::Refresh
  }

  dialogbutton $w.buttons.cancel -textvar ::tr(Close) -command {focus .; destroy .nedit}
  pack $w.buttons -side top -pady 5
  pack $w.buttons.replace $w.buttons.cancel -side left -padx 10

  label $w.status -text "" -width 1 -font font_Small -relief sunken -anchor w
  pack $w.status -side bottom -fill x

  wm resizable $w 0 0
  bind $w <Escape> { focus .; destroy .nedit }
  bind $w <Return> {.nedit.buttons.replace invoke}
  bind $w <Destroy> {set nameEditorWin 0}
  bind $w <F1> {helpWindow Maintenance Editing}
  standardShortcuts $w
  focus $w
  $w.typeButtons.$editNameType invoke
}


# addGameSaveEntry:
#   used in gameSave for setting up the simpler labels and entry boxes.
#
proc addGameSaveEntry { name row textname } {
  label .save.g.label$name -textvar $textname
  entry .save.g.entry$name -width 30  -relief sunken \
      -textvariable $name
  grid .save.g.label$name -row $row -column 0 -sticky w
  grid .save.g.entry$name -row $row -column 1 -columnspan 7 -sticky w
}

# gameSave:
#   The game save dialog. Used for adding and replacing games. If the
#   value gnum is zero, it is to add a new game; otherwise it is to
#   replace game number gnum.
#
proc gameSave {gnum} {
  global date year month day white black resultVal event site round
  global whiteElo blackElo whiteRType blackRType eco extraTags gsaveNum
  global edate eyear emonth eday

  if {![sc_base inUse]} {
    # We can't load a game, no database is open
    tk_messageBox -title "Scid: No database open" -type ok -icon info \
        -message "No database is open; open or create one first."
    return
  }

  if {[sc_base isReadOnly]} {
    tk_messageBox -type ok -icon error -title "Scid: Error" \
      -message "Database \"[file tail [sc_base filename]]\" is read-only."
    return
  }

  set w .save

  toplevel $w
  # bad !; catch {grab $w}

  if {$gnum == 0} {
    wm title $w "[tr GameAdd]"
  } else {
    wm title $w "[tr GameReplace]"
  }
  set gsaveNum $gnum

  # frame $f holds everything except save/cancel buttons 
  set f [frame $w.g]
  pack $f -side top

  # Get current values of tags:
  set year [sc_game tag get Year];    set eyear [sc_game tag get EYear]
  set month [sc_game tag get Month];  set emonth [sc_game tag get EMonth]
  set day [sc_game tag get Day];      set eday [sc_game tag get EDay]
  set white [sc_game tag get White];  set black [sc_game tag get Black]
  set event [sc_game tag get Event];  set site [sc_game tag get Site]
  set resultVal [sc_game tag get Result];  set round [sc_game tag get Round]
  set whiteElo [sc_game tag get WhiteElo]
  set blackElo [sc_game tag get BlackElo]
  set whiteRType [sc_game tag get WhiteRType]
  set blackRType [sc_game tag get BlackRType]
  set eco [sc_game tag get ECO];  set extraTags [sc_game tag get Extra]

  # Use question marks instead of zero values in date:
  if {$year == 0} { set year "????" }
  if {$month == 0} { set month "??" }
  if {$day == 0} { set day "??" }
  if {$eyear == 0} { set eyear "????" }
  if {$emonth == 0} { set emonth "??" }
  if {$eday == 0} { set eday "??" }

  addGameSaveEntry event 0 ::tr(Event:)
  addGameSaveEntry site 1 ::tr(Site:)

  frame $f.dateframe
  label $f.datelabel -textvar ::tr(Date:)
  entry $f.dateyear -width 6  -relief sunken \
      -textvariable year -justify right
  label $f.datedot1 -text "."
  entry $f.datemonth -width 3  -relief sunken \
      -textvariable month -justify right
  label $f.datedot2 -text "."
  entry $f.dateday -width 3  -relief sunken \
      -textvariable day -justify right
  grid $f.datelabel -row 2 -column 0 -sticky w
  grid $f.dateframe -row 2 -column 1 -columnspan 5 -sticky w
  button $f.datechoose -image ::utils::date::calendar -command {
    set newdate [::utils::date::chooser "$year-$month-$day" .save]
    if {[llength $newdate] == 3} {
      set year [lindex $newdate 0]
      set month [lindex $newdate 1]
      set day [lindex $newdate 2]
    }
  }
  button $f.today -textvar ::tr(Today) -command {
    set year [::utils::date::today year]
    set month [::utils::date::today month]
    set day [::utils::date::today day]
  }
  pack $f.dateyear $f.datedot1 $f.datemonth $f.datedot2 $f.dateday \
      -in $f.dateframe -side left
  pack $f.datechoose -in $f.dateframe -side left -padx 3
  pack $f.today -in $f.dateframe -side left

  frame $f.edateframe
  label $f.edatelabel -textvar ::tr(EventDate:)
  entry $f.edateyear -width 6  -relief sunken \
      -textvariable eyear -justify right
  label $f.edatedot1 -text "."
  entry $f.edatemonth -width 3  -relief sunken \
      -textvariable emonth -justify right
  label $f.edatedot2 -text "."
  entry $f.edateday -width 3  -relief sunken \
      -textvariable eday -justify right
  grid $f.edatelabel -row 3 -column 0 -sticky w
  grid $f.edateframe -row 3 -column 1 -columnspan 5 -sticky w
  button $f.edatechoose -image ::utils::date::calendar -command {
    set newdate [::utils::date::chooser "$eyear-$emonth-$eday" .save]
    if {[llength $newdate] == 3} {
      set eyear [lindex $newdate 0]
      set emonth [lindex $newdate 1]
      set eday [lindex $newdate 2]
    }
  }
  button $f.esame -text "=$::tr(Date)" -command {
    set eyear $year
    set emonth $month
    set eday $day
  }
  pack $f.edateyear $f.edatedot1 $f.edatemonth $f.edatedot2 $f.edateday \
      -in $f.edateframe -side left
  pack $f.edatechoose -in $f.edateframe -side left -padx 3
  pack $f.esame -in $f.edateframe -side left

  addGameSaveEntry round 4 ::tr(Round:)
  addGameSaveEntry white 5 ::tr(White:)
  addGameSaveEntry black 6 ::tr(Black:)

  # Game result

  ttk::label $f.reslabel -textvar ::tr(Result:)
  ttk::combobox $f.resentry -values {1 0 = *} -width 7 \
    -textvariable resultVal -state readonly
  grid $f.reslabel -row 7 -column 0 -sticky w
  grid $f.resentry -row 7 -column 1 -sticky w

  # White/Black Elo

  ttk::label $f.welolabel -text "$::tr(White) "
  ttk::combobox $f.wrtype -values [sc_info ratings] -width 7 \
    -textvariable whiteRType -state readonly
  ttk::entry $f.weloentry -width 6 -textvariable whiteElo -justify right
  
  ttk::label $f.belolabel -text "$::tr(Black) "
  ttk::combobox $f.brtype -values [sc_info ratings] -width 7 \
    -textvariable blackRType -state readonly
  ttk::entry $f.beloentry -width 6 -textvariable blackElo -justify right

  grid $f.welolabel -row 8 -column 0 -sticky w
  grid $f.wrtype -row 8 -column 1 -sticky w
  grid $f.weloentry -row 8 -column 2 -sticky w
  grid $f.belolabel -row 9 -column 0 -sticky w
  grid $f.brtype -row 9 -column 1 -sticky w
  grid $f.beloentry -row 9 -column 2 -sticky w

  # Eco

  label $f.ecolabel -text "ECO Code:"
  ttk::entry $f.ecoentry -width 6  -textvariable eco -justify right
  grid $f.ecolabel -row 10 -column 0 -sticky w
  grid $f.ecoentry -row 10 -column 2 -sticky w

  ttk::button $f.ecob -textvar ::tr(Classify) -command {set eco [sc_eco game]} -width 8 -takefocus 0
  grid $f.ecob -row 10 -column 1 -sticky w

  # Autocomplete text widget and label

  text $f.list -height 9 -width 40 -relief sunken -background grey90 \
      -tabs {2c right 2.5c left} -wrap none
  clearMatchList $f.list

  label $f.title -textvar ::tr(NameEditMatches) -font font_Italic

  grid $f.list -row 0 -rowspan 7 -column 8 -columnspan 2 -sticky nsew -padx 10
  grid $f.title -row 7           -column 8 -columnspan 2 -sticky n -padx 10

  # Extra tags text widget+scrollbar (in frame)

  frame $f.extra
  grid $f.extra -row 8 -rowspan 2 -column 8 -columnspan 2 -padx 10

  text $f.extratext -height 2 -width 40 -wrap none -yscrollcommand "$f.extrascroll set"
  # Override tab-binding for this text widget
  bind $f.extratext <Key-Tab> "[bind all <Key-Tab>]; break"
  $f.extratext insert 1.0 $extraTags

  scrollbar $f.extrascroll -command "$f.extratext yview" -takefocus 0

  pack $f.extratext   -in $f.extra -side left -fill both -expand 1
  pack $f.extrascroll -in $f.extra -side right -fill y

  # Extra tags label+button (below)

  label $f.extralabel -text {Extra tags (eg: Annotator "Anand")} -font font_Italic
  grid $f.extralabel -row 10 -column 8  -sticky n -pady 3

  ttk::button $f.extrabutton -text "Use prev tags" -command {
    set extraTags [sc_game tag get -last Extra]
    .save.g.extratext delete 1.0 end
    .save.g.extratext insert 1.0 $extraTags
  }
  if {$gnum == 0} {
    grid $f.extrabutton -row 10 -column 9 -sticky ew -pady 3
  }

  # <Return> invokes "save"

  foreach i {entryevent entrysite dateyear datemonth dateday \
	     entryround entrywhite entryblack resentry \
	     weloentry beloentry ecoentry edateyear edatemonth edateday} {
    bind $f.$i <Return> "$w.buttons.save invoke"
  }

  # Bindings so Ctrl-1 to Ctrl-9 select a matching name in the player,
  # site, event and round entryboxes:

  set j 0
  foreach {i j} { \
    entryevent "event"
    entrysite  "site"
    entrywhite "white"
    entryblack "black"
    entryround "round" } {
    for {set z 1} {$z <= 9} {incr z} {
      bind $f.$i [format "<Control-Key-%d>" $z] \
          [format "eval {if {\$nameMatchCount >= %d} \
            {set %s \$nameMatches(%d)}}" $z $j $z ]
    }
  }

  # Divider
  pack [frame $w.bar -height 2 -borderwidth 1 -relief sunken] -fill x -pady 5

  # Save/Cancel buttons

  frame $w.buttons
  if {$gnum == 0} {
    button $w.buttons.prev -text "As last game" -command {
    }
  }
  dialogbutton $w.buttons.save -textvar ::tr(Save) -underline 0 -command {
    set extraTags [.save.g.extratext get 1.0 end-1c]
    gsave $gsaveNum;
    destroy .save
  }

  dialogbutton $w.buttons.cancel -textvar ::tr(Cancel) -command "destroy $w"
  pack $w.buttons -side bottom -pady 10 -fill x
  if {$gnum == 0} {
    #pack .save.buttons.prev -side left -padx 10
  }
  packbuttons right $w.buttons.cancel $w.buttons.save

  bind $w <Alt-s> {
    set extraTags [.save.g.extratext get 1.0 end-1c]
    gsave $gsaveNum;
    focus .
    destroy .save
    break
  }
  bind $w <Escape> {
    focus .
    destroy .save
  }

  placeWinOverParent $w .

  if {$gnum > 0} { focus .save.buttons.save }
}

# gsave:
#    Called by gameSave when the user presses the "Save" button
#    to save the game. Attempts to save and reports the result.
#
proc gsave { gnum } {
  global date year month day white black resultVal event site round
  global whiteElo blackElo whiteRType blackRType eco extraTags
  global edate eyear emonth eday

  set date [format "%s.%s.%s" $year $month $day]
  set edate [format "%s.%s.%s" $eyear $emonth $eday]
  set extraTagsList [split $extraTags "\n"]
  sc_game tags set -event $event -site $site -date $date -round $round \
      -white $white -black $black -result $resultVal \
      -whiteElo $whiteElo -whiteRatingType $whiteRType \
      -blackElo $blackElo -blackRatingType $blackRType \
      -eco $eco -eventdate $edate -extra $extraTagsList
  set res [sc_game save $gnum]
  if {$res != {}} {
    tk_messageBox -type ok -icon info -parent .save -title "Scid" -message $res
  }
  updateBoard -pgn
  ::windows::gamelist::Refresh
  updateTitle
}

# gameAdd:
#   Calls gameSave with a game number of zero.
#
proc gameAdd {} { gameSave 0 }

# gameReplace:
#   Calls gameSave with the current game number, which should be nonzero.

proc gameReplace {} { gameSave [sc_game number] }


############################################################
#### Square Bindings &&&

# Pascal Georges : allow the drawing of markers directly on the board (not through comment editor)
set startArrowSquare ""

proc addMarker {sq color} {
  set to [::board::san $sq]
  set oldComment [sc_pos getComment]

  # check if the square is already of the same color
  set erase [regexp "\[\x5B\]%draw full,$to,$color\[\x5D\]" $oldComment]
  regsub "\[\x5B\]%draw full,$to,(green|yellow|red)\[\x5D\]" $oldComment "" newComment
  set newComment [string trim $newComment]
  if {!$erase} {
    append newComment " \[%draw full,$to,$color\]"
  }
  sc_pos setComment $newComment
  ::pgn::Refresh 1
  updateBoard
}

proc drawArrow {sq color} {
  global startArrowSquare
  if {$startArrowSquare == ""} {
    set startArrowSquare [::board::san $sq]
  } else  {
    set oldComment [sc_pos getComment]
    set to [::board::san $sq]
    if {$startArrowSquare != $to } {
      set erase [regexp "\[\x5B\]%draw arrow,$startArrowSquare,$to,$color\[\x5D\]" $oldComment]
      regsub "\[\x5B\]%draw arrow,$startArrowSquare,$to,(green|yellow|red)\[\x5D\]" $oldComment "" newComment
      set newComment [string trim $newComment]
      if {!$erase} {
        append newComment " \[%draw arrow,$startArrowSquare,$to,$color\]"
      }
      sc_pos setComment $newComment
      ::pgn::Refresh 1
      updateBoard
    }
    set startArrowSquare ""
  }
}

for {set i 0} { $i < 64 } { incr i } {
  ::board::bind .board $i <Enter> "enterSquare $i"
  ::board::bind .board $i <Leave> "leaveSquare $i"
  ::board::bind .board $i <ButtonPress-1> "pressSquare $i 0"
  ::board::bind .board $i <ButtonPress-2> "pressSquare $i 1"
  # ::board::bind .board $i <Control-ButtonPress-1> "drawArrow $i green"
  # ::board::bind .board $i <Control-ButtonPress-2> "drawArrow $i yellow"
  # ::board::bind .board $i <Control-ButtonPress-3> "drawArrow $i red"
  # ::board::bind .board $i <Shift-ButtonPress-1> "addMarker $i green"
  # ::board::bind .board $i <Shift-ButtonPress-2> "addMarker $i yellow"
  # ::board::bind .board $i <Shift-ButtonPress-3> "addMarker $i red"
  ::board::bind .board $i <B1-Motion> "::board::dragPiece %X %Y"
  ::board::bind .board $i <ButtonRelease-1> "releaseSquare %X %Y"
  ::board::bind .board $i <ButtonRelease-2> "releaseSquare %X %Y"

  ### Too dangerous. (backSquare deprecated for ::move::Back) S.A.
  # ::board::bind .board $i <ButtonPress-3> backSquare
}

foreach i {o q r n k O Q R B N K} {
  bind . <$i> "moveEntry_Char [string toupper $i]"
}
foreach i {a b c d e f g h 1 2 3 4 5 6 7 8} {
  bind . <Key-$i> "moveEntry_Char $i"
}

bind . <Control-BackSpace> ::move::Back
bind . <Control-Delete> ::move::Back
bind . <BackSpace> moveEntry_Backspace
bind . <Delete> moveEntry_Backspace
bind . <space> moveEntry_Complete


###  Other Key bindings:

# Bindings for quick move annotation entry in the main window:

bind . <exclam><Return> "sc_pos addNag !; updateBoard -pgn"
bind . <exclam><exclam><Return> "sc_pos addNag !!; updateBoard -pgn"
bind . <exclam><question><Return> "sc_pos addNag !?; updateBoard -pgn"
bind . <question><Return> "sc_pos addNag ?; updateBoard -pgn"
bind . <question><question><Return> "sc_pos addNag ??; updateBoard -pgn"
bind . <question><exclam><Return> "sc_pos addNag ?!; updateBoard -pgn"

bind . <plus><minus> "sc_pos addNag +-; updateBoard -pgn"
bind . <plus><slash> "sc_pos addNag +/-; updateBoard -pgn"
bind . <plus><equal> "sc_pos addNag +=; updateBoard -pgn"
bind . <equal><Return> "sc_pos addNag =; updateBoard -pgn"
bind . <minus><plus> "sc_pos addNag -+; updateBoard -pgn"
bind . <minus><slash> "sc_pos addNag -/+; updateBoard -pgn"
bind . <equal><plus> "sc_pos addNag =+; updateBoard -pgn"
bind . <asciitilde><Return> "sc_pos addNag ~; updateBoard -pgn"
bind . <asciitilde><equal><Return> "sc_pos addNag ~=; updateBoard -pgn"

# Null move entry:
bind . <minus><minus> "addMove null null"

# Arrow keys, Home and End:
bind . <Home> ::move::Start
bind . <Left> ::move::Back
bind . <Up> {
  if {[sc_pos isAt vstart]} {
    .button.exitVar invoke
  } else  {
    ::move::Back 10
  }
}
bind . <Down> {::move::Forward 10}
bind . <Right> ::move::Forward
bind . <End> ::move::End

bind . <Control-f> {if {!$tree(refresh)} {toggleRotateBoard}}

# MouseWheel in main window:
if {$windowsOS} {
  bind . <MouseWheel> {
    if {[expr -%D] < 0} { ::move::Back }
    if {[expr -%D] > 0} { ::move::Forward }
  }
  bind . <Shift-MouseWheel> {
    if {[expr -%D] < 0} { ::move::Back 10 }
    if {[expr -%D] > 0} { ::move::Forward 10}
  }
  bind . <Control-MouseWheel> {
    if {[expr -%D] < 0} {::board::resize .board +1}
    if {[expr -%D] > 0} {::board::resize .board -1}
  }
} else {
  bind . <Button-4> ::move::Back
  bind . <Button-5> ::move::Forward
  bind . <Shift-Button-4> {::move::Back 10}
  bind . <Shift-Button-5> {::move::Forward 10}
  bind . <Control-Button-4> {::board::resize .board +1}
  bind . <Control-Button-5> {::board::resize .board -1}
}

# Apply standard shortcuts to main window
standardShortcuts .

############################################################
### Packing the main window &&&

label .statusbar -textvariable statusBar -relief sunken -anchor w -width 1 -font font_Small

grid .statusbar -row 4 -column 0 -columnspan 3 -sticky we

if {!$::gameInfo(showStatus)} {
  grid remove .statusbar
}

#frame .sep -width 2 -borderwidth 2 -relief groove
#frame .panels
#grid .boardframe -row 1 -column 0 -columnspan 3 -sticky news
#grid .sep -row 1 -column 1 -rowspan 3 -sticky ns -padx 4
#grid .panels -row 1 -column 2 -rowspan 3 -sticky news -pady 2

grid columnconfigure . 0 -weight 1
grid rowconfigure . 3 -weight 1

grid .button -row 1 -column 0 -pady 5 -padx 5

if {!$::gameInfo(showButtons)} {
  grid remove .button
}

grid .board -row 2 -column 0 -sticky we -padx 5 -pady 5

# grid .gameInfoFrame -row 3 -column 0 -sticky news -padx 2
showGameInfo

#set p .panels
#::utils::pane::Create $p.pane top bottom 200 100 0.3
#pack $p.pane -side top -fill both -expand yes
#label $p.pane.top.db -font font_Bold -foreground white -background darkBlue -text "Databases" -anchor w
#pack $p.pane.top.db -side top -fill x
#autoscrollframe -bars y $p.pane.top.f canvas $p.pane.top.f.c
#pack $p.pane.top.f -side top -fill both -expand yes

#label $p.pane.bottom.title -font font_Bold -foreground white -background darkBlue -text "Notation" -anchor w
#pack $p.pane.bottom.title -side top -fill x
#autoscrollframe -bars y $p.pane.bottom.f text $p.pane.bottom.f.text -width 0
#pack $p.pane.bottom.f -side top -fill both -expand yes
#::htext::init $p.pane.bottom.f.text

redrawToolbar

### Wish 8.5 has a nice fullscreen feature.
### just press F11 in KDE , or use [wm attribute . -fullscreen 1]
# wm resizable . 0 1
# wm minsize . 0 0
wm iconname . Scid

#################
# Open files and databases:

# Check for arguments starting with "-" (or "/" on Windows):

set loadAtStart(spell) 1
set loadAtStart(eco) 1
set loadAtStart(tb) 1

proc getCommandLineOptions {} {
  global argc argv windowsOS loadAtStart

  if { $::macOS && ([string first "-psn" [lindex $argv 0]] == 0)} {
    # Remove Process Serial Number from argument list:
    set argv [lrange $argv 1 end]
    incr argc -1
  }

  while {$argc > 0} {
    set arg [lindex $argv 0]
    set firstChar [string index $arg 0]
    if {$firstChar == "-"  ||  ($windowsOS  &&  $firstChar == "/")} {
      # Seen option argument:
      incr argc -1
      set argv [lrange $argv 1 end]
      
      # Special argument "--" means no more options:
      if {$arg == "--"} { return }
      
      # Check for known option names:
      #   -f (/f), -fast (/fast): Fast start with no tablebases, etc.
      #   -xeco, -xe: Do not load ECO file.
      #   -xspell, -xs: Do not load spellcheck file.
      #   -xtb, -xt: Do not check tablebase directory.
      
      set argName [string range $arg 1 end]

      switch -glob -- $argName {
        -*   {
         puts "
$::scidName Version $::scidVersion ($::scidVersionDate)
Based on: Shane's Chess Information Database
Using Tcl/Tk version: [info patchlevel]

Author: Shane Hudson
Contribution: Pascal Georges
$::scidName: Steven Atkinson
Email: stevenaaus@yahoo.com
Http://scidvspc.sourceforge.net
"
          exit
        }
        "f"    -
        "fast" {
          ::splash::add "Fast start: no tablebases, ECO or spelling file loaded."
          set loadAtStart(spell) 0
          set loadAtStart(eco) 0
          set loadAtStart(tb) 0
        }
        "xt" -
        "xtb" {
          set loadAtStart(tb) 0
        }
        "xe" -
        "xeco" {
          set loadAtStart(eco) 0
        }
        "xs" -
        "xspell" {
          set loadAtStart(spell) 0
        }
        "s1"  { set ::boardSize 21 }
        "s2"  { set ::boardSize 25 }
        "s3"  { set ::boardSize 29 }
        "s4"  { set ::boardSize 33 }
        "s5"  { set ::boardSize 37 }
        "s6"  { set ::boardSize 40 }
        "s7"  { set ::boardSize 45 }
        "s8"  { set ::boardSize 49 }
        "s9"  { set ::boardSize 54 }
        "s10" { set ::boardSize 58 }
        "s11" { set ::boardSize 64 }
        "s12" { set ::boardSize 72 }
        default {
          ::splash::add "Warning: unknown option: \"$arg\"" error
        }
      }
    } else {
      # Seen first non-option argument:
      return
    }
  }
}

getCommandLineOptions

setLanguage $language

updateTitle
updateBoard
updateStatusBar
update idle

# Try to find tablebases:
if {$loadAtStart(tb)} {
  if {[sc_info tb]} {
    ::splash::add "Checking for endgame tablebase files..."
    set tbDirs {}
    foreach i {1 2 3 4} {
      if {$initialDir(tablebase$i) != ""} {
        if {$tbDirs != ""} { append tbDirs ";" }
        append tbDirs [file nativename $initialDir(tablebase$i)]
      }
    }
    set result 0
    if {$tbDirs != ""} {
      set result [sc_info tb $tbDirs]
    }
    if {$result == 0} {
      ::splash::add "    No tablebases were found."
    } else {
      ::splash::add "    Tablebases with up to $result pieces were found."
    }
  }
}

# Try to open the ECO classification file:
set result 0
set ecoFile_fullname [file nativename $ecoFile]

if {$loadAtStart(eco)} {
  ::splash::add "Trying to load the ECO openings file..."
  if {[catch { sc_eco read $ecoFile_fullname } result]} {
    # Could not load, so try "scid.eco" in the current directory:
    if {[catch {sc_eco read "scid.eco"} result]} {
      # Neither attempt worked, so do not use ECO classification
      ::splash::add "    Unable to open the ECO file: $ecoFile"
    } else {
      ::splash::add "    ECO file \"./scid.eco\" loaded: $result positions."
    }
  } else {
    ::splash::add "    ECO file \"[file tail $ecoFile_fullname]\"  loaded: $result positions."
  }
}

### Try to load the spellcheck file:

set spellCheckFileExists 0
if {$loadAtStart(spell)} {
  if {[catch {sc_name read $spellCheckFile} result]} {
    ::splash::add "Unable to load the default spellcheck file: $spellCheckFile"
  } else {
    ::splash::add "Spellcheck file \"[file tail $spellCheckFile]\" loaded:"
    ::splash::add "    [lindex $result 0] players, [lindex $result 1] events, [lindex $result 2] sites, [lindex $result 3] rounds."
    set spellCheckFileExists 1
  }
}

# fullname:
#   Given a file name, returns its absolute name.
#
proc fullname {fname} {
  if {[file pathtype $fname] == "absolute"} { return $fname }
  set old [pwd]
  if {[catch {cd [file dirname $fname]}]} { return $fname }
  set fname [file join [pwd] [file tail $fname]]
  catch {cd $old}
  return $fname
}

# Loading a database if specified on the command line:
# Need to check file type: .epd, .pgn, .pgn.gz, etc

while {$argc > 0} {
  set startbase [fullname [lindex $argv 0]]
  if {! [catch {sc_game startBoard $startbase}]} {
    set argc 0
    break
  }
  if {! [catch {sc_game startBoard [join $argv " "]}]} {
    set argc 0
    break
  }
  if {[string match "*.epd*" $startbase]} {
    ::splash::add "Opening EPD file: $startbase..."
    if {![newEpdWin openSilent $startbase]} {
      ::splash::add "   Error opening EPD file: $startbase" error
    }
    set initialDir(epd) [file dirname $startbase]
  } elseif {[string match "*.sso" $startbase]} {
    ::splash::add "Opening filter file: $startbase..."
    if {[catch {uplevel "#0" source $startbase} err]} {
      ::splash::add "   Error opening $startbase: $err" error
    } else {
      switch -- $::searchType {
        "Material" {
          sc_search material \
            -wq [list $pMin(wq) $pMax(wq)] -bq [list $pMin(bq) $pMax(bq)] \
            -wr [list $pMin(wr) $pMax(wr)] -br [list $pMin(br) $pMax(br)] \
            -wb [list $pMin(wb) $pMax(wb)] -bb [list $pMin(bb) $pMax(bb)] \
            -wn [list $pMin(wn) $pMax(wn)] -bn [list $pMin(bn) $pMax(bn)] \
            -wm [list $pMin(wm) $pMax(wm)] -bm [list $pMin(bm) $pMax(bm)] \
            -wp [list $pMin(wp) $pMax(wp)] -bp [list $pMin(bp) $pMax(bp)] \
            -flip $ignoreColors -filter $::search::filter::operation \
            -range [list $minMoveNum $maxMoveNum] \
            -length $minHalfMoves -bishops $oppBishops \
            -diff [list $minMatDiff $maxMatDiff] \
            -patt "$pattBool(1) $pattPiece(1) $pattFyle(1) $pattRank(1)" \
            -patt "$pattBool(2) $pattPiece(2) $pattFyle(2) $pattRank(2)" \
            -patt "$pattBool(3) $pattPiece(3) $pattFyle(3) $pattRank(3)" \
            -patt "$pattBool(4) $pattPiece(4) $pattFyle(4) $pattRank(4)" \
            -patt "$pattBool(5) $pattPiece(5) $pattFyle(5) $pattRank(5)" \
            -patt "$pattBool(6) $pattPiece(6) $pattFyle(6) $pattRank(6)" \
            -patt "$pattBool(7) $pattPiece(7) $pattFyle(7) $pattRank(7)" \
            -patt "$pattBool(8) $pattPiece(8) $pattFyle(8) $pattRank(8)" \
            -patt "$pattBool(9) $pattPiece(9) $pattFyle(9) $pattRank(9)" \
            -patt "$pattBool(10) $pattPiece(10) $pattFyle(10) $pattRank(10)"
            ::splash::add "   Material/Pattern filter file $startbase correctly applied"
        }
        "Header"   {
          set sPgnlist {}
          foreach i {1 2 3} {
            set temp [string trim $sPgntext($i)]
            if {$temp != ""} { lappend sPgnlist $temp }
          }
          set wtitles {}
          set btitles {}
          foreach i $sTitleList {
            if $sTitles(w:$i) { lappend wtitles $i }
            if $sTitles(b:$i) { lappend btitles $i }
          }
          sc_search header -white $sWhite -black $sBlack \
            -event $sEvent -site $sSite -round $sRound \
            -date [list $sDateMin $sDateMax] \
            -results [list $sResWin $sResDraw $sResLoss $sResOther] \
            -welo [list $sWhiteEloMin $sWhiteEloMax] \
            -belo [list $sBlackEloMin $sBlackEloMax] \
            -delo [list $sEloDiffMin $sEloDiffMax] \
            -eco [list $sEcoMin $sEcoMax $sEco] \
            -length [list $sGlMin $sGlMax] \
            -toMove $sSideToMove \
            -gameNumber [list $sGnumMin $sGnumMax] \
            -flip $sIgnoreCol -filter $::search::filter::operation \
            -fStdStart $sHeaderFlags(StdStart) \
            -fPromotions $sHeaderFlags(Promotions) \
            -fComments $sHeaderFlags(Comments) \
            -fVariations $sHeaderFlags(Variations) \
            -fAnnotations $sHeaderFlags(Annotations) \
            -fDelete $sHeaderFlags(DeleteFlag) \
            -fWhiteOp $sHeaderFlags(WhiteOpFlag) \
            -fBlackOp $sHeaderFlags(BlackOpFlag) \
            -fMiddlegame $sHeaderFlags(MiddlegameFlag) \
            -fEndgame $sHeaderFlags(EndgameFlag) \
            -fNovelty $sHeaderFlags(NoveltyFlag) \
            -fPawnStruct $sHeaderFlags(PawnFlag) \
            -fTactics $sHeaderFlags(TacticsFlag) \
            -fKingside $sHeaderFlags(KsideFlag) \
            -fQueenside $sHeaderFlags(QsideFlag) \
            -fBrilliancy $sHeaderFlags(BrilliancyFlag) \
            -fBlunder $sHeaderFlags(BlunderFlag) \
            -fUser $sHeaderFlags(UserFlag) \
            -pgn $sPgnlist -wtitles $wtitles -btitles $btitles
            ::splash::add "   Header filter file $startbase correctly applied"
        }
      }
      set glstart 1
      # needed ?
      ::windows::gamelist::Refresh
      ::windows::stats::Refresh
    }
  } elseif {[string match "*.sor" $startbase]} {
    ::splash::add "Opening repertoire file: $startbase..."
    if {[catch {::rep::OpenWithFile $startbase} err]} {
      ::splash::add "Error opening $startbase: $err" error
    }
  } else {
    busyCursor .
    ::splash::add "Opening database: $startbase ..."
    set err 0
    set errMessage ""
    if {[string match "*.pgn" $startbase] || \
          [string match "*.PGN" $startbase] || \
          [string match "*.pgn.gz" $startbase]} {
      set err [catch {sc_base create $startbase true} errMessage]
      if {$err == 0} {
        set err [catch {doPgnFileImport $startbase \
                    "\nOpening [file tail $startbase] read-only...\n"} errMessage]
        if {!$err} {
	  sc_base type [sc_base current] 3
        }
      }
    } else {
      set err [catch { ::file::Open $startbase} errMessage]
      if {! $err} { ::recentFiles::add "[file rootname $startbase].si4" }
    }
    if {$err} {
      ### Above err and errMessage should be shown as dialog messages S.A.
      ### Umm... they are. ? S.A.
      set errMessage "$errMessage\nCould not open database \"$startbase\""
      ::splash::add $errMessage error
      tk_messageBox -title "Scid: Error" -type ok -icon error -message $errMessage
    } else {
      ::splash::add "   Database \"$startbase\" opened: [sc_base numGames] games."
      set initialDir(base) [file dirname $startbase]
      set initialDir(file) [file tail $startbase]
      # this sets initialDir(file) for all files, not just pgn... 
      # but initialDir(file) is only (currently) used when saving pgn S.A.
      catch {sc_game load auto}
      flipBoardForPlayerNames $::myPlayerNames
    }
  }
  unbusyCursor .
  incr argc -1
  set argv [lrange $argv 1 end]
}

::splash::add "\nStartup completed."

##################################
### Main window initialisation ###
##################################

setWinLocation .
wm deiconify .
wm protocol . WM_DELETE_WINDOW { ::file::Exit }

if {$startup(switcher)} { ::windows::switcher::Open }
if {$startup(pgn)} { ::pgn::OpenClose }
if {$startup(gamelist)} { ::windows::gamelist::Open }
if {$startup(tree)} { ::tree::make }
if {$startup(stats)} { ::windows::stats::Open }
if {$startup(crosstable)} { ::crosstab::Open }
if {$startup(finder)} { ::file::finder::Open }
if {$startup(book)} { ::book::open }

updateBoard
updateStatusBar
updateTitle
updateLocale
update
bind . <Configure> "recordWinSize ."

# Bindings to map/unmap all windows when main window is mapped:
bind .statusbar <Map> { showHideAllWindows deiconify}
bind .statusbar <Unmap> { showHideAllWindows iconify}

################################################################################
# returns a list of all toplevel windows, except some that are utilities
################################################################################
proc getTopLevel {} {

  set topl {}
  set exclude { ".splash" ".tooltip" ".glistExtra" ".menu" "." ".pgnPopup" }
  foreach c [winfo children .] {
    if { $c != [winfo toplevel $c] } { continue }
    # Tk report .__tk_filedialog as toplevel window even if the window has been closed
    if { [ lsearch $topl $c ] == -1 && [ lsearch $exclude $c ] == -1 && ![string match "\.__tk*" $c] } {
      lappend topl $c
    }
  }
  return $topl
}
################################################################################
#
################################################################################
# showHideAllWindows:
#   Arranges for all major Scid windows to be shown/hidden
#   Should be called type = "iconify" or "deiconify"
#
proc showHideAllWindows {type} {

  # Don't do this if user option is off:
  if {! $::autoIconify} { return }

  # Some window managers like KDE generate Unmap events for other
  # situations like switching to another desktop, etc.
  # So if the main window is still mapped, do not iconify others:
  if {($type == "iconify")  && ([winfo ismapped .] == 1)} { return }

  # Now iconify/deiconify all the major Scid windows that exist:
  foreach w [getTopLevel] {
    # .baseWin .glistWin .pgnWin .tourney .maintWin \
    # .ecograph .crosstabWin .treeWin .analysisWin1 .anslysisWin2 \
    # .playerInfoWin .commentWin .repWin .statsWin .tbWin \
    # .sb .sh .sm .noveltyWin .emailWin .oprepWin .plist \
    # .rgraph .sgraph .importWin .helpWin .tipsWin
    if {[winfo exists $w]} { catch {wm $type $w} }
  }

}

proc raiseAllWindows {} {
  # Don't do this if auto-raise option is turned off:
  if {! $::autoRaise} { return }

  showHideAllWindows deiconify

  foreach w [getTopLevel] {
    # .baseWin .glistWin .pgnWin .tourney .maintWin \
    # .ecograph .crosstabWin .treeWin .analysisWin1 .anslysisWin2 \
    # .playerInfoWin .commentWin .repWin .statsWin .tbWin \
    # .sb .sh .sm .noveltyWin .emailWin .oprepWin .plist \
    # .rgraph .sgraph .importWin .helpWin .tipsWin
    if {[winfo exists $w]} { catch { raise $w } }
  }
}

### Very annoying for blitz Fics S.A.
# Bind double-click in main Scid window to raise all Scid windows:
# bind . <Double-Button-1> raiseAllWindows

# Hack to extract gif images out of Scid:

  proc dumpGifImages {dir} {
    package require base64
    file mkdir $dir
    set images [image names]
    foreach i $images {
      set data [string trim [$i cget -data]]
      if {$data == ""} { continue }
      if {[catch {set d [::base64::decode $data]}]} { continue }
      regsub -all {:} $i {_} i
      set fname [file join $dir $i.gif]
      set f [open $fname w]
      fconfigure $f -translation binary -encoding binary
      puts -nonewline $f $d
      close $f
    }
  }

  # hmm... Control-Shift-F7 doesn;t work for me ???
  bind . <Control-F7> {
	puts "Dumping images to /tmp/ScidImages"
	dumpGifImages /tmp/ScidImages
	exit
  }

if {$startup(tip)} { ::tip::show }

.splash.t yview moveto 0
if {$::splash::keepopen} {
  raiseWin .splash
  update
} else {
  after 500 { wm withdraw .splash }
}

# Opening files by drag & drop on Scid icon on Mac
if {![catch {tk windowingsystem} wsystem] && $wsystem == "aqua"} {
  # We opened for a drag & drop request, process it now:
  set isopenBaseready 1
  if {$dndargs != 0} {
    set isopenBaseready 2
    catch {::tk::mac::OpenDocument $dndargs} errmsg
    #::splash::add "Opening file(s)...\$dndargs"    
  }
}

### End of file: end.tcl
