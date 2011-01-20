###
### fics.tcl: part of Scid.
### Copyright (C) 2007  Pascal Georges
###
### Reorganised by stevenaaus, with a new Offers widget 2010

namespace eval fics {
  set server "freechess.org"
  set sockchan 0
  set seeklist {}
  set observedGame -1
  set playing 0
  set waitForRating ""
  set waitForMoves ""
  # This variable is misnamed S.A. 1=noise 0=quiet
  set sought 0
  set soughtlist {}
  set graphwidth 300
  set graphheight 200 ; # fine tuned to be the same height as clocks S.A.
  set graphoff 15 ;# axis offset
  set graphon 0
  set timeseal_pid 0
  font create font_offers -family courier -size 12 -weight bold
  set history {}
  set history_pos 0
  set history_current {}
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

  ################################################################################
  #
  ################################################################################
  proc config {} {
    variable logged
    global ::fics::sockChan
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
    wm title $w "ConfigureFics"

    label $w.lLogin -text "Username"
    entry $w.login -width 20 -textvariable ::fics::login
    label $w.lPwd -text "Password"
    entry $w.passwd -width 20 -textvariable ::fics::password -show "*"

    # Time seal configuration
    checkbutton $w.timeseal -text "Time seal" -variable ::fics::use_timeseal \
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
    button $w.timeseal_browse -text ". . ." -command { set ::fics::timeseal_exec [tk_getOpenFile -parent .ficsConfig] } -pady 0.8

    if {!$::fics::use_timeseal} {
      $w.timeseal_entry configure -state disabled
      $w.timeseal_browse configure -state disabled
    }

    # label $w.lFICS_IP -text "Server IP"
    # entry $w.ip -width 16 -textvariable ::fics::server_ip
    label $w.lFICS_port -text "Server port"
    entry $w.portserver -width 6 -textvariable ::fics::port_fics
    label $w.ltsport -text "Timeseal port"
    entry $w.portts -width 6 -textvariable ::fics::port_timeseal

    frame $w.button
    button $w.button.connect -text Login -command {
      set ::fics::login     [.ficsConfig.login get]
      set ::fics::reallogin $::fics::login
      set ::fics::password  [.ficsConfig.passwd get]
      ::fics::connect
    } -state disabled

    button $w.button.connectguest -text {Login as Guest} -command {
      set ::fics::reallogin guest
      ::fics::connect guest
    } -state disabled

    button $w.button.help -text Help -command {helpWindow FICS}

    button $w.button.cancel -text Cancel -command {destroy .ficsConfig}

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
    grid $w.timeseal_browse -column 2 -row $row -sticky w -padx 2

    incr row
    # grid $w.lFICS_IP -column 0 -row $row
    # grid $w.ip -column 1 -row $row
    # incr row
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

    update
    placeWinOverParent $w .
    wm state $w normal
    busyCursor .
    update

    # First handle the case of a network down
    if { [catch {set sockChan [socket -async $::fics::server $::fics::port_fics]} err]} {
      ::fics::unbusy_config
      tk_messageBox -icon error -type ok -title "Unable to contact $::fics::server" -message $err -parent .ficsConfig
      return
    }

    # Then the case of a proxy
    set timeOut 5
    set i 0
    while { $i <= $timeOut } {
      after 1000

      if { [catch {set peer [ fconfigure $sockChan -peername ]} err]} {
        if {$i == $timeOut} {
	  ::fics::unbusy_config
          tk_messageBox -icon error -type ok -title "Unable to contact $::fics::server" -message $err -parent .ficsConfig
          return
        }
      } else  {
        break
      }
      incr i
    }

    set ::fics::server_ip [lindex $peer 0]
    ::close $sockChan

    ::fics::unbusy_config
    update
  }

  proc unbusy_config {} {
    set w .ficsConfig
    $w.button.connect configure -state normal
    $w.button.connectguest configure -state normal
    focus $w.button.connect
    unbusyCursor .
  }

  proc pauseGame {args} {
    if {[winfo exists .fics]} {
      after 200 {
	if {![sc_pos isAt end] && $::fics::playing} { 
          warnStatusBar "Fics: Warning, board doesn't show current game position"
	}
      }
    }
  }

  ################################################################################
  #
  ################################################################################
  proc connect {{guest no}} {
    global ::fics::sockchan ::fics::seeklist ::fics::graphwidth ::fics::graphheight fontOptions

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
    pack $w.bottom.clocks -side left -padx 10 -pady 5
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

    # define colors for console
    $w.console.text tag configure seeking -foreground grey
    $w.console.text tag configure tells -foreground coral
    $w.console.text tag configure command -foreground skyblue
    $w.console.text tag configure game -foreground grey70
    $w.console.text tag configure gameresult -foreground SlateBlue1
    $w.console.text tag configure channel -foreground rosybrown

    entry $w.command.entry -insertofftime 0 -bg grey75 -font font_Large
    button $w.command.send -text Send -command ::fics::cmd
    button $w.command.clear -text Clear -command "
      $w.console.text delete 0.0 end
      $w.console.text insert 0.0 \"FICs ($::scidName $::scidVersion)\n\"
    "
    button $w.command.next -text Next -command {::fics::writechan next echo}
    bind $w.command.entry <Return> { ::fics::cmd }
    bind $w.command.entry <Up> { ::fics::cmdHistory up }
    bind $w.command.entry <Down> { ::fics::cmdHistory down }
    bind $w.command.entry <Alt-BackSpace> { 
      # bash like delete last word on command line
      set i [string last { } [.fics.command.entry get] ]
      incr i 1
      .fics.command.entry delete $i end
    }
    bind $w <Control-p> ::pgn::OpenClose
    bind $w <Prior> "$w.console.text yview scroll -1 page"
    bind $w <Next>  "$w.console.text yview scroll +1 page"
    # i cant think how to separate the entry and console bind for 'Home' and 'End'
    # bind $w <Home>  "$w.console.text yview moveto 0"
    bind $w <End>   "$w.console.text yview moveto 1"


    # steer focus into the command entry, as typing into the text widget is pointless
    bind $w.console.text <FocusIn> "focus $w.command.entry"
    pack $w.command.entry -side left -fill x -expand 1 -padx 3 -pady 2
    pack $w.command.next $w.command.clear $w.command.send -side right -padx 3 -pady 2
    focus $w.command.entry

    # clock 1 is white
    ::gameclock::new $w.bottom.clocks 1 100 0
    ::gameclock::new $w.bottom.clocks 2 100 0
    set ::fics::playing 0

    set row 0
    # silence button actually only affects tells now
    checkbutton $w.bottom.buttons.silence -text "Tells" -state disabled \
    -variable ::fics::silence -command {
      ::fics::writechan "set chanoff [expr !$::fics::silence]" noecho
    }
    checkbutton $w.bottom.buttons.shouts -text "Shouts" -state disabled -variable ::fics::shouts -command {
      ::fics::writechan "set shout $::fics::shouts" echo
      ::fics::writechan "set cshout $::fics::shouts" noecho
      # ::fics::writechan "set gin $::fics::gamerequests" echo
    }

    checkbutton $w.bottom.buttons.offers -text "Offers graph" -variable ::fics::graphon -command ::fics::showOffers -width 10 -state disabled
    # -state disabled ; enable for testing S.A. &&&

    grid $w.bottom.buttons.silence      -column 0 -row $row -sticky w
    grid $w.bottom.buttons.shouts	-column 1 -row $row -sticky w
    grid $w.bottom.buttons.offers       -column 2 -row $row -sticky w -padx 2 -pady 2

    incr row
    button $w.bottom.buttons.info2 -text "Opponent Info" -command {
      set t1 [sc_game tags get Black]
      if {$::fics::reallogin ==  $t1} {
	set t1 [sc_game tags get White]
      }
      if {$t1 != {} && $t1 != {?}} {
	::fics::writechan "finger $t1"
      }
    }
    button $w.bottom.buttons.info  -text Info -command {
      ::fics::writechan finger
      ::fics::writechan "inchannel $::fics::reallogin"
      ::fics::writechan history
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
    button $w.bottom.buttons.draw   -text {Offer Draw} -command { ::fics::writechan draw }
    button $w.bottom.buttons.resign -text Resign       -command { ::fics::writechan resign }
    button $w.bottom.buttons.abort  -text Rematch      -command { ::fics::writechan rematch }
    grid $w.bottom.buttons.draw   -column 0 -row $row -sticky ew -padx 3 -pady 2
    grid $w.bottom.buttons.resign -column 1 -row $row -sticky ew -padx 3 -pady 2
    grid $w.bottom.buttons.abort  -column 2 -row $row -sticky ew -padx 3 -pady 2

    incr row
    button $w.bottom.buttons.takeback  -text {Take Back}   -command {
      ::fics::writechan takeback
      # these two comments gets zero-ed. See "Game out of sync"
      catch { ::commenteditor::appendComment "$::fics::reallogin requests takeback $::fics::playerslastmove" }
    }
    button $w.bottom.buttons.takeback2 -text {Take Back 2} -command {
      ::fics::writechan {takeback 2}
      catch { ::commenteditor::appendComment "$::fics::reallogin requests takeback $::fics::playerslastmove" }
    }
    button $w.bottom.buttons.help    -text Help -command {helpWindow FICS}
    grid $w.bottom.buttons.takeback  -column 0 -row $row -sticky ew -padx 3 -pady 2
    grid $w.bottom.buttons.takeback2 -column 1 -row $row -sticky ew -padx 3 -pady 2
    grid $w.bottom.buttons.help      -column 2 -row $row -sticky ew -padx 3 -pady 2

    incr row
    frame $w.bottom.buttons.space -height 2 -borderwidth 0
    grid  $w.bottom.buttons.space -column 0 -row $row -columnspan 3 -sticky ew -pady 3

    incr row
    button $w.bottom.buttons.findopp -text {Start Game} -command { ::fics::findOpponent }
    button $w.bottom.buttons.cancel -text {Quit FICs} -command { ::fics::close }
    grid $w.bottom.buttons.findopp -column 0 -row $row -sticky ew -padx 3 -pady 2
    grid $w.bottom.buttons.cancel -column 2 -row $row -sticky ew -padx 3 -pady 2

    bind $w <Control-q> "::fics::close"
    bind $w <Destroy>   "::fics::close"
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

  ################################################################################
  #
  ################################################################################
  proc cmd {} {
    set l [.fics.command.entry get]
    .fics.command.entry delete 0 end
    if {$l == "quit"} {
      ::fics::close
      return
    }
    # do nothing if the command is void
    if {[string trim $l] == ""} {
      return
    }
    writechan $l "echo"
    # &&& for TESTING comment above
    lappend ::fics::history $l
    set ::fics::history_pos [llength $::fics::history]
    .fics.console.text yview moveto 1
  }
  ################################################################################
  #
  ################################################################################
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
    set w .ficsfindopp
    if {[winfo exists $w]} {
      focus $w
      return
    }
    toplevel $w
    wm state $w withdrawn
    wm title $w "Find Opponent"

    set row 0

    checkbutton $w.cbrated -text {Rated game} -onvalue rated -offvalue unrated -variable ::fics::findopponent(rated)
    grid $w.cbrated -column 1 -row $row -sticky w

    incr row
    checkbutton $w.cbmanual -text {Confirm manually} -onvalue manual -offvalue auto -variable ::fics::findopponent(manual)
    grid $w.cbmanual -column 1 -row $row -sticky w

    incr row
    frame $w.space$row -height 2 -borderwidth 0
    grid  $w.space$row -column 0 -row $row -columnspan 3 -sticky ew -pady 3

    incr row
    label $w.linit -text {Time (minutes)}
    spinbox $w.sbTime1 -width 7 -textvariable ::fics::findopponent(initTime) -from 0 -to 120 -increment 1
    label $w.linc -text {Increment (seconds)}
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
    label $w.color -text Color
    grid $w.color -column 1 -row $row

    incr row
    radiobutton $w.rb2 -text White -value white -variable ::fics::findopponent(color)
    radiobutton $w.rb3 -text Black -value black -variable ::fics::findopponent(color)
    radiobutton $w.rb1 -text Auto  -value auto  -variable ::fics::findopponent(color)
    grid $w.rb1 -column 0 -row $row -ipadx 5
    grid $w.rb2 -column 1 -row $row -ipadx 5
    grid $w.rb3 -column 2 -row $row -ipadx 5

    incr row
    frame $w.space$row -height 2 -borderwidth 0
    grid  $w.space$row -column 0 -row $row -columnspan 3 -sticky ew -pady 3

    incr row
    checkbutton $w.cblimitrating -text {Rating between} -variable ::fics::findopponent(limitrating)
    spinbox $w.sbrating1 -width 7 -textvariable ::fics::findopponent(rating1) \
	-from 800 -to 2800 -increment 50
    spinbox $w.sbrating2 -width 7 -textvariable ::fics::findopponent(rating2) \
	-from 800 -to 2800 -increment 50 

    grid $w.cblimitrating -column 0 -row $row -sticky w
    grid $w.sbrating1     -column 1 -row $row
    grid $w.sbrating2     -column 2 -row $row

    incr row
    checkbutton $w.cbformula -text {Filter with formula} -onvalue formula \
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
    button $w.help   -text "Help" -command "helpWindow FICSfindopp" -width 10
    button $w.cancel -text "Cancel" -command "destroy $w" -width 10

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
    # it seems that the first offer starts with a prompt
    if {[string match "fics% *" $l]} {
      set l [string range $l 6 end]
    }

    if { [ catch { if {[llength $l] < 8} { return 0} } ] } { return 0}

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
      return 0
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
  ################################################################################
  #
  ################################################################################
  proc readparse {line} {
    variable logged

    if {$line == "" || $line == "fics% "} {return}

    if { $::fics::sought } {
      if {[string match "* ad* displayed." $line]} {
        set ::fics::sought 0
        catch { displayOffers }
        return
      }
      # lappend ::fics::soughtlist $line
      if { [ parseSoughtLine $line ] } {
        return
      }
    }

    if {[string match "login: " $line]} {
      writechan $::fics::reallogin
      if { [string match -nocase guest $::fics::reallogin ] } {
        set logged 1
      }
      return
    }

    if {[string match "password: " $line]} {
      writechan $::fics::password
      set logged 1
      return
    }
    if {[string match "<sc>*" $line]} {
      set ::fics::seeklist {}
      return
    }
    if {[string match "<s>*" $line]} {
      parseSeek $line
      return
    }
    if {[string match "<sr>*" $line]} {
      removeSeek $line
      return
    }

    if {[string match "<12>*" $line]} {
      parseStyle12 $line
      return
    }

    # puts "readparse->$line"
    updateConsole $line

    if {[string match "Creating: *" $line]} {
      catch {destroy .ficsOffers}
      # Setting this, stops automatically accepting rematches. (But algorythm needs fixing a little)
      set ::fics::findopponent(manual) manual

      # hide offers graph
      if { $::fics::graphon } {
        .fics.bottom.buttons.offers invoke
      }
      ::utils::sound::PlaySound sound_move
      sc_game new
      # fics::playing : 1==game_start/my move, 0==not playing, -1==opponents move
      set ::fics::playing 1

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

      # set white [lindex $line 1]
      # set whiteElo [string map { "(" "" ")" "" } [lindex $line 2] ]
      # set black [lindex $line 3]
      # set blackElo [string map { "(" "" ")" "" } [lindex $line 4] ]
      
      sc_game tags set -white $white
      sc_game tags set -whiteElo $whiteElo
      sc_game tags set -black $black
      sc_game tags set -blackElo $blackElo
      sc_game tags set -date [::utils::date::today]
      
      sc_game tags set -event "Fics [lrange $line 5 end]"
      if { [::board::isFlipped .board] } {
        if { [ string match -nocase $white $::fics::reallogin ] } { ::board::flip .board }
      } else {
        if { [ string match -nocase $black $::fics::reallogin ] } { ::board::flip .board }
      }
      updateBoard -pgn -animate
      updateTitle
      # display the win / draw / loss score
      ::fics::writechan "assess" "noecho"
      set ::fics::ignore_abort 0
      set ::fics::ignore_takeback 0
      set ::fics::ignore_draw 0
      set ::fics::ignore_adjourn 0
      set ::fics::lastmove {no move}
      set ::fics::playerslastmove {no move}
      return
    }

    if {[string match "\{Game *" $line]} {
      set num [lindex [lindex $line 0] 1]
      set res [lindex $line end]
      if {$num == $::fics::observedGame} {
        if {[string match "1/2*" $res]} {
          tk_messageBox -title "Game result" -icon info -type ok -message "Draw"
        } else {
          if {[regexp {.* ([^ ]*) resigns.*} $line t1 t2]} {
	    ::commenteditor::appendComment "$t2 resigns"
          }

          tk_messageBox -title "Game result" -icon info -type ok -message "$res"
        }
        # Game is over. Set result and save game
        ::gameclock::stop 1
        ::gameclock::stop 2
        set t1 [::gameclock::getSec 1]
        set t2 [::gameclock::getSec 2]
	::commenteditor::appendComment "Whiteclock [expr $t1 / 60]:[expr $t1 % 60]"
	::commenteditor::appendComment "Blackclock [expr $t2 / 60]:[expr $t2 % 60]"
        sc_game tags set -result $res
        catch {sc_game save [sc_game number]}
        updateBoard -pgn
        set ::fics::playing 0
        set ::fics::observedGame -1
        set ::pause 0
        updateBoard -pgn
      }
      return
    }

    if { [string match "You are now observing game*" $line] } {
      scan $line "You are now observing game %d." ::fics::observedGame
    }

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
      writechan "set silence 1"
      writechan "set echo 1"
      writechan "set chanoff [expr !$::fics::silence]"
      writechan "set cshout $::fics::shouts"
      writechan "set shout $::fics::shouts"

      # What is this ? S.A. writechan "iset nowrap 1"
      writechan "iset nohighlight 1"
      .fics.bottom.buttons.offers       configure -state normal
      .fics.bottom.buttons.silence      configure -state normal
      .fics.bottom.buttons.shouts	configure -state normal
      return
    }

    if { $::fics::waitForRating == "wait" } {
      if {[catch {set val [lindex $line 0]}]} {
        return
      } else  {
        if {[lindex $line 0] == "Standard"} {
          set ::fics::waitForRating [lindex $line 1]
          return
        }
      }
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
      if {[llength $line ] == 5 && [scan $line "%d. %s (%d:%d) %s (%d:%d)" t1 m1 t2 t3 m2 t4 t5] != 7} {
        return
      }
      if {[llength $line ] == 3 && [scan $line "%d. %s (%d:%d)" t1 m1 t2 t3] != 4} {
        return
      }
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
            catch {
	      regexp {(.*) would like to take back} $line t1 t2
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
      catch {
	regexp {(.*) offers you a draw} $line t1 t2
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

  ################################################################################
  #
  ################################################################################
  proc updateConsole {line} {

    set t .fics.console.text

    # colors defined line 281

    if {[string match {fics% *} $line]} {
	set line [string range $line 6 end]
    }

    switch -glob $line {
	{\{Game *\}}	{ $t insert end "$line\n" game }
	{\{Game *\} *}	{ $t insert end "$line\n" gameresult }
	{Auto-flagging*} {$t insert end "$line\n"
                          ::commenteditor::appendComment "Loses on time" }
	{* tells you:*}	{ $t insert end "$line\n" tells 
			  catch {
			    regexp {(.*) tells you:(.*$)} $line t1 t2 t3
			    ::commenteditor::appendComment "\[$t2\] $t3"
			  }
			}
	{* seeking *}	{ $t insert end "$line\n" seeking }
	{->>say *}	{ $t insert end "$line\n" tells 
                          # if {$::fics::playing} 
			  catch {
                            regexp -- {->>say (.*$)} $line t1 t2
			    ::commenteditor::appendComment "\[$::fics::reallogin\] $t2"
                          }
			}
	{* says: *}	{ $t insert end "$line\n" tells 
			  catch {
                            regexp {(.*) says: (.*$)} $line t1 t2 t3
                            # remove trailing [342] (eg) from player name
                            if {[regexp {(^.*)\[.*\]} $t2 t3 t4]} {
			      ::commenteditor::appendComment "\[$t4\] $t3"
                            } else {
			      ::commenteditor::appendComment "\[$t2\] $t3"
                            } 
                          }
			}
	{->>tell *}	{ $t insert end "$line\n" tells }
    	{->>*}		{ $t insert end "$line\n" command }

	{*[A-Za-z]\(*\): *} { $t insert end "$line\n" channel }
        {Finger of *}   { $t insert end "$line\n" seeking }
        {History of *}  { $t insert end "$line\n" seeking }
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
    set color [lindex $line 9]
    set gameNumber [lindex $line 16]
    set white [lindex $line 17]
    set black [lindex $line 18]
    set relation [lindex $line 19]
    set initialTime [lindex $line 20]
    set increment [lindex $line 21]
    set whiteMaterial [lindex $line 22]
    set blackMaterial [lindex $line 23]
    set whiteRemainingTime  [lindex $line 24]
    set blackRemainingTime  [lindex $line 25]
    set moveNumber [lindex $line 26]
    set verbose_move [lindex $line 27]
    set moveTime [lindex $line 28]
    set moveSan [lindex $line 29]
    set ::fics::playing $relation ; # 1 is players move -1 is opponents move
    set ::fics::observedGame $gameNumber

    ::gameclock::setSec 1 [ expr 0 - $whiteRemainingTime ]
    ::gameclock::setSec 2 [ expr 0 - $blackRemainingTime ]
    if {$color == "W"} {
      ::gameclock::start 1
      ::gameclock::stop 2
    } else {
      ::gameclock::start 2
      ::gameclock::stop 1
    }

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
            set fen "$fen$count"
            set count 0
          }
          set fen "$fen$c"
        }
      }
      
      if {$count != 0} { set fen "$fen$count" }
      if {$i != 8} { set fen "$fen/" }
    }

    set fen "$fen [string tolower $color]"
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

    set fen "$fen $castle $enpassant [lindex $line 15] $moveNumber"

    # puts $verbose_move
    puts $moveSan

    # try to play the move and check if fen corresponds. If not this means the position needs to be set up.
    if {$moveSan != "none" && $::fics::playing != -1} {
      # first check side's coherency
      if { ([sc_pos side] == "white" && $color == "B") || ([sc_pos side] == "black" && $color == "W") } {
        # puts "sc_move addSan $moveSan"
        ::utils::sound::PlaySound sound_move
        ::utils::sound::AnnounceNewMove $moveSan
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
          updateBoard -pgn -animate
        }
      }
    } else {
      set ::fics::playerslastmove $moveSan
    }

    if {$fen != [sc_pos fen]} {
      ### Game out of sync, probably due to player takeback request (or opponent take back 2).
      # After player takeback, game gets reconstructed, comments are zeroed. Opponents takeback is handled better elsewhere.
      # Fics doesn't give much warning that take back was succesful, only the uncertain "Takeback request sent."
      # So just save previous (unfinished) game.

      # Todo: Before starting new game, try to move backwards in game.

      puts "Debug fen \n$fen\n[sc_pos fen]"
      
      catch {sc_game save [sc_game number]}
      sc_game new
      set ::fics::playing 1
      
      set ::fics::waitForRating "wait"
      writechan "finger $white /s"
      vwaitTimed ::fics::waitForRating 2000 "nowarn"
      if {$::fics::waitForRating == "wait"} { set ::fics::waitForRating "0" }
      sc_game tags set -white $white
      sc_game tags set -whiteElo $::fics::waitForRating
      
      set ::fics::waitForRating "wait"
      writechan "finger $black /s"
      vwaitTimed ::fics::waitForRating 2000 "nowarn"
      if {$::fics::waitForRating == "wait"} { set ::fics::waitForRating "0" }
      sc_game tags set -black $black
      sc_game tags set -blackElo $::fics::waitForRating
      
      set ::fics::waitForRating ""
      
      sc_game tags set -event "Fics game $gameNumber $initialTime/$increment"
      
      # try to get first moves of game
      writechan "moves $gameNumber"
      set ::fics::waitForMoves $fen
      vwaitTimed ::fics::waitForMoves 2000 "nowarn"
      set ::fics::waitForMoves ""
      
      # Did not manage to reconstruct the game, just set its position
      if {$fen != [sc_pos fen]} {
        sc_game startBoard $fen
      }
      updateBoard -pgn -animate
    }
  }
  ################################################################################
  #
  ################################################################################
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
  ################################################################################
  #
  ################################################################################
  proc redim {} {
    set w .fics
    update
    set x [winfo reqwidth $w]
    set y [winfo reqheight $w]
    wm geometry $w ${x}x${y}
  }
  ################################################################################
  #
  ################################################################################
  proc showOffers {} {

    set w .fics.bottom

    # I think it's ok to show clock ~or~ offers graph
    # , which also does away with packing/config issues - S.A

    if { $::fics::graphon } {
      pack forget $w.clocks
      pack $w.graph -side left
      updateOffers
    } else {
      after cancel ::fics::updateOffers
      pack forget $w.graph
      pack $w.clocks -side left -padx 10 -pady 5
    }
    # Repacking can make the console suspend, so seek to console end now
    update
    .fics.console.text yview moveto 1
  }
  ################################################################################
  #
  ################################################################################
  proc updateOffers { } {
    set ::fics::sought 1
    set ::fics::soughtlist {}
    writechan "sought"
    vwaitTimed ::fics::sought 5000 "nowarn"
    after 3000 ::fics::updateOffers
  }
  ################################################################################
  #
  ################################################################################
  proc displayOffers { } {
    global ::fics::graphwidth ::fics::graphheight ::fics::graphoff \
        ::fics::offers_minelo ::fics::offers_maxelo ::fics::offers_mintime ::fics::offers_maxtime
    after cancel ::fics::updateOffers

    set w .fics.bottom.graph
    set size 5
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
      set fillcolor green
      # if the time is too large, put it in red
      set tt [expr $l(time_init) + $l(time_inc) * 2 / 3 ]
      if { $tt > $offers_maxtime } {
        set tt $offers_maxtime
        set fillcolor red
      }
      # if a computer, put it in blue
      if { [string match "*(C)" $l(name)] } {
        set fillcolor blue
      }
      # if player without ELO, in gray
      if { [string match "Guest*" $l(name)] } {
        set fillcolor gray
      }
      
      set x [ expr $xoff + $tt * ($width - $xoff) / ($offers_maxtime - $offers_mintime)]
      set y [ expr $height - $yoff - ( $l(elo) - $offers_minelo ) * ($height - $yoff) / ($offers_maxelo - $offers_minelo)]
      if { $l(rated) == "rated" } {
        set object "oval"
      } else {
        set object "rectangle"
      }
      $w.c create $object [expr $x - $size ] [expr $y - $size ] [expr $x + $size ] [expr $y + $size ] -tag game_$idx -fill $fillcolor
      
      $w.c bind game_$idx <Enter> "::fics::setOfferStatus $idx %x %y"
      $w.c bind game_$idx <Leave> "::fics::setOfferStatus -1 %x %y"
      $w.c bind game_$idx <ButtonPress> "::fics::getOffersGame $idx"
      incr idx
    }

  }
  ################################################################################
  # Play the selected game
  ################################################################################
  proc getOffersGame { idx } {
    array set ga [lindex $::fics::soughtlist $idx]
    catch { writechan "play $ga(game)" echo }
  }
  ################################################################################
  #
  ################################################################################
  proc setOfferStatus { idx x y } {

    set w .fics.bottom.graph
    if { $idx != -1 } {
      set gl [lindex $::fics::soughtlist $idx]
      if { $gl == "" } { return }
      array set l [lindex $::fics::soughtlist $idx]
      set m "$l(game) $l(name)($l(elo)) $l(time_init)/$l(time_inc) $l(rated) $l(type) $l(color) $l(start)"
      
      $w.c create text 35 0 -tags status -text "$m" -font font_Regular -anchor nw
      $w.c raise game_$idx
    } else {
      $w.c delete status
    }
  }
  ################################################################################
  # hmmm.. not very  unique procname S.A.
  ################################################################################
  proc play {index} {
    writechan "play $index"
    # set ::fics::playing 1
    set ::fics::observedGame $index
  }
  ################################################################################
  #
  ################################################################################
  proc writechan {line {echo "noecho"}} {
    after cancel ::fics::stayConnected
    if {[eof $::fics::sockchan]} {
      tk_messageBox -title "Write error" -icon error -type ok -message "Network error\nFics will exit"
      ::fics::close error
      return
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
    # stop recursive call
    bind .fics <Destroy> {}

    if {$mode == "safe"} {
      set ans [tk_dialog .fics_dialog Abort "You are playing a game\nDo you want to exit ?" question {} Exit Cancel ]
      if {$ans == 1} {
	bind .fics <Destroy> ::fics::close
        return
      }
    }

    set ::fics::sought 0
    after cancel ::fics::updateOffers
    after cancel ::fics::stayConnected
    set logged 0

    if {$mode != "error"} {
      catch {
        writechan "exit"
      }
    }
    set ::fics::playing 0
    set ::fics::observedGame -1
    catch {
      ::close $::fics::sockchan
    }
    if { ! $::windowsOS } { catch { exec -- kill -s INT [ $::fics::timeseal_pid ] }  }

    catch {destroy .ficsOffers}
    destroy .fics
  }
}

###
### End of file: fics.tcl
###
