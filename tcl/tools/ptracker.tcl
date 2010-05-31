
####################
# Piece tracker window

namespace eval ::ptrack {}

set ::ptrack::psize 35
set ::ptrack::select d1
set ::ptrack::moves(start) 1
set ::ptrack::moves(end) 20
set ::ptrack::mode "-games"
set ::ptrack::color blue
set ::ptrack::colors [list black red yellow cyan blue xblack xred xyellow xcyan xblue]

trace variable ::ptrack::moves(start) w {::utils::validate::Integer 999 0}
trace variable ::ptrack::moves(end) w {::utils::validate::Integer 999 0}

# ::ptrack::sq
#   Given a square number (0=a1 to 63=h8), returns the square name.
#
proc ::ptrack::sq {n} {
  set sq [lindex [list a b c d e f g h] [expr {$n % 8} ]]
  append sq [expr {int($n/8) + 1} ]
  return $sq
}

# ::ptrack::unselect
#   Unselects all pieces in the Piece Tracker window.
#
proc ::ptrack::unselect {} {
  set w .ptracker
  set ::ptrack::select {}
  foreach i {a1 c1 e1 g1 b2 d2 f2 h2 a7 c7 e7 g7 b8 d8 f8 h8} {
    $w.bd.p$i configure -background $::dark
  }
  foreach i {b1 d1 f1 h1 a2 c2 e2 g2 b7 d7 f7 h7 a8 c8 e8 g8} {
    $w.bd.p$i configure -background $::lite
  }
}

# ::ptrack::select
#   Selects all the listed pieces the Piece Tracker window.
#
proc ::ptrack::select {plist} {
  ::ptrack::unselect
  foreach p $plist {
    lappend ::ptrack::select $p
    .ptracker.bd.p$p configure -background $::highcolor
  }
}

# ::ptrack::status
#   Sets the Piece Tracker window status bar.
#
proc ::ptrack::status {{text ""}} {
  set t .ptracker.status
  if {$text == ""} {
    $t configure -text "$::tr(Filter): [filterText]"
  } else {
    $t configure -text $text
  }
}

# ::ptrack::recolor
#   Changes the color scheme for track values.
#
proc ::ptrack::recolor {color} {
  set ::ptrack::color $color
  .ptracker.t.color.b configure -image ptrack_$::ptrack::color
  ::ptrack::refresh color
}

# ::ptrack::color
#   Given a real value between 0.0 and 100.0, returns
#   the corresponding Piece Tracker color value.
#
proc ::ptrack::color {pct {col ""}} {
  if {$col == ""} {
    set col $::ptrack::color
  }
  set x $pct
  if {$x > 100.0} { set x 100.0}
  if {$x < 0.01} { set x 0.01 }
  set y [expr {255 - round($x * 0.5 + 10 * log($x))} ]
  set yb [expr {255 - round($x * 2.0 + 10 * log($x))} ]
  if {$y > 255} { set y 255}
  if {$yb > 255} { set yb 255}
  if {$yb < 0} { set yb 0}
  if {$y < 0} { set y 0}
  if {$pct > 0.0  &&  $y == 0} { set y 1 }
  if {$pct > 0.0  &&  $yb == 0} { set yb 1 }
  set xy [expr {255 - $y} ]
  set xyb [expr {255 - $yb} ]
  switch $col {
    black   { set color [format "\#%02X%02X%02X" $yb $yb $yb] }
    red     { set color [format "\#%02X%02X%02X" $y $yb $yb] }
    yellow  { set color [format "\#%02X%02X%02X" $y $y $yb] }
    cyan    { set color [format "\#%02X%02X%02X" $yb $y $y] }
    blue    { set color [format "\#%02X%02X%02X" $yb $yb $y] }
    xblack  { set color [format "\#%02X%02X%02X" $xyb $xyb $xyb] }
    xred    { set color [format "\#%02X%02X%02X" $xyb $xy $xy] }
    xyellow { set color [format "\#%02X%02X%02X" $xyb $xyb $xy] }
    xcyan   { set color [format "\#%02X%02X%02X" $xy $xyb $xyb] }
    xblue   { set color [format "\#%02X%02X%02X" $xy $xy $xyb] }
  }
  return $color
}

# ::ptrack::make
#   Creates the Piece Tracker window
#
proc ::ptrack::make {} {
  set w .ptracker
  if {[winfo exists $w]} { return }

  toplevel $w
  wm title $w "Scid: [tr ToolsTracker]"
  setWinLocation $w
  bind $w <Escape> "destroy $w"
  bind $w <F1> {helpWindow PTracker}
  image create photo ptrack -width $::ptrack::psize -height $::ptrack::psize
  label $w.status -width 1 -anchor w -relief sunken -font font_Small
  pack $w.status -side bottom -fill x

  canvas $w.progress -height 20 -width 400  -relief solid -border 1
  $w.progress create rectangle 0 0 0 0 -fill blue -outline blue -tags bar
  $w.progress create text 395 10 -anchor e -font font_Regular -tags time \
    -fill black -text "0:00 / 0:00"
  pack $w.progress -side bottom -pady 2

  frame $w.bd
  pack $w.bd -side left -padx 2 -pady 4

  frame $w.t
  pack $w.t -side right -fill y -expand yes
  pack [frame $w.gap -width 5] -side left

  frame $w.t.color
  frame $w.t.mode
  frame $w.t.moves
  frame $w.t.buttons
  pack $w.t.buttons -side bottom -fill x
  pack $w.t.moves -side bottom
  pack $w.t.mode -side bottom
  pack $w.t.color -side bottom

  set ::ptrack::shade {}
  for {set i 0} {$i < 64} {incr i} {
    label $w.bd.sq$i -image ptrack  -border 1 -relief raised
    set rank [expr {$i / 8}]
    set file [expr {$i % 8} ]
    grid $w.bd.sq$i -row [expr {7 - $rank} ] -column [expr {$file + 1} ]
    lappend ::ptrack::shade 0.0
  }

  foreach rank {1 2 3 4 5 6 7 8} {
    label $w.bd.r$rank -text $rank -width 2
    grid $w.bd.r$rank -column 0 -row [expr {8 - $rank} ]
  }

  foreach column {1 2 3 4 5 6 7 8} file {a b c d e f g h} {
    label $w.bd.f$file -text $file
    grid $w.bd.f$file -row 8 -column $column
  }

  grid [frame $w.bd.gap1 -height 5] -row 9 -column 0

  foreach file {a b c d e f g h} c {1 2 3 4 5 6 7 8} p {r n b q k b n r} {
    set sq ${file}8
    set b $w.bd.p$sq
    label $b -image b$p$::ptrack::psize -border 1 -relief raised
    grid $b -row 10 -column $c
    bind $b <1> "::ptrack::select $sq"
  }
  foreach file {a b c d e f g h} c {1 2 3 4 5 6 7 8} p {p p p p p p p p} {
    set sq ${file}7
    set b $w.bd.p$sq
    label $b -image b$p$::ptrack::psize -border 1 -relief raised
    grid $b -row 11 -column $c
    bind $b <1> "::ptrack::select $sq"
    bind $b <3> "::ptrack::select {a7 b7 c7 d7 e7 f7 g7 h7}"
  }
  grid [frame $w.bd.gap2 -height 5] -row 12 -column 0
  foreach file {a b c d e f g h} c {1 2 3 4 5 6 7 8} p {p p p p p p p p} {
    set sq ${file}2
    set b $w.bd.p$sq
    label $b -image w$p$::ptrack::psize -border 1 -relief raised
    grid $b -row 13 -column $c
    bind $b <ButtonPress-1> "::ptrack::select $sq"
    bind $b <3> "::ptrack::select {a2 b2 c2 d2 e2 f2 g2 h2}"
  }
  foreach file {a b c d e f g h} c {1 2 3 4 5 6 7 8} p {r n b q k b n r} {
    set sq ${file}1
    set b $w.bd.p$sq
    label $b -image w$p$::ptrack::psize -border 1 -relief raised
    grid $b -row 14 -column $c
    bind $b <Button-1> "::ptrack::select $sq"
  }

  # Both-piece bindings:
  foreach sq {d1 e1 d8 e8} {
    bind $w.bd.p$sq <3> [list ::ptrack::select $sq]
  }
  foreach left {a b c} right {h g f} {
    set cmd [list ::ptrack::select [list ${left}1 ${right}1]]
    bind $w.bd.p${left}1 <ButtonPress-3> $cmd
    bind $w.bd.p${right}1 <ButtonPress-3> $cmd
    set cmd [list ::ptrack::select [list ${left}8 ${right}8]]
    bind $w.bd.p${left}8 <ButtonPress-3> $cmd
    bind $w.bd.p${right}8 <ButtonPress-3> $cmd
  }

  # Status-bar help:
  foreach sq {d1 e1 d8 e8} {
    bind $w.bd.p$sq <Any-Enter> {
      ::ptrack::status $::tr(TrackerSelectSingle)
    }
    bind $w.bd.p$sq <Any-Leave> ::ptrack::status
  }

  foreach sq {a1 b1 c1 f1 g1 h1 a8 b8 c8 f8 g8 h8} {
    bind $w.bd.p$sq <Any-Enter> {
      ::ptrack::status $::tr(TrackerSelectPair)
    }
    bind $w.bd.p$sq <Any-Leave> ::ptrack::status
  }
  foreach sq {a2 b2 c2 d2 e2 f2 g2 h2 a7 b7 c7 d7 e7 f7 g7 h7} {
    bind $w.bd.p$sq <Any-Enter> {
      ::ptrack::status $::tr(TrackerSelectPawn)
    }
    bind $w.bd.p$sq <Any-Leave> ::ptrack::status
  }
  set plist $::ptrack::select
  ::ptrack::unselect
  ::ptrack::select $plist

  set f $w.t.text
  pack [frame $f] -side top -fill both -expand yes -padx 2 -pady 2
  text $f.text -width 28 -height 1 -foreground black  \
    -yscrollcommand "$f.ybar set" -relief sunken -takefocus 0 \
    -wrap none -font font_Small
  set xwidth [font measure [$f.text cget -font] "x"]
  foreach {tab justify} {3 r 5 l 19 r 29 r} {
    set tabwidth [expr {$xwidth * $tab} ]
    lappend tablist $tabwidth $justify
  }
  $f.text configure -tabs $tablist
  scrollbar $f.ybar -takefocus 0 -command "$f.text yview"
  pack $f.ybar -side right -fill y
  pack $f.text -side left -fill y -expand yes

  set f $w.t.color

  menubutton $f.b -menu $f.b.menu -indicatoron 0 -relief raised
  menu $f.b.menu
  foreach col $::ptrack::colors {
    image create photo ptrack_$col -width 101 -height 20
    for {set i 0} {$i <= 100} {incr i} {
      set color [::ptrack::color $i $col]
      ptrack_$col put $color -to $i 0 [expr {$i+1} ] 19
    }
    $f.b.menu add command -image ptrack_$col \
      -command "::ptrack::recolor $col"
  }
  $f.b configure -image ptrack_$::ptrack::color
  label $f.label -text $::tr(GlistColor:) -font font_Bold
  pack $f.label $f.b -side left -pady 5

  set f $w.t.mode
  label $f.mode -text $::tr(TrackerStat:) -font font_Bold
  grid $f.mode -row 0 -column 0
  radiobutton $f.games -text $::tr(TrackerGames) -anchor w \
    -variable ::ptrack::mode -value "-games"
  radiobutton $f.time -text $::tr(TrackerTime) -anchor w \
    -variable ::ptrack::mode -value "-time"
  grid $f.games -row 1 -column 0 -sticky we
  grid $f.time -row 2 -column 0 -sticky we

  set f $w.t.moves
  label $f.lfrom -text $::tr(TrackerMoves:) -font font_Bold
  entry $f.from -width 3 -justify right -textvariable ::ptrack::moves(start)
  label $f.lto -text "-"
  entry $f.to -width 3 -justify right -textvariable ::ptrack::moves(end)
  pack $f.lfrom $f.from $f.lto $f.to -side left -pady 5
  bindFocusColors $f.from
  bindFocusColors $f.to
  bind $f.from <FocusIn> [list +::ptrack::status $::tr(TrackerMovesStart)]
  bind $f.from <FocusOut> +::ptrack::status
  bind $f.to <FocusIn> [list +::ptrack::status $::tr(TrackerMovesStop)]
  bind $f.to <FocusOut> +::ptrack::status

  set f $w.t.buttons
  button $f.stop -text $::tr(Stop) -command sc_progressBar -state disabled
  button $f.update -text $::tr(Update) -command ::ptrack::refresh
  button $f.close -text $::tr(Close) -command "destroy $w"
  pack $f.close $f.update $f.stop -side right -padx 3 -pady 5
  ::ptrack::status
  bind $w <Configure> "recordWinSize $w"
  wm resizable $w 0 0
  focus $w.t.buttons.update
}

# ::ptrack::refresh
#   Regenerates Piece Tracker statistics and updates the window
#
proc ::ptrack::refresh {{type "all"}} {
  set w .ptracker
  if {! [winfo exists $w]} { return }

  # Check if only the color needs refreshing:
  if {$type == "color"} {
    for {set i 0} {$i < 64} {incr i} {
      set x [lindex $::ptrack::shade $i]
      $w.bd.sq$i configure -background [::ptrack::color $x]
    }
    return
  }

  busyCursor .
  $w.t.buttons.update configure -state disabled
  $w.t.buttons.close configure -state disabled
  $w.t.buttons.stop configure -state normal
  catch {grab $w.t.buttons.stop}

  if {$::ptrack::moves(end) < $::ptrack::moves(start)} {
    set ::ptrack::moves(end) $::ptrack::moves(start)
  }

  set timeMode 0
  if {$::ptrack::mode == "-time"} { set timeMode 1 }

  sc_progressBar $w.progress bar 401 21 time
  set data [eval sc_base piecetrack $::ptrack::mode \
              $::ptrack::moves(start) $::ptrack::moves(end) \
              $::ptrack::select]
  set ::ptrack::data $data

  catch {grab release $w.t.buttons.stop}
  $w.t.buttons.stop configure -state disabled
  $w.t.buttons.update configure -state normal
  $w.t.buttons.close configure -state normal
  unbusyCursor .

  set dfilter [sc_filter count]
  if {$timeMode} {
    set nmoves [expr {$::ptrack::moves(end) + 1 - $::ptrack::moves(start)} ]
    set dfilter [expr {$dfilter * $nmoves} ]
  }
  if {$dfilter == 0} { set dfilter 1 } ;# to avoid divide-by-zero

  set max 1
  for {set i 0} {$i < 64} {incr i} {
    set freq [lindex $data $i]
    if {$freq > $max} {set max $freq}
  }

  set ::ptrack::shade {}
  for {set i 0} {$i < 64} {incr i} {
    set freq [lindex $data $i]
    set x [expr {$freq * 100.0 / $max} ]
    set color [::ptrack::color $x]
    lappend ::ptrack::shade $x
    $w.bd.sq$i configure -background $color
  }

  # Update text frame:
  set text $w.t.text.text
  $text delete 1.0 end
  array set printed {}
  for {set top 1} {$top <= 64} {incr top} {
    set best -1
    set idx -1
    for {set i 0} {$i < 64} {incr i} {
      set n [lindex $data $i]
      if {$n > $best  &&  ![info exists printed($i)]} {
        set idx $i
        set best $n
      }
    }

    set printed($idx) 1
    set pct [expr {round(double($best) * 10000.0 / double($dfilter)) / 100.0} ]
    set line [format "\t%2d.\t%s\t%7s\t%6.2f %%" $top \
                [::ptrack::sq $idx] [::utils::thousands $best] $pct]
    $text insert end "$line\n"
    set status "  [::ptrack::sq $idx]: [::utils::thousands $best] ($pct%%)  $top/64"
    bind $w.bd.sq$idx <Any-Enter> [list ::ptrack::status $status]
    bind $w.bd.sq$idx <Any-Leave> ::ptrack::status
  }
}
