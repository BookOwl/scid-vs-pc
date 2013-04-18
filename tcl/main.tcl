###
###
### main.tcl: Routines for creating and updating the main window.
###

############################################################
# Keyboard move entry:
#   Handles letters, digits and BackSpace/Delete keys.
#   Note that king- and queen-side castling moves are denoted
#   "OK" and "OQ" respectively.
#   The letters n, r, q, k, o and l are promoted to uppercase
#   automatically. A "b" can match to a b-pawn or Bishop move,
#   so in some rare cases, a capital B may be needed for the
#   Bishop move to distinguish it from the pawn move.

set moveEntry(Text) ""
set moveEntry(List) {}

# Bind Alt+letter key to nothing, to stop Alt+letter from
# matching the move entry bindings, so Alt+letter ONLY invokes
# the menus:
foreach key {a b c d e f g h i j k l m n o p q r s t u v w x y z} {
  bind . <Alt-$key> {}
}

set ::fics::premove {}

proc moveEntry_Clear {{escape 0}} {
  global moveEntry

  set moveEntry(Text) {}
  set moveEntry(List) {}
  set ::startArrowSquare {}
  if {$escape && $::fics::playing} {
    set ::fics::premove {}
    sc_pos setComment {}
    updateBoard
  }
  updateStatusBar
}

proc moveEntry_Complete {} {
  global moveEntry

  if { [winfo exists .fics] && $::fics::playing == -1} { ;# not player's turn
    moveEntry_Clear
    return
  }

  set len [llength $moveEntry(List)]
  if {$len > 0} {
    if {$moveEntry(AutoExpand)} {
      # Play a bell sound to let the user know the move was accepted already,
      # but only if move announcement is off?
      # bell
    }
    set move [lindex $moveEntry(List) 0]
    if {$move == "OK"} { set move "O-O" }
    if {$move == "OQ"} { set move "O-O-O" }

    if {[sc_pos isAt vend]} {
      set action replace
    } else {
      set action [confirmReplaceMove]
    }

    if {$action != "cancel"} {
      sc_game undoPoint
    }

    if {$action == "replace"} {
      sc_move addSan $move
    } elseif {$action == "var"} {
      sc_var create
      sc_move addSan $move
    } elseif {$action == "mainline"} {
      sc_var create
      sc_move addSan $move
      sc_var exit
      sc_var promote [expr {[sc_var count] - 1}]
      sc_move forward 1
    }

    # Now send the move done to FICS and NOVAG Citrine
    ::fics::checkAdd

    if {$::novag::connected} {
      set moveUCI [sc_game info previousMoveUCI]
      ::novag::addMove $moveUCI
    }

    moveEntry_Clear
    updateBoard -pgn -animate
    ::utils::sound::AnnounceNewMove $move
    if {$action == "replace"} { ::tree::doTraining }
  }
}

proc moveEntry_Backspace {} {
  global moveEntry
  set moveEntry(Text) [string range $moveEntry(Text) 0 \
      [expr {[string length $moveEntry(Text)] - 2}]]
  set moveEntry(List) [sc_pos matchMoves $moveEntry(Text) $moveEntry(Coord)]
  updateStatusBar
}

proc moveEntry_Char {ch} {
  global moveEntry
  set oldMoveText $moveEntry(Text)
  set oldMoveList $moveEntry(List)
  append moveEntry(Text) $ch
  set moveEntry(List) [sc_pos matchMoves $moveEntry(Text) $moveEntry(Coord)]
  set len [llength $moveEntry(List)]
  if {$len == 0} {
    # No matching moves, so do not accept this character as input:
    set moveEntry(Text) $oldMoveText
    set moveEntry(List) $oldMoveList
  } elseif {$len == 1} {
    # Exactly one matching move, so make it if AutoExpand is on,
    # or if it equals the move entered. Note the comparison is
    # case insensitive to allow for 'b' to match both pawn and
    # Bishop moves.
    set move [string tolower [lindex $moveEntry(List) 0]]

    if {$moveEntry(AutoExpand) > 0  ||
      ![string compare [string tolower $moveEntry(Text)] $move]} {
      moveEntry_Complete
    }
  } elseif {$len == 2} {
    # Check for the special case where the user has entered a b-pawn
    # capture that clashes with a Bishop move (e.g. bxc4 and Bxc4):
    set first [string tolower [lindex $moveEntry(List) 0]]
    set second [string tolower [lindex $moveEntry(List) 1]]
    if {[string equal $first $second]} {
      set moveEntry(List) [list $moveEntry(Text)]
      moveEntry_Complete
    }
  }
  updateStatusBar
}

# preMoveCommand: called before making a move to store text in the comment
#   editor window and EPD windows.
proc preMoveCommand {} {
  #resetAnalysis 1
  #resetAnalysis 2
  # ::commenteditor::storeComment
  storeEpdTexts
}

sc_info preMoveCmd preMoveCommand


###   Update the main Scid window title with player names or basename

proc updateTitle {} {

  regexp {^[^, ]*} [sc_game tag get White] white
  regexp {^[^, ]*} [sc_game tag get Black] black
  # set white [sc_game tag get White]
  # set black [sc_game tag get Black]

  set fname [file tail [sc_base filename]]
  if {![string match {\[*\]} $fname]} {
    set fname "\[$fname\]"
  }

  if {$fname == "\[$::tr(clipbase)\]"} {set fname {}}

  if {$white == {?} && $black == {?}} {
    wm title $::dot_w "$::scidName $fname"
  } else {
    wm title $::dot_w "$::scidName: $white - $black $fname"
  }
}


proc warnStatusBar {warning} {

   # Show statusbar if hidden
   if {!$::gameInfo(showStatus)} {
     set ::gameInfo(showStatus) 1
     toggleStatus
   }
   # Stop engine in status bar if neccessary
   if {[winfo exists .analysisWin1] && $::analysis(mini)} { makeAnalysisWin 1 }

   set ::statusBar $warning
   .main.statusbar configure -foreground red3
   # Will be restored by updateStatusBar in main.tcl
}

### Update the main status bar

proc updateStatusBar {} {
  global statusBar moveEntry

  ::windows::gamelist::checkAltered

  # Exit if engine 1 is running in status bar
  if {$::analysis(mini) && [winfo exists .analysisWin1]} {return}

  # Why are these things refreshed here ???
  # ::windows::switcher::Refresh
  ::maint::Refresh
  set statusBar "  "

  if {$moveEntry(Text) != ""} {
    append statusBar "Enter move: \[" $moveEntry(Text) "\]  "
    foreach thisMove $moveEntry(List) {
      append statusBar $thisMove " "
    }
    return
  }

  # Check if translations have not been set up yet:
  if {! [info exists ::tr(Database)]} { return }

  # append statusBar "  $::tr(Database): "
  set fname [sc_base filename]
  set fname [file tail $fname]
  if {$fname == ""} { set fname "<none>" }
  append statusBar "$fname: "

  if {[sc_base isReadOnly]} {
    append statusBar { (read-only) }
  } 

  # append statusBar "   $::tr(Filter)"
  append statusBar "  [filterText]"

  # if {[sc_game altered]} { append statusBar " (altered)" }
}


proc toggleRotateBoard {} {
  ::board::flip .main.board
}

proc toggleCoords {} {
  global boardCoords
  set coords [expr {1 + $boardCoords} ]
  if { $coords > 2 } { set coords 0 }
  set boardCoords $coords
  ::board::coords .main.board
}

proc toggleMat {} {
  global gameInfo
  set gameInfo(showMaterial) [expr {1 + $gameInfo(showMaterial)} ]
  if { $gameInfo(showMaterial) > 2 } { set gameInfo(showMaterial) 0 }
  ::board::togglematerial
}

image create photo autoplay_off -data {
R0lGODlhHgAeAKU6AAAAAAUFBQcHBwkJCQ0NDRISEhgYGCIiIi4uLkBA/0FB
/0ND/llZWUZG/khI/UtL/EtL/U1N/E5O/E9P+2JiYlBQ+1FR+2ZmZlZW+Wlp
aVhY+V1d92Fh9nR0dHd3d3Fx8oqK7ZCQ65GR65OT6pWV6paW8ZmZ8Jqa6Jqa
6Zqa8KCg56ioqKCg7rm54r6+vsHBwb6+58PDw8TEwMTExMjIxszMxc7OxdDQ
xNHRxO7u7tnZ2dnZ2dnZ2dnZ2dnZ2dnZ2SH5BAEKAD8ALAAAAAAeAB4AAAbQ
wJ9wSCwaj8ikcsksuprQX+cQZeYyAMYq+apSAFmkR1Aom89owwAcQMyMF7B8
Tq8DCDHjGM0/q9luRzI2ODg3NTRKX2FJLCYpJTBLWFpKGAsNCiBLU0wbERYR
GBwaKklPS58WFRMSDh8oIS1VQ6oWtxMPDpq0Qra3wKKkplG/wKutr7GznqDH
z7m7m83P1bfCGCdKxta3FREQCSLbzt3Bo9nk5hbRvNTVrK6wsk3c16OlVcbt
07Sq8cro9VIlLF+vIZcy9Ts45MQIEgIZSjQSBAA7
}

image create photo autoplay_on -data {
R0lGODlhHgAeAKUhAAAAAAMDAwcHBxAQEBsbGx8fHyIiIiQkJC8vLzo6OkRv
EV5eXmxsbHJycl+KLHR0dHZ2doGBgYWFhYaGhnukS5iYmJmZmZubm6amppm6
cbW1tanGhr29vcPDw8TExMDVptrlzv//////////////////////////////
////////////////////////////////////////////////////////////
/////////////////////////////////yH5BAEKAD8ALAAAAAAeAB4AAAav
wJ9wSCwaj8ikcskcMg6appRRsEibDIEhgsQ8vuCw+JsAABKSI8PMbrvfAKhx
Da+75cXLYs/v+/cIZggNHldJDAEDEEogG44fSwwEExxKDgqYGR+QSBUMHUuX
mKMbhkaiowoUGZqmQqipmZumsLGkhrW2qqycobq/mr1Iub+ppUnExZjHw8qx
q63IzsZNyanBUtYUj7jFzN2xGSDjrj+oFOjCrqjf5UIfjhsg7vRJQQA7
}

image create photo tb_windows -data {
R0lGODlhHgAeAMZkAIKCgoeHh4iIiImJiYqKiouLi4yMjI6Ojo+Pj5CQkJKS
kpSUlJWVlZeXl5iYmJmZmZqampubm5ycnJ2dnZ6enp+fn6CgoKGhoaKioqOj
o6SkpKWlpaampqenp6qqqqurq6ysrK2tra6urq+vr7CwsLGxsbOzs7W1tbm5
ubq6uru7u7y8vL29vb6+vr+/v8DAwMHBwcLCwsPDw8TExMXFxcbGxsfHx8jI
yMnJycrKysvLy8zMzM3Nzc7Ozs/Pz9DQ0NHR0dLS0tPT09TU1NXV1dbW1tfX
19jY2NnZ2dra2tvb29zc3N3d3d7e3t/f3+Dg4OHh4eLi4uPj4+Tk5OXl5ebm
5ufn5+jo6Onp6erq6uvr6+zs7O3t7e7u7u/v7/Dw8PHx8fLy8vPz8/T09P//
////////////////////////////////////////////////////////////
/////////////////////////////////////////////////yH5BAEKAH8A
LAAAAAAeAB4AAAf+gH+Cg4SFhoeEAwECjAGOj5CLBYiDCxIeIyUkm5ydJCMf
FQ6UfxUpRk9Qqk+srKtPTkcrF6QdO1RbWltbWVRQTsDBTUkvFKQeQ1ZaWVlX
TzwyMdIx0TEwJhEAlB9FV7laVEEhFRocHRzo6BsYFhXuFBEMgyJHV1z3TjUr
PFe6u9+6/PFysuKBIBFIsnRZmM+GEWYQs2DBEhGilBmj/oRIosWLxyc1ciTJ
omUZxJLLUGq5KO+PiCRbvsgEqUNJll0q7wFcBuWFgoNKtoAB84XJjB1LburU
5aWLzl1YmKg4IGjEEi5hwnw5AkMHky1cFt7j4tHp2CpFUFD9Q4JJlzD+YLgM
aaGjCdmyCz02dYrFyQ8UCQSVaOIlTJcrQFjocNJFJt6FYrNEObIjxc8/JZx4
+ZJFyg8WO550Gfqli5aJE5tNUUKEx4oFghlzqSJFSAseULyA0ZqlCpUpwKVA
YWKEyI8WLTPzokKlyIseUL7A5eKrlRMmS5AYMTIERgPBTCZasXIkho8ouw9D
acJEyZIlSpQkSaLkCA0IgkgsuYKFf5IZP0gBhhdYSNHEe/MpwQR2TAxjA35/
jICEMiUxUQMQAm5RxS9NsLcEE6w4kcoSN0AIQhBVjNWEDRge9psUUcSoShRS
1CiFEzpIIIgEH8iwQw89yHCCDk/0d8UV441rxx8WVhyJxRQ+GCMIAwYIsEgA
CLjgBEUVMVPSSVX8YAElBKiwBBb/pLkLF2vOxgMtlJQQhBa7DWXnUFll9YUU
MYxJyQYsKCEFc4QWSugTQJAwASkUSDDBoxNQIOmkkz5KwaKkZKrpppz+EQgA
Ow==
}

# image create photo finish_off -data ....
# image create photo finish_on -data ....
### Replaced by autoplay_

# Double size the buttonbar (disabled)
if {0} {
  image create photo tempimage
  foreach i {tb_flip tb_gameinfo autoplay_off autoplay_on tb_trial \
         tb_trial_on tb_start tb_prev tb_next tb_end tb_invar tb_outvar tb_addvar} {
    tempimage blank
    tempimage copy $i -zoom 2
    $i blank
    $i copy tempimage
  }
}

frame .main.button.space3 -width 4

button .main.button.flip     -image tb_flip      -command {::board::flip .main.board}
button .main.button.windows  -image tb_windows   -command raiseAllWindows
button .main.button.autoplay -image autoplay_off -command toggleAutoplay
button .main.button.trial    -image tb_trial     -command {setTrialMode toggle}

foreach i {start back forward end intoVar exitVar addVar autoplay flip windows trial} {
  .main.button.$i configure -relief flat -border 1 -highlightthickness 0 -takefocus 0
  # bind .main.button.$i <Any-Enter> "+.main.button.$i configure -relief groove"
  # bind .main.button.$i <Any-Leave> "+.main.button.$i configure -relief flat; statusBarRestore %W; break"
}

pack .main.button.start .main.button.back .main.button.forward .main.button.end \
     .main.button.space .main.button.exitVar .main.button.intoVar .main.button.addVar \
     .main.button.autoplay .main.button.trial .main.button.flip .main.button.windows \
        -side left -pady 1 -padx 0 -ipadx 2 -ipady 2

### Main Board Init

::board::new .main.board $boardSize 1
#.main.board.bd configure -relief solid -border 2
::board::showMarks .main.board 1
if {$boardCoords} {
  ::board::coords .main.board
}
if {$boardSTM} {
  ::board::togglestm .main.board
}

### Game Information Widget Init

autoscrollframe .main.gameInfoFrame text .main.gameInfo

.main.gameInfo configure -width 20 -wrap none -state disabled -cursor top_left_arrow -setgrid 1

::htext::init .main.gameInfo

### Context menu for main board
### allows customisation of board, gameinfo and a couple of windows

menu .main.gameInfo.menu -tearoff 0 -background gray90

.main.gameInfo.menu add checkbutton -label PGN -variable pgnWin -command ::pgn::OpenClose
.main.gameInfo.menu add checkbutton -label {Game List} \
   -variable ::windows::gamelist::isOpen -command ::windows::gamelist::OpenClose

.main.gameInfo.menu add separator

.main.gameInfo.menu add checkbutton -label {Menu Bar} -variable gameInfo(showMenu) -command showMenubar
.main.gameInfo.menu add checkbutton -label {Tool Bar} -variable gameInfo(showTool) -command toggleToolbar
.main.gameInfo.menu add checkbutton -label {Button Bar} -variable gameInfo(showButtons) -command toggleButtonBar
.main.gameInfo.menu add checkbutton -label {Game Info} -variable gameInfo(show) -command showGameInfo
.main.gameInfo.menu add checkbutton -label {Status Bar} -variable gameInfo(showStatus) -command toggleStatus

.main.gameInfo.menu add separator

.main.gameInfo.menu add checkbutton -label {Side to Move} \
    -variable boardSTM -offvalue 0 -onvalue 1 -command {::board::togglestm .main.board}

.main.gameInfo.menu add checkbutton -label {Highlight last move} \
    -variable ::highlightLastMove -offvalue 0 -onvalue 1 -command updateBoard

.main.gameInfo.menu add checkbutton -label GInfoFEN \
    -variable gameInfo(showFEN) -offvalue 0 -onvalue 1 -command checkGameInfoHeight

.main.gameInfo.menu add checkbutton -label GInfoHideNext \
    -variable gameInfo(hideNextMove) -offvalue 0 -onvalue 1 -command updateBoard

.main.gameInfo.menu add command -label GInfoMaterial -command toggleMat
.main.gameInfo.menu add command -label {Toggle Coords} -command toggleCoords

if { $::docking::USE_DOCKING } {
  foreach i {3 4 5 6 7 9 13 14} {
    .main.gameInfo.menu entryconfigure $i -command "[.main.gameInfo.menu entrycget $i -command] ; resizeMainBoard"
  }
}

proc contextmenu {x y} {
  if {$::board::_drag(.main.board) < 0} {
    tk_popup .main.gameInfo.menu $x $y
  }
}

# Pop-up this menu with a right click on a few empty real estates (if not dragging)

if { !$::docking::USE_DOCKING } {
  bind .main <ButtonPress-3> {contextmenu %X %Y}
}

# bind . <F9> {contextmenu %X %Y}

if { $macOS } {
  # Macs with one button need (shooting)
  # todo: find a way to seemlessly swap button-2 with button-3 as macs have them reversed
  bind . <Control-Button-1> {event generate . <Button-3> -x %x -y %y -button 3}
}

# updateVarMenus:
#   Updates the menus for moving into or deleting an existing variation.
#   Calls sc_var list and sc_var count to get the list of variations.
#
proc updateVarMenus {} {
  set varList [sc_var list]
  set numVars [sc_var count]
  .main.button.intoVar.menu delete 0 end
  .menu.edit.del delete 0 end
  .menu.edit.first delete 0 end
  .menu.edit.main delete 0 end
  # PG: add the move of main line
  if {$numVars > 0} {
    set move [sc_game info nextMove]
    if {$move == ""} { set move "($::tr(empty))" }
    .main.button.intoVar.menu add command -label "0: $move" -command "sc_move forward; updateBoard" -underline 0
  }
  for {set i 0} {$i < $numVars} {incr i} {
    set move [lindex $varList $i]
    set state normal
    if {$move == ""} {
      set move "($::tr(empty))"
      set state disabled
    }
    set str "[expr {$i + 1}]: $move"
    set commandStr "sc_var moveInto $i; updateBoard"
    if {$i < 9} {
      .main.button.intoVar.menu add command -label $str -command $commandStr \
          -underline 0
    } else {
      .main.button.intoVar.menu add command -label $str -command $commandStr
    }
    set commandStr "sc_var delete $i; updateBoard -pgn"
    .menu.edit.del add command -label $str -command $commandStr
    set commandStr "sc_var first $i; updateBoard -pgn"
    .menu.edit.first add command -label $str -command $commandStr
    set commandStr "sc_var promote $i; updateBoard -pgn"
    .menu.edit.main add command -label $str -command $commandStr \
        -state $state
  }
}
################################################################################
# added by Pascal Georges
# returns a list of num moves from main line following current position
################################################################################
proc getNextMoves { {num 4} } {
  set tmp ""
  set count 0
  while { [sc_game info nextMove] != "" && $count < $num} {
    append tmp " [sc_game info nextMove]"
    sc_move forward
    incr count
  }
  sc_move back $count
  return $tmp
}
################################################################################
#  Pascal Georges :
# displays a box with main line and variations for easy selection with keyboard
################################################################################
proc showVars {} {

  # No need to display an empty menu
  if {[sc_var count] == 0} {
    return
  }

  if {[sc_var count] == 1 &&  [sc_game info nextMove] == ""} {
    # There is only one variation and no main line, so enter it
    sc_var moveInto 0
    updateBoard
    return
  }

  sc_info preMoveCmd {}

  set w .variations
  if {[winfo exists $w]} { return }

  set varList [sc_var list]
  set numVars [sc_var count]

  # Present a menu of the possible variations
  toplevel $w
  wm state $w withdrawn
  wm title $w $::tr(Variations)
  set h [expr $numVars + 1]
  if { $h> 19} { set h 19 }
  listbox $w.lbVar -selectmode browse -height $h -width 30
  pack $w.lbVar -expand yes -fill both -side top

  #insert main line
  set move [sc_game info nextMove]
  if {$move == ""} {
    set move "($::tr(empty))"
  } else  {
    $w.lbVar insert end "0:[getNextMoves 5]"
    bind $w <KeyPress-0> "enterVar 0"
    bind $w <Button-5>   "bind $w <Button-5> {} ; enterVar 0"
  }

  # insert variations
  for {set i 0} {$i < $numVars} {incr i} {
    set move [::trans [lindex $varList $i]]
    if {$move == ""} {
      set move "($::tr(empty))"
    } else  {
      sc_var moveInto $i
      append move [getNextMoves 5]
      sc_var exit
    }
    set j [expr $i + 1]
    set str "$j: $move"
    $w.lbVar insert end $str
    if {$j <= 9 } {
      bind $w <KeyPress-$j> "enterVar $j"
    }
  }
  $w.lbVar selection set 0

  bind $w <Return> { enterVar }
  bind $w <ButtonRelease-1> { enterVar }
  bind $w <Right> { enterVar }
  bind $w <Up> {
    set cur [.variations.lbVar curselection]
    .variations.lbVar selection clear $cur
    set sel [expr $cur - 1]
    if {$sel < 0} { set sel 0 }
    .variations.lbVar selection set $sel
    .variations.lbVar see $sel
  }
  bind .variations <Down> {
    set cur [.variations.lbVar curselection]
    .variations.lbVar selection clear $cur
    set sel [expr $cur + 1]
    if {$sel >= [.variations.lbVar index end]} { set sel end }
    .variations.lbVar selection set $sel
    .variations.lbVar see $sel
  }
  bind $w <Left> { destroy .variations }
  bind $w <Escape>   { destroy .variations }
  # need to use "-force" to keep keyboared bindings after wheelmouse
  bind $w <Button-4> { destroy .variations ; focus -force .main.board }

  # Needed or the main window loses the focus
  if { $::docking::USE_DOCKING } {
      bind .variations <Destroy> { focus -force .main }
  }


  sc_info preMoveCmd preMoveCommand

  bind $w <Configure> "recordWinSize $w"
  setWinLocation $w
  wm state $w normal

  catch {
    focus $w

    # Disable grab if drawing arrows, as it pinches the arrows binding
    # ... Hmmm, but we need the grab to back out of variation window by using wheel-up! :<
    # So we have to compromise here. 
    # if {! $::showVarArrows} { grab $w }
    grab $w
  }
  update
}

proc enterVar {{n {}}} {
  sc_info preMoveCmd preMoveCommand
  if {$n == {}} {
    set n [.variations.lbVar curselection]
  }
  catch {destroy .variations}
  # need to use "-force" to keep keyboared bindings after wheelmouse
  focus -force .main.board 
  if {$n == 0} {
    sc_move forward; updateBoard -animate
  } else  {
    sc_var moveInto [expr $n - 1]; updateBoard -animate
  }
}

################################################################################
#
################################################################################
# V and Z key bindings: move into/out of a variation.
#
bind . <KeyPress-v> showVars
bind . <KeyPress-z> {.main.button.exitVar invoke}
bind . <Control-a> {.main.button.addVar invoke}

### Dialog box for editing "My Player Names"
### to know when to flip the board

proc editMyPlayerNames {} {
  global myPlayerNames
  set w .editMyPlayerNames
  if {[winfo exists $w]} {
    raiseWin $w
    return
  }
  toplevel $w
  wm state $w withdrawn
  wm title $w "[tr OptionsNames]"
  pack [frame $w.b] -side bottom -fill x

  frame $w.desc -borderwidth 0
  set height [expr {$::language == "E" ? 3 : 8}]
  text $w.desc.text -background gray90 -width 50 -height $height -wrap word
  $w.desc.text insert end [string trim $::tr(MyPlayerNamesDescription)]
  $w.desc.text configure -state disabled
  pack $w.desc -side top -fill x
  pack $w.desc.text -fill both -expand yes

  frame $w.f -borderwidth 0
  text $w.f.text -width 50 -height 10 -wrap none
  foreach name $myPlayerNames {
    $w.f.text insert end "\"$name\"\n"
  }
  pack $w.f -side top -fill both -expand yes
  pack $w.f.text -fill both -expand yes
  button $w.b.white -text $::tr(White) -command {
    .editMyPlayerNames.f.text insert end "\"[sc_game info white]\"\n"
  }
  button $w.b.black -text $::tr(Black) -command {
    .editMyPlayerNames.f.text insert end "\"[sc_game info black]\"\n"
  }
  button $w.b.help -text $::tr(Help) \
      -command {helpWindow Options MyPlayerNames}
  button $w.b.ok -text OK -command editMyPlayerNamesOK
  button $w.b.cancel -text $::tr(Cancel) -command "destroy $w"
  pack $w.b.cancel $w.b.ok -side right -padx 5 -pady 5
  pack $w.b.white $w.b.black $w.b.help -side left -padx 5 -pady 5

  bind $w <Escape> "destroy $w"
  update
  placeWinOverParent $w .
  wm state $w normal
  update
}

proc editMyPlayerNamesOK {} {
  global myPlayerNames
  set w .editMyPlayerNames
  set text [string trim [$w.f.text get 1.0 end]]
  set myPlayerNames {}
  foreach name [split $text "\n"] {
    set name [string trim $name]
    if {[string match "\"*\"" $name]} {
      set name [string trim $name "\""]
    }
    if {$name != ""} { lappend myPlayerNames $name }
  }
  destroy $w
}

proc getMyPlayerName {{n 0}} {
  global myPlayerNames
  return [string trim [lindex $myPlayerNames $n] {*?}]
}

# flipBoardForPlayerNames
#   Check if either player in the current game has a name that matches
#   a pattern in the specified list and if so, flip the board if
#   necessary to show from that players perspective.

set ::flippedForPlayer 0

proc flipBoardForPlayerNames {namelist {board .main.board}} {
  set white [sc_game info white]
  set black [sc_game info black]
  foreach pattern $namelist {
    if {[string match $pattern $white]} {
      ::board::flip $board 0
      set ::flippedForPlayer 0
      return
    }
    if {[string match $pattern $black]} {
      ::board::flip $board 1
      set ::flippedForPlayer 1
      return
    }
  }
  # This is a little tricky... but not too important
  # If previously we flipped, revert back
  if {$::flippedForPlayer} {
    ::board::flip $board 0
  }
  set ::flippedForPlayer 0
}

# updateBoard:
#    Updates the main board. Also updates the navigation buttons, disabling
#    those that have no effect at this point in the game.
#    Also ensure all menu settings are up to date.
#    If a parameter "-pgn" is specified, the PGN text is also regenerated.
#    If a parameter "-animate" is specified, board changes are animated.
#
#    It is now broken into a few parts, with the later two delayed till we're idle

proc updateBoard {args} {
  global boardSize
  set pgnNeedsUpdate 0
  set animate 0
  set ::selectedSq -1 ; # necessary for bugfix ?
  foreach arg $args {
    if {! [string compare $arg "-pgn"]} { set pgnNeedsUpdate 1 }
    if {! [string compare $arg "-animate"]} { set animate 1 }
  }

  if {$pgnNeedsUpdate} { ::pgn::Refresh $pgnNeedsUpdate }

  # Remove marked squares informations.
  # (This must be done _before_ updating the board!)
  ::board::mark::clear .main.board

  # wtf ! is this doing here ?
  # it does nothing generally as resize2 returns straight away
  # ::board::resize .main.board $boardSize

  ::board::update .main.board [sc_pos board] $animate
  ::board::material .main.board

  after cancel updateBoard2
  after cancel $::updateBoard3_id

  update idletasks

  after idle updateBoard2
  set ::updateBoard3_id [after idle updateBoard3 $pgnNeedsUpdate]
}

set updateBoard3_id {}

proc updateBoard2 {} {

  # Draw arrows and marks, color squares:

  foreach {cmd discard} [::board::mark::getEmbeddedCmds [sc_pos getComment]] {
    set type   [lindex $cmd 0]
    set square [::board::sq [lindex $cmd 1]]
    set color  [lindex $cmd end]
    if {[llength $cmd] < 4} { set cmd [linsert $cmd 2 ""] }
    set dest   [expr {[string match {[a-h][1-8]} [lindex $cmd 2]] \
          ? [::board::sq [lindex $cmd 2]] : [lindex $cmd 2]}]
    # add mark to board
    ::board::mark::add .main.board $type $square $dest $color
  }

  # Update the status of each navigation button:
  if {[sc_pos isAt start]} {
    .main.button.start configure -state disabled
  } else { .main.button.start configure -state normal }
  if {[sc_pos isAt end]} {
    .main.button.end configure -state disabled
  } else { .main.button.end configure -state normal }
  if {[sc_pos isAt vstart]} {
    .main.button.back configure -state disabled
  } else { .main.button.back configure -state normal }
  if {[sc_pos isAt vend]} {
    .main.button.forward configure -state disabled
  } else { .main.button.forward configure -state normal }
  # Cannot add a variation to an empty line:
  if {[sc_pos isAt vstart]  &&  [sc_pos isAt vend]} {
    .menu.edit entryconfig [tr EditAdd] -state disabled
    .menu.edit entryconfig [tr EditPasteVar]  -state disabled
    .main.button.addVar configure -state disabled
  } else {
    .menu.edit entryconfig [tr EditAdd] -state normal
    .menu.edit entryconfig [tr EditPasteVar] -state normal
    .main.button.addVar configure -state normal
  }
  if {[sc_var count] == 0} {
    .main.button.intoVar configure -state disabled
    .menu.edit entryconfig [tr EditDelete] -state disabled
    .menu.edit entryconfig [tr EditFirst] -state disabled
    .menu.edit entryconfig [tr EditMain] -state disabled
  } else {
    .main.button.intoVar configure -state normal
    .menu.edit entryconfig [tr EditDelete] -state normal
    .menu.edit entryconfig [tr EditFirst] -state normal
    .menu.edit entryconfig [tr EditMain] -state normal
  }

  # FICS examine mode 
  if {$::fics::playing == 2} {
    .main.button.back    configure -state normal
    .main.button.forward configure -state normal
    .main.button.start   configure -state normal
    .main.button.end     configure -state normal
  }

  updateVarMenus
  if {[sc_var level] == 0} {
    .main.button.exitVar configure -state disabled
  } else {
    .main.button.exitVar configure -state normal
  }

}

proc updateBoard3 {pgnNeedsUpdate} {

  if {![sc_base inUse]  ||  $::trialMode  ||  [sc_base isReadOnly]} {
    .main.tb.save configure -state disabled
  } else {
    .main.tb.save configure -state normal
  }

  updateGameinfo

  #TODO
  #Each function should be safe and check the appropriate "winfo exists" at the start
  #Change the order of refreshs: for example ::pgn::Refresh should be done before UpdatePlayerPhotos 

  updatePlayerPhotos
  updateEpdWins
  updateAnalysisWindows

  ::commenteditor::Refresh
  if {[::tb::isopen]} { ::tb::results }
  updateMenuStates

  # Show a warning message in the statusbar if Fics is playing
  # The statusbar is updated by moveEntry_Clear
  if {[winfo exists .fics] && ![sc_pos isAt end] && ($::fics::playing==1 || $::fics::playing==-1)} {
    moveEntry_Clear
    set ::statusBar "Fics: warning, board doesn't show current game position"
    .main.statusbar configure -foreground red3
  } else {
    .main.statusbar configure -foreground black
    moveEntry_Clear
  }

  if {[winfo exists .twinchecker]} { updateTwinChecker }
  ::pgn::Refresh $pgnNeedsUpdate
  if {[winfo exists .bookWin]} { ::book::refresh }
  if {[winfo exists .bookTuningWin]} { ::book::refreshTuning }
  if {[winfo exists .noveltyWin]} { updateNoveltyWin }

  # Refresh tree last because it is slowest. Side effects ?
  ::tree::refresh
}

proc updateGameinfo {} {
  global gameInfo

  .main.gameInfo configure -state normal
  .main.gameInfo delete 0.0 end
  ::htext::display .main.gameInfo [sc_game info -hide $gameInfo(hideNextMove) \
      -material $gameInfo(showMaterial) \
      -cfull $gameInfo(fullComment) \
      -fen $gameInfo(showFEN) -tb $gameInfo(showTB)]
  if {$gameInfo(wrap)} {
    .main.gameInfo configure -wrap word
    .main.gameInfo tag configure wrap -lmargin2 10
    .main.gameInfo tag add wrap 1.0 end
  } else {
    .main.gameInfo configure -wrap none
  }
  .main.gameInfo configure -state disabled
}

proc checkGameInfoHeight {{init 0}} {
  ### only called at init and when showFEN or showTB is changed
  # OSX seems to refresh button bars very slowly, so to limit occasions this
  # happens, leave a little extra room down below
  .main.gameInfo configure -height [expr {5 + $::gameInfo(showFEN) + $::macOS}]
  # + ($::gameInfo(showTB) ? 1 : 0) 
  if {!$init} { updateBoard }
}

checkGameInfoHeight 1

# Set up player photos:

image create photo photoW
image create photo photoB
label .main.photoW  -image photoW -anchor ne
label .main.photoB  -image photoB -anchor ne

proc readPhotoFile {fname} {
  set oldcount [array size ::photo]
  if {! [file readable $fname]} { return }
  catch {source $fname}
  set newcount [expr {[array size ::photo] - $oldcount}]
  if {$newcount > 0} {
    ::splash::add "Found $newcount player photos in [file tail $fname]"
  }
}

proc photo {player data} {
  #convert names tolower case and strip the first two blanks.
  set player [string tolower $player]
  set strindex [string first "\ " $player]
  set player [string replace $player $strindex $strindex]
  set strindex [string first "\ " $player]
  set player [string replace $player $strindex $strindex]
  set ::photo($player) $data
}

array set photo {}

# Read all Scid photo (*.spf) files in the Scid data/user/config directories:
foreach photofile [glob -nocomplain -directory $scidDataDir "*.spf"] {
  readPhotoFile $photofile
}
foreach photofile [glob -nocomplain -directory $scidUserDir "*.spf"] {
  readPhotoFile $photofile
}
foreach photofile [glob -nocomplain -directory $scidConfigDir "*.spf"] {
  readPhotoFile $photofile
}
foreach photofile [glob -nocomplain -directory [file join $scidShareDir "photos"] "*.spf"] {
  readPhotoFile $photofile
}

# Read players.img for compatibility with older versions:
readPhotoFile [file join $scidUserDir players.img]


# Try to change the engine name: ignore version number, try to ignore blanks
proc trimEngineName { engine } {
  set engine [sc_name retrievename $engine]

  set engine [string tolower $engine]
  if { [string first "deep " $engine] == 0 } {
    # strip "deep "
    set engine [string range $engine 5 end]
  }
  # delete two first blank to make "The King" same as "TheKing"
  # or "Green Light Chess" as "Greenlightchess"
  set strindex [string first "\ " $engine]
  set engine [string replace $engine $strindex $strindex]
  set strindex [string first "\ " $engine]
  set engine [string replace $engine $strindex $strindex]
  set strindex [string first "," $engine]
  set slen [string len $engine]
  if { $strindex == -1 && $slen > 2 } {
    #seems to be a engine name:
    # search until longest name matches an engine name
    set slen [string len $engine]
    for { set strindex $slen} {![info exists ::photo([string range $engine 0 $strindex])]\
          && $strindex > 2 } {set strindex [expr {$strindex - 1}] } { }
    set engine [string range $engine 0 $strindex]
  }
  return $engine
}

#   Updates the player photos in the game information area
#   for the two players of the current game.

proc updatePlayerPhotos {{force ""}} {
  global photo
  if {$force == "-force"} {
    # Force update even if it seems unnecessary. This is done
    # when the user selects to show or hide the photos.
    place forget .main.photoW
    place forget .main.photoB
  }
  if {! $::gameInfo(photos)} { return }

  ### Get photo from players
  set white [sc_game info white]
  set black [sc_game info black]
  catch { set white [trimEngineName $white] }
  catch { set black [trimEngineName $black] }
  if {[info exists ::photo($black)]} {
    image create photo photoB -data $::photo($black)
    image create photo photoB2 
    photoB2 copy photoB -subsample 2 2
    # force to update white, black size could be changed
  } else {
    image create photo photoB -data {}
    image create photo photoB2 -data {}
  }
  if {[info exists ::photo($white)]} {
    image create photo photoW -data $::photo($white)
    image create photo photoW2 
    photoW2 copy photoW -subsample 2 2
  } else {
    image create photo photoW -data {}
    image create photo photoW2 -data {}
  }

  mapPhotos

  bind .main.photoW <ButtonPress-1> togglePhotosSize
  bind .main.photoB <ButtonPress-1> togglePhotosSize
}

proc togglePhotosSize {} {
  set ::photosMinimized [expr !$::photosMinimized]
  mapPhotos
}

proc mapPhotos {} {

  if {!$::photosMinimized} {
    set distance [expr {[image width photoB]}]
    if { $distance < 10 } { set distance 80 }
    .main.photoB configure -image photoB -anchor ne
    place .main.photoB -in .main.gameInfo -x -0         -y 0 -relx 1.0 -relheight 1 -anchor ne
    .main.photoW configure -image photoW -anchor ne
    place .main.photoW -in .main.gameInfo -x -$distance -y 0 -rely 0.0 -relx 1.0 -relheight 1 -anchor ne
  } else  {
    .main.photoB configure -image photoB2 -anchor ne
    place .main.photoB -in .main.gameInfo -x -0 -y 0 -relx 1.0 -relheight .5 -anchor ne
    .main.photoW configure -image photoW2 -anchor ne
    place .main.photoW -in .main.gameInfo -x -0 -rely 0.51 -relx 1.0 -relheight .5 -anchor ne
  }

}
#########################################################
### Chess move input

# Globals for mouse-based move input:

set selectedSq -1
set currentSq -1
set bestSq -1

set EMPTY 0
set KING 1
set QUEEN 2
set ROOK 3
set BISHOP 4
set KNIGHT 5
set PAWN 6

################################################################################
#
################################################################################
proc getPromoPiece {} {
  global boardSize

  set w .promoWin
  set ::result 2 ; # queen
  if {$::fics::playing && $::fics::autopromote} {
     return $::result
  }
  set ::selectedSq -1
  toplevel $w
  wm transient $w .
  wm title $w "Promotion"
  wm resizable $w 0 0

  set col "w"
  if { [sc_pos side] == "black" } { set col "b" }
  set size [boardSize_plus_n -1]
  # OSX requires ttk::button because the png images get messed-up
  ttk::button $w.bq -image ${col}q$size -command "set ::result 2 ; destroy $w"
  ttk::button $w.br -image ${col}r$size -command "set ::result 3 ; destroy $w"
  ttk::button $w.bb -image ${col}b$size -command "set ::result 4 ; destroy $w"
  ttk::button $w.bn -image ${col}n$size -command "set ::result 5 ; destroy $w"
  pack $w.bq $w.br $w.bb $w.bn -side left
  bind $w <Escape> "set ::result 2 ; destroy $w"
  bind $w <Return> "set ::result 2 ; destroy $w"

  placeWinOverPointer $w
  ### hmmm... this update can cause the window to get dismissed before grab
  # update 
  tkwait visibility $w
  grab $w
  tkwait window $w
  return $::result
}

# confirmReplaceMove:
#   Asks the user what to do when adding a move when a move already
#   exists.
#   Returns a string value:
#      "replace" to replace the move, truncating the game.
#      "var" to add the move as a new variation.
#      "cancel" to do nothing.
#
set addVariationWithoutAsking 0

proc confirmReplaceMove {} {
  global askToReplaceMoves trialMode

  set ::selectedSq -1 ;# may fix a rare bug about move clicking S.A.

  if {$::addVariationWithoutAsking} { return var }

  if {! $askToReplaceMoves} { return replace }
  if {$trialMode} { return replace }

  # http://wiki.tcl.tk/1062
  option add *Dialog.msg.wrapLength 5i interactive
  # option add *Dialog.msg.font {Helvetica 10}
  # Can't bind <Escape> inside tk_dialog.

  catch {tk_dialog .dialog "Scid: $::tr(ReplaceMove)?" \
        $::tr(ReplaceMoveMessage) {} 2 \
        $::tr(ReplaceMove) $::tr(NewMainLine) \
        $::tr(AddNewVar) [tr EditTrial] \
        $::tr(Cancel)} answer
  option add *Dialog.msg.wrapLength 3i interactive
  if {$answer == 0} { return replace }
  if {$answer == 1} { return mainline }
  if {$answer == 2} { return var }
  if {$answer == 3} { setTrialMode 1; return replace }

  return cancel
}

### unused S.A.
# proc addNullMove {} { addMove null null }

# addMove:
#   Adds the move indicated by sq1 and sq2 if it is legal. If the move
#   is a promotion, getPromoPiece will be called to get the promotion
#   piece from the user.
#   If the optional parameter is "-animate", the move will be animated.

proc addMove { sq1 sq2 {animate ""}} {
  if { $::fics::playing == -1} { return } ;# not player's turn

  global EMPTY

  set nullmove [expr {$sq1 == "null"  &&  $sq2 == "null"}]

  if {!$nullmove  &&  [sc_pos isLegal $sq1 $sq2] == 0} {
    # Illegal move, but if it is King takes king then treat it as
    # entering a null move:
    set board [sc_pos board]
    set k1 [string tolower [string index $board $sq1]]
    set k2 [string tolower [string index $board $sq2]]
    if {$k1 == "k"  &&  $k2 == "k"} {
      set nullmove 1
    } else {
      return
    }
  }

  if {[sc_pos isPromotion $sq1 $sq2] == 1} {
    # sometimes, addMove is triggered twice
    if { [winfo exists .promoWin] } { return }
    set promo [getPromoPiece]
  } else {
    set promo $EMPTY
  }

  switch -- $promo {
    2 { set promoLetter "q"}
    3 { set promoLetter "r"}
    4 { set promoLetter "b"}
    5 { set promoLetter "n"}
    default {set promoLetter ""}
  }

  set moveUCI [::board::san $sq2][::board::san $sq1]$promoLetter
  ### moveUCI seems to be used by serGame, novag *and* fics below, so standardise them a little S.A.

  set move [sc_game info nextMoveUCI]
  if { [ string compare -nocase $moveUCI $move] == 0 && ! $nullmove } {
       sc_move forward
       updateBoard
       return
  }

  set varList [sc_var list UCI]
  set i 0
  foreach { move } $varList {
       if { [ string compare -nocase $moveUCI $move] == 0 } {
               sc_var moveInto $i
               updateBoard
               return
       }
       incr i
  }

  if {[sc_pos isAt vend]} {
    set action replace
  } else {
    set action [confirmReplaceMove]
  }

  if {$action == "cancel"} {
    return
  }

  sc_game undoPoint

  if {$action == "mainline" || $action == "var"} {
    sc_var create
  }

  if {$nullmove} {
    # todo: catch entering a null move while in check, which currently causes an error and wrecks the game
    sc_move addSan null
  } else {
    # if {[winfo exists .commentWin]} { .commentWin.cf.text delete 0.0 end }
    sc_move add $sq1 $sq2 $promo
    set san [sc_game info previous]
    if {$action == "mainline"} {
      sc_var exit
      sc_var promote [expr {[sc_var count] - 1}]
      sc_move forward 1
    }

    ### We need to do this incase moveUCI move was back to front because of reverse order square presses (eg e4e2)
    set moveUCI [sc_game info previousMoveUCI]

    ::fics::checkAdd

    if {[winfo exists .serGameWin]} {
      set ::sergame::lastPlayerMoveUci $moveUCI
    } else {
      set ::sergame::lastPlayerMoveUci ""
    }

    if {$::novag::connected} {
      ::novag::addMove $moveUCI
    }

    after idle [list ::utils::sound::AnnounceNewMove $san]
  }

  moveEntry_Clear
  updateBoard -pgn $animate

  ::tree::doTraining
}

# addSanMove
#   Like addMove above, but takes the move in SAN notation instead of
#   a pair of squares.
#
proc addSanMove {san {animate ""} {noTraining ""}} {
  set move [sc_game info nextMoveNT]
  if { [ string compare -nocase $san $move] == 0 } {
       sc_move forward
       updateBoard
       return
  }
  set varList [sc_var list]
  set i 0
  foreach { move } $varList {
       if { [ string compare -nocase $san $move] == 0 } {
               sc_var moveInto $i
               updateBoard
               return
       }
       incr i
  }

  if {[sc_pos isAt vend]} {
    set action replace
  } else {
    set action [confirmReplaceMove]
  }

  if {$action == "cancel"} {
    return
  }

  sc_game undoPoint

  if {$action == "var" || $action == "mainline"} {
    sc_var create
  } 

  # if {[winfo exists .commentWin]} { .commentWin.cf.text delete 0.0 end }
  sc_move addSan $san
  ::fics::checkAdd
  if {$action == "mainline"} {
    sc_var exit
    sc_var promote [expr {[sc_var count] - 1}]
  }
  moveEntry_Clear
  updateBoard -pgn $animate
  ::utils::sound::AnnounceNewMove $san
  if {$noTraining != "-notraining"} {
    ::tree::doTraining
  }
}

# enterSquare:
#   Called when the mouse pointer enters a board square.
#   Finds the best matching square for a move (if there is a
#   legal move to or from this square), and colors the squares
#   to indicate the suggested move.
#
proc enterSquare { square } {
  global highcolor currentSq bestSq bestcolor selectedSq suggestMoves
  set currentSq $square
  if {$selectedSq == -1} {
    set bestSq -1
    if {$suggestMoves} {
      set bestSq [sc_pos bestSquare $square]
    }
    if {[expr {$bestSq != -1}]} {
      ::board::colorSquare .main.board $square $bestcolor
      ::board::colorSquare .main.board $bestSq $bestcolor
    }
  }
}

# leaveSquare:
#    Called when the mouse pointer leaves a board square.
#    Recolors squares to normal (lite/dark) color.
#
proc leaveSquare { square } {
  global currentSq selectedSq bestSq
  #Klimmek: not needed anymore
  #  if {$square != $selectedSq} {
  #    ::board::colorSquare .main.board $square
  #  }
  if {$bestSq != -1} {
    #Klimmek: changed, because Scid "hangs" very often (after 5-7 moves)
    #    ::board::colorSquare .main.board $bestSq
    ::board::update .main.board
  }
}

# pressSquare:
#    Called when the left mouse button is pressed on a square. Sets
#    that square to be the selected square.
#
proc pressSquare {square confirm} {

  global selectedSq highcolor

  set ::addVariationWithoutAsking $confirm

  if { [winfo exists .fics] && $::fics::playing == -1} { return } ;# not player's turn

  # if training with calculations of var is on, just log the event
  if { [winfo exists .calvarWin] } {
    ::calvar::pressSquare $square
    return
  }

  if {$selectedSq == -1} {
    set selectedSq $square
    ::board::colorSquare .main.board $square $highcolor
    # Drag this piece if it is the same color as the side to move:
    set c [string index [sc_pos side] 0]  ;# will be "w" or "b"
    set p [string index [::board::piece .main.board $square] 0] ;# "w", "b" or "e"
    if {$c == $p} {
      ::board::setDragSquare .main.board $square
    }
  } else {
    ::board::setDragSquare .main.board -1
    ::board::colorSquare .main.board $selectedSq
    ::board::colorSquare .main.board $square
    if {$square != $selectedSq} {
      addMove $square $selectedSq -animate
    }
    set selectedSq -1
    enterSquare $square
  }
}

# releaseSquare:
#   Called when the left mouse button is released over a square.
#   If the square is different to that the button was pressed on, it
#   is a dragged move; otherwise it is just selecting this square as
#   part of a move.

proc releaseSquare { x y } {

  if { [winfo exists .calvarWin] } { return }

  global selectedSq bestSq

  set w .main.board
  ::board::setDragSquare $w -1
  set square [::board::getSquare $w $x $y]
  if {$square < 0} {
    set selectedSq -1
    return
  }

  if {$square == $selectedSq} {
    if {$::suggestMoves} {
      # User pressed and released on same square, so make the
      # suggested move if there is one:
      set selectedSq -1
      ::board::colorSquare $w $bestSq
      ::board::colorSquare $w $square
      addMove $square $bestSq -animate
      enterSquare $square
    } else {
      # Current square is the square user pressed the button on,
      # so we do nothing.
    }
  } else {
    if {$selectedSq == -1} {
      return
    }
    # User has dragged to another square, so try to add this as a move:
    addMove $square $selectedSq
    ::board::colorSquare $w $selectedSq
    set selectedSq -1
    ::board::colorSquare $w $square
  }
  set ::addVariationWithoutAsking 0
}

# backSquare: removed by S.A. Use ::move::Back instead


### Auto-playing of moves including lots of Annotation stuff

set autoplayMode 0
set tempdelay 0
trace variable tempdelay w {::utils::validate::Regexp {^[0-9]*\.?[0-9]*$}}


proc setAutoplayDelay {} {
  global autoplayDelay tempdelay

  set w .apdialog
  if {[winfo exists $w]} {
    focus $w
    return
  }
  set tempdelay [expr {$autoplayDelay / 1000.0}]

  toplevel $w
  wm state $w withdrawn
  wm title $w {Move Delay}

  label $w.label -text $::tr(AnnotateTime)
  pack $w.label -side top -pady 5 -padx 5
  spinbox $w.spDelay  -width 4 -textvariable tempdelay -from 1 -to 300 -increment 1
  pack $w.spDelay -side top -pady 5

  set b [frame $w.buttons]
  pack $b -side top -fill x
  dialogbutton $b.cancel -text $::tr(Cancel) -command {
    destroy .apdialog
    focus .main
  }
  dialogbutton $b.ok -text "OK" -command {
    if {$tempdelay < 0.1} { set tempdelay 0.1 }
    set autoplayDelay [expr {int($tempdelay * 1000)}]
    destroy .apdialog
    focus .main
  }
  pack $b.cancel $b.ok -side right -padx 5 -pady 5
  bind $w <Escape> { .apdialog.buttons.cancel invoke }
  bind $w <Return> { .apdialog.buttons.ok invoke }

  placeWinOverParent $w .
  wm state $w normal
  focus $w.spDelay
}

proc toggleAutoplay {} {
  global autoplayMode
  if {$autoplayMode == 0} {
    set autoplayMode 1
    .main.button.autoplay configure -image autoplay_on ; # -relief sunken S.A.
    autoplay
  } else {
    cancelAutoplay
  }
}

### Automatically move through a games moves at a certain speed.

proc autoplay {} {
  global autoplayDelay autoplayMode annotateEngine analysis

  ### autoplay had issues when not using book and moving from one game to the next
  # Hard to fix because of the (variation) stack

  if {$autoplayMode == 0} {
    return
  }

  set n $annotateEngine

  if {$n == -1} {
    ::move::Forward
    if {[sc_pos isAt vend]} {
      cancelAutoplay
    } else {
      after $autoplayDelay autoplay
    }
    return
  }

  ### Engine Annotation feature

  if { ![sc_pos isAt start] } {
    addAnnotation
  }

  # stop game annotation when out of opening

  if { $::isBatch && $::isOpeningOnly && \
        ( [sc_pos moveNumber] > $::isOpeningOnlyMoves || $::wentOutOfBook)} {
      nextgameAutoplay $n
      return
  }

  if {$::isOpeningOnly && $::wentOutOfBook} {
    cancelAutoplay
    return
  }

  if { [sc_pos isAt end] } {
    set move_done [sc_game info previousMoveNT]
    if { [string index $move_done end] != "#" && $::annotateWithVars != "no"} {
      set text [format "%d:%+.2f" $analysis(depth$n) $analysis(score$n)]
      set moves $analysis(moves$n)
      sc_move back
      sc_info preMoveCmd {}
      sc_var create
      sc_move addSan $move_done
      sc_pos setComment "[sc_pos getComment] $text"
      sc_move_add $moves $n
      sc_var exit
      sc_info preMoveCmd preMoveCommand
      updateBoard -pgn
    }
    if {$::isBatch && [sc_game number] != 0} {
      nextgameAutoplay $n
      return
    }
    cancelAutoplay
    return
  }

  ### Annotate variations

  if {$::isAnnotateVar} {
    if { [sc_pos isAt vend] } {
      sc_var exit
      set lastVar [::popAnalysisData $n]
      if { $lastVar > 0 } {
        incr lastVar -1
        sc_var enter $lastVar
        updateBoard -pgn
        ::pushAnalysisData $lastVar $n
      } else {
        ::move::Forward
      }
    } else {
      if {[sc_var count] > 0} {
        set lastVar [expr [sc_var count] -1]
        sc_var enter $lastVar
        updateBoard -pgn
        ::pushAnalysisData $lastVar $n
      } else  {
        ::move::Forward
      }
    }
  } else {
    ::move::Forward
  }

  after $autoplayDelay autoplay
}


proc nextgameAutoplay {n} {
  global autoplayDelay analysis

  toggleEngineAnalysis $n 1
  sc_game save [sc_game number]
  set analysis(prevscore$n) 0

  if {[sc_filter next] <= $::batchEnd  && [sc_filter next] != 0} {
    # if [sc_game number] < $::batchEnd
    # sc_game load [expr [sc_game number] + 1]

    ### Skip games not in filter (dont autoraise main window)
    ::game::LoadNextPrev next 0

    if {$::addAnnotatorTag} {
      appendTag Annotator " $analysis(name$n)"
    }
    set ::wentOutOfBook 0
    updateMenuStates
    updateStatusBar
    updateTitle
    updateBoard -pgn
    ### this seems wrong.. it adds a score/var before the book
    # addAnnotation

    set ::stack {}
    set analysis(prevscore$n) 0
    set analysis(score$n)     0
    set analysis(prevmoves$n) {}
    set analysis(moves$n)     {}
    set analysis(prevdepth$n) 0

    toggleEngineAnalysis $n 1
    after $autoplayDelay autoplay
  } else  {
    cancelAutoplay
  }
}

proc cancelAutoplay {} {
  global autoplayMode annotateEngine annotateButton

  set autoplayMode 0
  set annotateEngine -1
  set annotateButton 0
  after cancel autoplay
  .main.button.autoplay configure -image autoplay_off
}

set trialMode 0

proc setTrialMode {mode} {
  global trialMode
  if {$mode == "toggle"} {
    set mode [expr {1 - $trialMode}]
  }
  if {$mode == $trialMode} { return }
  if {$mode == "update"} { set mode $trialMode }

  if {$mode == 1} {
    set trialMode 1
    sc_game push copy
    .main.button.trial configure -image tb_trial_on
  } else {
    set trialMode 0
    sc_game pop
    .main.button.trial configure -image tb_trial
  }
  updateBoard -pgn
}

### Pause UCI and Phalanx games when an out of order move is made

proc pauseGame {args} {
  set ::paused 1
  if {[winfo exists .coachWin]} {
    .coachWin.fbuttons.resume configure -state normal
    after cancel ::tacgame::phalanxGo
  }
  if {[winfo exists .serGameWin]} {
    .serGameWin.fbuttons.resume configure -state normal
    after cancel ::sergame::engineGo
  }
}

### Add current position, and check for 3 fold repetition

proc checkRepetition {} {
  set elt [lrange [split [sc_pos fen]] 0 2]
  if {$elt == [lindex $::lFen end]} {
    return 0
  }

  lappend ::lFen $elt
  if { [llength [lsearch -all $::lFen $elt] ] >=3 && ! $::drawShown } {
    set ::drawShown 1
    pauseGame
    sc_game tags set -result =
    tk_messageBox -type ok -message $::tr(Draw) -parent .main.board -icon info
    puts $::lFen
    catch {sc_game save [sc_game number]}
    return 1
  }
  return 0
}

