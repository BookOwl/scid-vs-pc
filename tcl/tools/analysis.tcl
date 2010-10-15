### Analysis window: uses a chess engine to analyze the board.
###
### analysis.tcl: part of Scid.
### Copyright (C) 1999-2003  Shane Hudson.
### Copyright (C) 2007  Pascal Georges

# Rewritten stevenaaus July 2009
# String optimisations Dec  2009
# Overhauled again     May  2010
#
# Parts of this widget had a
# very bad procedural flow, which hopefully makes some sense
# now. Anyway, i have removed all sorting functionality, and
# added a configurable "Hot Key" feature Also swapped around
# the finish_{on,off} graphics, which were erroneous.
#
# I'm not sure about the status of annotateModeButton..
# but the auto finish mode now exists on all engines, instead of just #1
# Number of engines running at one time is now not limited

# analysis(logMax):
#   The maximum number of log message lines to be saved in a log file.
set analysis(logMax) 5000

# analysis(log_stdout):
#   Set this to 1 if you want Scid-Engine communication log messages
#   to be echoed to stdout.
#
set analysis(log_stdout) 0

set useAnalysisBook 1
set analysisBookSlot 1
set useAnalysisBookName ""
set wentOutOfBook 0

set isBatch 0
set batchEnd 1
set isBatchOpening 0
set isBatchOpeningMoves 12
set stack ""

set markTacticalExercises 1

################################################################################
# The different threshold values for !? ?? += etc
array set informant {}
set informant("!?") 0.5
set informant("?") 1.5
set informant("??") 3.0
set informant("?!") 0.5
set informant("+=") 0.5
set informant("+/-") 1.5
set informant("+-") 3.0
set informant("++-") 5.5

################################################################################
# resetEngine:
#   Reset all engine-specific data.
################################################################################

proc resetEngines {} {
  for {set i 1} {$i <= [llength $::engines(list)]} {incr i} {
    if {[winfo exists .analysisWin$i]} {
      resetEngine $i
    }
  }
}

proc resetEngine {n} {
  global analysis
  set analysis(pipe$n) {}             ;# Communication pipe file channel
  set analysis(seen$n) 0              ;# Seen any output from engine yet?
  set analysis(seenEval$n) 0          ;# Seen evaluation line yet?
  set analysis(score$n) 0             ;# Current score in centipawns
  set analysis(prevscore$n) 0         ;# Immediately previous score in centipawns
  set analysis(prevmoves$n) {}        ;# Immediately previous best line out from engine
  set analysis(nodes$n) 0             ;# Number of (kilo)nodes searched
  set analysis(depth$n) 0             ;# Depth in ply
  set analysis(prev_depth$n) 0        ;# Previous depth
  set analysis(time$n) 0              ;# Time in centisec (or sec; see below)
  set analysis(moves$n) {}            ;# PV (best line) output from engine
  set analysis(seldepth$n) 0
  set analysis(currmove$n) {}         ;# current move output from engine
  set analysis(currmovenumber$n) 0    ;# current move number output from engine
  set analysis(hashfull$n) 0
  set analysis(nps$n) 0
  set analysis(tbhits$n) 0
  set analysis(sbhits$n) 0
  set analysis(cpuload$n) 0
  set analysis(movelist$n) {}         ;# Moves to reach current position
  set analysis(nonStdStart$n) 0       ;# Game has non-standard start
  set analysis(has_analyze$n) 0       ;# Engine has analyze command
  set analysis(has_setboard$n) 0      ;# Engine has setboard command
  set analysis(send_sigint$n) 0       ;# Engine wants INT signal
  set analysis(wants_usermove$n) 0    ;# Engine wants "usermove" before moves
  set analysis(isCrafty$n) 0          ;# Engine appears to be Crafty
  set analysis(wholeSeconds$n) 0      ;# Engine times in seconds not centisec
  set analysis(analyzeMode$n) 0       ;# Scid has started analyze mode
  set analysis(invertScore$n) 1       ;# Score is for side to move, not white
  set analysis(automove$n) 0
  set analysis(automoveThinking$n) 0
  set analysis(automoveTime$n) 4000
  set analysis(lastClicks$n) 0
  set analysis(after$n) {}
  set analysis(log$n) {}              ;# Log file channel
  set analysis(logCount$n) 0          ;# Number of lines sent to log file
  set analysis(wbEngineDetected$n) 0  ;# Is this a special Winboard engine?
  set analysis(priority$n) normal     ;# CPU priority: idle/normal
  set analysis(multiPV$n) {}          ;# multiPV list sorted : depth score moves
  set analysis(multiPVraw$n) {}       ;# same thing but with raw UCI moves
  set analysis(uci$n) 0               ;# UCI engine
  # UCI engine options in format ( name min max ). This is not engine config but its capabilities
  set analysis(uciOptions$n) {}
  # the number of lines in multiPV. If =1 then act the traditional way
  set analysis(multiPVCount$n) 4      ;# number of N-best lines
  set analysis(index$n) 0             ;# the index of engine in engine list
  set analysis(uciok$n) 0             ;# uciok sent by engine in response to uci command
  set analysis(name$n) {}             ;# engine name
  set analysis(processInput$n) 0      ;# the time of the last processed event
  set analysis(waitForBestMove$n) 0
  set analysis(waitForReadyOk$n) 0
  set analysis(waitForUciOk$n) 0
  set analysis(movesDisplay$n) 1      ;# if false, hide engine lines, only display scores
  set analysis(lastHistory$n) {}      ;# last best line
  set analysis(maxmovenumber$n) 0     ;# the number of moves in this position
  set analysis(lockEngine$n) 0        ;# the engine is locked to current position
  set analysis(fen$n) {}              ;# the position that engine is analyzing
}

resetEngines

set annotateMode 0		; # $n of engine annotating
set annotateModeButtonValue 0	; # annotate checkbutton value

set annotateMoves all
set annotateBlunders blundersonly

################################################################################
# calculateNodes:
#   Divides string-represented node count by 1000
################################################################################
proc calculateNodes {{n}} {
  set len [string length $n]
  if { $len < 4 } {
    return 0
  } else {
    set shortn [string range $n 0 [expr {$len - 4}]]
    scan $shortn %d nd
    return $nd
  }
}


# resetAnalysis:
#   Resets the analysis statistics: score, depth, etc.
#
proc resetAnalysis {{n 1}} {
  global analysis
  set analysis(score$n) 0
  set analysis(scoremate$n) 0
  set analysis(nodes$n) 0
  set analysis(prev_depth$n) 0
  set analysis(depth$n) 0
  set analysis(time$n) 0
  set analysis(moves$n) {}
  set analysis(multiPV$n) {}
  set analysis(multiPVraw$n) {}
  set analysis(lastHistory$n) {}
  set analysis(maxmovenumber$n) 0
}

namespace eval enginelist {}

set engines(list) {}

# engine:
#   Global procedure to add an engine to the engine list.
#   Called from the "engines.dat" configuration file
#
proc engine {arglist} {
  global engines
  array set newEngine {}
  foreach {attr value} $arglist {
    set newEngine($attr) $value
  }
  # Check that required attributes exist:
  if {! [info exists newEngine(Name)] || 
      ! [info exists newEngine(Cmd)]  || 
      ! [info exists newEngine(Dir)]} { return  0 }
  # Fill in optional attributes:
  if {! [info exists newEngine(Args)]} { set newEngine(Args) {} }
  if {! [info exists newEngine(Elo)]} { set newEngine(Elo) 0 }
  if {! [info exists newEngine(Time)]} { set newEngine(Time) 0 }
  if {! [info exists newEngine(URL)]} { set newEngine(URL) {} }
  # puts this option here for compatibility with previous file format (?!)
  if {! [info exists newEngine(UCI)]} { set newEngine(UCI) 0 }
  if {! [info exists newEngine(UCIoptions)]} { set newEngine(UCIoptions) {} }

  lappend engines(list) [list $newEngine(Name) $newEngine(Cmd) \
      $newEngine(Args) $newEngine(Dir) \
      $newEngine(Elo) $newEngine(Time) \
      $newEngine(URL) $newEngine(UCI) $newEngine(UCIoptions)]
  return 1
}

# ::enginelist::read
#   Reads the user Engine list file.

proc ::enginelist::read {} {
  catch {source [scidConfigFile engines]}
}

# ::enginelist::write:
#   Writes the user Engine list file.

proc ::enginelist::write {} {
  global engines ::uci::newOptions scidUserDir scidShareDir

  set enginesFile [scidConfigFile engines]
  set enginesBackupFile [scidConfigFile engines.bak]
  # Try to rename old file to backup file and open new file:
  catch {file rename -force $enginesFile $enginesBackupFile}
  if {[catch {open $enginesFile w} f]} {
    catch {file rename $enginesBackupFile $enginesFile}
    return 0
  }

  puts $f "\# Analysis engines list file for Scid [sc_info version] with UCI support"
  puts $f {}
  foreach e $engines(list) {
    set name [lindex $e 0]
    set cmd [lindex $e 1]
    set args [lindex $e 2]
    set dir [lindex $e 3]
    set elo [lindex $e 4]
    set time [lindex $e 5]
    set url [lindex $e 6]
    set uci [lindex $e 7]
    set opt [lindex $e 8]
    puts $f "engine {"
      puts $f "  Name [list $name]"
      puts $f "  Cmd  [list $cmd]"
      puts $f "  Args [list $args]"
      puts $f "  Dir  [list $dir]"
      puts $f "  Elo  [list $elo]"
      puts $f "  Time [list $time]"
      puts $f "  URL  [list $url]"
      puts $f "  UCI [list $uci]"
      puts $f "  UCIoptions [list $opt]"
      puts $f "}"
    puts $f {}
  }
  close $f
  return 1
}

# Read the user Engine List file now:

catch { ::enginelist::read }
if {[llength $engines(list)] == 0} {
  # No engines, so set up a default engine list with Scidlet, Toga and Phalanx

  ### scidlet

  if {$::windowsOS} { set cmd [file join $::scidExeDir scidlet.exe]
  } else { set cmd scidlet }

  engine "Name Scidlet
          Cmd  $cmd
          Dir  ."

  ### toga

  engine "Name Toga
          Cmd  fruit
          Dir  $scidUserDir
          UCI  1"

  ### phalanx
  # use "Cmd phalanx -g /tmp/phalanx_logfile" for debugging

  engine "Name Phalanx
          Cmd  phalanx
          Dir  $scidUserDir"

}

# ::enginelist::date
#   Given a time in seconds since 1970, returns a formatted date string.
#
proc ::enginelist::date {time} {
  return [clock format $time -format "%d-%b-%Y %H:%M"]
}

proc ::enginelist::listEngines {{focus 0}} {
  global engines

  set w .enginelist
  if {! [winfo exists $w]} { return }
  set f $w.list.list
  $f delete 0 end
  set count 0
  foreach engine $engines(list) {
    incr count
    set name [lindex $engine 0]
    set elo  [lindex $engine 4]
    set time [lindex $engine 5]
    set uci  [lindex $engine 7]
    set date [::enginelist::date $time]
    set text [format "%-19s " $name]
    set eloText "    "
    if {$elo > 0} { set eloText [format "%4u" $elo] }
    append text $eloText

    # display any hot key bindings
    if {$engines(F2) == $count} {
      append text "  F2 "
    } elseif {$engines(F3) == $count} {
      append text "  F3 "
    } elseif {$engines(F4) == $count} {
      append text "  F4 "
    } else {
      append text "     "
    }

    set timeText "  "
    if {$time > 0} { set timeText "  $date" }
    append text $timeText
    $f insert end $text
  }
  $f selection set $focus

  $w.title configure -state normal
  foreach i {Name Elo Time} {
    $w.title tag configure $i -font font_Fixed -foreground {}
  }
  $w.title configure -state disabled
}

################################################################################
#   Configure chess engines
#   rewritten by S.A. July 7 2009  (and beyond :>)
################################################################################
proc ::enginelist::choose {} {
  global engines
  set w .enginelist

  if { [winfo exists $w] } { destroy $w }

  toplevel $w
  setWinLocation $w
  setWinSize $w

  wm title $w "Scid: [tr ToolsAnalysis]"
  wm protocol $w WM_DELETE_WINDOW "destroy $w"
  bind $w <F1> { helpWindow Analysis List }
  bind $w <Escape> "destroy $w"
  bind $w <F2> "startAnalysisWin F2"
  bind $w <F3> "startAnalysisWin F3"
  bind $w <F4> "startAnalysisWin F4"

  label $w.flabel -text $::tr(EngineList) -font font_Large
  pack $w.flabel -side top -pady 5

  frame $w.buttons

  text $w.title -width 50 -height 1 -font font_Fixed -relief flat \
      -cursor top_left_arrow -background gray95

  $w.title insert end $::tr(EngineName) Name
  for {set i [string length $::tr(EngineName)]} {$i < 19} { incr i } {
    $w.title insert end " "
  }
  $w.title insert end "  "

  $w.title insert end $::tr(EngineElo) Elo
  for {set i [string length $::tr(EngineElo)]} {$i < 4} { incr i } {
    $w.title insert end " "
  }

  $w.title insert end " Key "
  $w.title insert end "         "
  $w.title insert end "$::tr(EngineTime)" Time
  $w.title configure -state disabled
  pack $w.title -side top -fill x

  ### list of engines

  pack [frame $w.list -relief flat -borderwidth 0] \
    -side top -expand yes -fill both -padx 4 -pady 3

  listbox $w.list.list -height 10 -selectmode browse -setgrid 1 \
      -yscrollcommand "$w.list.ybar set" -font font_Fixed -exportselection 0 ; # -bg text_bg_color

  bind $w.list.list <Double-ButtonRelease-1> "$w.buttons.start invoke; break"
  scrollbar $w.list.ybar -command "$w.list.list yview"

  pack $w.list.ybar -side right -fill y
  pack $w.list.list -side top -fill both -expand yes
  $w.list.list selection set 0

  dialogbutton $w.buttons.add -text $::tr(EngineNew) -command {::enginelist::edit -1}

  dialogbutton $w.buttons.edit -text $::tr(EngineEdit) -command {
    ::enginelist::edit [lindex [.enginelist.list.list curselection] 0]
  }

  dialogbutton $w.buttons.delete -text $::tr(Delete) -command {
    ::enginelist::delete [lindex [.enginelist.list.list curselection] 0]
  }

  label $w.buttons.sep -text "   "

  dialogbutton $w.buttons.start -text $::tr(Start) -command {
    makeAnalysisWin [expr [lindex [.enginelist.list.list curselection] 0] + 1]
  }

  dialogbutton $w.close -textvar ::tr(Close) -command {
    destroy .enginelist
  }

  pack $w.buttons.add $w.buttons.edit $w.buttons.delete $w.buttons.start -side left -expand yes
  pack $w.buttons -side top -pady 12 -padx 2 -fill x
  pack $w.close -side bottom -pady 8
  focus $w.buttons.start

  ::enginelist::listEngines
  update
  bind $w <Configure> "recordWinSize $w"
}

# ::enginelist::setTime
#   Sets the last-opened time of the engine specified by its
#   index in the engines(list) list variable.
#   The time should be in standard format (seconds since 1970)
#   and defaults to the current time.
# God knows why this date is always updated, but left in for the moment S.A

proc ::enginelist::setTime {index {time -1}} {
  global engines
  set e [lindex $engines(list) $index]
  if {$time < 0} { set time [clock seconds] }
  set e [lreplace $e 5 5 $time]
  set engines(list) [lreplace $engines(list) $index $index $e]
}

trace variable engines(newElo) w [list ::utils::validate::Integer [sc_info limit elo] 0]

# ::enginelist::delete
#   Removes an engine from the list.
#
proc ::enginelist::delete {index} {
  global engines
  if {$index == ""  ||  $index < 0} { return }
  set e [lindex $engines(list) $index]
  set msg "Name: [lindex $e 0]
Command: [lindex $e 1]\n
Confirm delete engine\n"
  set answer [tk_messageBox -title Scid -icon question -type okcancel \
      -message $msg -parent .enginelist]
  if {$answer == "ok"} {
    set engines(list) [lreplace $engines(list) $index $index]
    ::enginelist::listEngines
    ::enginelist::write
  }
}

# ::enginelist::edit
#   Opens a dialog for editing an existing engine list entry (if
#   index >= 0), or adding a new entry (if index is -1).
#

proc ::enginelist::edit {index} {
  global engines

  set w .engineEdit
  if {$index == ""} { return }
  if {[winfo exists $w]} {
    raiseWin $w
    return
  }


  if {$index >= 0  ||  $index >= [llength $engines(list)]} {
    set e [lindex $engines(list) $index]
  } else {
    set e [list "" "" "" . 0 0 "" 1]
  }

  set engines(newIndex) $index
  set engines(newName)	[lindex $e 0]
  set engines(newCmd)	[lindex $e 1]
  set engines(newArgs)	[lindex $e 2]
  set engines(newDir)	[lindex $e 3]
  set engines(newElo)	[lindex $e 4]
  set engines(newTime)	[lindex $e 5]
  set engines(newURL)	[lindex $e 6]
  set engines(newUCI)	[lindex $e 7]
  set engines(newUCIoptions) [lindex $e 8]

  set engines(newDate) $::tr(None)
  if {$engines(newTime) > 0 } {
    set engines(newDate) [::enginelist::date $engines(newTime)]
  }

  toplevel $w
  wm title $w {Scid: Configure Engine}
  wm state $w withdrawn

  set f [frame $w.frame]
  pack $f -side top -fill x -expand yes -padx 3 -pady 7
  set row 0
  foreach i {Name Cmd Dir Args URL} {
    label $f.l$i -text $i
    if {[info exists ::tr(Engine$i)]} {
      $f.l$i configure -text $::tr(Engine$i)
    }
    entry $f.e$i -textvariable engines(new$i) -width 22
    bindFocusColors $f.e$i
    grid $f.l$i -row $row -column 0 -sticky w -pady 1 -padx 3
    grid $f.e$i -row $row -column 1 -sticky we -pady 1 -padx 3

    # Browse button for choosing an executable file:
    if {$i == "Cmd"} {
      button $f.b$i -text Browse... -command {
        if {$::windowsOS} {
          set scid_temp(filetype) {
            {"Applications" {".bat" ".exe"} }
            {"All files" {"*"} }
          }
        } else {
          set scid_temp(filetype) {
            {"All files" {"*"} }
          }
        }
        set scid_temp(cmd) [tk_getOpenFile -initialdir $engines(newDir) -parent .engineEdit \
            -title "Scid: Select Executable" -filetypes $scid_temp(filetype)]
        if {$scid_temp(cmd) != ""} {
          set engines(newCmd) $scid_temp(cmd)
          # if {[string first " " $scid_temp(cmd)] >= 0} {
          # The command contains spaces, so put it in quotes:
          # set engines(newCmd) "\"$scid_temp(cmd)\""
          # }
          # Set the directory from the executable path if possible:
          set engines(newDir) [file dirname $scid_temp(cmd)]
          if {$engines(newDir) == ""} [ set engines(newDir) .]
        }
      }
      grid $f.b$i -row $row -column 2 -sticky we -pady 1 -padx 3
    }

    if {$i == "Dir"} {
      button $f.current -text " . " -command {
        set engines(newDir) .
      }
      button $f.user -text "~/.scidvspc" -command {
        set engines(newDir) $scidUserDir
      }
      if {$::windowsOS} {
        $f.user configure -text "scid.exe dir"
      }
      grid $f.current -row $row -column 2 -sticky we -pady 1 -padx 3
      grid $f.user -row $row -column 3 -sticky we -pady 1 -padx 3
    }

    if {$i == "URL"} {
      $f.l$i configure -text Webpage
      button $f.bURL -text [tr FileOpen] -command {
        if {$engines(newURL) != ""} { openURL $engines(newURL) }
      }
      grid $f.bURL -row $row -column 2 -sticky we -pady 1 -padx 3
    }

    incr row
  }

  grid columnconfigure $f 1 -weight 1

  label $f.lUCI -text Protocol
  frame $f.rb
  radiobutton $f.rb.uci -variable engines(newUCI) -value 1 -text UCI \
    -command "checkState ::engines(newUCI) $f.bUCI"
  radiobutton $f.rb.xboard -variable engines(newUCI) -value 0 -text Xboard \
    -command "checkState ::engines(newUCI) $f.bUCI"
  pack $f.rb.uci -side left
  pack $f.rb.xboard -side right
  button $f.bUCI -text Configure -command {
    ::uci::uciConfig 2 [toAbsPath $engines(newCmd)] $engines(newArgs) \
                       [toAbsPath $engines(newDir)] $engines(newUCIoptions)
  }
  checkState ::engines(newUCI) $f.bUCI

  # Mark required fields:
  $f.lName configure -font font_Bold
  $f.lCmd configure -font font_Bold
  $f.lDir configure -font font_Bold
  # $f.lUCI configure -font font_Bold

  label $f.lElo -text $::tr(EngineElo)
  entry $f.eElo -textvariable engines(newElo) -width 22
  bindFocusColors $f.eElo
  grid $f.lElo -row $row -column 0 -sticky w -pady 1 -padx 3
  grid $f.eElo -row $row -column 1 -sticky we -pady 1 -padx 3

  incr row
  grid $f.lUCI -row $row -column 0 -sticky w -pady 1 -padx 3
  grid $f.rb   -row $row -column 1 -sticky w -pady 1 -padx 3
  grid $f.bUCI -row $row -column 2 -sticky w -pady 1 -padx 3
  incr row

  label $f.lTime -text $::tr(EngineTime)
  label $f.eTime -textvariable engines(newDate) -anchor w -width 1
  grid $f.lTime -row $row -column 0 -sticky w -pady 1 -padx 3
  grid $f.eTime -row $row -column 1 -sticky we -pady 1 -padx 3
  button $f.clearTime -text $::tr(Clear) -command {
    set engines(newTime) 0
    set engines(newDate) $::tr(None)
  }
  button $f.nowTime -text $::tr(Update) -command {
    set engines(newTime) [clock seconds]
    set engines(newDate) [::enginelist::date $engines(newTime)]
  }
  grid $f.clearTime -row $row -column 2 -sticky we -pady 1 -padx 3
  grid $f.nowTime -row $row -column 3 -sticky we -pady 1 -padx 3

  frame $w.radio
  label $w.radio.label -text {Hot Key}
  radiobutton $w.radio.f2	-text F2 -variable hotkey -value F2
  radiobutton $w.radio.f3	-text F3 -variable hotkey -value F3
  radiobutton $w.radio.f4	-text F4 -variable hotkey -value F4
  radiobutton $w.radio.none	-text none -variable hotkey -value none
  # have to use "none" instead of "" to stop radio button ghosting bug

  $w.radio.none select
  if {$engines(F2) == [expr $engines(newIndex) + 1]} {$w.radio.f2 select} 
  if {$engines(F3) == [expr $engines(newIndex) + 1]} {$w.radio.f3 select}
  if {$engines(F4) == [expr $engines(newIndex) + 1]} {$w.radio.f4 select}

  pack $w.radio -side top -anchor w
  pack $w.radio.label -side left
  pack $w.radio.f2 $w.radio.f3 $w.radio.f4 $w.radio.none -side left -padx 5

  pack [label $w.required -font font_Small -text $::tr(EngineRequired)] -side top

  addHorizontalRule $w
  set f [frame $w.buttons]
  dialogbutton $f.ok -text OK -command {
    # remove trailing spaces
    foreach i {newName newCmd newArgs newDir newElo newTime newURL newUCI} {
      set engines($i) [string trim $engines($i)]
    }
    if { $engines(newElo) == "" } { set engines(newElo) 0 }
    if {$engines(newName) == "" || $engines(newCmd) == "" || $engines(newDir) == ""} {
      tk_messageBox -title Scid -icon info -parent .engineEdit \
        -message "The Name, Command and Directory fields must not be empty."
    } else {
      set newEntry [list $engines(newName) $engines(newCmd) \
        $engines(newArgs) $engines(newDir) \
          $engines(newElo) $engines(newTime) \
          $engines(newURL) $engines(newUCI) $::uci::newOptions ]

      set index [expr $engines(newIndex) + 1]

      # just disable first in case of multiple selection
      if {$engines(F2) == $index} {set engines(F2) {}}
      if {$engines(F3) == $index} {set engines(F3) {}}
      if {$engines(F4) == $index} {set engines(F4) {}}
      if { $hotkey == "F2" || $hotkey == "F3" || $hotkey == "F4" } {
        # hotkey either F2 or F3 or F4
        set engines($hotkey) $index
      }

      if {$engines(newIndex) < 0} {
        lappend engines(list) $newEntry
      } else {
        set engines(list) [lreplace $engines(list) \
            $engines(newIndex) $engines(newIndex) $newEntry]
      }
      destroy .engineEdit
      ::enginelist::listEngines $engines(newIndex)
      ::enginelist::write
    }
  }
  dialogbutton $f.help -text $::tr(Help) -command {helpWindow Analysis List}
  dialogbutton $f.cancel -text $::tr(Cancel) -command "destroy $w"
  pack $f -side bottom
  pack $f.cancel -side right -padx 20 -pady 5
  pack $f.help -side right -padx 20 -pady 5
  pack $f.ok -side left -padx 20 -pady 5

  bind $w <Return> "$f.ok invoke"
  bind $w <Escape> "destroy $w"
  bind $w <F1> { helpWindow Analysis List }
  # focus $w.f.eName

  placeWinOverParent $w .enginelist
  wm state $w normal
  # bind $w <Configure> "recordWinSize $w"
  # wm resizable $w 1 0
  # catch {grab $w}
}

proc  checkState {arg widget} {
     if {[set $arg]} {
       set state normal
     } else {
       set state disabled
     }
     $widget configure -state $state
}

################################################################################
# Annotation configuration widget
################################################################################
proc initAnnotation {n} {
  global autoplayDelay tempdelay blunderThreshold annotateModeButtonValue annotateMode analysis

  set w .configAnnotation
  if { [winfo exists $w] } { destroy $w }
  if { ! $annotateModeButtonValue } { ; # end annotation
    toggleAutoplay
    return
  }

  trace variable blunderThreshold w {::utils::validate::Regexp {^[0-9]*\.?[0-9]*$}}

  set tempdelay [expr {$autoplayDelay / 1000.0}]
  toplevel $w
  wm state $w withdrawn
  wm title $w "Configure Annotation"

  ### Move delay frame

  frame $w.delay
  pack $w.delay -side top -padx 15 -pady 5 -fill x

  label $w.delay.label -text $::tr(AnnotateTime)
  spinbox $w.delay.spDelay -width 4 -textvariable tempdelay -from 1 -to 300 -increment 1
  pack $w.delay.label -side left -padx 2 -pady 5
  pack $w.delay.spDelay -side left -padx 2 -pady 5
  bind $w <Escape> { .configAnnotation.buttons.cancel invoke }
  bind $w <Return> { .configAnnotation.buttons.ok invoke }

  ### Add variations frame

  addHorizontalRule $w
  label $w.avlabel -text $::tr(AnnotateWhich...)
  radiobutton $w.all -text $::tr(AnnotateAll) -variable annotateMoves -value all -anchor w
  radiobutton $w.white -text $::tr(AnnotateWhite) -variable annotateMoves -value white -anchor w
  radiobutton $w.black -text $::tr(AnnotateBlack) -variable annotateMoves -value black -anchor w

  pack $w.avlabel -side top
  pack $w.all $w.white $w.black -side top -fill x
  addHorizontalRule $w

  ### Annotate frame

  label $w.anlabel -text $::tr(Annotate...)
  radiobutton $w.allmoves -text $::tr(AnnotateAllMoves) -variable annotateBlunders -value allmoves -anchor w 
  radiobutton $w.notbest -text $::tr(AnnotateNotBest) -variable annotateBlunders -value notbest -anchor w
  radiobutton $w.blundersonly -text $::tr(AnnotateBlundersOnly) \
    -variable annotateBlunders -value blundersonly -anchor w

  frame $w.blunderbox

  label $w.blunderbox.label -text "$::tr(Blunder) $::tr(BlundersThreshold)"
  spinbox $w.blunderbox.spBlunder -width 4 -textvariable blunderThreshold \
      -from 0.1 -to 3.0 -increment 0.1

  pack $w.anlabel -side top
  pack $w.allmoves $w.notbest $w.blundersonly -side top -fill x
  pack $w.blunderbox -side top -padx 10 -fill x
  pack $w.blunderbox.label $w.blunderbox.spBlunder -side left -padx 5
  addHorizontalRule $w

  ### General options frame

  checkbutton $w.cbAnnotateVar  -text $::tr(AnnotateVariations) -variable ::isAnnotateVar -anchor w
  checkbutton $w.cbShortAnnotation  -text $::tr(ShortAnnotations) -variable ::isShortAnnotation -anchor w
  checkbutton $w.cbAddScore  -text $::tr(AddScoreToShortAnnotations) -variable ::addScoreToShortAnnotations -anchor w
  checkbutton $w.cbAddAnnotatorTag  -text $::tr(addAnnotatorTag) -variable ::addAnnotatorTag -anchor w
  pack $w.cbAnnotateVar $w.cbShortAnnotation $w.cbAddScore $w.cbAddAnnotatorTag -anchor w

  # choose a book for analysis

  frame $w.usebook
  pack  $w.usebook -side top -fill x

  checkbutton $w.usebook.cbBook  -text $::tr(UseBook) -variable ::useAnalysisBook \
    -command "checkState ::useAnalysisBook $w.usebook.comboBooks"

  # load book names
  set bookPath $::scidBooksDir
  set bookList [ lsort -dictionary [ glob -nocomplain -directory $bookPath *.bin ] ]

  if { [llength $bookList] == 0 } {
      set ::useAnalysisBook 0
      $w.usebook.cbBook configure -state disabled
  }

  set tmp {}
  set idx 0
  set i 0
  foreach file  $bookList {
      lappend tmp [ file tail $file ]
      if {$::book::lastBook == [ file tail $file ] } {
	  set idx $i
      }
      incr i
  }

  ttk::combobox $w.usebook.comboBooks -width 12 -values $tmp
  catch { $w.usebook.comboBooks current $idx }
  checkState ::useAnalysisBook $w.usebook.comboBooks
  pack $w.usebook.cbBook -side left -padx 4
  pack $w.usebook.comboBooks -side left -padx 4

  # batch annotation of consecutive games, and optional opening errors finder
  frame $w.batch
  pack $w.batch -side top -fill x
  set to [sc_base numGames]
  if {$to <1} { set to 1}
  checkbutton $w.batch.cbBatch -text $::tr(AnnotateSeveralGames) -variable ::isBatch \
    -command "checkState ::isBatch $w.batch.spBatchEnd"

  spinbox $w.batch.spBatchEnd -width 6 -textvariable ::batchEnd \
      -from 1 -to $to -increment 1 -validate all -vcmd { regexp {^[0-9]+$} %P }

  checkState ::isBatch $w.batch.spBatchEnd

  checkbutton $w.batch.cbBatchOpening -text $::tr(FindOpeningErrors) -variable ::isBatchOpening \
     -command "checkState ::isBatchOpening $w.batch.spBatchOpening"

  spinbox $w.batch.spBatchOpening -width 2 -textvariable ::isBatchOpeningMoves \
      -from 10 -to 20 -increment 1 -validate all -vcmd { regexp {^[0-9]+$} %P }

  checkState ::isBatchOpening $w.batch.spBatchOpening

  label $w.batch.lBatchOpening -text $::tr(moves)
  # pack $w.batch.cbBatch $w.batch.spBatchEnd -side top -fill x
  # pack $w.batch.cbBatchOpening $w.batch.spBatchOpening $w.batch.lBatchOpening  -side left -fill x
  grid $w.batch.cbBatch -column 0 -row 0 -sticky w
  grid $w.batch.spBatchEnd -column 1 -row 0 -columnspan 2
  grid $w.batch.cbBatchOpening -column 0 -row 1 -sticky w
  grid $w.batch.spBatchOpening -column 1 -row 1 -sticky e -padx 2
  grid $w.batch.lBatchOpening -column 2 -row 1 -sticky w
  set ::batchEnd $to

  checkbutton $w.batch.cbMarkTactics -text $::tr(MarkTacticalExercises) -variable ::markTacticalExercises
  grid $w.batch.cbMarkTactics -column 0 -row 2 -sticky w
  if {! $::analysis(uci$n)} {
    set ::markTacticalExercises 0
    $w.batch.cbMarkTactics configure -state disabled
  }

  addHorizontalRule $w
  frame $w.buttons
  pack $w.buttons -side top -fill x
  dialogbutton $w.buttons.cancel -text $::tr(Cancel) -command {
    bind .configAnnotation <Destroy> {}
    destroy .configAnnotation
    set annotateMode 0
    set annotateModeButtonValue 0
  }
  dialogbutton $w.buttons.help -text $::tr(Help) -command {helpWindow Analysis Annotating}
  dialogbutton $w.buttons.ok -text "OK" -command "okAnnotation $n"

    pack $w.buttons.cancel $w.buttons.help $w.buttons.ok -side right -padx 5 -pady 5
    # focus $w.delay.spDelay

    bind $w <Destroy> "$w.buttons.cancel invoke"
    placeWinOverParent $w .analysisWin$n
    wm state $w normal
    update
}

################################################################################
# Start Annotation
################################################################################
proc okAnnotation {n} {
  global autoplayDelay tempdelay annotateMode analysis autoplayMode

  if {$annotateMode} {
    puts stderr "Scid: initAnnotation reports engine $annotateMode already annotating"
    return
  }
  set ::useAnalysisBookName [.configAnnotation.usebook.comboBooks get]
  set ::wentOutOfBook 0
  set ::book::lastBook $::useAnalysisBookName

  # tactical positions is selected, must be in multipv mode
  if {$::markTacticalExercises} {
    if { $::analysis(multiPVCount$n) < 2} {
      set ::analysis(multiPVCount$n) 4
      changePVSize $n
    }
  }

  if {$tempdelay < 0.1} { set tempdelay 0.1 }
  set autoplayDelay [expr {int($tempdelay * 1000)}]
  bind .configAnnotation <Destroy> {}
  destroy .configAnnotation
  set annotateMode $n
  if {! $analysis(analyzeMode$n)} {
    toggleEngineAnalysis $n 1
  }
  if {$::addAnnotatorTag} {
    appendAnnotator "$analysis(name$n)"
  }
  if {$autoplayMode == 0} { toggleAutoplay }
}

################################################################################
# Part of annotation process : will check the moves if they are in the book,
# and add a comment when going out of it
################################################################################
proc bookAnnotation { {n 1} } {
  global analysis

  if {$::annotateMode && $::useAnalysisBook} {

    set prevbookmoves {}
    set bn [ file join $::scidBooksDir $::useAnalysisBookName ]
    sc_book load $bn $::analysisBookSlot

    set bookmoves [sc_book moves $::analysisBookSlot]
    while {[string length $bookmoves] != 0 && ![sc_pos isAt vend]} {
      # we are in book, so move immediately forward
      ::move::Forward
      set prevbookmoves $bookmoves
      set bookmoves [sc_book moves $::analysisBookSlot]
    }
    sc_book close $::analysisBookSlot
    set ::wentOutOfBook 1

    set verboseMoveOutOfBook {}
    set verboseLastBookMove {}
    if {! $::isShortAnnotation } {
      set verboseMoveOutOfBook " $::tr(MoveOutOfBook)"
      set verboseLastBookMove " $::tr(LastBookMove)"
    }

    if { [ string match -nocase "*[sc_game info previousMoveNT]*" $prevbookmoves ] != 1 } {
      if {$prevbookmoves != {}} {
        sc_pos setComment "[sc_pos getComment]$verboseMoveOutOfBook ($prevbookmoves)"
      } else  {
        sc_pos setComment "[sc_pos getComment]$verboseMoveOutOfBook"
      }
    } else  {
      sc_pos setComment "[sc_pos getComment]$verboseLastBookMove"
    }

    # last move was out of book or the last move in book : it needs to be analyzed, so take back
    if { ![catch { sc_move back 1 } ] } {
      resetAnalysis $n
      updateBoard -pgn
      for {set i 0} {$i<100} {incr i} { update ; after [expr $::autoplayDelay / 100] }
      set analysis(prevscore$n) $analysis(score$n)
      set analysis(prevmoves$n) $analysis(moves$n)
      updateBoard -pgn
    }
  }
}
################################################################################
# Will add **** to any position considered as a tactical shot
#
################################################################################
proc markExercise { prevscore score } {
  global annotateMode
  set n $annotateMode

  if {!$::markTacticalExercises} { return }

  # check at which depth the tactical shot is found
  # this assumes analysis by an UCI engine
  if {! $::analysis(uci$n)} { return }

  set deltamove [expr {$score - $prevscore}]
  # filter tactics so only those with high gains are kept
  if { [expr abs($deltamove)] < $::informant("+/-") } { return }
  # dismiss games where the result is already clear (high score,and we continue in the same way)
  if { [expr $prevscore * $score] >= 0} {
    if { [expr abs($prevscore) ] > $::informant("++-") } { return }
    if { [expr abs($prevscore)] > $::informant("+-") && [expr abs($score) ] < [expr 2 * abs($prevscore)]} { return }
  }

  # The best move is much better than others.
  if { [llength $::analysis(multiPV$n)] < 2 } {
    puts "error, not enough PV"
    return
  }
  set sc2 [lindex [ lindex $::analysis(multiPV$n) 1 ] 1]
  if { [expr abs( $score - $sc2 )] < 1.5 } { return }

  # There is no other winning moves (the best move may not win, of course, but
  # I reject exercises when there are e.g. moves leading to +9, +7 and +5 scores)
  if { [expr $score * $sc2] > 0.0 && [expr abs($score)] > $::informant("+-") && [expr abs($sc2)] > $::informant("+-") } {
    return
  }

  # The best move does not lose position.
  if {[sc_pos side] == {white} && $score < [expr 0.0 - $::informant("+/-")] } { return }
  if {[sc_pos side] == {black} && $score > $::informant("+/-") } { return }

  # Move is not obvious: check that it is not the first move guessed at low depths
  set pv [ lindex [ lindex $::analysis(multiPV$n) 0 ] 2 ]
  set bm0 [lindex $pv 0]
  foreach depth {1 2 3} {
    set res [ sc_pos analyze -time 1000 -hashkb 32 -pawnkb 1 -searchdepth $depth ]
    set bm$depth [lindex $res 1]
  }
  if { $bm0 == $bm1 && $bm0 == $bm2 && $bm0 == $bm3 } {
    puts "obvious move"
    return
  }

  # find what time is needed to get the solution (use internal analyze function)
  set timer {1 2 5 10 50 100 200 1000}
  # set scorelist {}
  set movelist {}
  for {set t 0} {$t < [llength $timer]} { incr t} {
    set res [sc_pos analyze -time [lindex $timer $t] -hashkb 1 -pawnkb 1 -mindepth 0]
    # set score_analyze [lindex $res 0]
    set move_analyze [lindex $res 1]
    # if {[sc_pos side] == "black"} { set score_analyze [expr 0.0 - $score_analyze] }
    # lappend scorelist $score_analyze
    lappend movelist $move_analyze
  }

  # find at what timing the right move was reliably found
  # only the move is checked, not if the score is close to the expected one
  for {set t [expr [llength $timer] -1]} {$t >= 0} { incr t -1} {
    if { [lindex $movelist $t] != $bm0 } {
      break
    }
  }

  set difficulty [expr $t +2]

  puts "flag T pour [sc_game number] difficulty $difficulty"
  sc_game flag T [sc_game number] 1
  sc_pos setComment "****D${difficulty} [format %.1f $prevscore]->[format %.1f $score] [sc_pos getComment]"
  updateBoard
}
################################################################################
#
################################################################################
proc addAnnotation {} {
  global analysis annotateMoves annotateBlunders annotateMode blunderThreshold

  set n $annotateMode
  if {!$n} {
    puts stderr "Scid: addAnnotation called while annotateMode is 0"
    return
  }
  # First look in the book selected
  if { ! $::wentOutOfBook && $::useAnalysisBook} {
    bookAnnotation
    return
  }

  # Cannot add a variation to an empty variation:
  if {[sc_pos isAt vstart]  &&  [sc_pos isAt vend]} { return }

  # Cannot (yet) add a variation at the end of the game or a variation:
  if {[sc_pos isAt vend]} { return }

  set tomove [sc_pos side]
  if {$annotateMoves == {white}  &&  $tomove == {white} ||
    $annotateMoves == {black}  &&  $tomove == {black} } {
    set analysis(prevscore$n) $analysis(score$n)
    set analysis(prevmoves$n) $analysis(moves$n)
    return
  }

  # to parse scores if the engine's name contains - or + chars (see sc_game_scores)
  set engine_name  [string map {- { } + { }} $analysis(name$n)]

  set text [format "%d:%+.2f" $analysis(depth$n) $analysis(score$n)]
  set moves $analysis(moves$n)

  # if next move is what engine guessed, do nothing
  if { $analysis(prevmoves$n) != {} && ![sc_pos isAt vend] && $annotateBlunders != {allmoves}} {
    set move2 [sc_game info previousMoveNT]

    sc_info preMoveCmd {}
    sc_game push copyfast
    set move1 [lindex $analysis(prevmoves$n) 0]
    sc_move back 1
    sc_move_add $move1 $n
    set move1 [sc_game info previousMoveNT]
    sc_game pop
    sc_info preMoveCmd preMoveCommand

    if {$move1 == $move2} {
      set analysis(prevscore$n) $analysis(score$n)
      set analysis(prevmoves$n) $analysis(moves$n)
      return
    }
  }

  # Temporarily clear the pre-move command since we want to add a
  # whole line without Scid updating stuff:
  sc_info preMoveCmd {}

  set score $analysis(score$n)
  set prevscore $analysis(prevscore$n)

  set deltamove [expr {$score - $prevscore}]
  set isBlunder 0
  if {$annotateBlunders == {blundersonly}} {
    if { $deltamove < [expr 0.0 - $blunderThreshold] && $tomove == {black} || \
          $deltamove > $blunderThreshold && $tomove == {white} } {
      set isBlunder 1
    }
    # if the game is dead, and the score continues to go down, don't add any comment
    if { $prevscore > $::informant("++-") && $tomove == {white} || \
          $prevscore < [expr 0.0 - $::informant("++-") ] && $tomove == {black} } {
      set isBlunder 0
    }
  } elseif {$annotateBlunders == {notbest}} { ; # not best move option
    if { $deltamove < 0.0 && $tomove == {black} || \
          $deltamove > 0.0 && $tomove == {white} } {
      set isBlunder 1
    }
  }

  set text [format "%+.2f" $score]
  if {$annotateBlunders == {allmoves}} {
    set absdeltamove [expr { abs($deltamove) } ]
    if { $deltamove < [expr 0.0 - $blunderThreshold] && $tomove == {black} || \
          $deltamove > $blunderThreshold && $tomove == {white} } {
      if {$absdeltamove > $::informant("?!") && $absdeltamove <= $::informant("?")} {
        sc_pos addNag "?!"
      } elseif {$absdeltamove > $::informant("?") && $absdeltamove <= $::informant("??")} {
        sc_pos addNag "?"
        markExercise $prevscore $score
      } elseif {$absdeltamove > $::informant("??") } {
        sc_pos addNag "??"
        markExercise $prevscore $score
      }
    }


    if {! $::isShortAnnotation } {
      sc_pos setComment "[sc_pos getComment] $engine_name: $text"
    } else {
      if {$::addScoreToShortAnnotations} {
        sc_pos setComment "[sc_pos getComment] $text"
      }
    }

    if {$::isBatchOpening} {
      if { [sc_pos moveNumber] < $::isBatchOpeningMoves} {
        appendAnnotator "opBlunder [sc_pos moveNumber] ([sc_pos side])"
        updateBoard -pgn
      }
    }
    set nag [ scoreToNag $score ]
    if {$nag != {}} {
      sc_pos addNag $nag
    }

    sc_move back
    if { $analysis(prevmoves$n) != {}} {
      sc_var create
      set moves $analysis(prevmoves$n)
      sc_move_add $moves $n
      set nag [ scoreToNag $prevscore ]
      if {$nag != {}} {
        sc_pos addNag $nag
      }
      sc_var exit
      sc_move forward
    }
  } elseif { $isBlunder } {
    # Add the comment to highlight the blunder
    set absdeltamove [expr { abs($deltamove) } ]

    # if the game was won and the score remains high, don't add comment
    if { $score > $::informant("++-") && $tomove == {black} || \
          $score < [expr 0.0 - $::informant("++-") ] && $tomove == {white} } {
      set text [format "%+.2f (%+.2f)" $prevscore $score]
      if {! $::isShortAnnotation } {
        sc_pos setComment "[sc_pos getComment] $engine_name: $text"
      }  else {
        if {$::addScoreToShortAnnotations} {
          sc_pos setComment "[sc_pos getComment] $text"
        }
      }
    } else  {
      if {$absdeltamove > $::informant("?!") && $absdeltamove <= $::informant("?")} {
        sc_pos addNag "?!"
      } elseif {$absdeltamove > $::informant("?") && $absdeltamove <= $::informant("??")} {
        sc_pos addNag "?"
        markExercise $prevscore $score
      } elseif {$absdeltamove > $::informant("??") } {
        sc_pos addNag "??"
        markExercise $prevscore $score
      }
      
      set text [format "%s %+.2f / %+.2f" $::tr(Blunder) $prevscore $score]
      if {! $::isShortAnnotation } {
        sc_pos setComment "[sc_pos getComment] $engine_name: $text"
      } else {
        if {$::addScoreToShortAnnotations} {
          sc_pos setComment "[sc_pos getComment] [format %+.2f $score]"
        }
      }
    }

    if {$::isBatchOpening} {
      if { [sc_pos moveNumber] < $::isBatchOpeningMoves} {
        appendAnnotator "opBlunder [sc_pos moveNumber] ([sc_pos side])"
        updateBoard -pgn
      }
    }
    set nag [ scoreToNag $score ]
    if {$nag != {}} {
      sc_pos addNag $nag
    }
    # Rewind, request a diagram
    sc_move back
    sc_pos addNag D

    # Add the variation:
    if { $analysis(prevmoves$n) != {}} {
      sc_var create
      set moves $analysis(prevmoves$n)
      # Add as many moves as possible from the engine analysis:
      sc_move_add $moves $n
      set nag [ scoreToNag $prevscore ]
      if {$nag != {}} {
        sc_pos addNag $nag
      }
      sc_var exit
      sc_move forward
    }
  }

  set analysis(prevscore$n) $analysis(score$n)
  set analysis(prevmoves$n) $analysis(moves$n)

  # Restore the pre-move command:
  sc_info preMoveCmd preMoveCommand
  updateBoard -pgn
  # Update score graph if it is open:
  if {[winfo exists .sgraph]} { ::tools::graphs::score::Refresh }
}
################################################################################
#
################################################################################
proc scoreToNag {score} {
  if {$score >= $::informant("+-")} {
    return "+-"
  }
  if {$score >= $::informant("+/-")} {
    return "+/-"
  }
  if {$score >= $::informant("+=")} {
    return "+="
  }
  if { $score >= [expr 0.0 - $::informant("+=") ]} {
    return "="
  }
  if {$score <= [expr 0.0 - $::informant("+-") ]} {
    return "-+"
  }
  if {$score <= [expr 0.0 - $::informant("+/-") ]} {
    return "-/+"
  }
  if {$score <= [expr 0.0 - $::informant("+=") ]} {
    return "-="
  }
}
################################################################################
# will append arg to current game Annotator tag
################################################################################
proc appendAnnotator { s } {
  set extra [sc_game tags get Extra]
  # find Annotator tag
  set oldAnn {}
  set found 0
  foreach line $extra {
    if {$found} {
      set oldAnn $line
      break
    }
    if {[string match Annotator $line]} {
      set found 1
      continue
    }
  }

  if {$oldAnn != {}} {
    set ann "Annotator \"$oldAnn $s\"\n"
  } else  {
    set ann "Annotator \"$s\"\n"
  }
  sc_game tags set -extra [ list $ann ]
}
################################################################################
#
################################################################################
proc pushAnalysisData { { lastVar } { n 1 } } {
  global analysis
  lappend ::stack [list $analysis(prevscore$n) $analysis(score$n) \
      $analysis(prevmoves$n) $analysis(moves$n) $lastVar ]
}
################################################################################
#
################################################################################
proc popAnalysisData { { n 1 } } {
  global analysis
  # the start of analysis is in the middle of a variation
  if {[llength $::stack] == 0} {
    set analysis(prevscore$n) 0
    set analysis(score$n) 0
    set analysis(prevmoves$n) {}
    set analysis(moves$n) {}
    set lastVar 0
    return
  }
  set tmp [lindex $::stack end]
  set analysis(prevscore$n) [lindex $tmp 0]
  set analysis(score$n) [lindex $tmp 1]
  set analysis(prevmoves$n) [lindex $tmp 2]
  set analysis(moves$n) [lindex $tmp 3]
  set lastVar [lindex $tmp 4]
  set ::stack [lreplace $::stack end end]
  return $lastVar
}

################################################################################
#
################################################################################
proc addAnalysisVariation {n} {
  global analysis

  if {! [winfo exists .analysisWin$n]} { return }

  # if we are at the end of the game, we cannot add variation, so we add the
  # analysis one move before and append the last game move at the beginning of
  # the analysis

  set addAtStart [expr [sc_pos isAt vstart]  &&  [sc_pos isAt vend]]
  set isAt_end [sc_pos isAt end]
  set isAt_vend [sc_pos isAt vend]

  # Temporarily clear the pre-move command since we want to add a
  # whole line without Scid updating stuff
  sc_info preMoveCmd {}

  set moves $analysis(moves$n)
  if {$analysis(uci$n)} {
    set tmp_moves [ lindex [ lindex $analysis(multiPV$n) 0 ] 2 ]
    set text [format "\[%s\] %d:%s" $analysis(name$n) $analysis(depth$n) [scoreToMate $analysis(score$n) $tmp_moves $n]]
  } else  {
    set text [format "\[%s\] %d:%+.2f" $analysis(name$n) $analysis(depth$n) $analysis(score$n)]
  }

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

  # Add comment identifying analysis engine if at vstart
  # (perhaps this code belongs just above)
  if {[sc_pos isAt vstart]} {
    sc_pos setComment "[sc_pos getComment] $text"
  }

  if {$isAt_vend} {
    # Add the last move of the game at the beginning of the analysis
    sc_move_add $lastMove $n
  }

  # Add as many moves as possible from the engine analysis:
  sc_move_add $moves $n

  # Now go back to the previous place
  if {$create_var} {
    sc_var exit
  } else {
    sc_move back [llength $moves]
  }

  if {$addAtStart} {
    sc_move start
  } elseif {$isAt_vend && $create_var} {
    ### Automatically goto variation S.A.
    sc_var enter 0
  }

  # Restore the pre-move command:
  sc_info preMoveCmd preMoveCommand

  if {[winfo exists .pgnWin]} { ::pgn::Refresh 1 }

  # Update score graph if it is open:
  if {[winfo exists .sgraph]} { ::tools::graphs::score::Refresh }
}
################################################################################
#
################################################################################
proc addAllVariations {{n 1}} {
  global analysis

  if {! [winfo exists .analysisWin$n]} { return }

  # Cannot add a variation to an empty variation:
  if {[sc_pos isAt vstart]  &&  [sc_pos isAt vend]} { return }

  # if we are at the end of the game, we cannot add variation
  # so we add the analysis one move before and append the last game move at the beginning of the analysis
  set addAtEnd [sc_pos isAt vend]

  # Temporarily clear the pre-move command since we want to add a
  # whole line without Scid updating stuff:
  sc_info preMoveCmd {}

  foreach i $analysis(multiPVraw$n) j $analysis(multiPV$n) {
    set moves [lindex $i 2]

    set tmp_moves [ lindex $j 2 ]
    set text [format "\[%s\] %d:%s" $analysis(name$n) [lindex $i 0] [scoreToMate [lindex $i 1] $tmp_moves $n]]

    if {$addAtEnd} {
      # get the last move of the game
      set lastMove [sc_game info previousMoveUCI]
      sc_move back
    }

    # Add the variation:
    sc_var create
    # Add the comment at the start of the variation:
    sc_pos setComment "[sc_pos getComment] $text"
    if {$addAtEnd} {
      # Add the last move of the game at the beginning of the analysis
      sc_move_add $lastMove $n
    }
    # Add as many moves as possible from the engine analysis:
    sc_move_add $moves $n
    sc_var exit

    if {$addAtEnd} {
      #forward to the last move
      sc_move forward
    }

  }

  # Restore the pre-move command:
  sc_info preMoveCmd preMoveCommand

  if {[winfo exists .pgnWin]} { ::pgn::Refresh 1 }
  # Update score graph if it is open:
  if {[winfo exists .sgraph]} { ::tools::graphs::score::Refresh }
}
################################################################################
#
################################################################################
# TODO fonction obsolète à virer ??
proc addAnalysisToComment {line {n 1}} {
  global analysis
  if {! [winfo exists .analysisWin$n]} { return }

  # If comment editor window is open, add the score there, otherwise
  # just add the comment directly:
  if {[winfo exists .commentWin]} {
    set tempStr [.commentWin.cf.text get 1.0 end-1c]
  } else {
    set tempStr [sc_pos getComment]
  }
  set score $analysis(score$n)

  # If line is true, add the whole line, else just add the score:
  if {$line} {
    set scoretext [format "%+.2f: %s" $score $analysis(moves$n)]
  } else {
    set scoretext [format "%+.2f" $score]
  }

  # Strip out old score if it exists at the start of the comment:
  regsub {^\".*\"} $tempStr {} tempStr
  set newText "\"$scoretext\"$tempStr"
  if {[winfo exists .commentWin]} {
    .commentWin.cf.text delete 1.0 end
    .commentWin.cf.text insert 1.0 $newText
  } else {
    sc_pos setComment $newText
  }
  ::pgn::Refresh 1
}
################################################################################
#
################################################################################
proc makeAnalysisMove {n} {
  global analysis comp

  set s $analysis(moves$n)
  set res 1

  # Scan over any leading number/etc. This is ugly
  while {1} {
    switch -- [string index $s 0] {
      a - b - c - d - e - f - g - h -
      K - Q - R - B - N - P - O {
        break
      }
    }
    if {$s == {}} {return 0}
    set s [string range $s 1 end]
  }
  if {[scan $s %s move] != 1} { set res 0 }
  set action "replace"
  if {! [sc_pos isAt vend]} {
    set action [confirmReplaceMove]
  }
  if {$action == {cancel}} { return }
  set analysis(automoveThinking$n) 0
  if {$action == {var}} { sc_var create }

  if { [sc_move_add $move $n] } {
    ### Move fail
    set res 0
    puts "Error adding move $move" ; # &&&
  } else {
    puts_ "MOVE $n moves $move"
  }
    
  update idletasks ; # fixes tournament issues ?

  if { $comp(playing) && !$comp(animate) } {
    updateBoard -pgn
  } else {
    updateBoard -pgn -animate
  }  

  # if {!$analysis(has_setboard$comp(nextmove))} {}
  if {0} {
    # No setboard... but time controls are awful, so don't use it
    puts "SENDING OTHER sendToEngine $comp(nextmove) \"move $move\""
    sendToEngine $comp(nextmove) "move $move"
    if {![string compare [sc_pos side] "black"]} {
      sendToEngine $comp(nextmove) "black"
    } else {
      sendToEngine $comp(nextmove) "white"
    }
  }

  ::utils::sound::AnnounceNewMove $move
  return $res
}

################################################################################
#
################################################################################

# destroyAnalysisWin:
#   Closes an engine, because its analysis window is being destroyed.

proc destroyAnalysisWin {n} {

  # Is this working properly. We seem to have a process left S.A.

  global windowsOS analysis annotateModeButtonValue

  puts_ "destroyAnalysisWin $n"
  bind .analysisWin$n <Destroy> {}

  if { $annotateModeButtonValue } { ; # end annotation
    set annotateModeButtonValue 0
    toggleAutoplay
  }

  # Check the pipe is not already closed:
  if {$analysis(pipe$n) == {}} {
    set ::analysisWin$n 0
    return
  }

  # Send interrupt signal if the engine wants it:
  if {(!$windowsOS)  &&  $analysis(send_sigint$n)} {
  puts_ "killing $analysis(pipe$n), [pid $analysis(pipe$n)]"
    catch {exec -- kill -s INT [pid $analysis(pipe$n)]}
  }

  # Some engines in analyze mode may not react as expected to "quit"
  # so ensure the engine exits analyze mode first:
  if {$analysis(uci$n)} {
    sendToEngine $n stop
    sendToEngine $n quit
  } else  {
    sendToEngine $n exit
    sendToEngine $n quit
  }
  catch { flush $analysis(pipe$n) }

  # Uncomment the following line to turn on blocking mode before
  # closing the engine (but probably not a good idea!)
  #   fconfigure $analysis(pipe$n) -blocking 1

  # Close the engine, ignoring any errors since nothing can really
  # be done about them anyway -- maybe should alert the user with
  # a message box?
  close $analysis(pipe$n)
  #catch {close $analysis(pipe$n)}

  if {$analysis(log$n) != {}} {
    catch {close $analysis(log$n)}
    set analysis(log$n) {}
  }
  set analysis(pipe$n) {}
  set ::analysisWin$n 0
}

# sendToEngine:
#   Send a command to a running analysis engine.

proc sendToEngine {n text} {
  logEngine $n "Scid  : $text"
  puts_ "$n $text"
  catch {puts $::analysis(pipe$n) $text}
}

# sendMoveToEngine:
#   Sends a move to a running analysis engine, using sendToEngine.
#   If the engine has indicated (with "usermove=1" on a "feature" line)
#   that it wants it, send with "usermove " before the move.
#
proc sendMoveToEngine {n move} {
  # Convert "e7e8Q" into "e7e8q" since that is the XBoard/WinBoard
  # standard for sending moves in coordinate notation:
  set move [string tolower $move]
  if {$::analysis(uci$n)} {
    # should be position fen [sc_pos fen] moves ?
    sendToEngine $n "position fen [sc_pos fen] moves $move"
  } else  {
    if {$::analysis(wants_usermove$n)} {
      sendToEngine $n "usermove $move"
    } else {
      sendToEngine $n $move
    }
  }
}

# logEngine:
#   Log Scid-Engine communication.
#
proc logEngine {n text} {
  global analysis

  # Print the log message to stdout if applicable:
  if {$::analysis(log_stdout)} {
    puts stdout $text
  }

  if { [ info exists ::analysis(log$n)] && $::analysis(log$n) != {}} {
    puts $::analysis(log$n) $text
    catch { flush $::analysis(log$n) }

    # Close the log file if the limit is reached:
    incr analysis(logCount$n)
    if {$analysis(logCount$n) >= $analysis(logMax)} {
      puts $::analysis(log$n) \
          "NOTE  : Log file size limit reached; closing log file."
      catch {close $analysis(log$n)}
      set analysis(log$n) {}
    }
  }
}

# logEngineNote:
#   Add a note to the engine comminucation log file.
#
proc logEngineNote {n text} {
  logEngine $n "NOTE  : $text"
}

# What a fucking mess this is. S.A.
# Horrible hopeless design decisions meaning this code hasnt been touched since
# - Sorry Shane ;>

proc startAnalysisWin { FunctionKey } {
  global engines

  if {$engines($FunctionKey) != {}} {
    makeAnalysisWin $engines($FunctionKey)
  }
}

################################################################################
#
# makeAnalysisWin:
#
# Runs Engine n if not already running 
#
################################################################################

proc makeAnalysisWin { {n 1} } {
  global analysisWin$n font_Analysis analysisCommand analysis annotateModeButtonValue annotateMode
  set w .analysisWin$n

  if {[winfo exists $w]} {
    ### then reset engine and return
    focus .
    destroy $w
    set analysisWin$n 0
    resetEngine $n
    return
  }

  set annotateModeButtonValue 0

  # What an f-ing mess.
  # Previously the engines were sorted , and only engine 1 or 2 (in the sort order)
  # could be used. Engines often got resorted, and the key bindings would change.
  # This was stupid, and very confusing. This rewrite will allow 
  # any engine to be configured to run as engine 1 or 2 (or 3 ...)

  resetEngine $n

  # engine[0] will run in toplevel .analysisWin1
  # engine[1] will run in toplevel .analysisWin2

  set index [expr {$n - 1}]

  # index is now which engine to run from engine list

  if {$index == {}  ||  $index < 0} {
    set analysisWin$n 0
    return
  }
  ::enginelist::setTime $index
  catch {::enginelist::write}
  set analysis(index$n) $index
  set engineData [lindex $::engines(list) $index]
  set analysisName [lindex $engineData 0]
  set analysisCommand [ toAbsPath [lindex $engineData 1] ]
  set analysisArgs [lindex $engineData 2]
  set analysisDir [ toAbsPath [lindex $engineData 3] ]
  set analysis(uci$n) [ lindex $engineData 7 ]

  # If the analysis directory is not current dir, cd to it:
  set oldpwd {}
  if {$analysisDir != {.}} {
    set oldpwd [pwd]
    catch {cd $analysisDir}
  }

  if {! $analysis(uci$n) } {
    set analysis(multiPVCount$n) 1
  }

  # Try to execute the analysis program:
  if {[catch {set analysis(pipe$n) [open "| [list $analysisCommand] $analysisArgs" "r+"]} result]} {
    if {$oldpwd != {}} { catch {cd $oldpwd} }
    if {[winfo exists .enginelist]} {
      set parent .enginelist
    } else {
      set parent .
    }
    tk_messageBox -title "Scid: error starting analysis" \
        -icon warning -type ok -parent $parent \
        -message "Unable to start the program:\n$analysisCommand"
    set analysisWin$n 0
    resetEngine $n
    return
  }

  set analysisWin$n 1

  # Return to original dir if necessary:
  if {$oldpwd != ""} { catch {cd $oldpwd} }

  # Open log file if applicable:
  set analysis(log$n) {}
  if {$analysis(logMax) > 0} {
    if {! [catch {open [file join $::scidLogDir "engine$n.log"] w} log]} {
      set analysis(log$n) $log
      logEngine $n "Scid-Engine communication log file"
      logEngine $n "Engine: $analysisName"
      logEngine $n "Command: $analysisCommand"
      logEngine $n "Date: [clock format [clock seconds]]"
      logEngine $n ""
      logEngine $n "This file was automatically generated by Scid."
      logEngine $n "It is rewritten every time an engine is started in Scid."
      logEngine $n ""
    }
  }

  set analysis(name$n) $analysisName

  # Configure pipe for line buffering and non-blocking mode
  fconfigure $analysis(pipe$n) -buffering line -blocking 0

  #
  # Set up the  analysis window:
  #
  toplevel $w
  wm title $w "Scid: $analysisName"
  bind $w <F1> { helpWindow Analysis }
  if {$::comp(iconize) && ![winfo exists .enginelist]} {
    wm iconify $w
  }
  setWinLocation $w
  setWinSize $w
  standardShortcuts $w

  ::board::new $w.bd 25
  $w.bd configure -relief solid -borderwidth 1
  set analysis(showBoard$n) 0

  # This is no longer configurable, except here. (Used to be associated with b1.showinfo)
  # If set, it show heaps of hash info in the second line of text widget
  set analysis(showEngineInfo$n) 0 

  frame $w.b
  pack  $w.b -side top -fill x
  set relief flat	; # -width 24 -height 24

  checkbutton $w.b.automove -image tb_training  -indicatoron false  \
    -command "toggleAutomove $n" -variable analysis(automove$n) -relief $relief
  ::utils::tooltip::Set $w.b.automove $::tr(Training)

  checkbutton $w.b.lockengine -image tb_lockengine -indicatoron false \
    -variable analysis(lockEngine$n) -command "toggleLockEngine $n" -relief $relief
  ::utils::tooltip::Set $w.b.lockengine $::tr(LockEngine)

  button $w.b.line -image tb_addvar -command "addAnalysisVariation $n" -relief $relief
  ::utils::tooltip::Set $w.b.line $::tr(AddVariation)

  button $w.b.alllines -image tb_addallvars -command "addAllVariations $n" -relief $relief
  ::utils::tooltip::Set $w.b.alllines $::tr(AddAllVariations)

  button $w.b.move -image tb_addmove -command "makeAnalysisMove $n" -relief $relief
  ::utils::tooltip::Set $w.b.move $::tr(AddMove)

  spinbox $w.b.multipv -from 1 -to 8 -increment 1 -textvariable analysis(multiPVCount$n) -width 2 \
      -command "changePVSize $n" 
  ::utils::tooltip::Set $w.b.multipv $::tr(Lines)

  # start/stop engine analysis
  button $w.b.startStop -image tb_pause -command "toggleEngineAnalysis $n" -relief $relief
  ::utils::tooltip::Set $w.b.startStop "$::tr(StopEngine)(a)"

  set ::finishGameMode 0
  button $w.b.finishGame -image finish_off -command "toggleFinishGame $n"  -relief $relief
  ::utils::tooltip::Set $w.b.finishGame $::tr(FinishGame)

  button $w.b.showboard -image tb_coords -command "toggleAnalysisBoard $n" -relief $relief
  ::utils::tooltip::Set $w.b.showboard $::tr(ShowAnalysisBoard)

  # checkbutton $w.b.showinfo -image tb_engineinfo -indicatoron false \
  #  -variable analysis(showEngineInfo$n) -command "toggleEngineInfo $n" -relief $relief
  # ::utils::tooltip::Set $w.b.showinfo $::tr(ShowInfo)

  if {!$annotateModeButtonValue && !$annotateMode} {
    checkbutton $w.b.annotate -image tb_annotate -indicatoron false \
      -variable annotateModeButtonValue -command "initAnnotation $n" -relief $relief
    ::utils::tooltip::Set $w.b.annotate $::tr(Annotate...)
  } else {
    frame $w.b.annotate -width 0 -height 0
  }

  checkbutton $w.b.priority -image tb_cpu -indicatoron false -variable analysis(priority$n) \
    -onvalue idle -offvalue normal -command "setAnalysisPriority $n" -relief $relief
  ::utils::tooltip::Set $w.b.priority $::tr(LowPriority)

  # UCI does not support . command (Is this correct ? S.A)
  button $w.b.update -image tb_update \
    -command "if {$analysis(uci$n)} {sendToEngine $n .}"  -relief $relief
  ::utils::tooltip::Set $w.b.update $::tr(Update)

  button $w.b.help -image tb_help  -command {helpWindow Analysis} -relief $relief
  ::utils::tooltip::Set $w.b.help $::tr(Help)


  pack $w.b.startStop $w.b.lockengine $w.b.move $w.b.line $w.b.alllines \
       $w.b.multipv $w.b.annotate $w.b.automove $w.b.finishGame $w.b.showboard \
       $w.b.update $w.b.priority -side left -pady 2 -padx 1
  pack $w.b.help -side right -pady 2 -padx 1

  # pack  $w.b.showinfo 
  if {$analysis(uci$n)} {
    $w.b.multipv configure -state readonly
    pack forget $w.b.update
    $w.b.update  configure -state disabled
    text $w.text -height 1 -font font_Regular -wrap word -bg gray95
  } else  {
    # pack forget $w.b.showinfo
    # $w.b.showinfo configure -state disabled

    pack forget $w.b.multipv 
    pack forget $w.b.alllines
    $w.b.multipv configure -state disabled
    $w.b.alllines configure -state disabled
    text $w.text -height 4 -font font_Regular -wrap word -bg gray95
  }

  frame $w.hist
  text $w.hist.text -font font_Fixed \
      -wrap word -setgrid 1 -yscrollcommand "$w.hist.ybar set"
  $w.hist.text tag configure indent -lmargin2 [font measure font_Fixed "xxxxxxxxxxxx"]
  scrollbar $w.hist.ybar -command "$w.hist.text yview" -takefocus 0
  pack $w.text -side bottom -fill both
  pack $w.hist -side top -expand 1 -fill both
  pack $w.hist.ybar -side right -fill y
  pack $w.hist.text -side left -expand 1 -fill both

  bind $w.hist.text <ButtonPress-3> "toggleMovesDisplay $n"
  $w.text tag configure blue -foreground blue
  $w.hist.text tag configure blue -foreground blue -lmargin2 [font measure font_Fixed "xxxxxxxxxxxx"]
  $w.hist.text tag configure gray -foreground gray
  $w.text insert end "Please wait a few seconds for engine initialisation \
      (with some engines, you will not see any analysis until the board \
      changes. So if you see this message, try changing the board \
      by moving backward or forward or making a new move.)"
  $w.text configure -state disabled
  bind $w <Destroy> "destroyAnalysisWin $n"
  bind $w <Configure> "recordWinSize $w"
  bind $w <Escape> "focus .; destroy $w"
  bind $w <Key-a> "$w.b.startStop invoke"
  wm minsize $w 25 0
  bindMouseWheel $w $w.hist.text

  if {$analysis(uci$n)} {
    fileevent $analysis(pipe$n) readable "::uci::processAnalysisInput $n"
  } else  {
    fileevent $analysis(pipe$n) readable "processAnalysisInput $n"
  }
  after 1000 "checkAnalysisStarted $n"

  # finish MultiPV spinbox configuration
  if {$analysis(uci$n)} {
    # find UCI engine MultiPV capability

    # Wait for uciok
    while { !($analysis(uciok$n)) } { 
      # && [winfo exists .analysisWin$n]
      update
      after 200
    }
    set hasMultiPV 0
    foreach opt $analysis(uciOptions$n) {
      if { [lindex $opt 0] == "MultiPV" } {
        set hasMultiPV 1
        set min [lindex $opt 1]
        set max [lindex $opt 2]
        if {$min == ""} { set min 1}
        if {$max == ""} { set max 8}
        break
      }
    }
    set current -1
    set options  [ lindex $engineData 8 ]
    foreach opt $options {
      if {[lindex $opt 0] == "MultiPV"} { set current [lindex $opt 1] ; break }
    }
    if {$current == -1} { set current 1 }
    set analysis(multiPVCount$n) $current
    #    changePVSize $n
    catch {
      if { $hasMultiPV } {
        $w.b.multipv configure -from $min -to $max -state readonly
      } else  {
        $w.b.multipv configure -from 1 -to 1 -state disabled
	$w.b.alllines configure -state disabled
      }
    }
  } ;# end of MultiPV spinbox configuration

  # We hope the engine is correctly started at that point, so we can send the first analyze command
  # this problem only happens with winboard engine, as we don't know when they are ready
  if { !$analysis(uci$n) } {
    initialAnalysisStart $n
  }
  # necessary on windows because the UI sometimes starves, also keep latest priority setting
  if {$::windowsOS || $analysis(priority$n) == "idle"} {
    set analysis(priority$n) idle
    setAnalysisPriority $n
  }

}
################################################################################
#
################################################################################
proc toggleMovesDisplay {n} {
  set ::analysis(movesDisplay$n) [expr 1 - $::analysis(movesDisplay$n)]
  set h .analysisWin$n.hist.text
  $h configure -state normal
  $h delete 1.0 end
  $h configure -state disabled
  updateAnalysisText $n
}

################################################################################
# will truncate PV list if necessary and tell the engine to send N best lines
################################################################################
proc changePVSize { n } {
  global analysis
  if { $analysis(multiPVCount$n) < [llength $analysis(multiPV$n)] } {
    set analysis(multiPV$n) {}
    set analysis(multiPVraw$n) {}
  }
  if {$analysis(multiPVCount$n) == 1} {
    set h .analysisWin$n.hist.text
    $h configure -state normal
    $h delete 0.0 end
    $h configure -state disabled
    set analysis(lastHistory$n) {}
  }
  if { $analysis(uci$n) } {
    # if the UCI engine was analysing, we have to stop/restart it to take into acount the new multiPV option
    if {$analysis(analyzeMode$n)} {
      sendToEngine $n stop
      set analysis(waitForBestMove$n) 1
      vwait analysis(waitForBestMove$n)
      sendToEngine $n "setoption name MultiPV value $analysis(multiPVCount$n)"
      sendToEngine $n "position fen [sc_pos fen]"
      sendToEngine $n "go infinite"
    } else  {
      sendToEngine $n "setoption name MultiPV value $analysis(multiPVCount$n)"
    }
  }
}
################################################################################
# setAnalysisPriority
#   Sets the priority class (in Windows) or nice level (in Unix)
#   of a running analysis engine.
################################################################################
proc setAnalysisPriority {n} {
  global analysis

  # Get the process ID of the analysis engine:
  if {$analysis(pipe$n) == {}} { return }
  set pidlist [pid $analysis(pipe$n)]
  if {[llength $pidlist] < 1} { return }
  set pid [lindex $pidlist 0]

  # Set the priority class (idle or normal):
  if {$::windowsOS} {
    catch {sc_info priority $pid $analysis(priority$n)}
  } else {
    set priority 0
    if {$analysis(priority$n) == {idle}} { set priority 15 }
    catch {sc_info priority $pid $priority}
  }

  # Re-read the priority class for confirmation:
  if {[catch {sc_info priority $pid} newpriority]} { return }
  if {$::windowsOS} {
    if {$newpriority == {idle}  ||  $newpriority == {normal}} {
      set analysis(priority$n) $newpriority
    }
  } else {
    set priority normal
    if {$newpriority > 0} { set priority idle }
    set analysis(priority$n) $priority
  }
}
################################################################################
# checkAnalysisStarted
#   Called a short time after an analysis engine was started
#   to send it commands if Scid has not seen any output from
#   it yet.
################################################################################
proc checkAnalysisStarted {n} {
  global analysis
  if {$analysis(seen$n)} { return }
  # Some Winboard engines do not issue any output when
  # they start up, so the fileevent above is never triggered.
  # Most, but not all, of these engines will respond in some
  # way once they have received input of some type.  This
  # proc will issue the same initialization commands as
  # those in processAnalysisInput below, but without the need
  # for a triggering fileevent to occur.

  logEngineNote $n {Quiet engine (still no output); sending it initial commands.}

  if {$analysis(uci$n)} {
    # in order to get options
    sendToEngine $n uci
    # egine should respond uciok
    sendToEngine $n isready
    set analysis(seen$n) 1
  } else  {
    sendToEngine $n xboard
    sendToEngine $n "protover 2"
    sendToEngine $n "ponder off"
    sendToEngine $n post
    # Prevent some engines from making an immediate "book"
    # reply move as black when position is sent later:
    sendToEngine $n force
  }
}
################################################################################
# with wb engines, we don't know when the startup phase is over and when the
# engine is ready : so wait for the end of initial output and take some margin
# to issue an analyze command
################################################################################
proc initialAnalysisStart {n} {
  global analysis comp

  # hack to stop initialAnalysisStart when playing a comp
  if {$comp(playing)} {
    return
  }

  update

  if { $analysis(processInput$n) == 0 } {
    after 500 initialAnalysisStart $n
    return
  }
  set cl [clock clicks -milliseconds]
  if {[expr $cl - $analysis(processInput$n)] < 1000} {
    after 200 initialAnalysisStart $n
    return
  }
  after 200 startAnalyzeMode $n 1
}
################################################################################
# processAnalysisInput (only for win/xboard engines)
#   Called from a fileevent whenever there is a line of input
#   from an analysis engine waiting to be processed.
################################################################################
proc processAnalysisInput {n} {
  global analysis comp

  # Get one line from the engine:
  set line [gets $analysis(pipe$n)]

  ### Gaviota sends nasty characters...
  ### but still doesnt work
  # set line [string map {\" {} \} {} \{ {}} [gets $analysis(pipe$n)]]


  # this is only useful at startup but costs less than 10 microseconds
  set analysis(processInput$n) [clock clicks -milliseconds]

  if {$line == {}} { return }
  puts_ "ENGINE $n says: $line"

  logEngine $n "Engine: $line"

  if {![checkEngineIsAlive $n]} { return }

  if {! $analysis(seen$n)} {
    set analysis(seen$n) 1
    # First line of output from the program, so send initial commands:
    logEngineNote $n {First line from engine seen; sending it initial commands now.}
    sendToEngine $n xboard
    sendToEngine $n {protover 2}
    sendToEngine $n {ponder off}
    sendToEngine $n post
  }

  if {$comp(playing)} {
    # check for malformed lines
    if {[string match {* "} $line] || [string match {*\}:*}]} {
      return
    }

    ### Match "my move is", "My move is:"
    if {[string match "*y move is*" $line]} {
      set analysis(moves$n) [lrange $line 3 end]
      set analysis(waitForBestMove$n) 0
    }
    if {[lrange $line 0 0] == {move}} {
      set analysis(moves$n) [lrange $line 1 end]
      set analysis(waitForBestMove$n) 0
    }

    if {[lindex $line 0] == {1-0} || \
	[lindex $line 0] == {0-1} || \
	[lindex $line 0] == {resign} } {
      puts_ "RESIGNS (engine $n)"
      if {$n == $comp(white)} {
	sc_game tags set -result 0
	sc_pos setComment "White resigns"
      } else {
	sc_game tags set -result 1
	sc_pos setComment "Black resigns"
      }
      set comp(playing) 0
      set analysis(waitForBestMove$n) 0
    }
  }

  # Check for "feature" commands so we can determine if the engine
  # has the setboard and analyze commands:
  #
  if {[string match {feature*} $line]} {
    if {[string match {*analyze=1*} $line]} { set analysis(has_analyze$n) 1 }
    if {[string match {*setboard=1*} $line]} { set analysis(has_setboard$n) 1 }
    if {[string match {*usermove=1*} $line]} { set analysis(wants_usermove$n) 1 }
    if {[string match {*sigint=1*} $line]} { set analysis(send_sigint$n) 1 }
    if {[string match {*myname=*} $line] } {
      if { !$analysis(wbEngineDetected$n) } { detectWBEngine $n $line  }
      if { [regexp "myname=\"(\[^\"\]*)\"" $line dummy name]} {
        catch {wm title .analysisWin$n "Scid: $name"}
      }
    }
    return
  }


  # Check for a line starting with "Crafty", so Scid can work well
  # with older Crafty versions that do not recognize "protover"

  if {[string match {Crafty*} $line]} {
    logEngineNote $n {Seen "Crafty"; assuming analyze and setboard commands.}
    set major 0
    if {[scan $line "Crafty v%d.%d" major minor] == 2  &&  $major >= 18} {
      logEngineNote $n {Crafty version is >= 18.0; assuming scores are from White perspective.}
      set analysis(invertScore$n) 0
    }
    # Turn off crafty logging, to reduce number of junk files:
    sendToEngine $n {log off}
    # Set a fairly low noise value so Crafty is responsive to board changes,
    # but not so low that we get lots of short-ply search data:
    sendToEngine $n {noise 1000}
    sendToEngine $n {egtb off} ; # turn off end game table book
    sendToEngine $n {resign 0} ; # turn off alarm (resigning ?)
    set analysis(isCrafty$n) 1
    set analysis(has_setboard$n) 1
    set analysis(has_analyze$n) 1
    return
  }

  # hack to quit processAnalysisInput when playing a comp
  if {$comp(playing)} {
    return
  }

  # Scan the line from the engine for the analysis data

  set res [scan $line "%d%c %d %d %s %\[^\n\]\n" \
      temp_depth dummy temp_score \
      temp_time temp_nodes temp_moves]
  if {$res == 6} {
    if {$analysis(invertScore$n)  && (![string compare [sc_pos side] "black"])} {
      set temp_score [expr { 0.0 - $temp_score } ]
    }
    set analysis(depth$n) $temp_depth
    set analysis(score$n) $temp_score
    # Convert score to pawns from centipawns:
    set analysis(score$n) [expr {double($analysis(score$n)) / 100.0} ]
    set analysis(moves$n) [formatAnalysisMoves $temp_moves]
    set analysis(time$n) $temp_time
    set analysis(nodes$n) [calculateNodes $temp_nodes]

    # Convert time to seconds from centiseconds
    if {! $analysis(wholeSeconds$n)} {
      set analysis(time$n) [expr {double($analysis(time$n)) / 100.0} ]
    }

    updateAnalysisText $n

    if {! $analysis(seenEval$n)} {
      # This is the first evaluation line seen, so send the current
      # position details to the engine:
      set analysis(seenEval$n) 1
    }

    return
  }


  # Check for a "stat01:" line, the reply to the "." command:
  #
  if {! [string compare [string range $line 0 6] "stat01:"]} {
    if {[scan $line "%s %d %s %d" \
          dummy temp_time temp_nodes temp_depth] == 4} {
      set analysis(depth$n) $temp_depth
      set analysis(time$n) $temp_time
      set analysis(nodes$n) [calculateNodes $temp_nodes]
      # Convert time to seconds from centiseconds:
      if {! $analysis(wholeSeconds$n)} {
        set analysis(time$n) [expr {double($analysis(time$n)) / 100.0} ]
      }
      updateAnalysisText $n
    }
    return
  }

  # Check for other engine-specific lines:
  # The following checks are intended to make Scid work with
  # various WinBoard engines that are not properly configured
  # by the "feature" line checking code above.
  #
  # Many thanks to Allen Lake for testing Scid with many
  # WinBoard engines and providing this code and the detection
  # code in wbdetect.tcl
  if { !$analysis(wbEngineDetected$n) } {
    detectWBEngine $n $line
  }

}
################################################################################
# Returns 0 if engine died abruptly or 1 otherwise
# - this procedure is duplicated(?) in uci.tcl
################################################################################
proc checkEngineIsAlive { {n 1} } {
  global analysis

  if {[eof $analysis(pipe$n)]} {
    fileevent $analysis(pipe$n) readable {}
    catch {close $analysis(pipe$n)}
    set analysis(pipe$n) {}
    logEngineNote $n {Engine terminated without warning.}
    if {$::comp(playing)} {
      set ::comp(move) $n
      compAbort
    } else {
      catch {destroy .analysisWin$n}
    }

    if {[winfo exists .comp]} {
      set parent .comp
    } elseif {[winfo exists .enginelist]} {
      set parent .enginelist
    } else {
      set parent .
    }

    tk_messageBox -type ok -icon info -parent $parent -title Scid -message \
      "Analysis engine $analysis(name$n) terminated without warning. \
       It probably crashed, had an internal errors, or is misconfigured."
    if {[winfo exists .comp]} {
      puts_ "Engine failed... destroying .analysisWin$n, comp widget"
      compDestroy
      destroy .analysisWin$n
    }
    return 0
  }
  return 1
}
################################################################################
# formatAnalysisMoves:
#   Given the text at the end of a line of analysis data from an engine,
#   this proc tries to strip out some extra stuff engines add to make
#   the text more compatible for adding as a variation.
################################################################################
proc formatAnalysisMoves {text} {
  ### Yace puts ".", "t", "t-" or "t+" at the start of its moves text,
  ### unless directed not to in its .ini file. Get rid of it
  # if {[strIsPrefix {. } $text]} { set text [string range $text 2 end]}
  # if {[strIsPrefix {t } $text]} { set text [string range $text 2 end]}
  # if {[strIsPrefix {t- } $text]} { set text [string range $text 3 end]}
  # if {[strIsPrefix {t+ } $text]} { set text [string range $text 3 end]}

  # Trim any initial or final whitespace:
  set text [string trim $text]

  ### Yace often adds "H" after a move, e.g. "Bc4H". Remove them
  # regsub -all {H } $text { } text

  # Crafty adds "<HT>" for a hash table comment. Change it to "{HT}"
  regsub <HT> $text {{HT}} text

  return $text
}
################################################################################
# will ask engine to play the game till the end
################################################################################
proc toggleFinishGame {n} {
  global analysis
  set b ".analysisWin$n.b.finishGame"

  if { $::annotateModeButtonValue || $::autoplayMode || !$analysis(analyzeMode$n) || ! [sc_pos isAt vend] } {
    return
  }

  set ::finishGameMode [expr ! $::finishGameMode]
  if {$::finishGameMode} {
    $b configure -image finish_on
    after $::autoplayDelay autoplayFinishGame $n
  } else  {
    set ::finishGameMode 0
    $b configure -image finish_off
    after cancel autoplayFinishGame
  }
}
################################################################################
#
################################################################################
proc autoplayFinishGame {n} {
  if {!$::finishGameMode || ![winfo exists .analysisWin$n]} {return}
  .analysisWin$n.b.move invoke
  if { [string index [sc_game info previousMove] end] == {#}} {
    toggleFinishGame $n
    return
  }
  after $::autoplayDelay autoplayFinishGame $n
}
################################################################################
#
################################################################################
proc toggleEngineAnalysis {n {force 0}} {
  global analysis
  set b .analysisWin$n.b.startStop

  if { ($::annotateModeButtonValue || $::finishGameMode) && ! $force } {
    return
  }

  if {$analysis(analyzeMode$n)} {
    stopAnalyzeMode $n
    $b configure -image tb_play
    ::utils::tooltip::Set $b "$::tr(StartEngine)(a)"
    # reset lock mode and disable lock button
    set analysis(lockEngine$n) 0
    toggleLockEngine $n
    .analysisWin$n.b.lockengine configure -state disabled
  } else  {
    startAnalyzeMode $n
    $b configure -image tb_pause
    ::utils::tooltip::Set $b "$::tr(StopEngine)(a)"
    # enable lock button
    .analysisWin$n.b.lockengine configure -state normal
  }
}
################################################################################
# startAnalyzeMode:
#   Put the engine in analyze mode.
################################################################################
proc startAnalyzeMode {{n 1} {force 0}} {
  global analysis

  # Check that the engine has not already had analyze mode started:
  if {$analysis(analyzeMode$n) && ! $force } { return }
  set analysis(analyzeMode$n) 1
  if { $analysis(uci$n) } {
    set analysis(waitForReadyOk$n) 1
    sendToEngine $n isready
    vwait analysis(waitForReadyOk$n)
    sendToEngine $n "position fen [sc_pos fen]"
    sendToEngine $n {go infinite}
    set analysis(fen$n) [sc_pos fen]
    set analysis(maxmovenumber$n) 0
  } else  {
    if {$analysis(has_setboard$n)} {
      sendToEngine $n "setboard [sc_pos fen]"
    }
    if { $analysis(has_analyze$n) } {
      # why is this commented out. It crashes engine when re-instated S.A
      #updateAnalysis $n
      sendToEngine $n analyze
    } else  {
      updateAnalysis $n ;# in order to handle special cases (engines without setboard and analyse commands)
    }
  }
}
################################################################################
# stopAnalyzeMode
################################################################################
proc stopAnalyzeMode { {n 1} } {
  global analysis
  if {! $analysis(analyzeMode$n)} { return }
  set analysis(analyzeMode$n) 0
  if { $analysis(uci$n) } {
    sendToEngine $n stop
  } else  {
    sendToEngine $n exit
  }
}
################################################################################
# toggleLockEngine
#   Toggle whether engine is locked to current position.
################################################################################
proc toggleLockEngine {n} {
  global analysis
  if { $analysis(lockEngine$n) } {
    set state disabled
    set analysis(lockN$n) [sc_pos moveNumber]
    set analysis(lockSide$n) [sc_pos side]

    ### You can now lock the engine position, press "pause", and then
    # "add variation" to add the analysis of the locked position
    # NB. If trial mode is already set, locking the engine will lose previous position

    if  {$::trialMode} {
      setTrialMode update
    } else {
      setTrialMode 1
    }
  } else {
    setTrialMode 0
    if {$analysis(analyzeMode$n)} {
      stopAnalyzeMode $n
      startAnalyzeMode $n
    }
    set state normal
  }
  set w .analysisWin$n
  $w.b.move configure -state $state
  $w.b.line configure -state $state
  if {$analysis(uci$n)} {
    $w.b.multipv configure -state $state
  }
  $w.b.alllines configure -state $state
  $w.b.automove configure -state $state
  $w.b.annotate configure -state $state
  $w.b.finishGame configure -state $state
}
################################################################################
# updateAnalysisText
#   Update the text in an analysis window.
################################################################################
proc updateAnalysisText {{n 1}} {
  global analysis

  set nps 0
  if {$analysis(currmovenumber$n) > $analysis(maxmovenumber$n) } {
    set analysis(maxmovenumber$n) $analysis(currmovenumber$n)
  }
  if {$analysis(time$n) > 0.0} {
    set nps [expr {round($analysis(nodes$n) / $analysis(time$n))} ]
  }
  set score $analysis(score$n)

  set t .analysisWin$n.text
  set h .analysisWin$n.hist.text

  $t configure -state normal
  $t delete 0.0 end

  if { $analysis(uci$n) } {
    if { [expr abs($score)] == 327.0 } {
      if { [catch { set tmp [format "M%d " $analysis(scoremate$n)]} ] } {
        set tmp [format "%+.1f " $score]
      }
    } else {
      set tmp [format "%+.1f " $score]
    }
    $t insert end $tmp

    $t insert end "[tr Depth]: "
    if {$analysis(showEngineInfo$n) && $analysis(seldepth$n) != 0} {
      $t insert end [ format "%2u/%u " $analysis(depth$n) $analysis(seldepth$n)]
    } else {
      $t insert end [ format "%2u " $analysis(depth$n) ]
    }
    $t insert end "[tr Nodes]: "
    $t insert end [ format "%6uK (%u kn/s) " $analysis(nodes$n) $nps ]
    $t insert end "[tr Time]: "
    $t insert end [ format "%6.2f s" $analysis(time$n) ]
    if {$analysis(showEngineInfo$n)} {
      $t insert end \n
      $t insert end "[tr Current]: "
      $t insert end [ format "%s (%s/%s) " [::trans $analysis(currmove$n)] $analysis(currmovenumber$n) $analysis(maxmovenumber$n)]
      $t insert end {TB Hits: }
      $t insert end [ format "%u " $analysis(tbhits$n)]
      $t insert end {Nps: }
      $t insert end [ format "%u n/s " $analysis(nps$n)]
      $t insert end {Hash Full: }
      set hashfull [expr {round($analysis(hashfull$n) / 10)}]
      $t insert end [ format "%u%% " $hashfull ]
      $t insert end {CPU Load: }
      set cpuload [expr {round($analysis(cpuload$n) / 10)}]
      $t insert end [ format "%u%% " $cpuload ]
      
      #$t insert end [ format "\nCurrent: %s (%s) - Hashfull: %u - nps: %u - TBhits: %u - CPUload: %u" $analysis(currmove$n) $analysis(currmovenumber$n) $analysis(hashfull$n) $analysis(nps$n) $analysis(tbhits$n) $analysis(cpuload$n) ]
    }
  } else {
    set newStr [format "Depth:   %6u      Nodes: %6uK (%u kn/s)\n" $analysis(depth$n) $analysis(nodes$n) $nps]
    append newStr [format "Score: %+8.2f      Time: %9.2f seconds\n" $score $analysis(time$n)]
    $t insert 1.0 $newStr
  }

  if {$analysis(automove$n)} {
    if {$analysis(automoveThinking$n)} {
      set moves {   Thinking..... }
    } else {
      set moves {   Your move..... }
    }

    if { ! $analysis(uci$n) } {
      $t insert end $moves blue
    }
    $t configure -state disabled
    updateAnalysisBoard $n {}
    return
  }

  if {! $::analysis(movesDisplay$n)}  {
    $h configure -state normal
    $h delete 0.0 end

    $h insert end "\n\n\n     Right click to see moves\n" blue
    updateAnalysisBoard $n {}
    $h configure -state disabled
    return
  }

  if { $analysis(uci$n) } {
    set moves [ lindex [ lindex $analysis(multiPV$n) 0 ] 2 ]
  } else  {
    set moves $analysis(moves$n)
  }

  $h configure -state normal
  set cleared 0
  if { $analysis(depth$n) < $analysis(prev_depth$n)  || $analysis(prev_depth$n) == 0 } {
    $h delete 1.0 end
    set cleared 1
  }

  set line {}

  if { $analysis(uci$n) } {
    if {$cleared} { set analysis(multiPV$n) {} ; set analysis(multiPVraw$n) {} }
    if {$analysis(multiPVCount$n) == 1} {
      set newhst [format "%2d %s %s" \
		$analysis(depth$n)   \
		[scoreToMate $score $moves $n]  \
		[addMoveNumbers $n [::trans $moves]]]
      if {$newhst != $analysis(lastHistory$n) && $moves != ""} {
        append line [format "%s (%.2f)\n" $newhst $analysis(time$n)]
        set analysis(lastHistory$n) $newhst
      }
    } else {
      $h delete 1.0 end
      # First line
      set pv [lindex $analysis(multiPV$n) 0]
      catch { set newStr [format "%2d %s " [lindex $pv 0] [scoreToMate $score [lindex $pv 2] $n] ] }
      
      $h insert end {1 } gray
      append newStr "[addMoveNumbers $n [::trans [lindex $pv 2]]]\n"
      $h insert end $newStr blue
      
      set lineNumber 1
      foreach pv $analysis(multiPV$n) {
        if {$lineNumber == 1} { incr lineNumber ; continue }
        $h insert end "$lineNumber " gray
        set score [scoreToMate [lindex $pv 1] [lindex $pv 2] $n]
        append line [format "%2d %s %s\n" [lindex $pv 0] $score [addMoveNumbers $n [::trans [lindex $pv 2]]] ] 
        incr lineNumber
      }
    }
  } else  {
    # original Scid analysis display
    append line [format "%2d %+5.2f %s (%.2f)\n" $analysis(depth$n) $score [::trans $moves] $analysis(time$n)] 
  }

  ### Should we truncate line so it only takes up one line ? S.A.
  $h insert end $line indent
  # $h see end-1c
  set pos [lindex [ .analysisWin$n.hist.ybar get ] 1]
  if {$pos == 1.0} {
    $h yview moveto 1
  }


  $h configure -state disabled
  set analysis(prev_depth$n) $analysis(depth$n)
  if { ! $analysis(uci$n) } {
    $t insert end [::trans $moves] blue
  }
  $t configure -state disabled

  updateAnalysisBoard $n $analysis(moves$n)
}

################################################################################
# args = score, pv
# returns M X if mate detected (# or ++) or original score
################################################################################
proc scoreToMate { score pv n } {

  if {$::analysis(lockEngine$n)} {
    return [format "%+5.2f" $score]
  }

  if { [string index $pv end] == {#} || [string index $pv end] == {+} && [string index $pv end-1] == {+}} {
    set plies [llength $pv]

    set mate [expr $plies / 2 + 1 ]

    set sign {}
    if {[expr $plies % 2] == 0 && [sc_pos side] == {white} || [expr $plies % 2] == 1 && [sc_pos side] == {black}} {
      set sign -
    }
    if {[sc_pos side] == {white} } {
      if { $sign == {} } {
        set mate [expr $plies / 2 + 1 ]
      } else  {
        set mate [expr $plies / 2 ]
      }
    } else  {
      if { $sign == {} } {
        set mate [expr $plies / 2 ]
      } else  {
        set mate [expr $plies / 2 + 1 ]
      }
    }

    set ret M$sign$mate
  } else  {
    set ret [format "%+5.2f" $score]
  }

  return $ret
}
################################################################################
# returns the pv with move numbers added
# ::pgn::moveNumberSpaces controls space between number and move
################################################################################
proc addMoveNumbers { e pv } {
  global analysis

  if { $analysis(lockEngine$e) } {
    set n $analysis(lockN$e)
    set turn $analysis(lockSide$e)
  } else {
    set n [sc_pos moveNumber]
    set turn [sc_pos side]
  }

  if {$::pgn::moveNumberSpaces} {
    set spc { }
  } else {
    set spc {}
  }
  set ret {}
  set start 0
  if {$turn == {black}} {
    set ret "$n.$spc... [lindex $pv 0] "
    incr start 
    incr n
  }

  for {set i $start} {$i < [llength $pv]} {incr i} {
    set m [lindex $pv $i]
    if { [expr $i % 2] == 0 && $start == 0 || [expr $i % 2] == 1 && $start == 1 } {
      append ret "$n.$spc$m "
    } else  {
      append ret "$m "
      incr n
    }
  }
  return $ret
}
################################################################################
# toggleAnalysisBoard
#   Toggle whether the small analysis board is shown.
################################################################################
proc toggleAnalysisBoard {n} {
  global analysis
  if { $analysis(showBoard$n) } {
    set analysis(showBoard$n) 0
    pack forget .analysisWin$n.bd
    # setWinSize .analysisWin$n
    bind .analysisWin$n <Configure> "recordWinSize .analysisWin$n"
  } else {
    bind .analysisWin$n <Configure> {}
    set analysis(showBoard$n) 1
    pack .analysisWin$n.bd -side bottom -before .analysisWin$n.hist 

    update
    ### these are too wayward S.A
    # .analysisWin$n.hist.text configure -setgrid 0
    # .analysisWin$n.text configure -setgrid 0
    # set x [winfo reqwidth .analysisWin$n]
    # set y [winfo reqheight .analysisWin$n]
    # wm geometry .analysisWin$n ${x}x${y}
    .analysisWin$n.hist.text configure -setgrid 1
    .analysisWin$n.text configure -setgrid 1
  }
}
################################################################################
# toggleEngineInfo
#   Toggle whether engine info are shown.
################################################################################
proc toggleEngineInfo {n} {
  global analysis
  if { $analysis(showEngineInfo$n) } {
    .analysisWin$n.text configure -height 2
  } else {
    .analysisWin$n.text configure -height 1
  }
  updateAnalysisText $n
}
################################################################################
#
################################################################################
# updateAnalysisBoard
#   Update the small analysis board in the analysis window,
#   showing the position after making the specified moves
#   from the current main board position.
#
proc updateAnalysisBoard {n moves} {
  global analysis
  # PG : this should not be commented
  if {! $analysis(showBoard$n)} { return }

  set bd .analysisWin$n.bd
  # Temporarily wipe the premove command:
  sc_info preMoveCmd {}
  # Push a temporary copy of the current game:
  sc_game push copyfast

  # Make the engine moves and update the board:
  sc_move_add $moves $n
  ::board::update $bd [sc_pos board]

  # Pop the temporary game:
  sc_game pop
  # Restore pre-move command:
  sc_info preMoveCmd preMoveCommand
}

################################################################################
# updateAnalysis
#   Update an analysis window by sending the current board
#   to the engine.
################################################################################

proc updateAnalysisWindows {} {
  for {set i 1} {$i <= [llength $::engines(list)]} {incr i} {
    if {[winfo exists .analysisWin$i]} {
      updateAnalysis $i
    }
  }
}

proc updateAnalysis {{n 1}} {

if {[info exists ::comp(playing)] && $::comp(playing)} {return}

  global analysisWin analysis windowsOS
  if {$analysis(pipe$n) == {}} { return }

  # Just return if no output has been seen from the analysis program yet:
  if {! $analysis(seen$n)} { return }

  # No need to update if no analysis is running
  if { ! $analysis(analyzeMode$n) } { return }

  # If too close to the previous update, and no other future update is
  # pending, reschedule this update to occur in another 0.3 seconds:
  #
  if {[catch {set clicks [clock clicks -milliseconds]}]} {
    set clicks [clock clicks]
  }
  set diff [expr {$clicks - $analysis(lastClicks$n)} ]
  if {$diff < 300  &&  $diff >= 0} {
    if {$analysis(after$n) == {}} {
      set analysis(after$n) [after 300 updateAnalysis $n]
    }
    return
  }
  set analysis(lastClicks$n) $clicks
  set analysis(after$n) {}
  after cancel updateAnalysis $n

  set old_movelist $analysis(movelist$n)
  set movelist [sc_game moves coord list]
  set analysis(movelist$n) $movelist
  set nonStdStart [sc_game startBoard]
  set old_nonStdStart $analysis(nonStdStart$n)
  set analysis(nonStdStart$n) $nonStdStart

  # No need to send current board if engine is locked
  if { $analysis(lockEngine$n) } { return }

  if { $analysis(uci$n) } {
    sendToEngine $n stop
    set analysis(waitForBestMove$n) 1
    vwait analysis(waitForBestMove$n)
    sendToEngine $n "position fen [sc_pos fen]"
    sendToEngine $n {go infinite}
    set analysis(fen$n) [sc_pos fen]
    set analysis(maxmovenumber$n) 0
  } else {
    ### what a fucking mess

    # This section is for engines that support "analyze":
    if {$analysis(has_analyze$n)} {
      sendToEngine $n "exit"   ;# Get out of analyze mode, to send moves.
      
      # On Crafty, "force" command has different meaning when not in
      # XBoard mode, and some users have noticed Crafty not being in
      # that mode at this point -- although I cannot reproduce this.
      # So just re-send "xboard" to Crafty to make sure:

      ### try living without this S.A.
      # if {$analysis(isCrafty$n)} { sendToEngine $n xboard }
      
      sendToEngine $n "force"  ;# Stop engine replying to moves.
      # Check if the setboard command must be used -- that is, if the
      # previous or current position arose from a non-standard start.
      
      #if {$analysis(has_setboard$n)  &&  ($old_nonStdStart  || $nonStdStart)}
      # We skip all code below if the engine has setboard capability : this is provides less error prone behavior
      if {$analysis(has_setboard$n)} {
        sendToEngine $n "setboard [sc_pos fen]"
        # Most engines with setboard do not recognize the crafty "mn"
        # command (it is not in the XBoard/WinBoard protocol), so only send it to crafty:
        if {$analysis(isCrafty$n)} { sendToEngine $n "mn [sc_pos moveNumber]" }
        sendToEngine $n analyze
        return
      }
      
      # If we need a non-standard start and the engine does not have
      # setboard, the user is out of luck:
      if {$nonStdStart} {
        set analysis(moves$n) "  Sorry, this game has a non-standard start position."
        updateAnalysisText $n
        return
      }
      
      # Here, the engine has the analyze command (and no setboard) but this game does
      # not have a non-standard start position.
      
      set oldlen [llength $old_movelist]
      set newlen [llength $movelist]
      
      # Check for optimization to minimize the commands to be sent:
      # Scid sends "undo" to backup wherever possible, and avoid "new" as
      # on many engines this would clear hash tables, causing poor
      # hash table performance.
      
      # Send just the new move if possible (if the new move list is exactly
      # the same as the previous move list, with one extra move):
      if {($newlen == $oldlen + 1) && ($old_movelist == [lrange $movelist 0 [expr {$oldlen - 1} ]])} {
        sendMoveToEngine $n [lindex $movelist $oldlen]
        
      } elseif {($newlen + 1 == $oldlen) && ($movelist == [lrange $old_movelist 0 [expr {$newlen - 1} ]])} {
        # Here the new move list is the same as the old list but with one
        # less move, just send one "undo":
        sendToEngine $n undo
        
      } elseif {$newlen == $oldlen  &&  $old_movelist == $movelist} {
        
        # Here the board has not changed, so send nothing
        
      } else {
        
        # Otherwise, undo and re-send all moves:
        for {set i 0} {$i < $oldlen} {incr i} {
          sendToEngine $n undo
        }
        foreach m $movelist {
          sendMoveToEngine $n $m
        }
        
      }
      
      sendToEngine $n analyze
      
    } else {
      
      # This section is for engines without the analyze command:
      # In this case, Scid just sends "new", "force" and a bunch
      # of moves, then sets a very long search time/depth and
      # sends "go". This is not ideal but it works OK for engines
      # without "analyze" that I have tried.
      
      # If Unix OS and engine wants it, send an INT signal:
      if {(!$windowsOS)  &&  $analysis(send_sigint$n)} {
        catch {exec -- kill -s INT [pid $analysis(pipe$n)]}
      }
      sendToEngine $n new
      sendToEngine $n force
      if { $nonStdStart && ! $analysis(has_setboard$n) } {
        set analysis(moves$n) "  Sorry, this game has a non-standard start position."
        updateAnalysisText $n
        return
      }
      if {$analysis(has_setboard$n)} {
        sendToEngine $n "setboard [sc_pos fen]"
      } else  {
        foreach m $movelist {
          sendMoveToEngine $n $m
        }
      }
      # Set engine to be white or black:
      sendToEngine $n [sc_pos side]
      # Set search time and depth to something very large and start search:
      sendToEngine $n {st 120000}
      sendToEngine $n {sd 50}
      sendToEngine $n post
      sendToEngine $n go
    }
  }
}
################################################################################
#
################################################################################

set temptime 0
trace variable temptime w {::utils::validate::Regexp {^[0-9]*\.?[0-9]*$}}

proc setAutomoveTime {{n 1}} {
  global analysis temptime dialogResult
  set ::tempn $n
  set temptime [expr {$analysis(automoveTime$n) / 1000.0} ]
  set w .apdialog
  toplevel $w
  #wm transient $w .analysisWin
  wm title $w "Scid: Engine thinking time"
  wm resizable $w 0 0
  label $w.label -text "Set the engine thinking time per move in seconds:"
  pack $w.label -side top -pady 5 -padx 5
  entry $w.entry -width 10 -textvariable temptime
  pack $w.entry -side top -pady 5
  bind $w.entry <Escape> { .apdialog.buttons.cancel invoke }
  bind $w.entry <Return> { .apdialog.buttons.ok invoke }

  addHorizontalRule $w

  set dialogResult {}
  set b [frame $w.buttons]
  pack $b -side top -fill x
  button $b.cancel -text $::tr(Cancel) -command {
    focus .
    catch {grab release .apdialog}
    destroy .apdialog
    focus .
    set dialogResult Cancel
  }
  button $b.ok -text OK -command {
    catch {grab release .apdialog}
    if {$temptime < 0.1} { set temptime 0.1 }
    set analysis(automoveTime$tempn) [expr {int($temptime * 1000)} ]
    focus .
    catch {grab release .apdialog}
    destroy .apdialog
    focus .
    set dialogResult OK
  }

  pack $b.cancel $b.ok -side right -padx 5 -pady 5
  focus $w.entry
  update
  catch {grab .apdialog}
  tkwait window .apdialog
  if {$dialogResult != "OK"} {
    return 0
  }
  return 1
}

proc toggleAutomove {{n 1}} {
  global analysis
  if {! $analysis(automove$n)} {
    cancelAutomove $n
  } else {
    set analysis(automove$n) 0
    if {! [setAutomoveTime $n]} {
      return
    }
    set analysis(automove$n) 1
    automove $n
  }
}

proc cancelAutomove {{n 1}} {
  global analysis
  set analysis(automove$n) 0
  after cancel "automove $n"
  after cancel "automove_go $n"
}

proc automove {{n 1}} {
  global analysis autoplayDelay
  if {! $analysis(automove$n)} { return }
  after cancel "automove $n"
  set analysis(automoveThinking$n) 1
  after $analysis(automoveTime$n) "automove_go $n"
}

proc automove_go {{n 1}} {
  global analysis
  if {$analysis(automove$n)} {
    if {[makeAnalysisMove $n]} {
      set analysis(autoMoveThinking$n) 0
      updateBoard -pgn
      after cancel "automove $n"
      ::tree::doTraining $n
    } else {
      after 1000 "automove $n"
    }
  }
}


################################################################################
# If UCI engine, add move through a dedicated function in uci namespace
# returns the error caught by catch
################################################################################
proc sc_move_add { moves n } {
  if { [info exists ::analysis(uci$n)] && $::analysis(uci$n) } {
    return [::uci::sc_move_add $moves]
  } else  {
    return [ catch { sc_move addSan $moves } ]
  }
}
################################################################################
# append scid directory if path starts with .
################################################################################
proc toAbsPath { path } {
  set new $path
  if {[string index $new 0] == {.} } {
    set scidInstallDir [file dirname [info nameofexecutable] ]
    set new [ string replace $new 0 0  $scidInstallDir ]
  }
  return $new
}
################################################################################
#
################################################################################
image create photo tb_cpu -data {
R0lGODlhGAAYAOeiAAAAAAABAQECAgICAgIDAwUFBQYGBgYHCAgICDE1JzI1JzI2JzM3KDU5
Kjg8LTk9Ljk9Lzo+MDs/MTtALDxAMj1AMjxCLTxCLj1BMj5CND9FMEJIMkNKM0VMNE5VPFFX
P1ZfQlheR11mR15TuWBmUGFqSWJoU2FrSmNtS2RtTGNZvGRuTGVvTWVbvWZwTWdxTmddvmlv
Wml0UGp0UGthwGx2Umx2U2x3Um50YG1jwW14U255U255VG55VW9lwm96VG96VXB7VXB7VnF8
V3J8WHN5ZnJ9V3J9WHNpxHN+WXR/WnaAXHeBXXl+bHeCXnp/bXlvx3iDX3qAbXuAbnqEYXyB
b3txyHuFYn2CcHyGY3yGZH1zyX2HZX6HZYGCgYCFdH92yn+JZ4CKaIF4y4GLaYOId4KMa4WO
boaQcId+zomSc4qTdYuD0IyVd42Vd4+H0pCZe5WUipWVjJKK05KbfpSM1JaO1ZefhJiR1pqT
152V2KKhmJ+Y2aGa2qOd26af3Kii3a2to6+p4LGs4bax47iz5L29tr245sDAwMTDusXFvMnI
wMzLw9jSm9nTnNDQx9rTnN7Xn9bVzuLcouTdpOXepOfgpujhpt7e1+nip+rjqODf2uDf3ODg
3OHg3O3mqu3mq+3mrP//////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
/////////////////////////////////yH5BAEKAP8ALAAAAAAYABgAAAj+AP8JHEiwoMGD
CBMqRAigoUMABh9K/AdAlMWLoiASBNBD0xFQH4mEoojxosaBAG5UqkHphqUZk0iWzLiRwYIG
DypEkABhgcySEB0ykFJmyhcpRXDEIEERkdOniIKCytTgyR06a9SYMXNFyU+MQZPocIAFzpks
YboYCfLjq0mKmjI9qOLGDJdOnjY94uHWYtAhQDBgaSNGCydJjBLpoOilsWMvQT9dotAEjZMo
mBYp2iPjX4FDhAgVKjRIT9AjQjLgIEMliaFAcuKs+GeAECBAfvTgSRNZrokuSYKw1cHiBO1B
fvrosWNnS9AlNhiEYLJDRooSIkCAoC2oT546deZwQAnakMEHDx04aLAw4cKGfwi62wH/BsnJ
8gsS5Few/98BQHiAVwcbNJwkEAAyROICJC84gkIj/wjwR4BzvDFGDgEUBEAQn3Do4Sf/EMAH
GySCYQUMBlIkkUP/DGAFEj7A0IIKI6S40IoNLaTjjjsGBAA7
}
image create photo tb_training -data {
R0lGODlhGAAYAOedAAICAggICAkJCQoJCAoKCgsLCw0NDQ4ODhISEhQUFB0d
HR4eHh8eHSAeHiIfHCQgHigjHiUlJSokICYmJiwlHi0lHycnJicnJygoKCkp
KSoqKjIoICsrKywsLC0tLUApFi4uLi8vLzAwMDExMTMzMz8/P0BAQEJCQkND
Q0REREVFRcRkFs5rG8hwKNBvIdRuHKF+YttyHqt/XMN6P9J2LNd1JoyMjMR+
RuR4IeR4Io+Pj+R5IuV5IsuARJKSkpOTk6eQfZWVlZaWluaCMJeXl8yKVJiY
mPGBJpmZmfKCJvOCJ5qampubm5ycnNGOWb6Ucp2dnZ+fn6CgoKGhoaKioqSk
pOuSSqWlpaampqenp9+ZYaioqKmpqdidbqqqquyZVriom6ysrK6urtakfK+v
r7mtpLCwsLKysrOzs7S0tLa2tre3t7i4uLm5ubq6uru7u9a0mcC8usDAwMTE
xMfHx8jIyMnJycrKyt7GssvLy8zMzM/MyM3Nzc7Ozs/Pz9DQ0NHR0dLS0tTU
1NXV1dbW1tfX19jY2NzX1NnZ2dra2tvb29zc3N3d3d7e3t/f3+Dg4OHh4eLi
4uTk5OXl5ebm5ufn5+jo6Onp6erq6uvr6+zs7O3t7e7u7v//////////////
////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
/////////////////////yH5BAEKAP8ALAAAAAAYABgAAAj+AP8JHEiwoMGD
BoUsWACBgRCEEP81MPLFihYJEQ+C2DBEiRIeOR5kLAjCCY4jR3LUqDCSIIgi
MXDgiOGCQsuBIGDQePGCRQ8HNwWCACGjxYobFkAEFarCTxkVSpcKvODHTwip
AyNUVYH13wIjVYV4GKkChYqzKqpU3ZoCBYoTJrgWHLG2qo4ma3/UjUKCZNO6
UJYYEfLDR10/KhQQ5HC4KhMbQX4QaTyWqZ8xXfA03oy4hFA/cHYkmcF584XP
fsAAiVO68dV/IFqXnpNBoAc5b9ywUZMGzRkzYsJ44bIFSxUqU6JEwSCwAxI3
bdbw/k0muJctWa4clxJFymmhIDwUiO9AnoOG8xkyYFh/4cIEuV0HBgQAOw==
}

image create photo tb_addmove -data {
R0lGODlhGwAbAOMPAM0AI80AJ80CKc4HLs4NMs8WOc8WOtFCXdRxhNR0htN9
jdV8jdjCxtjCx9r38v///yH+FUNyZWF0ZWQgd2l0aCBUaGUgR0lNUAAh+QQB
CgAPACwAAAAAGwAbAAAEX/DJSau9OOvNu/9gKFJNM1aKYSjnhAAA0kpJECSz
swjC4ogKRGJxGAwOiwSC1WkYAAHBgEAYCAIAg8cJlVKtWK0nOCwek0uRjueb
1W6zxysWVxQKzBmDEe/7/4CBgiMRADs=
}

image create photo tb_update -data {
R0lGODlhGAAYAOfCAEm5Sly3Sme+Qmi/Q2a9XnG/RHTAPXLARXPBRnHBTXLCTnzAP2vCY3fD
QXbDSH3BQHTDT3zBR3DBaXnEQnfESX7CQXLEV3jFSnbFUYDDQnTFWILEO2/GZnjDXoHEQ4PF
PHbEZonDO4LFRITGPX7FU3zFWnrFYIrEPIPGRXvDbH/GVHvGYYbHPovFPYTHRnbHbn7HXIfI
P4zGPoXIR3fIb3zIYnrIaY/HN4nGTo3HQIPGYoHGaZDIOIfKSYTHY3nKcYDKXpHJOYvIUH3I
d5LKOn7JeJfIOoHJcZDKQ4jKX5PLPIbKZY3KUoTKbJjJO5XMNIjIcZDLTJTMPYXLbYnJcpjK
RJzLNJXNPprLPZHNTZ3MNYjLe57NNp/ON4rNfYjNg43Nd6DPOaLQMKXNOI7LgqfOL47OeKbO
OZHMfajPMKfPOqnQMpPOf6rRM6fQRK3SKazSNJPQh5DTgrHRNbTSK6/VLLLSNrXTLa7VN5XT
ibTTN53Td7bULrfVL7vTL5rTkbzUMKnTbJbWk7jXMZ3WgL7VMcDWJ7fXO7nYMp/VjZ3Vk7/W
MsHXKLjYPJ7WlMDXNKTXiMHYNcPZK8XbH7/cLKDYlr7YRsnYLL3YTr/ZR6bXlsPbOKrYkcnZ
OMvaL6bbk8HbSsfdL63ZjKvZks7cJczbMMvbO83cMcXdQ8feO7Lbh8beRdDfKM7eM7PciK/a
oM3ePbnaibjdfdXdNdHgNdbeNq/dqtXeQNHhQb7ehbzejNniQ7nfrdvjO9jiTNrjRdvkRuTm
Sv//////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
/////////////////////////////////yH+FUNyZWF0ZWQgd2l0aCBUaGUgR0lNUAAh+QQB
CgD/ACwAAAAAGAAYAAAI/gD/CRxIsKDBgwSLNGEiRBBChENWRMEELBgoCQ8J/jARJZOvXaYe
dQLFIKNAEpaC3erkZ5CfQ49MBRj4goQGgzbc3HrUBxGfPn4erQIgkEwjXLd6OCoYB4epTnai
3rFkioNAGLf4WGo1w6AgLKb8RLVDxxQagVNm+XlDdUXBJqHw2Hn0SK4pMwJfeWhFZ26Ygkge
tWlTatCsQaWODNRU5dEcO546DLRRx8+cR1WOSCFVSwdBKpTsqOnkYSCNR2fGkCrxT5GKNzsI
yhEzZ86gGAPNMBrDhVFsgVQUFXxiZ8ygJwO9+MGC5ZLih07aYJmDZCCBOm5u9Lnw8EsbLUro
mZQeGMRKDixjUiDE4CdHjjmsB0KY02LEmg1sDO4QEySEkTBeEJSCEjlsgEMYOYBAhkBbQBCG
ERlEEUYEBpXAxQYZZBAEF0GgMAJ6IiwwQRUfQHEQCVZkUIADEUzwgQgqGpBEILIId9ArCRgR
QgE8FiAACTrsEUssvJjUgQM5nJBBEnuIokssoxRpEoNgQMKJKJzYYsuUXBoUEAA7
}

image create photo tb_annotate -data {
R0lGODlhGAAYAOfzAAAAAAIAAAMAAAYAAAUFBRIMCw4ODisLBBQUFCUSDiIXFR8fHygoKDg4
OE9BFVpQLlxQK2FWL2JWN2FXOGVZMGZaMrs3GWxfNGFhYWdjWcBGK8FGKm9rY8NMMd9CHsRU
O3R0cnV0cs9SNcdXPtxQMN9PLnx4b3p6d9xWOHx7echhSslkS4CAf4GAf4KBfuNdP4OCgN9f
QYODgYSDgYaFgt9jRsxtWIiIhZCKgeVpTuJrUN9yWNB4ZZOTkJSUkd94X916Y5qVipuVit96
YpuWipiXlJeXl5iXl52Xi5mYkeh5YJ2XjJmYl56Yjed7Y5uZl5+ZjZ+Zjpqal5qamZual5+a
jqCajpubmaGbj6GbkJycnKGckOeBa6OdkaOdkp6enp+enKOekueDbaSek5+fnqGfnKGgnaGh
oKGhodeQfaWjoKSko+qMd+KPfamppqqppquqp6urqqyrqKurq6yrqa2rqa2sqe2kPq+vrrCv
rbCvrrGwrrOyr+eejbOysfCpP7Ozs7SzsbSzsrS0steudLW0srW0s7W1s7W1tLW1tba1tLe2
tbi3tPOvQrm3tri4trm4uLm5ubq5t/SyRO+0Tbu7ufe1RPK2Tfe1Rb29vO6rm8C/vMDAwMPC
vsXEwcnJx8rKyM3LyPbSNs3My83Nzc/OytDOyvjYN9DQz9LRzdHR0dPSzvncONTTz9PT0tPT
09XTztbU0PnfOdfV0dfW0dbW1tjW0djW0tnX09nX1PrkOtrZ1dvZ1fvnO9za1tza2Nzb2Nzb
2fzpO9zc2t3c2N3c2t7d2fzrPd/e2uDe2t/f3eDf2+Hf2+Hf3OHg3ODg3+Hg3eLh3ePi4OTj
4OXj4OXk4eTk5Obl4ufm4+jn5Ofn5+np6evq6Ozr6e3s6u3t6+3t7e/v7vDw7vDw8PHw7vLy
8vPy8fTz8vT09Pb19Pb29vj39vj49/n5+Pn5+fr6+fv7+/z8+/7+/v//////////////////
/////////////////////////////////yH5BAEKAP8ALAAAAAAYABgAAAj+AP8JHJhAQIAB
BwYqXKgQgEMdKEigEOGwogEGGBj+A/BKHQBNfdoAWQGglrt27bRZI7WAIQB18wCI+TFkx4gC
tea1C4dn2zxADRYCmBeTS40YNToUQMMpU6I14+ahm0OgIVEATkpo3aDAFbx25b5UdGg1phIP
aC0AIJMpU6QzjmTMIDtwqDwAZ9MCQLWunblnvz4B6HUJQN158RCwecH4AwAtlSAtUmQIwDFL
EAwLHPoOAJscoFUgGHWutDkAwjBd0Lx5HjvPPADwsIFgyiNEgQDomjSBbut0ANIAiANAAwBQ
5LwBkNVIAgAOrDfOOzcFAAsjTAC0ODIIACtKFQDYPDERfeg5c8o+DSNXTFIwAKf+UABwxQ6O
8vPEIUJ0qJAgQX4AIModDwAAAgyeBIHfN9504yA32UgDACERACDFG520EgV+3Oyxhx555EEH
AA44FIILPZixSxb4YXPNi9VQA4xDRVABRyer4IILFOW5Mw0dctRhhxtg3HBCCjT4UIYaatzS
RHngQNOMM8tEY0wqjPCxSSix8IKLLbMgUZ4qzCSDjDHLEJNLKaZ0yYsvt9ACixDlJRHGGF50
4cUWWFRhhRVZQAHFEksQkUF0G42l6KK+aeToowEBADs=
}

image create photo tb_play -data {
R0lGODlhGAAYAKUjAAAAAGxranJxcHt7en18e39+fYKBgIaFg4mIhoyLiY+OjJCPjZmZlp2c
mqGfnaGgnqWkoaemo6mopbCvrLSzsbWzsba0srm2tLm3tLq5try6t728ucPCv8XDwMfGw8fG
xNDOzNLRztjX1f//////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////yH+FUNyZWF0ZWQg
d2l0aCBUaGUgR0lNUAAh+QQBCgA/ACwAAAAAGAAYAAAGXsCfcEgsGo/IpHLJbDoBziQAGjUC
BNTqEDAIZLWAAoPwjQIMjcmi3AQcHhQLhL0EICCYjIYDGJkTEhsdIH1VAAoVHiGFhg0XIoyG
Dh+RhhGVhpiGflpEnJ2goaKjSEEAOw==
}

image create photo tb_pause -data {
R0lGODlhGAAYAIQcAAAAAHNzcn5+fYSEg4WEg4iIh5GQjqSko6aloqalpKinpqqpp66tqa+u
rLKwrbWzsLW0s7u6t7+9usC/vsPBvsrKyNHPzNTT0tfV09nY1t7d2/Pz8///////////////
/yH+FUNyZWF0ZWQgd2l0aCBUaGUgR0lNUAAh+QQBCgAfACwAAAAAGAAYAAAFeOAnjmRpnmiq
rmzrviYgy9xMs0AwFECt8xycQHHoAYbF4OqYgBgFzR6OsJgYqValCmBoVIzdrzbF9YLNY1RZ
vJYuEZGLES5PnwD0edy9ZUgwRn6AdjEOFBlGhoiEJQAPFhpGj5GMJDZGNpUjHJycG52dMKKj
pKUsIQA7
}

image create photo tb_addallvars -data {
R0lGODlhHgAeAMZFAAAAAAQEBAcHBwkJCQsLCwwMDA0NDQ8PDxERERQUFBYW
FhcXFxgYGBkZGRsbGxwcHCIiIi4uLjo6Os0AI80AJ80CKUREREZGRs4HLs4N
Mk5OTk9PT88WOc8WOlJSUlVVVVdXV1lZWVxcXGBgYGFhYWJiYmNjY2dnZ9FC
XXNzc39/f4ODg4mJiYuLi9RxhNR0hpOTk5aWlpeXl9N9jdV8jZqamp2dnaCg
oKOjo6SkpKampqenp6mpqaqqqqurq6ysrLi4uMLCwtjCxtjCx9r38v//////
////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
/////////////////////////////////////////////////yH+FUNyZWF0
ZWQgd2l0aCBUaGUgR0lNUAAh+QQBCgB/ACwAAAAAHgAeAAAH/oB/goOEhYaH
iImKi4yNjo+QkZKTgyMAlzuHLJc4jjuXACOHFgAIkAqXDIcCAB6HQ0OFsB6g
PIUwlzKGMx0dM4O8EzOgJIUaAAOHLhMTLoPLwrQADYUGABeGRDQVFTREf9rc
MymgPYM2ly2EMy40KBgYKDQuM+/xNKAlgyAAAYRDHSZUwJAhA4YKEzoQNIhB
moNBCQBI+BdwYMGDCRfCwwDKxx8dl1QUYucOnjx69uThu2TiD4lLQQ6F6/Zt
prcUBy49+PMAQIRE0JwJCipIGoAVl1IkmsGBwy9BTJ0KqgGqwCUgioQIKaSV
kDVQECgR2gAKwAmxg2KU/YF2EIFLDAvayp1Lt67du4UCAQA7
}

# image create photo tb_engineinfo -data {
# R0lGODdhFAAUAMIFAAAAAAAA/7i4uMDAwO7v8v///////////ywAAAAAFAAU
# AAADUEgarP6QsNkipIXaR/t2mPeF2jhl5UY2AtG+rXRqQl27sSx+XMVHgKBw
# SAQ8ikihQ2irDZtGRXK6nCKXUEDWNngIgltbsFsFf5nnIERdPRoTADs=}

image create photo tb_lockengine -data {
R0lGODlhGAAYAOd6AAAAAAwFABUJAg8PDxUQDBMTExQUFB0XEBwcHCUdFSEh
ISkhGjIhEC4kGS8lGycnJykpKTkrHTU1NTw8PEo5K0VFRW1CFUxMTFZTUl5a
Vl9fX2FhYGVjYZdcGpddGpheGppeG2pqaptgHqNrL6ZxN7B1MKl3PKt4P7J3
M7N4NLR4NLN5NLJ6PLJ7O7Z8NrZ9OLZ9Ord9ObR/Q7SBRbmAPbSCQLSBRraC
QbmBP7qBPrSDSbeDQrqDP7WETLqEQriFRLmFSLaGTLWITbyGRbeHTrqHSryH
RryHSLqISbmITruJSayMZbyKS76KTLqLUrqMVLqMVZSUlLuNVbuOVryOVsCN
Ub2OVryPWL2QWMCRVcCSVr+SWsCTWMSSVsGVXMKVXMKWXMOWX56ensaYVsOY
YMaYWMeYWMSZYMSZYcaYYaCgoKGhocabZMacZMibZ8ecZcmdYcidZcidZsqd
YcieZsifaMqfY8mfaMqebcqfaMuja8yka8ykbMykbc2kbc6ka8ylbc6kbsym
bc6mb9ClcM+mcM+ncM+ncs+nfNKndtCpcdGodNOqetOqe7KystKtdtOse9Su
d9auf9KvhdSwfNavgLa2tre2ttewgNizf9m0hNW2jtq2hde7ldm+mdq+mcPD
w+G9lNzAnd/AluDAmeDBmeLCm+PCnMjIyOPDnOTEneTGoM/Pz9DQ0OXQs9XV
1efSudbW1tjY2OnVvtnZ2e7Vt+3WuO7Yuu7Yu+7YvO/Yu+3ZwN3d3e/avvDa
v+/bv97e3uHh4eLi4ubm5ufn5+np6e3t7e/v78uja8uja8uja8uja8uja8uj
a8uja8uja8uja8uja8uja8uja8uja8uja8uja8uja8uja8uja8uja8uja8uj
a8uja8uja8uja8uja8uja8uja8uja8uja8uja8uja8uja8uja8uja8uja8uj
a8uja8uja8uja8uja8uja8uja8uja8uja8uja8uja8uja8uja8uja8uja8uj
a8uja8uja8uja8uja8ujayH5BAEKAP8ALAAAAAAYABgAAAj+AP8JHEiwoMGD
CBMqHAigYcOFBgEoEDOMGCo1BSAy1GBsWKxXvGStmQBAo4RjrC40NBCilaMK
EAEIkwWhpMABIVBFsZmwQDFQPAUiCCYm6MEHwCwZBUDsklGCAhok2JBhAQEH
CQ4koMABQwQGAQ4C+LVrFixXojx5+uSp06ZJiEA8/QfA16pKkAjdYdNGzhsy
Woa4+DAXQK5UlRoVytOGTh06aLgYiSFXLC5TkvCk2TLFCpYrSWb4UNGhcC9V
mDhRUvTHj6A9dszgSOGhsK5SjNyEoeLkiRQoQWTwWCGicK5TkjRFMrRHDx89
c8bkQDGisK1Qi9JgIaKjh5AgNlhKwChBovAtUo0yPRq0pw8gPnDK0HhxonCt
UYkCxTnj5QsYMFkw4UMTJhS2xCFdVIHEDjXc8IMSRxQBRAsWzEWXQxhm+JBG
HHaYUEAAOw==}
