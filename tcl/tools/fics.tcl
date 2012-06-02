###
### fics.tcl: part of Scid.
###
### Copyright (C) 2007  Pascal Georges
### Copyright Stevenaaus 2010-2012

namespace eval fics {
  set server "freechess.org"
  set sockchan 0
  set seeklist {}
  set mainGame -1
  set observedGames {}
  set playing 0
  set opponent {}
  set mutex 0
  set waitForMoves ""
  set sought 0
  set soughtlist {}
  set graphwidth 300
  # Fine tuned to be the same height as clocks , but needs re-tuning after making the observed games windgets
  set graphheight 200 
  set graphoff 15 ;# axis offset
  set graphon 0
  set timeseal_pid 0
  font create font_offers -family courier -size 12 -weight bold
  set history {}
  set history_pos 0
  set history_current {}
  set tells {}
  set tellindex 0
  set offers_minelo 1000
  set offers_maxelo 2500
  set offers_mintime 0
  set offers_maxtime 60
  variable logged 0
  set consolewidth 40
  set consoleheight 10

  set ignore_abort 0
  set ignore_adjourn 0
  set ignore_draw 0
  set ignore_takeback 0

  set ping {}
  array set shorttype {
    crazyhouse crazy
    bughouse bug
    standard normal
    lightning light
  }

  proc config {} {
    variable logged
    global ::fics::sockChan tr
    set w .ficsConfig

    if {[winfo exists $w]} {
      focus $w
      return
    }

    if {[winfo exists .fics]} {
      focus .fics
      return
    }
    set logged 0

    toplevel $w
    wm state $w withdrawn
    wm title $w "Configure Fics"
    label $w.lLogin -text "$tr(CCDlgLoginName)"
    entry $w.login -width 20 -textvariable ::fics::login
    label $w.lPwd -text [::tr "CCDlgPassword"]
    entry $w.passwd -width 20 -textvariable ::fics::password -show "*"

    # Time seal configuration
    checkbutton $w.timeseal -text [::tr FICSTimeseal] -variable ::fics::use_timeseal \
      -onvalue 1 -offvalue 0 -command {
        if {$::fics::use_timeseal} {
	  .ficsConfig.timeseal_entry configure -state normal
	  .ficsConfig.timeseal_browse configure -state normal
        } else {
	  .ficsConfig.timeseal_entry configure -state disabled
	  .ficsConfig.timeseal_browse configure -state disabled
        }
    }
    entry $w.timeseal_entry -width 20 -textvariable ::fics::timeseal_exec
    button $w.timeseal_browse -text $tr(Browse) -command { set ::fics::timeseal_exec [tk_getOpenFile -parent .ficsConfig] } -pady 0.8

    if {!$::fics::use_timeseal} {
      $w.timeseal_entry configure -state disabled
      $w.timeseal_browse configure -state disabled
    }
    # label IP address, Refresh button
    label $w.lFICS_ip -text $tr(FICSServerAddress)
    entry $w.ipserver -textvariable ::fics::server_ip -state readonly
    button $w.bRefresh -text $tr(FICSRefresh) -command ::fics::getIP -pady 0.8

    label $w.lFICS_port -text $tr(FICSServerPort)
    entry $w.portserver -width 6 -textvariable ::fics::port_fics
    label $w.ltsport -text $tr(FICSTimesealPort)
    entry $w.portts -width 6 -textvariable ::fics::port_timeseal

    frame $w.button
    button $w.button.connect -text $tr(FICSLogin) -command {
      set ::fics::login     [.ficsConfig.login get]
      set ::fics::reallogin $::fics::login
      set ::fics::password  [.ficsConfig.passwd get]
      ::fics::connect
    }

    button $w.button.connectguest -text $tr(FICSGuest) -command {
      set ::fics::reallogin guest
      ::fics::connect guest
    }

    button $w.button.help -text $tr(Help) -command {helpWindow FICS}

    button $w.button.cancel -text $tr(Cancel) -command {
      destroy .ficsConfig
    }

    ### Pack .ficsConfig widget in grid

    set row 0
    # grid $w.guest  -column 1 -row $row -sticky w
    # incr row
    grid columnconfigure $w 1 -weight 1
    grid $w.lLogin -column 0 -row $row
    grid $w.login  -column 1 -row $row -sticky ew

    incr row
    grid $w.lPwd   -column 0 -row $row
    grid $w.passwd -column 1 -row $row -sticky ew

    incr row
    # horizontal line
    frame $w.line$row -height 2 -borderwidth 2 -relief sunken 
    grid $w.line$row -pady 5 -column 0 -row $row -columnspan 3 -sticky ew

    incr row
    grid $w.timeseal -column 0 -row $row -sticky w

    grid $w.timeseal_entry -column 1 -row $row -sticky ew -padx 2
    grid $w.timeseal_browse -column 2 -row $row -sticky ew -padx 2

    incr row
    grid $w.lFICS_ip -column 0 -row $row
    grid $w.ipserver -column 1 -row $row -sticky ew
    grid $w.bRefresh -column 2 -row $row

    incr row
    grid $w.lFICS_port -column 0 -row $row
    grid $w.portserver -column 1 -row $row -sticky w -padx 2

    incr row
    grid $w.ltsport -column 0 -row $row
    grid $w.portts -column 1 -row $row -sticky w -padx 2

    incr row
    # horizontal line
    frame $w.line$row -height 2 -borderwidth 2 -relief sunken 
    grid $w.line$row -pady 5 -column 0 -row $row -columnspan 3 -sticky ew

    incr row
    grid $w.button -column 0 -row $row -columnspan 4 -sticky ew -pady 3 -padx 5
    foreach i {connect connectguest help cancel} {
      pack $w.button.$i -side left -padx 3 -pady 3 -expand 1 -fill x
    }

    bind $w <Escape> "$w.button.cancel invoke"
    bind $w <F1> {helpWindow FICS}

    # Get IP adress of server (as Timeseal needs IP adress)
    if { $::fics::server_ip == "0.0.0.0" } {
      getIP
    }

    update
    placeWinOverParent $w .
    wm state $w normal
    focus $w.button.connect
    update
  }

  proc getIP {} {
    set b .ficsConfig.bRefresh
    $b configure -state disabled
    busyCursor .
    update

    # First handle the case of a network down
    if {[catch {
          set sockChan [socket -async $::fics::server $::fics::port_fics]
       } err ]} {
	  ::fics::unbusy_config
          tk_messageBox -icon error -type ok -title "Unable to contact $::fics::server" -message $err -parent .ficsConfig
          return
    }

    # Give it 5 tries before giving up
    # Then the case of a proxy
    set timeOut 5
    set i 0

    while { $i <= $timeOut } {
      after 1000

      if { [catch {set peer [ fconfigure $sockChan -peername ]} err]} {
        if {$i == $timeOut} {
          tk_messageBox -icon error -type ok -title "Unable to contact $::fics::server" -message $err -parent .ficsConfig
	  $b configure -state normal
	  unbusyCursor .
          return
        }
      } else  {
        break
      }
      incr i
    }

    set ::fics::server_ip [lindex $peer 0]
    ::close $sockChan
    $b configure -state normal
    unbusyCursor .
  }
    
  proc unbusy_config {} {
    set w .ficsConfig
    # $w.button.connect configure -state normal
    # $w.button.connectguest configure -state normal
    focus $w.button.connect
    unbusyCursor .
  }

  ################################################################################
  #
  ################################################################################
  proc connect {{guest no}} {
    global ::fics::sockchan ::fics::seeklist ::fics::graphwidth ::fics::graphheight fontOptions tr

    if { $guest=="no" && $::fics::reallogin == ""} {
      tk_messageBox -title "Error" -icon error -type ok -parent .ficsConfig \
        -message "No login name specified" -parent .ficsConfig
      return
    }

    # check timeseal configuration
    if {$::fics::use_timeseal} {
      if {![ file executable $::fics::timeseal_exec ]} {
        tk_messageBox -title "Error" -icon error -type ok -message "Timeseal error : \"$::fics::timeseal_exec\" not executable" -parent .ficsConfig
        return
      }
    }
    destroy .ficsConfig

    set w .fics
    toplevel $w
    wm title $w "Free Internet Chess Server ($::fics::reallogin)"
    wm state $w withdrawn

    busyCursor .

    frame $w.console
    frame $w.command
    frame $w.bottom 
    pack $w.console  -fill both -expand 1 -side top
    pack $w.command -fill x -side top
    pack $w.bottom  -side bottom

    frame $w.bottom.buttons
    frame $w.bottom.clocks
    frame $w.bottom.graph 
    scale $w.bottom.scale -orient vertical -from 45 -to 25 -showvalue 0 -resolution 5 -length 240 \
      -variable ::fics::size -command ::fics::changeScaleSize -relief flat

    showClocks
    pack $w.bottom.scale -side left -padx 5 -pady 20

    pack $w.bottom.buttons -side right -padx 10 -pady 20 -anchor center
    # Pack graph when "Offers graph" clicked

    # graph widget initialised
    canvas $w.bottom.graph.c -background grey90 -width $::fics::graphwidth -height $::fics::graphheight
    pack $w.bottom.graph.c

    scrollbar $w.console.scroll -command "$w.console.text yview"

    ### Ok, this seems to be keeping it's shape now 
    # Use of "-height $::fics::consoleheight -width $::fics::consolewidth"
    # just didn't work, and also conflicted with the universal setWinSize procedure

    ### need a config option here... Somewhere! &&&
    text $w.console.text -bg $::fics::consolebg -fg $::fics::consolefg -wrap word -yscrollcommand "$w.console.scroll set" -width 40 -height 10 -font font_Fixed
    ### is font_Regular working here ? &&&
    bindMouseWheel $w $w.console.text 

    pack $w.console.scroll -side right -fill y 
    pack $w.console.text -side left -fill both -expand 1

    ### Console colours
    $w.console.text tag configure seeking -foreground grey
    $w.console.text tag configure tells -foreground coral
    $w.console.text tag configure command -foreground skyblue
    $w.console.text tag configure game -foreground grey70
    $w.console.text tag configure gameresult -foreground SlateBlue1
    $w.console.text tag configure channel -foreground rosybrown

    entry $w.command.entry -insertofftime 0 -bg grey75 -font font_Large
    button $w.command.send -text $tr(FICSSend) 
    button $w.command.clear -text $tr(Clear) -command "
      $w.command.entry delete 0 end"
    button $w.command.clearall -text "$tr(Clear) All" -command "
      $w.console.text delete 0.0 end
      $w.console.text insert 0.0 \"FICS ($::scidName $::scidVersion)\n\"
    "
    button $w.command.next -textvar ::tr(Next) -command {::fics::writechan next echo}
    bind $w.command.entry <Up> { ::fics::cmdHistory up }
    bind $w.command.entry <Down> { ::fics::cmdHistory down }
    bind $w.command.entry <Control-c> {.fics.command.entry delete 0 end}
    bind $w.command.entry <Alt-BackSpace> { 
      # bash like delete last word on command line
      set entry [.fics.command.entry get]
      # break line into two parts (before/after cursor)
      set i [.fics.command.entry index insert]
      set t1 [string range $entry 0 $i-1]
      set t2 [string range $entry $i end]
      if {[string is space [string index $t1 end]]} {
        while {[string is space [string index $t1 end]]} {
          set t1 [string range $t1 0 end-1]
        }
      } else {
	set j [string last { } $t1]
	set t1 [string range $t1 0 $j]
      }
      .fics.command.entry delete 0 end
      .fics.command.entry insert end $t1$t2
      .fics.command.entry icursor [string length $t1]
      break ; # avoid doing a backspace
    }
    bind $w <Control-p> ::pgn::OpenClose
    bind $w <Prior> "$w.console.text yview scroll -1 page"
    bind $w <Next>  "$w.console.text yview scroll +1 page"
    # i cant think how to separate the entry and console bind for 'Home' and 'End'
    # bind $w <Home>  "$w.console.text yview moveto 0"
    bind $w <End>   "$w.console.text yview moveto 1"
    bind $w <F9> {
      # F9 recalls a "tell" history 
      .fics.command.entry delete 0 end
      if {$::fics::tellindex >= [llength $::fics::tells]} {
	# .fics.command.entry insert 0 "tell "
        set ::fics::tellindex 0
      } else {
	.fics.command.entry insert 0 "xtell [lindex $::fics::tells $::fics::tellindex] "
	incr ::fics::tellindex
      }
    }
    bind $w <Escape> "$w.command.entry delete 0 end"


    # steer focus into the command entry, as typing into the text widget is pointless
    bind $w.console.text <FocusIn> "focus $w.command.entry"
    pack $w.command.entry -side left -fill x -expand 1 -padx 3 -pady 2
    pack $w.command.next $w.command.clearall $w.command.clear $w.command.send -side right -padx 3 -pady 2
    focus $w.command.entry

    # black
    ::gameclock::new $w.bottom.clocks 2 100 0 vertical
    # white
    ::gameclock::new $w.bottom.clocks 1 100 0 vertical

    label .board.clock2 -textvar ::gameclock::data(time2)
    label .board.clock1 -textvar ::gameclock::data(time1)
    ::board::ficslabels

    set ::fics::playing 0

    set row 0
    checkbutton $w.bottom.buttons.tells -text Tells -state disabled \
    -variable ::fics::chanoff -command {
      ::fics::writechan "set chanoff [expr !$::fics::chanoff]" noecho
    }
    checkbutton $w.bottom.buttons.shouts -text Shouts -state disabled -variable ::fics::shouts -command {
      ::fics::writechan "set shout $::fics::shouts" echo
      ::fics::writechan "set cshout $::fics::shouts" noecho
      # ::fics::writechan "set gin $::fics::gamerequests" echo
    }

    checkbutton $w.bottom.buttons.offers -text "$tr(FICSOffers) $tr(Graph)" -variable ::fics::graphon -command ::fics::showGraph -width 10 -state disabled
    # -state disabled ; enable for testing S.A. &&&

    grid $w.bottom.buttons.tells      -column 0 -row $row -sticky w
    grid $w.bottom.buttons.shouts	-column 1 -row $row -sticky w
    grid $w.bottom.buttons.offers       -column 2 -row $row -sticky w -padx 2 -pady 2

    incr row
    button $w.bottom.buttons.info2 -text "Opponent Info" -command {
      set t1 [sc_game tags get Black]
      if {[string match -nocase $::fics::reallogin $t1]} {
	set t1 [sc_game tags get White]
      }
      if {$t1 != {} && $t1 != {?}} {
	::fics::writechan "finger $t1"
      }
    }
    button $w.bottom.buttons.info  -text Info -command {
      ::fics::writechan finger
      ::fics::writechan "inchannel $::fics::reallogin"
      # ::fics::writechan history
    }
    button $w.bottom.buttons.font -text Font -command {
      set fontOptions(temp) [FontDialog Fixed .fics]
      if {$fontOptions(temp) != ""} { set fontOptions(Fixed) $fontOptions(temp) }
    }
    set ::fics::graphon 0

    grid $w.bottom.buttons.info  -column 0 -row $row -sticky ew -padx 3 -pady 2
    grid $w.bottom.buttons.info2 -column 1 -row $row -sticky ew -padx 3 -pady 2
    grid $w.bottom.buttons.font  -column 2 -row $row -sticky ew -padx 3 -pady 2

    incr row
    button $w.bottom.buttons.draw    -text {Offer Draw} -command {::fics::writechan draw}
    button $w.bottom.buttons.resign  -text Resign       -command {::fics::writechan resign}
    button $w.bottom.buttons.rematch -text Rematch      -command {::fics::writechan rematch}
    grid $w.bottom.buttons.draw     -column 0 -row $row -sticky ew -padx 3 -pady 2
    grid $w.bottom.buttons.resign   -column 1 -row $row -sticky ew -padx 3 -pady 2
    grid $w.bottom.buttons.rematch  -column 2 -row $row -sticky ew -padx 3 -pady 2

    incr row
    button $w.bottom.buttons.takeback  -text $tr(FICSTakeback) -command {
      ::fics::writechan takeback
      # these two comments gets zero-ed. See "Game out of sync"
      catch { ::commenteditor::appendComment "$::fics::reallogin requests takeback $::fics::playerslastmove" }
    }
    button $w.bottom.buttons.takeback2 -text $tr(FICSTakeback2) -command {
      ::fics::writechan {takeback 2}
      catch { ::commenteditor::appendComment "$::fics::reallogin requests takeback $::fics::playerslastmove" }
    }
    button $w.bottom.buttons.abort  -textvar ::tr(Abort) -command {::fics::writechan abort}
    grid $w.bottom.buttons.takeback  -column 0 -row $row -sticky ew -padx 3 -pady 2
    grid $w.bottom.buttons.takeback2 -column 1 -row $row -sticky ew -padx 3 -pady 2
    grid $w.bottom.buttons.abort     -column 2 -row $row -sticky ew -padx 3 -pady 2

    incr row
    frame $w.bottom.buttons.space -height 2 -borderwidth 0
    grid  $w.bottom.buttons.space -column 0 -row $row -columnspan 3 -sticky ew -pady 3

    incr row
    button $w.bottom.buttons.findopp -textvar ::tr(FICSFindOpponent) -command {::fics::findOpponent}
    button $w.bottom.buttons.quit    -text {Quit FICS} -command {::fics::close}
    button $w.bottom.buttons.help    -textvar ::tr(Help) -command {helpWindow FICS}
    grid $w.bottom.buttons.findopp -column 0 -row $row -sticky ew -padx 3 -pady 2
    grid $w.bottom.buttons.help    -column 1 -row $row -sticky ew -padx 3 -pady 2
    grid $w.bottom.buttons.quit    -column 2 -row $row -sticky ew -padx 3 -pady 2

    incr row
    label $w.bottom.buttons.ping -textvar ::fics::ping -font font_Small
    grid $w.bottom.buttons.ping -column 1 -row $row

    bind $w <Control-q> ::fics::close
    bind $w <Destroy>   ::fics::close
    bind $w <Configure> "::fics::recordFicsSize $w"

    bind $w <F1> {helpWindow FICS}

    # needs a little voodoo to get minsize working properly with setWinSize

    update
    set x [winfo reqwidth $w]
    set y [winfo reqheight $w]

    setWinLocation $w
    setWinSize $w
    wm state $w normal
    update

    # all widgets must be visible
    wm minsize $w $x $y

    ::gameclock::setColor 1 white
    ::gameclock::setColor 2 black

    updateConsole "Connecting $::fics::reallogin"

    # start timeseal proxy
    if {$::fics::use_timeseal} {
      updateConsole "Starting TimeSeal"
      if { [catch { set timeseal_pid [exec $::fics::timeseal_exec $::fics::server_ip $::fics::port_fics -p $::fics::port_timeseal &]} ] } {
        set ::fics::use_timeseal 0
        set port $::fics::port_fics
      } else {
        #wait for proxy to be ready !?
        after 500
        set server "localhost"
        set port $::fics::port_timeseal
      }
    } else {
      set server $::fics::server
      set port $::fics::port_fics
    }

    updateConsole "Socket opening"

    if { [catch { set sockchan [socket $server $port] } ] } {
      unbusyCursor .
      tk_messageBox -title "Error" -icon error -type ok -message "Network error\nCan't connect to $::fics::server $port" -parent .fics
      return
    }

    updateConsole "Channel configuration"

    fconfigure $sockchan -blocking 0 -buffering line -translation auto ;#-encoding iso8859-1 -translation crlf
    fileevent $sockchan readable ::fics::readchan

    unbusyCursor .

    # todo: fix this for windows &&&
    if { ! $::windowsOS } {
      initPing
    }
  }

  proc changeScaleSize {size} {
      foreach w [winfo children .fics.bottom] {
        if {[string match .fics.bottom.game* $w]} {
	  ::board::resize $w.bd $size
        }
      }
  }

  proc recordFicsSize {w} {
    variable logged
    global ::fics::consoleheight ::fics::consolewidth
    recordWinSize $w
    set  t .fics.console.text
    set width  [expr ([winfo width  $t] - 2 * [$t cget -borderwidth] - 4)/[font measure \
      [$t cget -font] 0]]
    set height [expr ([winfo height $t] - 2 * [$t cget -borderwidth] - 4)/[font metrics \
      [$t cget -font] -linespace]]
    incr height 2 ; # for some reason, two bigger is best for fics output

    if {$width != $::fics::consolewidth || $height != $::fics::consoleheight } {
      set ::fics::consolewidth $width
      set ::fics::consoleheight $height
      if {$logged} {
	writechan "set width  $width"  noecho
	writechan "set height $height" noecho
        $w.console.text yview moveto 1
      }
    }
  }


  proc cmd {} {
    set w .fics

    set l [string trim [$w.command.entry get]]
    $w.command.entry delete 0 end
    if {$l == "quit" || $l == "exit"} {
      ::fics::close
      return
    }

    set c [lindex [split $l] 0]
    switch -glob [string trim $c] {
      {}  {
	  updateConsole {}
	  return
	  }
      fg - foreground {
	  set fg [lindex $l 1]
	  if {$fg == {}} {
	    set fg [tk_chooseColor -initialcolor $::fics::consolefg -title {FICS Background} -parent $w]
	  }
	  if {![catch {$w.console.text configure -fg $fg}]} {
	    set ::fics::consolefg $fg
	  }
	  ::fics::addHistory $l
	  return
      }
      bg - background {
	  set bg [lindex $l 1]
	  if {$bg == {}} {
	    set bg [tk_chooseColor -initialcolor $::fics::consolebg -title {FICS Background} -parent $w]
	  }
	  if {![catch {$w.console.text configure -bg $bg}]} {
	    set ::fics::consolebg $bg
	  }
	  ::fics::addHistory $l
	  return
      }

      smoves - smove {
	  # smoves recreates a game without any further announcment
	  if {$::fics::playing == 1 || $::fics::playing == -1} {
	    updateConsole "Scid: smoves disabled while playing a game"
	    return
	  }

	  ::fics::demote_mainGame 
          if {$::fics::playing != 2} {
	    set confirm [::game::ConfirmDiscard2]
	    if {$confirm == 2} {return}
	    if {$confirm == 0} {sc_game save [sc_game number]}
          }
	  sc_game new
	  set ::fics::mainGame -1
	  set ::fics::playing 0
	  updateBoard -pgn
	  updateTitle

	  writechan $l echo
	  ::fics::addHistory $l

	  set ::fics::waitForMoves no_meaning
	  vwaitTimed ::fics::waitForMoves 5000 nowarn
	  updateBoard -pgn
	  updateTitle
	  return
      } 
      default {
	  if {([string match unob* $c]||[string match unex* $c])  && \
	       $::fics::playing != 1 && $::fics::playing != -1 && \
	       ($l == $c || [lindex $l 1] == $::fics::mainGame)} {
	    # unobserve/unexamine main game
	    set ::fics::mainGame -1
	    if {[string match unex* $c]} {
	      set ::fics::playing 0
	      updateBoard -pgn
	      updateTitle
	    }
	  }
          # Problems with doing this 
          # if exam game, ob (load) another game, exam newgame - gets confused :(
          # if {[string match {tell gamebot exam*} $l] ||
          #    [string match {exam*} $c]} {
	  #  ::fics::demote_mainGame 
          #}
      }
    } ; # switch
    ::fics::addHistory $l

    writechan $l echo
    $w.console.text yview moveto 1
  }

  proc addHistory { l } {
    if {[lindex $::fics::history end] != $l} {
      lappend ::fics::history $l
    }
    set ::fics::history_pos [llength $::fics::history]
  }

  proc cmdHistory { action } {
    set t .fics.command.entry

    if {$action == "up" && $::fics::history_pos > 0} {
      if {$::fics::history_pos == [llength $::fics::history]} {
        set ::fics::history_current [$t get]
      }
      $t delete 0 end
      incr ::fics::history_pos -1
      $t insert end [lindex $::fics::history $::fics::history_pos]
    }
    if {$action == "down"} {
      if {$::fics::history_pos < [llength $::fics::history]} {
        $t delete 0 end
        incr ::fics::history_pos
        if {$::fics::history_pos == [llength $::fics::history]} {
          set  entry $::fics::history_current 
        } else {
          set entry [lindex $::fics::history $::fics::history_pos]
        }
        $t insert end $entry
      }
    }
  }
  ################################################################################
  #
  ################################################################################
  proc findOpponent {} {
    global tr

    set w .ficsfindopp
    if {[winfo exists $w]} {
      focus $w
      return
    }
    toplevel $w
    wm state $w withdrawn
    wm title $w "Find Opponent"

    set row 0

    checkbutton $w.cbrated -text $tr(FICSRatedGame) -onvalue rated -offvalue unrated -variable ::fics::findopponent(rated)
    grid $w.cbrated -column 1 -row $row -sticky w

    incr row
    checkbutton $w.cbmanual -text $tr(FICSManualConfirm) -onvalue manual -offvalue auto -variable ::fics::findopponent(manual)
    grid $w.cbmanual -column 1 -row $row -sticky w

    incr row
    frame $w.space$row -height 2 -borderwidth 0
    grid  $w.space$row -column 0 -row $row -columnspan 3 -sticky ew -pady 3

    incr row
    label $w.linit -text $tr(FICSInitTime)
    spinbox $w.sbTime1 -width 7 -textvariable ::fics::findopponent(initTime) -from 0 -to 120 -increment 1
    label $w.linc -text $tr(FICSIncrement)
    spinbox $w.sbTime2 -width 7 -textvariable ::fics::findopponent(incTime) -from 0 -to 120 -increment 1
    grid $w.linit   -column 0 -row $row -sticky ew -padx 5
    grid $w.sbTime1 -column 1 -row $row -padx 5
    incr row
    grid $w.linc    -column 0 -row $row -sticky ew -padx 5
    grid $w.sbTime2 -column 1 -row $row -padx 5

    incr row
    frame $w.space$row -height 2 -borderwidth 0
    grid  $w.space$row -column 0 -row $row -columnspan 3 -sticky ew -pady 3

    incr row
    label $w.color -text $tr(FICSColour)
    grid $w.color -column 1 -row $row

    incr row
    radiobutton $w.rb2 -text $tr(White) -value white -variable ::fics::findopponent(color)
    radiobutton $w.rb3 -text $tr(Black) -value black -variable ::fics::findopponent(color)
    radiobutton $w.rb1 -text $tr(FICSAutoColour)  -value auto  -variable ::fics::findopponent(color)
    grid $w.rb1 -column 0 -row $row -ipadx 5
    grid $w.rb2 -column 1 -row $row -ipadx 5
    grid $w.rb3 -column 2 -row $row -ipadx 5

    incr row
    frame $w.space$row -height 2 -borderwidth 0
    grid  $w.space$row -column 0 -row $row -columnspan 3 -sticky ew -pady 3

    incr row
    checkbutton $w.cblimitrating -text $tr(RatingRange) -variable ::fics::findopponent(limitrating)
    spinbox $w.sbrating1 -width 7 -textvariable ::fics::findopponent(rating1) \
	-from 800 -to 2800 -increment 50
    spinbox $w.sbrating2 -width 7 -textvariable ::fics::findopponent(rating2) \
	-from 800 -to 2800 -increment 50 

    grid $w.cblimitrating -column 0 -row $row -sticky w
    grid $w.sbrating1     -column 1 -row $row
    grid $w.sbrating2     -column 2 -row $row

    incr row
    checkbutton $w.cbformula -text $tr(FICSFilterFormula) -onvalue formula \
      -offvalue none -variable ::fics::findopponent(formula)
    grid $w.cbformula -column 0 -row $row -sticky w

    incr row
    frame $w.space$row -height 2 -borderwidth 2 -relief sunken
    grid  $w.space$row -column 0 -row $row -columnspan 3 -sticky ew -pady 3

    button $w.seek -text {Make Offer} -command {
      set range ""
      if {$::fics::findopponent(limitrating) } {
        set range "$::fics::findopponent(rating1)-$::fics::findopponent(rating2)"
      }

      # can't use a blank value in radiobuttons/checkbuttons... they look stupid
      set color $::fics::findopponent(color)
      if {$::fics::findopponent(color) == "auto"} { set color {} }
      set formula $::fics::findopponent(formula)
      if {$::fics::findopponent(formula) == "none"} { set formula {} }

      set cmd "seek $::fics::findopponent(initTime) $::fics::findopponent(incTime) \
               $::fics::findopponent(rated) $color \
               $::fics::findopponent(manual) $formula $range"
      ::fics::writechan $cmd
      destroy .ficsfindopp
      ::fics::initOffers
    } -width 10
    button $w.help   -text $tr(Help) -command "helpWindow FICSfindopp" -width 10
    button $w.cancel -text $tr(Cancel) -command "destroy $w" -width 10

    bind $w <F1> {helpWindow FICSfindopp}

    incr row
    grid $w.seek   -column 0 -row $row -padx 3 -pady 8
    grid $w.help   -column 1 -row $row -padx 3 -pady 8 -sticky e
    grid $w.cancel -column 2 -row $row -padx 3 -pady 8 -sticky e

    update
    placeWinOverParent $w .fics
    wm state $w normal
  }

  ################################################################################
  #
  ################################################################################
  proc readchan {} {
    variable logged
    if {[eof $::fics::sockchan]} {
      fileevent $::fics::sockchan readable {}
      tk_messageBox -title "Read error" -icon error -type ok -message "Network error\nFics will exit." -parent .fics
      ::fics::close error
      return
    }
    # switch from read to gets in case a read is done at the middle of a line
    if {! $logged} {
      set line [read $::fics::sockchan]
      foreach l [split $line "\n"] {
        readparse $l
      }
    } else  {
        set line [gets $::fics::sockchan]
        set line [string map {"\a" ""} $line]
        readparse $line   
    }

  }

  ################################################################################
  # Appends an array to soughtlist if the parameter is correct
  # returns 0 if the line is not parsed and so it is still pending for use
  ################################################################################
  proc parseSoughtLine { l } {
    global ::fics::offers_minelo ::fics::offers_maxelo ::fics::offers_mintime ::fics::offers_maxtime

    if { [ catch { if {[llength $l] < 8} { return 0} } ] } { return 0}

    # 72 ++++ GuestIEEE           1  10 unrated blitz      [white]     0-9999 m
    # auto/manual     indicates whether a game will start automatically when 
    #                 abbreviated by "a" and "m" [default: auto start]
    # formula         indicates whether your formula will used to screen , abbreviated by "f"

    array set ga {}

    set offset 0
    set ga(game) [lindex $l 0]
    if { ! [string is integer $ga(game)] } { return 0}
    set tmp [lindex $l 1]
    if { [scan $tmp "%d" ga(elo)] != 1} { set ga(elo) $offers_minelo }
    if { $ga(elo) < $offers_minelo } { set ga(elo) $offers_minelo }
    set ga(name) [lindex $l 2]

    set tmp [lindex $l 3]
    if { [scan $tmp "%d" ga(time_init)] != 1} { set ga(time_init) $offers_maxtime}
    set tmp [lindex $l 4]
    if { [scan $tmp "%d" ga(time_inc)] != 1} { set ga(time_inc) 0 }

    set ga(rated) [lindex $l 5]
    if {$ga(rated) != "rated" && $ga(rated) != "unrated"} { return 0 }
        
    set ga(type) [lindex $l 6]
    if { $ga(type) != "untimed" && $ga(type) != "blitz" && $ga(type) != "standard" && $ga(type) != "lightning" } {
      # this line can now be ignored
      return 2
    }
    set ga(color) ""
    if { [lindex $l 7] == "\[white\]" || [lindex $l 7] == "\[black\]" } {
      set ga(color) [lindex $l 7]
      set offset 1
    }
    set ga(rating_range) [lindex $l [expr 7 + $offset]]
    if { [ catch { set ga(start) [lindex $l [expr 8 + $offset]] } ] } {
      set ga(start) ""
    }

    lappend ::fics::soughtlist [array get ga]
    return 1
  }

  proc readparse {line} {
    variable logged
    ### what is the significance of the fics prompt "fics%" &&&

    # Many lines have trailing spaces, so best not to do this
    # if {$logged} {set line [string trim $line]}

    if {[string match {fics%*} $line]} {
	set line [string trim [string range $line 5 end]]
    }

    if { $::fics::sought } {
      if {[string match "* ad* displayed." $line]} {
	set ::fics::sought 0
	catch { displayGraph }
	return
      }
      if { [ parseSoughtLine $line ] } {
	return
      }
    }

    switch -glob $line {
      {} {return}

      {login: } {
	writechan $::fics::reallogin
	if { [string match -nocase guest $::fics::reallogin ] } {
	  set logged 1
	}
	return
      }

      {password: } {
	writechan $::fics::password
	set logged 1
	return
      }

      {<sc>*} {
	set ::fics::seeklist {}
	return
      }

      {<s>*} {
	parseSeek $line
	return
      }

      {<sr>*} {
	removeSeek $line
	return
      }

      {<12>*} {
	parseStyle12 $line
	return
      }

      {<b1>*} {
        ### variants info lines
        # When showing positions from bughouse games, a second line showing piece
        # holding is given, with "<b1>" at the beginning, for example:
        # <b1> game 6 white [PNBBB] black [PNB]
        # .fics.bottom.game$game.w.white configure -text "[lindex $line 17] ([lindex $line 24] secs) X"
	if { [scan $line "<b1> game %d white %s black %s" game piecesw piecesb] == 3} {
          catch {
            if {$piecesw == {[]}} {set piecesw {}}
            if {$piecesb == {[]}} {set piecesb {}}
	    set tempw [.fics.bottom.game$game.w.white cget -text]
	    set tempb [.fics.bottom.game$game.b.black cget -text]
	    if {[string index $tempw end] == "X"} {
              .fics.bottom.game$game.w.white configure -text "[string range $tempw 0 end-2] $piecesw X"
              .fics.bottom.game$game.b.black configure -text "$tempb $piecesb"
            } else {
              .fics.bottom.game$game.w.white configure -text "$tempw $piecesw"
              .fics.bottom.game$game.b.black configure -text "[string range $tempb 0 end-2] $piecesb X"
            }
          }
        }
        return
      }
    }

    updateConsole $line

    if { [string match "You are now observing game*" $line] } {
      # You are now observing game 193.
      # Game 193: franky (1758) homeomorphism (1722) rated lightning 1 0

      scan $line "You are now observing game %d." game

      # Only setup a new little board if its not the mainGame
      # mainGame gets loaded later (in parseStyle12)
      if {$game != $::fics::mainGame} {
	addObservedGame $game
      }
      return
    }

    ### Removing game 393 from observation list.
    if { [string match "Removing game *" $line] } {
      scan $line "Removing game %d from observation list." game
      remove_observedGame $game
      return
    }

    if {[string match "Creating: *" $line]} {
      catch {destroy .ficsOffers}
      # Setting this, stops automatically accepting rematches. (But algorythm needs fixing a little)
      set ::fics::findopponent(manual) manual
      after cancel ::fics::updateGraph

      # Move a previously observed game back to the fics widget
      ::fics::demote_mainGame 
      set ::fics::mainGame -1 ; # reset to this new game with first style12 

      sc_game new

      set idx1 [string first "(" $line]
      set white [string trim [string range $line 10 [expr $idx1 -1]] ]
      set idx2 [string first ")" $line]
      set whiteElo [string trim [string range $line [expr $idx1 +1] [expr $idx2 -1]] ]

      set idx1 [expr $idx2 +1]
      set idx2 [string first "(" $line $idx1]
      set black [string trim [string range $line $idx1 [expr $idx2 -1]] ]

      set idx1 [expr $idx2 +1]
      set idx2 [string first ")" $line $idx1]
      set blackElo [string trim [string range $line $idx1 [expr $idx2 -1]] ]

      if { $whiteElo == "++++"} { set whiteElo 0 }
      if { $blackElo == "++++"} { set blackElo 0 }

      if { [ string match -nocase $white $::fics::reallogin ] } {
	### 1 = game_start/my move, 0 = not playing, -1 = opponents move
	set ::fics::playing 1
      } else {
	set ::fics::playing -1
      }

      sc_game tags set -white $white
      sc_game tags set -whiteElo $whiteElo
      sc_game tags set -black $black
      sc_game tags set -blackElo $blackElo
      sc_game tags set -date [::utils::date::today]

      if {[string match -nocase $::fics::reallogin $white]} {
        set ::fics::opponent $black 
      } elseif {[string match -nocase $::fics::reallogin $black]} {
        set ::fics::opponent $white
      } else {
        set ::fics::opponent {}
      }
        
      
      # line: "Creating: hruvulum (1079) stevenaaus (1148) rated blitz 2 18"
      # resumed game line is different though
      if {[regexp {.*\) ([^\)]*$)} $line t1 t2]} {
	sc_game tags set -event "Fics $t2"
      }
      if { [::board::isFlipped .board] } {
        if { [ string match -nocase $white $::fics::reallogin ] } { ::board::flip .board }
      } else {
        if { [ string match -nocase $black $::fics::reallogin ] } { ::board::flip .board }
      }
      updateBoard -pgn -animate
      updateTitle

      if {$::fics::sound} {
	::utils::sound::PlaySound sound_move
      }

      ### hide offers graph ; sometime ::fics::updateGraph doesn't get cancelled though !?^&$%!
      set ::fics::graphon 0
      showGraph

      # display the win / draw / loss score
      ::fics::writechan assess noecho
      set ::fics::ignore_abort 0
      set ::fics::ignore_takeback 0
      set ::fics::ignore_draw 0
      set ::fics::ignore_adjourn 0
      set ::fics::lastmove {no move}
      set ::fics::playerslastmove {no move}
      return
    }

    # {Game 331 (AmorVerus vs. killerbie) killerbie checkmated} 1-0

    # Creating: Libertie (1263) stevenaaus (1092) rated blitz 6 12
    # {Game 112 (Libertie vs. stevenaaus) Creating rated blitz match.}

    if {[string match "\{Game *" $line]} {
      if {[string match {* Creating *} $line]} {
	scan $line "\{Game %d %s" num tmp
        return
      }
      set num [lindex [lindex $line 0] 1]
      set res [lindex $line end]

      if {$num == $::fics::mainGame} {
        # Game is over. Set result and save game
        ::gameclock::stop 1
        ::gameclock::stop 2

	# {Game 331 (AmorVerus vs. killerbie) killerbie ran out of time and Oli has no material to mate} 1/2-1/2
	set resultcomment [lrange [lindex $line 0] 2 end]
	set t1 [string first {)} $resultcomment]
	if {$t1 > -1} {
	  set resultcomment [string range $resultcomment $t1+2 end]
	}

        set t1 [::gameclock::getSec 1]
        set t2 [::gameclock::getSec 2]
	::commenteditor::appendComment "$resultcomment\nWhiteclock [expr $t1 / 60]:[format {%02i} [expr $t1 % 60]] Blackclock [expr $t2 / 60]:[format {%02i} [expr $t2 % 60]]"
        sc_game tags set -result $res
        catch {sc_game save [sc_game number]}
        updateBoard -pgn
        set ::fics::playing 0
        set ::fics::mainGame -1
        set ::pause 0
	if {[string match -nocase $::fics::reallogin [sc_game tags get Black]] ||
            [string match -nocase $::fics::reallogin [sc_game tags get White]]} {
	  if {[string match "1/2*" $res]} {
	    tk_messageBox -title "Game result" -icon info -type ok -message "Draw"
	  } else {
	    tk_messageBox -title "Game result" -icon info -type ok -message "$res"
	  }
	}
      } else {
         # Add result to white label
         catch {
	  .fics.bottom.game$num.w.result configure -text \
	    "[.fics.bottom.game$num.w.result cget -text] ($res)"
          pack forget .fics.bottom.game$num.b.load
         }
         ::fics::remove_observedGame $num
      } 
      return
    }

    if {[string match "Game *rated *" $line]} {

      # Game notification: Kaitlin ( 696) vs. leilatov (1186) rated bughouse 2 0: Game 335
      if {[string match "Game notification*" $line]} {
        return
      }

      ### Get observed game Info
      # Game 237: impeybarbicane (1651) bust (1954) rated crazyhouse 5 0
      # Game 237: impeybarbicane ( 649) bust ( 987) rated crazyhouse 5 0
      # note - the stray '('s in the line below seems to make matching the elo easier

      if {[scan $line {Game %d: %s (%s %s (%s %s %s %d %d} g white whiteElo black blackElo dummy gametype t1 t2] == 9} {
          set ::fics::elo($white) [string range $whiteElo 0 end-1]
          set ::fics::elo($black) [string range $blackElo 0 end-1]
          if {[winfo exists .fics.bottom.game$g]} {
	    .fics.bottom.game$g.w.white configure -text $white
	    .fics.bottom.game$g.b.black configure -text $black
            set type $gametype
            catch {set type $::fics::shorttype($gametype)}
	    .fics.bottom.game$g.w.result configure -text "$type"
	    # disable load button if non-standard game
	    if {$gametype != {untimed} && $gametype != {blitz} && $gametype != {lightning} && $gametype != {standard}} {
	      pack forget .fics.bottom.game$g.b.load
	    }
          }
      } else {
        updateConsole "Error parsing Game line \"$line\""
      }
    }

    # "Movelist for game *:" (unhandled)

    if {[string match "*Starting FICS session*" $line]} {
      # mandatory init commands
      writechan "iset seekremove 1"
      writechan "iset seekinfo 1"
      writechan "style 12"
      writechan "iset nowrap 1"
      writechan "iset nohighlight 1"

      # user init commands
      # writechan "set seek $::fics::gamerequests"
      # writechan "set gin  $::fics::gamerequests"
      writechan "set gin  0"
      # writechan "set silence 1"
      writechan "set echo 1"
      writechan "set seek 0"
      # pychess sets this bloody thing
      writechan "set availinfo off"
      writechan "set chanoff [expr !$::fics::chanoff]"
      writechan "set cshout $::fics::shouts"
      writechan "set shout $::fics::shouts"

      # What is this ? S.A. writechan "iset nowrap 1"
      writechan "iset nohighlight 1"
      .fics.bottom.buttons.offers  configure -state normal
      .fics.bottom.buttons.tells   configure -state normal
      .fics.bottom.buttons.shouts  configure -state normal
      bind .fics.command.entry <Return> ::fics::cmd
      .fics.command.send configure -command ::fics::cmd
      return
    }

    if { $::fics::waitForMoves != "" } {
      set m1 ""
      set m2 ""
      set line [string trim $line]

      # Because some free text may be in the form (".)
      if {[catch {llength $line} err]} {
        puts "Exception $err llength $line"
        return
      }

      set length [llength $line ]

      if {$length == 5 && [scan $line "%d. %s (%d:%d) %s (%d:%d)" t1 m1 t2 t3 m2 t4 t5] != 7} {
        return
      }
      if {$length == 3 && [scan $line "%d. %s (%d:%d)" t1 m1 t2 t3] != 4} {
        return
      }
      if {$length == 12 && [scan $line {%s (%s %s %s (%s} t1 t2 t3 t4 t5] == 5} {
	# ImaGumby (1280) vs. Kaitlin (1129) --- Sat Feb  4, 02:12 PST 2012
        # stevenaaus (1157) vs. Abatwa (1103) --- Sun Feb  5, 23:13 PST 2012
        if {$t3 == "vs."} {
	  sc_game tags set -white    $t1
	  sc_game tags set -black    $t4
          sc_game tags set -whiteElo [string range $t2 0 end-1]
          sc_game tags set -blackElo [string range $t5 0 end-1]
          # todo
	  # sc_game tags set -date [::utils::date::today]
	  # sc_game tags set -event "FICS Game $game $initialTime/$increment"

        }
        return
      }
      if {$length == 2 && [string match {\{*\} *} $line]} {
	# {White forfeits on time} 1-0
        ::commenteditor::appendComment [lindex $line 0]
	sc_game tags set -result [lindex $line 1]
        set ::fics::waitForMoves ""
        return
      }

      # Add this move
      # 1.  d4      (0:00)     d6      (0:00)
      # 2.  c4      (0:25)     Bf5     (0:01)

      catch { sc_move addSan $m1 }
      if {$m2 != ""} {
        catch { sc_move addSan $m2 }
      }
      
      if {[sc_pos fen] == $::fics::waitForMoves } {
        set ::fics::waitForMoves ""
      }
    }

    if {[string match "Challenge:*" $line]} {
	if {[winfo exists .ficsOffers] && $::fics::findopponent(manual) == {auto}} {
            writechan accept
	} else {
	    ::fics::addOffer $line
	}
    }

    if {[string match "Challenge * removed*" $line]} {
	::fics::delOffer [string tolower [lindex [split $line] 2]]
    }

    if {[string match "* withdraws * offer*" $line]} {
	::fics::delOffer [string tolower [lindex [split $line] 0]]
    }

    # JM: To avoid "denial of play" attack by the opponent constantly issuing request[s]
    # SA: Add ignore_request checks, and use tk_dialog instead of tk_messageBox

    # abort request

    if {[string match "* would like to abort the game;*" $line] \
     && ! $::fics::ignore_abort && ! [winfo exists .fics_dialog]} {
      set ans [tk_dialog .fics_dialog Abort "$line\nDo you accept ?" question {} Yes No Ignore]
      switch -- $ans {
        0 {writechan accept}
        1 {writechan decline}
        2 {set ::fics::ignore_abort 1}
      }
    }

    # takeback
    if {[string match "* would like to take back *" $line] \
     && ! $::fics::ignore_takeback && ! [winfo exists .fics_dialog]} {
      set ans [tk_dialog .fics_dialog {Take Back} "$line\nDo you accept ?" question {} Yes No Ignore]
      switch -- $ans {
        0 {
            writechan accept
	    if {[regexp {(.*) would like to take back} $line t1 t2]} {
	      ::commenteditor::appendComment "$t2 takes back move $::fics::lastmove"
	    }
          }
        1 {writechan decline}
        2 {set ::fics::ignore_takeback 1}
      }
    }

    # draw
    if {[string match "*offers you a draw*" $line]
     && ! $::fics::ignore_draw && ! [winfo exists .fics_dialog]} {
      if {[regexp {(.*) offers you a draw} $line t1 t2]} {
	::commenteditor::appendComment "$t2 offers draw"
      }
      set ans [tk_dialog .fics_dialog {Draw Offered} "$line\nDo you accept ?" question {} Yes No Ignore]
      switch -- $ans {
        0 {writechan accept}
        1 {writechan decline}
        2 {set ::fics::ignore_draw 1}
      }
    }

    # adjourn
    if {[string match "*would like to adjourn the game*" $line]
     && ! $::fics::ignore_adjourn && ! [winfo exists .fics_dialog]} {
      set ans [tk_dialog .fics_dialog {Adjourn Offered} "$line\nDo you accept ?" question {} Yes No Ignore]
      switch -- $ans {
        0 {writechan accept}
        1 {writechan decline}
        2 {set ::fics::ignore_adjourn 1}
      }
    }

    # guest logging
    if {[string match "Logging you in as*" $line]} {
      set line [string map {"\"" "" ";" ""} $line ]
      set ::fics::reallogin [lindex $line 4]
      wm title .fics "Free Internet Chess Server ($::fics::reallogin)"
    }
    if {[string match "Press return to enter the server as*" $line]} {
      writechan "\n"
    }

  }

  ### Make a new small board in the fics widget to observe a game

  proc addObservedGame {game} {
      set w .fics

      if {[lsearch -exact $::fics::observedGames $game] == -1} {
	lappend ::fics::observedGames $game
      }
      if {[winfo exists $w.bottom.game$game]} {
        # Check for clash between finished games and new games
	bind .fics <Destroy> {}
        destroy $w.bottom.game$game
        bind .fics <Destroy> ::fics::close
      }
      frame $w.bottom.game$game
      ::board::new $w.bottom.game$game.bd $::fics::size 1
      # At bottom we have White and Buttons
      # (note whiteElo, blackElo labels are not packed, only used for data should we load game
      # data for these labels is read next line from fics
      frame $w.bottom.game$game.w
      label $w.bottom.game$game.w.white  -font font_Small
      label $w.bottom.game$game.w.result -font font_Small
      # At top we have Black and Buttons
      frame $w.bottom.game$game.b 
      label $w.bottom.game$game.b.black -font font_Small

      button $w.bottom.game$game.b.close -image arrow_close -font font_Small -relief flat -command "
        bind .fics <Destroy> {}
        destroy .fics.bottom.game$game
        bind .fics <Destroy> ::fics::close
        ::fics::unobserveGame $game"

      button $w.bottom.game$game.b.load -image arrow_up -font font_Small -relief flat -command "

	if {\[lsearch -exact \$::fics::observedGames $game\] > -1} {
          if {\$::fics::playing == -1 || \$::fics::playing == 1} {
            return
          }
	  ### If we're already observing a game, move it back to a small board
	  ::fics::demote_mainGame 
	  ### Restarting observe ensures we get a parseStyle12 line straight away
	  ::fics::unobserveGame $game
	  set ::fics::mainGame $game
	  ::fics::writechan \"observe $game\"
	  bind .fics <Destroy> {}
	  destroy .fics.bottom.game$game
	  bind .fics <Destroy> ::fics::close
          raiseWin .
	} else {
          ### should never get here
	  # close game if it is finished
	  bind .fics <Destroy> {}
	  destroy .fics.bottom.game$game
	  bind .fics <Destroy> ::fics::close
	}
      "

      # button $w.bottom.game$game.w.flip -text flip -font font_Small -relief flat -command ""

      pack $w.bottom.game$game -side left -before $w.bottom.scale -padx 3 -pady 3

      pack $w.bottom.game$game.b  -side top -anchor w -expand 1 -fill x
      pack $w.bottom.game$game.b.black -side left 
      pack [frame $w.bottom.game$game.b.space -width 24] \
           $w.bottom.game$game.b.close $w.bottom.game$game.b.load -side right
      pack $w.bottom.game$game.bd -side top
      pack $w.bottom.game$game.w -side top -expand 1 -fill x
      pack $w.bottom.game$game.w.white -side left 
      pack [frame $w.bottom.game$game.w.space -width 20] \
           $w.bottom.game$game.w.result -side right
  }

  proc unobserveGame {game} {
    if {[::fics::remove_observedGame $game]} {
      ::fics::writechan "unobserve $game"
    }
  }

  proc remove_observedGame {game} {
    set i [lsearch -exact $::fics::observedGames $game]
    if {$i > -1} {
      set ::fics::observedGames [lreplace $::fics::observedGames $i $i]
      return 1
    } else {
      return 0
    }
  }

  proc demote_mainGame {} {
    if {$::fics::mainGame > -1 && $::fics::playing != 2} {
      ::fics::writechan "unobserve $::fics::mainGame"
      ::fics::writechan "observe $::fics::mainGame"
      ::fics::addObservedGame $::fics::mainGame
    }
  }

  proc updateConsole {line} {

    set t .fics.console.text

    # colors defined line 281

    switch -glob $line {
	{\{Game *\}}	{ $t insert end "$line\n" game }
	{\{Game *\} *}	{ $t insert end "$line\n" gameresult }
	{Auto-flagging*} {$t insert end "$line\n"
                          # ::commenteditor::appendComment "Loses on time" ; # recorded above
                        }
	{* tells you:*}	{ $t insert end "$line\n" tells 
			  if {[regexp {(.*) tells you:(.*$)} $line t1 t2 t3]} {
                            if {[set temp [string first {(} $t2]] > -1} {
                              set t2 [string range $t2 0 $temp-1]
                            }
                            if {[string match mamer* $t2]} {
			      tk_messageBox -title Mamer -icon info -type ok -parent .fics -message "$t2 tells you" -detail $t3
			    } else {
                              if {$::fics::playing != 0} {
				::commenteditor::appendComment "\[$t2\] $t3"
                              }
			      # Add this person to tells
			      set i [lsearch -exact $::fics::tells $t2]
			      if {$i > -1} {
				set ::fics::tells [lreplace $::fics::tells $i $i]
			      }
			      set ::fics::tells [linsert $::fics::tells 0 $t2]
			      set ::fics::tellindex 0
                            }
			  }
			}
	{* seeking *}	{ $t insert end "$line\n" seeking }
	{->>say *} - {->>. *}	{
                          $t insert end "$line\n" tells 
                          if {$::fics::playing == 1 || $::fics::playing == -1}  {
			    if {[regexp -- {->>say (.*$)} $line t1 t2]} {
			      ::commenteditor::appendComment "\[$::fics::reallogin\] $t2"
			    }
                          }
			}
	{* says: *}	{ $t insert end "$line\n" tells 
			  catch {
                            regexp {(.*) says: (.*$)} $line t1 t2 t3
                            # remove trailing [342] (eg) from player name
                            if {[regexp {(^.*)\[.*\]} $t2 t0 t4]} {
			      ::commenteditor::appendComment "\[$t4\] $t3"
                            } else {
			      ::commenteditor::appendComment "\[$t2\] $t3"
                            } 
                          }
			}
        {Draw request sent*} { ::commenteditor::appendComment "$::fics::reallogin offers draw"
                          $t insert end "$line\n"
                        }
	{->>tell *}	{ $t insert end "$line\n" tells }
    	{->>*}		{ $t insert end "$line\n" command }

	{*[A-Za-z]\(*\): *} { $t insert end "$line\n" channel }
        {Finger of *}   { $t insert end "$line\n" seeking }
        {History of *}  { $t insert end "$line\n" seeking }
        {Present company includes: *} { $t insert end "$line\n" gameresult }
        {* goes forward [0-9]* move*} {}
        {* backs up [0-9]* move*} {}
	{Width set *}	{}
	{Height set *}	{}
	default		{ $t insert end "$line\n" }
      }

    set pos [ lindex [ .fics.console.scroll get ] 1 ]
    if {$pos == 1.0} {
      $t yview moveto 1
    }
  }

  ################################################################################
  # New Fics Offer widgets S.A.
  ################################################################################

  ### Init 

  proc initOffers {} {
    set w .ficsOffers

    if {[winfo exists $w]} {return}

    toplevel $w
    wm state $w withdrawn
    wm title $w "Fics Offers"
    pack [label $w.title -text "Offers for $::fics::reallogin" -font font_Regular] -side top -padx 20 -pady 5

    pack [button $w.cancel -text "Cancel" \
	-command "::fics::writechan unseek ; destroy $w"] -side bottom -pady 5
    pack [frame $w.line -height 2 -borderwidth 2 -relief sunken ] \
        -fill x -expand 1 -side bottom -pady 2

    set ::fics::Offers 0
    ::fics::checkZeroOffers 0

    update
    placeWinOverParent $w .fics
    wm state $w normal
  }

  ### Add Offer

  proc addOffer {line} {
    # Challenge: GuestYGTD (----) stevenaaus (1670) unrated standard 15 1
    if {![winfo exists .ficsOffers]} {
	::fics::initOffers
    }

    set PLAYER [lindex [split $line] 1]
    set player [string tolower $PLAYER]
    # set elo [string trimright [lindex [split $line] 3] )]
    if { [regexp {\(----\).*([0-9][0-9][0-9])} $line ] || \
         [regexp {\(----\).*\(----\)} $line ] } {
	set elo {unrated}
    } else {
        regexp {([0-9]+)} $line elo 
    }
    if {"$player" == ""} {
       puts "Fics:Empty player offer!"
       return
    }

    set f .ficsOffers.$player

    if {[winfo exists $f]} { 
	return
    }

    ::fics::checkZeroOffers +1

    pack [frame $f] -side top -padx 5 -pady 5
    pack [label $f.name -text "$PLAYER ($elo)" -width 20] -side left
    pack [button $f.decline -text "decline" \
	-command "::fics::writechan \"decline $PLAYER\" ; destroy $f ; ::fics::checkZeroOffers -1" ] -side right -padx 5
    pack [button $f.accept -text "accept" \
	-command "::fics::writechan \"accept $PLAYER\"  ; destroy $f ; ::fics::checkZeroOffers -1" ] -side right -padx 5
    update
    raiseWin .ficsOffers

  }

  ### Delete Offer 

  proc delOffer {player} {
  # Challenge from PLAYER removed.

    if {![winfo exists .ficsOffers]} {
	return
    }

    if {"$player" == ""} {
       puts "Fics:Empty player offer!"
       return
    }

    if {[winfo exists .ficsOffers.$player]} { 
	destroy .ficsOffers.$player
	::fics::checkZeroOffers -1
    }
  }

  ### update the number of offers, and draw a blank frame if there's none

  proc checkZeroOffers {n} {

    set f .ficsOffers.blank

    incr ::fics::Offers $n

    if {$::fics::Offers <= 0} {
      if {$::fics::findopponent(manual) == {auto}} {
	  pack [frame $f] -side top -padx 5 -pady 5
	  pack [label $f.name -text "Awaiting offer" -width 20] -padx 10
      } else {
	if {![winfo exists $f]} {
	  pack [frame $f] -side top -padx 5 -pady 5
	  pack [label $f.name -text "No offers" -state disabled -width 20] -side left 
	  pack [button $f.decline -text "decline" -state disabled ] -side right -padx 5
	  pack [button $f.accept -text "accept" -state disabled ] -side right -padx 5
	}
      }
    } else {
      destroy $f
    }
    update
  }

  ################################################################################
  #
  ################################################################################
  proc removeSeek {line} {
    global ::fics::seeklist
    foreach l $line {
      
      if { $l == "<sr>" } {continue}
      
      # remove seek from seeklist
      for {set i 0} {$i < [llength $seeklist]} {incr i} {
        array set a [lindex $seeklist $i]
        if {$a(index) == $l} {
          set seeklist [lreplace $seeklist $i $i]
          break
        }
      }
      
      # remove seek from graph
      if { $::fics::graphon } {
        for {set idx 0} { $idx < [llength $::fics::soughtlist]} { incr idx } {
          array set g [lindex $::fics::soughtlist $idx]
          set num $g(game)
          if { $num == $l } {
            .fics.bottom.graph.c delete game_$idx
            break
          }
        }
      }
      
    }
  }
  ################################################################################
  #
  ################################################################################
  proc parseStyle12 {line} {

    # <12> r-----k- p----ppp ---rq--- --R-p--- -------- ------PP --R--P-- ------K-
    #      W -1 0 0 0 0 2 182 stevenaaus DRSlay 1 5 12 13 24 84 28 32 Q/e7-e6 (0:40) Qe6 0 1 77

    set game  [lindex $line 16]
    set color [lindex $line 9]

    ### Observed games are a row of small boards down the bottom left 
    if {[lsearch -exact $::fics::observedGames $game] > -1} {
      if {$color == "W"} {
	.fics.bottom.game$game.w.white configure -text "[lindex $line 17] ([lindex $line 24] secs) X"
	.fics.bottom.game$game.b.black configure -text "[lindex $line 18] ([lindex $line 25] secs)"
      } else {
	.fics.bottom.game$game.w.white configure -text "[lindex $line 17] ([lindex $line 24] secs)"
	.fics.bottom.game$game.b.black configure -text "[lindex $line 18] ([lindex $line 25] secs) X"
      }
      set moves [lreverse [lrange $line 1 8]]
      set boardmoves [string map { "-" "." " " "" } $moves]
      ::board::update .fics.bottom.game$game.bd $boardmoves 1
      return
    }

    set white [lindex $line 17]
    set black [lindex $line 18]
    set state [lindex $line 19]

    # todo: make a "follow!" command that autoloads games into the main widget and saves them as each game finishes &&&

    # If not playing and not examiner (state 1, -1, 2), then we unobserve game, as its not in $observedGames
    if { $state != -1 && $state != 1 && $state != 2 && ($game != $::fics::mainGame) } {
      # Is "unobserve" really necessary now. This code *can* be reached, but an unobserve has been queued already
      ::fics::writechan "unobserve $game"
      return
    }

    set initialTime   [lindex $line 20]
    set increment     [lindex $line 21]
    set whiteMaterial [lindex $line 22]
    set blackMaterial [lindex $line 23]
    set whiteRemainingTime [lindex $line 24]
    set blackRemainingTime [lindex $line 25]
    set moveNumber      [lindex $line 26]
    set verbose_move    [lindex $line 27]
    set moveTime        [lindex $line 28]
    set moveSan         [lindex $line 29]
    set ::fics::playing [lindex $line 19]
      # -3 isolated position, such as for "ref 3" or the "sposition" command
      # -2 I am observing game being examined
      #  2 I am the examiner of this game
      # -1 I am playing, it is my opponent's move
      #  1 I am playing and it is my move
      #  0 I am observing a game being played
    set ::fics::mainGame $game

    ::gameclock::setSec 1 [ expr 0 - $whiteRemainingTime ]
    ::gameclock::setSec 2 [ expr 0 - $blackRemainingTime ]
    # Show time remaining in titlebar ?
    # wm title . "$::scidName: $white ($whiteRemainingTime) - $black ($blackRemainingTime)"
    if {$fics::playing == 1 || $fics::playing == -1 ||  $fics::playing == 0} {
      if {$color == "W"} {
	::gameclock::start 1
	::gameclock::stop 2
      } else {
	::gameclock::start 2
	::gameclock::stop 1
      }
    }

    ### Constrct fen from [lrange $line 1 8] lines of the game. Slow!
    ### r-----k- p----ppp ---rq--- --R-p--- -------- ------PP --R--P-- ------K-
    set fen ""
    for {set i 1} {$i <=8} { incr i} {
      set l [lindex $line $i]
      set count 0
      
      for { set col 0 } { $col < 8 } { incr col } {
        set c [string index $l $col]
        if { $c == "-"} {
          incr count
        } else {
          if {$count != 0} {
            append fen $count
            set count 0
          }
          append fen $c
        }
      }
      
      if {$count != 0} { append fen $count }
      if {$i != 8} { append fen {/} }
    }

    append fen " [string tolower $color]"
    set f [lindex $line 10]

    # en passant
    if { $f == "-1" || $verbose_move == "none"} {
      set enpassant "-"
    } else {
      set enpassant "-"
      set conv "abcdefgh"
      set fl [string index $conv $f]
      if {$color == "W"} {
        if { [ string index [lindex $line 4] [expr $f - 1]] == "P" || [ string index [lindex $line 4] [expr $f + 1]] == "P" } {
          set enpassant "${fl}6"
        }
      } else {
        if { [ string index [lindex $line 5] [expr $f - 1]] == "p" || [ string index [lindex $line 5] [expr $f + 1]] == "p" } {
          set enpassant "${fl}3"
        }
      }
    }

    set castle ""
    if {[lindex $line 11] == "1"} {set castle "${castle}K"}
    if {[lindex $line 12] == "1"} {set castle "${castle}Q"}
    if {[lindex $line 13] == "1"} {set castle "${castle}k"}
    if {[lindex $line 14] == "1"} {set castle "${castle}q"}
    if {$castle == ""} {set castle "-"}

    append fen " $castle $enpassant [lindex $line 15] $moveNumber"

    if {$::fics::playing == 2} {
      # Examining game
      sc_game tags set -white $white
      sc_game tags set -black $black
      if {[catch {sc_game startBoard $fen}]} {
	# Hmm - pawn and piece counts get verified in Position::ReadFromFEN, but crazyhouse often has more than 8 pawns.
	updateGameinfo
	set moves [lreverse [lrange $line 1 8]]
	set boardmoves [string map { "-" "." " " "" } $moves]
	::board::update .board $boardmoves 1
	.button.back    configure -state normal
	.button.forward configure -state normal
	.button.start   configure -state normal
	.button.end     configure -state normal
      } else {
	updateBoard -pgn
      }
      wm title . "$::scidName: FICS (Examine Mode)"
      return
    }

    # puts $verbose_move
    # puts $moveSan

    # try to play the move and check if fen corresponds. If not this means the position needs to be set up.
    if {$moveSan != "none" && $::fics::playing != -1} {
      # Process opponents move
      # Move to game end incase user was messing around with the game
      sc_move end

      # Why is this check necessary ?
      if { ([sc_pos side] == "white" && $color == "B") || ([sc_pos side] == "black" && $color == "W") } {
	if {$::utils::sound::announceNew} {
	  ::utils::sound::AnnounceMove $moveSan
	} else {
	  if {$::fics::sound} {
	    # ::utils::sound::CancelSounds
	    if {[lindex $::utils::sound::soundQueue end] != "sound_move"} {
	      ::utils::sound::PlaySound sound_move
            }
	  }
        }
        set ::fics::lastmove $moveSan ; # remember last opponenets move for takeback comment
        if { [catch { sc_move addSan $moveSan } err ] } {
          puts "error $err"
        } else {
          if { $::novag::connected } {
            set m $verbose_move
            if { [string index $m 1] == "/" } { set m [string range $m 2 end] }
            set m [string map { "-" "" "=" "" } $m]
            ::novag::addMove $m
          }
        }
      }
    } else {
      set ::fics::playerslastmove $moveSan
    }

    if {$fen == [sc_pos fen]} {
      updateBoard -pgn -animate
    } else {
      ### Game out of sync, probably due to player takeback request (or opponent take back 2).
      ### But also used to load observed games
      # After player takeback, game gets reconstructed, comments are zeroed. Opponents takeback is handled better elsewhere.
      # Fics doesn't give much warning that take back was succesful, only the uncertain "Takeback request sent."
      # If player makes a move after his time has expired, we end up here. Bad.
      # Todo: Before starting new game, try to move backwards in game.

      # To solve the problem of concurrent processing of parseStyle12 lines, we have to have mutexs on this proc
      # ... for some reason using individual mutexs for each game doesnt work properly &&&
      # while {$::fics::mutex($num)} {vwait ::fics::mutex($num)}

      if {$::fics::mutex} {
        return
      }
      set ::fics::mutex 1

      puts "Debug fen \n$fen\n[sc_pos fen]"

      ### Save previous (unfinished?) game.
      # ideally we can save observed games too, but only after we have the "Debug fen" working 100%

      if {[string match -nocase $white $::fics::reallogin] ||
          [string match -nocase $black $::fics::reallogin]} {
	catch {sc_game save [sc_game number]}
      }

      sc_game new
      sc_game tags set -white $white
      sc_game tags set -black $black
      if {[info exists ::fics::elo($white)]} {
	sc_game tags set -whiteElo $::fics::elo($white)
      }
      if {[info exists ::fics::elo($black)]} {
	sc_game tags set -blackElo $::fics::elo($black)
      }
      sc_game tags set -date [::utils::date::today]
      sc_game tags set -event "FICS Game $game $initialTime/$increment"

      ### Try to get first moves of game

      writechan "moves $game"
      set ::fics::waitForMoves $fen
      vwaitTimed ::fics::waitForMoves 5000 nowarn
      set ::fics::waitForMoves ""

      # After the 5 second time period, we could decide to give up and just set the FEN,
      # but this leaves the game without it's move history
      if {$fen != [sc_pos fen]} {
        # Did not manage to reconstruct the game, just set its position
        # (But this never works !? &&& )
        sc_game startBoard $fen
      }

      set ::fics::mutex 0
      updateBoard -pgn
      updateTitle
      if {$::fics::playing != 1 && $::fics::playing != -1 && $::fics::observedGames != {}} {
        writechan "primary $game"
      }
    }
  }


  proc parseSeek {line} {
    array set seekelt {}
    set seekelt(index) [lindex $line 1]
    foreach m [split $line] {
      if {[string match "w=*" $m]} { set seekelt(name_from) [string range $m 2 end] ; continue }
      if {[string match "ti=*" $m]} { set seekelt(titles) [string range $m 3 end] ; continue }
      if {[string match "rt=*" $m]} { set seekelt(rating) [string range $m 3 end] ; continue }
      if {[string match "t=*" $m]} { set seekelt(time) [string range $m 2 end] ; continue }
      if {[string match "i=*" $m]} { set seekelt(increment) [string range $m 2 end] ; continue }
      if {[string match "r=*" $m]} { set seekelt(rated) [string range $m 2 end] ; continue }
      if {[string match "tp=*" $m]} { set seekelt(type) [string range $m 3 end] ; continue }
      if {[string match "c=*" $m]} { set seekelt(color) [string range $m 2 end] ; continue }
      if {[string match "rr=*" $m]} { set seekelt(rating_range) [string range $m 3 end] ; continue }
      if {[string match "a=*" $m]} { set seekelt(automatic) [string range $m 2 end] ; continue }
      if {[string match "f=*" $m]} { set seekelt(formula_checked) [string range $m 2 end] ; continue }
    }
    lappend ::fics::seeklist [array get seekelt]
  }


  # Unused

  proc redim {} {
    set w .fics
    update
    set x [winfo reqwidth $w]
    set y [winfo reqheight $w]
    wm geometry $w ${x}x${y}
  }
  
  proc showGraph {} {
    set w .fics.bottom

    ### Either the clock or offers graph are shown at any one time

    if { $::fics::graphon } {
      showClocks
      pack $w.graph -side left
      updateGraph
    } else {
      after cancel ::fics::updateGraph
      pack forget $w.graph
      showClocks
    }

    ### Repacking can make the console suspend, so seek to console end 
    update
    .fics.console.text yview moveto 1
  }

  proc showClocks {} {
    set w .fics.bottom

    if {![winfo exists .fics]} {
      return
    }
    if {$::fics::graphon || $::fics::smallclocks} {
      pack forget $w.clocks
    } else {
      pack $w.clocks -side left -padx 10 -pady 5
    }
    catch ::board::ficslabels
  }


  proc updateGraph { } {
    set ::fics::sought 1
    set ::fics::soughtlist {}
    writechan "sought"
    ### This vwait cause f-ing headaches.
    # ... so don't update graph if playing
    vwaitTimed ::fics::sought 5000 "nowarn"
    if {$::fics::playing != 1 && $::fics::playing != -1 && $::fics::graphon && [winfo exists .fics]} {
      after 3000 ::fics::updateGraph
    }
  }


  proc displayGraph { } {
    global ::fics::graphwidth ::fics::graphheight ::fics::graphoff \
        ::fics::offers_minelo ::fics::offers_maxelo ::fics::offers_mintime ::fics::offers_maxtime

    after cancel ::fics::updateGraph

    set w .fics.bottom.graph
    set size 7
    set idx 0

    #first erase the canvas
    foreach id [ $w.c find all] { $w.c delete $id }

    set xoff $graphoff
    set yoff [expr $graphoff - 2]
    set width  $::fics::graphwidth
    set height $::fics::graphheight
    set gx [expr $width - $xoff]
    set gy [expr $height - $yoff]

    # Draw Axis
    # E (xoff,0)
    # L |
    # O |
    #   |
    #   |
    #   (xoff,gy)-------------------(width,gy) Time

    # X axis, Y Axis
    $w.c create line $xoff $gy $width $gy -fill blue
    # Y axis
    $w.c create line $xoff $gy $xoff 0 -fill blue

    # Labels
    $w.c create text [expr $xoff - 10] 0 -fill black -anchor nw -text "E\nL\nO"
    $w.c create text $width [expr $height + 2] -fill black -anchor se -text [tr Time]

    # Time marker at 5'
    set x [ expr $xoff + 5 * ($width - $xoff) / ($offers_maxtime - $offers_mintime)]
    $w.c create line $x 0 $x $gy -fill grey
    $w.c create text [expr $x - 5] [expr $height + 2]  -fill black -anchor sw -text "5min"

    # Time marker at 15'
    set x [ expr $xoff + 15 * ($width - $xoff) / ($offers_maxtime - $offers_mintime)]
    $w.c create line $x 0 $x $gy -fill grey
    $w.c create text [expr $x - 5] [expr $height + 2] -fill black -anchor sw -text "15min"

    foreach g $::fics::soughtlist {
      array set l $g
      set fillcolor skyblue ; set outline blue

      # if the time is too large, put it in red
      set tt [expr $l(time_init) + $l(time_inc) * 2 / 3 ]
      if { $tt > $offers_maxtime } {
        set tt $offers_maxtime
        set fillcolor red ; set outline darkred
      }
      # Computer opponent
      if { [string match "*(C)" $l(name)] } {
        set fillcolor green ; set outline darkgreen
      }
      # Player without ELO
      if { [string match "Guest*" $l(name)] } {
        set fillcolor gray ; set outline darkgray
      }
      
      set x [ expr $xoff + $tt * ($width - $xoff) / ($offers_maxtime - $offers_mintime)]
      set y [ expr $height - $yoff - ( $l(elo) - $offers_minelo ) * ($height - $yoff) / ($offers_maxelo - $offers_minelo)]
      if { $l(rated) == "rated" } {
        set object "oval"
      } else {
        set object "rectangle"
      }
      $w.c create $object [expr $x - $size ] [expr $y - $size ] [expr $x + $size ] [expr $y + $size ] -tag game_$idx -fill $fillcolor -outline $outline
      
      $w.c bind game_$idx <Enter> "::fics::showGraphText $idx %x %y"
      $w.c bind game_$idx <Leave> "::fics::delGraphText $idx"
      $w.c bind game_$idx <ButtonPress> "::fics::acceptGraphGame $idx"
      incr idx
    }

  }
  ################################################################################
  # Play the selected game
  ################################################################################
  proc acceptGraphGame { idx } {
    array set ga [lindex $::fics::soughtlist $idx]
    catch {
      writechan "play $ga(game)" echo
    }
  }
  ################################################################################
  #
  ################################################################################

  proc delGraphText { idx } {
    set w .fics.bottom.graph

    $w.c itemconfig game_$idx -width 1
    $w.c delete status
  }

  proc showGraphText {idx x y {exit 0}} {

    set w .fics.bottom.graph

    $w.c itemconfig game_$idx -width 2
    set gl [lindex $::fics::soughtlist $idx]
    if { $gl == "" } { return }
    array set l [lindex $::fics::soughtlist $idx]
    set m "$l(name)($l(elo)) $l(time_init)/$l(time_inc) $l(rated) $l(type) $l(color) $l(start)"
    
    $w.c delete status
    $w.c create text 20 0 -tags status -text "$m" -font font_Regular -anchor nw
    $w.c raise game_$idx

  }

  proc writechan {line {echo "noecho"}} {
    after cancel ::fics::stayConnected
    if {[eof $::fics::sockchan]} {
      tk_messageBox -title "Write error" -icon error -type ok -message "Network error\nFics will exit"
      ::fics::close error
      return
    }

    if {$::fics::use_timeseal} {
      # Remove non-ascii chars. They cause timeseal to die and give a network error
      set line [regsub -all {[\u0080-\uffff]} $line ?]
    }

    puts $::fics::sockchan $line

    if {$echo != "noecho"} {
      updateConsole "->>$line"
    }
    after 2700000 ::fics::stayConnected
  }
  ################################################################################
  # FICS seems to close connexion after 1 hr idle. So send a dummy command
  # every 45 minutes
  ################################################################################
  proc stayConnected {} {
    catch {
      writechan "date" "noecho"
      after 2700000 ::fics::stayConnected
    }
  }
  ################################################################################
  #
  ################################################################################
  proc close {{mode {}}} {
    variable logged

    bind .fics <Destroy> {}
    destroy .board.clock2
    destroy .board.clock1

    # Unused
    if {$mode == "safe"} {
      set ans [tk_dialog .fics_dialog Abort "You are playing a game\nDo you want to exit ?" question {} Exit Cancel ]
      if {$ans == 1} {
	bind .fics <Destroy> ::fics::close
        return
      }
    }

    set ::fics::sought 0
    after cancel ::fics::updateGraph
    after cancel ::fics::stayConnected
    set logged 0

    if {$mode != "error"} {
      catch {
        writechan "exit"
      }
    }
    set ::fics::playing 0
    set ::fics::mainGame -1
    # Hmmm... why do we need to catch these ?
    catch { ::close $::fics::sockchan }
    catch { ::close $::fics::sockping }
    after cancel ::fics::clearPing
    if { ! $::windowsOS } { catch { exec -- kill -s INT [ $::fics::timeseal_pid ] }  }

    catch {destroy .ficsOffers}
    catch {destroy .fics}
  }


  proc initPing {} {
    # get ping to report in every 10 seconds
    set ::fics::sockping [open "|ping -i 10 $::fics::server" r]
    fconfigure $::fics::sockping -blocking 0 -buffering line -translation auto 
    fileevent $::fics::sockping readable ::fics::readPing
    updateConsole "Starting Ping"
  }

  proc readPing {} {

    # ping should report every ten seconds (see above), so if it doesn't, zero ping label
    after cancel ::fics::clearPing
    after 18000  ::fics::clearPing 
    
    if {[eof $::fics::sockping]} {
      fileevent $::fics::sockping readable {}
      puts "Ping exitted"
      return
    }
    set line [gets $::fics::sockping]
    
    if {[regexp {.* time=(.*) } $line t1 t2]} {
      set ::fics::ping "ping: $t2 ms"
    } else {
      set ::fics::ping {ping ....}
    }
    ### Windows/ FreeBSD ?
    ### ping: 64 bytes from fics.freechess.org (69.36.243.188): icmp_seq=24 ttl=55 time=265 ms
  }

  proc clearPing {} {
    set ::fics::ping {ping ....}
  }


}

###
### End of file: fics.tcl
###
