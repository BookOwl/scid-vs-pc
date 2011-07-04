
########################################################################
### Games list window

# 27/06/2009
# Rewritten to use the ttk::treeview widget (man ttk_treeview) by Steven Atkinson

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

#    Note that the "g" (game number) field MUST appear somewhere. (Mebbee ?)
#    The field order is how they are appear in the widget.
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
  W WElo	e 5
  B BElo	e 5
  s Site	w 10
  o ECO		e 5
  D Deleted	e 2
  O Opening	w 6
  U Flags	e 2
  V Variations	e 2
  C Comments	e 2
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

### glistCodes is a printf format style string. A \n is used to split the main "sc_game list"
# string into a proper list for processing. It is now appended in sc_game_list

### not sure about these missing fields at all &&&

# set glistNames { Number White WElo Black BElo Event Site Round Date Result Length ECO Opening Deleted Flags Variations Comments Annos Start }
# Number Filtered White WElo Black BElo Event Site Round Date Year EDate Result Length Country ECO Opening EndMaterial Deleted Flags Variations Comments Annos Start
#  Number White WElo Black BElo Event Site Round Date Result Length ECO Opening Deleted Flags Variations Comments Annos Start

proc ::windows::gamelist::FilterText {} {
  global glstart
  variable findtext

  ::utils::history::AddEntry ::windows::gamelist::findtext $findtext
  # clear highlighted text in widget
  .glistWin.b.find selection range end end

  busyCursor .glistWin
  update

  foreach needle [split $findtext +] {
    # temp is number of items removed - currently unused
    #         sc_filter textfilter CASE_FLAG                      TEXT
    set temp [sc_filter textfilter $::windows::gamelist::findcase [string trim $needle]]
  }

  set glstart 1
  ::windows::gamelist::Refresh first
  .glistWin.tree selection set [lindex [.glistWin.tree children {}] 0]

  unbusyCursor .glistWin
}

### Rewrote this ... again. S.A
#
# Find text only matches against White/Black/Event/Site
#
# Previously it would treat "+" as a logical AND... but it's just too slow for tcl.

proc ::windows::gamelist::FindText {} {
  global glstart
  variable findtext

  ::utils::history::AddEntry ::windows::gamelist::findtext $findtext
  .glistWin.b.find selection range end end

  busyCursor .glistWin 
  update
  set temp [sc_filter textfind $::windows::gamelist::findcase $glstart $findtext]
  unbusyCursor .glistWin

  if {$temp < 1} {
    set glstart 1
    ::windows::gamelist::Refresh first
    bell
  } else {
    set glstart $temp
    ::windows::gamelist::Refresh first
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

  # Ooops. [sc_game number] returns 0 after sorting, making this widget useless after sorting

  set index [sc_game number]
  set ::windows::gamelist::goto $index
  ::windows::gamelist::showNum $index
}

proc ::windows::gamelist::showNum {index {bell 1}} {
  global glstart glistSize
  set result [sc_filter locate $index]

  # First, check that requested game is not filtered
  if  { [sc_filter index $result] != $index \
     || $result < 1 \
     || $result > [sc_filter count]} {
    if {$bell=={1}} {
      bell
    }
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

      set totalSize [sc_filter count]
      set lastEntry [expr $totalSize - $glistSize]
      if {$lastEntry < 1} {
	set lastEntry 1
      }
      if {$glstart > $lastEntry} {
	set glstart $lastEntry
      }

      # Highlights CURRENT game if on screen, otherwise game "index"
      # Even when we'd prefer just to highlight "index" :<

      set current_item [::windows::gamelist::Refresh first]
      if {$current_item == {}} {
	# Nasty, nasty recursive call... "found" above will now trigger and highlight this game
	::windows::gamelist::showNum $result $bell
      } else {
	.glistWin.tree selection set $current_item
      }
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
  global glistNames glistFields glistSortedBy glSortReversed glistSize
  global maintFlags maintFlaglist

  if {[winfo exists .glistWin]} {
    focus .
    destroy .glistWin
    set ::windows::gamelist::isOpen 0
    return
  }
  set w .glistWin
  toplevel $w
  wm iconname $w "Scid: [tr WindowsGList]"
  wm withdraw $w
  setWinLocation $w
  setWinSize $w
  ::windows::gamelist::SetSize

  standardShortcuts $w
  bind $w <F1> { helpWindow GameList }
  bind $w <Destroy> { ::windows::gamelist::Close }
  bind $w <Escape> "destroy $w"

  set ::windows::gamelist::isOpen 1

  ### Frames

  pack [frame $w.c] -side bottom -fill x -padx 5 
  pack [frame $w.b] -side bottom -fill x -padx 5

  frame $w.f
  ttk::treeview $w.tree -columns $glistNames -show headings -xscroll "$w.hsb set"
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
  $w.tree tag configure deleted -foreground gray80
  $w.tree tag configure error -foreground red
  # bind $w.tree <ButtonRelease-1> { parray ::ttk::treeview::State}

  # Hmm... seems no way to change the deafult blue bg colour for selected items
  # without using (extra) tags. So this colour must look ok with a blue background
  $w.tree tag configure current -foreground skyblue2

  # $w.tree tag configure colour -background $::defaultBackground
  # $w.tree tag bind click1 <Button-1> {}

  ### can't use scrollbar because  the line "set glstart $::glistStart($b)" in gamelist::Reload fails
  # scale  $w.vsb -from 1 -orient vertical -variable glstart -showvalue 0 -command ::windows::gamelist::SetStart -bigincrement $glistSize -relief flat 
  ttk::scale     $w.vsb -orient vertical -command ::windows::gamelist::SetStart -from 1 -variable glstart
  # -borderwidth 0
  ttk::scrollbar $w.hsb -orient horizontal -command "$w.tree xview"

  # SCID:
  #  scale $w.scale -from 1 -length 250 -orient horiz -variable glstart -showvalue 0 -command ::windows::gamelist::SetStart \ -bigincrement $glistSize -takefocus 0 -width 10 -troughcolor $buttoncolor


  pack $w.f -fill both -expand 1
  grid $w.tree $w.vsb -in $w.f -sticky nsew
  grid $w.hsb         -in $w.f -sticky nsew
  grid column $w.f 0 -weight 1
  grid row    $w.f 0 -weight 1

  ### Init the ttk_treeview column titles

  set font [ttk::style lookup [$w.tree cget -style] -font]
  foreach {code col anchor null} $glistFields width $::windows::gamelist::widths {
      if {[info exists ::tr(Glist$col)]} {
        set name $::tr(Glist$col)
      } else {
        set name $col
      }
      $w.tree heading $col -text  $name  -command [list SortBy $w.tree $col]
      $w.tree column  $col -width $width -anchor $anchor -stretch 0
  }

  set glistSortedBy {}
  set glSortReversed 0

  bind $w <Left>  {}
  bind $w <Right> {}
  bind $w <Up>    {::windows::gamelist::Scroll -1}
  bind $w <Down>  {::windows::gamelist::Scroll  1}
  bind $w <Prior> {::windows::gamelist::Scroll -$glistSize}
  bind $w <Control-a> {.glistWin.tree selection set [.glistWin.tree children {}]}
  bind $w <Home> {
    set glstart 1
    ::windows::gamelist::Refresh first
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
    ::windows::gamelist::Refresh last
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
    ::windows::gamelist::Refresh first
  }
  # MouseWheel bindings:
  # bind $w <MouseWheel> {::windows::gamelist::Scroll [expr {- (%D / 120)}]}
  if {$::windowsOS} {
    bind $w <MouseWheel> {
      if {[expr -%D] < 0} { ::windows::gamelist::Scroll -1}
      if {[expr -%D] > 0} { ::windows::gamelist::Scroll 1}
    }
  } else {
    bind $w <Button-4> {::windows::gamelist::Scroll -1}
    bind $w <Button-5> {::windows::gamelist::Scroll 1}
  }

  bind $w <Control-F> ::search::filter::reset
  bind $w <Control-N> ::search::filter::negate

  set ::windows::gamelist::findtextprev {}
  set ::windows::gamelist::finditems {}

  ### Top row of buttons, etc

  button $w.b.gfirst -image tb_gfirst -command "
    event generate $w.tree <Home>
    ::game::LoadNextPrev first 0" -relief flat
  button $w.b.gprev -image tb_gprev -command {::game::LoadNextPrev previous 0} -relief flat
  button $w.b.gnext -image tb_gnext -command {::game::LoadNextPrev next 0} -relief flat
  button $w.b.glast -image tb_glast -command "
    event generate $w.tree <End>
   ::game::LoadNextPrev last 0" -relief flat

  button $w.b.current -font font_Small -relief flat -textvar ::tr(Current) \
    -command ::windows::gamelist::showCurrent
  set ::windows::gamelist::goto {}

  button $w.b.negate -text Negate -font font_Small -relief flat -command {
    # .glistWin.tree selection toggle [.glistWin.tree children {}]
    sc_filter negate
    ::windows::gamelist::Refresh
  }


  ### Filter items. (Delete items is different)
  button $w.b.remove -textvar ::tr(GlistDeleteField) -font font_Small -relief flat -command {
    set items [.glistWin.tree selection]
    foreach i $items {
      sc_filter remove [.glistWin.tree set $i Number]
    }
    set gl_num [.glistWin.tree set [.glistWin.tree next [lindex $items end]] Number]
    .glistWin.tree delete $items

    ::windows::stats::Refresh
    ::windows::gamelist::Refresh
    ::windows::gamelist::showNum $gl_num nobell

    set ::windows::gamelist::finditems {}
    setGamelistTitle
  }
  bind $w.tree <Delete> "$w.b.remove invoke"

  button $w.b.removeabove -text Rem -image arrow_up -compound right -font font_Small -relief flat -command {removeFromFilter up}
  button $w.b.removebelow -text Rem -image arrow_down -compound right -font font_Small -relief flat -command {removeFromFilter down}
  button $w.b.reset -text Reset -font font_Small -relief flat -command ::search::filter::reset

  ### Filter items against the find entry widget
   button $w.b.filter -font font_Small -relief flat -text "Filter" \
    -command {::windows::gamelist::FilterText}

  button $w.b.findlabel -font font_Small -relief flat -textvar ::tr(GlistFindText) \
    -command {::windows::gamelist::FindText}

  # button $w.b.findall -font font_Small -relief flat -text "Find All" \
  #   -command {::windows::gamelist::FindText}

  ttk::combobox $w.b.find -width 15 -font font_Small -textvariable ::windows::gamelist::findtext
  ::utils::history::SetCombobox ::windows::gamelist::findtext $w.b.find

  # didn't use to work
  # ::utils::history::SetLimit ::windows::gamelist::findtext 5
  # ::utils::history::PruneList ::windows::gamelist::findtext

  bind $w.b.find <Control-Return> "$w.c.load invoke ; destroy $w "
  bind $w.b.find <Return> {::windows::gamelist::FindText}
  bind $w.b.find <Home> "$w.b.find icursor 0; break"
  bind $w.b.find <End> "$w.b.find icursor end; break"

  checkbutton $w.b.findcase -text "Ignore Case" -font font_Small \
    -variable ::windows::gamelist::findcase -onvalue 1 -offvalue 0

  pack $w.b.findcase -side right
  pack $w.b.find -side right ; # -expand 1 -fill x
  pack $w.b.findlabel $w.b.filter $w.b.reset -side right
  pack $w.b.gfirst $w.b.gprev $w.b.gnext $w.b.glast $w.b.current $w.b.negate $w.b.remove $w.b.removeabove $w.b.removebelow -side left

  ### Bottom row of buttons , etc

  entry $w.c.goto -width 8 -justify right -textvariable ::windows::gamelist::goto -font font_Small
  bind $w.c.goto <Return> {
    ::windows::gamelist::showNum $::windows::gamelist::goto
  }
  button $w.c.browse -text $::tr(Browse) -font font_Small -command {
    set selection [.glistWin.tree selection]
    if { $selection != {} } {
      ::gbrowser::new 0 [.glistWin.tree set [lindex $selection 0] Number]
    }
  }

  button $w.c.load -text Load -font font_Small -command {
    set selection [.glistWin.tree selection]
    if { $selection != {} } {
      ::windows::gamelist::Load [.glistWin.tree set [lindex $selection 0] Number]
    }
  }

  button $w.c.delete -text $::tr(Delete) -font font_Small -command {
    ::windows::gamelist::ToggleFlag D
    configDeleteButtons
    updateGameinfo
  }

  button $w.c.empty -text {Compact} -font font_Small -command "compactGames $w ; configDeleteButtons"

  # Flag Menubutton
  menubutton $w.c.title -menu $w.c.title.m -indicatoron 1 -relief flat -font font_Small
  menu $w.c.title.m -font font_Small

  foreach flag $maintFlaglist  {
    # dont translate CustomFlag (todo)
    if { [lsearch -exact { 1 2 3 4 5 6 } $flag ] == -1 } {
      set tmp $::tr($maintFlags($flag))
    } else {
      set tmp [sc_game flag $flag description]
      if {$tmp == "" } {
        set tmp "Custom $flag"
      } else {
        set tmp "$tmp ($flag)"
      }
    }
    $w.c.title.m add command -label "$tmp" -command "
      set glistFlag $flag
      $w.c.title configure -text \"$tmp\"
      refreshCustomFlags
      "
  }
  # only need to call this now to init the menubutton "-text"
  refreshCustomFlags

  button $w.c.flag -text $::tr(Flag) -font font_Small -command {
    ::windows::gamelist::ToggleFlag $glistFlag
    updateGameinfo
  }

  configDeleteButtons

  button $w.c.export -textvar ::tr(Save) -font font_Small -command openExportGList
  button $w.c.help  -textvar ::tr(Help) -width 5 -font font_Small -command { helpWindow GameList }
  button $w.c.close -textvar ::tr(Close) -font font_Small -command { focus .; destroy .glistWin }

  pack $w.c.close $w.c.help $w.c.export -side right -padx 3
  pack $w.c.flag $w.c.title $w.c.goto $w.c.browse $w.c.load $w.c.delete $w.c.empty -side left -padx 3

  set ::windows::gamelist::goto 1
  bind $w <Configure> {::windows::gamelist::Configure %W }

  update

  if {$::windowsOS} {
    # cant focus entry combo on windows as it hogs the wheelmouse
    focus $w.tree
  } else {
    # focus entry box
    focus $w.b.find
  }

  # hacks to disable the down/page-down keys for combobox
  bind  $w.b.find <Down> "focus $w.tree ; event generate $w.tree <Down> ; break"
  bind  $w.b.find <End>  "focus $w.tree ; event generate $w.tree <End> ; break"

  ::windows::gamelist::Refresh
  ::windows::switcher::Open
  wm state $w normal
}

proc ::windows::gamelist::Configure {window} {
  recordWidths
  recordWinSize .glistWin

  if {$window == {.glistWin.tree}} {
    ::windows::gamelist::Refresh
  }
}

proc configDeleteButtons {} {
  # also check the Flag button
  set w .glistWin
  # debug puts [sc_base current] &&&
  if {[sc_base current] == [sc_info clipbase]} {
    ### Can't compact clipbase
    $w.c.empty configure -state disabled
    $w.c.flag configure -state normal
    $w.c.title configure -state normal
    $w.c.delete configure -state normal
  } elseif {[sc_base isReadOnly]} {
    $w.c.flag configure -state disabled
    $w.c.title configure -state disabled
    $w.c.delete configure -state disabled
    $w.c.empty configure -state disabled
  } else {

    ### do we want to always check the delete and flag buttons ? &&&
    #  if {[.glistWin.tree selection] == ""} disable delete, flag
    # $w.tree tag bind click <Button-1> {configDeleteButtons}

    $w.c.flag configure -state normal
    $w.c.title configure -state normal
    $w.c.delete configure -state normal
    $w.c.empty configure -state normal

    ### too slow!
    # if {[compactGamesNull]} 
    #  $w.c.empty configure -state disabled
    # else 
    #  $w.c.empty configure -state normal
  }
}

proc ::windows::gamelist::Scroll {nlines} {
  global glstart

  incr glstart $nlines
  if {$nlines < 0} {
  ::windows::gamelist::Refresh last
  } else {
  ::windows::gamelist::Refresh first
  }
}

proc ::windows::gamelist::SetSize {} {
  global glistSize glFontHeight 

  ### Figure out how many lines of text in the treeview widget
  ### This is probably broke on some platforms

  ### "treeview configure -rowheight" might work better, but is only in cvs
  ### also consider "[$w bbox [lindex [$w children {}] 0]]" 

  set w .glistWin.tree
  if {![winfo exists $w]} {return}

  if {![info exists glFontHeight]} {

    set fontspace [font metrics [ttk::style lookup [$w cget -style] -font] -linespace]

    # Nasty hack to make things work

    if {$::windowsOS} {
      set glFontHeight [expr $fontspace*130/72]
    } elseif {$::macOS} {
      set glFontHeight [expr $fontspace*92/72]
    } else {
      set glFontHeight [expr $fontspace*106/72]
    }
  }
  # $glFontHeight ~ 22 linux

  set glistSize [expr {[winfo height $w] / $glFontHeight +([winfo height $w]-300)/200}]

  # debugging voodoo
  # puts "glistSize $glistSize , winfo height [winfo height $w]"
  # 700 = +2 # 100 = -1
}

image create photo arrow_up -format gif -data {
R0lGODlhCgAKAIABAAAAAP///yH5BAEKAAEALAAAAAAKAAoAAAIPjI+pq8AA
G4xnWmMz26gAADs=
}

image create photo arrow_down -format gif -data {
R0lGODlhCgAKAIABAAAAAP///yH5BAEKAAEALAAAAAAKAAoAAAIPjI+pa+D/
GnRoqrgA26wAADs=
}

### Array recording which databases have been sorted, and which field and order

array set glistSortColumn {}
array set glistStart {}

# There is no other mechanism to remember last database sort, but there should
# probably be one in "tkscid.h::struct scidBaseT".
# "glistSortColumn" is currently not persistent.  It could be done, but isn't
# trivial as a problem with having a history is that it gets complicated when
# handling read-only PGNs

proc SortBy {tree col} {
    global glistCodes glistSortedBy glstart glSortReversed glistSortColumn

    set w .glistWin

    # hmmm. WElo, BElo and a few others are not valid sorting... apparently

    set ::windows::gamelist::finditems {}
  
    if {$col == $glistSortedBy} {
      set glSortReversed [expr !$glSortReversed]
    } else {
      set glSortReversed 0

      # clear previous arrows
      if {$glistSortedBy != {} } {
	$w.tree heading $glistSortedBy -image {}
      }

      set glistSortedBy $col
    }

    set glistSortColumn([sc_base current]) [list $col $glSortReversed ]

    if {$glSortReversed} {
      sc_base sortdown
    } else {
      sc_base sortup
    }

    busyCursor .
    update
    catch {sc_base sort $col {}}
    unbusyCursor .

    set glstart 1
    ::windows::gamelist::Refresh
}


proc setGamelistTitle {} {
  set fname [file tail [sc_base filename]]
  if {![string match {\[*\]} $fname]} {
    set fname "\[$fname\]"
  }

  setTitle "$fname [sc_filter count]/[sc_base numGames] $::tr(games)" 
}

proc setTitle {message} {
  wm title .glistWin "Scid: $message"
}

# called by file.tcl when db is changed

proc ::windows::gamelist::Reload {} {
  global glistSortedBy glstart

  set b [sc_base current]

  if {[info exists ::glistStart($b)]} {
    set glstart $::glistStart($b)
  }

  set w .glistWin
  if {![winfo exists $w]} {return}

  if {$glistSortedBy != {} } {
    $w.tree heading $glistSortedBy -image {}
  }

  set glistSortedBy {}
  sc_base sortup
  ::windows::gamelist::Refresh
}

# Returns the treeview item for current game (if it is shown in widget)

proc ::windows::gamelist::Refresh {{see {}}} {
  global glistCodes glstart glistSize glistSortColumn glistSortedBy glistStart

  set w .glistWin
  if {![winfo exists $w]} {return}

  set b [sc_base current]

  if {[info exists glistSortColumn($b)]} {

    foreach {col glSortReversed} $glistSortColumn($b) {}
    set glistSortedBy $col
    if {$glSortReversed} {
	$w.tree heading $col -image arrow_down
    } else {
	$w.tree heading $col -image arrow_up
    }
  } else {
    # clear previous arrows
    if {$glistSortedBy != {} } {
      $w.tree heading $glistSortedBy -image {}
    }
  }

  ::windows::gamelist::SetSize

  set ::windows::gamelist::finditems {}
  updateStatusBar
  $w.tree delete [$w.tree children {}]

  # check boundries !
  set totalSize [sc_filter count]

  if {$glstart < 1} {
    set glstart 1
  }
  if {$glstart == 1} {
    set see first
  }
  if {$glstart > $totalSize} {
    set glstart $totalSize
  }
  set glistStart($b) $glstart

  set glistEnd [expr $glstart + $glistSize]
  if { $glistEnd > $totalSize} {
    set glistEnd $totalSize
  }

  set current_item {}
  set current [sc_game number]

  ### sc_game_list now returns a string with NEWLINES which we use to split into a list
  ### It will probably break/misbehave if somehow a NEWLINE gets into the database.

  if {$glistEnd < $glstart} {
    set glistEnd $glstart
  }

  set c [expr $glistEnd - $glstart + 1]

  set chunk [sc_game list $glstart $c $glistCodes]
  # remove trailing "\n"
  set chunk [string range $chunk 0 end-1]

  set  VALUES [split $chunk "\n"]
  set i [llength $VALUES]

  # reverse insert for speed-up

  for {set line $glistEnd} {$line >= $glstart} {incr line -1} {
    incr i -1
    set values [lindex $VALUES $i]

    if {[catch {set thisindex [lindex $values 0]}]} {
      ### Mismatched brace in game values. Bad!
      # Scid's gamelist handles it ok, but game causes errors in other places
      set thisindex [string range $values 1 [string first " " $values]]
      $w.tree insert {} 0 -values [list $thisindex {Unmatched brace} {in game}] -tag [list click2 error]
    } else {
      if {$thisindex == "$current "} {
	set current_item [$w.tree insert {} 0 -values $values -tag [list click2 current]]
      } elseif {[lindex $values 12] == {D }} {
	$w.tree insert {} 0 -values $values -tag [list click2 deleted] ;#treefont
      } else {
	$w.tree insert {} 0 -values $values -tag click2
      }
    }
  }

  ## first and last attempts to work around it's hard to know how many lines fit in ttk::treeview
  ## but isnt working properly S.A
  # if {$see == {first}} 

  $w.tree see [lindex [.glistWin.tree children {}] 0]

  # if {$see == {last}} { $w.tree see [lindex [.glistWin.tree children {}] end] } 

  setGamelistTitle

  $w.vsb configure -to [expr $totalSize - $glistSize]

  configDeleteButtons
  ::windows::switcher::Refresh

  return $current_item
}

proc ::windows::gamelist::SetStart {unit} {
  global glstart

  set glstart [expr {int($unit)}]

  after cancel {::windows::gamelist::Refresh first}
  after idle {::windows::gamelist::Refresh first}
}

proc ::windows::gamelist::ToggleFlag {flag} {

  set items [.glistWin.tree selection]
  if { "$items" == "" } {
    bell
  } else {
    set sel [.glistWin.tree selection]
    foreach item $sel {
      # mark item as "flag"
      set number [.glistWin.tree set $item Number]
      catch {sc_game flag $flag $number invert}

      if {$flag == {D}} {
	# toggle treeview delete field
	set deleted [.glistWin.tree set $item Deleted]
	if {$deleted == {D }} {
	  set deleted {  }
	} else {
	  set deleted {D }
	}
	.glistWin.tree set $item Deleted $deleted
      } else {
	.glistWin.tree set $item Flags "[string map {D {}} [sc_flags $number]] "
      }
    }
    # ::windows::gamelist::Refresh
  }
}

### Remove rom filter all games above or below the selected item(s)

proc removeFromFilter {dir} {

  set items [.glistWin.tree selection]

  # in case of multiple items selected
  if {$dir == {up}} {
    set i [lindex $items 0]
  } else {
    set i [lindex $items end]
  }

  set gl_num [.glistWin.tree set $i Number]

  if {$gl_num < 1} { return }
  if {$gl_num > [sc_base numGames]} { return }
  if {$dir == {up}} {
    sc_filter remove 1 [expr $gl_num - 1]
  } else {
    sc_filter remove [expr $gl_num + 1] $::MAXGAME
  }

  ::windows::stats::Refresh
  ::windows::gamelist::Refresh
  ::windows::gamelist::showNum $gl_num nobell

  set ::windows::gamelist::finditems {}
  setGamelistTitle
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
    -wrap none -font font_Small -relief flat
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
  set text [sc_game list 1 5 "$glexport "]
  # remove trailing "\n"
  set text [string range $text 0 end-1]

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
  set res [catch {sc_game list 1 $::MAXGAME "$glexport\n" $fname} err]
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

