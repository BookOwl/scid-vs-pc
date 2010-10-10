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
set scidName {Scid vs. PC}
set scidVersion 4.0
set scidVersionDate {July 1, 2010}

# Set to 0 before releasing, so some alpha-state code is not included
# Set to 1 to have access to all code
set NOT_FOR_RELEASE 0

package require Tcl 8.5
package require Tk  8.5

# Determine operating system platform: unix or windows

set windowsOS	[expr {$tcl_platform(platform) == "windows"}]
set unixOS	[expr {$tcl_platform(platform) == "unix"}]

set macOS 0
if {![catch {tk windowingsystem} wsystem] && $wsystem == "aqua"} { set macOS 1 }

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
  ::windows::gamelist ::windows::stats ::tree ::windows::tree
  ::windows::switcher ::windows::eco ::crosstab ::pgn ::book
  ::tools
  ::tools::analysis ::tools::email
  ::tools::graphs
  ::tools::graphs::filter ::tools::graphs::absfilter ::tools::graphs::rating ::tools::graphs::score
  ::tb ::optable
  ::board ::move
  ::tacgame ::sergame ::opening ::tactics ::calvar ::uci ::fics
  ::config
  ::commenteditor
} {
  namespace eval $ns {}
}

### ::pause is used as a semaphore by the trace command in tacgame (and fics)

set ::pause 0
set ::defaultBackground white
set ::tacgame::threshold 0.9
set ::tacgame::blunderwarning false
set ::tacgame::blunderwarningvalue 0.0
set ::tacgame::levelMin 1200
set ::tacgame::levelMax 2200
set ::tacgame::levelFixed 1500
set ::tacgame::randomLevel 0
set ::tacgame::isLimitedAnalysisTime 1
set ::tacgame::showblunder 1
set ::tacgame::showblundervalue 1
set ::tacgame::showblunderfound 1
set ::tacgame::showmovevalue 1
set ::tacgame::showevaluation 1
set ::tacgame::isLimitedAnalysisTime 1
set ::tacgame::analysisTime 10
set ::tacgame::openingType new
set ::commenteditor::showBoard 0
set ::windows::gamelist::widths {}
set ::windows::gamelist::findcase 1

#############################################################
# Customisable variables:

# scidExeDir: contains the directory of the Scid executable program.
# Used to determine the location of various relative data directories.
set scidExecutable [info nameofexecutable]
if {[file type $scidExecutable] == "link"} {
  set scidExeDir [file dirname [file readlink $scidExecutable]]
  if {[file pathtype $scidExeDir] == "relative"} {
    set scidExeDir [file dirname [file join [file dirname $scidExecutable]\
      [file readlink $scidExecutable]]]
  }
} else {
  set scidExeDir [file dirname $scidExecutable]
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

# boardStyle: Default board piece set. See bitmaps.tcl for styles.
set boardStyle Alpha

# language for help pages and messages:
set language E
set oldLang X

# Toolbar configuration:
foreach {tbicon status}  {
  new 1 open 1 save 1 close 1
  finder 1 bkm 1 gprev 1 gnext 1
  cut 0 copy 0 paste 0
  rfilter 1 bsearch 1 hsearch 1 msearch 1
  switcher 1 glist 1 pgn 1 tmt 1 maint 1 eco 1 tree 1 crosst 1 engine 1
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
  set fontOptions(Regular) [list Arial           10 normal roman]
  set fontOptions(Menu)    [list {MS Sans Serif}  9 normal roman]
  set fontOptions(Small)   [list Arial            9 normal roman]
  set fontOptions(Tiny)    [list Arial            8 normal roman]
  set fontOptions(Fixed)   [list Courier          9 normal roman]
} elseif {$macOS} {
  set fontOptions(Regular) [list system    11 normal roman]
  set fontOptions(Menu)    [list menu      14 normal roman]
  set fontOptions(Small)   [list system    10 normal roman]
  set fontOptions(Tiny)    [list system     9 normal roman]
  set fontOptions(Fixed)   [list Monaco    10 normal roman]
} else {
  set fontOptions(Regular) [list helvetica 11 normal roman]
  set fontOptions(Menu)    [list helvetica 10 normal roman]
  set fontOptions(Small)   [list helvetica 10 normal roman]
  set fontOptions(Tiny)    [list helvetica  9 normal roman]
  set fontOptions(Fixed)   [list {courier 10 pitch} 12 normal roman]
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

# Colors: dark and lite are square colors
#   whitecolor/blackcolor are piece colors (unused)
#   highcolor is the color when something is selected.
#   bestcolor is used to indicate a suggested move square.
#   bgcolor   is the canvas bgcolor, and appears as the lines between the squares
#   progcolor is progress bar colour
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

set ::tactics::analysisTime 3

# Defaults for the PGN window:
# if ::pgn::showColor is 1, the PGN text will be colorized.
set ::pgn::showColor 1
set ::pgn::indentVars 1
set ::pgn::indentComments 1
set ::pgn::symbolicNags 1
set ::pgn::moveNumberSpaces 0
set ::pgn::shortHeader 0
set ::pgn::boldMainLine 1
set ::pgn::columnFormat 0
set ::pgn::stripMarks 0
set pgnColor(Header) "\#00008b"
set pgnColor(Main) "\#000000"
set pgnColor(Var) "\#0000ee"
set pgnColor(Nag) "\#ee0000"
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
set ::fics::findopponent(manual) "auto"
set ::fics::findopponent(formula) ""
set ::fics::consolebg	grey35
set ::fics::consolefg	LimeGreen
set ::fics::silence	1
set ::fics::shouts	1

# Defaults for initial directories:
set initialDir(base) "."
set initialDir(book) "."
set initialDir(epd) "."
set initialDir(html) "."
set initialDir(tex)  "."
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
      .playerInfoWin .baseWin .treeBest .treeGraph .tourney .finder \
      .ecograph .statsWin .glistWin .maintWin .nedit} {
  set winX($i) -1
  set winY($i) -1
}

for {set b 1} {$b<=[sc_base count total]} {incr b} {
  foreach i { .treeWin .treeBest .treeGraph } {
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
set winWidth(.crosstabWin)  65
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

# Show suggested moves: on by default. Not S.A.
set suggestMoves 0

# Show variations popup window
set showVarPopup 1

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

# startup:
#   Stores which windows should be opened on startup.
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
#
set myPlayerNames {}


# Game information area options:
set gameInfo(show) 1
set gameInfo(photos) 1
set gameInfo(hideNextMove) 0
set gameInfo(showMaterial) 0
set gameInfo(showFEN) 0
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
set exportFlags(symbols) 1
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


# ::windows::switcher::vertical
#
#   If 1, Switcher frames are arranged vertically.
#
set ::windows::switcher::vertical 0
set ::windows::switcher::icons 1

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

# sets visibility of gameInfo panel at the bottom of main board

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

# Email configuration:
set email(logfile) [file join $scidLogDir "scidmail.log"]
set email(smtp) 1
set email(smproc) "/usr/lib/sendmail"
set email(server) localhost
set email(from) ""
set email(bcc) ""


### Audio move announcement options:

set ::utils::sound::soundFolder [file nativename [file join $::scidExeDir sounds]]
set ::utils::sound::announceNew 0
set ::utils::sound::announceForward 0
set ::utils::sound::announceBack 0

set ::book::lastBook "" ; # book name without extension (.bin)

# Engines list file: -- OLD NAMES, NO LONGER USED
#set engines(file) [file join $scidUserDir "engines.lis"]
#set engines(backup) [file join $scidUserDir "engines.bak"]

# Engines data:
set engines(list) {}
set engines(sort) Time
set engines(F2)  1
set engines(F3)  2
set engines(F4)  {}
set engineCoach1 {}
set engineCoach2 {}

image create photo icon -format gif -data {
R0lGODlhOAAwAMZRAAChAACiAACjAROhAA+iFRaiAhKjFhmjBA2kIxWkGBCl
JBilGROmJSOkLSekJCSmLimlJianLyOoOCioMSWpOSqpMjOnODCoQTSoOTGp
Qi6qSTapOzOqQzypSj+pQz2qSzqrUj6rS0SpUUWqUkOsWUasU0StWkWuW0qs
YU6sWkutYk+tW02uY06vZFKtaVatY1OualeuZFWva1qucV2ua1uvcl6vbFyw
c2GveWSvc16wgGKwemOxe2avgGqvemixgmqzg26xiW+zinC0i3SykXeyi3W0
kna1k3qzmX2zk3u1mny2m4O0m4C2ooG3o4i1o4m2pP//////////////////
////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
/////////////////////////////////////////////////yH5BAEKAH8A
LAAAAAA4ADAAAAf+gH+Cg4SFhoeIiYqLjI2Oj4gNDYwqLDEwkJmFEBWMKy8u
mJqjkhUUiCYrlTCio5kTFRIbiCsoKi6XrpqSErIZGRofHyMiI6mhMDY3uo+x
FhsXGxkeHyIgIyuqljAzNcyMCg68EhcXGhwfIca1Kyyhgjk7O0DfhxAQkhsb
sh4dGiPXUpxQ8YKbIBzz6NUbtEDBA3z5yk3zAFBECm0sRN3AgQMIECEL/yBw
oKABvn36PGgAoc7ECFsFZRzE0eOjQmYLcipgMGFCg33lPGRIJ+JEqkouZNjw
9gcHjyBChhjBuQDBAggOewHN0KHatVoEWc1Y9seHRyFFiuAk4ABBAwb+vGb9
yYCuWDFVBZPVyIFD0EchRo4kcUVAZ0lxzwRxFTZiXaVLNWogFNQDMGAlrqo6
cADhQYUGWn8FG2YiFYqM3CTv8AukiBEjg0cRKNwQLmhoEz+ACJgNlAwaNW6s
/tMjCJHAmDMVYEtgZAMHFSxoNde12AhBq2Z0i8dDIVojSDTlLJATgUNJz6B5
QDfs+p+wSVXXFOT6yBFIA2aXN68AIjlyGnQFgiBHXdJNcHx5B1tsjhAAQH60
bfZAPuRc4AE1HwiSTTsxKCUZD/P9McRljgAAwGyFNdeQAp/9pA91whCIAigs
dLMRRwq5BluJJkJIW0ksgjbdSiJomE1G8Qn+Z5YgRpDYiIkOCqLiAg545uIF
GRBijAm2sNDCdjnw0BGTrzG4SI8LCJITSQyUJKQshIBg0UWgJMURDzp4d1x4
jTgIAHn6jYTIYo2RwKUKl9Agg2Q+dPSRIEcgoQQTjJxYmKUjKYDIeukQc5EK
LcRwYJhmCQHSH/Yp0USJBAywwGyIQNNBV8OQkM0tGS2qZGWnRjppia7Shkg5
F9RFTCovZETDDRvtoEOpgiSRhKohadVPMNdYZAJBLtDQDUfPVgZpEkhQuhAG
0ARVDTaHbqOrD6X2qkQSq37TQCy9YMlBB3KSQGcoMwBXAw87QPuHEUv8au9t
WM7qlQi1nAbwnWf+KYRcvcwIqY80/dh1lLKL8vUsVIAJUm4TTzDzGVAX+MOY
CSmgMKOokcljVmVGqPWHqk+kPAoDEAG1AQfoyOmYCyikJlyef031h6Qou1Il
aFf2sy42XcLgLUcF+2BqzoKo6oTPkDTkVgMU5NswYxbhJdYN8QBR6msmm6uJ
AuEEfYEEwARjTWOqwHAJDKrFa6ogS2D8yJo7cZJPSsE0BvNAAEfGVw9zO30y
2Y3k1JAkFFpoYacpbLtCC6wshVBHpqIVNsqcM+L5AkDHspVKu4lgqy0xdBgc
QpjjrDkTUT+CwEi2xSWBSheKEALE2aAugwzMNvqX638k7oQTkDTnQG02yl8Y
ggfF7J7dt856HYRUdffcfU4MQGd7hRqsVE0K/6aOww08mPUR2H+gVxOgEJIC
GvCAiAgEADs=}

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
      # Scid doesn't handle well .sg3 and .sn3 files.
      if {([file extension $file] == ".sg3") || \
            ([file extension $file] == ".sn3")} {
        set eName ".si3"
        set fName [file rootname $file]
        set file "$fName$eName"
      }
      # Scid doesn't handle well .sg and .sn files either.
      if {([file extension $file] == ".sg") || \
            ([file extension $file] == ".sn")} {
        set eName ".si"
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

if {[catch {source $optionsFile} ]} {
  ::splash::add "Unable to find the options file: [file tail $optionsFile]" error
} else {
  ::splash::add "Using options file \"[file tail $optionsFile]\"."
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

# font_Regular is the default font for widgets:
option add *Font font_Regular
option add *Text*background $defaultBackground widgetDefault
# Use font_Menu for menu entries:
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

  bind $w <F1> {helpWindow Index}
  bind $w <Escape> {.splash.dismiss invoke}

  $w.t tag configure indent -lmargin2 20
  $w.t tag configure error -foreground red
  $w.t tag configure scid_title -font {Arial 24 normal} -foreground darkslateblue

  $w.t insert end "        $::scidName     " scid_title
  $w.t image create end -image splash -padx 20 -pady 10
}

# Scid logo
image create photo splash -format gif -data {
R0lGODlhYABQAOfJAB8fHyEhISMjIyQkJCYmJicnJykpKSsrKywsLC0tLS8v
LzAwMDIyMjMzMzQ0NDU1NTY2Njc3Nzg4ODk5OTo6Ojs7Ozw8PD09PT4+Pj8/
P0BAQEFBQUJCQkNDQ0REREVFRUZGRkhISElJSUpKSktLS0xMTE1NTU5OTk9P
T1BQUFFRUVJSUlNTU1RUVFVVVVZWVldXV1hYWFlZWVpaWltbW1xcXF1dXV5e
Xl9fX2BgYGFhYWJiYmNjY2RkZGVlZWZmZmdnZ2hoaGlpaWpqamtra2xsbG1t
bW5ubm9vb3BwcHFxcXJycnNzc3R0dHV1dXZ2dnd3d3h4eHl5eXp6ent7e3x8
fH19fX5+fn9/f4CAgIGBgYKCgoODg4SEhIWFhYaGhoeHh4iIiImJiYqKiouL
i4yMjI2NjY6Ojo+Pj5CQkJGRkZKSkpOTk5SUlJWVlZaWlpeXl5iYmJmZmZqa
mpubm5ycnJ2dnZ6enp+fn6CgoKGhoaKioqOjo6SkpKWlpaampqenp6ioqKmp
qaqqqqurq6ysrK2tra6urq+vr7CwsLGxsbKysrS0tLW1tba2tre3t7i4uLm5
ubq6uru7u7y8vL29vb6+vr+/v8DAwMHBwcLCwsPDw8TExMXFxcbGxsfHx8jI
yMnJycrKysvLy8zMzM3Nzc7Ozs/Pz9DQ0NHR0dLS0tPT09TU1NXV1dbW1tfX
19jY2NnZ2dra2tvb29zc3N3d3d7e3t/f3+Dg4OHh4eLi4uPj4+Tk5OXl5ebm
5ufn5+jo6Onp6erq6uvr6+zs7O3t7e7u7vDw8PLy8v//////////////////
////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
/////////////////////yH5BAEKAP8ALAAAAABgAFAAAAj+AP8JHEiwoMGD
CBMqXMiwocOHECNKnEixosWLGDNq3Mixo8eKrVKhGkmypMmTKFG2+piRlalE
iA7JnEmzps2bNxNNesWyYqlNfPIIHUq0qNGjSIcuUtVz4idBd6JKnUq1qtWr
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
OvYBOlcdnNiJnviJoBiKojiKpFiKplgRAQEAOw==
}

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
::splash::add "(C) 2008-2010 Steven Atkinson (stevenaaus@yahoo.com)"
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

::splash::add "User directory is \"$scidUserDir\""

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
