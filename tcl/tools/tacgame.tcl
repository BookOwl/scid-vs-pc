###
### tacgame.tcl: part of Scid.
### Copyright (C) 2006  Pascal Georges
###

namespace eval tacgame {
  ######################################################################
  ### Tacgame window: uses a chess engine (Phalanx) in easy mode and
  ### another engine (for example Toga) to track blunders

  set resignCount 0

  # if true, follow a specific opening
  set chosenOpening ""
  set openingMovesList {}
  set openingMovesHash {}
  set openingMoves ""
  set outOfOpening 0

  # list of fen positions played to detect 3 fold repetition
  set lFen {}

  set lastblundervalue 0.0
  set prev_lastblundervalue 0.0
  set blundermissed false
  set blunderwarning false
  set blunderwarningvalue 0.0
  set blundermissedvalue 0.0

  set blunderWarningLabel $::tr(Noblunder)
  set scoreLabel 0.0

  set blunderpending 0
  set prev_blunderpending 0
  set currentPosHash 0
  set lscore {}

  set analysisCoach(paused) 0 ; # S.A

  # ======================================================================
  # resetValues
  #   Resets all blunders data.
  # ======================================================================
  proc resetValues {} {
    # see tcl/start.tcl
    set ::tacgame::blundermissed false
    set ::tacgame::lastblundervalue 0.0
    set ::tacgame::prev_lastblundervalue 0.0
    set ::tacgame::prev_blunderpending 0
    set ::tacgame::currentPosHash [sc_pos hash]
    set ::tacgame::lscore {}
    set ::tacgame::resignCount 0
    set ::tacgame::drawShown 0
    set ::tacgame::mateShown 0
    set ::tacgame::resignShown 0
  }

  # ======================================================================
  # resetEngine:
  #   Resets all engine-specific data.
  # ======================================================================
  proc resetEngine {n} {

    global ::tacgame::analysisCoach
    set analysisCoach(pipe$n) ""             ;# Communication pipe file channel
    set analysisCoach(seen$n) 0              ;# Seen any output from engine yet?
    set analysisCoach(seenEval$n) 0          ;# Seen evaluation line yet?
    set analysisCoach(score$n) 0             ;# Current score in centipawns
    set analysisCoach(moves$n) ""            ;# PV (best line) output from engine
    set analysisCoach(movelist$n) {}         ;# Moves to reach current position
    set analysisCoach(nonStdStart$n) 0       ;# Game has non-standard start
    set analysisCoach(has_analyze$n) 0       ;# Engine has analyze command
    set analysisCoach(has_setboard$n) 0      ;# Engine has setboard command
    set analysisCoach(send_sigint$n) 0       ;# Engine wants INT signal
    set analysisCoach(wants_usermove$n) 0    ;# Engine wants "usermove" before moves
    set analysisCoach(wholeSeconds$n) 0      ;# Engine times in seconds not centisec
    set analysisCoach(analyzeMode$n) 0       ;# Scid has started analyze mode
    set analysisCoach(invertScore$n) 1       ;# Score is for side to move, not white
    # these vars used by analysis.tcl
    set analysisCoach(automove$n) 0
    set analysisCoach(automoveThinking$n) 0
    set analysisCoach(automoveTime$n) 2000
    set analysisCoach(lastClicks$n) 0
    set analysisCoach(after$n) ""
    set analysisCoach(log$n) ""              ;# Log file channel
    set analysisCoach(logCount$n) 0          ;# Number of lines sent to log file
    set analysisCoach(wbEngineDetected$n) 0  ;# Is this a special Winboard engine?
  }

  # ======================================================================
  #		::tacgame::config
  #   Configure coach games :
  #			- Phalanx engine (because it has an 'easy' option)
  #			- Coach engine (Toga is the best)
  #			- level of difficulty
  # ======================================================================
  proc config {} {

    global ::tacgame::configWin ::tacgame::analysisCoachCommand \
    ::tacgame::analysisCoach engineCoach1 engineCoach2 ::tacgame::level \
    ::tacgame::levelFixed ::tacgame::isLimitedAnalysisTime ::tacgame::analysisTime \
    ::tacgame::index1 ::tacgame::index2 ::tacgame::chosenOpening 

    # check if game window is already opened. If yes abort previous game
    if {[winfo exists .coachWin]} {
      focus .
      destroy .coachWin
      ::tacgame::closeEngine 1
      ::tacgame::closeEngine 2
    }

    # find Phalanx (index1) and Toga (index2) engines
    set i 0
    set index1 -1
    set index2 -1
    foreach e $::engines(list) {
      if { $index1 != -1 && $index2 != -1 } { break }
      set name [lindex $e 0]
      if { [ string match -nocase "*phalanx*" $name ]  } {
        set engineCoach1 $name
        set index1 $i
	set analysisCoach(automove$index1) 0
      }
      
      if { [ string match -nocase "*toga*" $name ] } {
        set engineCoach2 $name
        set index2 $i
      }
      incr i
    }

    # could not find Toga or Phalanx
    if { $index1 == -1 || $index2 == -1 } {
      tk_messageBox -title "Scid" -icon warning -type ok -message $::tr(PhalanxOrTogaMissing)
      return
    }

    set w ".configWin"
    if {[winfo exists $w]} {
      focus $w
      # wm attributes $w -topmost
      return
    }

    toplevel $w
    wm state $w withdrawn
    wm title $w "$::tr(configurecoachgame)"

    bind $w <F1> { helpWindow TacticalGame }

    frame $w.flevel -relief raised -borderwidth 1
    frame $w.flevel.diff_fixed
    frame $w.flevel.diff_random
    frame $w.fopening -relief raised -borderwidth 1
    frame $w.flimit -relief raised -borderwidth 1
    frame $w.fbuttons

    label $w.flevel.label -text "[string toupper $::tr(difficulty) 0 0]"
    label $w.flevel.space -text {}

    pack $w.flevel -side top -fill x
    pack $w.flevel.label -side top -pady 3
    pack $w.flevel.diff_fixed -side top
    pack $w.flevel.diff_random -side top
    pack $w.flevel.space -side bottom
    pack $w.fopening  -side top -fill both -expand 1
    pack $w.flimit $w.fbuttons -side top -fill x

    radiobutton $w.flevel.diff_random.cb -text $::tr(RandomLevel) -variable ::tacgame::randomLevel -value 1 -width 15  -anchor w
    scale $w.flevel.diff_random.lMin -orient horizontal -from 1200 -to 2200 -length 100 -variable ::tacgame::levelMin -tickinterval 0 -resolution 50
    scale $w.flevel.diff_random.lMax -orient horizontal -from 1200 -to 2200 -length 100 -variable ::tacgame::levelMax -tickinterval 0 -resolution 50
    pack $w.flevel.diff_random.cb -side left
    pack $w.flevel.diff_random.lMin $w.flevel.diff_random.lMax -side left -expand 1

    radiobutton $w.flevel.diff_fixed.cb -text "$::tr(FixedLevel)\n($::tr(easy) - $::tr(hard))" -variable ::tacgame::randomLevel -value 0 -width 15  -anchor w
    scale $w.flevel.diff_fixed.scale -orient horizontal -from 1200 -to 2200 -length 200 \
        -variable ::tacgame::levelFixed -tickinterval 0 -resolution 50
    pack $w.flevel.diff_fixed.cb -side left
    pack $w.flevel.diff_fixed.scale

    label $w.fopening.label -text $::tr(Opening)
    pack $w.fopening.label -side top -pady 3

    # start new game
    radiobutton $w.fopening.cbNew -text $::tr(StartNewGame)  -variable ::tacgame::openingType -value new

    # start from current position
    radiobutton $w.fopening.cbPosition -text $::tr(StartFromCurrentPosition) -variable ::tacgame::openingType -value current

    # fischer chess
    radiobutton $w.fopening.cbFischer -text {Fischer Chess} -variable ::tacgame::openingType -value fischer

    # random pawn chess
    radiobutton $w.fopening.cbPawn -text {Random Pawns} -variable ::tacgame::openingType -value pawn

    # or choose a specific opening
    radiobutton $w.fopening.cbSpecific -text $::tr(SpecificOpening) -variable ::tacgame::openingType -value specific

    # Tweak opening type according to game pos
    if {[sc_pos isAt start]} {
      if {$::tacgame::openingType == {current}} { set ::tacgame::openingType new }
    } else {
      set ::tacgame::openingType current
    }

    pack $w.fopening.cbNew -anchor w -padx 100
    pack $w.fopening.cbPosition -anchor w -padx 100
    pack $w.fopening.cbFischer   -anchor w -padx 100
    pack $w.fopening.cbPawn   -anchor w -padx 100
    pack $w.fopening.cbSpecific -anchor w -padx 100

    frame $w.fopening.fOpeningList
    listbox $w.fopening.fOpeningList.lbOpening -yscrollcommand "$w.fopening.fOpeningList.ybar set" \
        -height 5 -width 40 -list ::tacgame::openingList
    $w.fopening.fOpeningList.lbOpening selection set 0
    scrollbar $w.fopening.fOpeningList.ybar -command "$w.fopening.fOpeningList.lbOpening yview"
    pack $w.fopening.fOpeningList.lbOpening -side right -fill both -expand 1
    pack $w.fopening.fOpeningList.ybar  -side right -fill y
    pack $w.fopening.fOpeningList -expand yes -fill both -side top -expand 1

    # in order to limit CPU usage, limit the time for analysis (this prevents noise on laptops)
    checkbutton $w.flimit.blimit -text $::tr(limitanalysis) -variable ::tacgame::isLimitedAnalysisTime -relief flat
    scale $w.flimit.analysisTime -orient horizontal -from 5 -to 60 -length 200 -label $::tr(seconds) -variable ::tacgame::analysisTime -resolution 5
    pack $w.flimit.blimit $w.flimit.analysisTime -side left -expand yes -pady 5

    button $w.fbuttons.close -text $::tr(Play) -command {
      focus .
      set ::tacgame::chosenOpening \
        [.configWin.fopening.fOpeningList.lbOpening curselection]
      destroy .configWin
      ::tacgame::play
    }
    button $w.fbuttons.cancel -textvar ::tr(Cancel) -command "focus .; destroy $w"

    pack $w.fbuttons.close $w.fbuttons.cancel -expand yes -side left -padx 20 -pady 2
    focus $w.fbuttons.close

    bind $w <Escape> { .configWin.fbuttons.cancel invoke }
    bind $w <Return> { .configWin.fbuttons.close invoke }
    bind $w <F1> { helpWindow TacticalGame }
    bind $w <Destroy> {}
    bind $w <Configure> "recordWinSize $w"
    wm minsize $w 45 0
    update
    placeWinOverParent $w .
    wm state $w normal
  }

  trace add variable ::pause write ::tacgame::pauseGame
  proc pauseGame {args} {
    if {[winfo exists .coachWin]} {
      set ::tacgame::analysisCoach(paused) 1
      .coachWin.fbuttons.resume configure -state normal
      # mess with game clocks ??? S.A
    }
  }

  proc check_Fischer_Game {} {
    if {$::tacgame::openingType == "fischer"} {
      sc_game tags set -event "Tactical game, Fischer chess"
      set fen {r n b q k b n r}
      for {set i 50} {$i > 0} {incr i -1} {
	set i1 [expr int(rand()*8)]
	set i2 [expr int(rand()*8)]
	# swap elements i1 and i2
	set el1 [lindex $fen $i1]
	set el2 [lindex $fen $i2]
	set fen [lreplace $fen $i1 $i1 $el2]
	set fen [lreplace $fen $i2 $i2 $el1]
      }

      # The white King is placed somewhere between the two white Rooks. 
      set i1 [lsearch $fen "k"]
      set i2 [lsearch $fen "r"]
      if { [expr $i1 < $i2 ] } {
	set el1 [lindex $fen $i1]
	set el2 [lindex $fen $i2]
	set fen [lreplace $fen $i1 $i1 $el2]
	set fen [lreplace $fen $i2 $i2 $el1]
      } else {
        set i2 [lindex [lsearch -all $fen "r"] 1]
	if { [expr $i1 > $i2 ] } {
	  set el1 [lindex $fen $i1]
	  set el2 [lindex $fen $i2]
	  set fen [lreplace $fen $i1 $i1 $el2]
	  set fen [lreplace $fen $i2 $i2 $el1]
        }
      }

      # The white Bishops are placed on opposite-colored squares.
      set i1 [lindex [lsearch -all $fen "b"] 0]
      set i2 [lindex [lsearch -all $fen "b"] 1]
      if { [expr ($i1 % 2) == ($i2 % 2) ] } {
        set i2 [lindex [lsearch -all $fen "n"] 0]

        # Check this knight is not on the same color
        if { [expr ($i1 % 2) == ($i2 % 2) ] } {
          set i2 [lindex [lsearch -all $fen "n"] 1]
          # And if this knight is ~still~ on the same color, go for queen. Qed.
          if { [expr ($i1 % 2) == ($i2 % 2) ] } {
            set i2 [lindex [lsearch -all $fen "q"] 0]
          }
        }

	set el1 [lindex $fen $i1]
	set el2 [lindex $fen $i2]
	set fen [lreplace $fen $i1 $i1 $el2]
	set fen [lreplace $fen $i2 $i2 $el1]
      }

      set fen [join $fen {}]
      sc_game startBoard "$fen/pppppppp/8/8/8/8/PPPPPPPP/[string toupper $fen] w - - 0 1"
    } elseif {$::tacgame::openingType == "pawn" } {
      sc_game tags set -event "Tactical game, Random Pawns"
      set row2 {}
      set row3 {}
      for {set i 0} {$i < 8} {incr i} {
        if {[expr rand() < .5]} {
          set row2 "p$row2"
          set row3 "1$row3"
        } else {
          set row2 "1$row2"
          set row3 "p$row3"
        }
      }
      sc_game startBoard "rnbqkbnr/$row2/$row3/8/8/[string toupper $row3]/[string toupper $row2]/RNBQKBNR w KQkq - 0 1"
    }
  }

  # ======================================================================
  #
  #	::tacgame::play
  #
  # ======================================================================
  proc play { } {
    global ::tacgame::analysisCoach ::tacgame::threshold \
	  ::tacgame::showblunder ::tacgame::showblundervalue \
	  ::tacgame::blunderfound ::tacgame::showmovevalue \
	  ::tacgame::level ::tacgame::levelFixed engineCoach1 \
	  engineCoach2 ::tacgame::index1 ::tacgame::index2 \
	  ::tacgame::chosenOpening ::tacgame::openingType \
	  ::tacgame::openingList ::tacgame::openingMovesList \
	  ::tacgame::openingMovesHash ::tacgame::openingMoves \
	  ::tacgame::outOfOpening ::tacgame::drawShown ::tacgame::resignShown ::tacgame::mateShown 

    resetEngine 1
    resetEngine 2
    catch { unset ::uci::uciInfo(score$::tacgame::index2) }

    set ::tacgame::lFen {}

    if {$::tacgame::randomLevel} {
      if {$::tacgame::levelMax < $::tacgame::levelMin} {
        set tmp $::tacgame::levelMax
        set ::tacgame::levelMax $::tacgame::levelMin
        set ::tacgame::levelMin $tmp
      }
      set level [expr int(rand()*($::tacgame::levelMax - $::tacgame::levelMin)) + $::tacgame::levelMin ]
    } else {
      set level $::tacgame::levelFixed; # S.A.
    }

    # if will follow a specific opening line
    if {$openingType == "specific"} {
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
        set n [string trim $m]
        lappend openingMovesList [string trim [regsub {^[1-9]+\.} $m ""] ]
      }
      
      sc_game new
      lappend openingMovesHash [sc_pos hash]
      foreach m  $openingMovesList {
        if {[catch {sc_move addSan $m}]} {
        }
        lappend openingMovesHash [sc_pos hash]
      }
    }

    if {$::tacgame::openingType != "current"} {
      initTacgame
    } else {
      # set names if not already set

      set player_name [getMyPlayerName]
      if {$player_name == ""} {set player_name {?}}
      set ai_name "Phalanx $::tacgame::level ELO"
      if { [::board::isFlipped .board] } {
	set tmp_name $ai_name
	set ai_name $player_name
        set player_name $tmp_name
      }
      if {[sc_game tags get White] != "?" } {set player_name [sc_game tags get White]}
      if {[sc_game tags get Black] != "?" } {set ai_name     [sc_game tags get Black]}

      sc_game tags set -black $ai_name
      sc_game tags set -white $player_name
    }

    updateBoard -pgn
    ::windows::gamelist::Refresh
    updateTitle
    updateMenuStates

    set w .coachWin
    if {[winfo exists $w]} {
      focus .
      destroy $w
      return
    }

    toplevel $w
    if {$::tacgame::openingType == "fischer"} {
      wm title $w "Fischer Elo $level"
    } elseif {$::tacgame::openingType == "pawn"} {
      wm title $w "Random Pawns Elo $level"
    } else {
      wm title $w "Elo $level"
    }
    wm protocol $w WM_DELETE_WINDOW ::tacgame::abortGame

    setWinLocation $w

    frame $w.fdisplay -relief groove -borderwidth 1
    frame $w.fthreshold -relief groove -borderwidth 1
    frame $w.finformations -relief groove -borderwidth 1
    frame $w.fclocks -relief raised -borderwidth 2
    frame $w.fbuttons
    pack $w.fdisplay $w.fthreshold $w.finformations $w.fclocks $w.fbuttons -side top -expand yes -fill both

    checkbutton $w.fdisplay.b1 -text $::tr(showblunderexists) -variable ::tacgame::showblunder -relief flat
    checkbutton $w.fdisplay.b2 -text $::tr(showblundervalue) -variable ::tacgame::showblundervalue -relief flat
    checkbutton $w.fdisplay.b5 -text $::tr(showscore) -variable ::tacgame::showevaluation -relief flat
    pack $w.fdisplay.b1 $w.fdisplay.b2 $w.fdisplay.b5 -expand yes -anchor w

    label $w.fthreshold.l -text $::tr(moveblunderthreshold) -wraplength 300 -font {helvetica -12 italic}
    scale $w.fthreshold.t -orient horizontal -from 0.0 -to 5.0 \
        -variable ::tacgame::threshold -resolution 0.1 -tickinterval 0 -font {helvetica -10}
    pack $w.fthreshold.l -padx 10
    pack $w.fthreshold.t -expand yes -fill x -padx 10

    label $w.finformations.l1 -textvariable ::tacgame::blunderWarningLabel -bg linen
    label $w.finformations.l3 -textvariable ::tacgame::scoreLabel -fg WhiteSmoke -bg SlateGray
    pack $w.finformations.l1 $w.finformations.l3 -padx 10 -pady 5 -side top -fill x

    ::gameclock::new $w.fclocks 2 80
    ::gameclock::new $w.fclocks 1 80
    ::gameclock::setColor 1 white
    ::gameclock::setColor 2 black
    ::gameclock::reset 1
    ::gameclock::start 1

    ### "Resume" restarts paused computer (while player moves forward/back in history) S.A

    set ::tacgame::analysisCoach(paused) 0
    button $w.fbuttons.resume -state disabled -textvar ::tr(Resume) -command {
      set ::tacgame::analysisCoach(paused) 0
      .coachWin.fbuttons.resume configure -state disabled
      ::tacgame::phalanxGo
    }
    pack $w.fbuttons.resume -expand yes -fill both -padx 10 -pady 2

    ### "Restart" starts a new computer game S.A.

    button $w.fbuttons.restart -textvar ::tr(Restart) -command {

      set ::tacgame::analysisCoach(paused) 0
      .coachWin.fbuttons.resume configure -state disabled

      set ::tacgame::lFen {}
      ::tacgame::initTacgame

      # todo: reset hash tables too
      # todo: restart engine if table has been flipped ?

      # I dont know what this will do to the database &&& S.A.

      ::gameclock::reset 1
      ::gameclock::reset 2
      ::gameclock::draw 2
      ::gameclock::start 1
      ::tacgame::resetValues
      ::tacgame::phalanxGo
      updateBoard -pgn
      ::tacgame::updateAnalysisText
    }
    pack $w.fbuttons.restart -expand yes -fill both -padx 10 -pady 2

    button $w.fbuttons.close -textvar ::tr(Abort) -command ::tacgame::abortGame
    pack $w.fbuttons.close -expand yes -fill both -padx 10 -pady 2

    ::tacgame::launchengine $index1
    ::uci::startEngine $index2 
    set ::uci::uciInfo(multipv$index2) 1
    changePVSize $index2

    ::tacgame::resetValues
    updateAnalysisText

    bind $w <F1> { helpWindow TacticalGame }
    bind $w <Escape> ::tacgame::abortGame
    bind $w <Configure> "recordWinSize $w"
    wm minsize $w 45 0

    ::tacgame::phalanxGo

    ###can't focus main window! S.A.
    # update
    # raise . $w
    # focus .
  }

  proc initTacgame {} {
    sc_game new
    sc_game tags set -event "Tactical game"

    set player_name [getMyPlayerName]
    if {$player_name == ""} {set player_name {?}}
    set ai_name "Phalanx $::tacgame::level ELO"

    if { [::board::isFlipped .board] } {
      sc_game tags set -white $ai_name
      sc_game tags set -black $player_name
    } else  {
      sc_game tags set -black $ai_name
      sc_game tags set -white $player_name
    }
    check_Fischer_Game
    sc_game tags set -date [::utils::date::today]
    # if {[sc_base inUse [sc_base current]]} { catch {sc_game save 0}  }
  }


  proc abortGame {} {
    after cancel ::tacgame::phalanxGo
    stopAnalyze
    destroy .coachWin
    focus .
    ::tacgame::closeEngine $::tacgame::index1
    ::tacgame::closeEngine $::tacgame::index2
    # ::uci::closeUCIengine 2 ?
  }

  # ======================================================================
  #   ::tacgame::launchengine
  #  - launches both engines
  #  - updates values for :
  #						blundermissed (boolean), blunderwarning (boolean)
  #						blunderwarningvalue (real), blundermissedvalue (real)
  #						totalblundersmissed (real), totalblunders (real)
  # ======================================================================

  proc launchengine {n} {
    global ::tacgame::analysisCoach ::tacgame::level

    ::tacgame::resetEngine $n
    set engineData [lindex $::engines(list) $n]
    set analysisName [lindex $engineData 0]
    set analysisCommand [ ::toAbsPath [ lindex $engineData 1 ] ]
    set analysisArgs [lindex $engineData 2]
    set analysisDir [ ::toAbsPath [lindex $engineData 3] ]

    if {$::macApp && [file pathtype $analysisCommand] != "absolute"} {
      # Maybe if they put a full path in the config they knew what they wanted?
      # Otherwise, look in the analysisDir. - dr
      set analysisCommand [file join $analysisDir $analysisCommand]
    }

    # turn phalanx book, ponder and learning off, easy on
    # convert Elo = 1200 to level 100 up to Elo=2200 to level 0
    set easylevel [expr int(100-(100*($level-1200)/(2200-1200)))]
    append analysisArgs " -b+ -p- -l- -e $easylevel "

    # If the analysis directory is not current dir, cd to it:
    set oldpwd ""
    if {$analysisDir != "."} {
      set oldpwd [pwd]
      catch {cd $analysisDir}
    }

    # Try to execute the analysis program:
    if {[catch {set analysisCoach(pipe$n) [open "| [list $analysisCommand] $analysisArgs" "r+"]} result]} {
      if {$oldpwd != ""} { catch {cd $oldpwd} }
      tk_messageBox -title "Scid: error starting analysis" \
          -icon warning -type ok \
          -message "Unable to start the program:\n$analysisCommand"
      ::tacgame::resetEngine $n
      return
    }

    # Return to original dir if necessary:
    if {$oldpwd != ""} { catch {cd $oldpwd} }

    # Configure pipe for line buffering and non-blocking mode:
    fconfigure $analysisCoach(pipe$n) -buffering line -blocking 0

    fileevent $analysisCoach(pipe$n) readable ::tacgame::processInput
    after 1000 "::tacgame::checkAnalysisStarted $n"

  }

  # ======================================================================
  # ::tacgame::closeEngine
  #   Close an engine.
  # ======================================================================
  proc closeEngine {n} {
    global windowsOS ::tacgame::analysisCoach

    # Check the pipe is not already closed
    if { $n == $::tacgame::index1 } {
      if {$analysisCoach(pipe$n) == "" } {
        return
      }
    }
    if { $n == $::tacgame::index2 } {
      ::uci::closeUCIengine $n
      return
    }

    # Send interrupt signal if the engine wants it:
    if {(!$windowsOS)  &&  $analysisCoach(send_sigint$n)} {
      catch {exec -- kill -s INT [pid $analysisCoach(pipe$n)]}
    }

    # Some engines in analyze mode may not react as expected to "quit"
    # so ensure the engine exits analyze mode first:
    sendToEngine $n "exit"
    sendToEngine $n "quit"
    catch { flush $analysisCoach(pipe$n) }

    # Uncomment the following line to turn on blocking mode before
    # closing the engine (but probably not a good idea!)
    #   fconfigure $analysisCoach(pipe$n) -blocking 1

    # Close the engine, ignoring any errors since nothing can really
    # be done about them anyway -- maybe should alert the user with
    # a message box?
    catch {close $analysisCoach(pipe$n)}

    set analysisCoach(pipe$n) ""
  }
  # ======================================================================
  # sendToEngine:
  #   Send a command to a running analysis engine.
  # ======================================================================
  proc sendToEngine {n text} {
    catch {puts $::tacgame::analysisCoach(pipe$n) $text}
  }

  # ======================================================================
  # checkAnalysisStarted
  #   Called a short time after an analysis engine was started
  #   to send it commands if Scid has not seen any output from
  #   it yet.
  # ======================================================================
  proc checkAnalysisStarted {n} {
    global ::tacgame::analysisCoach
    if {$analysisCoach(seen$n)} { return }

    # Some Winboard engines do not issue any output when
    # they start up, so the fileevent above is never triggered.
    # Most, but not all, of these engines will respond in some
    # way once they have received input of some type.  This
    # proc will issue the same initialization commands as
    # those in processAnalysisInput below, but without the need
    # for a triggering fileevent to occur.

    set analysisCoach(seen$n) 1
    ::tacgame::sendToEngine $n "xboard"
    ::tacgame::sendToEngine $n "protover 2"
    ::tacgame::sendToEngine $n "post"
    ::tacgame::sendToEngine $n "ponder off"

    # Prevent some engines from making an immediate "book"
    # reply move as black when position is sent later:
    ::tacgame::sendToEngine $n "force"
  }

  # ======================================================================
  #
  # processInput from the engine blundering (Phalanx)
  #
  # ======================================================================
  proc processInput {} {
    global ::tacgame::analysisCoach ::tacgame::analysis ::tacgame::index1 

    # Get one line from the engine:
    set line [gets $analysisCoach(pipe$index1)]
    if {$line == ""} {return}

    # check that the engine is really Phalanx
    if { ! $analysisCoach(seen$index1) && $line != {Phalanx XXII-pg} && $line != {Phalanx XXIII} } {
      # There's a bug here... Control flow somehow continues, giving an error
      ::tacgame::abortGame
      tk_messageBox -type ok -icon warning -parent . -title "Scid" -message \
        "Phalanx reports version \"$line\", but should be \"Phalanx XXIII\"."
      focus .
      return
    }

    # Check that the engine did not terminate unexpectedly:
    if {[eof $analysisCoach(pipe$index1)]} {
      fileevent $analysisCoach(pipe$index1) readable {}
      catch {close $analysisCoach(pipe$index1)}
      set analysisCoach(pipe$index1) ""
      tk_messageBox -type ok -icon info -parent . -title "Scid" \
          -message "Phalanx terminated without warning; it probably crashed or had an internal error."
    }

    if {! $analysisCoach(seen$index1)} {
      # First line of output from the program, so send initial commands:
      set analysisCoach(seen$index1) 1
      ::tacgame::sendToEngine $index1 "xboard"
      ::tacgame::sendToEngine $index1 "post"
    }

    ::tacgame::makePhalanxMove $line
  }

  # ======================================================================
  # startAnalyzeMode:
  #   Put the engine in analyze mode
  # ======================================================================
  proc startAnalyze { } {
    global ::tacgame::analysisCoach ::tacgame::isLimitedAnalysisTime ::tacgame::analysisTime
    set n $::tacgame::index2
    set ::analysis(waitForReadyOk$n) 1
    ::uci::sendToEngine $n "isready"
    vwait ::analysis(waitForReadyOk$n)
    ::uci::sendToEngine $n "position fen [sc_pos fen]"
    ::uci::sendToEngine $n "go infinite ponder"

    if { $isLimitedAnalysisTime == 1 }  {
      after [expr 1000 * $analysisTime] ::tacgame::stopAnalyze
    }

  }
  # ======================================================================
  # stopAnalyzeMode:
  #   Stop the engine analyze mode
  # ======================================================================
  proc stopAnalyze { } {
    global ::tacgame::analysisCoach ::tacgame::isLimitedAnalysisTime ::tacgame::analysisTime

    after cancel ::tacgame::stopAnalyze
    ::uci::sendToEngine 2 "stop"
  }
  ################################################################################
  # returns true if last move is a mate and stops clocks
  ################################################################################
  proc endOfGame {} {
    # Use score to check for stale, check mate.
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
        set ::tacgame::mateShown 1
	if { [getPhalanxColor] == [sc_pos side] } {
	  set side Player
        } else {
          set side Phalanx
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
  # ======================================================================
  # phalanxGo
  #		it is phalanx's turn to play
  # ======================================================================

  proc phalanxGo {} {
    global ::tacgame::analysisCoach ::tacgame::openingType ::tacgame::openingMovesList \
        ::tacgame::openingMovesHash ::tacgame::openingMoves ::tacgame::outOfOpening ::tacgame::index1

    after cancel ::tacgame::phalanxGo

    ### should show endOfGame

    if {$analysisCoach(paused)} {
      .coachWin.fbuttons.resume configure -state normal
      return
    }

    if { [::tacgame::endOfGame] } {
      catch {sc_game save [sc_game number]}
      return
    }

    # check if Phalanx is already thinking
    if { $analysisCoach(automoveThinking$index1) } {
      after 1000 ::tacgame::phalanxGo
      return
    }

    updateAnalysisText

    if { [sc_pos side] != [::tacgame::getPhalanxColor] } {
      after 1000 ::tacgame::phalanxGo
      return
    }

    ::gameclock::stop 1
    ::gameclock::start 2
    repetition

    # make a move corresponding to a specific opening, (it is Phalanx's turn)
    if {$openingType == "specific" && !$outOfOpening} {
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
            after 1000 ::tacgame::phalanxGo
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
          
          ::utils::sound::AnnounceNewMove $move
          updateBoard -pgn -animate
          ::gameclock::stop 2
          ::gameclock::start 1
          repetition
          after 1000 ::tacgame::phalanxGo
          return
        }
      }
      
    }

    # Pascal Georges : original Phalanx does not have 'setboard'
    set analysisCoach(automoveThinking$index1) 1
    sendToEngine $index1 "setboard [sc_pos fen]"
    sendToEngine $index1 "go"
    after 1000 ::tacgame::phalanxGo
  }

  ################################################################################
  #   add current position for 3fold repetition detection and returns 1 if
  # the position is a repetion
  ################################################################################
  proc repetition {} {
    set elt [lrange [split [sc_pos fen]] 0 2]
    lappend ::tacgame::lFen $elt
    if { [llength [lsearch -all $::tacgame::lFen $elt] ] >=3 \
      && ! $::tacgame::drawShown } {
      ::tacgame::pauseGame
      set ::tacgame::drawShown 1
      sc_game tags set -result =
      tk_messageBox -type ok -message $::tr(Draw) -parent .board -icon info
      catch {sc_game save [sc_game number]}
      return 1
    }
    return 0
  }


  proc makePhalanxMove {input} {

    global ::tacgame::lscore ::tacgame::analysisCoach ::tacgame::currentPosHash ::tacgame::resignCount ::tacgame::index1

    # The input move is of the form "my move is MOVE"
    if {[scan $input "my move is %s" move] != 1} {
      return 0
    }

    ::tacgame::stopAnalyze

    # Phalanx will move : update the score list to detect any blunder
    if {[info exists ::tacgame::sc1]} {
      lappend lscore $::tacgame::sc1
    }

    # if the resign value has been reached more than 3 times in a raw, resign
    if { ( [getPhalanxColor] == "black" && [lindex $lscore end] >  $::informant("++-") ) || \
          ( [getPhalanxColor] == "white" && [lindex $lscore end] < [expr 0.0 - $::informant("++-")] ) } {
      incr resignCount
    } else  {
      set resignCount 0
    }

    # check the sequence of moves
    # in case of any event (board setup, move back/forward), reset score list
    if { ![sc_pos isAt start] && ![sc_pos isAt vstart]} {
      sc_move back 1
      if { [sc_pos hash] != $currentPosHash} {
        set lscore {}
        updateAnalysisText
      }
      sc_move forward 1
    } else  {
      if { [sc_pos hash] != $currentPosHash} {
        set lscore {}
        updateAnalysisText
      }
    }

    # play the move
    set action "replace"
    if {![sc_pos isAt vend]} { set action [confirmReplaceMove] }
    if {$action == "replace"} {
      if {[catch {sc_move addSan $move}]} {
        # No move from Phalanx : remove the score (last element)
        set lscore [lreplace $lscore end end]
        return 0
      }
    } elseif {$action == "var"} {
      sc_var create
      if {[catch {sc_move addSan $move}]} {
        # No move from Phalanx : remove the score (last element)
        set lscore [lreplace $lscore end end]
        return 0
      }
    } elseif {$action == "mainline"} {
      sc_var create
      if {[catch {sc_move addSan $move}]} {
        # No move from Phalanx : remove the score (last element)
        set lscore [lreplace $lscore end end]
        return 0
      }
      sc_var exit
      sc_var promote [expr {[sc_var count] - 1}]
      sc_move forward 1
    } elseif {$action == "cancel"} {
      return
    }

    set analysisCoach(automoveThinking$index1) 0
    set currentPosHash [sc_pos hash]

    ::tacgame::startAnalyze
    ::utils::sound::AnnounceNewMove $move
    updateBoard -pgn -animate

    ::gameclock::stop 2
    ::gameclock::start 1
    repetition

    if { $resignCount > 3 && ! $::tacgame::resignShown } {
      tk_messageBox -type ok -message $::tr(Iresign) -parent .board -icon info
      set ::tacgame::resignShown 1
      set resignCount 0
    }
  }

  # ======================================================================
  # updateScore
  # ======================================================================
  proc updateScore { } {
    global ::tacgame::index2

    if { ! $::tacgame::showevaluation } { return }
    if {![info exists ::uci::uciInfo(score$index2)]} {
      set ::tacgame::scoreLabel ""
      return
    } else {
      set ::tacgame::scoreLabel "Score : $::uci::uciInfo(score$index2)"
    }
  }

  # ======================================================================
  # updateAnalysisText
  #   Update the text in an analysis window.
  #   Human blunders are not checked, only Phalanx'one
  # ======================================================================
  proc updateAnalysisText { } {
    global ::tacgame::analysisCoach ::tacgame::showblunder ::tacgame::blunderWarningLabel \
        ::tacgame::showblunder ::tacgame::showblundervalue ::tacgame::showblunderfound ::tacgame::showmovevalue \
        ::tacgame::showevaluation ::tacgame::lscore ::tacgame::threshold \
        ::tacgame::lastblundervalue ::tacgame::prev_lastblundervalue ::tacgame::scoreLabel \
        ::tacgame::blunderpending ::tacgame::prev_blunderpending ::tacgame::sc1 ::tacgame::index1 ::tacgame::index2

    # only update when it is human turn
    if { [getPhalanxColor] == [sc_pos side] } { return }

    catch {
      set sc1 $::uci::uciInfo(score$index2)
      set sc2 [lindex $lscore end]
    }

    # There are less than 2 scores in the list
    if {[llength $lscore] < 2} {
      set blunderWarningLabel $::tr(Noinfo)
      set scoreLabel ""
      if {[llength $lscore] == 1 && $showevaluation } {
        set scoreLabel "Score : [lindex $lscore end]"
      }
      return
    }

    # set sc1 [lindex $lscore end]
    # set sc2 [lindex $lscore end-1]

    if { $analysisCoach(automoveThinking$index1) } {
      set blunderWarningLabel $::tr(Noinfo)
    }

    # Check if a blunder was made by Phalanx at last move.
    # The check is done during player's turn
    if { $showblunder && [::tacgame::getPhalanxColor] != [sc_pos side] } {
      if {[llength $lscore] >=2} {
        if { ($sc1 - $sc2 > $threshold && [::tacgame::getPhalanxColor] == "black") || \
              ($sc1 - $sc2 < [expr 0.0 - $threshold] && [::tacgame::getPhalanxColor] == "white") } {
          set lastblundervalue [expr $sc1-$sc2]
          # append a ?!, ? or ?? to the move if there is none yet and if the game was not dead yet
          # (that is if the score was -6, if it goes down to -10, this is a normal evolution
          if { [expr abs($sc2)] < $::informant("++-") } {
            sc_pos clearNags
            set b [expr abs($lastblundervalue)]
            if { $b >= $::informant("?!") && $b < $::informant("?") } {
              sc_pos addNag "?!"
            } elseif { $b >= $::informant("?") && $b < $::informant("??") }  {
              sc_pos addNag "?"
            } elseif  { $b >= $::informant("??") } {
              sc_pos addNag "??"
            }
          }
          
          .coachWin.finformations.l1 configure -bg LightCoral
          if { $showblundervalue } {
            set tmp $::tr(blunder)
            append tmp [format " %+8.2f" [expr abs($sc1-$sc2)]]
            set blunderWarningLabel $tmp
            set blunderpending 1
          } else {
            set blunderWarningLabel "$::tr(blunder) !"
          }
        } else {
          sc_pos clearNags
          .coachWin.finformations.l1 configure -bg linen
          set blunderWarningLabel $::tr(Noblunder)
          set blunderpending 0
        }
      }
    } else {
      set blunderWarningLabel "---"
    }

    if { !$showblunder || $analysisCoach(automoveThinking$index1) } {
      set blunderWarningLabel "---"
    }

    # displays current score sent by the "good" engine (Toga)
    if { $showevaluation } {
      set scoreLabel "Score : $sc1"
    } else {
      set scoreLabel ""
    }
  }

  # ======================================================================
  # getPhalanxColor
  #   Returns "white" or "black" (Phalanx always plays at top)
  # ======================================================================
  proc getPhalanxColor {} {
    # Phalanx always plays for the upper side
    if { [::board::isFlipped .board] == 0 } {
      return "black"
    } else  {
      return "white"
    }
  }

  ################################################################################
  #
  ################################################################################
  set openingList [ list \
      "$::tr(Reti): 1.Nf3" \
      "$::tr(English): 1.c4" \
      "$::tr(d4Nf6Miscellaneous): 1.d4 Nf6" \
      "$::tr(Trompowsky): 1.d4 Nf6 2.Bg5" \
      "$::tr(Budapest): 1.d4 Nf6 2.c4 e5" \
      "$::tr(OldIndian): 1.d4 Nf6 2.c4 d6" \
      "$::tr(BenkoGambit): 1.d4 Nf6 2.c4 c5 3.d5 b5" \
      "$::tr(ModernBenoni): 1.d4 Nf6 2.c4 c5 3.d5 e6" \
      "$::tr(DutchDefence): 1.d4 f5" \
      "1.e4" \
      "$::tr(Scandinavian): 1.e4 d5" \
      "$::tr(AlekhineDefence): 1.e4 Nf6" \
      "$::tr(Pirc): 1.e4 d6" \
      "$::tr(CaroKann): 1.e4 c6" \
      "$::tr(CaroKannAdvance): 1.e4 c6 2.d4 d5 3.e5" \
      "$::tr(Sicilian): 1.e4 c5" \
      "$::tr(SicilianAlapin): 1.e4 c5 2.c3" \
      "$::tr(SicilianClosed): 1.e4 c5 2.Nc3" \
      "$::tr(Sicilian): 1.e4 c5 2.Nf3 Nc6" \
      "$::tr(Sicilian): 1.e4 c5 2.Nf3 e6" \
      "$::tr(SicilianRauzer): 1.e4 c5 2.Nf3 d6 3.d4 cxd4 4.Nxd4 Nf6 5.Nc3 Nc6" \
      "$::tr(SicilianDragon): 1.e4 c5 2.Nf3 d6 3.d4 cxd4 4.Nxd4 Nf6 5.Nc3 g6 " \
      "$::tr(SicilianScheveningen): 1.e4 c5 2.Nf3 d6 3.d4 cxd4 4.Nxd4 Nf6 5.Nc3 e6" \
      "$::tr(SicilianNajdorf): 1.e4 c5 2.Nf3 d6 3.d4 cxd4 4.Nxd4 Nf6 5.Nc3 a6" \
      "$::tr(OpenGame): 1.e4 e5" \
      "$::tr(Vienna): 1.e4 e5 2.Nc3" \
      "$::tr(KingsGambit): 1.e4 e5 2.f4" \
      "$::tr(RussianGame): 1.e4 e5 2.Nf3 Nf6" \
      "$::tr(OpenGame): 1.e4 e5 2.Nf3 Nc6" \
      "$::tr(ItalianTwoKnights): 1.e4 e5 2.Nf3 Nc6 3.Bc4" \
      "$::tr(Spanish): 1.e4 e5 2.Nf3 Nc6 3.Bb5" \
      "$::tr(SpanishExchange): 1.e4 e5 2.Nf3 Nc6 3.Bb5 a6 4.Bxc6" \
      "$::tr(SpanishOpen): 1.e4 e5 2.Nf3 Nc6 3.Bb5 a6 4.Ba4 Nf6 5.O-O Nxe4" \
      "$::tr(SpanishClosed): 1.e4 e5 2.Nf3 Nc6 3.Bb5 a6 4.Ba4 Nf6 5.O-O Be7" \
      "$::tr(FrenchDefence): 1.e4 e6" \
      "$::tr(FrenchAdvance): 1.e4 e6 2.d4 d5 3.e5" \
      "$::tr(FrenchTarrasch): 1.e4 e6 2.d4 d5 3.Nd2" \
      "$::tr(FrenchWinawer): 1.e4 e6 2.d4 d5 3.Nc3 Bb4" \
      "$::tr(FrenchExchange): 1.e4 e6 2.d4 d5 3.exd5 exd5" \
      "$::tr(QueensPawn): 1.d4 d5" \
      "$::tr(Slav): 1.d4 d5 2.c4 c6" \
      "$::tr(QGA): 1.d4 d5 2.c4 dxc4" \
      "$::tr(QGD): 1.d4 d5 2.c4 e6" \
      "$::tr(QGDExchange): 1.d4 d5 2.c4 e6 3.cxd5 exd5" \
      "$::tr(SemiSlav): 1.d4 d5 2.c4 e6 3.Nc3 Nf6 4.Nf3 c6" \
      "$::tr(QGDwithBg5): 1.d4 d5 2.c4 e6 3.Nc3 Nf6 4.Bg5" \
      "$::tr(QGDOrthodox): 1.d4 d5 2.c4 e6 3.Nc3 Nf6 4.Bg5 Be7 5.e3 O-O 6.Nf3 Nbd7" \
      "$::tr(Grunfeld): 1.d4 Nf6 2.c4 g6 3.Nc3 d5" \
      "$::tr(GrunfeldExchange): 1.d4 Nf6 2.c4 g6 3.Nc3 d5 4.cxd5" \
      "$::tr(GrunfeldRussian): 1.d4 Nf6 2.c4 g6 3.Nc3 d5 4.Nf3 Bg7 5.Qb3" \
      "$::tr(Catalan): 1.d4 Nf6 2.c4 e6 3.g3 " \
      "$::tr(CatalanOpen): 1.d4 Nf6 2.c4 e6 3.g3 d5 4.Bg2 dxc4" \
      "$::tr(CatalanClosed): 1.d4 Nf6 2.c4 e6 3.g3 d5 4.Bg2 Be7" \
      "$::tr(QueensIndian): 1.d4 Nf6 2.c4 e6 3.Nf3 b6" \
      "$::tr(NimzoIndian): 1.d4 Nf6 2.c4 e6 3.Nc3 Bb4" \
      "$::tr(NimzoIndianClassical): 1.d4 Nf6 2.c4 e6 3.Nc3 Bb4 4.Qc2" \
      "$::tr(NimzoIndianRubinstein): 1.d4 Nf6 2.c4 e6 3.Nc3 Bb4 4.e3" \
      "$::tr(KingsIndian): 1.d4 Nf6 2.c4 g6" \
      "$::tr(KingsIndianSamisch): 1.d4 Nf6 2.c4 g6 4.e4 d6 5.f3" \
      "$::tr(KingsIndianMainLine): 1.d4 Nf6 2.c4 g6 4.e4 d6 5.Nf3" \
      ]
}
###
### End of file: tacgame.tcl
###
