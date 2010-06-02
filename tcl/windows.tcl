###
### windows.tcl: part of Scid.
### Copyright (C) 1999-2003  Shane Hudson.
###


namespace eval ::windows {

    # TODO
}

########################################################################
###  Optional windows: all off initially.

set treeWin 0
set pgnWin 0
set commentWin 0
set filterGraph 0

set nagValue 0

# recordWinSize:
#   Records window width and height, for saving in options file.
#
#   winX and winY are now offsets to main window, instead of absolute screen x,y
#   except for the main window itself   S.A

proc recordWinSize {win} {

  # This procedure gets called way too often S.A.
  # It shouldnt really be bound to <Configure> , but only called on exit.

  global winWidth winHeight winX winY

  if {![winfo exists $win]} { return }
  set geom [wm geometry $win]
  set maingeom [wm geometry .]

  set n [scan $geom "%dx%d+%d+%d" width height x y]
  scan $maingeom "%dx%d+%d+%d" mainwidth mainheight mainx mainy
  if {$n == 4} {
    if {$win == "."} {
      # trick to handle main window
      set mainx 0
      set mainy 0
    }
    set winWidth($win) $width
    set winHeight($win) $height
    set winX($win) [expr $x - $mainx]
    set winY($win) [expr $y - $mainy]
# puts "$win savegeom x $x y $y mainx $mainx mainy $mainy"
# puts "$win savegeom winWidth $winWidth($win) winHeight $winHeight($win)"
  }
}

proc setWinLocation {win} {
  global winX winY

  if {[info exists winX($win)]  &&  [info exists winY($win)] } {

    set maingeom [wm geometry .]
    scan $maingeom "%dx%d+%d+%d" mainwidth mainheight mainx mainy

    if {$win == "."} {
      # trick to handle main window
      set mainx 0
      set mainy 0
    }

    set x [expr $mainx + $winX($win)]
    set y [expr $mainy + $winY($win)]
    if { $x < 0 } { set x 0 }
    if { $y < 0 } { set x 0 }
    if { $x > [winfo screenwidth .] } { set x [winfo screenwidth .] }
    if { $y > [winfo screenwidth .] } { set x [winfo screenwidth .] }

    catch [list wm geometry $win "+$x+$y"]
  }
}

proc setWinSize {win} {
  global winWidth winHeight
  if {[info exists winWidth($win)]  &&  [info exists winHeight($win)]  &&  \
    $winWidth($win) > 0  &&  $winHeight($win) > 0} {
    catch [list wm geometry $win "$winWidth($win)x$winHeight($win)"]
# puts "$win setgeom winWidth $winWidth($win) winHeight $winHeight($win)"
  }
}

# These procs only work ~properly~ if window is updated first
# (preferably in a withdrawn state) S.A

proc placeWinOverParent {w parent} {

  set reqwidth [winfo reqwidth $w]
  set reqheight [winfo reqheight $w]

  if {[scan [winfo geometry $parent] "%dx%d+%d+%d" width height x y] == 4} {
    wm geometry $w "+[expr $x+($width-$reqwidth)/2]+[expr $y+($height-$reqheight)/3]"
  } else {
    puts {placeWinOverParent: scan != 4}
  }

  # wm minsize $w $reqwidth $reqheight; # optional ?
  # wm state $w normal
  # update
}

proc placeWinOverPointer {w} {
  set x [winfo pointerx .]
  set y [winfo pointery .]
  set width [winfo reqwidth $w]
  set height [winfo reqheight $w]
  if {$x>0 && $y>0 } {
    wm geometry $w +[expr $x - $width/2]+[expr $y - $height/2]
  }
}

###
### End of file: windows.tcl
###
