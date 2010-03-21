
########################################################################
### Games list window

# Rewritten to use the ttk::treeview widget (man ttk_treeview)
# by Steven Atkinson 27/06/2009

set ::windows::gamelist::isOpen 0
set glstart 1
set glSelection 0
set glNumber 0

# glistExtra is the window that displays the starting moves of a
# game when the middle mouse button is pressed in the game list window.

toplevel .glistExtra
wm overrideredirect .glistExtra 1
wm withdraw .glistExtra
text .glistExtra.text -font font_Small -background lightYellow \
  -width 40 -height 8 -wrap word -relief solid -borderwidth 1
pack .glistExtra.text -side top

set glistMaxWidth 30

set ::windows::gamelist::findtext ""
set ::windows::gamelist::goto ""
trace variable ::windows::gamelist::goto w {::utils::validate::Regexp {^[0-9]*$}}

### still have to sort this out properly S.A. &&&

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

set glistFields {
  g Number	e
  w White	w
  W WElo	e
  b Black	w
  B BElo	e
  r Result	e
  e Event	w
  s Site	w
  n Round	e
  d Date	w
  m Length	e
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
  # unusual glistCodes format is needed for [sc_game list ...]
  lappend glistCodes "$code*\n"
  lappend glistNames $title
}

### not sure about these missing fileds at all &&&

# set glistNames { Number White WElo Black BElo Event Site Round Date Result Length ECO Opening Deleted Flags Vars Comments Annos Start }
# Number Filtered White WElo Black BElo Event Site Round Date Year EDate Result Length Country ECO Opening EndMaterial Deleted Flags Vars Comments Annos Start
#  Number White WElo Black BElo Event Site Round Date Result Length ECO Opening Deleted Flags Vars Comments Annos Start

proc ::windows::gamelist::FindText {findcase {findall 0}} {
  global glstart
  variable findtext
  busyCursor .glistWin 1
  ::utils::history::AddEntry ::windows::gamelist::findtext $findtext
  .glistWin.b.find selection range end end

  set found 0
  set index 0

  ### A little voodoo to search the whole list

  if { $findall } {
      set items [.glistWin.tree children {}]
      set ::windows::gamelist::finditems {}
  } else {
    if {$::windows::gamelist::findtextprev == $findtext && \
	$::windows::gamelist::finditems != {}} {
      set items $::windows::gamelist::finditems
    } else {
      set items [.glistWin.tree children {}]
    }
  }

  set itemsfound {}
  foreach item $items {
    incr index
    if { [regexp "[expr { $findcase ? {-nocase} : {--} } ]" $findtext [.glistWin.tree item $item -values]] } {
      set found 1
      lappend itemsfound $item
      if { !$findall } { break }
    }
  }

  if {$found} {
    .glistWin.tree selection set $itemsfound
    .glistWin.tree see [lindex $itemsfound end]
    .glistWin.tree see [lindex $itemsfound 0]
    # discard previously searched items from list
    set ::windows::gamelist::finditems [lrange $items $index end]
  } else {
    set ::windows::gamelist::finditems {}

    # flash combo box
    # .glistWin.b.find configure -background mistyrose1
    # update
    # after 500
    # .glistWin.b.find configure -background white
    .glistWin.tree selection set {}
    bell
  }
  unbusyCursor .glistWin

  set ::windows::gamelist::findtextprev $findtext

  return

  # the old way is done in C, and will be faster on big tables, but
  # it forces a redraw of the widget
  
  set temp [sc_filter textfind $glstart $findtext]
  busyCursor .glistWin 0
  if {$temp < 1} { set temp 1 }
  set glstart $temp
  ::windows::gamelist::Refresh
}

proc ::windows::gamelist::showCurrent {} {
  global glistCodes

  set index [sc_game number]
  ::windows::gamelist::showNum $index
}

proc ::windows::gamelist::showNum {index} {

  set found 0
  foreach item [.glistWin.tree children {}] {
    if { [.glistWin.tree set $item Number] == $index } {
      set found 1
      break
    }
  }
  if { $found } {
    .glistWin.tree selection set $item
    .glistWin.tree see $item
    .glistWin.tree focus $item
  } else {
    tk_messageBox -type ok -icon warning -title "Scid" \
      -message "Item $index not found" -parent .glistWin
  }
  ### Hmmm
  # ::windows::gamelist::Refresh
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

  global glstart highcolor glSelection helpMessage
  global glNumber buttoncolor glistNames glistFields glistSortedBy
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

  standardShortcuts $w
  bind $w <F1> { helpWindow GameList }
  bind $w <Destroy> { ::windows::gamelist::Close }
  bind $w <Escape> "destroy $w"
  bind $w <Left> {}
  bind $w <Right> {}
  set ::windows::gamelist::isOpen 1

  # Entry/Button frames
  pack [frame $w.c] -side bottom -fill x -ipady 5 -padx 10 
  pack [frame $w.b] -side bottom -fill x -ipady 5 -padx 10

  ttk::frame $w.f
  ttk::treeview $w.tree -columns $glistNames -show headings \
    -yscroll "$w.vsb set" -xscroll "$w.hsb set"

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

  $w.tree tag bind click2 <Double-Button-1> {::game::Load [%W set [%W focus] Number]}
  $w.tree tag bind click1 <Button-1> {.glistWin.b.goto delete 0 end }

  if {[tk windowingsystem] ne "aqua"} {
      ttk::scrollbar $w.vsb -orient vertical -command "$w.tree yview"
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

  ## Init the ttk_treeview column titles

  set font [ttk::style lookup [$w.tree cget -style] -font]
  foreach {code col anchor} $glistFields width $::windows::gamelist::widths {
      $w.tree heading $col -text  $col   -command "SortBy $w.tree $col"
      $w.tree column  $col -width $width -anchor $anchor -stretch 0
  }

  set glistSortedBy Number

  dialogbutton $w.c.invert -text Negate -command {
    set items [.glistWin.tree selection]

    ### This should work ! Hmmpphhh
    # .glistWin.tree selection toggle $items

    set result {}
    set allitems [.glistWin.tree children {}]
    foreach i $allitems {
      if {[lsearch -exact $items $i] == -1} {
        lappend result $i
      }
    }
    .glistWin.tree selection set $result
  }

  dialogbutton $w.c.reset -text Reset -command ::search::filter::reset

  dialogbutton $w.c.remove -textvar ::tr(GlistDeleteField) -command {
    set items [.glistWin.tree selection]
    foreach i $items {
      # puts "removing [.glistWin.tree set $i Number]"
      sc_filter remove [.glistWin.tree set $i Number]
    }
    .glistWin.tree delete $items

    ### do we have to ?
    # ::windows::stats::Refresh
    # ::windows::gamelist::Refresh

    set ::windows::gamelist::finditems {}
    setTitle "[sc_filter count] $::tr(games)"
  }

  dialogbutton $w.c.browse -text $::tr(Browse) -command {
    set selection [.glistWin.tree selection]
    if { $selection != {} } {
      ::gbrowser::new 0 [.glistWin.tree set [lindex $selection 0] Number]
    }
  }

  dialogbutton $w.c.load -text Load -command {
    set selection [.glistWin.tree selection]
    if { $selection != {} } {
      ::game::Load [.glistWin.tree set [lindex $selection 0] Number]
    }
  }

  bind $w <Up> {}
  bind $w <Down> {}
  bind $w <Prior> {}
  bind $w <Next> {}
  bind $w <Home> {
    set item [lindex [.glistWin.tree children {}] 0]
   .glistWin.tree selection set $item
   .glistWin.tree see $item
   .glistWin.tree focus $item
  }
  bind $w <End> {
    set item [lindex [.glistWin.tree children {}] end]
   .glistWin.tree selection set $item
   .glistWin.tree see $item
   .glistWin.tree focus $item
  }

  # It's a bit of work to focus item when pageup/pagedown is used
  # and not sure how to do it. Bug &&& S.A.
  # bind $w <Prior> "$w.b.pgup invoke"
  # bind $w <Next>  "$w.b.pgdn invoke"

  button $w.b.gotolabel -relief flat -textvar ::tr(GlistGameNumber) -command {
    ::windows::gamelist::showNum $::windows::gamelist::goto
  }
  entry $w.b.goto -width 8 -justify right -textvariable ::windows::gamelist::goto
  bind $w.b.goto <Return> {
    ::windows::gamelist::showNum $::windows::gamelist::goto
  }
  button $w.b.current -relief flat -textvar ::tr(Current) -command ::windows::gamelist::showCurrent

  frame $w.c.space -width 20

  set ::windows::gamelist::findtextprev {}
  set ::windows::gamelist::finditems {}

  button $w.b.findall -relief flat -text "Find All" \
    -command {::windows::gamelist::FindText $findcase 1}
  button $w.b.findlabel -relief flat -textvar ::tr(GlistFindText) \
    -command {::windows::gamelist::FindText $findcase}

  ### could use ttk::combo box everywhere 
  ::combobox::combobox $w.b.find -width 15 -textvariable ::windows::gamelist::findtext
  ::utils::history::SetCombobox ::windows::gamelist::findtext $w.b.find
  ### doesnt work
  # ::utils::history::SetLimit ::windows::gamelist::findtext 5
  # ::utils::history::PruneList ::windows::gamelist::findtext

  bind $w.b.find <Return> {::windows::gamelist::FindText $findcase}
  bind $w.b.find <Home> "$w.b.find icursor 0; break"
  bind $w.b.find <End> "$w.b.find icursor end; break"

  checkbutton $w.b.findcase -text "Ignore Case" -variable findcase

  dialogbutton $w.c.export -textvar ::tr(Save...) -command openExportGList
  dialogbutton $w.c.close -textvar ::tr(Close) -command { focus .; destroy .glistWin }

  pack $w.b.gotolabel $w.b.goto $w.b.current -side left 
  pack $w.b.findcase $w.b.find $w.b.findlabel $w.b.findall \
    -side right
  pack $w.c.invert $w.c.reset $w.c.remove -side left -padx 3
  pack $w.c.space $w.c.browse $w.c.load -side left -padx 3
  pack $w.c.close $w.c.export -side right -padx 3

  # MouseWheel bindings:
  # bind $w <MouseWheel> {::windows::gamelist::Scroll [expr {- (%D / 120)}]}
  # if {! $::windowsOS} {
  #   bind $w <Button-4> {::windows::gamelist::Scroll -1}
  #   bind $w <Button-5> {::windows::gamelist::Scroll 1}
  # }

  ::windows::gamelist::Refresh
  focus $w.tree
  bind $w <Configure> { recordWidths ; recordWinSize .glistWin }
}

proc SortBy {tree col} {

    global glistCodes glistSortedBy
    set w .glistWin
    set ::windows::gamelist::finditems {}

    ### directions are actually reversed so we can insert
    ### into tree instead of appending (for speedup)
    if {$col != $glistSortedBy} {
      set dir {-decreasing}
      set glistSortedBy $col
    } else {
      set dir {-increasing}
      set glistSortedBy {}
    }

    setTitle " ... sorting games"
    update

    # Hmmm... remove and delete are different

    # This is tricky as when we delete items the "Number" and "sc_game list" are different

    # Build something we can sort
    set data {}
    foreach item [$tree children {}] {
      lappend data [list [$tree set $item $col] [$tree item $item -values]]
    }

    ### Rebuilding tree is quicker than using "tree move"

    $w.tree delete [$w.tree children {}]

    foreach line [lsort -dictionary -index 0 $dir $data] {
      $w.tree insert {} 0 -values [lindex $line 1] -tag {click1 click2 treefont}
    }

    if {$col == "Number"} {
      setTitle "[sc_filter count] $::tr(games)"
    } else {
      setTitle " ... sorted by $col"
    }

    $w.tree yview 0
}


proc setTitle {message} {
  # wm title .glistWin "Scid [tr WindowsGList]: $message"
  set fname [sc_base filename]
  set fname [file tail $fname]
  wm title .glistWin "$fname: $message"
}

proc ::windows::gamelist::Refresh {} {
  global glstart glistCodes

  set w .glistWin

  if {![winfo exists $w]} {return}

  setTitle " ... loading games"
  update

  set ::windows::gamelist::finditems {}
  updateStatusBar

  set totalSize [sc_filter count]

  $w.tree delete [$w.tree children {}]

  for {set line $totalSize} {$line > 0} {incr line -1} {
    set values [sc_game list $line 1 $glistCodes]
    $w.tree insert {} 0 -values $values -tag {click1 click2 treefont}
  }

  setTitle "$totalSize $::tr(games)" 
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

