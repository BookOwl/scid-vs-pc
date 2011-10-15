
# ::game::ConfirmDiscard
#
#   Prompts the user if they want to discard the changes to the
#   current game. Returns 1 if they selected yes, 0 otherwise.
#

# ConfirmDiscard can sometimes be drawn underneath the comment editor 
# It should be replaced by ConfirmDiscard2 anyway, which has a game save option. S.A.

proc ::game::ConfirmDiscard {} {

  # sanity check in case of errant multiple call
  if {[winfo exists .cgDialog]} {return 0}

  if {$::trialMode}		{return 1}
  if {[sc_base isReadOnly]}	{return 1}
  if {! [sc_game altered]}	{return 1}

  set answer [ tk_dialog .cgDialog "Scid: [tr GameNew]" $::tr(ClearGameDialog) {} {} \
    [lindex [split $::tr(DiscardChangesAndContinue) "\n"] 0] $::tr(Cancel) ]

  return [expr $answer == 0]
}

# ::game::ConfirmDiscard2
# Clearer buttons than ConfirmDiscard
#   Prompts the user if they want to discard the changes to the
#   current game. Returns :
# 0 -> saves then continue
# 1 -> discard changes and continue
# 2 -> cancel action

proc ::game::ConfirmDiscard2 {} {
  # This should be rewritten with tk_dialog and "return answer"
  # rather than "::game::answer" S.A.

  if {$::trialMode} { return 1 }
  if {[sc_base isReadOnly]} { return 1 }
  if {! [sc_game altered]} { return 1 }

  set w .confirmDiscard
  toplevel $w
  wm state $w withdrawn
  wm title $w "Scid: [tr GameNew]"
  set ::game::answer 2
  pack [frame $w.top] -side top
  addHorizontalRule $w
  pack [frame $w.bottom] -expand 1 -fill x -side bottom

  # label $w.top.icon -bitmap question
  # pack $w.top.icon -side left -padx 20 -pady 5

  label $w.top.txt -text "This game has been altered.\nDo you wish to save it?"
  pack $w.top.txt -padx 5 -pady 5 -side right

  button $w.bottom.b1 -width 10 -text {Save} -command {destroy .confirmDiscard ; set ::game::answer 0}
  button $w.bottom.b2 -width 10 -text {Don't Save} -command {destroy .confirmDiscard ; set ::game::answer 1}
  button $w.bottom.b3 -width 10 -text $::tr(Cancel) -command {destroy .confirmDiscard ; set ::game::answer 2}
  pack $w.bottom.b1 $w.bottom.b2 $w.bottom.b3 -side left -padx 10 -pady 5

  bind $w <Destroy> {set ::game::answer 2}
  bind $w <Right> "event generate $w <Tab>"
  bind $w <Left> "event generate $w <Shift-Tab>"

  update
  placeWinOverParent $w .
  wm state $w normal

  catch { grab $w }

  focus $w.bottom.b2
  vwait ::game::answer
  return $::game::answer
}

# ::game::Clear
#
#   Clears the active game, checking first if it is altered.
#   Updates any affected windows.
#
proc ::game::Clear {} {
  set confirm [::game::ConfirmDiscard2]
  if {$confirm == 2} { return }
  if {$confirm == 0} {
    sc_game save [sc_game number]
    # ::gameReplace
  }

  setTrialMode 0
  sc_game new
  updateBoard -pgn
  updateTitle
  updateMenuStates
}

# ::game::Strip
#
#   Strips all comments or variations from a game

proc ::game::Strip {type {parent .}} {
  sc_game undoPoint

  if {[catch {sc_game strip $type} result]} {
    tk_messageBox -parent $parent -type ok -icon info -title "Scid" -message $result
    return
  }
  updateBoard -pgn
  updateTitle
}

# ::game::TruncateBegin
#
proc ::game::TruncateBegin {} {
  sc_game undoPoint

  if {[catch {sc_game truncate -start} result]} {
    tk_messageBox -parent . -type ok -icon info -title "Scid" -message $result
    return
  }
  updateBoard -pgn
  updateTitle
}

# ::game::Truncate
#
proc ::game::Truncate {} {
  sc_game undoPoint

  if {[catch {sc_game truncate} result]} {
    tk_messageBox -parent . -type ok -icon info -title "Scid" -message $result
    return
  }
  updateBoard -pgn
  updateTitle
}

# game::LoadNextPrev
#
#   Loads the next or previous filtered game in the database.
#   The parameter <action> should be "previous" , "next", "first" or "last"
#
proc ::game::LoadNextPrev {action {raise 1}} {
  global pgnWin statusBar
  if {![sc_base inUse]} {
    set statusBar "  There is no $action game: this is an empty database."
    return
  }
  set number [sc_filter $action]
  if {$number == 0} {
    set statusBar "  There is no $action game in the current filter."
    return
  }
  ::game::Load $number 1 $raise
}

# ::game::Reload
#
#   Reloads the current game.
#
proc ::game::Reload {} {
  if {![sc_base inUse]} { return }
  if {[sc_game number] < 1} { return }
  ::game::Load [sc_game number]
}

# ::game::LoadRandom
#
#   Loads a random game from the database.
#
proc ::game::LoadRandom {} {
  set ngames [sc_filter size]
  if {$ngames == 0} { return }
  set r [expr {(int (rand() * $ngames)) + 1} ]
  set gnumber [sc_filter index $r]
  ::game::Load $gnumber
}


# ::game::LoadNumber
#
#    Prompts for the number of the game to load.
#
set ::game::entryLoadNumber ""
trace variable ::game::entryLoadNumber w {::utils::validate::Regexp {^[0-9]*$}}

proc ::game::LoadNumber {} {
  set ::game::entryLoadNumber ""
  if {![sc_base inUse]} { return }

  set confirm [::game::ConfirmDiscard2]
  if {$confirm == 2} { return }
  if {$confirm == 0} {
    # ::gameReplace
    sc_game save [sc_game number]
  }

  if {[sc_base numGames] < 1} { return }
  set w [toplevel .glnumDialog]
  wm title $w "Scid: [tr GameNumber]"
  grab $w

  label $w.label -text $::tr(LoadGameNumber)
  pack $w.label -side top -pady 5 -padx 5

  entry $w.entry  -width 10 -textvariable ::game::entryLoadNumber
  bind $w.entry <Escape> { .glnumDialog.buttons.cancel invoke }
  bind $w.entry <Return> { .glnumDialog.buttons.load invoke }
  pack $w.entry -side top -pady 5

  set b [frame $w.buttons]
  pack $b -side top -fill x
  dialogbutton $b.load -text "OK" -command {
    grab release .glnumDialog
    if {[catch {sc_game load $::game::entryLoadNumber} result]} {
      tk_messageBox -type ok -icon info -title "Scid" -message $result
    }
    focus .
    destroy .glnumDialog
    flipBoardForPlayerNames $::myPlayerNames
    updateBoard -pgn
    ::windows::gamelist::Refresh
    updateTitle
  }
  dialogbutton $b.cancel -text $::tr(Cancel) -command {
    focus .
    grab release .glnumDialog
    destroy .glnumDialog
    focus .
  }
  packbuttons right $b.cancel $b.load

  set x [ expr {[winfo width .] / 4 + [winfo rootx .] }]
  set y [ expr {[winfo height .] / 4 + [winfo rooty .] }]
  wm geometry $w "+$x+$y"

  focus $w.entry
}

# ::game::Load
#
#   Loads a specified game from the active database.
#
proc ::game::Load { selection {update 1} {raise 1}} {
  # If an invalid game number, just return:
  if {$selection < 1} { return }
  if {$selection > [sc_base numGames]} { return }
  set confirm [::game::ConfirmDiscard2]
  if {$confirm == 2} { return }
  if {$confirm == 0} {
    sc_game save [sc_game number]
    # ::gameReplace
  }

  setTrialMode 0
  sc_game load $selection
  flipBoardForPlayerNames $::myPlayerNames
  if {$update} {
    updateBoard -pgn
  }
  ### don't S.A
  # ::windows::gamelist::Refresh
  updateTitle

  if {$raise && \
      ![winfo exists .tourney] && \
      ![winfo exists .twinchecker] && \
      ![winfo exists .sb] && \
      ![winfo exists .sh] && \
      ![winfo exists .bmedit] && \
      ![winfo exists .sm] } {
    raiseWin .
  }
  if {[winfo exists .sgraph]} {
    ::tools::graphs::score::Refresh
  }
    ::windows::gamelist::Refresh
}

# ::game::LoadMenu
#
#   Produces a popup dialog for loading a game or other actions
#   such as merging it into the current game.
#
proc ::game::LoadMenu {w base gnum x y} {
  set m $w.gLoadMenu
  if {! [winfo exists $m]} {
    menu $m
    $m add command -label $::tr(BrowseGame)
    $m add command -label $::tr(LoadGame)
    $m add command -label $::tr(MergeGame)
  }
  $m entryconfigure 0 -command "::gbrowser::new $base $gnum"
  $m entryconfigure 1 -command "sc_base switch $base; ::game::Load $gnum"
  $m entryconfigure 2 -command "mergeGame $base $gnum"
  event generate $w <ButtonRelease-1>
  $m post $x $y
  event generate $m <ButtonPress-1>
}


# ::game::moveEntryNumber
#
#   Entry variable for GotoMoveNumber dialog.
#
set ::game::moveEntryNumber ""
trace variable ::game::moveEntryNumber w {::utils::validate::Regexp {^[0-9]*$}}

# ::game::GotoMoveNumber
#
#    Prompts for the move number to go to in the current game.
#
proc ::game::GotoMoveNumber {} {
  set ::game::moveEntryNumber ""
  set w [toplevel .mnumDialog]
  wm title $w "Scid: [tr GameGotoMove]"
  grab $w

  label $w.label -text $::tr(GotoMoveNumber)
  pack $w.label -side top -pady 5 -padx 5

  entry $w.entry -width 8 -textvariable ::game::moveEntryNumber -borderwidth 0 ; # -justify right
  bind $w.entry <Escape> { .mnumDialog.buttons.cancel invoke }
  bind $w.entry <Return> { .mnumDialog.buttons.load invoke }
  pack $w.entry -side top -pady 5

  set b [frame $w.buttons]
  pack $b -side top -fill x
  dialogbutton $b.load -text "OK" -command {
    grab release .mnumDialog
    if {$::game::moveEntryNumber > 0} {
      catch {sc_move ply [expr {($::game::moveEntryNumber - 1) * 2}] ; sc_move forward}
    }
    focus .
    destroy .mnumDialog
    # updateBoard -pgn
    updateBoard
  }
  dialogbutton $b.cancel -text $::tr(Cancel) -command {
    focus .
    grab release .mnumDialog
    destroy .mnumDialog
    focus .
  }
  packbuttons right $b.cancel $b.load

  placeWinOverParent $w .

  focus $w.entry
}
