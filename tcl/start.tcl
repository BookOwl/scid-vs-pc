#!/bin/sh

# Scid vs. PC
#
# Based on Shane's Chess Information Database
#
# Copyright Steven Atkinson (stevenaaus@yahoo.com) , Pascal Georges, Shane Hudson
# Released under the GPL
# This is freely redistributable software; see the file named "COPYING"
# or "copying.txt" that came with this program.

# The next line restarts using tkscid: \
exec `dirname $0`/tkscid "$0" "$@"

# Alter the version if any patches have been made to the Tcl code only:
set scidVersion 4.7
set scidVersionDate {Jan 20, 2012}

# Set to 0 before releasing, so some alpha-state code is not included
# Set to 1 to have access to all code
set NOT_FOR_RELEASE 0

package require Tcl 8.5
package require Tk  8.5

# Determine operating system platform: unix or windows

set windowsOS	[expr {$tcl_platform(platform) == "windows"}]
set unixOS	[expr {$tcl_platform(platform) == "unix"}]

if {![catch {tk windowingsystem} wsystem] && $wsystem == "aqua"} {
  set macOS 1
  set scidName {Scid vs. Mac}
} else {
  set macOS 0
  set scidName {Scid vs. PC}
}

# See if we're inside a Mac .app bundle.  This duplcates part of the command-line
# parsing, which options should probably be done earlier, but I'm afraid to move
# things around that much - dr

if { $::macOS && ([string first "-psn" [lindex $argv 0]] == 0)} {
  # Remember that we were invoked in a MacOS app bundle
  set macApp 1
} else {
  set macApp 0
}

# Check that on Unix, the version of tkscid matches the version of this
# script or on Windows, that the scid.exe and scid.gui versions are identical.

if {[string compare [sc_info version] $scidVersion]} {
  wm withdraw .
  if {$windowsOS} {
    set msg "This is $::scidName version [sc_info version], but the scid.gui data\n"
    append msg "file has the version number $scidVersion.\n"
  } else {
    set msg "This is $::scidName version $scidVersion,\nbut the "
    append msg "tkscid program \nit uses is version [sc_info version].\n"
    append msg "Check that the path to tkscid is correct."
  }
  tk_messageBox -type ok -icon error -title "Scid: version error" -message $msg
  exit 1
}

#############################################################
#
# NAMESPACES
#
# The main Tcl/Tk namespaces used in the Scid application are
# initialized here, so that default values can be set up and
# altered when the user options file is loaded.
#
foreach ns {
  ::splash
  ::utils
  ::utils::date ::utils::font ::utils::history ::utils::pane ::utils::string
  ::utils::sound ::utils::validate ::utils::win
  ::file
  ::file::finder ::file::maint ::maint
  ::bookmarks
  ::edit
  ::game
  ::gbrowser
  ::search
  ::search::filter ::search::board ::search::header ::search::material
  ::windows
  ::windows::gamelist ::windows::stats ::tree ::tree::mask ::windows::tree
  ::windows::switcher ::windows::eco ::crosstab ::pgn ::book
  ::tools
  ::tools::analysis ::tools::email
  ::tools::graphs
  ::tools::graphs::filter ::tools::graphs::absfilter ::tools::graphs::rating ::tools::graphs::score
  ::tb ::optable
  ::board ::move
  ::tacgame ::sergame ::tactics ::calvar ::uci ::fics
  ::config
  ::commenteditor
} {
  namespace eval $ns {}
}

### ::pause is used as a semaphore by the trace command in tacgame (and fics)

set ::MAX_GAMES [sc_info limit games]
set ::pause 0
set ::defaultBackground white
set ::tacgame::threshold 0.9
set ::tacgame::blunderwarning false
set ::tacgame::blunderwarningvalue 0.0
set ::tacgame::levelMin 1200
set ::tacgame::levelMax 2200
set ::tacgame::levelFixed 1500
set ::tacgame::randomLevel 0
set ::tacgame::showblunder 1
set ::tacgame::showblundervalue 1
set ::tacgame::showblunderfound 1
set ::tacgame::showmovevalue 1
set ::tacgame::showevaluation 1
set ::tacgame::isLimitedAnalysisTime 1
set ::tacgame::analysisTime 10
set ::tacgame::openingType new
set ::tacgame::chosenOpening 0
set ::sergame::bookToUse {}
set ::sergame::useBook 1
set ::sergame::startFromCurrent 0
set ::sergame::timeMode movetime
set ::sergame::movetime 6
set ::sergame::current 0
set ::sergame::chosenOpening 0
set ::commenteditor::showBoard 0
set ::windows::gamelist::widths {}
set ::windows::gamelist::findcase 1
set ::windows::switcher::icons 1
set ::file::finder::data(dir) [pwd]
set ::file::finder::data(sort) name
set ::file::finder::data(recurse) 0
set ::file::finder::data(Scid) 1
set ::file::finder::data(PGN) 1
set ::file::finder::data(EPD) 1
set ::file::finder::data(Old) 1
set ::tools::graphs::absfilter::type year
set ::tools::graphs::filter::type year
set ::tools::graphs::showpoints 1
set ::addAnnotatorTag 1
set ::annotateMoves all
set ::annotateWithVars blunders
set ::annotateWithScore allmoves
set ::useAnalysisBook 0
set ::isAnnotateVar 0
set ::addAnnotatorComment 0
set ::maintFlag W
set ::glistFlag W
set ::gbrowser::size 35
set comp(timecontrol) pergame
set comp(seconds) 180
set comp(minutes) 1
set comp(incr) 0
set comp(timeout) 0 ;# disabled by default
set comp(name) $scidName
set comp(rounds) 2
set comp(showclock) 0
set comp(debug) 1 ; # print info to console
set comp(animate) 1
set comp(firstonly) 0
set comp(ponder) 0

### Tree/mask options:
set ::tree::mask::recentMask {}

#############################################################
# Customisable variables:

# scidExeDir: contains the directory of the Scid executable program.
# Used to determine the location of various relative data directories.
set scidExecutable [info nameofexecutable]

if {$scidExecutable == {}} {
  ### Shit. Wish8.6b2 returns {} 
  # I wonder if new tcl-8.5 works ok ?
  if {$unixOS} {
    catch {
      set scidExecutable [exec readlink /proc/[pid]/exe]
    }
    puts "scidExecutable is null. Now is \"$scidExecutable\"" 
  } else {
    puts "scidExecutable is null" 
  }
}

if {$scidExecutable == {}} {
  ### may work on windows, but will be broken on other OS
  set scidExeDir .
} else {
  if {[file type $scidExecutable] == "link"} {
    set scidExeDir [file dirname [file readlink $scidExecutable]]
    if {[file pathtype $scidExeDir] == "relative"} {
      set scidExeDir [file dirname [file join [file dirname $scidExecutable]\
	[file readlink $scidExecutable]]]
    }
  } else {
    set scidExeDir [file dirname $scidExecutable]
  }
}

# scidUserDir: location of user-specific Scid files.
# This is "~/.scid" on Unix, and the Scid exectuable dir on Windows.
if {$windowsOS} {
  set scidUserDir $scidExeDir
} else {
  set scidUserDir [file nativename "~/.scidvspc"]
}

# scidConfigDir, scidDataDir, scidLogDir:
#   Location of Scid configuration, data and log files.
set scidConfigDir [file nativename [file join $scidUserDir "config"]]
set scidDataDir [file nativename [file join $scidUserDir "data"]]
set scidLogDir [file nativename [file join $scidUserDir "log"]]

# boardSizes: a list of the available board sizes.
set boardSizes [list 25 30 35 40 45 50 55 60 65 70 75 80]
set boardSizesOLD [list 21 25 29 33 37 40 45 49 54 58 64 72]

#load textures for lite and dark squares
set boardfile_dark "emptySquare"
set boardfile_lite "emptySquare"

#[file join $scidExeDir "bitmaps" "empty.gif"] ;# wsquare.gif

# boardSize: Default board size. See the available board sizes above.
set boardSize 60

# language for help pages and messages:
set language E
set oldLang X

# Toolbar configuration:
foreach {tbicon status}  {
  new 0 open 0 save 1 close 0
  finder 0 bkm 1 gfirst 1 gprev 1 gnext 1 glast 1
  newgame 0 copy 0 paste 0
  rfilter 0 bsearch 0 hsearch 0 msearch 0
  glist 1 pgn 1 tmt 1 comment 0 maint 1 eco 0 tree 1 crosst 1 engine 1 book 1
} {
  set toolbar($tbicon) $status
}

# boardCoords: 1 to show board Coordinates, 0 to hide them.
set boardCoords 0

# boardSTM: 1 to show side-to-move icon, 0 to hide it.
set boardSTM 1

# Default values for fonts:
proc createFont {name} {
  set opts $::fontOptions($name)
  font create font_$name \
      -family [lindex $opts 0] -size [lindex $opts 1] \
      -weight [lindex $opts 2] -slant [lindex $opts 3]
}

proc configureFont {name} {
  set opts $::fontOptions($name)
  font configure font_$name \
      -family [lindex $opts 0] -size [lindex $opts 1] \
      -weight [lindex $opts 2] -slant [lindex $opts 3]
}

proc reinitFont {name} {
  set ::fontOptions($name) $::fontOptions(old$name)
  configureFont $name
}

if {$windowsOS} {
  set fontOptions(Regular) { Arial           10 normal roman}
  set fontOptions(Menu)    { {MS Sans Serif}  9 normal roman}
  set fontOptions(Small)   { Arial            9 normal roman}
  set fontOptions(Tiny)    { Arial            8 normal roman}
  set fontOptions(Fixed)   { Courier          9 normal roman}
} elseif {$macOS} {
  set fontOptions(Regular) { {Lucida Grande} 12 normal roman}
  set fontOptions(Menu)    { {Lucida Grande} 14 normal roman}
  set fontOptions(Small)   { {Lucida Grande} 11 normal roman}
  set fontOptions(Tiny)    { {Lucida Grande} 10 normal roman}
  set fontOptions(Fixed)   { Monaco 10 normal roman}
} else {
  set fontOptions(Regular) { helvetica 11 normal roman}
  set fontOptions(Menu)    { helvetica 10 normal roman}
  set fontOptions(Small)   { helvetica 10 normal roman}
  set fontOptions(Tiny)    { helvetica  9 normal roman}

  # try a couple of fonts, and default to "fixed" if no luck
  if {[lsearch [font families] {Liberation Mono}] > 0} {
    set fontOptions(Fixed)   { {Liberation Mono} 11 normal roman}
  } elseif {[lsearch [font families] {Courier 10 Pitch}] > 0} {
    set fontOptions(Fixed)         { {Courier 10 Pitch} 12 normal roman}
  } else {
    set fontOptions(Fixed)   { fixed 11 normal roman}
  }
}

createFont Regular
createFont Menu
createFont Small
createFont Tiny
createFont Fixed

# Analysis command: to start chess analysis engine.
set analysisCommand ""
if {$windowsOS} {
  set analysisChoices {wcrafty.exe}
} else {
  set analysisChoices {crafty}
}
set analysis(mini) 0
set analysis(logEngines) 1

# Colors: dark and lite are square colors
#   whitecolor/blackcolor are piece colors (unused)
#   highcolor is the color when something is selected.
#   bestcolor is used to indicate a suggested move square.
#   bgcolor   is the canvas bgcolor, and appears as the lines between the squares
#   progcolor is progress bar colour
#   maincolor is Main line arrow color
#   varcolor  is Variation arrow colors

set lite {#f3f3f3}
set dark {#7389b6}
set whitecolor  {#ffffff}
set blackcolor  {#000000}
set whiteborder {#000000}
set blackborder {#ffffff}
set highcolor   {#b0d0e0}
set bestcolor   {#bebebe}
set bgcolor	grey20
set progcolor   rosybrown
set buttoncolor {#b0c0d0}
set borderwidth 1
set maincolor black
set varcolor grey80

set ::tactics::analysisTime 3

# Defaults for the PGN window:
# if ::pgn::showColor is 1, the PGN text will be colorized.
set ::pgn::showColor 1
set ::pgn::indentVars 1
set ::pgn::indentComments 1
set ::pgn::symbolicNags 1
set ::pgn::moveNumberSpaces 0
set ::pgn::shortHeader 0
set ::pgn::boldMainLine 0
set ::pgn::columnFormat 0
set ::pgn::stripMarks 0
set ::pgn::showScrollbar 0
set pgnColor(Header) "\#00008b"
set pgnColor(Main) "\#000000"
set pgnColor(Var) "\#0000ee"
set pgnColor(Nag) "\#aa2c2c" ;# ee0000
set pgnColor(Comment) "\#008b00"
set pgnColor(Current) lightSteelBlue
set pgnColor(NextMove) "\#fefe80"
set pgnColor(Background) "\#ffffff"

array set findopponent {}
set ::fics::use_timeseal 0
set ::fics::timeseal_exec "timeseal"
set ::fics::port_fics 5000
set ::fics::port_timeseal 5001
set ::fics::login ""
set ::fics::password ""
set ::fics::findopponent(initTime) 15
set ::fics::findopponent(incTime) 20
set ::fics::findopponent(rated) "rated"
set ::fics::findopponent(color) ""
set ::fics::findopponent(limitrating) 1
set ::fics::findopponent(rating1) 1000
set ::fics::findopponent(rating2) 1500
set ::fics::findopponent(manual) "manual"
set ::fics::findopponent(formula) ""
set ::fics::consolebg	grey35
set ::fics::consolefg	LimeGreen
set ::fics::silence	1
set ::fics::shouts	1
set ::fics::server_ip   0.0.0.0
set ::fics::autopromote 0
set ::fics::smallclocks 0
set ::fics::size        30

# Defaults for initial directories:
set initialDir(base) "."
set initialDir(pgn) "."
set initialDir(book) "."
set initialDir(epd) "."
set initialDir(html) "."
set initialDir(tex)  "."
set initialDir(stm)  "."
set initialDir(sso)  "."
set initialDir(report) "."
set initialDir(tablebase1) ""
set initialDir(tablebase2) ""
set initialDir(tablebase3) ""
set initialDir(tablebase4) ""

# glistSize: Number of games displayed in the game list window
set glistSize 15

# glexport: Format for saving Game List to text file.
set glexportDefault "g6: w13 W4  b13 B4  r3:m2 y4 s11 o4"
set glexport $glexportDefault

# glistSelectPly: The number of moves to display in a game list entry
# when that entry is selected with button-2 to shoe the first moves
# of a game. E.g., a value of 4 might give: "1.e4 e5 2.Nf3 Nc6".
set glistSelectPly 80


# Default window locations:
foreach i {. .pgnWin .helpWin .crosstabWin .treeWin .commentWin .glist \
      .playerInfoWin .baseWin .treeBest .tourney .finder \
      .ecograph .statsWin .glistWin .maintWin .nedit} {
  set winX($i) -1
  set winY($i) -1
}

for {set b 1} {$b<=[sc_base count total]} {incr b} {
  foreach i {.treeWin .treeBest} {
    set winX($i$b) -1
    set winY($i$b) -1
  }
}

# Default PGN window size:
set winWidth(.pgnWin)  65
set winHeight(.pgnWin) 20

# Default help window size:
set winWidth(.helpWin)  50
set winHeight(.helpWin) 32

# Default stats window size:
set winWidth(.statsWin) 60
set winHeight(.statsWin) 13

# Default crosstable window size:
set winWidth(.crosstabWin)  75
set winHeight(.crosstabWin) 15

# Default tree window size:
set winWidth(.treeWin)  58
set winHeight(.treeWin) 20

# Default comment editor size:
set winWidth(.commentWin)  40
set winHeight(.commentWin)  6

# Default spellcheck results window size:
set winWidth(.spellcheckWin)  55
set winHeight(.spellcheckWin) 25

# Default player info window size:
set winWidth(.playerInfoWin)  45
set winHeight(.playerInfoWin) 20

# Default switcher window size:
set winWidth(.baseWin) 310
set winHeight(.baseWin) 110

# Default Correspondence Chess window size:
set winWidth(.ccWindow) 10
set winHeight(.ccWindow) 20

# Default stats window lines:
array set ::windows::stats::display {
  r2600 1
  r2500 1
  r2400 1
  r2300 1
  r2200 0
  r2100 0
  r2000 0
  y1900 0
  y1950 0
  y1960 0
  y1970 0
  y1980 0
  y1990 0
  y2000 1
  y2002 1
  y2004 1
  y2006 1
  y2007 1
  y2008 1
  y2009 1
  y2010 1
  y2011 1
}

# Default PGN display options:
set pgnStyle(Tags) 1
set pgnStyle(Comments) 1
set pgnStyle(Vars) 1


# Default Tree sort method:
set tree(order) frequency

# Auto-save tree cache when closing tree window:
set tree(autoSave) 0

# Auto-save options when exiting:
set optionsAutoSave 1

#  Numeric locale: first char is decimal, second is thousands.
#  Example: ".," for "1,234.5" format; ",." for "1.234,5" format.
set locale(numeric) ".,"

# Ask for piece translations (first letter)
set translatePieces 1

# Hightlight the last move played
set highlightLastMove 1
set highlightLastMoveWidth 2
set highlightLastMoveColor "grey"
set highlightLastMovePattern {} ; # this option is not saved

# Ask before replacing existing moves: on by default
set askToReplaceMoves 1

# Show suggested moves
set suggestMoves 0

# Show variations popup window, arrows
set showVarPopup 0
set showVarArrows 1

# Keyboard Move entry options:
set moveEntry(On) 1
set moveEntry(AutoExpand) 0
set moveEntry(Coord) 1

# Autoplay and animation delays in milliseconds:
set autoplayDelay 5000
set animateDelay 200

# Blunder Threshold
set blunderThreshold 1.0

# Geometry of windows:
array set geometry {}

#   Which windows should be opened on startup
set startup(pgn) 0
set startup(switcher) 0
set startup(tip) 0
set startup(tree) 0
set startup(finder) 0
set startup(crosstable) 0
set startup(gamelist) 0
set startup(stats) 0
set startup(book) 0

# myPlayerNames:
#   List of player name patterns for which the chessboard should be
#   flipped each time a game is loaded to show the board from that
#   players perspective.

set myPlayerNames {}

# These new checkbuttons (showMenu, showButtons etc) don't really have anything
# to do with gameInfo, but are here anyway S.A

set gameInfo(show) 1
set gameInfo(photos) 1
set gameInfo(hideNextMove) 0
set gameInfo(showMaterial) 1
set gameInfo(showFEN) 0
set gameInfo(showButtons) 1
set gameInfo(showStatus) 1
set gameInfo(showMenu) 1
set gameInfo(showTool) 1
set gameInfo(showMarks) 1
set gameInfo(wrap) 0
set gameInfo(fullComment) 0
set gameInfo(showTB) 0
if {[sc_info tb]} { set gameInfo(showTB) 2 }

# Twin deletion options:

array set twinSettings {
  players No
  colors  No
  event   No
  site    Yes
  round   Yes
  year    Yes
  month   Yes
  day     No
  result  No
  eco     No
  moves   Yes
  skipshort  Yes
  setfilter  Yes
  undelete   Yes
  comments   Yes
  variations Yes
  usefilter  No
  delete     Shorter
}
array set twinSettingsDefaults [array get twinSettings]

# Opening report options:
array set optable {
  Stats 1
  Oldest 5
  Newest 5
  Popular 1
  MostFrequent 6
  MostFrequentWhite 1
  MostFrequentBlack 1
  AvgPerf 1
  HighRating 8
  Results 1
  Shortest 5
  ShortestWhite 1
  ShortestBlack 1
  MoveOrders 8
  MovesFrom 1
  Themes 1
  Endgames 1
  MaxGames 500
  ExtraMoves 1
}
array set optableDefaults [array get optable]

# Player report options
array set preport {
  Stats 1
  Oldest 5
  Newest 5
  MostFrequentOpponents 6
  AvgPerf 1
  HighRating 8
  Results 1
  MostFrequentEcoCodes 6
  Themes 1
  Endgames 1
  MaxGames 500
  ExtraMoves 1
}
array set preportDefaults [array get preport]

# Export file options:
set exportFlags(comments) 1
set exportFlags(indentc) 0
set exportFlags(vars) 1
set exportFlags(indentv) 1
set exportFlags(column) 0
set exportFlags(append) 0
set exportFlags(symbols) 0
set exportFlags(htmldiag) 0
set exportFlags(stripMarks) 0
set exportFlags(convertNullMoves) 1
set default_exportStartFile(PGN) {}
set default_exportEndFile(PGN) {}

set default_exportStartFile(LaTeX) {\documentclass[10pt,twocolumn]{article}
  % This is a LaTeX file generated by Scid.
  % You must have the "chess12" package installed to typeset this file.

  \usepackage{times}
  \usepackage{a4wide}
  \usepackage{chess}
  \usepackage[T1]{fontenc}
  \usepackage{latexsym}

  \setlength{\columnsep}{7mm}
  \setlength{\parindent}{0pt}

  % Macros for variations and diagrams:
  \newenvironment{variation}{\begin{quote}}{\end{quote}}
  \newenvironment{diagram}{\begin{nochess}}{$$\showboard$$\end{nochess}}

  \begin{document}
}
set default_exportEndFile(LaTeX) {\end{document}
}


set default_exportStartFile(HTML) {<html>
  <head><title>Scid export</title></head>
  <body bgcolor="#ffffff">
}
set default_exportEndFile(HTML) {</body>
  </html>
}

foreach type {PGN HTML LaTeX} {
  set exportStartFile($type) $default_exportStartFile($type)
  set exportEndFile($type) $default_exportEndFile($type)
}


# autoRaise: defines whether the "raise" command should be used to raise
# certain windows (like progress bars) when they become obscured.
# Some Unix window managers (e.g. some versions of Enlightenment and sawfish,
# so I have heard) have a bug where the Tcl/Tk "raise" command times out
# and takes a few seconds. Setting autoRaise to 0 will help avoid this.

# The above mentioned "1 second" bug is relevant to kde1 i think.
# Kde 3.5 (and WinXP) have focus stealing code that stops "raise"
# from working by default. In kde this can be changed by
# configuring "desktop > window behavior > advanced > focus stealing prevention"
# to "none"

set autoRaise 1

proc raiseWin {w} {
  global autoRaise
  if {$autoRaise} {
    wm deiconify $w
    raise $w
    focus $w
  }
  return
}

# autoIconify:
#   Specified whether Scid should iconify all other Scid windows when
#   the main window is iconified. Most people like this behaviour but
#   some window managers send an "UnMap" event when the user switches
#   to another virtual window without iconifying the Scid window so
#   users of such managers will probably want to turn this off.

set autoIconify 1

proc toggleToolbar {} {
  if {$::gameInfo(showTool)} {
    grid .tb -row 0 -column 0 -columnspan 3 -sticky we
  } else {
    grid forget .tb
  }
}

proc toggleMenubar {} {
  set ::gameInfo(showMenu) [expr !$::gameInfo(showMenu)]
  showMenubar
}

proc showMenubar {} {
  if {!$::gameInfo(showMenu)} {
    . configure -menu {}
  } else {
    . configure -menu .menu
  }
}

proc toggleButtonBar {} {
  if {!$::gameInfo(showButtons)} {
    grid remove .button
  } else {
    grid configure .button -row 1 -column 0 -pady 5 -padx 5
  }
}

proc toggleStatus {} {
  if {!$::gameInfo(showStatus)} {
    grid remove .statusbar
  } else {
    grid configure .statusbar -row 4 -column 0 -columnspan 3 -sticky we
  }
}

proc toggleGameInfo {} {
  set ::gameInfo(show) [expr ! $::gameInfo(show)]
  showGameInfo
}

proc showGameInfo {} {
  if {$::gameInfo(show)} {
    grid .gameInfoFrame -row 3 -column 0 -sticky nsew -padx 2
  } else  {
    grid forget .gameInfoFrame
  }
  update idletasks
}

# Email configuration

set email(logfile) [file join $scidLogDir "scidmail.log"]
set email(smtp) 1
set email(smproc) "/usr/lib/sendmail"
set email(server) localhost
set email(from) ""
set email(bcc) ""

# Sound options

set ::utils::sound::announceNew 0
set ::utils::sound::announceForward 0
set ::utils::sound::announceBack 0
set ::utils::sound::soundFolder {} ;# disabled by default

set ::book::lastBook1 {} ; # book name without extension (.bin)
set ::book::lastBook2 {}
set ::book::lastTuning {}
set ::book::sortAlpha 0
set ::book::showTwo 0
set ::book::oppMovesVisible 0

# Engines list file: -- OLD NAMES, NO LONGER USED
#set engines(file) [file join $scidUserDir "engines.lis"]
#set engines(backup) [file join $scidUserDir "engines.bak"]

# Engines data:
set engines(list) {}
set engines(sort) Time
set engines(F2)  1
set engines(F3)  2
set engines(F4)  {}

proc resetInformants {} {
  global informant
  array set informant {}
  set informant("!?")  0.5
  set informant("?")   1.5
  set informant("??")  3.0
  set informant("?!")  0.5
  set informant("+=")  0.5
  set informant("+/-") 1.5
  set informant("+-")  3.0
  set informant("++-") 5.5
}

resetInformants

# Nice icon from OSX,
# ... but it doesn't antialias well in the text widget !%^&*

image create photo icon -format gif -data {
R0lGODlhLwAvAOf/AA4OIAQNQgQNSAYPOAYPPQ0PKg4NOBcPFQ4LQw8QMBAN
PggOUAARVxEMSgkOVx0SDRARNhQSKCQTBQwRUw0XNhYWJhATTxkUNREWRi4V
AhUZMwkXXxMUVx0ZIQsYWR8bGhgXWxkeMzMaAhIcXiMeJx0cQyUiEhQeWjgd
AR4hPCsiFCoiGT4dAB4eVh8gUhogYyImMSEfXioqIx4lYjIrD0YkACkqMSQn
UycmX04nADkxFVIpAk8rATwzDiYuZj40BzczIzEuT1UrADQzMVAxAFgtADEv
YFAxDV0tAlUwCjQ4OlkvClgyAEQ6DS41Z2AvAFEzFjczXVoxCVY4ADM3ZVA3
F2IxB083HmQyAUo5J0s/Blg1Hkc8KEE5S007I2c1BDs7XF47AEg+LkQ/NFU5
Kmo3AEk6TD1EQFREBFk7J2c6Bzw+Zz9DRUNDO2Y7D0dBS1E9RldIAERGQ1Y+
PUFFV19GAE1DQ0JFY2hAHExHRnBCAGVDHURMSF1NAEJNTmhJAF1OBVZKNVRL
QGNIKEhMX0hLbGRTAmFSEHhKAEhTU2hSBG1RAFNMYlJPXkxVUElRbmhXAGxV
AGpPM2ZSOmVXI2lTNmtaDGFWPm5cAlBbXGJXR3FeAFJeXndfAIRZAGFdTmhb
RnZjAGRbYGFdXltjX3pmBYNkAFxjcGhhW31pAFxnaF1kd21mVHppKoNtAm5o
XGFsbWRsaIpuAIhxAINvHHVuVWdvdm9uZo9zAJNxAI12AW50aox2EJ9wAJB4
AH9zS5F5BpN7AKN0AJh6AIt4M5Z+AJqBBKJ9BZeAHZ2DAI1/UaCGAKSEAJ6F
C5WBO6OIAJ+GGqWKA5yGM7GEBpeFTJ6JJaiNAKyLAK2RALOQAaOOSLGUBLeU
ALqRCLCUFrSXALWYDLOXKrqcAL6aALyeBMGcBsOdAMGhAMiiAL+iLMKjH8en
AsylBM+oAMKlNdOsANeuAsytK9iwBtqxANSyDt+1AOK4AOm9AOW9De7CAPLF
APXHAPjKAPvMAP7PAP///yH5BAEKAP8ALAAAAAAvAC8AAAj+AP8JHEiw4MBb
X5gMQ/fuHbyHD98tS5bMmMWLxcyx24jOnMGPBfcgWTSuYT15J+nRK7esJbOJ
FJMtW0dzXbtzIHOCKkMkVbFm0b59O9eu3btszCompVhsWLZ3RduxQ5fz4y03
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
}

wm iconphoto . -default icon

# Opening files by drag & drop on Scid icon on Mac
if { $macOS } {
  # Drag & Drop
  set dndisbusy 0
  set isopenBaseready 0
  set dndargs 0

  proc dragndrop {args} {
    global dndisbusy
    global isopenBaseready
    global dndargs

    # Un-nest arguments:
    set args [join $args]

    # Wait for openBase to be ready, if needed.
    if {$isopenBaseready == 0} {
      if {$dndargs != 0} {
        tk_messageBox -type ok -icon info -title "Scid" -message \
            "Please, wait until Scid finish starting up."
        return
      } else {
        # Save file names for later use:
        set dndargs $args
      }
      return
    }

    # Are we busy opening files? if so, display message and do nothing
    if {$dndisbusy != 0} {
      tk_messageBox -type ok -icon info -title "Scid" -message \
          "Please, wait until the previou(s) database(s) are opened and try again."
      return
    }

    # Un-nest argumens again if Scid opened on drag & drop
    if {$isopenBaseready == 2} {
      # Un-nest arguments:
      set args [join $args]
      set isopenBaseready 1
    }

    set dndisbusy 1
    set errmsg ""
    foreach file $args {
      # Check for available slots:
      if {[sc_base count free] == 0} {
        tk_messageBox -type ok -icon info -title "Scid" \
            -message "Too many databases are open; close at least one \n\
            before opening more databases"
        #::splash::add "No slot available."
        return
      }
      # Email File:
      if {[file extension $file] == ".sem"} {
        #::tools::email
        continue
      }
      # SearchOptions file:
      if {[file extension $file] == ".sso"} {
        set ::fName $file
        if {[catch {uplevel "#0" {source $::fName}} errmsg]} {
          tk_messageBox -title "Scid: Error reading file" -type ok -icon warning \
              -message "Unable to open or read SearchOptions file: $file"
        } else {
          switch -- $::searchType {
            "Material" { ::search::material }
            "Header"   { ::search::header }
            default    { continue }
          }
        }
        continue
      }
      # Scid doesn't handle well .sg4 and .sn4 files.
      if {([file extension $file] == ".sg4") || \
            ([file extension $file] == ".sn4")} {
        set eName ".si4"
        set fName [file rootname $file]
        set file "$fName$eName"
      }
      # Scid doesn't handle well .sg3 and .sn3 files.
      if {([file extension $file] == ".sg3") || \
            ([file extension $file] == ".sn3")} {
        set eName ".si3"
        set fName [file rootname $file]
        set file "$fName$eName"
      }
      # Check if base is already opened
      if {[sc_base slot $file] != 0} {
        tk_messageBox -type ok -icon info -title "Scid" -message \
            "$file is already opened."
      } else  {
        # All seems good, let's open those files:
        catch {::file::Open $file} errmsg
      }
    }
    set dndisbusy 0
    set dndargs 0
  }
  proc tkOpenDocument {args} {
    after idle [list dragndrop $args]
  }
  rename tkOpenDocument ::tk::mac::OpenDocument
}

# Add empty updateStatusBar proc to avoid errors caused by early
# closing of the splash window:
#
proc updateStatusBar {} {}

set ::splash::keepopen 1
set ::splash::cache {}

# the function gets redfined once the fonts have been read from options.dat

proc ::splash::add {text {tag {indent}}} {
  lappend ::splash::cache $text
}

# Remember old font settings before loading options file:
set fontOptions(oldRegular) $fontOptions(Regular)
set fontOptions(oldMenu) $fontOptions(Menu)
set fontOptions(oldSmall) $fontOptions(Small)
set fontOptions(oldTiny) $fontOptions(Tiny)
set fontOptions(oldFixed) $fontOptions(Fixed)

# New configuration file names:
set scidConfigFiles(options)     options.dat
set scidConfigFiles(engines)     engines.dat
set scidConfigFiles(engines.bak) engines.dat
set scidConfigFiles(recentfiles) recent.dat
set scidConfigFiles(history)     history.dat
set scidConfigFiles(bookmarks)   bookmarks.dat
set scidConfigFiles(reports)     reports.dat
set scidConfigFiles(optrainer)   optrainer.dat

set ecoFile {}

# scidConfigFile:
#   Returns the full path and name of a Scid configuration file,
#   given its configuration type.
#
proc scidConfigFile {type} {
  global scidConfigDir scidConfigFiles
  if {! [info exists scidConfigFiles($type)]} {
    return -code error "No such config file type: $type"
  }
  return [file nativename [file join $scidConfigDir $scidConfigFiles($type)]]
}

# Create user ".scid" directory in Unix if necessary:
# Since the options file used to be ".scid", rename it:
if {! [file isdirectory $scidUserDir]} {
  if {[catch {file mkdir $scidUserDir} err]} {
    ::splash::add "Error creating $scidUserDir directory: $err" error
  } else {
    catch {file rename "$scidUserDir.old" $optionsFile}
  }
}

# Create the config, data and log directories if they do not exist:
proc makeScidDir {dir} {
  if {! [file isdirectory $dir]} {
    if {[catch {file mkdir $dir} err]} {
      ::splash::add "Error creating directory $dir: $err" error
    } else {
      ::splash::add "Created directory: $dir"
    }
  }
}

makeScidDir $scidConfigDir
makeScidDir $scidDataDir
makeScidDir $scidLogDir

# moveOldConfigFiles removed S.A

set optionsFile [scidConfigFile options]

::splash::add "Command line is \"$::argv0 $::argv\""
::splash::add "User directory is \"$scidUserDir\""

# set board piece style

if { [catch { package require img::png } ] } {
  ::splash::add "TkImg not found. Most piece sets are disabled."
  set png_image_support 0
  set boardStyle Alpha
} else {
  ::splash::add "TkImg found. Enabling png image support."
  set png_image_support 1
  set boardStyle Merida1
}

set useGraphFigurine 1

if {[catch {source $optionsFile} ]} {
  ::splash::add "Error loading options file \"$optionsFile\"" error
} else {
  ::splash::add "Loaded options from \"$optionsFile\"."
}

# Reconfigure fonts if necessary

foreach i {Regular Menu Small Tiny Fixed} {
  if {$fontOptions($i) == $fontOptions(old$i)} {
    # Old font format in options file, or no file. Extract new options:
    set fontOptions($i) {}
    lappend fontOptions($i) [font actual font_$i -family]
    lappend fontOptions($i) [font actual font_$i -size]
    lappend fontOptions($i) [font actual font_$i -weight]
    lappend fontOptions($i) [font actual font_$i -slant]
  } else {
    # New font format in options file:
    configureFont $i
  }
}

# make font_Regular the default font for widgets

set fd_size [font actual font_Regular -size]
option add *Font font_Regular
option add *Text*background $defaultBackground widgetDefault
option add *Menu*Font font_Menu
# option add *Menubutton*Font font_Menu
if {$unixOS} {
  option add Scrollbar*borderWidth 1
}

### Fonts now fully configure :> S.A

# Start up splash screen:

proc ::splash::make {} {
  wm withdraw .
  set w [toplevel .splash]
  wm withdraw $w
  wm protocol $w WM_DELETE_WINDOW [list wm withdraw $w]
  wm title $w "Welcome to $::scidName $::scidVersion"
  frame $w.f
  frame $w.b
  text $w.t -height 15 -width 55 -cursor top_left_arrow \
       -font font_Regular -wrap word \
      -yscrollcommand [list $w.ybar set] -setgrid 1
  scrollbar $w.ybar -command [list $w.t yview]
  checkbutton $w.auto -text "Keep open after startup" \
      -variable ::splash::keepopen -font font_Small -pady 5 -padx 5
  button $w.dismiss -text Close -width 8 -command [list wm withdraw $w] \
      -font font_Small
  pack $w.f -side top -expand yes -fill both
  pack $w.b -side top -fill x
  pack $w.auto -side left -in .splash.b -pady 2 -ipadx 10 -padx 10
  pack $w.dismiss -side right -in .splash.b -pady 2 -ipadx 10 -padx 10
  pack $w.ybar -in $w.f -side right -fill y
  pack $w.t -in $w.f -side left -fill both -expand yes

  # Centre the splash window:
  update idletasks
  set x [expr {[winfo screenwidth $w]/2 - [winfo reqwidth $w]/2 \
        - [winfo vrootx .]}]
  set y [expr {[winfo screenheight $w]/2 - [winfo reqheight $w]/2 \
        - [winfo vrooty .]}]
  wm geom $w +$x+$y
  wm deiconify $w

  bind $w <F1> {helpWindow Contents}
  bind $w <Escape> {.splash.dismiss invoke}

  $w.t tag configure indent -lmargin2 20
  $w.t tag configure error -foreground red
  $w.t tag configure scid_title -font {Arial 24 normal} -foreground darkslateblue

  $w.t insert end "        $::scidName     " scid_title
  $w.t image create end -image icon -padx 20 -pady 10
}

# new logo from www.vitualpieces.net

::splash::make

proc ::splash::add {text {tag {indent}}} {
  if {[winfo exists .splash]} {
    .splash.t insert end "\n$text" $tag
    if {$tag == {error}} {
      puts stderr $text
    }
    update
  }
}

::splash::add "$::scidName $::scidVersion ($::scidVersionDate)."
::splash::add "http://scidvspc.sourceforge.net"
::splash::add ""
::splash::add "(C) 2008-2011 Steven Atkinson (stevenaaus@yahoo.com)"
::splash::add "(C) 2006-2008 Pascal Georges"
::splash::add "(C) 1999-2004 Shane Hudson"
::splash::add ""

# add cached splash comments
foreach line $::splash::cache {
  ::splash::add $line
}

# A lot of code assumes tcl_platform is either windows or unix, so
# lotsa stuff may break if this is not the case.

::splash::add "Using Tcl/Tk version: [info patchlevel] , \"$tcl_platform(platform)\" operating system."
if {(! $windowsOS)  &&  (! $unixOS)} {
  ::splash::add "Operating System may not be supported"
}

### Workaround a bug in Wish 8.5.10 ttk::scale.
# To trigger, press Control-l three times and try to move y scrollbar

set buggyttk [expr {[info patchlevel] == {8.5.10}}]
if {$buggyttk} {
      ::splash::add "Warning - Disabling Tk-8.5.10's buggy ttk::scale widget." error
}


# Check board size is valid:
set newSize [lindex $boardSizes 0]
foreach sz $boardSizes {
  if {$boardSize >= $sz} { set newSize $sz }
}
set boardSize $newSize

# Check for old (single-directory) tablebase option:
if {[info exists initialDir(tablebase)]} {
  set initialDir(tablebase1) $initialDir(tablebase)
}

# Set the radiobutton and checkbutton background color if desired.
# I find the maroon color on Unix ugly!
if {$unixOS} {
  option add *Radiobutton*selectColor $buttoncolor
  option add *Checkbutton*selectColor $buttoncolor
  option add *Menu*selectColor $buttoncolor
}

set fontsize [font configure font_Regular -size]
set font [font configure font_Regular -family]

font create font_Bold -family $font -size $fontsize -weight bold
font create font_BoldItalic -family $font -size $fontsize -weight bold \
    -slant italic
font create font_Italic -family $font -size $fontsize -slant italic
font create font_H1 -family $font -size [expr {$fontsize + 16} ] -weight bold
font create font_H2 -family $font -size [expr {$fontsize + 6} ] -weight bold
font create font_H3 -family $font -size [expr {$fontsize + 4} ] -weight bold
font create font_H4 -family $font -size [expr {$fontsize + 2} ] -weight bold
font create font_H5 -family $font -size [expr {$fontsize + 0} ] -weight bold

set fontsize [font configure font_Small -size]
set font [font configure font_Small -family]
font create font_SmallBold -family $font -size $fontsize -weight bold
font create font_SmallItalic -family $font -size $fontsize -slant italic

## ttk init
# Gregor's code to give readonly combos/enrties/spinboxes a non-grey background
set fbg {}
switch "_$::ttk::currentTheme" {
   _alt     { set fbg [list readonly white disabled [ttk::style lookup $::ttk::currentTheme -background]] }
   _clam    { set fbg [list readonly white {readonly focus} [ttk::style lookup $::ttk::currentTheme -selectbackground]] }
   _default { set fbg [list readonly white disabled [ttk::style lookup $::ttk::currentTheme -background]] }
}
if {[llength $fbg]} {
   ttk::style map TCombobox -fieldbackground $fbg
   ttk::style map TEntry -fieldbackground $fbg
   if {[info tclversion] >= "8.6"} { 
      ttk::style map TSpinbox -fieldbackground $fbg
   }
}

# Start in the clipbase, if no database is loaded at startup.
sc_base switch clipbase

###
### End of file: start.tcl
