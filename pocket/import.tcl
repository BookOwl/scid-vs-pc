### ScidPocket.
### Copyright (C) 2007  Pascal Georges
proc importPgnGame {} {
  if {[winfo exists .importWin]} { return }
  set w [toplevel .importWin]
  wm title $w "Scid: Import PGN game"
  
  wm minsize $w 50 5
  frame $w.b
  pack $w.b -side bottom
  set pane [::utils::pane::Create $w.pane edit err 650 300 0.8]
  pack $pane -side top -expand true -fill both
  set edit $w.pane.edit
  text $edit.text -height 12 -width 80 -wrap none -background white \
      -yscroll "$edit.ybar set" -xscroll "$edit.xbar set"  -setgrid 1
  # Override tab-binding for this widget:
  bind $edit.text <Key-Tab> "[bind all <Key-Tab>]; break"
  ttk::scrollbar $edit.ybar -command "$edit.text yview" -takefocus 0
  ttk::scrollbar $edit.xbar -orient horizontal -command "$edit.text xview" \
      -takefocus 0
  grid $edit.text -row 0 -column 0 -sticky nesw
  grid $edit.ybar -row 0 -column 1 -sticky nesw
  grid $edit.xbar -row 1 -column 0 -sticky nesw
  grid rowconfig $edit 0 -weight 1 -minsize 0
  grid columnconfig $edit 0 -weight 1 -minsize 0
  
  # Right-mouse button cut/copy/paste menu:
  menu $edit.text.rmenu -tearoff 0
  $edit.text.rmenu add command -label "Cut" -command "tk_textCut $edit.text"
  $edit.text.rmenu add command -label "Copy" -command "tk_textCopy $edit.text"
  $edit.text.rmenu add command -label "Paste" -command "tk_textPaste $edit.text"
  $edit.text.rmenu add command -label "Select all" -command \
      "$edit.text tag add sel 1.0 end"
  bind $edit.text <ButtonPress-3> "tk_popup $edit.text.rmenu %X %Y"
  
  text $pane.err.text -height 4 -width 75 -wrap word \
      -yscroll "$pane.err.scroll set"
  $pane.err.text insert end ImportHelp1
  $pane.err.text insert end "\n"
  $pane.err.text insert end ImportHelp2
  $pane.err.text configure -state disabled
  ttk::scrollbar $pane.err.scroll -command "$pane.err.text yview" -takefocus 0
  pack $pane.err.scroll -side right -fill y
  pack $pane.err.text -side left -expand true -fill both
  
  button $w.b.paste -text "PasteCurrentGame" -command {
    .importWin.pane.edit.text delete 1.0 end
    .importWin.pane.edit.text insert end [sc_game pgn -width 70]
    .importWin.pane.err.text configure -state normal
    .importWin.pane.err.text delete 1.0 end
    .importWin.pane.err.text configure -state disabled
  }
  button $w.b.clear -text "Clear" -command {
    .importWin.pane.edit.text delete 1.0 end
    .importWin.pane.err.text configure -state normal
    .importWin.pane.err.text delete 1.0 end
    .importWin.pane.err.text configure -state disabled
  }
  button $w.b.ok -text "Import" -command {
    set err [catch {sc_game import \
          [.importWin.pane.edit.text get 1.0 end]} result]
    .importWin.pane.err.text configure -state normal
    .importWin.pane.err.text delete 1.0 end
    .importWin.pane.err.text insert end $result
    .importWin.pane.err.text configure -state disabled
    if {! $err} {
      updateBoard -pgn
      updateTitle
    }
  }
  button $w.b.cancel -textvar Close -command {
    destroy .importWin; focus .
  }
  frame $w.b.space -width 20
  pack $w.b.paste $w.b.clear $w.b.space -side left -padx 2 -pady 2
  pack $w.b.cancel $w.b.ok -side right -padx 10 -pady 5
  # Paste the current selected text automatically:
  if {[catch {$w.pane.edit.text insert end [selection get]}]} {
    # ?
  }
  # Select all of the pasted text:
  $w.pane.edit.text tag add sel 1.0 end
  
  bind $w <F1> { helpWindow Import }
  bind $w <Alt-i> { .importWin.b.ok invoke }
  bind $w <Alt-p> { .importWin.b.paste invoke }
  bind $w <Alt-c> { .importWin.b.clear invoke }
  bind $w <Escape> { .importWin.b.cancel invoke }
  # bind $w.pane.edit.text <Any-KeyRelease> { .importWin.b.ok invoke }
  focus $w.pane.edit.text
}


proc importClipboardGame {} {
  importPgnGame
  catch {event generate .importWin.pane.edit.text <<Paste>>}
}

proc importPgnLine {line} {
  importPgnGame
  set w .importWin.pane.edit.text
  $w delete 1.0 end
  $w insert end $line
  $w tag add sel 1.0 end
  focus $w
}

proc importMoveList {line} {
  sc_move start
  sc_move addSan $line
  updateBoard
}

set importPgnErrors ""

### Import file of Pgn games:

proc importPgnFile {} {
  global importPgnErrors
  
  set err ""
  if {[sc_base isReadOnly]} { set err "This database is read-only." }
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
}
################################################################################
#
################################################################################
proc doPgnFileImport {fname text {multiple 0} } {
  set w .ipgnWin
  if {[winfo exists $w] && ! $multiple } { destroy $w }
  if {! [winfo exists $w]} {
    toplevel $w
    wm title $w "Importing PGN file"
    
    canvas $w.progress -width 200 -height 20 -bg white -relief solid -border 1
    $w.progress create rectangle 0 0 0 0 -fill blue -outline blue -tags bar
    $w.progress create text 195 10 -anchor e -font font_Regular -tags time -fill black -text "0:00 / 0:00"
    
    pack $w.progress -side bottom
    
    frame $w.buttons
    pack $w.buttons -side bottom -fill x
    button $w.buttons.stop -text "Stop" -command {sc_progressBar}
    button $w.buttons.close -text "Close" -command "focus .; destroy $w"
    pack $w.buttons.close $w.buttons.stop -side right -ipadx 5 -padx 5 -pady 2
    
    pack [frame $w.tf] -side top -expand yes -fill both
    text $w.text -height 4 -width 30 -background gray90 \
        -wrap none -cursor watch -setgrid 1 -yscrollcommand "$w.ybar set"
    ttk::scrollbar $w.ybar -command "$w.text yview"
    pack $w.ybar -in $w.tf -side right -fill y
    pack $w.text -in $w.tf -side left -fill both -expand yes
  }
  
  sc_progressBar $w.progress bar 201 21 time
  update
  catch {grab $w.buttons.stop}
  bind $w <Escape> "$w.buttons.stop invoke"
  $w.buttons.close configure -state disabled
  $w.text insert end $text
  $w.text insert end "Importing PGN games from [file tail $fname]...\n\n"
  $w.text configure -state disabled
  
  set importPgnErrors ""
  set err [catch {sc_base import file $fname} result]
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
      append str " no errors"
    } else {
      append str ".\nPGN errors:\n$warnings"
    }
    $w.text insert end "$str\n"
  }
  
  $w.text configure -state disabled
  $w.buttons.close configure -state normal
  $w.buttons.stop configure -state disabled
  catch {grab release $w.buttons.stop}
  bind $w <Escape> "$w.buttons.close invoke; break"
  # Auto-close import progress window if there were no errors/warnings?
  if {!$err  &&  $warnings == "" && ! $multiple} { destroy $w }
  
  update
}

###
### End of file: import.tcl
###

