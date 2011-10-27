###
### search/board.tcl: Board Search routines for Scid.
###

set searchInVars 0
set sBoardIgnoreCols 0
set sBoardSearchType Exact

# ::search::board
#   Opens the search window for the current board position.
#
proc ::search::board {} {
  global glstart searchInVars sBoardType sBoardIgnoreCols

  set w .sb
  if {[winfo exists $w]} {
    wm deiconify $w
    raiseWin $w
    return
  }

  toplevel $w
  wm withdraw $w
  wm title $w "Scid: $::tr(BoardSearch)"

  bind $w <Escape> "$w.b.cancel invoke"
  bind $w <Return> "$w.b.search invoke"
  bind $w <F1> { helpWindow Searches Board }

  label $w.type -textvar ::tr(SearchType) -font font_Bold
  pack $w.type -side top
  pack [frame $w.g] -side top -fill x
  radiobutton $w.g.exact -textvar ::tr(SearchBoardExact) \
      -variable sBoardSearchType -value Exact
  radiobutton $w.g.pawns -textvar ::tr(SearchBoardPawns) \
      -variable sBoardSearchType -value Pawns
  radiobutton $w.g.files -textvar ::tr(SearchBoardFiles) \
      -variable sBoardSearchType -value Fyles
  radiobutton $w.g.material -textvar ::tr(SearchBoardAny) \
      -variable sBoardSearchType -value Material
  set row 0
  foreach i {exact pawns files material} {
    grid $w.g.$i -row $row -column 0 -sticky w
    incr row
  }
  addHorizontalRule $w

  pack [frame $w.refdb] -side top -fill x
  checkbutton $w.refdb.cb -textvar ::tr(SearchInRefDatabase) -variable ::searchRefBase \
               -command "checkState ::searchRefBase $w.refdb.lb"

  set ::listbases {}

  # populate the combobox
  for {set i 1} {$i <= [sc_base count total]} {incr i} {
    if {[sc_base inUse $i]} {
      set fname [file tail [sc_base filename $i]]
      lappend ::listbases $fname
    }
  }
  ttk::combobox $w.refdb.lb -textvariable refDatabase -values $::listbases
  $w.refdb.lb current 0

  checkState ::searchRefBase $w.refdb.lb
  
  pack $w.refdb.cb -side left
  pack $w.refdb.lb -side left -padx 20
  addHorizontalRule $w

  ::search::addFilterOpFrame $w
  addHorizontalRule $w

  ### Progress bar

  canvas $w.progress -height 20 -width 300  -relief solid -border 1
  $w.progress create rectangle 0 0 0 0 -fill $::progcolor -outline $::progcolor -tags bar
  $w.progress create text 295 10 -anchor e -font font_Regular -tags time \
      -fill black -text "0:00 / 0:00"

  frame $w.b2
  pack $w.b2 -side top
  frame $w.b
  checkbutton $w.b2.vars -textvar ::tr(LookInVars) -padx 10 -pady 5 \
      -onvalue 1 -offvalue 0 -variable searchInVars
  checkbutton $w.b2.flip -textvar ::tr(IgnoreColors) -padx 10 -pady 5 \
      -onvalue 1 -offvalue 0 -variable sBoardIgnoreCols

  dialogbutton $w.b.stop -textvar ::tr(Stop) -command sc_progressBar
  $w.b.stop configure -state disabled

  dialogbutton $w.b.search -textvar ::tr(Search) -command {
    busyCursor .
    .sb.b.stop configure -state normal
    grab .sb.b.stop
    sc_progressBar .sb.progress bar 301 21 time

    if { $::searchRefBase } {
      ### Search a particular base rather than the one that is open

      # Find the base number by searching the basenames for a match with combobox variable refDatabase
      set found 0
      set base  9 ; # this line not really needed
      for {set i 1} {$i <= [sc_base count total]} {incr i} {
	if {[sc_base inUse $i]} {
	  set fname [file tail [sc_base filename $i]]
	  if {$fname == $refDatabase} {
	    set base $i
	    set found 1
	    break
	  }
	}
      }

      if {$found} {
	set str [sc_search board $::search::filter::operation $sBoardSearchType $searchInVars $sBoardIgnoreCols $base]
      } else {
	set str {Database not open}
      }
    } else {
      set str [sc_search board $::search::filter::operation $sBoardSearchType $searchInVars $sBoardIgnoreCols ]
    }

    unbusyCursor .
    grab release .sb.b.stop
    .sb.b.stop configure -state disabled
    .sb.status configure -text $str
    set glstart 1
    ::windows::gamelist::Refresh

    set gamesFound [lindex $str 0]
    if { $::searchRefBase && $gamesFound > 0 && $gamesFound != {Database}} {
      ::file::SwitchToBase $base
      ::search::loadFirstGame
    }
    ::windows::stats::Refresh
  }

  dialogbutton $w.b.cancel -textvar ::tr(Close) -command "focus .; destroy $w"
  pack $w.b2.vars $w.b2.flip -side left -pady 2 -padx 5
  packbuttons right $w.b.cancel .sb.b.stop .sb.b.search
  label $w.status -text "" -width 1 -font font_Small -relief sunken -anchor w
  pack $w.status -side bottom -fill x
  pack $w.b -side bottom -fill x
  pack $w.progress -side bottom -pady 2
  wm resizable $w 0 0
  standardShortcuts $w
  ::search::Config

  placeWinOverParent $w .
  wm state $w normal
  focus $w.b.search
}
