### Computer Tournament 
###
### comp.tcl: part of Scid.
### Copyright (C) 2010- Steven Atkinson

# Credit to Fulvio for a few lines of UCI code that enabled me
# to make this run nicely (without constantly reseting analysis),
# and gave me impetus for a decent control structure using
# semaphores/vwait instead of the often abused dig-deeper procedural flow 
# sometimes evident in tcl programs.

# The functionality of this feature is not amazing because of my lack of knowledge
# about the uci and xboard protocols. Having said that, it works great imho, and
# supports a suprising number of chess engines. UCI support seems comprehensive, and
# on the xboard side - Crafty, Scorpio, Sjeng and GnuChess, amongst others, seem fine.

# Opening books are disabled for UCI engines... which makes doing a computer
# tournament Xboard openings will work if configured individually.

set comp(playing) 0
set comp(current) 0
set comp(games) {}
set comp(debug) 1
set comp(badmoves) 0
set comp(iconize) 0
set comp(animate) 1

proc compInit {} {
  global analysis comp engines

  set w .comp

  if {[winfo exists $w]} {
    raiseWin $w
    return
  }
  toplevel $w
  wm state $w withdrawn
  wm title $w "Configure Tournament"
  setWinLocation $w

  pack [frame $w.engines] -side top
  addHorizontalRule $w
  pack [frame $w.config] -fill x -expand 1
  addHorizontalRule $w
  pack [frame $w.buttons] -side bottom -pady 10 -padx 5

  ### Engines

  pack [label $w.engines.label -text "Number of Engines"] -side top -padx 5 -pady 5

  pack [frame $w.engines.top] -side top -padx 10 -pady 5 -expand 1 -fill x
  pack [spinbox $w.engines.top.count -textvariable comp(count) -from 2 -to [llength $engines(list)] -width 5] \
    -side left -padx 5 -pady 5
  dialogbutton $w.engines.top.update -text Update -command drawCombos
  pack $w.engines.top.update -side right -padx 5 -pady 5

  set comp(count) 2
  set comp(countcombos) $comp(count)
  drawCombos

  ### Config widgets

  set row 0

  label $w.config.eventlabel -text {Event Name}
  entry $w.config.evententry -width 10 -textvariable comp(name) -borderwidth 1

  grid $w.config.eventlabel -row $row -column 0 -sticky w -padx 5 -pady 2
  grid $w.config.evententry -row $row -column 1 -sticky w -padx 5 -pady 2

  incr row
  label $w.config.roundslabel -text {Number of Rounds}
  spinbox $w.config.roundsvalue -textvariable comp(rounds) -from 1 -to 10 -width 9

  grid $w.config.roundslabel -row $row -column 0 -sticky w -padx 5 -pady 2
  grid $w.config.roundsvalue -row $row -column 1 -sticky w -padx 5 -pady 2

  incr row
  frame $w.config.control
  label $w.config.control.0 -text {Time Control is per}
  radiobutton $w.config.control.1 -variable comp(timecontrol) -value pergame -text Game -command checkTimeControl
  radiobutton $w.config.control.2 -variable comp(timecontrol) -value permove -text Move -command checkTimeControl

  pack $w.config.control.0 $w.config.control.1 $w.config.control.2 -side left -expand 1 -fill x
  grid $w.config.control  -row $row -column 0 -columnspan 2 -sticky ew -pady 2

  incr row
  frame $w.config.timegame 
    # hack to stop the spinbox from zeroing floating point values for minutes time
    set temp $comp(minutes)
  label $w.config.timegame.label -text {Time per Game}
  spinbox $w.config.timegame.mins -textvariable comp(minutes) -from 0 -to 40 -width 4
    set comp(minutes) $temp
  label $w.config.timegame.label2 -text mins
  spinbox $w.config.timegame.incr -textvariable comp(incr) -from 0 -to 60 -width 4
  label $w.config.timegame.label3 -text secs

  pack $w.config.timegame.label -side left
  pack $w.config.timegame.label3 $w.config.timegame.incr $w.config.timegame.label2 $w.config.timegame.mins -side right
  grid $w.config.timegame -row $row -column 0 -columnspan 2 -sticky ew -pady 2 -padx 5

  incr row
  frame $w.config.timesecs 
  label $w.config.timesecs.label -text {Time per Move}
  spinbox $w.config.timesecs.value -textvariable comp(seconds) -from 1 -to 3600 -width 4
  label $w.config.timesecs.label2 -text secs

  pack $w.config.timesecs.label -side left
  pack $w.config.timesecs.label2 $w.config.timesecs.value -side right
  grid $w.config.timesecs -row $row -column 0 -columnspan 2 -sticky ew -pady 2 -padx 5

  checkTimeControl

  incr row
  grid  [frame $w.config.line -height 2 -borderwidth 2 -relief sunken] -pady 5 -sticky ew -row $row -column 0 -columnspan 2

  incr row
  label $w.config.timeoutlabel -text {Time-out (seconds)}
  spinbox $w.config.timeoutvalue -textvariable comp(timeout) -from 1 -to 300 -width 9

  grid $w.config.timeoutlabel -row $row -column 0 -sticky w -padx 5 -pady 2
  grid $w.config.timeoutvalue -row $row -column 1 -sticky w -padx 5 -pady 2

  incr row
  label $w.config.verboselabel -text {Print info to Console}
  checkbutton $w.config.verbosevalue -variable comp(debug) 
  set comp(debug) 1

  grid $w.config.verboselabel -row $row -column 0 -sticky w -padx 5 -pady 2
  grid $w.config.verbosevalue -row $row -column 1 -padx 5 -pady 2

  grid $w.config.verboselabel -row $row -column 0 -sticky w -padx 5 -pady 2
  grid $w.config.verbosevalue -row $row -column 1 -padx 5 -pady 2

  incr row
  label $w.config.iconizelabel -text {Analysis starts Iconized}
  checkbutton $w.config.iconizevalue -variable comp(iconize) 
  set comp(iconize) 1

  grid $w.config.iconizelabel -row $row -column 0 -sticky w -padx 5 -pady 2
  grid $w.config.iconizevalue -row $row -column 1 -padx 5 -pady 2

  incr row
  label $w.config.animatelabel -text {Animate moves}
  checkbutton $w.config.animatevalue -variable comp(animate) 
  set comp(animate) 1

  grid $w.config.animatelabel -row $row -column 0 -sticky w -padx 5 -pady 2
  grid $w.config.animatevalue -row $row -column 1 -padx 5 -pady 2

  incr row
  label $w.config.start_title -text {Start Position}
  grid $w.config.start_title -row $row -column 0 -columnspan 2

  set comp(start) 0

  incr row
  label $w.config.start1label -text {New Games}
  radiobutton $w.config.start1button -variable comp(start) -value 0
  grid $w.config.start1label -row $row -column 0 -sticky w -padx 5 -pady 2
  grid $w.config.start1button -row $row -column 1 -padx 5 -pady 2

  incr row
  label $w.config.start2label -text {First game from this position}
  radiobutton $w.config.start2button -variable comp(start) -value 1
  grid $w.config.start2label -row $row -column 0 -sticky w -padx 5 -pady 2
  grid $w.config.start2button -row $row -column 1 -padx 5 -pady 2

  incr row
  label $w.config.start3label -text {All games from this position}
  radiobutton $w.config.start3button -variable comp(start) -value 2
  grid $w.config.start3label -row $row -column 0 -sticky w -padx 5 -pady 2
  grid $w.config.start3button -row $row -column 1 -padx 5 -pady 2

  ### OK, Cancel Buttons

  if {$::windowsOS} {
    # fixed width dialogbutton cuts text in winxp
    set button button
  } else {
    set button dialogbutton
  }

  $button $w.buttons.cancel -text Cancel -command compClose
  $button $w.buttons.ok -text Ok -command compOk
  $button $w.buttons.help -text $::tr(Help) -command {helpWindow Tourney}

  focus $w.buttons.ok
  pack $w.buttons.ok $w.buttons.help -side left -padx 5
  pack $w.buttons.cancel -side right -padx 5

  bind $w <Configure> "recordWinSize $w"
  bind $w <Destroy> compClose
  bind $w <Escape> compClose
  bind $w <F1> {helpWindow Tourney}
  wm state $w normal
  update

}

proc checkTimeControl {} {
  if {$::comp(timecontrol) == "permove" } {
    foreach i [winfo children .comp.config.timesecs] {
      $i configure -state normal
    }
    foreach i [winfo children .comp.config.timegame] {
      $i configure -state disabled
    }
  } else {
    foreach i [winfo children .comp.config.timesecs] {
      $i configure -state disabled
    }
    foreach i [winfo children .comp.config.timegame] {
      $i configure -state normal
    }
  }
  update
}

proc compOk {} {
  global analysis comp engines

  set w .comp

  set comp(start_fen) [sc_pos fen]

  if {$comp(count) != $comp(countcombos)} {
    drawCombos
    return
  }

  if {[sc_base isReadOnly]} {
    set answer [tk_messageBox -title Tournanment -icon question -type okcancel \
	-message {Database is read only, continue ?} -parent $w]
    if {$answer != "ok"} {return}
  }
    
  set players {}
  set names {}
  set comp(games) {}
  set comp(current) 0

  if {$comp(timecontrol) == "permove"} {
    set comp(time) [expr $comp(seconds) * 1000]
    puts_ "Move delay is $comp(time) seconds"
  } 

  for {set i 0} {$i < $comp(count)} {incr i} {
    set j [$w.engines.list.$i current]
    lappend players [expr $j + 1]
    lappend names   [lindex [lindex $engines(list) $j] 0]
  }

  ### Check players are unique
  if {[llength [lsort -unique $players]] != $comp(count)} {
    tk_messageBox -type ok -parent $w -title {Scid: error} \
      -message {Duplicate engines not supported}
    return
  }

  foreach i $players j $names {
    puts_ "player $i is $j"
  }

  ### Reconfigure init widget for pausing

  for {set i 0} {$i < $comp(count)} {incr i} {
    $w.engines.list.$i configure -state disabled ; # disable widgets too
  }
  foreach j {.comp.config .comp.engines .comp.engines.top .comp.config.control .comp.config.timesecs .comp.config.timegame} {
    foreach i [winfo children $j] {
      catch {$i configure -state disabled}
    }
  }
  $w.buttons.ok configure -text Pause -command compPause -state normal
  $w.buttons.help configure -text {End Game} -command compGameEnd -state normal
  $w.buttons.cancel configure -text {End Comp} -command compAbort -state normal
  wm title $w {Scid Tournament}
  focus $w.buttons.ok
  bind $w <Destroy> compAbort
  
  ### Place games in cue

  for {set i 0} {$i < $comp(count)} {incr i} {
    for {set j 0} {$j <= $i} {incr j} {
      if {$i == $j} {continue}
      for {set k 1} {$k <= $comp(rounds)} {incr k} {
	compCueGame [lindex $players $j] [lindex $players $i] [lindex $names $j] [lindex $names $i] $k
        incr k
        if {$k <= $comp(rounds)} {
	  compCueGame [lindex $players $i] [lindex $players $j] [lindex $names $i] [lindex $names $j] $k
        }
      }
    }
  }
  puts_ "CHECKING game count:"
  set num_games [expr {$comp(count) * ($comp(count)-1) * $comp(rounds) / 2}]
  puts_ "Length of cue is [llength $comp(games)], Calculated number of games is $num_games"

  ttk::progressbar $w.progress -mode determinate \
    -maximum $num_games -variable comp(current)
  pack $w.progress -side bottom -fill x -padx 10 -pady 5

  ### Play games

  set thisgame [lindex $comp(games) $comp(current)]

  while {$thisgame != {} } {
    puts_ "thisgame is \"$thisgame\", games are \"$comp(games)\""
    set n     [lindex $thisgame 0]
    set m     [lindex $thisgame 1]
    set name1 [lindex $thisgame 2]
    set name2 [lindex $thisgame 3]
    set k     [lindex $thisgame 4]
    if {$n != {} && $m != {}} {
      puts_ "Game [expr $comp(current) + 1]: $name1 vs. $name2"
      incr comp(current)
      compNM $n $m $k
    }
    set thisgame [lindex $comp(games) $comp(current)]
  } 

  ### Comp over

  puts_ {Comp finished}
  set comp(iconize) 0
  if {[winfo exists .comp]} {
    bind .comp <Destroy> {}
    # voodoo that you do
    wm geometry .comp [wm geometry .comp]
    pack forget .comp.buttons.ok
    pack forget .comp.buttons.cancel
    .comp.buttons.help configure -text Close -command {
       compDestroy
    }
    raiseWin .comp
  }
}

proc compNM {n m k} {
  global analysis comp

  if {$comp(timecontrol) == "pergame"} {
    # minutes does not have to be an integer
    set comp(wtime) [expr int($comp(minutes)*60*1000)]
    set comp(btime) [expr int($comp(minutes)*60*1000)]
    set total [expr int($comp(minutes) * 60)]
    set mins [expr $total/60]
    set secs [expr $total%60]
    if {$secs == 0} {
      set timecontrol $mins
    } else {
      if {$secs < 10} {
	set secs "0$secs"
      }
      set timecontrol $mins:$secs
    }

    puts_ "Game period is $comp(wtime) seconds"
  }

  if {$comp(start) > 0 && $comp(current) == 1} {
    # ok!
  } elseif {$comp(start) == 2} {
    sc_game new
    sc_game startBoard $comp(start_fen)
  } else {
    sc_game new
  }

  set comp(playing) 1
  set comp(paused) 0
  set comp(white) $n
  set comp(fen) {}

  if {[winfo exists .analysisWin$n]} "destroy .analysisWin$n"
  if {[winfo exists .analysisWin$m]} "destroy .analysisWin$m"

  makeAnalysisWin $n
  if {![winfo exists .analysisWin$n]} {
    puts_ ".analysisWin$n dead, exitting Tournament"
    set comp(games) {}
    return
  }
  toggleMovesDisplay $n

  makeAnalysisWin $m
  if {![winfo exists .analysisWin$m]} {
    puts_ ".analysisWin$m dead, exitting Tournament"
    set comp(games) {}
    return
  }
  toggleMovesDisplay $m

  #Stop all engines
  if {$analysis(analyzeMode$n)} { toggleEngineAnalysis $n 1 }
  if {$analysis(analyzeMode$m)} { toggleEngineAnalysis $m 1 }
  
  puts_ "compNM : setting white $analysis(name$n) , black $analysis(name$m), round $k"
  sc_game tags set -white $analysis(name$n)
  sc_game tags set -black $analysis(name$m)
  sc_game tags set -event $comp(name)
  if {$comp(timecontrol) == "permove"} {
    sc_game tags set -date [::utils::date::today] -round $k -extra "{Movetime \"$comp(seconds)\"}"
  } else {
    sc_game tags set -date [::utils::date::today] -round $k -extra "{TimeControl \"$timecontrol/$comp(incr)\"}"
  }
  update idletasks
  updateBoard -pgn

  updateTitle
  update

  after [expr $comp(timeout) * 1000] compTimeout

  ### Initialsation

  puts_ "COMP Engine initialisation"
  foreach current_engine "$n $m" {
    if {$::analysis(uci$current_engine)} {
        # fulvio issues isready every move ??
	set analysis(waitForReadyOk$current_engine) 1
	sendToEngine $current_engine "isready"
	vwait analysis(waitForReadyOk$current_engine)
	# if {!$comp(playing)} {break}
    } else {
	sendToEngine $current_engine xboard

	# Should this be ponder off ?
	# If you have one computer and you want to use all cores of the
	# computer and you start to test with ponder on then it is possible
	# that one program may steal time from the second program(because you
	# have no way to force both engines to use 50% of the cpu time)

	sendToEngine $current_engine "ponder on"
	sendToEngine $current_engine "bk off"

	# done later
	# sendToEngine $current_engine "st $comp(seconds)"

	# Sjeng or Chen run too fast unless "hard" is issued
	if {[regexp -nocase arasan $analysis(name$current_engine)]} {
	  puts_ {Arasan detected. Issuing "hard"}
	  sendToEngine $current_engine hard
	}
	if {[regexp -nocase sjeng $analysis(name$current_engine)]} {
	  puts_ {Sjeng detected. Issuing "hard"}
	  sendToEngine $current_engine hard
	}
	if {[regexp -nocase xchen $analysis(name$current_engine)] || \
	    [regexp -nocase chenard $analysis(name$current_engine)] } {
	  puts_ {Chenard detected. Issuing "hard"}
	  sendToEngine $current_engine hard
	}
        # I thought this might be necessary to ?
	# if {$current_engine == $m} { sendToEngine $current_engine new }
    }
  }

  if {[sc_pos side] == {white}} {
    set current_engine $n
    set other_engine $m
  } else {
    set current_engine $m
    set other_engine $n
  }

  # Thanks to Fulvio for inspiration to rewrite this properly (?!) :>

  while {$comp(playing)} {
    set comp(lasttime) [clock clicks -milli]
    set comp(move) $current_engine
    set comp(nextmove) $other_engine

    if {$::analysis(uci$current_engine)} {
      ### uci

      sendToEngine $current_engine "position fen [sc_pos fen]"

      if {$comp(timecontrol) == "permove"} {
	sendToEngine $current_engine "go movetime $comp(time)"
      } else {
        set incr [expr $comp(incr) * 1000]
	puts_ "go wtime $comp(wtime) btime $comp(btime) winc $incr binc $incr"
	sendToEngine $current_engine "go wtime $comp(wtime) btime $comp(btime) winc $incr binc $incr"
      }

      
      set analysis(fen$current_engine) [sc_pos fen]
      set analysis(maxmovenumber$current_engine) 0

      set analysis(waitForBestMove$current_engine) 1
      vwait analysis(waitForBestMove$current_engine)

      if {!$comp(playing)} {break}
    } else {
      ### xboard

      # "st TIME" [time limit] and "playother" are only for protoversion 2
      # phalanx and other older(?) engines won't honour time limit
      # but they'll get beat anyway
      # Should fix it up though

      ## Don't test for setboard as Phalanx doest report this working feature
      # if {$analysis(has_setboard$current_engine)}
      sendToEngine $current_engine "setboard [sc_pos fen]"

      # Some xboard engines move very rapidly... there might be a 
      # inbred bug confusing centiseconds and seconds.

      if {$comp(timecontrol) == "permove"} {
	# This needs sorting out properly
	sendToEngine $current_engine "st $comp(seconds)"
	sendToEngine $current_engine "time [expr $comp(seconds) * 100]"
      } else {
	if {$current_engine == $n} {
          set temp $comp(wtime)
        } else {
          set temp $comp(btime)
        }
        set secs [expr $temp/1000]
        set mins [expr $secs/60]:[expr $secs%60]
        sendToEngine $current_engine "level 0 $mins $comp(incr)"
        puts_ "sendToEngine $current_engine level 0 $mins $comp(incr)"
      }

      sendToEngine $current_engine "go"
      vwait analysis(waitForBestMove$current_engine)

      if {!$comp(playing)} {break}

      # sendToEngine $current_engine playother
    }

    if {[makeAnalysisMove $current_engine]} {
      ### Move success

      # expired time is
      set expired [expr [clock clicks -milli] - $comp(lasttime)]
      puts_ "Time expired $expired"

      set comp(badmoves) 0
      after cancel compTimeout

      while {$comp(paused)} {
	puts_ "  PAUSED at [clock format [clock seconds]]"
	vwait comp(paused)
	puts_ "UNPAUSED at [clock format [clock seconds]]"
      }

      after [expr $comp(timeout) * 1000] compTimeout

      # set moves [ lindex [ lindex $analysis(multiPV$current_engine) 0 ] 2 ]
      # set text [format "%+.2f %s - %s  Depth: %d  Time:%6.2f s" \
      # $analysis(score$current_engine) \
      # [addMoveNumbers $current_engine [::trans $moves]] \
      # $analysis(name$current_engine) \
      # $analysis(depth$current_engine) \
      # $analysis(time$current_engine) ]
      # sc_pos setComment $text

      set score [sc_pos analyze -time 50]
      if { $score == {0 {}}} {
	### stalemate
	sc_game tags set -result =
	puts_ Stalemate
	break
      } elseif { $score == {-32000 {}}} {
	### checkmate
	if {[sc_pos side] == {black}} {
	  sc_game tags set -result 1
	} else {
	  sc_game tags set -result 0
	}
	puts_ Checkmate
	break
      } else {
	set f [lindex [split [sc_pos fen]] 0]
	lappend comp(fen) $f
	if {[llength [lsearch -all $comp(fen) $f]] > 2 } {
	  sc_game tags set -result =
	  ### draw
	  puts_ Draw
	  break
	} 
      }

      # swap players
      if {$current_engine != $n} {
	if {$comp(timecontrol) == "pergame"} {
	  set comp(btime) [expr $comp(btime) - $expired]
          if {$comp(btime) < 0} {
            sc_game tags set -result 1
            puts_ {Black forfeits on time}
            break
          }
          # add time increment
          incr comp(btime) [expr $comp(incr) * 1000]
        }
        # Now its whites turn
	set current_engine $n
	set other_engine $m
      } else {
	if {$comp(timecontrol) == "pergame"} {
	  set comp(wtime) [expr $comp(wtime) - $expired]
          if {$comp(wtime) < 0} {
            sc_game tags set -result 0
            puts_ {White forfeits on time}
            break
          }
          # add time increment
          incr comp(wtime) [expr $comp(incr) * 1000]
        }
        # Now its blacks turn
	set current_engine $m
	set other_engine $n
      }

    } else {
      ### Move failed... don't swap players
      puts_ {Move FAIL}

      ### Unlikely, but could happen
      while {$comp(paused)} {
	after cancel compTimeout

	puts_ "  PAUSED at [clock format [clock seconds]]"
	vwait comp(paused)
	puts_ "UNPAUSED at [clock format [clock seconds]]"

	after [expr $comp(timeout) * 1000] compTimeout
      }
    }

  } 
  ### This game is over

  after cancel compTimeout
  puts_ "Game $n - $m is over"

  # Save game

  if {$comp(timecontrol) == "pergame"} {
    sc_pos setComment "[sc_pos getComment]White time $comp(wtime), Black time $comp(btime)"
  }

  if {![sc_base isReadOnly]} {
  puts_ {saving game}
    sc_game save [sc_game number]
    ::windows::gamelist::Refresh
    ::crosstab::Refresh
  }

  # Destroy analysis windgets

  destroy .analysisWin$n
  destroy .analysisWin$m
}

proc compPause {} {
  global analysis comp engines
  set w .comp

  after cancel compTimeout
  $w.buttons.ok configure -text Resume -command compResume
  set comp(paused) 1
}

proc compResume {} {
  global analysis comp engines
  set w .comp

  $w.buttons.ok configure -text Pause -command compPause
  set comp(paused) 0
}

proc puts_ {message} {
  if {$::comp(debug) && $::comp(playing)} {
    puts "$message"
  }
}

proc drawCombos {} {
  global analysis comp engines

  # Check number of engines is sane
  if {![string is integer -strict $comp(count)]} {
    set comp(count) 2
    update
  }
  if {$comp(count) > [llength $engines(list)]} {
    set comp(count) [llength $engines(list)]
    update
  }

  set w .comp
  set l $w.engines.list

  bind $w <Destroy> {} ; # stupid thing!
  if {[winfo exists $l]} {destroy $l}
  bind $w <Destroy> compClose

  pack [frame $l] -side top -padx 10 -pady 10

  set values {}

  foreach e $engines(list) {
    lappend values [lindex $e 0]
  }

  for {set i 0} {$i < $comp(count)} {incr i} {
    ttk::combobox  $l.$i -width 20 -state readonly -values $values
    $l.$i current $i
    pack $l.$i -side top -pady 5
  }
  set comp(countcombos) $comp(count)
  update
}

proc compCueGame {n m name1 name2 k} {
  global analysis comp
  lappend comp(games) [list $n $m $name1 $name2 $k]
}


proc compTimeout {} {
    global analysis comp

    puts_ "!!! Move timed out, starting next game"
    sc_pos setComment {Game timed out.}

    set comp(playing) 0
    set analysis(waitForReadyOk$comp(move)) 1
    set analysis(waitForBestMove$comp(move)) 1
}

proc compGameEnd {} {
    global analysis comp
 
    puts_ compGameEnd

    set comp(playing) 0
    set analysis(waitForReadyOk$comp(move)) 1
    set analysis(waitForBestMove$comp(move)) 1
}

proc compAbort {} {
    # Close all games, called when game is active
    global analysis comp

    puts_ compAbort
    set comp(playing) 0
    set comp(games) {}

    catch {
      set analysis(waitForReadyOk$comp(move)) 1
      set analysis(waitForBestMove$comp(move)) 1
    }
}

proc compClose {} {
    # Close all games,  called when game is inactive
    global analysis comp

    puts_ compClose
    compDestroy
}

proc compDestroy {} {
    global comp

    ### there's some ttk bug when destroying widget, but havent found it yet
    # ttk::combobox seems to need destroying
    # for {set i 0} {$i < $comp(countcombos)} {incr i} {
    # must unbind .comp Destroy
    # destroy  .comp.engines.list.$i
    # }

    set comp(iconize) 0
    set comp(games) {}
    set comp(playing) 0
    bind .comp <Destroy> {}
    update idletasks
    destroy .comp
}

###
### End of file: comp.tcl
###
