###
### search/material.tcl: Material Search routine for Scid.
###

namespace eval ::search::material {}

image create photo button_oneplus -data {
  R0lGODlhFAAUAIAAAAAAAP///yH5BAEKAAEALAAAAAAUABQAAAIpjI+py+0P
  FwCSzVnlzZaaC3oJNooadyqmun4OGR1wHMxQ2HYgzfd+UgAAOw==
}

set ignoreColors 0
set minMoveNum 1
set maxMoveNum 999
set minHalfMoves 1
set oppBishops "Either"
set minMatDiff -40
set maxMatDiff +40

trace variable minMoveNum w {::utils::validate::Integer 999 0}
trace variable maxMoveNum w {::utils::validate::Integer 999 0}
trace variable minHalfMoves w {::utils::validate::Integer 99 0}
trace variable minMatDiff w {::utils::validate::Integer -99 0}
trace variable maxMatDiff w {::utils::validate::Integer -99 0}

set nPatterns 10

array set pMin [list wq 0 bq 0 wr 0 br 0 wb 0 bb 0 wn 0 bn 0 wm 0 bm 0 wp 0 bp 0]
array set pMax [list wq 2 bq 2 wr 2 br 2 wb 2 bb 2 wn 2 bn 2 wm 4 bm 4 wp 8 bp 8]
for { set i 1 } { $i <= $nPatterns } { incr i } {
  set pattPiece($i) "?";  set pattFyle($i) "?";  set pattRank($i) "?"
}

proc checkPieceCounts {name el op} {
  global pMin pMax
  ::utils::validate::Integer 9 0 $name $el $op
  # Now make sure minor piece counts fit with bishop/knight counts:
  set wmMin [expr {$pMin(wn) + $pMin(wb)} ]
  set wmMax [expr {$pMax(wn) + $pMax(wb)} ]
  set bmMin [expr {$pMin(bn) + $pMin(bb)} ]
  set bmMax [expr {$pMax(bn) + $pMax(bb)} ]
  if {$pMin(wm) < $wmMin} { set pMin(wm) $wmMin }
  if {$pMax(wm) > $wmMax} { set pMax(wm) $wmMax }
  if {$pMin(bm) < $bmMin} { set pMin(bm) $bmMin }
  if {$pMax(bm) > $bmMax} { set pMax(bm) $bmMax }
  foreach p {wq wr wb wn wm wp bq br bb bn bm bp} {
    if {$pMax($p) != ""  &&  $pMax($p) < $pMin($p)} { set pMax($p) $pMin($p) }
  }
}

trace variable pMin w checkPieceCounts
trace variable pMax w checkPieceCounts


proc makeBoolMenu {w varName} {
  upvar #0 $varName var
  if {![info exists var]} { set var "Yes" }
  menubutton $w -textvariable $varName -indicatoron 0 -menu $w.menu \
      -relief raised -bd 2 -highlightthickness 2 -anchor w -image ""
  menu $w.menu -tearoff 0
  $w.menu add radiobutton -label Yes -image ::rep::_tick \
      -variable $varName -value Yes \
      -command "$w configure -image ::rep::_tick" ;# -hidemargin 1
  $w.menu add radiobutton -label No -image ::rep::_cross \
      -variable $varName -value No \
      -command "$w configure -image ::rep::_cross" ;# -hidemargin 1
  return $w.menu
}

proc makePieceMenu {w varName} {
  global dark
  upvar #0 $varName var
  if {![info exists var]} { set var "?" }
  menubutton $w -textvariable $varName -indicatoron 0 -menu $w.menu \
      -relief raised -bd 2 -highlightthickness 2 -anchor w -image ""
  menu $w.menu -tearoff 0
  $w.menu add radiobutton -label " ? " -variable $varName -value "?" \
      -command "$w configure -image e20" ;# -hidemargin 1
  foreach i {wk wq wr wb wn wp bk bq br bb bn bp} {
    $w.menu add radiobutton -label $i -image ${i}20 -value $i \
        -variable $varName \
        -command "$w configure -image ${i}20" ;# -hidemargin 1
  }
  foreach i {" ? " wk bk} {
    $w.menu entryconfigure $i -columnbreak 1
  }
  return $w.menu
}

proc updatePatternImages {} {
  global pattPiece nPatterns pattBool
  if {! [winfo exists .sm]} { return }
  for {set i 1} {$i <= $nPatterns} {incr i} {
    if {$pattBool($i) == "Yes"} {
      .sm.mp.patt.grid.b$i configure -image ::rep::_tick
    } else {
      .sm.mp.patt.grid.b$i configure -image ::rep::_cross
    }
    if {$pattPiece($i) == "?"} {
      .sm.mp.patt.grid.p$i configure -image e20
    } else {
      .sm.mp.patt.grid.p$i configure -image "$pattPiece($i)20"
    }
  }
}

# ::search::material::zero
#
#   Called to clear all material minumum/maximum values to zero.
#
proc ::search::material::zero {} {
  global pMin pMax
  array set pMin {wq 0 bq 0 wr 0 br 0 wb 0 bb 0 wn 0 bn 0 wm 0 bm 0 wp 0 bp 0}
  array set pMax {wq 0 bq 0 wr 0 br 0 wb 0 bb 0 wn 0 bn 0 wm 0 bm 0 wp 0 bp 0}
}

proc ::search::material::any {} {
  global pMin pMax
  array set pMin {wq 0 bq 0 wr 0 br 0 wb 0 bb 0 wn 0 bn 0 wm 0 bm 0 wp 0 bp 0}
  array set pMax {wq 2 bq 2 wr 2 br 2 wb 2 bb 2 wn 2 bn 2 wm 4 bm 4 wp 8 bp 8}
  set ::minMatDiff -40
  set maxMatDiff +40
}

proc clearPatterns {} {
  global pattPiece pattFyle pattRank pattBool nPatterns
  
  for { set i 1 } { $i <= $nPatterns } { incr i } {
    set pattPiece($i) "?";  set pattFyle($i) "?";  set pattRank($i) "?"
    set pattBool($i) "Yes"
  }
  updatePatternImages
}

proc setPatterns {pattlist} {
  global pattPiece pattFyle pattRank pattBool nPatterns
  
  clearPatterns
  set count 1
  foreach patt $pattlist {
    if {$count <= $nPatterns  &&  [llength $patt] == 4} {
      set pattPiece($count) [lindex $patt 0]
      set pattFyle($count) [lindex $patt 1]
      set pattRank($count) [lindex $patt 2]
      set pattBool($count) [lindex $patt 3]
      incr count
    }
  }
  updatePatternImages
}

set smDisplayed(Material) 1
set smDisplayed(Patterns) 0


# ::search::material
#
#   Opens the window for searching by material or patterns.
#
proc ::search::material {} {
  global glstart dark pMin pMax ignoreColors minMoveNum maxMoveNum
  global pattPiece pattFyle pattRank pattBool oppBishops nPatterns
  global minHalfMoves smDisplayed
  
  set w .sm
  if {[winfo exists $w]} {
    wm deiconify $w
    raiseWin $w
    return
  }
  set small font_Small
  
  toplevel $w
  wm title $w "Scid: $::tr(MaterialSearch)"
  #  button $w.piecelabel -font font_Bold -textvar ::tr(Material:) -command {
  #    if {$smDisplayed(Material)} {
  #      set smDisplayed(Material) 0
  #      pack forget .sm.q .sm.r .sm.b .sm.n .sm.m .sm.p .sm.b1 .sm.mdiff
  #    } else {
  #      set smDisplayed(Material) 1
  #      pack .sm.q .sm.r .sm.b .sm.n .sm.m .sm.p .sm.b1 .sm.mdiff \
  #        -after .sm.piecelabel
  #    }
  #  }
  
  bind $w <F1> { helpWindow Searches Material }
  bind $w <Escape> "$w.b3.cancel invoke"
  bind $w <Return> "$w.b3.search invoke"
  
  pack [frame $w.mp] -side top
  pack [frame $w.mp.material] -side left
  
  label $w.mp.material.title -font font_Bold -textvar ::tr(Material:)
  pack $w.mp.material.title -side top -pady 3
  
  foreach piece {q r b n m p} {
    frame $w.mp.material.$piece
    pack $w.mp.material.$piece -side top ;# -padx 2
  }
  
  foreach i {q r b n m p} {
    set f $w.mp.material.$i
    button $f.w0 -text "0" -command "set pMin(w$i) 0; set pMax(w$i) 0"
    button $f.w1 -text "1" -command "set pMin(w$i) 1; set pMax(w$i) 1"
    button $f.w2 -text "2" -command "set pMin(w$i) 2; set pMax(w$i) 2"
    button $f.wa -text "0+" -command "set pMin(w$i) 0; set pMax(w$i) 2"
    button $f.w1p -text "1+" -command "set pMin(w$i) 1; set pMax(w$i) 2"
    label $f.wi -image w${i}20 -font font_Small
    label $f.wto -text "-" -font font_Small -padx 0
    entry $f.wmin -width 2 -relief sunken -textvar pMin(w$i) -font font_Small \
        -justify right
    entry $f.wmax -width 2 -relief sunken -textvar pMax(w$i) -font font_Small \
        -justify right
    pack $f.w0 $f.w1 $f.w2 $f.wa $f.w1p $f.wi $f.wmin $f.wto $f.wmax -side left -pady 1
    
    pack [frame $f.space -width 20] -side left
    button $f.b0 -text "0" -command "set pMin(b$i) 0; set pMax(b$i) 0"
    button $f.b1 -text "1" -command "set pMin(b$i) 1; set pMax(b$i) 1"
    button $f.b2 -text "2" -command "set pMin(b$i) 2; set pMax(b$i) 2"
    button $f.ba -text "0+" -command "set pMin(b$i) 0; set pMax(b$i) 2"
    button $f.b1p -text "1+" -command "set pMin(b$i) 1; set pMax(b$i) 2"
    label $f.bi -image b${i}20 -font font_Small
    label $f.bto -text "-" -font font_Small
    entry $f.bmin -width 2 -relief sunken -textvar pMin(b$i) -font font_Small \
        -justify right
    entry $f.bmax -width 2 -relief sunken -textvar pMax(b$i) -font font_Small \
        -justify right
    pack $f.b0 $f.b1 $f.b2 $f.ba $f.b1p $f.bi $f.bmin $f.bto $f.bmax -side left -pady 1
    
    foreach b {0 1 2 a 1p} {
      $f.w$b configure -width 2 -pady 0 -padx 1 -takefocus 0 -font $small
      $f.b$b configure -width 2 -pady 0 -padx 1 -takefocus 0 -font $small
    }
    foreach widget {wmin wmax bmin bmax} {
      bindFocusColors $f.$widget
    }
    if {$i == "p"} {
      $f.w1p configure -command "set pMin(wp) 1; set pMax(wp) 8"
      $f.wa configure -command "set pMin(wp) 0; set pMax(wp) 8"
      $f.b1p configure -command "set pMin(bp) 1; set pMax(bp) 8"
      $f.ba configure -command "set pMin(bp) 0; set pMax(bp) 8"
    }
    if {$i == "m"} {
      $f.w1p configure -command "set pMin(wm) 1; set pMax(wm) 4"
      $f.wa configure -command "set pMin(wm) 0; set pMax(wm) 4"
      $f.b1p configure -command "set pMin(bm) 1; set pMax(bm) 4"
      $f.ba configure -command "set pMin(bm) 0; set pMax(bm) 4"
    }
  }
  
  # Buttons that manipulate material settings:
  set f $w.mp.material.b1
  pack [frame $f] -side top -ipady 2
  
  dialogbutton $f.zero -textvar ::tr(Zero) -font $small -command ::search::material::zero
  dialogbutton $f.reset -textvar ::tr(Any) -font $small -command ::search::material::any
  dialogbutton $f.current -textvar ::tr(CurrentBoard) -font $small -command {
    ::search::material::zero
    set bd [sc_pos board]
    for {set i 0} {$i < 64} {incr i} {
      set piece $::board::letterToPiece([ string index $bd $i ])
      if {$piece != "e"  &&  $piece != "wk"  &&  $piece != "bk"} {
        incr pMin($piece); set pMax($piece) $pMin($piece)
      }
    }
  }
  
  menubutton $f.common -textvar ::tr(CommonEndings...) \
      -menu $f.common.m -relief raised -font $small
  menu $f.common.m -font $small
  set m $f.common.m
  $m add command -label [tr EndingPawns] -command {
    ::search::material::zero
    array set pMin {wp 1 bp 1}
    array set pMax {wp 8 bp 8}
  }
  $m add command -label [tr EndingRookVsPawns] -command {
    ::search::material::zero
    array set pMin {wr 1 bp 1}
    array set pMax {wr 1 bp 8}
  }
  $m add command -label [tr EndingRookPawnVsRook] -command {
    ::search::material::zero
    array set pMin {wr 1 br 1 wp 1}
    array set pMax {wr 1 br 1 wp 1}
  }
  $m add command -label [tr EndingRookPawnsVsRook] -command {
    ::search::material::zero
    array set pMin {wr 1 br 1 wp 1}
    array set pMax {wr 1 br 1 wp 8}
  }
  $m add command -label [tr EndingRooks] -command {
    ::search::material::zero
    array set pMin {wr 1 br 1}
    array set pMax {wr 1 br 1 wp 8 bp 8}
    set pMin(wr) 1; set pMax(wr) 1; set pMin(wp) 0; set mPax(wp) 8
    set pMin(br) 1; set pMax(br) 1; set pMin(bp) 0; set mPax(bp) 8
  }
  $m add command -label [tr EndingRooksPassedA] -command {
    ::search::material::zero
    array set pMin {wr 1 br 1 wp 1}
    array set pMax {wr 1 br 1 wp 8 bp 8}
    setPatterns {{wp a ? Yes} {bp a ? No} {bp b ? No}}
    set ignoreColors 1
  }
  $m add command -label [tr EndingRooksDouble] -command {
    ::search::material::zero
    array set pMin {wr 2 br 2}
    array set pMax {wr 2 br 2 wp 8 bp 8}
  }
  $m add command -label [tr EndingBishops] -command {
    ::search::material::zero
    array set pMin {wb 1 bb 1 wm 1 bm 1}
    array set pMax {wb 1 bb 1 wm 1 bm 1 wp 8 bp 8}
  }
  $m add command -label [tr EndingBishopVsKnight] -command {
    ::search::material::zero
    array set pMin {wb 1 bn 1 wm 1 bm 1}
    array set pMax {wb 1 bn 1 wm 1 bm 1 wp 8 bp 8}
  }
  $m add command -label [tr EndingKnights] -command {
    ::search::material::zero
    array set pMin {wn 1 bn 1 wm 1 bm 1}
    array set pMax {wn 1 bn 1 wm 1 bm 1 wp 8 bp 8}
  }
  $m add command -label [tr EndingQueens] -command {
    ::search::material::zero
    array set pMin {wq 1 bq 1}
    array set pMax {wq 1 bq 1 wp 8 bp 8}
  }
  $m add command -label [tr EndingQueenPawnVsQueen] -command {
    ::search::material::zero
    array set pMin {wq 1 bq 1 wp 1}
    array set pMax {wq 1 bq 1 wp 1}
  }
  $m add command -label [tr BishopPairVsKnightPair] -command {
    ::search::material::zero
    array set pMin {wb 2 bn 2 wm 2 bm 2}
    array set pMax {wq 1 bq 1 wr 2 br 2 wb 2 bn 2 wm 2 bm 2 wp 8 bp 8}
  }
  
  pack $f.zero $f.reset $f.current $f.common -side left -pady 5 -padx 10
  #if {! $smDisplayed(Material)} {
  #  pack forget .sm.q .sm.r .sm.b .sm.n .sm.m .sm.p .sm.b1 .sm.mdiff
  #}
  
  set f $w.mp.material.mdiff
  pack [frame $f] -side top
  label $f.label -font font_SmallBold -textvar ::tr(MaterialDiff:)
  entry $f.min -width 3 -relief sunken -textvar minMatDiff -font $small \
      -justify right
  bindFocusColors $f.min
  label $f.sep -text "-" -font $small
  entry $f.max -width 3 -relief sunken -textvar maxMatDiff -font $small \
      -justify right
  bindFocusColors $f.max
  label $f.sep2 -text " " -font $small
  button $f.any -textvar ::tr(Any) -font $small -padx 1 -pady 1 \
      -command {set minMatDiff -40; set maxMatDiff +40}
  button $f.w1 -text " + " -font $small -padx 1 -pady 1 \
      -command {set minMatDiff +1; set maxMatDiff +40}
  button $f.equal -text " = " -font $small -padx 1 -pady 1 \
      -command {set minMatDiff 0; set maxMatDiff 0}
  button $f.b1 -text " - " -font $small -padx 1 -pady 1 \
      -command {set minMatDiff -40; set maxMatDiff -1}
  pack $f.label $f.min $f.sep $f.max -side left
  pack $f.sep2 $f.any $f.w1 $f.equal $f.b1 -side left
  set f [frame $w.mp.material.mdiff2]
  pack $f -side top
  label $f.explan -font $small \
      -text "($::tr(MaterialDiff) = $::tr(White) - $::tr(Black); Q=9 R=5 B=3 N=3 P=1)"
  pack $f.explan -side top
  
  addVerticalRule $w.mp
  
  set f [frame $w.mp.patt]
  pack $f -side top
  
  #dialogbutton $w.pattl -font font_Bold -textvar ::tr(Patterns:) -command {
  #  if {$smDisplayed(Patterns)} {
  #    set smDisplayed(Patterns) 0
  #    pack forget .sm.patt .sm.b2
  #  } else {
  #    set smDisplayed(Patterns) 1
  #    pack .sm.patt .sm.b2 -after .sm.pattl
  #  }
  #}
  label $w.mp.patt.title -textvar ::tr(Patterns:) -font font_Bold
  pack $w.mp.patt.title -side top -pady 3
  
  pack [frame $f.grid] -side top
  for { set i 1 } { $i <= $nPatterns } { incr i } {
    makeBoolMenu $f.grid.b$i pattBool($i)
    set menuPiece1 [ makePieceMenu $f.grid.p$i pattPiece($i) ]
    tk_optionMenu $f.grid.f$i pattFyle($i) "?" a b c d e f g h
    tk_optionMenu $f.grid.r$i pattRank($i) "?" 1 2 3 4 5 6 7 8
    $f.grid.b$i configure -indicatoron 0 ;# -width 4
    $f.grid.f$i configure -indicatoron 0 -width 1 -pady 1
    $f.grid.r$i configure -indicatoron 0 -width 1 -pady 1
    set column [expr {5 * (($i - 1) / 5)} ]
    set row [expr {($i - 1) % 5} ]
    grid $f.grid.b$i -row $row -column $column -padx 0; incr column
    grid $f.grid.p$i -row $row -column $column -padx 0; incr column
    grid $f.grid.f$i -row $row -column $column -padx 0; incr column
    grid $f.grid.r$i -row $row -column $column -padx 0; incr column
    if {$column == 4  ||  $column == 9} {
      label $f.grid.sp_$i -text "  "
      grid $f.grid.sp_$i -row $row -column $column
    }
  }
  
  updatePatternImages
  
  ### Buttons that manipulate patterns:
  set f .sm.mp.patt.b2
  frame $f
  dialogbutton $f.clearPat -textvar ::tr(Clear) -command clearPatterns
  menubutton $f.common -textvar ::tr(CommonPatterns...) \
      -menu $f.common.m -relief raised -font $small
  menu $f.common.m -font $small
  $f.common.m add command -label [tr PatternWhiteIQP] -command {
    if {$pMin(wp) < 1} { set pMin(wp) 1 }
    setPatterns {{wp d ? Yes} {wp c ? No} {wp e ? No}}
  }
  $f.common.m add command -label [tr PatternWhiteIQPBreakE6] -command {
    if {$pMin(wp) < 1} { set pMin(wp) 1 }
    if {$pMin(bp) < 1} { set pMin(bp) 1 }
    setPatterns {{wp d 5 Yes} {wp c ? No} {wp e ? No} {wp d 4 No} \
          {bp e 6 Yes} {bp c ? No} {bp d ? No}}
  }
  $f.common.m add command -label [tr PatternWhiteIQPBreakC6] -command {
    if {$pMin(wp) < 1} { set pMin(wp) 1 }
    if {$pMin(bp) < 1} { set pMin(bp) 1 }
    setPatterns {{wp d 5 Yes} {wp c ? No} {wp e ? No} {wp d 4 No} \
          {bp c 6 Yes} {bp e ? No} {bp d ? No}}
  }
  $f.common.m add command -label [tr PatternBlackIQP] -command {
    if {$pMin(bp) < 1} { set pMin(bp) 1 }
    setPatterns {{bp d ? Yes} {bp c ? No} {bp e ? No}}
  }
  $f.common.m add command -label [tr PatternWhiteBlackIQP] -command {
    if {$pMin(wp) < 1} { set pMin(wp) 1 }
    if {$pMin(bp) < 1} { set pMin(bp) 1 }
    setPatterns {{wp d ? Yes} {wp c ? No} {wp e ? No} \
          {bp d ? Yes} {bp c ? No} {bp e ? No}}
  }
  $f.common.m add command -label [tr PatternCoupleC3D4] -command {
    set pMin(wp) 4; set pMax(wp) 6
    set pMin(bp) 4; set pMax(bp) 6
    setPatterns {{wp c 3 Yes} {wp d 4 Yes} {wp b ? No} {wp e ? No}
      {bp c ? No} {bp d ? No}}
  }
  $f.common.m add command -label [tr PatternHangingC5D5] -command {
    set pMin(bp) 4; set pMax(bp) 6
    set pMin(wp) 4; set pMax(wp) 6
    setPatterns {{bp c 5 Yes} {bp d 5 Yes} {bp b ? No} {bp e ? No}
      {wp c ? No} {wp d ? No}}
  }
  $f.common.m add command -label [tr PatternMaroczy] -command {
    if {$pMin(bp) < 1} { set pMin(bp) 1 }
    if {$pMax(bp) > 7} { set pMax(bp) 7 }
    if {$pMin(wp) < 2} { set pMin(wp) 2 }
    if {$pMax(wp) > 7} { set pMax(wp) 7 }
    setPatterns {{wp c 4 Yes} {wp e 4 Yes} {bp d ? Yes} {wp d ? No}
      {bp c ? No} {bp d 5 No}}
  }
  $f.common.m add command -label [tr PatternRookSacC3] -command {
    set pMin(br) 2; set pMax(br) 2
    set pMin(wr) 2; set pMax(wr) 2
    setPatterns { {br c 3 Yes} {wp b 2 Yes} }
  }
  $f.common.m add command -label [tr PatternKc1Kg8] -command {
    setPatterns { {wk c 1 Yes} {bk g 8 Yes} }
  }
  $f.common.m add command -label [tr PatternKg1Kc8] -command {
    setPatterns { {wk g 1 Yes} {bk c 8 Yes} }
  }
  $f.common.m add command -label [tr PatternLightFian] -command {
    set pMin(wb) 1; set pMin(bb) 1
    setPatterns { {wb g 2 Yes} {bb b 7 Yes} }
  }
  $f.common.m add command -label [tr PatternDarkFian] -command {
    set pMin(wb) 1; set pMin(bb) 1
    setPatterns { {wb b 2 Yes} {bb g 7 Yes} }
  }
  $f.common.m add command -label [tr PatternFourFian] -command {
    set pMin(wb) 2; set pMin(bb) 2
    setPatterns { {wb b 2 Yes} {wb g 2 Yes} {bb b 7 Yes} {bb g 7 Yes} }
  }
  
  pack $f -side top
  pack $f.clearPat $f.common -side left -pady 5 -padx 10
  #if {! $smDisplayed(Patterns)} {
  #  pack forget $w.patt $w.b2
  #}
  updatePatternImages
  
  addHorizontalRule $w
  
  ### Now the move counter:
  
  set f $w.bishops
  pack [frame $f] -side top
  label $f.t1 -text "1" -font font_Small
  label $f.t2 -image wb20
  label $f.t3 -text "- 1" -font font_Small
  label $f.t4 -image bb20
  label $f.t5 -textvar ::tr(squares:) -font font_Small
  radiobutton $f.same -textvar ::tr(SameColor) -variable oppBishops \
      -value "Same" -padx 5 -pady 4 -font font_Small
  radiobutton $f.opp -textvar ::tr(OppColor) -variable oppBishops \
      -value "Opposite" -padx 5 -pady 4 -font font_Small
  radiobutton $f.either -textvar ::tr(Either) -variable oppBishops \
      -value "Either" -padx 5 -pady 4 -font font_Small
  foreach i {t1 t2 t3 t4 t5 same opp either} { pack $f.$i -side left }
  
  set f $w.move
  pack [frame $f] -side top -ipady 5
  label $f.fromlab -textvar ::tr(MoveNumberRange:)
  entry $f.from -width 4 -relief sunken -textvar minMoveNum -justify right
  label $f.tolab -text "-"
  entry $f.to -width 4 -relief sunken -textvar maxMoveNum -justify right
  label $f.space -text "  "
  label $f.label1 -textvar ::tr(MatchForAtLeast)
  entry $f.hmoves -width 3 -relief sunken -textvar minHalfMoves -justify right
  label $f.label2 -textvar ::tr(HalfMoves)
  bindFocusColors $f.from
  bindFocusColors $f.to
  bindFocusColors $f.hmoves
  pack $f.fromlab $f.from $f.tolab $f.to $f.space \
      $f.label1 $f.hmoves $f.label2 -side left
  
  addHorizontalRule $w
  ::search::addFilterOpFrame $w 1
  addHorizontalRule $w
  
  ### Progress bar:
  
  canvas $w.progress -height 20 -width 300 -bg white -relief solid -border 1
  $w.progress create rectangle 0 0 0 0 -outline blue -fill blue -tags bar
  $w.progress create text 295 10 -anchor e -font font_Regular -tags time \
      -fill black -text "0:00 / 0:00"
  
  ### Last of all, the buttons frame:
  
  set f $w.b3
  pack [frame $f] -side top -ipady 5 -fill x
  checkbutton $f.ignorecol -textvar ::tr(IgnoreColors) \
      -variable ignoreColors -padx 4
  
  dialogbutton $f.save -textvar ::tr(Save...) -padx 10 -command ::search::material::save
  
  dialogbutton $f.stop -textvar ::tr(Stop) -command sc_progressBar
  $f.stop configure -state disabled
  
  dialogbutton $f.search -textvar ::tr(Search) -command {
    busyCursor .
    .sm.b3.stop configure -state normal
    grab .sm.b3.stop
    sc_progressBar .sm.progress bar 301 21 time
    set str [sc_search material \
        -wq [list $pMin(wq) $pMax(wq)] -bq [list $pMin(bq) $pMax(bq)] \
        -wr [list $pMin(wr) $pMax(wr)] -br [list $pMin(br) $pMax(br)] \
        -wb [list $pMin(wb) $pMax(wb)] -bb [list $pMin(bb) $pMax(bb)] \
        -wn [list $pMin(wn) $pMax(wn)] -bn [list $pMin(bn) $pMax(bn)] \
        -wm [list $pMin(wm) $pMax(wm)] -bm [list $pMin(bm) $pMax(bm)] \
        -wp [list $pMin(wp) $pMax(wp)] -bp [list $pMin(bp) $pMax(bp)] \
        -flip $ignoreColors -filter $::search::filter::operation \
        -range [list $minMoveNum $maxMoveNum] \
        -length $minHalfMoves -bishops $oppBishops \
        -diff [list $minMatDiff $maxMatDiff] \
        -patt "$pattBool(1) $pattPiece(1) $pattFyle(1) $pattRank(1)" \
        -patt "$pattBool(2) $pattPiece(2) $pattFyle(2) $pattRank(2)" \
        -patt "$pattBool(3) $pattPiece(3) $pattFyle(3) $pattRank(3)" \
        -patt "$pattBool(4) $pattPiece(4) $pattFyle(4) $pattRank(4)" \
        -patt "$pattBool(5) $pattPiece(5) $pattFyle(5) $pattRank(5)" \
        -patt "$pattBool(6) $pattPiece(6) $pattFyle(6) $pattRank(6)" \
        -patt "$pattBool(7) $pattPiece(7) $pattFyle(7) $pattRank(7)" \
        -patt "$pattBool(8) $pattPiece(8) $pattFyle(8) $pattRank(8)" \
        -patt "$pattBool(9) $pattPiece(9) $pattFyle(9) $pattRank(9)" \
        -patt "$pattBool(10) $pattPiece(10) $pattFyle(10) $pattRank(10)" ]
    grab release .sm.b3.stop
    .sm.b3.stop configure -state disabled
    unbusyCursor .
    #tk_messageBox -type ok -title $::tr(SearchResults) -message $str
    .sm.status configure -text $str
    set glstart 1
    ::windows::gamelist::Refresh
    
    ::search::loadFirstGame
    
    ::windows::stats::Refresh
  }
  
  dialogbutton $f.cancel -textvar ::tr(Close) \
      -command { focus .; destroy .sm }
  
  pack $f.ignorecol $w.b3.save -side left -pady 5 -padx 5
  pack $w.b3.cancel $w.b3.search $w.b3.stop -side right -pady 5 -padx 5
  pack $w.progress -side top -pady 2
  
  label $w.status -text "" -width 1 -font font_Small -relief sunken -anchor w
  pack $w.status -side bottom -fill x
  
  # update
  wm resizable $w 0 0
  standardShortcuts $w
  ::search::Config
  focus $f.search
}

proc ::search::material::save {} {
  global pMin pMax ignoreColors minMoveNum maxMoveNum minHalfMoves
  global pattPiece pattFyle pattRank pattBool oppBishops nPatterns
  
  set ftype { { "Scid SearchOptions files" {".sso"} } }
  set fName [tk_getSaveFile -initialdir [pwd] -filetypes $ftype -title "Create a SearchOptions file"]
  if {$fName == ""} { return }
  
  if {[string compare [file extension $fName] ".sso"] != 0} {
    append fName ".sso"
  }
  
  if {[catch {set searchF [open $fName w]}]} {
    tk_messageBox -title "Error: Unable to open file" -type ok -icon error \
        -message "Unable to create SearchOptions file: $fName"
    return
  }
  puts $searchF "\# SearchOptions File created by Scid [sc_info version]"
  puts $searchF "set searchType Material"
  # First write the material counts:
  foreach i {wq bq wr br wb bb wn bn wp bp} {
    puts $searchF "set pMin($i) $pMin($i)"
    puts $searchF "set pMax($i) $pMax($i)"
  }
  # Now write other numeric values:
  foreach i {
    ignoreColors minMoveNum maxMoveNum minHalfMoves oppBishops
    ::search::filter::operation
  } {
    puts $searchF "set $i [set $i]"
  }
  # Last, write the patterns:
  for {set i 1} {$i <= $nPatterns} {incr i} {
    puts $searchF "set pattPiece($i) $pattPiece($i)"
    puts $searchF "set pattFyle($i) $pattFyle($i)"
    puts $searchF "set pattRank($i) $pattRank($i)"
    puts $searchF "set pattBool($i) $pattBool($i)"
  }
  tk_messageBox -type ok -icon info -title "Search Options saved" \
      -message "Material/pattern search options saved to: $fName"
  close $searchF
}

