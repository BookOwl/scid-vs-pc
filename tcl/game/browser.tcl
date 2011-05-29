
####################
# Game Browser window

namespace eval ::gbrowser {}

proc ::gbrowser::new {base gnum {ply -1} {w {}}} {

  # If $w is given, it is a toplevel already created which we will use

  # Hack to stop the gnext button from using ply after treeBest has been destroyed
  if {![winfo exists .treeBest$base]} { set ply 0 }

  set gnum [string trim $gnum]
  set n 0

  if {$base < 1} { set base [sc_base current] }
  if {$gnum < 1} { set gnum [sc_game number] }

  # perform sanity check
  if {$gnum > [sc_base numGames $base]} {
    set gnum [sc_base numGames $base]
  }
  
  set filename [file tail [sc_base filename $base]]
  if {[catch {set header [sc_game summary -base $base -game $gnum header]}]} {
    return
  }

  if {$w == {}} {
    while {[winfo exists .gb$n]} { incr n }
    set w .gb$n
    toplevel $w
    setWinLocation $w
    wm resizable $w 1 0

    pack [frame $w.b] -side bottom -fill x

    ::board::new $w.bd $::gbrowser::size
    $w.bd configure -relief solid -borderwidth 1
    pack $w.bd -side left -padx 4 -pady 4

    autoscrollframe $w.t text $w.t.text \
      -foreground black  -wrap word \
      -width 40 -height 12 -font font_Small -setgrid 1
    pack $w.t -side right -fill both -expand yes

    set t $w.t.text
    $t configure -cursor {}
    event generate $t <ButtonRelease-1>
    $t tag configure header -foreground darkBlue
    $t tag configure next -background $::pgnColor(Current)

    bind $w <F1> {helpWindow GameList Browsing}
    bind $w <Escape> "destroy $w"
    bind $w <Home> "::gbrowser::update $n start"
    bind $w <End> "::gbrowser::update $n end"
    bind $w <Left> "::gbrowser::update $n -1"
    bind $w <Right> "::gbrowser::update $n +1"
    bind $w <Up> "::gbrowser::update $n -10"
    bind $w <Down> "::gbrowser::update $n +10"
    bind $w <Control-Shift-Left> "::board::resize $w.bd -1"
    bind $w <Control-Shift-Right> "::board::resize $w.bd +1"

    if {$::windowsOS} {
      # needs testing
      bind $w <MouseWheel> {
	if {[expr -%D] < 0} "::gbrowser::update $n -1"
	if {[expr -%D] > 0} "::gbrowser::update $n +1"
      }
      bind $w <Control-MouseWheel> {
	if {[expr -%D] < 0} "::board::resize $w.bd +1"
	if {[expr -%D] > 0} "::board::resize $w.bd -1"
      }
      # TODO: Test above, and handle wheelmouse in text widget
    } else {
      bind $w <Button-4> "::gbrowser::update $n -1"
      bind $w <Button-5> "::gbrowser::update $n +1"
      bind $w <Control-Button-4> "::board::resize $w.bd +1"
      bind $w <Control-Button-5> "::board::resize $w.bd -1"
      # Handle wheelmouse in text widget
      bind $w.t.text <Button-4> "::gbrowser::update $n -1 ; break"
      bind $w.t.text <Button-5> "::gbrowser::update $n +1 ; break"
      bind $w.t.text <Control-Button-4> "::board::resize $w.bd +1 ; break"
      bind $w.t.text <Control-Button-5> "::board::resize $w.bd -1 ; break"
    }

    button $w.b.start -image tb_start -command "::gbrowser::update $n start" -relief flat
    button $w.b.back -image tb_prev -command "::gbrowser::update $n -1" -relief flat
    button $w.b.forward -image tb_next -command "::gbrowser::update $n +1" -relief flat
    button $w.b.end -image tb_end -command "::gbrowser::update $n end" -relief flat
    button $w.b.autoplay -image autoplay_off -command "::gbrowser::autoplay $n" -relief flat
    set ::gbrowser::flip($n) [::board::isFlipped .board]
    button $w.b.flip -image tb_flip -command "::gbrowser::flip $n" -relief flat

    # hack to center the lower button bar
    # set width [expr [winfo reqwidth $w.bd] - [winfo reqwidth $w.b.start]*6]

    pack [frame $w.b.gap -width 20] $w.b.start $w.b.back $w.b.forward $w.b.end \
      $w.b.autoplay $w.b.flip -side left -padx 3 -pady 1

    set ::gbrowser::autoplay($n) 0

    if {$gnum > 0} {
      dialogbutton $w.b.load -textvar ::tr(LoadGame) -command "sc_base switch $base; ::game::Load $gnum"
      dialogbutton $w.b.merge -textvar ::tr(MergeGame) -command "mergeGame $base $gnum"
    }

    # Behaviour of ply is a little confusing.
    # It is generally "-1", and gets its value from sc_filter
    # The gnext/gprev buttons below will also set it explicitly

    if {$ply < 0} {
      set ply 0
      if {$gnum > 0} {
	set ply [sc_filter value $base $gnum]
	if {$ply > 0} { incr ply -1 }
      }
    }

    button $w.b.first -image tb_gfirst -relief flat -command "::gbrowser::load $w $base $gnum $ply 1"
    button $w.b.prev -image tb_gprev -relief flat -command   "::gbrowser::load $w $base $gnum $ply -1"
    button $w.b.next -image tb_gnext -relief flat -command   "::gbrowser::load $w $base $gnum $ply +1"
    button $w.b.last -image tb_glast -relief flat -command   "::gbrowser::load $w $base $gnum $ply end"
    dialogbutton $w.b.close -textvar ::tr(Close) -command "destroy $w"

    pack $w.b.close $w.b.last $w.b.next $w.b.prev $w.b.first -side right -padx 1 -pady 1
    if {$gnum > 0} {
      pack $w.b.merge $w.b.load -side right -padx 1 -pady 1
    }

    # bind $w <Configure> "recordWinSize $w"

  } else {

    scan $w {.gb%i} n
    set t $w.t.text
    $t configure -state normal
    $t delete 0.0 end

    $w.b.first configure -command "::gbrowser::load $w $base $gnum $ply 1"
    $w.b.prev configure -command   "::gbrowser::load $w $base $gnum $ply -1"
    $w.b.next configure -command   "::gbrowser::load $w $base $gnum $ply +1"
    $w.b.last configure -command   "::gbrowser::load $w $base $gnum $ply end"
  }

  wm title $w "Scid:  $filename :  game $gnum"
  set ::gbrowser::boards($n) [sc_game summary -base $base -game $gnum boards]
  set moves [sc_game summary -base $base -game $gnum moves]

  $t insert end "$header" header
  $t insert end "\n\n"

  set m 0

  foreach i $moves {
    set moveTag m$m
    $t insert end [::trans $i] $moveTag
    $t insert end " "
    $t tag bind $moveTag <ButtonRelease-1> "::gbrowser::update $n $m"
    $t tag bind $moveTag <Any-Enter> \
      "$t tag configure $moveTag -underline 1"
    $t tag bind $moveTag <Any-Leave> \
      "$t tag configure $moveTag -underline 0"
    incr m
  }

  ::gbrowser::update $n $ply
}

proc ::gbrowser::load {w base gnum ply n} {
  global tree

  # The behaviour changes according to whether .treeBest$base exists or not
  if {![sc_base inUse $base]} {
    tk_messageBox -type ok -icon error -title "Browser Error" -message "Base $base is no longer open." -parent $w
    destroy $w
    return
  }

  if {[winfo exists .treeBest$base]} {

    ### best games

    set newgame $gnum
    set index [lsearch $tree(bestList$base) $gnum]
    set max [llength $tree(bestList$base)]
    if {$index == -1} {
      # oops - best games list may have changed, so load first game
      set n 1
    }

    switch -- $n {
      1 {
	 set newgame [lindex $tree(bestList$base) 0]
      }
      -1 {
	 if {$index > 0} {
	   incr index -1
	   set newgame [lindex $tree(bestList$base) $index]
	 }
      }
      +1 {
	 incr index 1
	 if {$index < $max} {
	   set newgame [lindex $tree(bestList$base) $index]
	 }
      }
      end {
	   set newgame [lindex $tree(bestList$base) end]
      }
      default {
	 puts "::gbrowser::load: bad variable 'n'"
	 set newgame 1
      }
   }
  } else {
    set newgame $gnum
    switch -- $n {
      1 {
	 set newgame 1
      }
      -1 {
	 if {$gnum > 1} {
	   incr newgame -1
	 }
      }
      +1 {
	 incr newgame +1
      }
      end {
	 set newgame $::MAXGAME
      }
      default {
	 puts "::gbrowser::load: bad variable 'n'"
	 set newgame 1
      }
   }

  }
  ::gbrowser::new $base $newgame $ply $w
}

proc ::gbrowser::flip {n} {
  ::board::flip .gb$n.bd
}

proc ::gbrowser::update {n ply} {
  set w .gb$n
  if {! [winfo exists $w]} { return }
  set oldply 0
  if {[info exists ::gbrowser::ply($n)]} { set oldply $::gbrowser::ply($n) }
  if {$ply == "forward"} { set ply [expr {$oldply + 1} ] }
  if {$ply == "back"} { set ply [expr {$oldply - 1} ] }
  if {$ply == "start"} { set ply 0 }
  if {$ply == "end"} { set ply 9999 }
  if {[string index $ply 0] == "-"  ||  [string index $ply 0] == "+"} {
    set ply [expr {$oldply + $ply} ]
  }
  if {$ply < 0} { set ply 0 }
  set max [expr {[llength $::gbrowser::boards($n)] - 1} ]
  if {$ply > $max} { set ply $max }
  set ::gbrowser::ply($n) $ply
  ::board::update $w.bd [lindex $::gbrowser::boards($n) $ply] 1

  set t $w.t.text
  $t configure -state normal
  set moveRange [$t tag nextrange m$ply 1.0]
  $t tag remove next 1.0 end
  set moveRange [$t tag nextrange m$ply 1.0]
  if {[llength $moveRange] == 2} {
    $t tag add next [lindex $moveRange 0] [lindex $moveRange 1]
    $t see [lindex $moveRange 0]
  }
  $t configure -state disabled

  if {$::gbrowser::autoplay($n)} {
    if {$ply >= $max} {
      ::gbrowser::autoplay $n
    } else {
      after cancel "::gbrowser::update $n +1"
      after $::autoplayDelay "::gbrowser::update $n +1"
    }
  }
}

proc ::gbrowser::autoplay {n} {
  if {$::gbrowser::autoplay($n)} {
    set ::gbrowser::autoplay($n) 0
    .gb$n.b.autoplay configure -image autoplay_off
    return
  } else {
    set ::gbrowser::autoplay($n) 1
    .gb$n.b.autoplay configure -image autoplay_on
    ::gbrowser::update $n +1
  }
}

