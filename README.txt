  Scid vs. PC
  Chess Database and Toolkit

  ____________________________________________________________

  Table of Contents


  1. introduction
  2. features
        2..1 New and Improved features
        2..2 Missing Features

  3. download
  4. installation
        4..1 Linux , FreeBSD
        4..2 Windows
        4..3 Mac OS X

  5. news
  6. miscellaneous
     6.1 docked windows
     6.2 how to play
     6.3 todo
     6.4 known issues
     6.5 bugs
     6.6 thanks
     6.7 scid's history

  7. changes
        7..1 Scid vs. PC 4.12
        7..2 Scid vs. PC 4.11
        7..3 Scid vs. PC 4.10
        7..4 Scid vs. PC 4.9.2
        7..5 Scid vs. PC 4.9.1
        7..6 Scid vs. PC 4.9
        7..7 Scid vs. PC 4.8
        7..8 Scid vs. PC 4.7
        7..9 Scid vs. PC 4.6
        7..10 Scid vs. PC 4.5
        7..11 Scid vs. PC 4.4.1
        7..12 Scid vs. PC 4.4
        7..13 Scid vs. PC 4.3
        7..14 Scid vs. PC 4.2
        7..15 Scid vs. PC 4.1
        7..16 Scid vs. PC 4.0
        7..17 Scid vs. PC 3.6.26.1

  8. contact
  9. links


  ______________________________________________________________________


  1.  introduction


  Shane's Chess Information Database is a powerful Chess Toolkit, with
  which one can create huge chess databases, run engine engines, or play
  casual games against the computer or online with the Free Internet
  Chess Server. It was originally written by Shane Hudson , and has
  received strong contribution from Pascal Georges and others.

  Scid vs. PC <http://scidvspc.sourceforge.net/> is a usability and bug-
  fix fork of Scid, with some new features. The project has been
  extensively tested, and is authored by ``Stevenaaus''.

  2.  features

  See ``changes'' for a comprehensive changelog, or the gallery
  <https://sourceforge.net/apps/gallery/scidvspc/index.php> for some
  screenshots..

  2.0.1.  New and Improved features

  o  Computer Tournaments.

  o  Rewritten Gamelist, with the Database Switcher incorporated.

  o  Improved Computer Game , FICs and Annotation features.

  o  Large Board sizes.

  o  Clickable Variation Arrows, and Paste Variation feature.

  o  Improved Undo and Redo.

  o  Tri-coloured Tree Bar-graphs alongside statistics.

  o  PGN Window can display small chess pieces.

  o  Player Information window has useful new buttons.

  o  Ratings Graph can show multiple players.

  o  Book tuning Remove Move feature.

  o  Move Search feature (eg h3 Bh5 g4 Bxg4).

  o  Separate board sections are hideable via right-click.

  o  Redone Buttons and Toolbar icons.

  o  Clickable Tablebase moves.

  o  Any number of Chess Engines may run at one time. Engine 1 can be
     docked into the Status Bar. Engine Logs are easily viewable.

  o  The Chessboard/Pieces options have been totally overhauled, and
     custom Pieces/Tiles are suported. (NB - most piece-sets require the
     TkImg package to work).

  o  Setup Start Board has many fixes and improvements.

  o  The Help index is now meaningful to new users, with links to the
     game's main features.

  o  Many more bug-fixes and interface refinements.

  2.0.2.  Missing Features

  o  Mainline SCID has a powerful filter sorting capability, but it is
     overly complicated, and perhaps not stable.
  o  Some language translations need updating.

  3.  download

  source scid_vs_pc-4.11.tgz
  <http://sourceforge.net/projects/scidvspc/files/source/scid_vs_pc-4.11.tgz/download>

  windows Scid vs PC-4.11.exe
  <http://sourceforge.net/projects/scidvspc/files/windows/Scid%20vs%20PC-4.11.exe/download>

  mac ScidvsMac-4.11.dmg
  <http://sourceforge.net/projects/scidvspc/files/mac/ScidvsMac-4.11.dmg/download>

  browse files
  <https://sourceforge.net/project/showfiles.php?group_id=263836>

  The latest code is available from subversion - svn checkout
  http://svn.code.sf.net/p/scidvspc/code/ scidvspc-code
  or as a tarball https://sourceforge.net/p/scidvspc/code/HEAD/tarball
  <https://sourceforge.net/p/scidvspc/code/HEAD/tarball>

  4.  installation

  4.0.1.  Linux , FreeBSD

  Scid vs. PC requires Tcl/Tk <http://tcl.tk> 8.5 or later.  Tcl/Tk
  8.5.10 has nasty bugs and should be avoided.Most Unices should have
  Tcl/Tk installed by default.  To verify this, look for a command named
  wish or wish8.5.  Extra chess pieces (such as Berlin) are now enabled
  by default for Wish 8.6, but 8.5 requires installing TkImg
  <https://sourceforge.net/project/downloading.php?group_id=263836&filename=tkimg1.3.scidvspc.tar.bz2>.
  Sound support requires Snack
  <http://sourceforge.net/projects/scidvspc/files/support%20files/snack2.2.10.scidvspc.tgz/download>.
  (Both of these downloads have fixes applied).  Then, installing from
  source:

  ______________________________________________________________________
  tar -xzf scid_vs_pc-4.12.tgz
  cd scid_vs_pc-4.12
  ./configure
  sudo make install
  scid
  ______________________________________________________________________


  It is also possible to install Scid vs. PC into /usr, instead of the
  normal /usr/local.  This allows for parallel installation with
  mainline Scid, and is done by: ./configure BINDIR=/usr/bin/
  SHAREDIR=/usr/share/scid/
  Scid's multi-language support can cause problems. Chinese (and other)
  users should use: ./configure LANGUAGES=""

  4.0.2.  Windows

  Windows installation simply requires downloading the ``executable'',
  and following the prompts.

  The configuration files, including the chess engine list, are stored
  in the Scid-vs-PC\bin\config directory, and may be copied over from
  old versions to make upgrading easier. If the app is installed in
  "Program Files" On Windows 7, the config files are mirrored in
  C:\Users\[USERNAME]\AppData\Local\VirtualStore\Program Files\Scid vs
  PC


  People with Visual Studio 11 should now be able to compile the project
  fairly easily (see Makefile.vc for more details).

  4.0.3.  Mac OS X

  The ``ScidvsMac-4.12 app'' should include everything you need. Simply
  drag and drop the App into /Applications (or similar).

  Users upgrading may have to remove (or edit)
  $HOME/.scidvspc/config/engines.dat to properly configure the chess
  engines.

  OS X has a poor implementation of Tcl, and docked mode has minor bugs
  (some windows work better after being moved around, keyboard shortcuts
  are very hit and miss).

  To compile from source - once you have XCode installed - please read
  ScidvsMac-HowTo.rtfd in the source tarball.

  OS X's Cocoa port of Wish is broken, with little chance of repair.
  Scid vs PC ships with a custom 32bit Carbon build of Wish.

  5.  news

   December 2013

  4.11 is out, with large board sizes, and a fix for the annoying
  filter/tree issue.

   April 2013

  Finally have a docked windows feature. It's a damn complicated thing,
  but i am fond of it.  Scid vs PC 4.9 is coming :)

   March 2012

  Big effort by Gregor to write Drag and Drop support for Scidb and
  ScidvsPC. Thanks. FICS is looking great too.

   September 29, 2011

  Jiri Pavlovsky has made a windows installer. It's a nice piece of
  software :) Big thank-you. And we now have undo and redo features.

   July 8, 2011

  Thanks to Gilles for the web page restructure and OSX testing. Gregor
  Cramer  <http://scidb.sf.net> has contributed a PGN figurine feature.

   April 19, 2011

  A belated thanks to Lee from Sourceforge for this article
  <http://sourceforge.net/blog/after-scid-row-a-new-chess-app-is-born/>.

   December 10, 2010

  Sicd vs. PC 4.2 includes support for Scid's si4 db format.

   July 3, 2010

  For the tenth release I've adopted verison number 4.0 . It includes a
  new Computer Tournament feature (thanks to some UCI snippets from
  Fulvio) and the Gamelist Widget is finally up-to-speed for large
  databases.


   April 19, 2010

  Release 3.6.26.9 includes a Fics accept/decline offers widget.

   December 20, 2009

  Thanks to Dorothy for making me a Mac DMG package with this release ,
  3.6.26.8.

   August 16, 2009

  With 3.6.26.6 I've fixed Phalanx's illegal castling. There is also
  changes to the Setup board and Toolbar configuration widgets.

   July 17, 2009

  3.6.26.5 - New Gamelist widget, and re-fashioned main buttons.
  Project's looking quite solid :->

   June 23, 2009

  The monkey on my back has really been having a good time. This release
  includes changes to the Gameinfo, Comment Editor, and Board Style
  widgets, some new chess pieces, colour schemes and tiles. Thanks to
  Michal and Alex for feedback.

   June 4, 2009

  Well, the html is up, and i've got a couple of files in the downloads
  section. My project is fairly modest fork of Scid ... just rewriting
  Tk widgets when i get the urge.

  6.  miscellaneous

  6.1.  docked windows

  This powerful feature is maturing. See the Docked Windows help item
  for more info.

  o  Window focus automatically follows the mouse around, and also
     impacts which keyboard bindings are active. Most bindings are
     active when the mouse is over the main board.

  o  In the event of Scid failing to start, restart the program with the
     -nodock option.

  o  Windows undocked from within docking mode can have glitches.
     Mainly: drag and drop game copies in the switcher don't work.

  o  OS X support is not great.

     Make sure to check out the new Theme Options, which affect how the
     Docked Windows (and Gamelist) look and feel.

  6.2.  how to play


     Playing against the Computer
        The main Computer vs. Player feature is accessed from
        Play->Computer. Here you'll find options to play against Phalanx
        (a flexible computer opponent whose skill you can select), or
        any installed UCI engine.

     Playing on the Internet
        Playing on the Internet is done via the the Play->Internet menu
        item. I recommend visiting the Fics <http://www.freechess.org>
        website to create a user account, but it is also possible to
        play anonymously. To start a game, press the Login as Guest
        button, then watch the available games as they are announced in
        the console. Enter play [game number] to accept a game
        challenge.


  There is more information about the Fics and Tactical Game features in
  the Scid Help menus.

  6.3.  todo


  o  Openseal is an open source version of FICS Timeseal. It needs some
     rewriting to work with Scid, though it is a small program.

  o  FICS could be adapted to work with the ICC. The work involves
     analysing the differences in the strings used by the two programs.
     (for example, for FICS we have this line to ackowledge successful
     log-in if {string match "*Starting FICS session*" $line]} { The two
     servers do have many similarities i think, and examining xboard's
     "backend.c" (or some other client) for "FICS" particularities

  o  Russian translation is broken afaics, and has been removed for the
     time being.

  o  The month i've updated the translations a little. (Thanks to Peter
     for totally overhauling the Dutch one). The checklangs.tcl script
     is in much better shape, but of course there are still lots of
     translation "todos"

  o  The TCL sound package, Snack, needs a maintainer.

  o  There was a lot of work done to implement Fischer Chess (Chess
     960), but they never fixed all the bugs, and the web site
     http://www.wtfai.me.uk/scid960.html is now gone. The latest code is
     in ScidvsPC's source patches/chess960.patch

  o  The Tree code works reasonably well, but i have never found the
     time to overhaul the Slow/Fast/Slow modes. These were (for a long
     time) negelected when Fulvio wrote the interuptible tree code. Scid
     now has the Modes removed, so doing this in ScidvsPC probably
     wouldnt be terribly hard to do.

  o  There are two engine types - UCI and XBoard. Pascal's UCI code is
     in some ways inferior to Shane's Xboard code.  Though this is
     mostly mitigated by the speed of modern processors, it'd be nice to
     make use of the UCI ponder feature in analysis mode (Comp mode
     already does so).

  o  I've never had a chance to verify/update the Novag Citrine drivers
     and interface due to lack of hardware.

  o  Our Windows port needs a little overhaul to properly use Users home
     directory to store all the various data.  I will get around to
     doing it one day though.

  o  A lot of people use chessbase books (.ctg). Scid can only read
     polyglot opening books, but inlining this projects work may not be
     too hard. https://github.com/sshivaji/ctgexporter

  6.4.  known issues


  o  Tcl/Tk-8.5.10 is buggy. Tcl/Tk-8.6.0 also is immature, but mostly
     works.
  o  OS X docked mode has multiple issues due to it's poor Tcl/Tk.

  o  Chinese Language Support. Scid's multilanguage support is broken
     for some countries. The work around involves compiling from source,
     using: ./configure LANGUAGES=""
     Alternatively, remove all lines between "### deutsch.tcl" and "#
     end of serbian.tcl" in the scid.gui file.

  o  Focus Issues. Kde users can allow Tcl apps to properly raise
     themselves by configuring desktop > window behavior > advanced >
     focus stealing prevention set to "none"

  6.5.  bugs


  o  See the known issues about Tcl/Tk (above).

  o  Importing huge PGN archives can sometimes fail. The command line
     utility pgnscid is a more reliable way to create large databases
     from pgn. Typing "pgnscid somefile.pgn" creates a new database
     "somefile.si4".

  o  Using the '+' operator and clicking on 'Find' in the gamelist
     widget can be very slow. The code needs to be moved from
     gamelist.tcl to tkscid.cpp.

  o  Windows only:

     o  Using "ALT+F"... etc key bindings to access the menus is badly
        broke. This is a Tcl/Tk issue.

     o  Window focus/raise issues, another Tcl/Tk issue.

  6.6.  thanks

  Thanks to Gregor Cramer <http://scidb.sf.net> for the PGN figurines
  and Drag and Drop features, and technical support.

  For Gilles and Dorothy for OSX packages, Jiri Pavlovsky for the
  windows installer, and all Scid vs. PC testers.

  Sourceforge.net <http://sourceforge.net> for their great hosting,

  Pascal Georges for his many technical contributions.

  Fulvio and Gerd for their much appreciated contributions to mainline
  Scid.

  Michal Rudolf <http://chessx.sf.net> and Alex Wagner for initial
  feedback and bug-reports,

  and of course Shane Hudson, and the authors of Tcl/Tk <http://tcl.tk>

  6.7.  scid's history

  Scid is a huge project, with an interesting history. Originally
  authored by Shane Hudson from New Zealand, it combined the power of
  Tk's GUI and the speed of C, to produce a free Chess Database
  application with Opening Reports, Tree Analysis, and Tablebase
  support.  It gained quite some attention, as it was arguably the first
  project of it's kind; but after writing over a hundred thousand lines
  of code, in 2004 development stopped and Shane never contributed to
  Scid again.

  Two new versions of Scid appeared around 2006. The first was ChessDB
  authored by Dr. David Kirby. With some good documentation and the
  ability to automatically download games from several web portals, it
  became popular. But at the same time Pascal Georges from France was
  making strong technical improvements to Scid. Frustrated with Scid's
  dormancy, and because of disagreements with ChessDB's author, Pascal
  released his own tree, Scid-pg, which included UCI support and
  numerous Player versus Computer features.

  But subtley, and with some controversy, he began to adopt the name
  Scid as his own. Some people objected, especially Dr. Kirby, with whom
  a flame war began, but Pascal's efforts to gain ownership of the
  Sourceforge Scid project eventually succeeded.

  Under Pascal, and with the help of numerous contributors, Scid again
  strode forward. Pascal wrote a Tree Mask feature, and in 2009 he
  upgraded the database format to si4, all the time making speed and
  technical improvements to the neglect of the interface. In 2010,
  Pascal ceased contributing at all, and shortly after the last stable
  version of Scid (4.3) was released.  Since then, Scid has had
  widespread, and unstable technical changes; mostly by Fulvio Benini,
  who is a long-standing contributor.

  Currently there exist several Scid related projects.

  Chessx was originally by Michal Rudolf (a longtime Scid contributor
  from Germany) and named Newscid. Now led by Jens Nissen, with a 1.0
  release, it is an attractive Chess GUI but with a small feature set
  and without si4 support.

  Scid vs. PC was started in 2009 by Steven Atkinson from Australia.
  Forked from Scid-3.6.26, it began as an effort to tidy Shane's
  frenetic code base and improve the user interface, and has since
  matured into a capable Scid successor.

  The Android app, Scid on the Go, supports the si4 database format, and
  is the only mobile Scid related project.

  Another project nearing a 1.0 release is Scidb by Gregor Cramer from
  Germany. It is an ambitious chess database program inspired by Scid,
  with heavy utilization of C++ classes and customized Tk widgets. It
  also supports Chessbase databases and many chess variants.

  7.  changes

  7.0.1.  Scid vs. PC 4.12


  o  Gamelist/Filter fixes. Filter works better with Tree.

  o  New Crosstable tie-break options and reorder Crosstable menus.

  o  Game-result is now shown alongside Player names, at top of GameInfo
     window.

  o  Middle button in main board toggles game info.

  o  Databases open faster ("avoid the time consuming file locking").

  o  Allow dragging Docked Window tabs to alter their order.

     Gamelist button/menu changes:

  o  Flag button is now context menu, Gamelist Save is moved to
     tools->export, Find button removed (use enter in Find entrybox)

     Spelling changes:

  o  Update spelling file to a custom version of Franz's Jan-5-2014
     spellling.ssp.

  o  Spell-checking can now remove GM, IM, FM, CM, WGM prefixes from
     player names.

  o  Doing player-name replacements, show how many fail due to age/date
     considerations.

     FICS changes:

  o  Add user-configurable init commands.

  o  Board size slider is now a menu.

  o  Game Offers pack over buttons (making it less crowded, use
     escape/button-2 to cancel).

  o  New find entrybox to search the console.

  o  Remove Clear button (as getting crowded).

  o  Remove the never used big clocks.

  o  Add start, end sounds (and minor sound fixes - though still buggy).

  o  Dont save FICS aborted games.

  o  Disable engines when playing a FICS game.

     Analysis and Annotation changes:

  o  Make 'scoreToMate' work better and faster, which stops occasional
     incorrect Mate-in-N lines showing up, and works better at near-mate
     positions.

  o  Make the Annotation config window fit on small displays.

  o  Stop engine at end of annotating a single game.

  o  Try a new approach to Depth-based annotation, which works better,
     but still needs fine-tuning.

  o  Spanish translation update from Igor Sosa Mayor.

  o  Polish translation update from Adam Umiastowski.

  o  Add a find entrybox to the splash window

  o  Strip PGN Tags improvements

  o  Right-clicking toolbar Game-Save icon quick saves game.

  o  Sound devices can now be selected; mainly useful for Linux systems

  o  Dont insert newlines into PGN copied to text buffer... Some web PGN
     browsers don't work with newlines following movenum. eg "10.

  o  Save game history when Scid quits

  o  Remove tree status bar. Same info avail in switcher and tree text
     widget.

  o  Booktuning nextmove is now highlighted (same as Book), and padding
     has been tweaked a bit.

  o  Move Maintenance menu from File to Tools menu

  o  Remove the annoying " from myPlayerNames.

     Bugfixes:

  o  When saving PGN to file, disable translating pieces. (Export to PGN
     was already this way).

  o  FICS Digital clocks didnt appear under some circumstances

  o  Undo/redo refinement/fix for when buffer has been full

  o  Fix import issue - Sometimes first tag is lost (If UTF byte order
     mark is present)

  o  MSWindows - Board keyboard bindings are were getting lost after
     Variation window popup is dismissed.

  o  Some tooltip refinements, including removing tooltips with board
     update (mask tooltips were erroneously persistent).

  o  Tablebase window: Results Board was not getting packed (is now
     below Results Frame). Change the damn awful red, update help, give
     tbWin the widest paned window.

  o  With wish8.6, we cant close undocked windows with a Close button.
     Fix

  o  Some fixes for javascript and html game exports

  o  Correctly handle plain text crosstables.

  7.0.2.  Scid vs. PC 4.11


  o  Maximum board size is now twice as big

  o  Gamelist context menu (right-click). Less button crowding

  o  Annotation improvements: Depth based annotation, and cut-off
     features

  o  Dock a few extra windows (graphs, tablebase)

  o  Computer tournament stability/speed fix

  o  Locked Analysis Engines now show the locked position (not the
     working line) , and bug-fix the engine lock, which didnt work
     properly

  o  Add a low CPU priority check box to Engine Configuration window
     (especially important for MS Windows - where engines can kill GUI)

  o  Engine configuration window now repsonds to keystrokes to quickly
     find any engine

  o  Display "(altered)" in statusbar is game has been changed

  o  Fullscreen menu item (Options->Windows->Fullscreen)

  o  FICS tweaks, including over-riding takeback/abort request dialogs
     when game ends

  o  Remove some wasted space around FICS, main button bar, and other
     widgets
  o  New Greek translation

  o  Read custom chess pieces from  /.scidvspc/pieces

  o  Docked tabs/menu refinements

  o  OS X - Clicking on URLs will open the link in a browser

  o  Add a command console to the start-up window

  o  Bug-fix: Fix main board rendering anomoly in docked mode with MS
     Windows

  o  Bug-fix: When tree is open, gamelist filter operations didn't work
     properly

  o  Bug-fix: Search in variations never matched positions at end-of-
     line

  o  Bug-fix: Opening Table favourites werent working properly

  o  In Export PGN dialog, add an option for "Space after Move Numbers"

  o  Keyboard short-cuts changes. Control-L (etc) no longer open/close,
     but open/raise

  o  Tweak Comment Editor and Player Info buttons

  7.0.3.  Scid vs. PC 4.10


  o  When sorting databases, don't reset filter and remember current
     game/gamestate

  o  Game history menu

  o  Implement (and bugfix) SCID's more comprehensive NAG framework

  o  Change a couple of field orders in the gamelist, remember field
     widths, and remove the icon context menus from the switcher (middle
     click now toggles show/hide the database icons)

  o  FICS: Allow use of alternative URLs (used during FICS outage) and
     other minor tweaks

  o  Window focus improvements (mainly for MS Windows and OS X)

  o  Computer Tournament: add 'Engine Scores as comments' option, and
     make some minor global/:: var changes

  o  Add Book Tuning to dockable windows

  o  Automatically flip board (if applicable) in game browser and
     analysis miniboards

  o  When diffing twin games, ignore newlines in the comments, which
     make diffing impossible

  o  Add undo points for user generated addNag events

  o  Bookmarks: add a few key bindings (delete/up/down), and shuffle the
     gamelist bookmark button up one row

  o  Drag and drop hardening


  o  Windows 7 bugfix: PGN export and Progress bars weren't working in
     undocked mode

  o  Translation framework updates. Overhaul Dutch translation, and
     remove (broken) Russian one

  o  Convert braces '{', '}' to '(',')' when exporting PGN comments
     (against PGN standard). Also tweak various PGN help topics

  7.0.4.  Scid vs. PC 4.9.2


  o  OS X changes, including docked mode fixes

  7.0.5.  Scid vs. PC 4.9.1


  o  Fix promotion bug in non-docked mode

  o  Small pictures allign top/bottom in game info

  o  Clickable crosstable columns

  o  Make an undo point with Setup Board, and disable undo for Trial
     mode

  o  Add Tournament lookup to Player Info window

  o  PGN import window was not getting mapped

  7.0.6.  Scid vs. PC 4.9


  o  Window Docking feature - Different windows are docked/restored than
     Scid. Five layout slots with three custom layouts. Bug-fixes. F11
     for fullscreen. Tcl-8.6.0 may have issues. Selectable Ttk themes
     (also for Gamelist)

     General

  o  Move search feature (eg 'h6 Bxh6')

  o  UCI: replace 'position fen ...' with 'position startpos moves ...'
     for general analysis

  o  Better Twin Games Checker - highlights missing comments and
     variations in duplicate games

  o  Windows has a MSVC makefile (Makefile.vc) and includes Stockfish
     2.31 (JA legacy build)

  o  Fix windows stack problem (hopefully)

  o  Text Find widgets in help, crosstable, engine logs

  o  Game Save dialog remembers any custom tags you add to a game,
     making them easy to recall

  o  Restore drawing arrows and marks from the main board (also used by
     FICS premove)

  o  Arrow length/widths configurable via comment editor

  o  PGN Figurines now display in bold, and a different font, if
     applicable (from Gregor)

  o  Some new board textures (from Ed Collins)

  o  Automatically save "bitmaps" directory when exporting to HTML

  o  Player info window shows Photos in a scrollable canvas insead of
     stuck in top right corner

  o  Delete key deletes moves in game/variation after the current move

  o  Score Graphs are now bargraphs instead of lines

  o  Bind statusbar->middle button to 'switch base'

  o  FICS context menu, game offers now show more information, and
     premove

  o  FICS: deiconify/raise window when game starts (nodock mode only)

  o  FICS: stop clock when we make a move (even though we may not have
     acknowledgemnt from FICS about move)

  o  FICS: 'upload' command for uploading local games to FICS examine
     mode

  o  Allow the Name editor to glob '*' for Site, Event and Round fields
     (but not for 'All Games', too dangerous when used by mistake)

  o  The material board can display *all* taken pieces

  o  Gamelist button rows can be hidden by right-clicking the list, and
     it has a game save icon

  o  Right click V+ button adds the second variation

  o  Windows analysis engines no longer run at low priority

  o  When annotating the score on blunders, show the main score first,
     var second (eg: +1.00 / +2.50)

  o  Add programmers reference to the help contents/online doc

  o  Bind space-bar to engine start/stop

  o  Update twic2scid.py script

  o  Remember if .board is flipped for each open base

     Bugfixes

  o  Make the database switcher icons/frames get smaller if they are
     cramped (so we can see them all)

  o  Half fix UCI game (sergame.tcl) time issues

  o  Corrospondence Chess now works

  o  Tree Mask bugfix: Checks couldnt be added to mask

  o  Fix Tree 'Fill cache with game/base' feature

  o  Try to handle shortened FENs with Paste FEN

  o  Crosstable: 'Set Filter' now includes deleted games if +deleted

  o  Crosstable: handle games with a year-only date differently for
     crosstable purposes (Instead of +/-3 months, match any other games
     in the calender year

  o  FICS: Stop clocks after a takeback request from opponent

  o  FICS: Games with move lengths greater than 1:00:00 would break
     parse

  o  Add missing FICSLogin translation

  o  New windows Phalanx build. It works better under win7, but has
     analysis polling issues

  o  OS X: pad out flag buttons in Header search

  o  base_open_failure was erroneously closing wrong base

  o  Windows Preview HTML for Reports is fixed

  7.0.7.  Scid vs. PC 4.8


  o  Drag and Drop file open(s) on Windows and Unix

  o  Custom background images (jpegs, gifs and pngs)

  o  Random sort pgn feature

  o  Crosstable now have +/-/= subtotals

  o  (and Player Stats format changed from +/=/- to +/-/=)

  o  General PGN search has ignore case option

  o  Board Search gets it's combobox updated when DBs are opened and
     closed

  o  Save game before PGN Import

  o  Save game: enable the use of 'prev game tags' for existing games.
     This allows easy addition of the same tags to consecutive existing
     games

  o  Remove the 'Scid: ' prefix from several window titles

  o  Update some translations

  o  Show Linux version/distro in the startup window

  o  Add a patch to make toolbar buttons raise only (instead of toggle
     open/shut)

  o  Add a patch for Chess960 support (from Ben Hague). Unfinished

     Analysis

  o  UCI: properly handle UCI buttons. Previously they were invoked at
     every engine restart

  o  Right clicking 'Add Var' button adds Engine Score comment only

  o  Replace ponder on/off with hard/easy for xboard engines

  o  Super quick engine infos can happen before Scid's PV is inited
     properly. So we have to default to PV = 1


  o  Allow xboard engines to use lowercase 'b' for bishop promotion (eg
     a7b8b)

  o  Don't send an erroneous 'isready' (with 'uci') to quiet analysis
     engines

  o  Right clicking the widget allows to disable line wrapping

  o  Don't add a line to analysis history if moves are null

     Tree

  o  Move ECO stats to the end of line

  o  Several Mask refinements - notably Searches are much more readable
     and previously clicking on searched lines didn't work

  o  Fix up minor bugs about castling moves (OO, O-O, O-O-O)

     Computer Tournament

  o  Computer Tournament Book feature

  o  Dont' kill tournament if engine crashes

  o  Only pack the first 10 engine combos (which allows for big
     tournaments)

  o  Fix up Xboard time/move command order. Xboard engines should behave
     much better

  o  Various other tweaks

     Gamelist

  o  Show altered games in red

  o  Control-wheelmouse scrolls up/down one page

  o  Switcher now has text on two lines (if icons are shown)

     FICS

  o  Digital clocks now (optionally) on the main board

  o  Better integration of FICS "examine" and "observe" features

  o  FICS has it's own options menu

  o  bind F9 to xtell instead of tell

  o  Change the move.wav sound from tick-tock to a short click

     OS X

  o  Filter graph bugfix

  o  Material Search properly shows the little buttons

  o  Copy and Paste text from disabled OSX text widgets (engines, help,
     gameinfo)

  o  Buttons 2 and 3 are swapped around

     General Bugs

  o  Work arounds for wish 8.5.12 and 8.5.8 issues

  o  Analysis logs can badly break autoscroll, so use normal frames and
     scrollbars

  o  Handle PGN parsing of unspecified promotions (b8 becomes b8=Q , for
     eg)

  7.0.8.  Scid vs. PC 4.7


  o  Tree: Add coloured bargraphs representing win/draw/loss (and remove
     the old tree graph)

  o  Tablebases: Make best tablebase moves clickable

  o  Tablebases: tidy up config , main window and help items

  o  FICs: Can now play and watch (observe) multiple games at the same
     time

  o  FICS: Support loading old/interupted games for analysis (using
     'smoves' command)

  o  FICs: Add an Abort button. Other minor fixes

  o  Serious Game overhaul (though still has minor issues) Add pause,
     resume features and mate, game drawn dialogs

  o  Computer Tournament: Add 'first engine only' feature for testing a
     single engine against others

  o  Enable material difference display for game browser and fics
     observerd games

  o  Analysis: View engine logs from within Scid, and can also disable
     logging

  o  Analysis no longer word wraps, and uses fixed font

  o  Analysis: add a xboard/uci protocol column to the engine list

  o  Include updates to SCID's spellchk.c, improving the ELO add-ratings
     feature

  o  Update spelling.ssp file to Jan 2012, and include with windows

  o  Player info: clicking FIDE ID opens relevant url

  o  New feature: 'Search-Filter to Last Move'. All filter games will
     load at the last move (end of game)

  o  Refine the Calculation of Variation (Stoyko Exercise) feature and
     Help

  o  Toolbar has a 'book window' icon

  o  Tweak PGN context menu: reorder the Strip/Delete move items

  o  Gamelist: replace the Negate button with a Select button

  o  Tree: Include a patch for embedding the Best Games into the Tree
     window

  o  Analysis: Revert Lock engine changes. Previously, lock engine would
     also start Trial Mode
     Bugfixes

  o  Importing PGN, check that Promotion Moves are long enough
     (otherwise can segfault)

  o  Document CCRL pgn round name problem, and handle errors better when
     Name limits hit

  o  FICS: remove non-ascii chars from commands if using timeseal

  o  Gamelist: To display unusual characters, convert to unicode before
     displaying games

  o  Sync html bitmaps with SCID

  o  Book: Only do the second book move lookup if we have too. (slight
     performance boost)

  o  EPD: Quick fix for epd analysis annotation bug

  o  Hungarian, Swedish and Potugese Spanish were broken if Piece
     translation enabled (which was default). Fixed

  o  Fix up Tacgame score-isn't-updated bug

  7.0.9.  Scid vs. PC 4.6


  o  Undo and Redo features (partly from SCID)

  o  Microsoft Windows has a proper installer

  o  Always loads games at the correct game ply when using the tree and
     searches

  o  Ratings graph can show multiple players (and there's a minimum ELO
     feature)

  o  Computer Tournament: Improvements for both Xboard and UCI engines,
     and implement the 50 move draw rule

  o  Auto-promote feature for FICs

  o  Book tuning 'Remove move' feature

  o  Autoraise button raises all windows

  o  Annotation improvements, and it is now possible to score All moves
     while only annotating Blunders

  o  Known aliases Biographical data is shown in the player information
     window

  o  The player info widget has buttons enabling quick player renames
     and look-up

  o  'Read-Only' context menu to the Database Switcher, and Read-Only
     bases are greyed out

  o  Fix bug in the opening/theory table

  o  Remember game position when stripping comments and variations from
     PGN

  o  Change analysis colors for MultiPV to black/grey instead of
     blue/black
  o  New 'Search in (other) Database' feature to the board search (from
     SCID)

  o  Variation/Mainline arrows can have custom colours

  o  Crosstable can (optionally) show 3 points for a win

  o  Fix sc_remote (which allows games to be opened in an already
     running Scid vs PC)

  o  Phalanx tacgame bug-fixes (play brainy, and stop after the correct
     amount of time)

  o  Tweak the best games widget (make fields line-up)

  o  When handling Import PGN errors, show the game numbers as well as
     the line in file

  o  Catch a nasty wish8.5.10 bug with the gamelist (Wish-8.5.10 should
     be avoided)

  o  Remove the broken integer field validation and replace it with
     something that allows backspace to work

  o  Bind Control-Tab to 'switch to next base', and Control-(quoteleft)
     to 'switch to clipbase'

  o  Fix a couple of corner cases concerning dates and searches

  o  Analysis widget : small speed improvements , icon changes and bug-
     fixes

  o  Add a help item for Maintenance 'Check Games' feature

  o  Swap around the 'Next Move' and 'Event' game-information lines

  o  New documentation about making Polyglot books

  o  Make the player Report config widget a bit easier to use

  o  Catch a nasty wish8.5.10 bug with the gamelist (Wish-8.5.10 should
     be avoided)

  o  New OSX HowTo

  o  Crosstable bugfix: the 'show white first' feature didn't work for
     two match rounds

  o  Update 'Tips'

  o  Clarify Scid's maximum number of games

  o  Update Spanish and Polish translations

  o  Update FICs , PGN and Menu language translations

  7.0.10.  Scid vs. PC 4.5

  PGN Window:

  o  PGN chess font support (but font installation on Windows isn't
     great)

     Computer Tournament:


  o  Per-game time control

  o  Clock widgets for remaining time

  o  Manual adjudication buttons, and a Restart button

     General:

  o  Game List remembers it's view when switching between bases

  o  Game Browser has new buttons and functionality

  o  Tournament Finder is more readable

  o  Restore PGN scrollbar (pgn option)

  o  Phalanx now reads enpassant and 50 move field from FEN (thanks
     Bernhard Prmmer)

  o  FICs console fg and bg colours are now configurable

  o  Name Editor tidy up and documentation review

  o  Player Info: add a 'Refine Filter' result group

  o  Typing 'OO' castles (previously only 'OK','OQ')

  o  Mask Search widget fixes

  o  Annotation: Dont add nags when annotating score. Don't repeat
     previous nag if annotating all moves

  o  Crosstable shows current game in green

  o  Use translations for Game List column titles (if available)

  o  Add a 'Game Delete' menu

  o  Improve ./configure and Makefile, and CC FLAGS are propagated to
     all targets

  o  Game Save autocomplete now uses mouse instead of clumsy keyboard
     bindings

  o  Restrict Game List sort to valid columns, and add a 'confirm sort'
     widget for bases > 200000 games

     MS Windows tweaks:

  o  Windows Crosstable transparency glitch is fixed

  o  Fix wheelmouse support in a few places

  o  Add a 'make-scidgui.bat' hack for assembling a new 'scid.gui' from
     subversion

  o  Computer Tournament buttons padding fixed

     OSX:

  o  Make an OSX app with a working ;> version of Tcl (thanks Gilles)

  o  Many OSX wheelmouse and graphical fixes

     Bug fixes:

  o  Null move fixes including - analysis engines can append variations

  o  Tree training feature fixes

  o  Show Progressbar for loading bases with a dot (.) in their name

  o  If Scid crashes, Game List could be left with zero size

  o  PGN middle-click move preview feature fixed for variations

  o  PGN text tabstops are now dynamic to allow for correct column
     allignment in column mode

  o  Remember position of custom ecoFile if loaded

  o  Change the second book slot to avoid conflict with Annotation
     feature

  o  Catch unmatched braces in gamelist values

  o  Fix 'Paste FEN' castling sanity check

  o  Browser previously highlighted Next move instead of Current move

  o  Fix scid.eco unicode bug

  o  Remove 'newlines' from Mask Search results

  o  When addAnalysisVariation fails due to bad moves, don't move back N
     moves

  o  Theory table incorrectly started from start position

  7.0.11.  Scid vs. PC 4.4.1


  o  Fix nasty flicker bug when board is flipped

  o  Fix fics bug that graph sometimes doesn't stop when new game starts

  o  Add Burnett chess pieces

  7.0.12.  Scid vs. PC 4.4


  o  Implement SCID's interruptable tree processing

  o  Implement SCID's custom flags

  o  Gamelist is much faster for big databases

  o  Add widgets to the gamelist for manipulating flags and browsing
     first/last/next/previous games

  o  Opening Book and Book Tuning overhaul - allow two books to be
     opened with side-by-side sorting, and various interface
     improvements

  o  Overhaul Annotate widget - allow choice of scores/variation/both
     and remember annotation options

  o  Crosstable sort by Country feature

  o  Update Fics to allow for different Port/IP Address (using SCID
     code)

  o  Graph changes - remember widget settings, change colours+dot size,
     fix up half-move bug and a title misallignment, add 2010 decade

  o  Fix up the global grab for progressWindow (opening databases)

  o  Add "Half moves" (moves since capture or pawn move) to setup board

  o  ECO Browser changes - add "update" and "up" buttons, when clicking
     on "Start ECO" open browser at top level, make statistics more
     readable

  o  Add the "Last Move Color" to the main board colours widget

  o  Restructure "Tools" menu

  o  Icons - remove the large gameinfo and togglemenu buttons, add a
     "comment editor" icon to the toolbar and tidy up various icons

  o  Busy cursor when sorting database via Gamelist column click

  o  For OSX (esp. single button mice) - bind to context menu for main
     window and pgn window

  o  Make the 'paste variation' feature work a bit better at var/game
     end

  o  Make variation popup remember it's location instead of being
     centered

  o  Add "Read-only" button to maintenance window

  o  A nice PGN/htext performance tweak that smooths out large game
     edits

  o  When using "-fast", perform fast database opens also. Otherwise,
     update the progressbar to show "Calculating name
     frequencies"(todo?)

     Bug-fixes

  o  Ubuntu 11 have put libX11.so somewhere stupid. Update configure
     script

  o  Paste FEN bug involving fen validation

  o  Fix promotion bug involving busy CPU and missed grab

  o  Fix off-screen window placement on windows

  o  On Macs, dont place the window at top of screen, as it's then stuck
     under the main menubar

  o  Make the game save dialog center and resize properly

  o  Fix up file loading (and bookmarks) of DBs with dots (.) in their
     name

  o  Statusbar shows correct value after Crosstable update

  7.0.13.  Scid vs. PC 4.3


  o  Clickable Variation arrows

  o  Paste Variation feature

  o  Database Switcher has been moved to the Gamelist Widget (and has
     some new icons)

  o  Gamelist can now perform logical ANDs in the search widget using
     "+", and include the date

  o  Gamelist now has remove-above and remove-below buttons

  o  FICs improvements, including a ping feature to indicate network
     health (*nix only), and player communications are saved as PGN
     comments

  o  FICs bug-fix: don't automatically accept rematches

  o  FICs "Opponent Info" button

  o  New Toolbar buttons: "Load First Game" , "Load Last Game"

  o  Bookmark Widget has been overhauled

  o  Analysis Engine's move history doesn't get spammed by "Mate in 1"
     (for eg) messages

  o  An engine can now be run in the Statusbar

  o  Allow engines to be reordered

  o  Simplify the Bestgames Widget : Remove the PGN pane, nice-ify the
     widget, and enable graph and best widgets to remember size

  o  Several interface speed-ups from Fulvio

  o  Other SCID C++ changes from Gerd and Fulvio, including "Don't
     decode games when copying games"

  o  Some Tree Search optimisations from SCID

  o  Sort by number of Variations and Comments from Gerd

  o  Help Widget has a search entrybox

  o  Help Widget font size (and Pgn Window) can be easily increased by
     control+wheelmouse

  o  When pasting FEN directly, do a castling sanity check

  o  Bugfix: When user starts scidvspc for the first time, clipbase is
     left closed

  o  Browser widget has a nicer button bar, and windows wheel-mouse
     bindings

  o  Overhaul the Edit Menus

  o  Numerous GUI fixes

  o  Revert PlayerInfo to old format, but add a "Won Drawn Lost" header

  o  Tweak crosstable knock-out format

  7.0.14.  Scid vs. PC 4.2


  o  New si4 database support


  o  Include tree and mask improvements from Scid (excepting Fulvio's
     delayed tree code, which has issues)

  o  Overhaul right-click menu and allow toolbar / menubar / statusbar
     to be hidden

  o  Allow tournament games to start from current position

  o  Easier 64 bit compilation

  o  Include Scid's correspondence feature

  o  Make analysis widget info properly hideable, and tweak buttons

  o  Tweak game save forms

  o  A couple of Mac fixes, including the broken gamelist widget (bad!)

  o  Restructure game info widget - Player names are more prominent,
     Length field added, Colors made consistent

  o  Reincluded Merida2 pieces

  o  Remove Repertoire editor (same functionality via Tree Masks)

  o  New Finder rename fucntion

  o  PGN indentation fix (especially for comments)

  o  Work around for batch annotation bug (still under dev by Joost)

  o  Header search widget tidy

  o  New icon

  7.0.15.  Scid vs. PC 4.1


  o  Quite a few FICs tweaks, including new help pages and D.O.S. attack
     fixes

  o  Numerous Gamelist improvements (see below)

  o  Tree widget improvements: next move is highlighted, main filter is
     now independant of Tree filter, wheel mouse bindings

  o  Tactics feature fixed up: Renamed "Puzzle" , and Problem Solutions
     can now be browsed in-game

  o  Analysis window "add variation" now *appends* variations if at var
     end

  o  Comment Editor has undo and redo bindings

  o  Main board grid colour can be changed

  o  Setup board can rotate and flip the board

  o  Clicking on moves in the gameinfo area shows Comment Editor

  o  Better window raising/focusing

  o  Kill analysis window after batch annotations

  o  New marble tile theme and colour themes

  o  Some menu re-ordering

  o  Recent Files menu is basename only

  o  Remove Control+V game paste binding .... too dangerous

  o  Further refinements of Switcher widget and Icons

  o  ttk comboboxes are no longer grey

  o  Analysis widget scrolling will pause to allow backwards review

  o  Splash widget changes, and remove pop-up for missing Bases and Book
     directories

  o  Rewritten Help items

  o  Gamelist improvements -

     o  Field order rearranged

     o  Columns now sort in both directions, with arrow depicting
        direction

     o  Deleting items works better

     o  Can be sorted by ELO

     o  Draws sorted alongside no-result

     o  Delete and Compact buttons disable better


  o  Bugfixes -

     o  Twinchecker PGN text diff-ing was sometimes broken

     o  Phalanx observes tournament feature time control

     o  Fix "Show Suggested Move" feature

     o  Fix occasionaly issue with erroneously selecting squares, then
        being unable to reselect them

     o  Ignore crafty's resignations which caused X-window flash events

     o  No context menu if dragging a piece

     o  RobboLito (and others ?) had uppercase piece promotion which
        occasionally broke

     o  "Show Suggested Move" was broken

     o  Gamelist sometimes left off the last or first item


  o  Widget tidies -

     o  Analysis engine config widget

     o  Maintenance tweaks

     o  Game save widget made better

     o  Parent Date widget

     o  Delete twins

     o  Database Switcher changes, including new icons

     o  Finder now has three columns (and other changes)

     o  Player finder + Tournament Finder sub-widgets alligned

     o  Statistics window restructured

  7.0.16.  Scid vs. PC 4.0


  o  Computer Chess tournament feature

  o  The Gamelist widget has been rewritten to work with huge databases.
     Other new features include a case insensitive search, deleted items
     are greyed out, and there's a "Compact" button to empty trash with

  o  Add a background colour option that applies to many text widgets,
     including gameinfo, pgn window and help window

  o  Restructured the analysis widgets, putting toolbar on top, tiny
     board at bottom, tweaking toolbar icons and reparenting analysis
     died error dialog

  o  Update the book and book-tuning windows (untested, from SCID)

  o  Add a new logo, and some wm title tweaks

  o  Board Screenshot feature (Control+F12)

  o  Bind mouse wheel to move progression (and widget resize) for the
     little browser windows

  o  Change all comboboxes to ttk::combobox

  o  Allow xboard lowercase promotion moves (eg while g7g8Q always
     worked, g7g8q previously failed)

  o  Enable hovering over toolbar help pop-ups

  o  Fix up analysis widget "lock to position" feature

  o  All analysis windows can now use annotation, and autoplay feature

  o  Bind F4 to start another analysis window

  o  Various C fixes from SCID

  o  Sync the tools::connect-hardware feature with SCID (untested)

  o  When using the setup board widget, do a sanity check about the
     FEN's castling field

  o  Some minor version fixes anticipating tcl8.6

  o  Small bugfix: variation pop-up could previously throw errors if
     moving through movs fast

  o  F1 *toggles* help window

  o  Remove space-only lines from project - they mess up vim's paragraph
     traversal feature


  o  Fics "withdraws offer" fix

  o  Toolbar icons tweak

  o  Allow databses to have "." in their name

  o  Tactical Game stores game result

  o  Set Game Info widget includes Site field

  o  Small "update idletasks" in main.tcl improves main board
     responsiveness

  o  Fix up the history limit of combobox-es (especially the setup board
     FEN combo)

  o  UCI kludges for Prodeo and Rybka from SCID (untested)

  o  Turn off craftys egtb (end game tablebook) for the analysis widget

  o  Comment editor bugfix - unbind left/right from main board

  o  Fix for matsig.cpp overflow (unapplied? , untested)

  o  Key binding for first/last game is now Control+Home/End instead of
     Control+Shift+Up/Down

  o  Perform a db refresh after importing PGN file(s)

  7.0.17.  Scid vs. PC 3.6.26.1


  o  Overhauling the tactical game feature

  o  including a Fischer chess option

  o  Overhauling the tools->analysis widget

  o  Some re-organization of menu widgets, including tear-off menus

  o  Rewritten board style widget

  o  Fix parenting of some pop-ups, including the splash widget

  o  Clock widgets placed side-by-side

  o  Remember fics widget size

  o  Last move displayed in bold

  8.  contact

  Scid vs. PC mailing list
  <https://lists.sourceforge.net/lists/listinfo/scidvspc-users>

  Stevenaaus <email://stevenaaus at yahoo dot com> is a uni graduate in
  math and computer science, who programs as a hobby in tcl/tk, bash and
  C. He lives and works in rural australia, and spends some Saturday
  mornings playing against an ancient guy from Iceland.

  9.  links


  o  Scid vs. PC  <http://scidvspc.sourceforge.net/>


  o  Project page  <http://sourceforge.net/projects/scidvspc>

  o  Online documentation
     <http://scidvspc.sourceforge.net/doc/Contents.htm>

  o  Millbase database  <http://katar.weebly.com/index.html>

  o  Player Information resources
     <http://sourceforge.net/projects/scid/files/Player Data/>

  o  FICS  <http://www.freechess.org>

  o  FICS game archives  <http://ficsgames.org>

  o  The PGN and EPD standards
     <http://www.saremba.de/chessgml/standards/pgn/pgn-complete.htm>

  o  Pgn of players  <http://www.pgnmentor.com/files.html#players>

  o  Pgn of events  <http://www.pgnmentor.com/files.html#events>

  o  Mailing list subscribe
     <https://lists.sourceforge.net/lists/listinfo/scidvspc-users>

  o  Mailing list archive
     <http://sourceforge.net/mailarchive/forum.php?forum_name=scidvspc-
     users>

  o  Programmer's reference
     <http://scidvspc.sourceforge.net/doc/progref.html>

  o  UCI engine protocol  <http://wbec-
     ridderkerk.nl/html/UCIProtocol.html>

  o  Xboard engine protocol  <http://www.open-
     aurec.com/wbforum/WinBoard/engine-intf.html>
     Popular chess portals

  o  <http://www.chessbase.com>

  o  <http://www.theweekinchess.com/>

  o  <http://www.chesschat.org>

  o  Professional quality chess icons  <http://www.virtualpieces.net>

  o  Tango icons  <http://tango.freedesktop.org/Tango_Desktop_Project>


