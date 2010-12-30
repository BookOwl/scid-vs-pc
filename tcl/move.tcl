### move.tcl
### Functions for moving within a game.

namespace eval ::move {}

proc ::move::drawVarArrows {} {
  if {! $::showVarArrows || $::autoplayMode} { return 0 }
  if {[winfo exists .coachWin]} { return 0 }
  if {[winfo exists .serGameWin]} { return 0 }
  
  set bDrawArrow 0
  set varList [sc_var list UCI]

  if {$varList != ""} {    
    set move [sc_game info nextMoveUCI]
    if {$move != ""} { set varList [linsert $varList 0 $move] }    
    foreach { move } $varList {
      set bDrawn 0      
      set sq_start [ ::board::sq [ string range $move 0 1 ] ]
      set sq_end [ ::board::sq [ string range $move 2 3 ] ]
        foreach mark $::board::_mark(.board) {
          if { [lindex $mark 0] == "arrow" ||[lindex $mark 0] == "var" } {
	    if {[lindex $mark 1] == $sq_start && [lindex $mark 2] == $sq_end} { 
	      set bDrawn 1
	      break
	    }
        }
      }
      if {! $bDrawn } { set bDrawArrow 1; break }
    }
  }
  
  return $bDrawArrow
}

proc ::move::showVarArrows {} {
  set move [sc_game info nextMoveUCI]
  set varList [sc_var list UCI]  

  # It's a little hard to pass this arg to DrawVar through the overloaded
  # ::board::mark::add, so use a global, and a max check because of an isseu somewhere :<

  set ::move::var 0
  set ::move::maxvar [llength $varList]

  if {$move != ""} {
    set sq_start [ ::board::sq [ string range $move 0 1 ] ]
    set sq_end [ ::board::sq [ string range $move 2 3 ] ]
    ::board::mark::add .board var $sq_start $sq_end black
    incr ::move::var
  }

  foreach { move } $varList {
    set sq_start [ ::board::sq [ string range $move 0 1 ] ]
    set sq_end [ ::board::sq [ string range $move 2 3 ] ]
    ::board::mark::add .board var $sq_start $sq_end grey
    incr ::move::var
  }
}

proc ::move::Start {} {
  if {$::tree(refresh)} { return }
  set ::pause 1
  sc_move start
  updateBoard  -pgn
  if {[::move::drawVarArrows]} { ::move::showVarArrows }
}

proc ::move::End {} {
  if {$::tree(refresh)} { return }
  set ::pause 1
  sc_move end
  updateBoard
  if {[::move::drawVarArrows]} { ::move::showVarArrows }
}

proc ::move::ExitVar {} {
  sc_var exit; 
  updateBoard -animate; 
  # Do comments work properly ?
puts fuck1
  if {[::move::drawVarArrows]} { ::move::showVarArrows }
}

proc ::move::Back {{count 1}} {
  if {$::tree(refresh)} { return }
  if {[sc_pos isAt start]} { return }
  if {[sc_pos isAt vstart]} { ::move::ExitVar; return }

  ### if playing, remove this move from hash array S.A

  set ::tacgame::lFen [lrange $::tacgame::lFen 0 end-$count]

  set ::pause 1

  sc_move back $count

  if {$count == 1} {
    # Do animation and speech:
    updateBoard -animate
    ::utils::sound::AnnounceBack
  } else {
    updateBoard
  }
puts fuck2
  if {[::move::drawVarArrows]} { ::move::showVarArrows }
}

proc ::move::Forward {{count 1}} {
  global autoplayMode

  if {$::tree(refresh)} { return }
  if {[sc_pos isAt end]  ||  [sc_pos isAt vend]} { return }
  set ::pause 1
  set bArrows [::move::drawVarArrows]

  set move [sc_game info next]
  if {$count == 1} {
    if {[sc_var count] != 0 && ! $autoplayMode && $::showVarPopup} {
      ::commenteditor::storeComment
      showVars
      set bArrows $::showVarArrows
    } else  {
      if {! $bArrows} { sc_move forward }
    }

    # Animate and speak this move:
    updateBoard -animate
    ::utils::sound::AnnounceForward $move
  } else {
    if {! $bArrows} { sc_move forward $count }
    updateBoard
  }
  if {$bArrows} {puts fuck3; ::move::showVarArrows }
}


