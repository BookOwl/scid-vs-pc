###
### sergame.tcl: part of Scid.
### Copyright (C) 2007  Pascal Georges
### Copyright (C) 2011  Stevenaaus
###

namespace eval sergame {


  # if true, follow a specific opening
  set isOpening 0
  set openingMovesList {}
  set openingMovesHash {}
  set openingMoves ""
  set outOfOpening 0
  array set engineListBox {}
  set coachIsWatching 0
  set engineName ""
  set bookSlot 2
  set depth 0
  set nodes 0
  set ponder 0

  # list of fen positions played to detect 3 fold checkRepetition
  set ::lFen {}
  set lastPlayerMoveUci ""

  ################################################################################
  #
  ################################################################################
  proc config {} {
    global ::sergame::configWin ::sergame::chosenOpening

    # Abort previous game if exists
    if {[winfo exists .serGameWin]} {
      focus .
      destroy .serGameWin
    }

    set w .configSerGameWin
    if {[winfo exists $w]} {
      focus $w
      return
    }

    toplevel $w
    wm state $w withdrawn
    wm title $w "$::tr(configuregame)"

    bind $w <F1> {helpWindow ComputerGame UCIGame}

    frame $w.fengines -relief groove -borderwidth 1
    frame $w.ftime -relief groove -borderwidth 1
    frame $w.fconfig -borderwidth 1
    frame $w.fbook -relief groove -borderwidth 1
    frame $w.fopening -relief groove -borderwidth 1
    frame $w.fbuttons

    pack $w.fengines $w.ftime $w.fconfig $w.fbook -side top -fill x
    pack $w.fopening -side top -fill both -expand 1
    pack $w.fbuttons -side top -fill x

    set row 0

    ### UCI engine listbox

    label $w.fengines.label -text $::tr(Engine)
    frame $w.fengines.fEnginesList -relief raised -borderwidth 1
    listbox $w.fengines.fEnginesList.lbEngines -yscrollcommand "$w.fengines.fEnginesList.ybar set" \
        -height 5 -width 50 -exportselection 0 -font font_Small
    scrollbar $w.fengines.fEnginesList.ybar -command "$w.fengines.fEnginesList.lbEngines yview"
    pack $w.fengines.label -side top
    pack $w.fengines.fEnginesList.ybar -side left -fill y
    pack $w.fengines.fEnginesList.lbEngines -side left -fill both -expand yes
    pack $w.fengines.fEnginesList -expand yes -fill both -side top -padx 3
    set i 0
    set idx 0
    foreach e $::engines(list) {
      if { [lindex $e 7] != 1} {
        # not an UCI engine
        incr idx
        continue
      }
      set ::sergame::engineListBox($i) $idx
      set name [lindex $e 0]
      $w.fengines.fEnginesList.lbEngines insert end $name
      incr i
      incr idx
    }

    # if no engines defined, bail out
    if {$i == 0} {
      tk_messageBox -type ok -message "No UCI engines found" -icon error -parent .
      destroy $w
      return
    }

    catch {
      $w.fengines.fEnginesList.lbEngines selection set $::sergame::current
      $w.fengines.fEnginesList.lbEngines see $::sergame::current
    }

    ### Engine config button (limit strength for example)

    button $w.fengines.bEngineConfig -text $::tr(ConfigureUCIengine) -command {
      set sel [.configSerGameWin.fengines.fEnginesList.lbEngines curselection]
      set index $::sergame::engineListBox($sel)
      set engineData [lindex $::engines(list) $index]
      set name [lindex $engineData 0]
      set cmd [ toAbsPath [lindex $engineData 1] ]
      set args [lindex $engineData 2]
      set dir [ toAbsPath [lindex $engineData 3] ]
      set options [lindex $engineData 8]
      ::uci::uciConfig $index $name [toAbsPath $cmd] $args [toAbsPath $dir] $options
    }

    pack $w.fengines.bEngineConfig -side top

    # Time bonus frame
    frame $w.ftime.timebonus

    grid  $w.ftime.timebonus -row 0 -column 0 -columnspan 2

    # label $w.ftime.timebonus.label -text $::tr(TimeMode)
    # grid $w.ftime.timebonus.label -row $row -column 2 -columnspan 2
    # incr row

    radiobutton $w.ftime.timebonus.rb1 -text $::tr(TimeBonus) -value "timebonus" -variable ::sergame::timeMode
    grid $w.ftime.timebonus.rb1 -row $row -column 0 -sticky w -rowspan 2

    label $w.ftime.timebonus.whitelabel -text $::tr(White)
    grid $w.ftime.timebonus.whitelabel -row $row -column 1 -padx 10
    spinbox $w.ftime.timebonus.whitespminutes  -width 4 -from 1 -to 120 -increment 1 -validate all -vcmd {string is int %P}
    grid $w.ftime.timebonus.whitespminutes -row $row -column 2
    label $w.ftime.timebonus.whitelminutes -text $::tr(TimeMin)
    grid $w.ftime.timebonus.whitelminutes -row $row -column 3
    spinbox $w.ftime.timebonus.whitespseconds  -width 4 -from 0 -to 60 -increment 1 -validate all -vcmd {string is int %P}
    grid $w.ftime.timebonus.whitespseconds -row $row -column 4
    label $w.ftime.timebonus.whitelseconds -text $::tr(TimeSec)
    grid $w.ftime.timebonus.whitelseconds -row $row -column 5

    incr row
    label $w.ftime.timebonus.blacklabel -text $::tr(Black)
    grid $w.ftime.timebonus.blacklabel -row $row -column 1 -padx 10
    spinbox $w.ftime.timebonus.blackspminutes  -width 4 -from 1 -to 120 -increment 1 -validate all -vcmd {string is int %P}
    grid $w.ftime.timebonus.blackspminutes -row $row -column 2
    label $w.ftime.timebonus.blacklminutes -text $::tr(TimeMin)
    grid $w.ftime.timebonus.blacklminutes -row $row -column 3
    spinbox $w.ftime.timebonus.blackspseconds  -width 4 -from 0 -to 60 -increment 1 -validate all -vcmd {string is int %P}
    grid $w.ftime.timebonus.blackspseconds -row $row -column 4
    label $w.ftime.timebonus.blacklseconds -text $::tr(TimeSec)
    grid $w.ftime.timebonus.blacklseconds -row $row -column 5

    $w.ftime.timebonus.whitespminutes set 5
    $w.ftime.timebonus.whitespseconds set 10
    $w.ftime.timebonus.blackspminutes set 5
    $w.ftime.timebonus.blackspseconds set 10

    # Fixed depth
    radiobutton $w.ftime.depthbutton -text $::tr(FixedDepth) -value "depth" -variable ::sergame::timeMode
    spinbox $w.ftime.depthvalue  -width 4 -from 1 -to 20 -increment 1 -validate all -vcmd {string is int %P}
    $w.ftime.depthvalue set 3

    grid $w.ftime.depthbutton -row 1 -column 0 -sticky w
    grid $w.ftime.depthvalue -row 1 -column 1 -sticky w

    radiobutton $w.ftime.nodesbutton -text "$::tr(Nodes) (x1000)" -value "nodes" -variable ::sergame::timeMode
    spinbox $w.ftime.nodesvalue  -width 4 -from 5 -to 10000 -increment 5 -validate all -vcmd {string is int %P}
    $w.ftime.nodesvalue set 10

    grid $w.ftime.nodesbutton -row 2 -column 0 -sticky w
    grid $w.ftime.nodesvalue -row 2 -column 1 -sticky w

    radiobutton $w.ftime.movetimebutton -text $::tr(SecondsPerMove) -value "movetime" -variable ::sergame::timeMode
    spinbox $w.ftime.movetimevalue  -width 4 -from 1 -to 120 -increment 1 -validate all -vcmd {string is int %P} -textvariable ::sergame::movetime
    # $w.ftime.movetimevalue set $movetime

    grid $w.ftime.movetimebutton -row 3 -column 0 -sticky w
    grid $w.ftime.movetimevalue -row 3 -column 1 -sticky w

    # New game or use current position ?
    checkbutton $w.fconfig.cbPosition -text $::tr(StartFromCurrentPosition) -variable ::sergame::startFromCurrent
    pack $w.fconfig.cbPosition  -side top -anchor w

    # Permanent thinking
    checkbutton $w.fconfig.cbPonder -text $::tr(Ponder) -variable ::sergame::ponder
    pack $w.fconfig.cbPonder  -side top -anchor w

    # Coach is watching (warn if the user makes weak/bad moves)
    checkbutton $w.fconfig.cbCoach -text $::tr(CoachIsWatching) -variable ::sergame::coachIsWatching
    pack $w.fconfig.cbCoach -side top -anchor w

    # Book checkbutton and combobox

    checkbutton $w.fbook.cbUseBook -text $::tr(UseBook) -variable ::sergame::useBook
    set bookPath $::scidBooksDir
    set bookList [ lsort -dictionary [ glob -nocomplain -directory $bookPath *.bin ] ]
    set tmp {}
    ttk::combobox $w.fbook.combo -width 12
    if { [llength $bookList] == 0 } {
      $w.fbook.cbUseBook configure -state disabled
      set ::sergame::useBook 0
    } else {
      set i 0
      set idx 0
      foreach file  $bookList {
	lappend tmp [ file tail $file ]
	if { $::sergame::bookToUse == [ file tail $file ]} {
	  set idx $i
	}
	incr i
      }
      $w.fbook.combo configure -values $tmp
      $w.fbook.combo current $idx 
    }

    pack $w.fbook.cbUseBook -side left -pady 3
    pack $w.fbook.combo -side right -expand yes -fill both -padx 10 -pady 3

    # Choose a specific opening

    checkbutton $w.fopening.cbOpening -text $::tr(SpecificOpening) -variable ::sergame::isOpening
    frame $w.fopening.fOpeningList -relief raised -borderwidth 1
    listbox $w.fopening.fOpeningList.lbOpening -yscrollcommand "$w.fopening.fOpeningList.ybar set" \
        -height 5 -width 50 -list ::tacgame::openingList -exportselection 0 -font font_Small

    catch {
      $w.fopening.fOpeningList.lbOpening selection set $::sergame::chosenOpening
      $w.fopening.fOpeningList.lbOpening see $::sergame::chosenOpening
    }

    scrollbar $w.fopening.fOpeningList.ybar -command "$w.fopening.fOpeningList.lbOpening yview"
    pack $w.fopening.fOpeningList.lbOpening -side right -fill both -expand 1
    pack $w.fopening.fOpeningList.ybar -side right -fill y
    pack $w.fopening.cbOpening -fill x -side top
    pack $w.fopening.fOpeningList -expand yes -fill both -side top -expand 1 -padx 3

    bind $w.fopening.fOpeningList.lbOpening <Button-1> {set ::sergame::isOpening 1}

    dialogbutton $w.fbuttons.play -text $::tr(Play) -command {
      focus .
      set sel [.configSerGameWin.fengines.fEnginesList.lbEngines curselection]
      set ::sergame::current $sel
      set ::sergame::engineName [.configSerGameWin.fengines.fEnginesList.lbEngines get $sel]
      set n $::sergame::engineListBox($sel)

      set ::sergame::chosenOpening [.configSerGameWin.fopening.fOpeningList.lbOpening curselection]
      if {$::sergame::useBook} {
        set ::sergame::bookToUse [.configSerGameWin.fbook.combo get]
        if {$::sergame::bookToUse == "" } {
          set ::sergame::useBook 0
        }
      }
      set ::uci::uciInfo(wtime$n) [expr [.configSerGameWin.ftime.timebonus.whitespminutes get]*1000*60]
      set ::uci::uciInfo(btime$n) [expr [.configSerGameWin.ftime.timebonus.blackspminutes get]*1000*60]
      set ::uci::uciInfo(winc$n) [expr [.configSerGameWin.ftime.timebonus.whitespseconds get]*1000]
      set ::uci::uciInfo(binc$n) [expr [.configSerGameWin.ftime.timebonus.blackspseconds get]*1000]
      set ::uci::uciInfo(fixeddepth$n) [.configSerGameWin.ftime.depthvalue get]
      set ::uci::uciInfo(fixednodes$n) [expr [.configSerGameWin.ftime.nodesvalue get]*1000]
      set ::uci::uciInfo(movetime$n) [expr [.configSerGameWin.ftime.movetimevalue get]*1000]
      
      destroy .configSerGameWin
      ::sergame::play $n
    }
    bind $w.fengines.fEnginesList.lbEngines <Double-Button-1> "$w.fbuttons.play invoke"

    dialogbutton $w.fbuttons.help -textvar ::tr(Help) -command {helpWindow ComputerGame UCIGame}
    dialogbutton $w.fbuttons.cancel -textvar ::tr(Cancel) -command "destroy $w"

    pack $w.fbuttons.play $w.fbuttons.help $w.fbuttons.cancel -expand yes -side left -pady 3

    bind $w <Escape> { .configSerGameWin.fbuttons.cancel invoke }
    bind $w <Return> { .configSerGameWin.fbuttons.play invoke }
    bind $w <F1> {helpWindow ComputerGame UCIGame}
    bind $w <Destroy> ""
    update
    placeWinOverParent $w .
    wm state $w normal
    wm minsize $w 45 0
  }


  ### ::sergame::play

  proc play {n} {
    global ::sergame::chosenOpening ::sergame::isOpening ::tacgame::openingList ::sergame::openingMovesList \
        ::sergame::openingMovesHash ::sergame::openingMoves ::sergame::outOfOpening

    set ::sergame::engine $n

    set ::lFen {}
    set ::drawShown 0

    ::uci::startEngine $n
    ::uci::sendUCIoptions $n

    set ::uci::uciInfo(prevscore$n) 0.0
    set ::uci::uciInfo(score$n) 0.0
    set ::uci::uciInfo(ponder$n) ""

    if {$::sergame::startFromCurrent} {
      set isOpening 0
    }

    # ponder
    if {$::sergame::ponder} {
      ::sergame::sendToEngine $n "setoption name Ponder value true"
    } else {
      ::sergame::sendToEngine $n "setoption name Ponder value false"
    }

    # if will follow a specific opening line
    if {$isOpening} {
      set fields [split [lindex $openingList $chosenOpening] ":"]
      set openingName [lindex $fields 0]
      set openingMoves [string trim [lindex $fields 1]]
      set openingMovesList ""
      set openingMovesHash ""
      set outOfOpening 0
      foreach m [split $openingMoves] {
        # in case of multiple adjacent spaces in opening line
        if {$m =={}} {
          continue
        }
        set p [string trim $m]
        lappend openingMovesList [string trim [regsub {^[1-9]+\.} $p ""] ]
      }
      
      sc_game new
      lappend openingMovesHash [sc_pos hash]
      foreach m  $openingMovesList {
        if {[catch {sc_move addSan $m}]} { }
        lappend openingMovesHash [sc_pos hash]
      }
    }
    if {!$::sergame::startFromCurrent} {
      # create a new game if a DB is opened
      sc_game new
      sc_game tags set -event "UCI Game"
      set player_name [getMyPlayerName]
      if {$player_name == ""} {set player_name {?}}
      if { [::board::isFlipped .board] } {
        sc_game tags set -white "$::sergame::engineName"
	sc_game tags set -black $player_name
      } else  {
        sc_game tags set -black "$::sergame::engineName"
	sc_game tags set -white $player_name
      }
      sc_game tags set -date [::utils::date::today]
      if {[sc_base inUse [sc_base current]]} { catch {sc_game save 0}  }
    }

    updateBoard -pgn
    ::windows::gamelist::Refresh
    updateTitle
    updateMenuStates
    set w .serGameWin
    if {[winfo exists $w]} {
      focus .
      destroy $w
    }

    toplevel $w
    wm title $w "$::sergame::engineName"

    setWinLocation $w

    frame $w.fclocks -relief raised -borderwidth 1
    frame $w.fbuttons
    pack $w.fclocks $w.fbuttons -side top -expand yes -fill both

    if {$::sergame::timeMode == "timebonus"} {
      ::gameclock::new $w.fclocks 2 80 1
      ::gameclock::new $w.fclocks 1 80 1
    } else {
      # dont call flag when playing seconds per move
      ::gameclock::new $w.fclocks 2 80 0
      ::gameclock::new $w.fclocks 1 80 0
    }
    # These are broken for flipped games. (Tacgame too)
    ::gameclock::setColor 1 white
    ::gameclock::setColor 2 black
    ::gameclock::reset 1
    ::gameclock::start 1

    set ::paused 0

    button $w.fbuttons.resume -state disabled -textvar ::tr(Resume) -command {
      set ::paused 0
      .serGameWin.fbuttons.resume configure -state disabled
      ::sergame::engineGo
    }
    pack $w.fbuttons.resume -expand yes -fill both -padx 10 -pady 2

    button $w.fbuttons.restart -text Restart -command {
      ::sergame::abortGame
      ::sergame::play $::sergame::engine
    }
    pack $w.fbuttons.restart -expand yes -fill both -padx 10 -pady 2

    button $w.fbuttons.abort -textvar ::tr(Abort) -command ::sergame::abortGame
    pack $w.fbuttons.abort -expand yes -fill both -padx 10 -pady 2

    bind $w <F1> {helpWindow ComputerGame UCIGame}
    bind $w <Destroy> ::sergame::abortGame
    bind $w <Escape> ::sergame::abortGame
    bind $w <Configure> "recordWinSize $w"
    wm minsize $w 45 0

    # setup clocks
    if {$::sergame::timeMode == "timebonus"} {
      if { [::sergame::getEngineColor] == "white" } {
	::gameclock::setSec 2 [expr 0 - $::uci::uciInfo(wtime$n)/1000]
	::gameclock::setSec 1 [expr 0 - $::uci::uciInfo(btime$n)/1000]
      } else  {
	::gameclock::setSec 1 [expr 0 - $::uci::uciInfo(wtime$n)/1000]
	::gameclock::setSec 2 [expr 0 - $::uci::uciInfo(btime$n)/1000]
      }
    }

    set ::sergame::wentOutOfBook 0
    ::sergame::engineGo
  }

  proc abortGame {} {
    set n $::sergame::engine

    set ::lFen {}
    if { $::uci::uciInfo(pipe$n) == ""} { return }
    after cancel ::sergame::engineGo
    ::uci::closeUCIengine $n
    ::gameclock::stop 1
    ::gameclock::stop 2
    set ::uci::uciInfo(bestmove$n) "abort"
    destroy .serGameWin
    focus .
  }

  ### ::sergame::sendToEngine

  proc sendToEngine {n text} {
    logEngine $n "Scid  : $text"
    catch {puts $::uci::uciInfo(pipe$n) $text}
  }

  ################################################################################
  # returns true if last move is a mate and stops clocks
  ################################################################################

  proc endOfGame {} {
    # Use score to check for stalemate, checkmate.
    # sc_pos analyze -time 50 (50 milliseconds) returns two args, a score and the best move.
    # Score 32000 represents Inifity , {} represents "no move"

    # Hmmmm... can cause core dumps! &&&
    set score [sc_pos analyze -time 50]

    if { $score == {0 {}}} {
      ::gameclock::stop 1
      ::gameclock::stop 2
      sc_game tags set -result =
      tk_messageBox -type ok -message {Stalemate} -parent .board -icon info -title {Game Over}
      return 1
    }

    # if { [string index [sc_game info previousMove] end ] == "#"}
    if { $score == {-32000 {}}} {
      ::gameclock::stop 1
      ::gameclock::stop 2
      # if {!$::tacgame::mateShown} 
      if {1} {
        # mate dialog
        if { [::sergame::getEngineColor] == [sc_pos side] } {
          set side Player
        } else {
          set side $::sergame::engineName
        }
        if {[sc_pos side] == {black}} {
          sc_game tags set -result 1
        } else {
          sc_game tags set -result 0
        }
        updateBoard -pgn

        tk_messageBox -type ok -message "$side Wins" -parent .board -icon info -title Checkmate
      }
      return 1
    }
    return 0
  }

  proc engineGo {} {
    global ::sergame::isOpening ::sergame::openingMovesList ::sergame::openingMovesHash \
           ::sergame::openingMoves ::sergame::timeMode ::sergame::outOfOpening

    set n $::sergame::engine

    after cancel ::sergame::engineGo

    if { [::sergame::endOfGame] } {
      catch {sc_game save [sc_game number]}
      return
    }


    if { [sc_pos side] != [::sergame::getEngineColor] } {
      # Not computers turn, come back in 1  second
      after 1000 ::sergame::engineGo
      return
    }

    # The player moved : add clock time
    if {!([::sergame::getEngineColor] == "black" && [sc_pos moveNumber] == 1)} {
      if {$::sergame::timeMode == "timebonus"} {
	if { [::sergame::getEngineColor] == "white" } {
	  ::gameclock::add 1 [expr $::uci::uciInfo(binc$n)/1000]
	} else  {
	  ::gameclock::add 1 [expr $::uci::uciInfo(winc$n)/1000]
	}
      }
    }
    ::gameclock::stop 1
    ::gameclock::start 2
    if {[checkRepetition]} {
      return
    }

    # make a move corresponding to a specific opening, (it is engine's turn)
    if {$isOpening && !$outOfOpening} {
      set index 0
      # Warn if the user went out of the opening line chosen
      if { !$outOfOpening } {
        set ply [ expr [sc_pos moveNumber] * 2 - 1]
        if { [sc_pos side] == "white" } {
          set ply [expr $ply - 1]
        }
        
        if { [lsearch $openingMovesHash [sc_pos hash]] == -1 && [llength $openingMovesList] >= $ply} {
          set answer [tk_messageBox -icon question -parent .board -title $::tr(OutOfOpening) -type yesno \
              -message "$::tr(NotFollowedLine) $openingMoves\n $::tr(DoYouWantContinue)" ]
          if {$answer == no} {
            sc_move back 1
            updateBoard -pgn
            ::gameclock::stop 2
            ::gameclock::start 1
            after 1000 ::sergame::engineGo
            return
          }  else  {
            set outOfOpening 1
          }
        }
      }
      
      set hpos [sc_pos hash]
      # Find a corresponding position in the opening line
      set length [llength $openingMovesHash]
      for {set i 0}   { $i < [expr $length-1] } { incr i } {
        set h [lindex $openingMovesHash $i]
        if {$h == $hpos} {
          set index [lsearch $openingMovesHash $h]
          set move [lindex $openingMovesList $index]
          # play the move
          set action "replace"
          if {![sc_pos isAt vend]} { set action [confirmReplaceMove] }
          if {$action == "replace"} {
            if {[catch {sc_move addSan $move}]} {}
          } elseif {$action == "var"} {
            sc_var create
            if {[catch {sc_move addSan $move}]} {}
          } elseif {$action == "mainline"} {
            sc_var create
            if {[catch {sc_move addSan $move}]} {}
            sc_var exit
            sc_var promote [expr {[sc_var count] - 1}]
            sc_move forward 1
          }
          
          updateBoard -pgn -animate
          ::gameclock::stop 2
          ::gameclock::start 1
          if {[checkRepetition]} {
            return
          }
	  if {$::sergame::timeMode == "timebonus"} {
	    if { [::sergame::getEngineColor] == "white" } {
	      ::gameclock::add 2 [expr $::uci::uciInfo(winc$n)/1000]
	    } else  {
	      ::gameclock::add 2 [expr $::uci::uciInfo(binc$n)/1000]
	    }
	  }
	  after 1000 ::sergame::engineGo
          return
        }
      }
    }
    # -------------------------------------------------------------
    # use a book
    if {$::sergame::useBook && ! $::sergame::wentOutOfBook} {
      set move [ ::book::getMove $::sergame::bookToUse [sc_pos fen] $::sergame::bookSlot]
      if {$move == ""} {
        set ::sergame::wentOutOfBook 1
      } else  {
        sc_move addSan $move
        ::utils::sound::AnnounceNewMove $move
        # we made a book move so assume a score = 0
        set ::uci::uciInfo(prevscore$n) 0.0
        updateBoard -pgn -animate
        ::gameclock::stop 2
        ::gameclock::start 1
        if {[checkRepetition]} {
	  return
        }
	if {$timeMode == "timebonus"} {
	  if { [::sergame::getEngineColor] == "white" } {
	    ::gameclock::add 2 [expr $::uci::uciInfo(winc$n)/1000]
	  } else  {
	    ::gameclock::add 2 [expr $::uci::uciInfo(binc$n)/1000]
	  }
	}
	after 1000 ::sergame::engineGo
        return
      }
    }

    ### check if the engine pondered on the right move

    if { $::sergame::ponder && $::uci::uciInfo(ponder$n) == $::sergame::lastPlayerMoveUci} {
      ::sergame::sendToEngine $n "ponderhit"
    } else {
      
      if { $::sergame::ponder } {
        ::sergame::sendToEngine $n "stop"
      }
      set ::analysis(waitForReadyOk$n) 1
      ::sergame::sendToEngine $n "isready"
      vwait ::analysis(waitForReadyOk$n)
      ::sergame::sendToEngine $n "position fen [sc_pos fen]"
      if { [::sergame::getEngineColor] == "white" } {
        set wtime [expr [::gameclock::getSec 2] * 1000 ]
        set btime [expr [::gameclock::getSec 1] * 1000 ]
      } else  {
        set wtime [expr [::gameclock::getSec 1] * 1000 ]
        set btime [expr [::gameclock::getSec 2] * 1000 ]
      }
      if {$timeMode == "timebonus"} {
        ::sergame::sendToEngine $n "go wtime $wtime btime $btime winc $::uci::uciInfo(winc$n) binc $::uci::uciInfo(binc$n)"
      } elseif {$timeMode == "depth"} {
        ::sergame::sendToEngine $n "go depth $::uci::uciInfo(fixeddepth$n)"
      } elseif {$timeMode == "movetime"} {
        ::sergame::sendToEngine $n "go movetime $::uci::uciInfo(movetime$n)"
      } elseif {$timeMode == "nodes"} {
        ::sergame::sendToEngine $n "go nodes $::uci::uciInfo(fixednodes$n)"
      }
    }

    set ::uci::uciInfo(bestmove$n) ""
    vwait ::uci::uciInfo(bestmove$n)

    # -------------------------------------------------------------
    # if weak move detected, propose the user to tack back
    if { $::sergame::coachIsWatching && $::uci::uciInfo(prevscore$n) != "" } {
      set blunder 0
      set delta [expr $::uci::uciInfo(score$n) - $::uci::uciInfo(prevscore$n)]
      if {$delta > $::informant("?!") && [getEngineColor] == "white" ||
        $delta < [expr 0.0 - $::informant("?!")] && [getEngineColor] == "black" } {
        set blunder 1
      }
      
      if {$delta > $::informant("?") && [getEngineColor] == "white" ||
        $delta < [expr 0.0 - $::informant("?")] && [getEngineColor] == "black" } {
        set blunder 2
      }
      
      if {$delta > $::informant("??") && [getEngineColor] == "white" ||
        $delta < [expr 0.0 - $::informant("??")] && [getEngineColor] == "black" } {
        set blunder 3
      }
      
      if {$blunder == 1} {
        set tBlunder "DubiousMovePlayedTakeBack"
      } elseif {$blunder == 2} {
        set tBlunder "WeakMovePlayedTakeBack"
      } elseif {$blunder == 3} {
        set tBlunder "BadMovePlayedTakeBack"
      }
      
      if {$blunder != 0} {
        set answer [tk_messageBox -icon question -parent .board -title "Scid" -type yesno -message $::tr($tBlunder) ]
        if {$answer == yes} {
          sc_move back 1
          updateBoard -pgn
          ::gameclock::stop 2
          ::gameclock::start 1
          after 1000 ::sergame::engineGo
          return
        }
      }
    }

    # -------------------------------------------------------------
    if { $::uci::uciInfo(bestmove$n) == "abort" } {
      return
    }

    ::uci::sc_move_add $::uci::uciInfo(bestmove$n)
    ::utils::sound::AnnounceNewMove $::uci::uciInfo(bestmove$n)
    set ::uci::uciInfo(prevscore$n) $::uci::uciInfo(score$n)
    updateBoard -pgn -animate
    if {[checkRepetition]} {
      return
    }

    # add time after a move played
    if {$timeMode == "timebonus"} {
      if { [::sergame::getEngineColor] == "white" } {
        ::gameclock::add 2 [expr $::uci::uciInfo(winc$n)/1000]
      } else  {
        ::gameclock::add 2 [expr $::uci::uciInfo(binc$n)/1000]
      }
    }
    ::gameclock::stop 2
    ::gameclock::start 1

    # ponder mode (the engine just played its move)
    if {$::sergame::ponder && $::uci::uciInfo(ponder$n) != ""} {
      ::sergame::sendToEngine $n "position fen [sc_pos fen] moves $::uci::uciInfo(ponder$n)"
      if { [::sergame::getEngineColor] == "white" } {
        set wtime [expr [::gameclock::getSec 2] * 1000 ]
        set btime [expr [::gameclock::getSec 1] * 1000 ]
      } else  {
        set wtime [expr [::gameclock::getSec 1] * 1000 ]
        set btime [expr [::gameclock::getSec 2] * 1000 ]
      }
      if {$timeMode == "timebonus"} {
        ::sergame::sendToEngine $n "go ponder wtime $wtime btime $btime winc $::uci::uciInfo(winc$n) binc $::uci::uciInfo(binc$n)"
      } elseif {$timeMode == "depth"} {
        ::sergame::sendToEngine $n "go ponder depth $::uci::uciInfo(fixeddepth$n)"
      } elseif {$timeMode == "movetime"} {
        ::sergame::sendToEngine $n "go ponder movetime $::uci::uciInfo(movetime$n)"
      } elseif {$timeMode == "nodes"} {
        ::sergame::sendToEngine $n "go ponder nodes $::uci::uciInfo(fixednodes$n)"
      }
    }

    after 1000 ::sergame::engineGo
  }

  proc getEngineColor {} {
    # Engine always plays for the upper side
    if {[::board::isFlipped .board]} {
      return white
    } else  {
      return black
    }
  }

}
###
### End of file: sergame.tcl
###
