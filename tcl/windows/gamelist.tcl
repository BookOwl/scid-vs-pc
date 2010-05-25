
########################################################################
### Games list window

# 27/06/2009
# Rewritten to use the ttk::treeview widget (man ttk_treeview) by Steven Atkinson

# 24/05/2010
# To make this widget work _fast_ with huge databases isnt impossible
# We have to make use of Scid's in built DB sorting instead of using text
# sorting.

set ::windows::gamelist::isOpen 0
set glstart 1
set ::windows::gamelist::findtext {}
set ::windows::gamelist::goto {}

### This trace messes up some other widgets i think S.A.
# trace variable ::windows::gamelist::goto w {::utils::validate::Regexp {^[0-9]*$}}

### Still have to sort this out properly S.A. &&&

# set glistFields {
#   { g  7 right black      1 }
#   { w 14 left  darkBlue   0 }
#   { W  5 right darkGreen  1 }
#   { b 14 left  darkBlue   0 }
#   { B  5 right darkGreen  1 }
#   { e 10 left  black      0 }
#   { s 10 left  black      0 }
#   { n  2 right black      1 }
#   { d  7 left  darkRed    1 }
#   { r  3 left  blue       0 }
#   { m  3 right black      1 }
#   { o  5 left  darkGreen  0 }
#   { O  6 left  darkGreen  1 }
#   { D  1 left  darkRed    0 }
#   { U  2 left  blue       1 }
#   { V  2 right blue       0 }
#   { C  2 right blue       0 }
#   { A  2 right blue       0 }
#   { S  1 left  darkRed    0 }
# }

# b:  Black player name.
# B:  Black Elo. Prints in width of 4, ignoring specified width.
# e:  Event name.
# f:  Game number, filtered (e.g. 1 = first game in filter).
# g:  Game number, actual (ignoring filter).
# m:  Number of moves. Prints "##" if width < 3 and numMoves > 99.
# M:  Final position material, e.g. "r1:r" for Rook+Pawn vs Rook.
# n:  Round name.
# o:  ECO code.
# r:  Result. Prints as 1 byte (1/0/=*) or as 3 bytes (1-0, etc).
# s:  Site name.
# S:  Start position flag. Prints "S" or " " (1 byte) ignoring width.
# w:  White player name.
# W:  White Elo. Prints in width of 4, ignoring specified width.
# y:  Year. Prints in width of 4, ignoring specified width.

# I think these fields can be reordered on whim S.A.

set glistFields {
  g Number	e
  w White	w
  W WElo	e
  b Black	w
  B BElo	e
  r Result	e
  m Length	e
  e Event	w
  s Site	w
  n Round	e
  d Date	w
  o ECO		e
  O Opening	w
  D Deleted	e
  U Flags	e
  V Vars	e
  C Comments	w
  A Annos	e
  S Start	e
}

set glistCodes {} 
set glistNames {}

foreach {code title anchor} $glistFields {
  # Unusual glistCodes format is needed for [sc_game list ...]
  # SCID uses - append cformat "*\n" - but appending a space works too

  lappend glistCodes "$code* "
  lappend glistNames $title
}

### not sure about these missing fileds at all &&&

# set glistNames { Number White WElo Black BElo Event Site Round Date Result Length ECO Opening Deleted Flags Vars Comments Annos Start }
# Number Filtered White WElo Black BElo Event Site Round Date Year EDate Result Length Country ECO Opening EndMaterial Deleted Flags Vars Comments Annos Start
#  Number White WElo Black BElo Event Site Round Date Result Length ECO Opening Deleted Flags Vars Comments Annos Start

proc ::windows::gamelist::FilterText {} {

  global glstart glistCodes
  variable findtext

  ::utils::history::AddEntry ::windows::gamelist::findtext $findtext
  .glistWin.b.find selection range end end

  busyCursor .glistWin 1
  update

 for {set line [sc_filter count]} {$line >= 1} {incr line -1} {
    if {![regexp $::windows::gamelist::findcase $findtext [string map {\{ \  \} \ } [sc_game list $line 1 $glistCodes]]]} {
      sc_filter remove $line
    }
  }
  ::windows::gamelist::SetSize
  set glstart 1
  ::windows::gamelist::Refresh
  unbusyCursor .glistWin
  update
}

proc ::windows::gamelist::FindText {} {
  global glstart glistCodes
  variable findtext

  busyCursor .glistWin 1
  update
  ::utils::history::AddEntry ::windows::gamelist::findtext $findtext
  .glistWin.b.find selection range end end

  # set temp [sc_filter $::windows::gamelist::findcase $glstart $findtext]

  set line $glstart 
  incr line
  set totalSize [sc_filter count]
  while {$line <= $totalSize} {
    if {[regexp $::windows::gamelist::findcase $findtext \
           [string map {\{ \  \} \ } [sc_game list $line 1 $glistCodes]]]} {
      break
    }
    incr line 1
  }

  if {$line > $totalSize} {
    set glstart 1
    ::windows::gamelist::Refresh
    bell
  } else {
    set glstart $line
    ::windows::gamelist::SetSize
    ::windows::gamelist::Refresh
    .glistWin.tree selection set [lindex [.glistWin.tree children {}] 0]
  }
  unbusyCursor .glistWin
  update
}

proc ::windows::gamelist::Load {number} {
  # for some reason, number has a trailing "\n"

  set number [string trim $number "\n"]
  set ::windows::gamelist::goto $number
  ::game::Load $number
}

# bug: this will still succeed even if current game has been filtered
proc ::windows::gamelist::showCurrent {} {

  global glistCodes

  set index [sc_game number]
puts "!!$index"
  set ::windows::gamelist::goto $index
  ::windows::gamelist::showNum $index
}

# bug: this will still succeed even if numbered game has been filtered
proc ::windows::gamelist::showNum {index} {

  global glstart
 
  set result [sc_filter locate $::windows::gamelist::goto]
  if {$result < 1 || $result > [sc_filter count]} {
    bell
  } else {
    set glstart $result
    ::windows::gamelist::Refresh
    .glistWin.tree selection set [lindex [.glistWin.tree children {}] 0]
  }

  return
}

proc recordWidths {} {
  global glistNames

  ### get column widths
  set ::windows::gamelist::widths {}
  foreach column $glistNames {
    lappend ::windows::gamelist::widths [.glistWin.tree column $column -width]
  }
}

proc ::windows::gamelist::Close {} {
  set ::windows::gamelist::isOpen 0
  recordWidths
  bind .glistWin <Destroy> {}
}

proc ::windows::gamelist::Open {} {

  package require Ttk

  ### ttk::style theme use alt
  # default classic alt clam

  global highcolor helpMessage
  global glistNames glistFields glistSortedBy
  if {[winfo exists .glistWin]} {
    focus .
    destroy .glistWin
    set ::windows::gamelist::isOpen 0
    return
  }
  set w .glistWin
  toplevel $w
  wm iconname $w "Scid: [tr WindowsGList]"
  setWinLocation $w
  setWinSize $w
  ::windows::gamelist::SetSize

  standardShortcuts $w
  bind $w <F1> { helpWindow GameList }
  bind $w <Destroy> { ::windows::gamelist::Close }
  bind $w <Escape> "destroy $w"

  set ::windows::gamelist::isOpen 1

  ### Frames

  pack [frame $w.c] -side bottom -fill x -ipady 5 -padx 10 
  pack [frame $w.b] -side bottom -fill x -ipady 5 -padx 10

  ttk::frame $w.f
  ttk::treeview $w.tree -columns $glistNames -show headings \
                            -xscroll "$w.hsb set"
    # -yscroll "$w.vsb set" -xscroll "$w.hsb set"


  if { $::windows::gamelist::widths == "" } {
    set ::windows::gamelist::widths {}
    set charwidths { 4      10    5    10    5    10    10   4     8    4      4      4   20      2       2     2    2        2     2 }
    #        names { Number White WElo Black BElo Event Site Round Date Result Length ECO Opening Deleted Flags Vars Comments Annos Start }

    set fontwidth [font measure [ttk::style lookup [$w.tree cget -style] -font] "X"]
    foreach i $charwidths {
	lappend ::windows::gamelist::widths [expr $fontwidth * $i]
    }
  }

  # title font isn't working &&& I don't think it's configurable !
  $w.tree tag configure treetitle -font font_H1
  # this font is working, but doesn't affect how many entries fit on a screen
  $w.tree tag configure treefont -font font_Regular

  $w.tree tag bind click2 <Double-Button-1> {::windows::gamelist::Load [%W set [%W focus] Number]}
  $w.tree tag bind click1 <Button-1> {}

  if {[tk windowingsystem] ne "aqua"} {
      # ttk::scrollbar $w.vsb -orient vertical -command "$w.tree yview"
      ttk::scale     $w.vsb -orient vertical -command ::windows::gamelist::SetStart -from 1 -variable glstart
      ttk::scrollbar $w.hsb -orient horizontal -command "$w.tree xview"
  } else {
      scrollbar $w.vsb -orient vertical -command "$w.tree yview"
      scrollbar $w.hsb -orient horizontal -command "$w.tree xview"
  }

  pack $w.f -fill both -expand 1
  grid $w.tree $w.vsb -in $w.f -sticky nsew
  grid $w.hsb         -in $w.f -sticky nsew
  grid column $w.f 0 -weight 1
  grid row    $w.f 0 -weight 1

  ### Init the ttk_treeview column titles

  set font [ttk::style lookup [$w.tree cget -style] -font]
  foreach {code col anchor} $glistFields width $::windows::gamelist::widths {
      $w.tree heading $col -text  $col   -command "SortBy $w.tree $col"
      $w.tree column  $col -width $width -anchor $anchor -stretch 0
  }

  set glistSortedBy Number

  bind $w <Left>  {}
  bind $w <Right> {}
  bind $w <Up>    {::windows::gamelist::Scroll -1}
  bind $w <Down>  {::windows::gamelist::Scroll  1}
  bind $w <Prior> {::windows::gamelist::Scroll -$glistSize}
  bind $w <Home> {
    set glstart 1
    ::windows::gamelist::Refresh
  }
  bind $w <End> {
    set totalSize [sc_filter count]
    set glstart $totalSize
    set lastEntry [expr $totalSize - $glistSize]
    if {$lastEntry < 1} {
      set lastEntry 1
    }
    if {$glstart > $lastEntry} {
      set glstart $lastEntry
    }
    ::windows::gamelist::Refresh
  }
  bind $w <Next>  {
    incr glstart $glistSize
    set totalSize [sc_filter count]
    set lastEntry [expr $totalSize - $glistSize]
    if {$lastEntry < 1} {
      set lastEntry 1
    }
    if {$glstart > $lastEntry} {
      set glstart $lastEntry
    }
    ::windows::gamelist::Refresh
  }
  # MouseWheel bindings:
  # bind $w <MouseWheel> {::windows::gamelist::Scroll [expr {- (%D / 120)}]}
  if {! $::windowsOS} {
    bind $w <Button-4> {::windows::gamelist::Scroll -1}
    bind $w <Button-5> {::windows::gamelist::Scroll 1}
  }

  set ::windows::gamelist::findtextprev {}
  set ::windows::gamelist::finditems {}

  ### Top row of buttons, etc

  button $w.b.negate -text Negate -relief flat -command {
    .glistWin.tree selection toggle [.glistWin.tree children {}]
  }

  button $w.b.reset -text Reset -relief flat -command ::search::filter::reset

  ### Filter items. (Delete items is different)
  button $w.b.remove -textvar ::tr(GlistDeleteField) -relief flat -command {
    set items [.glistWin.tree selection]
    foreach i $items {
      sc_filter remove [.glistWin.tree set $i Number]
    }
    .glistWin.tree delete $items

    ::windows::stats::Refresh
    ::windows::gamelist::Refresh

    set ::windows::gamelist::finditems {}
    setTitle "[sc_filter count] $::tr(games)"
  }

  frame $w.b.space -width 20

  ### Filter items against the find entry widget
   button $w.b.filter -relief flat -text "Filter" \
    -command {::windows::gamelist::FilterText}

  button $w.b.findlabel -relief flat -textvar ::tr(GlistFindText) \
    -command {::windows::gamelist::FindText}

  # button $w.b.findall -relief flat -text "Find All" \
  #   -command {::windows::gamelist::FindText}

  ### could use ttk::combo box everywhere 
  ::combobox::combobox $w.b.find -width 12 -textvariable ::windows::gamelist::findtext
  ::utils::history::SetCombobox ::windows::gamelist::findtext $w.b.find

  ### doesn't work
  # ::utils::history::SetLimit ::windows::gamelist::findtext 5
  # ::utils::history::PruneList ::windows::gamelist::findtext

  bind $w.b.find <Return> {::windows::gamelist::FindText}
  bind $w.b.find <Home> "$w.b.find icursor 0; break"
  bind $w.b.find <End> "$w.b.find icursor end; break"

  checkbutton $w.b.findcase -text "Ignore Case" \
    -variable ::windows::gamelist::findcase -onvalue {-nocase} -offvalue {--}
  set ::windows::gamelist::findcase {--}

  pack $w.b.findcase $w.b.find $w.b.findlabel $w.b.filter -side right
  pack $w.b.negate $w.b.reset $w.b.remove -side left 

  ### Bottom row of buttons , etc

  button $w.c.current -relief flat -textvar ::tr(Current) \
    -command ::windows::gamelist::showCurrent
  set ::windows::gamelist::goto {}
  entry $w.c.goto -width 8 -justify right -textvariable ::windows::gamelist::goto
  bind $w.c.goto <Return> {
    ::windows::gamelist::showNum $::windows::gamelist::goto
  }

  frame $w.c.space -width 30

  dialogbutton $w.c.browse -text $::tr(Browse) -command {
    set selection [.glistWin.tree selection]
    if { $selection != {} } {
      ::gbrowser::new 0 [.glistWin.tree set [lindex $selection 0] Number]
    }
  }

  dialogbutton $w.c.load -text Load -command {
    set selection [.glistWin.tree selection]
    if { $selection != {} } {
      ::windows::gamelist::Load [.glistWin.tree set [lindex $selection 0] Number]
    }
  }

  dialogbutton $w.c.delete -text {(Un)Delete} -command {
    ::windows::gamelist::ToggleFlag delete
  }

  dialogbutton $w.c.export -textvar ::tr(Save...) -command openExportGList
  dialogbutton $w.c.help  -textvar ::tr(Help) -command { helpWindow GameList }
  dialogbutton $w.c.close -textvar ::tr(Close) -command { focus .; destroy .glistWin }

  pack $w.c.current $w.c.goto -side left -padx 0
  pack $w.c.space $w.c.browse $w.c.load $w.c.delete -side left -padx 3
  pack $w.c.close $w.c.help $w.c.export -side right -padx 3

  ::windows::gamelist::Refresh
  set ::windows::gamelist::goto 1
  focus $w.tree
  bind $w <Configure> {
    recordWidths
    recordWinSize .glistWin
    ::windows::gamelist::SetSize
    ::windows::gamelist::Refresh
  }
}

proc ::windows::gamelist::Scroll {nlines} {
  global glstart

  incr glstart $nlines
  ::windows::gamelist::Refresh
}

proc ::windows::gamelist::SetSize {} {
  global glistSize glFontHeight

  ### Figure out how many lines of text in the treeview widget
  ### This is probably broke on some platforms

  set w .glistWin.tree
  if {![winfo exists $w]} {return}

  if {![info exists glFontHeight]} {

    # treeview configure -rowheight is in cvs
    # set fontup [font metrics [ttk::style lookup [$w cget -style] -font] -ascent]
    # set fontdown [font metrics [ttk::style lookup [$w cget -style] -font] -descent]

    set fontspace [font metrics [ttk::style lookup [$w cget -style] -font] -linespace]
    # set glFontHeight [expr $fontspace*13/9]
    set glFontHeight [expr $fontspace*106/72]
  }

  set glistSize [expr {int( [winfo height $w] / $glFontHeight)}]
}

proc ::windows::gamelist::SetSelection {code xcoord ycoord} {
  global glSelection glNumber
  set glSelection [expr {int([.glistWin.c$code.text index @$xcoord,$ycoord])}]
  set glNumber [.glistWin.cg.text get $glSelection.0 $glSelection.end]
}

proc SortBy {tree col} {
    global glistCodes glistSortedBy glstart

    set w .glistWin

    # hmmm. WElo, BElo and a few others are not valid sorting... apparently
    # and no reverse order !?

    set ::windows::gamelist::finditems {}
    catch {sc_base sort $col {}}

    ### directions are actually reversed so we can insert
    ### into tree instead of appending (for speedup)
    if {$col != $glistSortedBy} {
      set dir {-decreasing}
      set glistSortedBy $col
    } else {
      set dir {-increasing}
      set glistSortedBy {}
    }

    set glstart 1
    ::windows::gamelist::Refresh
}


proc setTitle {message} {
  wm title .glistWin "Scid: [tr WindowsGList] $message"
}

proc ::windows::gamelist::Refresh {} {
  global glistCodes
  global glstart
  global glistSize 

  set w .glistWin
  if {![winfo exists $w]} {return}

  set ::windows::gamelist::finditems {}
  updateStatusBar
  $w.tree delete [$w.tree children {}]

  # check boundries !

  set totalSize [sc_filter count]

  if {$glstart < 1} {
    set glstart 1
  }

  if {$glstart > $totalSize} {
    set glstart $totalSize
  }

  set glistEnd [expr $glstart + $glistSize]
  if { $glistEnd > $totalSize} {
    set glistEnd $totalSize
  }

  for {set line $glistEnd} {$line >= $glstart} {incr line -1} {
    set values [sc_game list $line 1 $glistCodes]
    $w.tree insert {} 0 -values $values -tag [list click1 click2 treefont]
  }

  setTitle "$totalSize $::tr(games)" 

  # unbusyCursor .glistWin

  $w.vsb configure -to [expr $totalSize - $glistSize]

  if {[sc_base isReadOnly]} {
    $w.c.delete configure -state disabled
  } else {
    $w.c.delete configure -state normal
  }
}

proc ::windows::gamelist::SetStart {unit} {
  global glstart

  set glstart [expr {int($unit)}]

  ::windows::gamelist::Refresh
}

proc ::windows::gamelist::ToggleFlag {flag} {

  ### currently only used to mark games as (un)deleted

  set items [.glistWin.tree selection]
  if { "$items" == "" } {
    bell
  } else {
    busyCursor .glistWin 1
    foreach item [.glistWin.tree selection] {
      # mark item as "flag"
      set number [.glistWin.tree set $item Number]
      catch {sc_game flag $flag $number invert}
    }
    ::windows::gamelist::Refresh
    unbusyCursor .glistWin
  }
}

# unused
proc removeFromFilter {{dir none}} {
  global glNumber glstart
  if {$glNumber < 1} { return }
  if {$glNumber > [sc_base numGames]} { return }
  if {$dir == "none"} {
    sc_filter remove $glNumber
  } elseif {$dir == "up"} {
    sc_filter remove 1 $glNumber
    set glstart 1
  } else {
    sc_filter remove $glNumber 9999999
  }
  ::windows::stats::Refresh
  ::windows::gamelist::Refresh
}

trace variable glexport w updateExportGList

proc openExportGList {} {
  global glexport
  set w .glexport

  if {[sc_filter count] < 1} {
    tk_messageBox -type ok -icon info -title "Scid" \
      -message "This are no games in the current filter." -parent .glistWin
    return
  }

  if {[winfo exists $w]} {
    raiseWin $w
    updateExportGList
    return
  }
  toplevel $w
  wm title $w "Scid: Save Game List"

  label $w.lfmt -text "Format:" -font font_Bold
  pack $w.lfmt -side top
  entry $w.fmt -textvar glexport -bg white -fg black -font font_Fixed
  pack $w.fmt -side top -fill x
  text $w.tfmt -width 1 -height 5 -font font_Fixed -fg black \
    -wrap none -relief flat
  pack $w.tfmt -side top -fill x
  $w.tfmt insert end "w: White            b: Black            "
  $w.tfmt insert end "W: White Elo        B: Black Elo        \n"
  $w.tfmt insert end "m: Moves count      r: Result           "
  $w.tfmt insert end "y: Year             d: Date             \n"
  $w.tfmt insert end "e: Event            s: Site             "
  $w.tfmt insert end "n: Round            o: ECO code         \n"
  $w.tfmt insert end "g: Game number      f: Filtered number  "
  $w.tfmt insert end "F: Final material   S: Non-std start pos\n"
  $w.tfmt insert end "D: Deleted flag     U: User flags       "
  $w.tfmt insert end "C: Comments flag    V: Variations flag  \n"
  $w.tfmt configure -cursor top_left_arrow -state disabled
  addHorizontalRule $w
  label $w.lpreview -text $::tr(Preview:) -font font_Bold
  pack $w.lpreview -side top
  text $w.preview -width 80 -height 5 -font font_Fixed -bg gray95 -fg black \
    -wrap none -setgrid 1 -xscrollcommand "$w.xbar set"
  scrollbar $w.xbar -orient horizontal -command "$w.preview xview"
  pack $w.preview -side top -fill x
  pack $w.xbar -side top -fill x
  addHorizontalRule $w
  pack [frame $w.b] -side bottom -fill x
  button $w.b.default -text "Default" -command {set glexport $glexportDefault}
  button $w.b.ok -text "OK" -command saveExportGList
  button $w.b.close -textvar ::tr(Cancel) -command "focus .; grab release $w; destroy $w"
  pack $w.b.close $w.b.ok -side right -padx 2 -pady 2
  pack $w.b.default -side left -padx 2 -pady 2
  wm resizable $w 1 0
  focus $w.fmt
  updateExportGList
  grab $w
}

proc updateExportGList {args} {
  global glexport
  set w .glexport
  if {! [winfo exists $w]} { return }
  set text [sc_game list 1 5 "$glexport\n"]
  $w.preview configure -state normal
  $w.preview delete 1.0 end
  $w.preview insert end $text
  $w.preview configure -state disabled
}

proc saveExportGList {} {
  global glexport env
  set ftypes {{"Text files" {.txt}} {"All files" *}}
  set fname [tk_getSaveFile -filetypes $ftypes -parent .glexport \
               -title "Scid: Save Game List" -initialdir $env(HOME)]
  if {$fname == ""} { return }
  set showProgress 0
  if {[sc_filter count] >= 20000} { set showProgress 1 }
  if {$showProgress} {
    progressWindow "Scid" "Saving game list..." $::tr(Cancel) sc_progressBar
  }
  busyCursor .
  set res [catch {sc_game list 1 9999999 "$glexport\n" $fname} err]
  unbusyCursor .
  if {$showProgress} { closeProgressWindow }
  if {$res} {
    tk_messageBox -type ok -icon warning -title "Scid" -message $err
    return
  }
  focus .
  grab release .glexport
  destroy .glexport
  return
}

