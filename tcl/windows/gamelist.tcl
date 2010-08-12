
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

# glistFields: Layout of the GameList window fields.

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

#    Note that the "g" (game number) field MUST appear somewhere,
#    but the fields can be in any order.
#    See the comments at the start of the function "PrintGameInfo" in
#    src/index.cpp for a list of available field codes.

# code  name  anchor  width

set glistFields {
  g Number	e 7
  w White	w 14
  b Black	w 14
  r Result	e 5
  m Length	e 5
  e Event	w 10
  n Round	e 5
  d Date	w 10
  s Site	w 10
  W WElo	e 5
  B BElo	e 5
  o ECO		e 5
  O Opening	w 6
  D Deleted	e 2
  U Flags	e 2
  V Vars	e 2
  C Comments	w 2
  A Annos	e 2
  S Start	e 1
}

set glistCodes {} 
set glistNames {}

# ???
# lappend glistFields { c  3 left  black      0 }
# lappend glistFields { E  7 left  darkRed    0 }
# lappend glistFields { F  7 left  darkBlue   0 }


foreach {code title anchor null} $glistFields {
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
  global glstart
  variable findtext

  ::utils::history::AddEntry ::windows::gamelist::findtext $findtext
  .glistWin.b.find selection range end end

  set temp [sc_filter textfilter $::windows::gamelist::findcase $findtext]
  #         sc_filter textfilter  CASE_FLAG  TEXT

  busyCursor .glistWin 0

  if {$temp == {0}} {
    puts "$temp matches"
    set glstart 1
    ::windows::gamelist::Refresh
    bell
  } else {
    set glstart 1
    ::windows::gamelist::Refresh
    .glistWin.tree selection set [lindex [.glistWin.tree children {}] 0]
  }
}

### Rewrote this ... again. S.A
#
# Find text only matches against White/Black/Event/Site

proc ::windows::gamelist::FindText {} {
  global glstart
  variable findtext

  ::utils::history::AddEntry ::windows::gamelist::findtext $findtext
  .glistWin.b.find selection range end end

  set temp [sc_filter textfind $::windows::gamelist::findcase $glstart $findtext]
  busyCursor .glistWin 0
  if {$temp < 1} {
    set glstart 1
    ::windows::gamelist::Refresh
    bell
  } else {
    set glstart $temp
    ::windows::gamelist::Refresh
    .glistWin.tree selection set [lindex [.glistWin.tree children {}] 0]
  }
}

proc ::windows::gamelist::Load {number} {
  # for some reason, number has a trailing "\n"

  set number [string trim $number "\n"]
  set ::windows::gamelist::goto $number
  ::game::Load $number
}

proc ::windows::gamelist::showCurrent {} {
  global glistCodes

  set index [sc_game number]
  set ::windows::gamelist::goto $index
  ::windows::gamelist::showNum $index
}

proc ::windows::gamelist::showNum {index} {
  global glstart

  set result [sc_filter locate $index]

  # First, check that requested game is not filtered
  if  { [sc_filter index $result] != $index \
     || $result < 1 \
     || $result > [sc_filter count]} {
    bell
  } else {
    # See if it's already on the screen
    set found 0
    foreach item [.glistWin.tree children {}] {
      if {[.glistWin.tree set $item Number] == $index} {
	set found 1
	break
      }
    }
    if {$found} {
      .glistWin.tree selection set $item
    } else {
      set glstart $result
      ::windows::gamelist::Refresh
      .glistWin.tree selection set [lindex [.glistWin.tree children {}] 0]
    }
  }
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


  if { $::windows::gamelist::widths == {} } {
    # initialise field widths
    set fontwidth [font measure [ttk::style lookup [$w.tree cget -style] -font] "X"]
    foreach {nulla nullb nullc i} $glistFields {
	lappend ::windows::gamelist::widths [expr $fontwidth * $i]
    }
  }

  # title font isn't working &&& I don't think it's configurable !
  $w.tree tag configure treetitle -font font_H1

  # this font is working, but doesn't affect how many entries fit on a screen, and isn't enabled
  $w.tree tag configure treefont -font font_Regular

  $w.tree tag bind click2 <Double-Button-1> {::windows::gamelist::Load [%W set [%W focus] Number]}
  $w.tree tag configure deleted -foreground gray70
  $w.tree tag configure current -foreground RoyalBlue3

  # $w.tree tag configure colour -background $::defaultBackground
  # $w.tree tag bind click1 <Button-1> {}

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
  foreach {code col anchor null} $glistFields width $::windows::gamelist::widths {
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

  button $w.b.current -relief flat -textvar ::tr(Current) \
    -command ::windows::gamelist::showCurrent
  set ::windows::gamelist::goto {}
  entry $w.b.goto -width 8 -justify right -textvariable ::windows::gamelist::goto
  bind $w.b.goto <Return> {
    ::windows::gamelist::showNum $::windows::gamelist::goto
  }

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
    set new_focus [.glistWin.tree set [.glistWin.tree next [lindex $items end]] Number]
    .glistWin.tree delete $items

    ::windows::stats::Refresh
    ::windows::gamelist::Refresh
    ::windows::gamelist::showNum $new_focus

    set ::windows::gamelist::finditems {}
    setGamelistTitle
  }
  bind $w.tree <Delete> "$w.b.remove invoke"


  ### Filter items against the find entry widget
   button $w.b.filter -relief flat -text "Filter" \
    -command {::windows::gamelist::FilterText}

  button $w.b.findlabel -relief flat -textvar ::tr(GlistFindText) \
    -command {::windows::gamelist::FindText}

  # button $w.b.findall -relief flat -text "Find All" \
  #   -command {::windows::gamelist::FindText}

  ttk::combobox $w.b.find -width 12 -textvariable ::windows::gamelist::findtext
  ::utils::history::SetCombobox ::windows::gamelist::findtext $w.b.find

  ### doesn't work
  # ::utils::history::SetLimit ::windows::gamelist::findtext 5
  # ::utils::history::PruneList ::windows::gamelist::findtext

  bind $w.b.find <Return> {::windows::gamelist::FindText}
  bind $w.b.find <Home> "$w.b.find icursor 0; break"
  bind $w.b.find <End> "$w.b.find icursor end; break"

  checkbutton $w.b.findcase -text "Ignore Case" \
    -variable ::windows::gamelist::findcase -onvalue 1 -offvalue 0

  pack $w.b.current $w.b.goto -side left -padx 0
  pack $w.b.findcase $w.b.find $w.b.findlabel $w.b.filter $w.b.reset -side right
  pack $w.b.negate $w.b.remove -side left 

  ### Bottom row of buttons , etc

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
    configDeleteButtons
  }

  dialogbutton $w.c.empty -text {Compact} -command "compactGames $w ; configDeleteButtons"

  configDeleteButtons

  dialogbutton $w.c.export -textvar ::tr(Save...) -command openExportGList
  dialogbutton $w.c.help  -textvar ::tr(Help) -command { helpWindow GameList }
  dialogbutton $w.c.close -textvar ::tr(Close) -command { focus .; destroy .glistWin }

  pack $w.c.browse $w.c.load $w.c.delete $w.c.empty -side left -padx 3
  pack $w.c.close $w.c.help $w.c.export -side right -padx 3

  ::windows::gamelist::Refresh
  set ::windows::gamelist::goto 1
  focus $w.tree
  bind $w <Configure> {
    recordWidths
    recordWinSize .glistWin
    ::windows::gamelist::Refresh
  }
}
proc configDeleteButtons {} {
  set w .glistWin
  if {[sc_base current] == [sc_info clipbase]} {
    ### clipbase open
    $w.c.delete configure -state normal
    $w.c.empty configure -state disabled
  } else {
    if {[sc_base isReadOnly]} {
      $w.c.delete configure -state disabled
      $w.c.empty configure -state disabled
    } else {
      $w.c.delete configure -state normal
      if {[compactGamesEmpty]} {
	$w.c.empty configure -state disabled
      } else {
	$w.c.empty configure -state normal
      }
    }
  }
}

proc ::windows::gamelist::Scroll {nlines} {
  global glstart

  incr glstart $nlines
  ::windows::gamelist::Refresh
}

proc ::windows::gamelist::SetSize {} {
  global glistSize glFontHeight windowsOS

  ### Figure out how many lines of text in the treeview widget
  ### This is probably broke on some platforms

  ### "treeview configure -rowheight" might work better, but is only in cvs
  ### also consider "[$w bbox [lindex [$w children {}] 0]]" 

  set w .glistWin.tree
  if {![winfo exists $w]} {return}

  if {![info exists glFontHeight]} {

    set fontspace [font metrics [ttk::style lookup [$w cget -style] -font] -linespace]

    # Nasty hack to make things work

    if {$windowsOS} {
      set glFontHeight [expr $fontspace*120/72]
    } else {
      set glFontHeight [expr $fontspace*106/72]
    }
  }

  set glistSize [expr {[winfo height $w] / $glFontHeight}]
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


proc setGamelistTitle {} {
  setTitle "[sc_filter count]/[sc_base numGames] $::tr(games)" 
}

proc setTitle {message} {
  wm title .glistWin "Scid: $message"
}

proc ::windows::gamelist::Refresh {} {
  global glistCodes
  global glstart
  global glistSize 

  set w .glistWin
  if {![winfo exists $w]} {return}

  ::windows::gamelist::SetSize

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

  set current [sc_game number]
  for {set line $glstart} {$line <= $glistEnd} {incr line} {
    set values [sc_game list $line 1 $glistCodes]
    if {[lindex $values 0] == "$current "} {
      $w.tree insert {} end -values $values -tag [list click2 current]
    } elseif {[lindex $values 13] == {D }} {
      $w.tree insert {} end -values $values -tag [list click2 deleted] ;#treefont
    } else {
      $w.tree insert {} end -values $values -tag click2
    }
  }

  setGamelistTitle
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
    foreach item [.glistWin.tree selection] {
      # mark item as "flag"
      set number [.glistWin.tree set $item Number]
      catch {sc_game flag $flag $number invert}
    }
    ::windows::gamelist::Refresh
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
  entry $w.fmt -textvar glexport  -fg black -font font_Fixed
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

