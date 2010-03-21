proc fenErrorDialog {{msg {}}} {

  if {[winfo exists .setup]} {
    tk_messageBox -icon info -type ok -title "Scid: Invalid FEN" -message $msg -parent .setup
  } else {
    tk_messageBox -icon info -type ok -title "Scid: Invalid FEN" -message $msg 
  }

}

# copyFEN
#
#   Copies the FEN of the current position to the text clipboard.
#
proc copyFEN {} {
  set fen [sc_pos fen]
  # Create a text widget to hold the fen so it can be the owner
  # of the current text selection:
  set w .tempFEN
  if {! [winfo exists $w]} { text $w }
  $w delete 1.0 end
  $w insert end $fen sel
  clipboard clear
  clipboard append $fen
  selection own $w
  selection get
}

# pasteFEN
#
#   Bypasses the board setup window and tries to paste the current
#   text selection as the setup position, producing a message box
#   if the selection does not appear to be a valid FEN string.
#
proc pasteFEN {} {
  set fenStr ""
  if {[catch {set fenStr [selection get -selection PRIMARY]} ]} {
    catch {set fenStr [selection get -selection CLIPBOARD]}
  }
  set fenStr [string trim $fenStr]

  set fenExplanation {FEN is the standard text representation of a chess position. As an example, the FEN representation of the standard starting position is:
"rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"}

  if {$fenStr == ""} {
    set msg "The current text selection is empty. To paste the start board, select some text that contains a position in FEN notation.\n\n$fenExplanation"
    fenErrorDialog $msg
    return
  }
  if {[catch {sc_game startBoard $fenStr}]} {
    if {[string length $fenStr] > 80} {
      set fenStr [string range $fenStr 0 80]
      append fenStr "..."
    }
    set msg "\"$fenStr\" is not a valid chess position in FEN notation.\n\n $fenExplanation"

    fenErrorDialog $msg
    return
  }
  updateBoard -pgn
}

proc setSetupBoardToFen {w setupFen} {

  # Called from ".setup.fencombo" FEN combo S.A

  # Once the FEN combo box in the Setup board widget is accessed, the original
  # game poisiotn can still be had, but game history is lost

  global setupboardSize setupBd


  if {[catch {sc_game startBoard $setupFen} err]} {
    fenErrorDialog $err
  } else {
    # ::utils::history::AddEntry setupFen $setupFen
    set setupBd [sc_pos board]
    setBoard .setup.l.bd $setupBd $setupboardSize
  }
}

############################################################
### Board setup window:

set setupBd {}
set setupFen {}

# makeSetupFen:
#    Reconstructs the FEN string from the current settings in the
#    setupBoard dialog. Check to see if the position is
#    acceptable (a position can be unacceptable by not having exactly
#    one King per side, or by having more than 16 pieces per side).
#

proc makeSetupFen {args} {
  global setupFen setupBd moveNum toMove castling epFile
  set fenStr ""
  set errorStr [validateSetup]
  if {$errorStr != ""} {
    set setupFen "Invalid board: $errorStr"
    return
  }
  for {set bRow 56} {$bRow >= 0} {incr bRow -8} {
    if {$bRow < 56} { append fenStr "/" }
    set emptyRun 0
    for {set bCol 0} {$bCol < 8} {incr bCol} {
      set sq [expr {$bRow + $bCol} ]
      set piece [string index $setupBd $sq]
      if {$piece == "."} {
        incr emptyRun
      } else {
        if {$emptyRun > 0} {
          append fenStr $emptyRun
          set emptyRun 0
        }
        append fenStr $piece
      }
    }
    if {$emptyRun > 0} { append fenStr $emptyRun }
  }
  append fenStr " " [string tolower [string index $toMove 0]] " "
  if {$castling == ""} {
    append fenStr "- "
  } else {
    append fenStr $castling " "
  }
  if {$epFile == ""  ||  $epFile == "-"} {
    append fenStr "-"
  } else {
    append fenStr $epFile
    if {$toMove == "White"} {
      append fenStr "6"
    } else {
      append fenStr "3"
    }
  }
  # We assume a halfmove clock of zero:
  append fenStr " 0 " $moveNum
  set setupFen $fenStr
}

# validateSetup:
#   Called by makeSetupFen to check that the board is sensible: that is,
#   that there is one king per side and there are at most 16 pieces per
#   side.
#
proc validateSetup {} {
  global setupBd
  set wkCount 0; set bkCount 0; set wCount 0; set bCount 0
  set wpCount 0; set bpCount 0
  for {set i 0} {$i < 64} {incr i} {
    set p [string index $setupBd $i]
    if {$p == "."} {
    } elseif {$p == "P"} { incr wCount; incr wpCount
    } elseif {$p == "p"} { incr bCount; incr bpCount
    } elseif {$p == "N" || $p == "B" || $p == "R" || $p == "Q"} {
      incr wCount
    } elseif {$p == "n" || $p == "b" || $p == "r" || $p == "q"} {
      incr bCount
    } elseif {$p == "K"} { incr wCount; incr wkCount
    } elseif {$p == "k"} { incr bCount; incr bkCount
    } else { return "Invalid piece: $p" }
  }
  if {$wkCount != 1} { return "There must be one white king"
  } elseif {$bkCount != 1} { return "There must be one black king"
  } elseif {$wCount > 16} { return "Too many white pieces"
  } elseif {$bCount > 16} { return "Too many black pieces"
  } elseif {$wpCount > 8} { return "Too many white pawns"
  } elseif {$bpCount > 8} { return "Too many black pawns" }
  return ""
}

proc useBoardPiece { square } {
  global setupBd pastePiece 

  set temp [string index $setupBd $square]
  if {$temp != "."} {
    set pastePiece $temp
  }
}

# setupBoardPiece:
#    Called by setupBoard to set or clear a square when it is clicked on.
#    Sets that square to containing the active piece (stored in pastePiece)
#    unless it already contains that piece, in which case the square is
#    cleared to be empty.
# S.A. It's a little better now. but should implement dragging pieces

proc setupBoardPiece { square {clear 0}} {
  global setupBd pastePiece setupboardSize setupFen
  set oldState $setupBd
  set setupBd {}
  set piece $pastePiece

  if {[string index $oldState $square] == $pastePiece || $clear } {
    if {$clear} {
      set temp [string index $oldState $square]
      if {$temp != "."} {
	set pastePiece $temp
      }
    }
    set piece "."
  }
  if {$piece == "P"  ||  $piece == "p"} {
    if {$square < 8  ||  $square >= 56} {
      set setupBd $oldState
      unset oldState
      return
    }
  }
  append setupBd \
    [string range $oldState 0 [expr {$square - 1} ]] \
    $piece \
    [string range $oldState [expr {$square + 1} ] 63]
  unset oldState
  setBoard .setup.l.bd $setupBd $setupboardSize
  makeSetupFen
}

# switchPastePiece:
#   Changes the active piece selection in the board setup dialog to the
#   next or previous piece in order.
#
proc switchPastePiece { switchType } {
  global pastePiece
  array set nextPiece { K Q Q R R B B N N P P k k q q r r b b n n p p K}
  array set prevPiece { K p Q K R Q B R N B P N k P q k r q b r n b p n}
  if {$switchType == "next"} {
    set pastePiece $nextPiece($pastePiece)
  } else {
    set pastePiece $prevPiece($pastePiece)
  }
}

proc exitSetupBoard {} {

  # called when "OK" button hit

  global setupFen

  # unbind cancel binding
  bind .setup <Destroy> {}

  if {[catch {sc_game startBoard $setupFen} err]} {
    fenErrorDialog $err
    bind .setup <Destroy> cancelSetupBoard

    # Ideally, "$err" should be more specific than "Invalid FEN", but
    # procedural flow is a little complicated S.A.
  } else {
    ::utils::history::AddEntry setupFen $setupFen
    destroy .setup
    updateBoard -pgn
  }
}

proc cancelSetupBoard {} {

  # When FEN strings are previewed, the gameboard state is changed, but *not*
  # drawn in the main window. This means that while the game state can be
  # restored in the event of user hitting "cancel", game history has been lost
  # This behaviour is necessary to enable FEN previewing.

  global origFen

  bind .setup <Destroy> {}

  # restore old gamestate if changed

  if {$origFen != "[sc_pos fen]"} {
    catch {sc_game startBoard $origFen}
    updateBoard -pgn
  }
  destroy .setup
}

# Global variables for entry of the start position:
set epFile {}          ;# legal values are empty, or "a"-"h".
set moveNum 1          ;# legal values are 1-999.
set castling KQkq      ;# will be empty or some combination of KQkq letters.
set toMove White       ;# side to move, "White" or "Black".
set pastePiece K       ;# Piece being pasted, "K", "k", "Q", "q", etc.

# Traces to keep entry values sensible:

trace variable moveNum w {::utils::validate::Integer 999 0}
trace variable epFile w {::utils::validate::Regexp {^(-|[a-h])?$}}
trace variable castling w {::utils::validate::Regexp {^(-|[KQkq]*)$}}


# setupBoard:
#   The main procedure for creating the dialog for setting the start board.
#   Calls switchPastePiece and makeSetupFen.
#   On "Setup" button press, calls sc_pos startBoard to try to set the
#   starting board.

#   todo: perhaps ensure all engines have stopped before doing this S.A.

proc setupBoard {} {

  global boardSizes boardSize setupboardSize lite dark setupBd pastePiece \
         toMove epFile moveNum castling setupFen highcolor origFen borderwidth

  if {[winfo exists .setup]} { return }

  toplevel .setup
  wm title .setup "Scid: Setup Board"
  setWinLocation .setup

  set origFen [sc_pos fen]

  # Fenframe is a gridded frame at bottom of screen
  frame .setup.fenframe
  pack .setup.fenframe -side bottom -expand yes -fill x

  set sl .setup.l
  set sr .setup.r
  set sbd $sl.bd

  frame $sl
  frame $sr
  pack $sl -side left
  pack $sr -side right -expand yes -fill y

  # make the setup board a couple of sizes smaller
  set setupboardSize [boardSize_plus_n -3]
  set psize $setupboardSize

  # S.A: It seems too hard to implement the setup board like this:
  # ::board::new $sbd $setupboardSize nomat

  # border not implemented yet
  set border $borderwidth
  set bsize [expr $psize * 8 + $border * 9 + 1]

  ### Main setup board/canvas

  # It's fairly hacked together from lots of other places, so i hope it's solid.
  # Trying to make drag and drop... not too easy. - S.A.

  frame $sl.hints
  # label $sl.hints.label1 -text {Mouse buttons:} -font font_SmallItalic
  label $sl.hints.label2 -text {Left button - Paste} -font font_SmallItalic
  label $sl.hints.label3 -text {Middle button - Cut} -font font_SmallItalic
  label $sl.hints.label4 -text {Right button - Copy} -font font_SmallItalic
  pack $sl.hints -side top -expand yes -fill x
  pack $sl.hints.label2 $sl.hints.label3 $sl.hints.label4 -side left -expand yes -fill x

  frame $sbd
  canvas $sbd.bd -width $bsize -height $bsize -background black \
                 -borderwidth 0 -highlightthickness 0
  if {[info tclversion] == 8.5} {
    grid anchor $sbd center
  }

  grid $sbd -row 1 -column 1 -rowspan 8 -columnspan 8

  pack $sbd -padx 10 -pady 10
  pack $sbd.bd

  # Create empty board:
  for {set i 0} {$i < 64} {incr i} {
    set xi [expr {$i % 8} ]
    set yi [expr {int($i/8)} ]
    set x1 [expr {$xi * ($psize + $border) + $border +1 } ]
    set y1 [expr {(7 - $yi) * ($psize + $border) + $border +1 } ]
    set x2 [expr {$x1 + $psize }]
    set y2 [expr {$y1 + $psize }]

    $sbd.bd create rectangle $x1 $y1 $x2 $y2 -tag sq$i -outline "" -fill [::board::defaultColor $i]
    # ::board::colorSquare $sbd $i
    #this inserts a textures on a square and restore piece
    set xc [expr ($x1 + $x2) /2]
    set yc [expr ($y1 + $y2) /2]
    set boc bgd$psize
    if { ($i + ($i / 8)) % 2 } { set boc bgl$psize }
    $sbd.bd delete br$i
    $sbd.bd create image $xc $yc -image $boc -tag br$i

    $sbd.bd bind p$i <ButtonPress-1> "setupBoardPiece $i"
    $sbd.bd bind p$i <ButtonPress-2> "setupBoardPiece $i 1"
    $sbd.bd bind p$i <ButtonPress-3> "useBoardPiece $i"


    # ::board::bind .board $i <ButtonPress-1> "set ::addVariationWithoutAsking 0 ; pressSquare $i"
    # bind $sbd.$i <ButtonPress-1> "setupBoardPiece $i"
  }

  bind .setup <ButtonPress-4> "switchPastePiece next"
  bind .setup <ButtonPress-5> "switchPastePiece prev"

  pack [frame $sl.b] -side top -padx 8 -pady 8    ;# -expand yes -fill x
  pack [frame $sl.w] -side bottom -padx 8 -pady 8 ;# -expand yes -fill x

  set setupBd [sc_pos board]
  setBoard $sbd $setupBd $setupboardSize

  ### Piece Buttons

  # set pastePiece P
  # set toMove White

  set setupboardSize2 [boardSize_plus_n -4]
  foreach i {p n b r q k} {
    foreach color {w b} value "[string toupper $i] $i" {
      radiobutton $sl.$color.$i -image $color$i$setupboardSize2 -indicatoron 0 \
	-variable pastePiece -value $value -activebackground $highcolor 
	# -relief raised -activebackground grey75 -selectcolor rosybrown
      pack $sl.$color.$i -side left ;# -expand yes -fill x -padx 5
    }
  }

  ### Side to move frame.

  frame $sr.tomove
  label $sr.tomove.label -textvar ::tr(SideToMove:)
  frame $sr.tomove.buttons
  radiobutton $sr.tomove.buttons.w -text $::tr(White) -variable toMove -value White \
    -command makeSetupFen
  radiobutton $sr.tomove.buttons.b -text $::tr(Black) -variable toMove -value Black \
    -command makeSetupFen

  pack $sr.tomove -pady 7
  pack $sr.tomove.label -side top -pady 2
  pack $sr.tomove.buttons -side top
  pack $sr.tomove.buttons.w $sr.tomove.buttons.b -side left

  set toMove [lindex $origFen 1]
  if {$toMove == "b" || $toMove == "B"} {
    set toMove Black
  } else {
    set toMove White
  }

  set moveNum [lindex $origFen end]
  if {![string is integer $moveNum]} {
    set moveNum 1
  }

  ### Move number

  pack [frame $sr.mid] -padx 5 -pady 5

  frame $sr.mid.movenum
  label $sr.mid.movenum.label -textvar ::tr(MoveNumber:)
  entry $sr.mid.movenum.e -width 3 -background white -textvariable moveNum

  pack $sr.mid.movenum -pady 10 -expand yes -fill x
  pack $sr.mid.movenum.label $sr.mid.movenum.e -side left -anchor w -expand yes -fill x

  ### Castling 

  frame $sr.mid.castle
  label $sr.mid.castle.label -textvar ::tr(Castling:)
  ::combobox::combobox $sr.mid.castle.e -width 5 \
    -textvariable castling -command makeSetupFen
  foreach c {KQkq KQ kq -} {
    $sr.mid.castle.e list insert end $c
  }

  set castling [lindex $origFen 2]

  pack $sr.mid.castle -pady 10 -expand yes -fill x
  pack $sr.mid.castle.label $sr.mid.castle.e -side left -anchor w -expand yes -fill x

  ### En Passant file

  frame $sr.mid.ep
  label $sr.mid.ep.label -textvar ::tr(EnPassantFile:)
  ::combobox::combobox $sr.mid.ep.e -width 2 -background white -textvariable epFile \
    -command makeSetupFen

  foreach f {- a b c d e f g h} {
    $sr.mid.ep.e list insert end $f
  }

  set epFile [string index [lindex $origFen 3] 0]

  pack $sr.mid.ep -pady 10 -expand yes -fill x
  pack $sr.mid.ep.label $sr.mid.ep.e -side left -anchor w -expand yes -fill x

  # Set bindings so the Fen string is updated at any change. The "after idle"
  # is needed to ensure any keypress which causes a text edit is processed
  # before we regenerate the FEN text.

  foreach i "$sr.mid.ep.e $sr.mid.castle.e $sr.mid.movenum.e" {
    bind $i <Any-KeyPress> {after idle makeSetupFen}
    bind $i <FocusOut> {after idle makeSetupFen}
  }

  ### Buttons: Clear Board and Initial Board.

  frame $sr.b

  button $sr.b.clear -textvar ::tr(EmptyBoard) -command {
    set setupBd \
      "................................................................"
    setBoard .setup.l.bd $setupBd $setupboardSize
    set castling {}
    makeSetupFen
  } -width 10

  button $sr.b.initial -textvar ::tr(InitialBoard) -command {
    set setupBd \
      "RNBQKBNRPPPPPPPP................................pppppppprnbqkbnr"
    setBoard .setup.l.bd $setupBd $setupboardSize
    set castling KQkq
    makeSetupFen
  } -width 10

  pack $sr.b -side top -pady 15
  pack $sr.b.clear -side top -padx 5 -pady 10
  pack $sr.b.initial -side bottom -padx 5 -pady 10

  ### Buttons: Setup and Cancel.

  frame $sr.b2
  button $sr.b2.ok -text "OK" -width 7 -command exitSetupBoard
  button $sr.b2.cancel -textvar ::tr(Cancel) -width 7 -command cancelSetupBoard

  pack $sr.b2 -side bottom -pady 20 -anchor s
  pack $sr.b2.ok -side left -padx 5
  pack $sr.b2.cancel -side right -padx 5

  ### Fen combobox and buttons
  button .setup.paste -textvar ::tr(PasteFen) -command {
    if {[catch {set setupFen [selection get -selection PRIMARY]} ]} {
      catch {set setupFen [selection get -selection CLIPBOARD]}
      # PRIMARY is the X selection, unsure about CLIPBOARD
    }
  }
  button .setup.clear -textvar ::tr(ClearFen) -command {set setupFen ""}

  ::combobox::combobox .setup.fencombo -relief sunken -textvariable setupFen \
    -background white -height 10 -maxheight 10 -command setSetupBoardToFen

  ::utils::history::SetCombobox setupFen .setup.fencombo

  update ; # necessary in case of quick-draw user interactions

  pack .setup.paste .setup.clear -in .setup.fenframe -side left
  pack .setup.fencombo -in .setup.fenframe -side right -expand yes -fill x -anchor w

  bind .setup <Escape> cancelSetupBoard
  bind .setup <Destroy> cancelSetupBoard

  makeSetupFen

  bind .setup <Configure> "recordWinSize .setup"
}

# setBoard (previously in main.tcl):
#   Resets the squares of the board according to the board string
#   "boardStr" and the piece bitmap size "psize".

proc setBoard {w boardStr psize {rotated 0}} {
  for {set i 0} { $i < 64 } { incr i } {

    if {$rotated > 0} {
      set piece [string index $boardStr [expr {63 - $i}]]
    } else {
      set piece [ string index $boardStr $i ]
    }

    set c [$w.bd coords sq$i]

    # Klimmek: calculation change, because some sizes are odd
    #          and then some squares are shifted by 1 pixel
    # set x [expr {([lindex $c 0] + [lindex $c 2]) / 2} ]
    # set y [expr {([lindex $c 1] + [lindex $c 3]) / 2} ]

    set x [expr {[lindex $c 0] + $psize/2} ]
    set y [expr {[lindex $c 1] + $psize/2} ]

    set piece [string index $boardStr $i]
    $w.bd delete p$i
    $w.bd create image $x $y -image $::board::letterToPiece($piece)$psize -tag p$i
  }
}

