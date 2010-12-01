### help.tcl: Help pages for Scid.

#################################################

set helpTitle(Contents) "$::scidName"
set helpText(Contents) {<h1>Scid vs. PC</h1>

  <ht><img splash></ht>
  <ht><a Intro>Introduction</a></ht>
  <ht><a TacticalGame>Playing against the Computer</a></ht>
  <ht><a FICS>Playing on the Internet (FICS)</a></ht>
  <ht><a Tourney>Computer Tournaments</a></ht>
  <ht><a BrowsingPGN>Browsing Games and Tournaments</a></ht>
  <ht><a TacticsTrainer>Mate in .... Puzzles</a></ht>
  <ht><a Scid>Databases and Advanced Use</a></ht>
  <br>
  <br>
  <ht><a Related>Links</a></ht>
  <ht><a Author>About</a></ht>
  <br>
  <p><footer>Updated: Scid vs. PC 4.1, September 2010</footer></p>
}
set helpTitle(Intro) "$::scidName"
set helpText(Intro) {<h1>Introduction</h1>

<p>
<url http://scidvspc.sourceforge.net/>Scid vs. PC</url>
is a usability and bug-fix fork of Scid. With it you can play chess online
or against the computer, browse tournaments downloaded in pgn format, and
create huge chess databases.</p>

<p>
Chess is a very technical thing. A single game can be analysed through and
through, openings can fill volumes, and tournaments are full of statistics
about winners, losers and openings played. Scid is a program whose original
purpose was to combine all this information into databases of various
sorts; hence it's name "Shane's Chess Information Database". As it turns
out, computers are very good at  playing  chess too. This is the focus of
Scid vs. PC</p>

<h3>Features</h3>
<ul>
<li>A Computer Tournament feature</li>
<li>Compatibility with SCID's si4 databases.</li>
<li>A rewritten Gamelist Widget using the new Ttk Treeview feature. Deleted items are greyed out, and there's a handy "Compact" button.</li>
<li>Improved Tactical Game program.</li>
<li>Redone Button bar, Toolbar and Icons.</li>
<li>The Fics interface is fairly different, with a nice accept/decline widget for multiple offers.</li>
<li>Improvements to "Mate in ..." puzzles.</li>
<li>The Chessboard/Pieces config widget has been totally overhauled. There are some nice colour and tile theme, and great piece set available if the optional TkImg package is installed.</li>
<li>The Setup Start Board has many fixes and improvements. Annoyingly, if Scid uses a tiled theme, it's setup board is displayed a different colour.</li>
<li>The main board has a handy right-click menu, and the side-to-move indicator is now on the left.</li>
<li>The Help index is now meaningful to new users, with links to the game's main features.</li>
<li>The Comment editor has been overhauled, and is much more stream-lined.</li>
<li>Restructured workings of the Analysis Engines widget. The F2 and F3 key bindings can now be set explicitly.</li>
<li>Many other improved interfaces and help files.</li>
</ul>
<h3>Note</h3>
<ul>
<li>The over ambitious Tiled Windowing System is not included. It has very many
unresolved issues, and is not very usable.</li>
<li>Wish 8.5 includes a basic implementation of themes, and there has been
widespread changes to Scid to use them. Unfortunately, the changes are not
justified for some dubious eye candy.</li>
<li>The use of si4 custom flags is not included (but this does not affect
the database, or SCID's use of them).</li>
</ul>
  <p><footer>Updated: Scid vs. PC 4.2 November 2010 </footer></p>
}

set helpTitle(FICS) "Fics"
set helpText(FICS) {<h1>Fics</h1>
<ul>
<p>
The Free Internet Chess Server (FICS) is a web portal where people from
all over the world play chess.  Features include a player rating system,
international tournaments and the ability to follow and discuss other peoples
games.</p>

<p>
To create a user account, visit <url http://www.freechess.org>www.freechess.org</url>;
though it is also possible to play anonymously.
Using Fics with Scid vs. PC is done via the
<run ::fics::config><green>Play--<gt>Internet</green></run> menu item.
</p>

<li><a FICSlogin>Logging In</a>
<br>
<li><a FICSwidget>The Fics Widget</a></li>
<br>
<li><a FICSfindopp>Finding an Opponent</a></li>
<br>
<li><a FICScommands>Fics Commands and Variables</a></li>
<br>
<li><a FICStraining>Other Features</a></li>
</ul>
<br>
  <p><footer>Updated: Scid vs. PC 3.4.1, September 2010</footer></p>
}

set helpTitle(BrowsingPGN) "PGN"
set helpText(BrowsingPGN) {<h1>Browsing Games and Tournaments</h1>

<ul>
<p>A great use for Scid is to download chess tournaments in PGN format and play
through the games. <a PGN>PGN</a> (Portable Game Notation) is the standard in
which games are stored as plain text files. They can comprise single games,
or many games pasted back to back.</p></ul>

<h3>Opening a Game</h3>

<ul><p>Once you have loaded a game from the command line or the 
<run ::file::Open><green>File--<gt>Open</green></run> dialog,
open the <run ::pgn::OpenClose><green>PGN Window</green></run>
to browse the game. Clicking on moves will move the game forward. (You can also
use the buttons or the wheel mouse in the main window). Clicking on comments
allows you to edit them.</p>

<p>In the Game Info window, you will see the names of the players and
tournament. These names are also clickable, and will show you information about
the tournament and how the player performed. This is the start of Scid's
database capabilities.</p></ul>

<h3>Browsing Games</h3>

<ul><p>If you have opened a mult-game PGN, the
<a GameList>Game List</a> widget
allows you to browse the games and select those of interest.</p>

<p>This window also serves to select and delete games from Scid's
databases.</p></ul>

<h3>Saving Changes</h3>

<ul>
<p>Beware, PGN is not the native format of Scid Databases. In general , any
changes or variations you make to a PGN file must be saved via the
<run ::pgn::savePgn .><green>File--<gt>Save PGN</green></run> menu,
and only as single games. If you open a PGN file with multiple games, Scid does not support saving any changes or comments you may add. In this case you should import the file into a 
<a Formats>Scid Database</a>, or save the individual game and manually insert it into the PGN archive.</p>
</ul>

<h3>More Information</h3>

<ul><p>For more detail about the PGN window's function, see <a PGN>here</a>.</p>
</ul>

<p><footer>Updated: Scid vs. PC 3.6.26.8, December 2009</footer></p>
}

set helpTitle(Scid) {Advanced Use}
set helpText(Scid) {<h1>Databases and Advanced Use</h1>
  <p>
  Scid is a chess database application; with it you can browse databases of
  chess games, perform searches, view best lines, and other
  statistics. Databases are implemented via a fast <a Formats>three file format</a> and populated by importing PGN archives or other databases.
  </p>

  <h4>Starting out and general help</h4>
  <ul>
  <li><a MainWindow>The <b>Main Window</b></a></li>
  <li><a Menus>Scid <b>Menus</b></a></li>
  <li><a Moves>Entering <b>Moves</b></a></li>
  <li><a Clipbase>Using the default database (<b>Clipbase</b>)</a></li>
  <li><a Searches><b>Searches</b> in Scid</a></li>
  <li><a Annotating><b>Annotating games</b></a></li>
  <li><a Hints><b>Hints</b></a></li>
  </ul>

  <h4>Other Scid windows</h4>
  <ul>
  <li><a Analysis><b>Analysis</b> window</a></li>
  <li><a Book><b>Book</b> window</a></li>
  <li><a CalVar><b>Calculation of variations</b> window</a></li>
  <li><a Comment><b>Comment editor</b> window</a></li>
  <li><a Crosstable><b>Crosstable</b> window</a></li>
  <li><a Switcher><b>Database Switcher</b> window</a></li>
  <li><a Email><b>Email</b> chess manager window</a></li>
  <li><a Finder><b>File Finder</b> window</a></li>
  <li><a GameList><b>Game List</b> window</a></li>
  <li><a Import><b>Import game</b> window</a></li>
  <li><a OpeningTrainer><b>Opening Trainer</b> window </a></li>
  <li><a Reports><b>Reports</b></a></li>
  <li><a PGN><b>PGN</b> (game text) window</a></li>
  <li><a PTracker><b>Piece Tracker</b></a></li>
  <li><a PList><b>Player Finder</b> window</a></li>
  <li><a PInfo><b>Player Info</b> window</a></li>
  <li><a TacticalGame><b>Tactical game</b> window</a></li>
  <li><a Tmt><b>Tournament Finder</b> window</a></li>
  <li><a Tree><b>Tree</b> window</a></li>
  <li><a Graphs><b>Graph</b> windows</a></li>
  <li><a TB>Using <b>Tablebases</b> in Scid</a></li>
  </ul>

  <h4>Other utilities and information</h4>
  <ul>
  <li><a Bookmarks><b>Bookmarks</b></a></li>
  <li><a Cmdline>Command-line options</a></li>
  <li><a Compact><b>Compacting</b> a database</a></li>
  <li><a Correspondence>Correspondence Chess</a></li>
  <li><a Maintenance><b>Database maintenance</b> tools</a></li>
  <li><a ECO><b>ECO</b> openings classification</a></li>
  <li><a EPD><b>EPD</b> files</a></li>
  <li><a Export><b>Exporting</b> games to text files</a></li>
  <li><a Flags>Game <b>Flags</b></a></li>
  <li><a LaTeX>Using <b>LaTeX</b> with Scid</a></li>
  <li><a Options><b>Options</b> and preferences</a></li>
  <li><a Sorting><b>Sorting</b> a database</a></li>
  <li><a Pgnscid><b>Pgnscid</b>: converting PGN files</a></li>
  <li><a NAGs>Standard <b>NAG</b> annotation values</a></li>
  <li><a Formats>Scid Database <b>file formats</b></a></li>
  <li><a Author>Contact information</a></li>
  </ul>

  <p><footer>Updated: Scid vs. PC 4.1, September 2010</footer></p>
}

###############
### Topic Index

set helpTitle(Index) "Scid Help Topic Index"
set helpText(Index) {<h1>Scid Help Index</h1>

<br>
<a Index A>  A</a> <a Index B>  B</a> <a Index C>  C</a> <a Index D>  D</a> <a Index  E> E</a> <a Index F>  F</a> <a Index G>  G</a> <a Index H>  H</a> <a Index I>  I</a> <a Index  J> J</a> <a Index K>  K</a> <a Index L>  L</a> <a Index M>  M</a> <a Index N>  N</a> <a Index O>  O</a> <a Index P>  P</a> <a Index Q>  Q</a> <a Index R>  R</a> <a Index S>  S</a> <a Index T>  T</a> <a Index U>  U</a> <a Index V>  V</a> <a Index W>  W</a> <a Index X>  X</a> <a Index Y>  Y</a> <a Index Z>  Z</a>
<br>
  <h4><name A>A </name></h4>
  <ul>
  <li><a Analysis>Analysis</a> window</li>
  <li><a Annotating>Annotating games</a></li>
  <li><a NAGs>Annotation symbols</a></li>
  <li><a Author>Author, contacting</a></li>
  <li><a MainWindow Autoplay>Autoplay mode</a></li>
  </ul>

  <h3><name B>B</name></h3>
  <ul>
  <li><a Finder>Backups</a></li>
  <li><a Tree Best>Best games</a> window</li>
  <li><a Searches Board>Board searches</a></li>
  <li><a Book>Book</a> window</li>
  <li><a BookTuning>Book</a> tuning</li>
  <li><a Bookmarks>Bookmarks</a></li>
  <li><a GameList Browsing>Browsing games</a></li>
  </ul>

  <h3><name C>C</name></h3>
  <ul>
  <li><a Maintenance Cleaner>Cleaner</a></li>
  <li><a Clipbase>Clipbase</a></li>
  <li><a Changelog>Changelog</a></li>
  <li><a Cmdline>Command-line options</a></li>
  <li><a Comment>Comment editor</a></li>
  <li><a Tourney>Computer Tournament</a></li>
  <li><a Compact>Compacting a database</a></li>
  <li><a Correspondence>Correspondence Chess</a></li>
  <li><a CCIcons>Correspondence Chess Icons</a></li>
  <li><a Author>Contact information</a></li>
  <li><a Contents>Contents</a></li>
  <li><a Crosstable>Crosstable</a> window</li>
  </ul>

  <h3><name D>D</name></h3>
  <ul>
  <li><a Compact>Database compaction</a></li>
  <li><a Formats>Database file formats</a></li>
  <li><a Maintenance>Database maintenance</a></li>
  <li><a Sorting>Database sorting</a></li>
  <li><a Switcher>Database switcher</a> window</li>
  <li><a Maintenance Twins>Deleting twin games</a></li>
  </ul>

  <h3><name E>E</name></h3>
  <ul>
  <li><a ECO Browser>ECO Browser</a> window</li>
  <li><a ECO Codes>ECO code system</a></li>
  <li><a ECO>ECO openings classification</a></li>
  <li><a Menus Edit>Edit menu</a></li>
  <li><a Email>Email manager</a> window</li>
  <li><a CCeMailChess>Email Chess</a></li>
  <li><a Analysis List>Engines list</a></li>
  <li><a Moves>Entering moves</a></li>
  <li><a EPD>EPD files</a></li>
  <li><a Export>Exporting games to text files</a></li>
  </ul>

  <h3><name F>F</name></h3>
  <ul>
  <li><a FICS>FICS</a> (Free Internet Chess Server)</li>
  <li><a Finder>File Finder</a></li>
  <li><a FindBestMove>Training: Find best move</a></li>
  <li><a Formats>File formats</a></li>
  <li><a Menus File>File menu</a></li>
  <li><a Searches Filter>Filter</a></li>
  <li><a Export>Filter, exporting</a></li>
  <li><a Graphs Filter>Filter graph</a></li>
  <li><a Finder>Finder</a></li>
  <li><a Flags>Flags</a></li>
  <li><a Options Fonts>Fonts</a></li>
  </ul>

  <h3><name G>G</name></h3>
  <ul>
  <li><a Flags>Game flags</a></li>
  <li><a MainWindow GameInfo>Game Info</a></li>
  <li><a GameList>Game List</a> window</li>
  <li><a Menus Game>Game menu</a></li>
  <li><a Searches Header>General searches</a></li>
  <li><a Graphs>Graph windows</a></li>
  </ul>

  <h3><name H>H</name></h3>
  <ul>
  <li><a Searches Header>Header searches</a></li>
  <li><a Menus Help>Help menu</a></li>
  <li><a Hints>Hints</a></li>
  </ul>

  <h3><name I>I</name></h3>
  <ul>
  <li><a Import>Import</a> window</li>
  <li><a Moves Informant>Informant Symbols</a></li>
  <li><a CCGameListIcons>Icons for Correspondence Chess</a></li>
  <li><a FICS>Internet play</a></li>
  </ul>

  <h3><name J>J</name></h3>
  <ul>
  </ul>

  <h3><name K>K</name></h3>
  <ul>
  </ul>

  <h3><name L>L</name></h3>
  <ul>
  <li><a LaTeX>LaTeX</a> output format</li>
  <li><a Related>Links</a></li>
  </ul>

  <h3><name M>M</name></h3>
  <ul>
  <li><a MainWindow>Main Window</a></li>
  <li><a Maintenance>Maintenance tools</a></li>
  <li><a TreeMasks>Masks for Trees</a></li>
  <li><a Searches Material>Material/pattern searches</a></li>
  <li><a Menus>Menus</a></li>
  <li><a GameList Browsing>Merging games</a></li>
  <li><a Moves>Move entry</a></li>
  </ul>

  <h3><name N>N</name></h3>
  <ul>
  <li><a Maintenance Editing>Names, editing</a></li>
  <li><a Maintenance Spellcheck>Names, spellchecking</a></li>
  <li><a NAGs>NAG annotation values</a></li>
  <li><a Annotating Null>Null moves</a></li>
  </ul>

  <h3><name O>O</name></h3>
  <ul>
  <li><a ECO>Opening classification (ECO)</a></li>
  <li><a Reports Opening>Opening report</a> window</li>
  <li><a OpeningTrainer>Training: Openings</a></li>
  <li><a Options>Options</a></li>
  </ul>

  <h3><name P>P</name></h3>
  <ul>
  <li><a PGN>PGN</a> window</li>
  <li><a Pgnscid>Pgnscid</a></li>
  <li><a FICS>Play on the Internet (FICS)</a></li>
  <li><a PTracker>Piece Tracker</a> window</li>
  <li><a PList>Player Finder</a> window</li>
  <li><a PInfo>Player Info</a> window</li>
  <li><a Reports Player>Player report</a> window</li>
  <li><a TacticalGame>Play tactical game</a></li>
  <li><a SeriousGame>Play serious game</a></li>
  <li><a TacticsTrainer>Puzzles</a> - Mate in ... </li>
  </ul>

  <h3><name Q>Q</name></h3>
  <ul>
  </ul>

  <h3><name R>R</name></h3>
  <ul>
  <li><a Graphs Rating>Rating graph</a></li>
  <li><a Repertoire>Repertoire editor</a></li>
  </ul>

  <h3><name S>S</name></h3>
  <ul>
  <li><a Searches>Searches</a></li>
  <li><a Menus Search>Search menu</a></li>
  <li><a SeriousGame>Play serious game</a></li>
  <li><a Sorting>Sorting a database</a></li>
  <li><a Maintenance Spellcheck>Spellchecking names</a></li>
  <li><a Switcher>Switcher</a> window</li>
  </ul>

  <h3><name T>T</name></h3>
  <ul>
  <li><a TB>Tablebases</a></li>
  <li><a TacticalGame>Tactical game</a></li>
  <li><a Menus Tools>Tools menu</a></li>
  <li><a Tourney>Tournament</a>of Chess Engines</li>
  <li><a Tmt>Tournament finder</a></li>
  <li><a FindBestMove>Training: Find best move</a></li>
  <li><a OpeningTrainer>Training: Openings</a></li>
  <li><a FICStraining>Training: FICS lectures</a></li>
  <li><a Tree>Tree window</a></li>
  <li><a Moves Trial>Trial mode</a></li>
  <li><a Maintenance Twins>Twin (duplicate) games</a></li>
  </ul>

  <h3><name U>U</name></h3>
  <ul>
  </ul>

  <h3><name V>V</name></h3>
  <ul>
  <li><a Annotating Vars>Variations</a></li>
  </ul>

  <h3><name W>W</name></h3>
  <ul>
  <li><a Menus Windows>Windows menu</a></li>
  </ul>

  <h3><name X>X</name></h3>
  <ul>
  <li><a CCXfcc>Xfcc support</a></li>
  </ul>

  <h3><name Y>Y</name></h3>
  <ul>
  </ul>

  <h3><name Z>Z</name></h3>
  <ul>
  </ul>

  <p><footer>Updated: Scid vs PC 4.0, June 2010</footer></p>
}



####################
### Hints page:
set helpTitle(Hints) "Scid Hints"
set helpText(Hints) {<h1>Scid Hints</h1>

  <h4>Can I get Scid to load a database when it starts?</h4>
  <p>
  Yes, you can add databases, PGN files or <a EPD>EPD files</a>
  to the command line. For example:
  <ul>
  <li> <b>scid  mybase  games.pgn.gz</b> </li>
  </ul>
  will load the Scid Database <b>mybase</b> and also load the
  Gzip-compressed PGN file <b>games.pgn.gz</b>.
  </p>

  <h4>Is there an easier way to change the board size than using the
  options menu?</h4>
  <p>
  Yes, you can use the shortcut keys <b>Control+Shift+LeftArrow</b> and
  <b>Control+Shift+RightArrow</b> to decrease or increase the board size.
  </p>

  <h4>I am training by playing through a game, so I do not want Scid to
  print the next move in the game information area below the chessboard.
  Can I hide it?</h4>
  <p>
  You can hide the next move by pressing the <b>right</b> mouse button in the
  game information area, and selecting <b>Hide next move</b> from the
  menu that appears.
  </p>

  <h4>How can I see the ECO opening code for the current position?</h4>
  <p>
  The ECO code is displayed on the bottom line of the game
  information box, below the chessboard in the <a MainWindow>main window</a>,
  if you have the ECO classification file (<b>scid.eco</b>) loaded. <br>
  The <a ECO>ECO codes</a> help page explains how to load the ECO classification
  file and save options so it will be loaded every time you start Scid.
  </p>

  <h4>I am entering a game, and I am up to move 30, but just saw that move
  10 was wrong. How can I correct it and keep all the moves after it?</h4>
  <p>
  You can use the <a Import>Import</a> window; see the
  <a Moves Mistakes>entering moves</a> help page for more information.
  </p>

  <h4>How do I copy games from one database to another?</h4>
  <p>
  Use the <a Switcher>database switcher window</a>: drag from the source
  database to the target database to copy all games in the source database
  <a Searches Filter>filter</a>.
  </p>

  <h4>Every time I enter a move where one already exists, I get a
  "Replace move?" dialog box. How do I avoid that?</h4>
  <p>
  Turn it off with the <b>Ask before replacing moves</b> option in the
  <menu>Options: Moves</menu> menu.
  Or, get into the habit of taking back moves using the right-mouse button,
  which actually removes the move from the game if you are at the last move of
  the game.
  </p>

  <h4>How can I use the tree window on a selection of games, not my whole
  database?</h4>
  <p>
  Use the <a Clipbase>clipbase</a>. Set your database filter to contain the
  games you want to use the tree on, then copy them to the clipbase using the
  <a Switcher>database switcher</a>. Then, just open the tree window in the
  clipbase.
  </p>

  <h4>The Tree is slow for large databases. How do I speed it up?</h4>
  <p>
  Save the Tree cache often, to save tree results for future use.
  See the caching section of the <a Tree>Tree</a> help page for details.
  </p>

  <h4>How can I edit the PGN representation of the game directly?</h4>
  <p>
  You cannot use the <a PGN>PGN</a> window to edit the current game, but you can
  still edit its PGN representation using the <a Import>Import game</a> window.
  Just open it (shortcut key: <b>Control+Shift+I</b>) and then press the
  <b>Paste current game</b> button, then edit the game, then press <b>Import</b>.
  </p>

  <h4>My database has several spellings for some player names. How do I
  correct them all?</h4>
  <p>
  You can edit individual names or spellcheck all the names in a database
  with the commands in the <menu>File: Maintenance</menu> menu.
  See the <a Maintenance Editing>maintenance</a> page.
  </p>

  <h4>I have two databases open: one with my own games, and a large database of
  grandmaster games. How do I compare one of my games to those in the large
  database?</h4>
  <p>
  Just open the <a Tree>Tree</a> window for the reference database and
  switch back to the game to compare by means of the database
  switcher. Alternatively, a base can directly be opened as tree via
  the <term>File</term> menu.
  </p>

  <p><footer>Updated: Scid 3.6.28, December 2008</footer></p>
}


####################
### Main window help:

set helpTitle(MainWindow) "Scid Main Window"
set helpText(MainWindow) {<h1>Scid Main Window</h1>
  <p>
  The main window displays a large board with the current game,
  a game information box, and a few other widgets.
  Separate help pages describe the <a Menus>menus</a> and ways to
  <a Moves>enter chess moves</a>.
  </p>

  <h4>Game navigation buttons</h4>
  <p>
  The navigation buttons above the board have the following meanings [and key bindings].
  <ul>
  <li> <button tb_start> Move to the start of the game  [Home] </li>
  <li> <button tb_prev> Move back one move  [Left] </li>
  <li> <button tb_next> Move forward one move  [Right] </li>
  <li> <button tb_end> Move to the end of the game  [End] </li>
  <li> <button tb_invar> Move into a <a Annotating Vars>variation</a>  [v] </li>
  <li> <button tb_outvar> Move out of the current variation  [z] </li>
  <li> <button tb_addvar> Add a new variation  [control+a]</li>
  <li> <button autoplay_off> Start/stop <a MainWindow Autoplay>autoplay mode</a> [control+z] </li>
  <li> <button tb_trial> Start/stop <a Moves Trial>trial mode</a> [control+space] </li>
  <li> <button tb_flip> Flip the board [control+f]</li>
  <li> <button tb_showmenu> Show/hide menus</li>
  <li> <button tb_gameinfo> Show/hide game information</li>
  </ul>

  <h4><name GameInfo>Game Information Widget</name></h4>
  <p>
  The area below the chessboard shows general information about the current game. 
  (Display options for this widget are found in the <b>Options-<gt>Game Information</b> menu).
  </p>
  <p>
  The first line shows the <b>Player Names</b> (and ranks).
  Then the <b>Moves</b> and any <b>Comments</b>,
  and the <b>Event</b> and <b>Site</b> fields.
  </p>
  <p>
  Below follows the Game number (and any flags), Result, Material evaluation,
   and <a ECO>ECO</a> (Encyclopedia of Chess
  Openings) code for the current position (if appearing in the current ECO file).
  </p>
  <p>
  If Scid can find a suitable FIDE.spf photo file (either in <b>~/.scidvspc</b> or Scid's
  share directory) these photos will appear. Clicking on the photos minimizes them.
  </p>

  <h4>Game Context Menu</h4>
  <p>
  Right clicking the main board draws with commonly used options.
  </p>
  <h4>Material Values</h4>
  <p>
  On the right hand side of the board the material balance can be
  displayed by small piece symbols. They repesent the piece <b>difference</b>
  between black and white.
  </p>

  <h4>Tablebases</h4>
  <p>
  The game information area also displays tablebase results whenever the
  displayed position reaches a material configuration found in a
  tablebase file. See the <a TB>tablebases</a> help page for details.
  </p>

  <h4>The Status Bar</h4>
  <p>
  The status bar shows information about the current database.
  The first field indicates the game status: <b>XX</b> means it has been
  altered and not yet saved, while <b>--</b> means it is unchanged,
  and <b>%%</b> indicates the database is read-only (not alterable).
  Also shown is how many games are currently in the game <a Searches Filter>filter</a>.
  </p>

  <h4><name Autoplay>Autoplay Mode</name></h4>
  <p>
  In autoplay mode, Scid automatically plays the moves in the current game,
  moving forward until the end of the game. The time delay between moves can
  be set from the <green>Options--<gt>Moves</green> menu
  </p>
  <p>
  The shortcut key <b>control+z</b> starts or stops autoplay mode, and
  you can also stop with <b>escape</b>.
  </p>
  <p>
  If you start autoplay mode when the <a Analysis>analysis window</a> is open,
  the game is <term>annotated</term>: the score and analysis for each position
  are added to the game as a new variation just before each move is made.
  See the <a Analysis>analysis window</a> help page for details.
  </p>

  <p><footer>Updated: Scid vs. PC 4.2 November 2010 </footer></p>
}


####################
### Menus help screen:

set helpTitle(Menus) "Menus"
set helpText(Menus) {<h1>Scid Menus</h1>

  <h3><name File>File</name></h3>
  <ul>
  <li><menu>New</menu>: Creates a new empty Scid Database.</li>
  <li><menu>Open</menu>: Opens an existing Scid Database.</li>
  <li><menu>Close</menu>: Closes the current Scid Database.</li>
  <li><menu>Finder</menu>: Opens the <a Finder>File Finder</a>.</li>
  <li><menu>Bookmarks</menu>: <a Bookmarks>Bookmarks</a> and bookmark
  functions.</li>
  <li><menu>Maintenance</menu>: Database <a Maintenance>maintenance</a>
  functions.</li>
  <ul>
  <li><menu>Maintenance window</menu>: Opens/closes the database maintenance
  window.</li>
  <li><menu>Delete twin games</menu>: Finds <a Maintenance Twins>twin</a>
  games in the database.</li>
  <li><menu>ECO-Classify games</menu>: Recomputes the
  <a ECO>ECO code</a> for all games in the database. </li>
  <li><menu>Name editor</menu>: Replaces all occurrences of a player,
  event site or round name.</li>
  </ul>
  <li><menu>Read-Only</menu>: Makes the current database read-only.</li>
  <li><menu>Base 1/2/3/4/5</menu>: These commands let you switch between
  the four available database slots and the <a Clipbase>clipbase</a>
  database.</li>
  <li><menu>Exit</menu>: Exits Scid. </li>
  </ul>

  <h3><name Edit>Edit</name></h3>
  <ul>
  <li><menu>Add Variation</menu>: Adds a new empty variation for the
  next move, or for the previous move if there is no next move yet.</li>
  <li><menu>Delete Variation</menu>: Provides a submenu of variations for
  the current move, so one can be deleted.</li>
  <li><menu>Make First Variation</menu>: Promotes a variation to be the
  first variation of the current move.</li>
  <li><menu>Promote Variation to Main line</menu>: Promotes a variation
  to be the main line, swapping it with its parent.</li>
  <li><menu>Try Variation</menu>: Enters <a Moves Trial>trial mode</a> for
  testing a temporary variation without altering the current game.</li>
  <li><menu>Strip</menu>: Strips all comments or variations from the current
  game.</li>
  <br>
  <li><menu>Empty Clipbase</menu>: Empties the <a Clipbase>clipbase</a>
  so it contains no games.</li>
  <li><menu>Copy this game to clipbase</menu>: Copies the current game
  to the <a Clipbase>clipbase</a> database.</li>
  <li><menu>Paste last clipbase game</menu>: Pastes the active game of
  the <a Clipbase>clipbase</a> to be the active game of the current
  database.</li>
  <br>
  <li><menu>Setup start board</menu>: Sets the starting position for the
  current game.</li>
  <li><menu>Paste start board</menu>: Sets the start board from the current
  text selection (clipboard).</li>
  </ul>

  <h3><name Game>Game</name></h3>
  <ul>
  <li><menu>New Game</menu>: Resets the active game to an empty state,
  discarding any unsaved changes.</li>
  <li><menu>Load First/Previous/Next/Last Game</menu>: These load the first,
  previous, next or last game in the <a Searches Filter>filter</a>.</li>
  <li><menu>Reload this game</menu>: Reloads the current game, discarding
  any changes made.</li>
  <li><menu>Load Game Number</menu>: Loads the game given its game number
  in the current database.</li>
  <br>
  <li><menu>Save: Replace game</menu>: Saves the current game, replacing
  its original version in the database.</li>
  <li><menu>Save: Add new game</menu>: Saves the current game as a new
  game, appending to the end of the database.</li>
  <br>
  <li><menu>Identify opening</menu>: Finds the deepest
  position in the current game that is in the ECO file.</li>
  <li><menu>Goto move number</menu>: Goes to the specified move number in
  the current game.</li>
  <li><menu>Find novelty</menu>: Finds the first move of the current game
  that has not been played before.</li>
  </ul>

  <h3><name Search>Search</name></h3>
  <ul>
  <li><menu>Reset Filter</menu>: Resets the <a Searches Filter>filter</a>
  so all games are included.</li>
  <li><menu>Negate filter</menu>: Inverts the filter to only include
  games that were excluded.</li>
  <br>
  <li><menu>Current board</menu>: Searches for the
  <a Searches Board>current board</a> position.</li>
  <li><menu>Header</menu>: Searches by <a Searches Header>header</a>
  information such as player names.</li>
  <li><menu>Material/Pattern</menu>: Searches by
  <a Searches Material>material</a> or chessboard patterns</a>.</li>
  <br>
  <li><menu>Using search file</menu>: Searches using
  <a Searches Settings>settings</a> from a SearchOptions file.</li>
  </ul>

  <h3><name Windows>Windows</name></h3>
  <ul>
  <li><menu>Comment Editor</menu>: Opens/closes the
  <a Comment>Comment Editor</a> window.</li>
  <li><menu>Game List window</menu>: Opens/closes the
  <a GameList>Game List window</a>.</li>
  <li><menu>PGN window</menu>: Opens/closes the
  <a PGN>PGN window</a>.</li>
  <li><menu>Crosstable</menu>: Constructs a tournament
  <a Crosstable>crosstable</a> for the current game. </li>
  <li><menu>Tournament Finder</menu>: Opens/closes the
  <a Tmt>Tournament Finder</a> window.</li>
  <br>
  <li><menu>Database switcher</menu>: Opens/closes the
  <a Switcher>Database Switcher</a> window, which lets you switch to
  another database or copy games between databases easily.</li>
  <li><menu>Maintenance window</menu>: Opens/closes the database
  <a Maintenance>maintenance</a> window.</li>
  <br>
  <li><menu>ECO Browser</menu>: Opens/closes the
  <a ECO browser>ECO Browser</a> window.</li>
  <li><menu>Statistics window</menu>: Opens/closes the
  <term>Filter statistics window</term> which gives a win/loss summary
  of the games in the <a Searches Filter>filter.</a></li>
  <li><menu>Tree window</menu>: Opens/closes the <a Tree>tree window</a>.</li>
  <li><menu>Endgame Tablebase window</menu>: Opens/closes the window that
  displays <a TB>tablebase</a> information.</li>
  </ul>

  <h3><name Tools>Tools</name></h3>
  <ul>
  <li><menu>Analysis engine</menu>: Starts/stops the chess analysis
  engine, displaying the evaluation of the current position
  in the <a Analysis>analysis window</a>.</li>
  <li><menu>Analysis engine #2</menu>: Starts/stops a second analysis
  engine.</li>
  <li><menu>Email manager</menu>: Opens/closes the <a Email>email manager</a>
  window, for managing email correspondence games.</li>
  <br>
  <li><menu>Opening report</menu>: Generates an
  <a Reports Opening>opening report</a> for the current position.</li>
  <li><menu>Piece Tracker</menu>: Opens the <a PTracker>piece tracker</a>
  window.</li>
  <br>
  <li><menu>Player information</menu>: Displays <a PInfo>player information</a>
  for one of the two players of the current game.</li>
  <li><menu>Rating graph</menu>: Displays the
  <a Graphs Rating>rating graph</a>.</li>
  <li><menu>Score graph</menu>: Displays the
  <a Graphs Score>score graph</a>.</li>
  <br>
  <li><menu>Export current game</menu>: Saves the current game to a text
  file in PGN, HTML or LaTeX format. See the <a Export>export</a> help
  page.</li>
  <li><menu>Export all filter games</menu>: Saves all games in the
  search <a Searches Filter>filter</a> to a text file in PGN, HTML or
  LaTeX format. See the <a Export>export</a> help page.</li>
  <br>
  <li><menu>Import PGN game</menu>: Opens the <a Import>Import window</a>
  for entering a game by typing or pasting its text in
  <a PGN>PGN format</a>.</li>
  <li><menu>Import file of PGN games</menu>: Imports a whole file containing
  games in PGN format to the current database. Note, that several PGN
  files can be selected in this dialogue at once.</li>
  </ul>

  <h3><name Options>Options</name></h3>
  <p>
  This menu provides entries for setting most of Scid's configurable
  options.
  The <menu>Save options</menu> entry saves the current options to the
  file "<b>~/.scid/scidrc</b>" (or <b>scid.opt</b> in the
  directory of the Scid executable programs for Windows users);
  this file is loaded each time you start up Scid.
  </p>

  <h3><name Help>Help</name></h3>
  <p>
  This menu contains help functions, and access to the tip of the day
  window or the startup window which provides information about the
  files Scid loaded when it started.
  </p>

  <p><footer>Updated: Scid 3.6.26, October 2008</footer></p>
}


####################
### Entering moves help:

set helpTitle(Moves) "Entering moves"
set helpText(Moves) {<h1>Entering Chess Moves</h1>
  <p>
  Scid allow moves to be made using either the mouse or keyboard.
  Use the mouse to click on a piece, and then on the
destination square. Alternatively you may drag the piece. There exists a
<b>suggested move</b> feature which, if enabled, will highlight all squares
to which there is a legal move.
  </p>
  <p><i>
  If you want to enter a variation without being asked for a
  confirmation, use the middle mouse button of the mouse to enter the
  move.
  </i></p>
  <p>
  Keyboard moves are made using the standard notation, with the exception of castling.
  To castle kingside enter <b>OK</b>, or queen-side use <b>OQ</b>. See below for more info.
  </p>

  <h4>Retracting a move</h4>
  <p>
  To take back a move, press the Left-Arrow, Control+Delete
  or Control+Backspace keys.
  </p>

  <h4>Replacing old moves</h4>
  <p>
  When you enter a move where a move already exists,
  Scid will ask if you want to replace the
  move (when the old move and all after it will be lost), or
  add the new move as a variation. If one finds this annoying, 
  it is possible to skip this dialog
  via the <green>Options--<gt>Moves</green> menu option
  </p>

  <h4><name Trial>Trial mode</name></h4>
  <p>
  If you are studying a game and reach a position where you want to try
  an alternative variation on the board without altering the game, select
  <b>Try variation</b> from the <menu>Edit</menu> menu to enter trial
  mode. In this mode, you can make temporary moves and changes to the
  game, then return to the original position when you exit trial mode.
  </p>

  <h3><name Mistakes>Correcting mistakes</name></h3>
  <p>
  If you are entering a game and suddenly see an incorrect move several
  moves earlier, it is possible to correct it without losing the extra
  moves you have added. The only way is to edit the PGN representation
  of the game: open the <a Import>Import</a> window, select "Paste current
  game", correct the incorrect move, then select "Import".
  </p>

  <h3>Keyboard move entry</h3>
  <p>
  To enter moves at the keyboard, simply press letter and digit
  keys. Note that accepted moves should be in <term>SAN notation</term>,
  <i>without</i> the capture symbol (x) or the promotion symbol (=).
  Moves are matched case-insensitively, so you can type
  [n][f][3] instead of Nf3, for example -- but see the note below
  about conflicts with pawn moves.
  </p>
  <p>
  To ensure that no move is a prefix of any other move, the notation
  for kingside and queenside castling is [O][K] and
  [O][Q] respectively, instead of the usual O-O and O-O-O.
  </p>
  <p>
  As you enter a move, the status bar will show the list of matching moves.
  You can press the [space] bar at any time to choose the first
  matching move in the list and add it to the game.
  To delete a character, press [Backspace] or [Delete].
  </p>
  <p>
  <b>Note</b> that a lower-case letter matches to a pawn first, so a
  [b] can match to a pawn or Bishop, but if there is a conflict
  you must use a capital [B] for the Bishop move.
  </p>

  <h4>Auto-Completion</h4>
  <p>
  In the Options menu, you can turn on or off <term>Auto-Completion</term>
  of moves.
  With auto-completion, a move is made as soon as you have typed enough
  to distinguish it from any other legal move. For example, with
  auto-completion, you would only need to type [n][f] instead
  of [n][f][3] for <b>Nf3</b> in the starting position.
  </p>

  <h3><name Null>Entering null moves</name></h3>
  <p>
  <a Annotating Null>Null</a> (empty) moves can be useful in variations, where
  you want to skip a move for one side. You can enter a null move with the
  mouse by capturing one king with the other king, or with the keyboard by
  typing "<b>--</b>" (that is, pressing the minus key twice).
  </p>

  <h3><name Informant>Entering common annotation symbols</h3>
  <p>
  You can also add common <a NAGs>annotation symbols</a> using the keyboard
  in the main window, without needing to use the <a Comment>comment editor</a>
  window. The following list shows which symbols you can add, and their
  keyboard shortcuts:
  <ul>
  <li> !  : [!][Return] </li>
  <li> ?  : [?][Return] </li>
  <li> !? : [!][?][Return] </li>
  <li> ?! : [?][!][Return] </li>
  <li> !! : [!][!][Return] </li>
  <li> ?? : [?][?][Return] </li>
  <li> </li>
  <li> +- : [+][-] </li>
  <li> +/-: [+][/] </li>
  <li> += : [+][=] </li>
  <li> =  : [=][Return] </li>
  <li> -+ : [-][+] </li>
  <li> -/+: [-][/] </li>
  <li> =+ : [=][+] </li>
  </ul>
  <b>Note</b> Scid uses some of these symbols for automatic
  annotations, also. To this end, these symbols have to be associated
  with a certain pawn value. These pawn values can be set via Options
  / Game information / Configure Informant values.

  <p><footer>Updated: Scid vs. PC 4.2 November 2010 </footer></p>
}


########################################
### Searches help screen:

set helpTitle(Searches) "Searches"
set helpText(Searches) {<h1>Searches in Scid</h1>
  <p>
  Scid can perform many different types of searches.
  The main ones are:
  <ul>
  <li><b>General information</b> searches (such as players, result, date) in the game header </li>
  <li><b>Game positions</b> identical to the current board </li>
  <li>Specific <b>material and piece</b> patterns </li>
  </ul>
  <p>
  <i>In addition to these, there is also an automatic search mode called the
  <a Tree>Tree window</a>, explained separately</i>.
  </p>

  <h3><name Filter>The Filter</name></h3>
  <p>
  The Scid filter represents
  a subset of games in the current database. At any time, each game is either
  included in or excluded from the filter (as per the <a GameList>Game List</a> widget).
  </p>
  <p>
  With each new search, you can choose to restrict the existing
  filter, add to it, or reset it and search the whole database.
  This choice permits complex searches to be built up incrementally.
  </p>
  <p><i>Do not confuse Filtered games with Deleted games. They are separate ideas... See <a GameList>here</a> for more info</i></p>
  <p>
  You can also copy all games in the filter of one database to another
  using the <a Switcher>database switcher</a> window.
  </p>
  <p>
  With exact position, <a Tree>tree</a> or material/pattern searches, the
  move number of the first matching position of each matching game is
  remembered, so when you load each game it will show the matching position
  automatically.
  </p>
  <p>
  <i>Most searches only apply to the main line moves of a game, not to variations</i>.
  </p>

  <h3><name Header>General (Header) Searches</name></h3>
  <p>
  This search is for game information stored
  in the header; such as player names, date, result, flags and ratings.
  </p>
  <p>
  For a game to match a Header search, <b>all</b> fields that you
  specify must match.
  </p>
  <p>
  The name fields (White, Black, Event, Site and Round) match on any text
  inside the name, case-insensitive and ignoring spaces.
  </p>
  <p>
  You can do case-sensitive wildcard searches for the White, Black, Event,
  Site and Round fields (with <b>?</b> representing one character and
  <b>*</b> representing zero or more characters) by putting the
  search text in double quotes. For example a search for the site <b>USA</b>
  will find American cities and also <b>Lausanne SUI</b>, which is probably
  not what you wanted! A search for the site <b>"*USA"</b> (remember to
  use the double-quotes) will only match cities in the United States.
  </p>
  <p>
  If you are searching for a particular player (or pair of opponents) as White
  or Black and it does not matter what color they played, select the
  <b>Ignore Colors</b> option.
  </p>
  <p>
  Finally, the Header search can be used to find any text
  (case-sensitive and without wildcards) in the PGN representation of
  each game.  You may enter up to three text phrases, and they must
  all appear in a game for it to be a match.  This search is very
  useful for searching in the comments or extra tags of a game (such
  as <b>lost on time</b> or <b>Annotator</b>), or for a move sequence
  like <b>Bxh7+</b> and <b>Kxh7</b> for a bishop sacrifice on h7 that
  was accepted.  However, this type of search can be <i>very</i> slow
  since all the games that match other criteria must be decoded and
  scanned for the text phrases.  So it is a good idea to limit these
  searches as much as possible.  Here are some examples.  To find
  games with under-promotions to a rook, search for <b>=R</b> and also
  set the <b>Promotions</b> flag to Yes.  When searching for text that
  would appear in comments, set the <b>Comments</b> flag to Yes.  If
  you are searching for the moves <b>Bxh7+</b> and <b>Kxh7</b>, you
  may want to restrict the search to games with a 1-0 result and at
  least 40 half-moves, for example, or do a material/pattern search
  first to find games where a white bishop moves to h7.
  </p>
  <p>
  <i>Note - if a search by <a ECO>ECO</a> code is performed, games
  that have no ECO code attached are ignored</i>.
  </p>

  <h3><name Board>Current Board Searches</name></h3>
  <p>
  This search finds games that contain the currently displayed position,
  ignoring castling and <i>en passant</i> rights.
  </p>
  <p>
  There are four different board searches:
  <ul>
  <li> <b>Exact</b> - the two positions must match on every square </li>
  <li> <b>Pawns</b> - the pawn structure must match exactly, but other pieces
  can be anywhere </li>
  <li> <b>Files</b> - the number of white and black pawns on each file must match
  exactly, but other pieces can be anywhere </li>
  <li> <b>Material</b> - pawns and pieces can be anywhere </li>
  </ul>
  <p>
  The pawns search is useful for studying openings by pawn structure, and
  the files and material searches are useful for finding similar positions
  in an endgame.
  </p>
  <p>
  To search for an arbitrary position, you can set the position first
  (from the <menu>Edit: Setup Start Board</menu> menu) and then
  start the search.
  </p>
  <p>
  You can request that the search look in variations (instead of only
  examining actual game moves) by selecting <b>Look in variations</b>
  , but this may slow the search if your database
  is large with many games and variations.
  </p>

  <h3><name Material>Material/Pattern Searches</name></h3>
  <p>
  This powerful feature is useful for finding end-game or middle-game themes.
  You can specify minimum and maximum amounts of each type of material,
  and patterns such as a Bishop on f7, or a pawn on the f-file.
  </p>
  <p>
  A number of common material and pattern settings are provided, such
  as Rook vs. Pawn endings, or isolated Queens pawns.
  </p>
  <p>
  <i>Hint -
  The speed of pattern searches can vary widely, and be reduced 
  by setting restrictions intelligently. For example,
  if you set the minimum move number to 20 for an ending, all games that
  end in under 20 moves can be skipped</i>.
  </p>

  <h3><name Settings>Saving Search Settings</name></h3>
  <p>
  The Material/Pattern and Header search windows provide a
  <term>Save settings</term> button. This lets you save the current
  search settings for later use, to a <term>SearchOptions</term> file
  (<b>.sso</b>).
  To search using a previously saved SearchOptions (.sso) file, select
  <menu>Open</menu> from the <menu>Search</menu> menu.
  </p>

  <h3>Search Times and Skipped Games</h3>
  <p>
  Most searches produce a message indicating the time taken and the number
  of games that were <term>skipped</term>. A skipped game is one that can
  be excluded from the search without decoding any of its moves, based on
  information stored in the index. See the help page on
  <a Formats>file formats</a> for more information.
  </p>

  <p><footer>Updated: Scid vs. PC 4.1 September 2010</footer></p>
}


#################
### Clipbase help:

set helpTitle(Clipbase) "The Clipbase"
set helpText(Clipbase) {<h1>The Default Database</h1>
  <p>
  In addition to physical databases existing on disk, Scid provides
  a transient one known as <term>clipbase</term>. It is opened by default, and used to cut and paste games between other bases. Additionally, each base has a 
  game numbered 0 which also acts as a scratch game.
  </p>
  <p>
  The clipbase is useful as a temporary database, for merging
  the results of searches on more than one database or for treating the
  results of a search as a separate database.
  For example, assume you want to prepare for an opponent and have searched
  a database so the <a Searches Filter>filter</a> contains only games where
  the opponent played White.
  You can copy these games to the clipbase (by dragging from their database
  to the clipbase in the <a Switcher>database switcher</a> window),
  switch to the clipbase database, and then open
  the <a Tree>Tree window</a> to examine that players repertoire.
  </p>
<h4>Notes</h4>
  <p>
  You can copy games in the filter of one database directly to another
  opened database (without needing the clipbase as an intermediary
  location) using the <a Switcher>database switcher</a> window.
  </p>
  <p>
  Note that the clipbase <i>cannot</i> be closed; selecting the
  <green>File--<gt>Close</green> command while in the clipbase is equivalent
  to <green>Edit--<gt>Empty Clipbase</green> which empties the clipbase.
  </p>
  <p>
  The clipbase has a limit of 100,000 games at any time, since it exists in
  memory only.
  </p>

  <p><footer>Updated: Scid vs. PC 4.1 September 2010</footer></p>
}

#################################
### Variations and comments help:

set helpTitle(Annotating) "Annotating games"
set helpText(Annotating) {<h1>Annotating Games</h1>
  <p>
  Scid lets you add notes to games. There are three types of
  annotation you can add after a move: symbols, a comment, and
  variations. This section describes manual annotations, see the <a
  Analysis Annotating>Analyis</a> for engine supported analysis.
  </p>

  <h3>Symbols and comments</h3>
  <p>
  Symbols are used to indicate an evaluation of the position (such as
  "+-" or "=") or point out good ("!") and bad ("?") moves, while
  comments can be any text. To add symbols and comments to a game, use
  the <a Comment>Comment editor</a> window.
  There is also a help page listing <a NAGs>standard symbol values</a>.
  </p>
  <p>
  Note that each move can have more than one annotation symbol, but only
  one comment. A comment before the first move of the game is printed as text
  before the start of the game.
  </p>

  <h3><name Vars>Variations</name></h3>
  <p>
  A <term>variation</term> of a move is an alternative sequence of
  moves at a particular point in a game. Variations can contain
  comments and even recursively have sub-variations. The buttons
  above the board with a "<b>V</b>" symbol, and commands in the
  <menu>Edit</menu> menu, can be used to create, navigate and edit
  variations.
  </p>

  <h4>Keyboard shortcuts</h4>
  <p>
  When a move has variations, they are shown in the game information
  area. The first will be named <b>v1</b>, the second <b>v2</b>, etc.
  You can click on a variation to enter it, or press "<b>v</b>". In
  the latter case the <term>Variation</term> window will pop up
  allowing to select a variation using the cursor keys. Setting
  Options / Moves / Show variation window will pop up this window
  automatically every time a move with a variation is found while
  navigating through the game using the cursor keys. In the variation
  window one can enter the variation by selecting it with the up/down
  cursor keys and hitting enter or clicking on it with the mouse. This
  allows for navigation through the game with the cursor keys only.
  To leave a variation, you can use the "<b>z</b>" shortcut key. At
  the beginning of the variation, the up arrow can be used
  alternatively.
  </p>

  <h3><name Null>Null moves</name></h3>
  <p>
  Sometimes, you may find it useful in a variation to skip over a move
  for one side. For example, you may want to add the move 14.Bd3 to
  a variation and point out that it threatens 15.Bxh7+ Kxh7 16.Ng5+
  with an attack. You can do this by making a <term>null move</term>
  between 14.Bd3 and 15.Bxh7+, in the above example. A null move is
  displayed as "<b>--</b>" and can be inserted using the mouse by making
  an illegal move of capturing one king with the other, or from the
  keyboard by typing "<b>--</b>" (two minus signs).
  </p>
  <p>
  Note that null moves are not a part of the PGN Standard, so if you
  export games with null moves to a PGN file, Scid will provide (among
  other export options) an option to preserve null moves or convert them
  to comments for compatibility with other software.
  See the <a Export>Exporting</a> help page for more details.
  </p>
  <p>
  Also note, that Scid is capable of handling the move <term>Z0</term>
  as a null move, a notation that is common in some commercial chess
  applications.
  </p>

  <p><footer>Updated: Scid 3.6.26, October 2008</footer></p>
}

###############################
### Comment editor window help:

set helpTitle(Comment) "Comment Editor window"
set helpText(Comment) {<h1>The Comment Editor Window</h1>
  <p>
  The Comment Editor window lets you add or edit comments and symbolic
  annotation symbols for moves in the active chess game.
  </p>

  <h3>Annotation symbols</h3>
  <p>
  Scid uses the <a Related>PGN Standard</a>
  for annotation symbols, accepting
  <a NAGs>NAG (numeric annotation glyph)</a> values for annotations.
  Some of the most common symbols (such as "!" or "+-") are displayed
  as symbols, and have a button in the comment editor window for fast
  entry. For other symbols, you can enter the appropriate
  numeric NAG value which is a number from 1 to 255.
  For example, the NAG value 36 means "White has the initiative" and will
  be displayed as "$36" in the <a PGN>PGN text</a> of the game.
  </p>
  <p>
  See the help page of <a NAGs>NAG values</a> for NAG values defined
  by the PGN Standard.
  </p>
  <p>
  <b>Hint:</b> You can add the common move evaluation symbols (!, ?, !!,
  ??, !? and ?!) while in the main window, without needing
  to use the comment editor window, by typing the symbol followed by
  the [Return] key.
  This is especially useful if you are <a Moves>entering chess moves</a>
  using the keyboard.
  </p>

  <h3>Comments</h3>
  <p>
  You can edit comments by typing in the text area provided and using
  the Clear, Revert and Store buttons.  You do not need to press the
  Store button to update a comment; it is automatically updated
  whenever you move to another position in the game.
  </p>
  <p>
  <b>Hint:</b> To add a comment before the first move in a variation,
  go to the first move and hit the left arrow key once and then insert
  the comment.
  </p>

  <h3>Coloring squares</h3>
  <p>
  You can color any square with any color using a special embedded command
  which can appear anywhere in a comment. The command format is:
  </p>
  <ul>
  <li><b>[%mark square color]</b><li>
  </ul>
  <p>
  where <b>square</b> is a square name like d4 and <b>color</b> is any
  recognized color name (such as red, blue4, darkGreen, lightSteelBlue, etc)
  or RGB code (a <b>#</b> followed by six hexadecimal digits, such as #a0b0c8).
  If the color is omitted, it defaults to <red>red</red>.
  </p>
  <p>
  A comment may contain any number of color commands, but each must have
  in its own <b>[%mark ...]</b> tag.
  For example, the comment text</p>
  <p>
  Now d6 [%mark d6] is weak and the knight can attack it
  from b5. [%mark b5 #000070]
  </p>
  <p>
  will color d6 <red>red</red> and b5 with the dark-blue color
  <darkblue>#000070</darkblue>.
  </p>

  <h3>Drawing arrows</h3>
  <p>
  You can draw an arrow from one square to another using a special
  comment command similar to the for coloring squares described above.
  The format is:
  </p>
  <ul>
  <li><b>[%arrow fromSquare toSquare color]</b><li>
  </ul>
  <p>
  where <b>fromSquare</b> and <b>toSquare</b> are square names like d4
  and <b>color</b> is any recognized color name (such as red, blue4, etc)
  or RGB code (like #a0b0c0).
  If the color is omitted, it defaults to <red>red</red>.
  </p>
  <p>
  For example, the comment text
  </p>
  <p>
  The c3-knight and c4-bishop control the weak d5 square.
  [%arrow c3 d5 red] [%arrow c4 d5 blue]
  </p>
  <p>
  will draw a red arrow from c3 to d5 and a blue one from c4 to d5.
  </p>

  <p>
  <b>Note</b>
  Coloured squares and arrows can be entered directly on the board
  without the use of the Comment editor by using the mouse
  buttons. For coloured squares one can Shift-click on the square in
  question. Shift-Left button markes the square in green, the middle
  button in yellow, the right button in red. To draw arrows one can
  Ctrl-click on the source and target squares. The left mouse button
  again results in a green, the middle in a yellow and the right mouse
  button in a red arrow.
  </p>

  <p><footer>Updated: Scid 3.6.26, October 2008</footer></p>
}

####################
### Crosstable window help:

set helpTitle(Crosstable) "Crosstable window"
set helpText(Crosstable) {<h1>The Crosstable Window</h1>
  <p>
  The crosstable window shows the tournament crosstable for the
  current game. Each time you refresh the crosstable window (by
  pressing its Refresh button, by pressing the <b>Return</b> key in the
  crosstable window, or by typing <b>Control+Shift+X</b> in the
  <a MainWindow>main</a> or <a GameList>game list</a> windows), Scid
  searches for all games in the same tournament as the current game.
  </p>
  <p>
  Any game played up to <b>twelve months before or after</b> the current game,
  with the <b>exact same Event and Site tags</b>, is considered to be in
  the tournament.
  </p>
  <p>
  A single left-mouse button click on any result in the crosstable
  loads the corresponding game.
  You can add all the games in the tournament to the
  <a Searches Filter>filter</a>
  with the <b>Add to filter</b> button in the crosstable window.
  </p>

  <h4>Crosstable window menus</h4>
  <p>
  The <menu>File</menu> menu lets you print the current table to a file
  in plain text, LaTeX or HTML table format.
  </p>
  <p>
  The <menu>Display</menu> menu allows you to choose the table format:
  <b>All-play-all</b>, <b>Swiss</b> or <b>Knockout</b> or <b>Auto</b>.
  </p>
  <p>
  The all-play-all format (for round-robin-type events) has a limit of 30
  players, but the Swiss format (for tournaments with many players) can
  display up to 200 players and up to 20 rounds. <b>Auto</b>, which chooses
  the best format automatically for each tournament, is the default.
  </p>
  <p>
  Note that Scid uses the <b>Round</b> tag of each game to produce a Swiss
  crosstable, so you will not see any games in the Swiss table for a tournament
  if its games do not have numeric round values: 1, 2, 3, etc.
  </p>
  <p>
  The Display menu also lets you customize the data presented to
  include or exclude ratings, countries and player titles. You can also
  choose whether color allocations in Swiss tables are displayed.
  </p>
  <p>
  The <b>Separate score groups</b> option only affects the layout of the table
  when the players are sorted by score: it causes a blank line to be inserted
  between each group of players with the same score.
  </p>
  <p>
  The <menu>Sort</menu> menu allows you to sort the players by name, rating
  or score; by score is the default.
  </p>
  <p>
  The <menu>Color</menu> menu lets you turn color (hypertext) display on or off.
  Since it can take a long time to format and display large crosstables in
  hypertext, selecting <b>Plain text</b> for large events will save a
  lot of time.
  However, in plain text mode you cannot click on players or games.
  </p>

  <h4>Duplicate games in crosstables</h4>
  <p>
  To get good results with the crosstable, you should mark duplicate games
  for deletion and your games should have consistent spelling of player,
  site and event names.
  See the <a Maintenance>database maintenance</a> page for help on
  deleting duplicate games and editing (or spellchecking)
  player/event/site names.
  </p>

  <p><footer>Updated: Scid 3.6.15, May 2007</footer></p>
}


####################
### Database switcher help:

set helpTitle(Switcher) "Database Switcher"
set helpText(Switcher) {<h1>The Database Switcher Window</h1>
  <p>
  The 
  <run ::windows::switcher::Open><green>Database Switcher</green></run>
provides a view which makes it easy to
  switch between databases or copy games between databases.
  The name, <a Searches Filter>filter</a> state and graphic type icon
  of each database is displayed, and the active database is highlighted
  with a yellow background.
  </p>
  <p>
  You can open the database switcher window from the <menu>Windows</menu> menu,
  or by its shortcut key: <b>Control+D</b>.
  </p>
  <p>
  To copy all the filtered games in one database to another, drag with the
  left mouse button from the source base to the target base. You will then
  see a confirmation dialog (if the target database is not the
  <a Clipbase>clipbase</a>) if the games can be copied, or an error message
  if the games cannot be copied (for example, if a selected database is not
  open).
  </p>
  <p>
  Pressing right mouse button over a database produces a popup menu applying
  to that database, from which you can change the database type icon or
  reset its <a Searches Filter>filter</a>. You can also use this menu to
  change the orientation of the window (to arrange the database slots
  vertically or horizontally) which is useful for smaller screens.
  </p>

  <p><footer>Updated: Scid 3.6.2, December 2006</footer></p>
}


####################
### File Finder window help:

set helpTitle(Finder) "File Finder Window"
set helpText(Finder) {<h1>File Finder Window</h1>
  <p>
  With the <run ::file::finder::Open><green>File--<gt>Finder</green></run>
  you can browse the
filesystem for Scid files, perform backups and other file
operations.
  </p>

  <p>
  Clicking on a file will open it, while right-click will
  show a <b>context menu</b> from which you can perform
  various file operations:

  <ul>
      <li><term>Open</term>	Open the file in question.
      The same as left-clicking the file.</li>
      <li><term>Backup</term>	Makes a copy of the file
      with the current date and time appended to its name.</li>
      <li><term>Copy</term>	Copy the selected database to a new
      location.</li>
      <li><term>Move</term>	Move the selected database to a new
      location.</li>
      <li><term>Delete</term>	Delete the selected database.</li>
   </ul>
  <p>
   These functions are especially helpful for Scid
databases, which consist of several files.
  </p>

  <h3>Looking in subdirectories</h3>
  <p>
  This checkbox makes Scid recursively examine subdirectories for compatible
  files.  This, however, can take a long time, so you may not
  want to do it for large directory trees.  The process can be
  interrupted by pressing the <b>Stop</b> button.
  </p>

  <h3>Games field</h3>
  <p>
  The meaning of this field depends on the file type;
  For Databases and PGN files it is
  the number of games, for EPD files, the number of
  positions, and for repertoire files it is the number of
  (include or exclude) lines.
  </p>
  <p>
  For all file types except Scid Databases, the file size is
  an <b>estimate</b> taken by examining only the first 64 kilobytes
  of the file, and is represented by a tilde (~).
  </p>


  <p><footer>Updated: Scid vs. PC 4.1, August 2010</footer></p>
}

####################
### Tournament Finder window help:

set helpTitle(Tmt) "Tournament Finder window"
set helpText(Tmt) {<h1>The Tournament Finder window</h1>
  <p>
  The <term>Tournament Finder</term> lets you find tournaments in the
  current database. It scans all the database games and collates data
  about the tournaments found. Note that two games are considered to
  be in the same tournament if they have the same Event tag, same Site
  tag and were played within three months of each other.
  </p>
  <p>
  You can limit the list of tournaments by the number of players and
  games, date, mean Elo rating and country, by editing the fields below
  the tournament list and then pressing the <b>Update</b> button.
  </p>
  <p>
  The displayed list can be sorted by date, number of players, number
  of games, mean Elo rating, site, event or the surname of the winner.
  Select the category from the <menu>Sort</menu> menu or click on a
  column title to change the sort field.
  </p>
  <p>
  To load the first game of any displayed tournament, just click the
  left mouse button when its line is highlighted. This will also
  update the <a Crosstable>Crosstable</a> window if it is open.
  If you press the right mouse button instead, the game will be loaded
  and the Crosstable window will be opened even if it is closed.
  </p>
  <p>
  To speed up the tournament searching process, it is a good idea to
  set a fairly small date range (like a few years at most) or select
  a particular country (by its three-letter standard code). Doing
  these will greatly reduce the number of games Scid has to consider
  when trying to form tournaments out of the games in the database.
  </p>

  <p><footer>Updated: Scid 3.6.2, December 2006</footer></p>
}

####################
### GameList window help:

set helpTitle(GameList) "Game List window"
set helpText(GameList) {<h1>The Game List Window</h1>

  <p> The <run ::windows::gamelist::Open><green>Game List</green></run>
widget allows easy perusal of all (filtered) games in the
currently open Database / PGN archive.
</p>
<p>A common use of the widget is to search for games by entering
text in the <b>Find</b> entry box. Clicking <b>Filter</b>
shows all matching games.
<i>For more info about Searches and Filters, see <a Searches>here</a>, or below</i>.
</p>
<p>
Buttons:
<ul>
<li><b>Reset</b> - resets game filter</li>
<li><b>Remove</b> - removes highlighted game(s) from filter</li>
<li><b>Browse</b> - shows highlighted game in a pop-up window (resizable using Control+Wheel or Control+Shift+Left/Right). From here it is possible to <a GameList Browsing>merge</a> games.</li>
<li><b>Current</b> - highlights the current game, <i>if it has not been filtered.</i></li>
<li><b>Delete</b> - toggles the delete flag for highlighted games.</li>
<li><b>Compact</b> - perform database compaction.</li>
</ul>
</p>
<p>
Other features include:
<ul>
<li>Load games by double-clicking.</li>
<li>Multiple games can be selected by using Shift or Control while single clicking.</li>
<li>Resize column widths by dragging the column edge.</li>
<li>Sort games by single clicking the column title. </li>
<li><b>Note</b>: <i>Sort resets the game filter, and the current game cannot be replaced</i>.</li>
</ul>


  <h3>Deleted and Filtered Games</h3>
  <p>
  Scid has two notions of removed games - which can be confusing.</p>

  <p>The first is <b>Filtered Games</b>.  In the Gamelist widget,
  selecting some game(s) and pressing "Remove" or "Filter"
  will <b>filter</b> those games. They will disappear from the Game List
  widget, but can easily be found again with the "Reset" button. Filtering games
  has <b>no effect</b> on the database.</p>

  <p><b>Deleted</b> games on the other hand, are not removed from the Game List widget.
  They are simply marked as deleted, and no further action is taken until
  the database is compacted - whence they will be <b>permanently deleted</b> from the database.
This can be done by the <b>Compact</b> button, or 
  from the <a Maintenance>maintenance</a> window.</p>
<p><i>Note - the default database (Clipbase) cannot be compacted</i>.</p>
  
  <h3><name Browsing>Merging Games</name></h3>
  <p>
  The Merge Game feature provides a way to include the
  selected game as a variation of the current game. Scid finds the
  deepest point where the selected game differs from the current
  game (taking transpositions into account) and adds a variation
  for the selected game at that position. You can change the number
  of moves of the selected game to be shown, depending on whether you
  are interested in adding the whole game or just its opening phase.
  </p>

  <p><footer>Updated: Scid vs. PC 4.1, September 2010</footer></p>
}


####################
### Import window help:

set helpTitle(Import) "Import window"
set helpText(Import) {<h1>The Import Window</h1>
  <p>
  Scids Import window provides an easy way for you to paste a game
  in <a PGN>PGN format</a> into Scid from some other application or window.
  </p>
  <p>
  The large white frame in the window is where you type or paste
  the text of the game in PGN format, and the gray frame below it
  provides feedback of any errors or warnings.
  </p>

  <h3>Editing the current game with the Import window</h3>
  <p>
  The Import window also doubles as a convenient way to make a few changes
  to the current game: you can paste the current game into the
  Import window (with the <b>Paste current game</b> button), edit the
  text, and click <b>Import</b> when done.
  </p>

  <h3>PGN tags in the Import window</h3>
  <p>
  Scid expects to see PGN header tags such as
  <ul>
  <li> <b>[Result "*"]</b> </li>
  </ul>
  before any moves, but you can just paste in a game fragment like
  <ul>
  <li> <b>1.e4 e5 2.Bc4 Bc5 3.Qh5?! Nf6?? 4.Qxf7# 1-0</b> </li>
  </ul>
  without any header tags and Scid will import it.
  </p>

  <h3>Using PGN files in Scid</h3>
  <p>
  If you want to use a PGN format file in Scid but do not
  want to convert it with <a Pgnscid>pgnscid</a> first, there are two
  possible ways.
  </p>
  <p>
  First, you can import the games in the file to an existing database
  with the <menu>Tools: Import file of PGN games...</menu> menu command.
  </p>
  <p>
  The alternative is to open the PGN file directly in Scid. However, PGN
  format files are opened read-only and consume more memory than a
  comparable Scid Database, so this is only recommended for relatively
  small PGN files.
  </p>

  <p><footer>Updated: Scid 3.6.2, December 2006</footer></p>
}

####################
### Exporting help:

set helpTitle(Export) "Exporting games"
set helpText(Export) {<h1>Exporting Games</h1>
  <p>
  You can use commands under the <menu>Tools</menu> menu to export the
  current game or all games in the current filter to a text file.
  </p>
  <p>
  Four text file formats are available: <a PGN>PGN</a> (portable game
  notation), HTML (for web pages), HTML and JavaScript (for
  interactive web pages) and LaTeX (a popular typesetting system).
  </p>
  <p>
  When exporting, you can choose to create a new file, or add the
  games to an existing file of games exported by Scid.
  </p>

  <h3>Diagrams</h3>
  <p>
  When exporting in HTML or LaTeX format, Scid will automatically add
  a diagram wherever a diagram <a NAGs>nag</a> ("D") or a <a
  Comment>comment</a> that starts with the character "#" appears in
  the game.
  </p>

  <h3><name Null>Null moves in PGN Export</name></h3>
  <p>
  Scid allows <a Annotating Null>null (empty) moves</a> to be stored
  in games, as they can be helpful when annotating games using
  variations.  However, the PGN Standard has no null move concept. So
  if you export Scid games with null moves to a PGN file, other
  PGN-reading software will not be able to read the null moves.
  </p>
  <p>
  To solve this problem, Scid provides an extra option,
  <b>Convert null moves to comments</b>, when exporting games in PGN format.
  If you want to create a PGN file that other software can use, turn this
  option on and variations containing null moves will be converted to
  comments. However, if you want to create a PGN file that can be imported
  back into Scid later with null moves preserved, leave the option off.
  </p>

  <h3>HTML Export</h3>
  <p>
  Scid can export games to an HTML file. For diagrams to appear, you
  will need the diagram images (distributed with Scid in the directory
  "<b>bitmaps/</b>") to be in a subdirectory <b>bitmaps/</b> under the
  directory the HTML file is in.
  </p>

  <h3>HTML with JavaScript Export</h3>
  <p>
  While the HTML export generates a static file that may contain
  static board diagrams, this format offers dynamic HTML, that allows
  to move through the game interactively with the mouse.
  </p>
  <p>
  This format consists of several files that need to be stored in a
  specific structure. Therefore, it is advisable to first generate a
  empty folder that will contain these files. The name of the main
  file can be specified and it will get the extension html (e.g.
  mygame.html). This file should be loaded by the web browser. The
  other files are required to exist in exactly the position the export
  filter places them. However, the whole folder can easily be uploaded
  to some web server.
  </p>

  <h3>LaTeX Export</h3>
  <p>
  Scid can export games to a LaTeX file.  Games be printed two columns
  to a page and moves are in figurine algebraic notation with proper
  translation of the NAG symbols. Diagrams are added whenever a
  <term>D</term> comment is found.
  </p>
  <p>
  See the <a LaTeX>Using LaTeX with Scid</a> help page for more information.
  </p>

  <p><footer>Updated: Scid 3.6.26, October 2008</footer></p>
}

####################
### LaTeX help:

set helpTitle(LaTeX) "Scid and LaTeX"
set helpText(LaTeX) {<h1>Using LaTeX with Scid</h1>
  <p>
  Scid can save games and opening reports to files in LaTeX format.
  LaTeX is an extension to TeX, a popular typesetting system.
  </p>
  <p>
  To typeset the LaTeX files produced by Scid, you must have
  LaTeX (of course) and have the "chess12" chess font package installed.
  This font package is usually not part of standard LaTeX installations,
  so even if you have LaTeX, you may not have the chess font.
  </p>
  <p>
  For information about downloading and installing the LaTeX chess font,
  visit the
  <url http://scid.sourceforge.net/latex.html>Using LaTeX with Scid</url>
  page at the <url http://scid.sourceforge.net/>Scid website</url>.
  </p>

  <p><footer>Updated: Scid 3.6.2, December 2006</footer></p>
}

####################
### PGN window help:

set helpTitle(PGN) "PGN window"
set helpText(PGN) {<h1>The PGN Window</h1>

  <p>
  PGN (Portable Game Notation) is a common standard for representing
  chess games.  A PGN file consists of two
  sections; a header containing tags such as
  <b>[White "Kasparov, Gary"]</b>
  and
  <b>[Result "1/2-1/2"]</b>, and a body containing the actual moves in standard
  algebraic notation (SAN) along with any variations, <a NAGs>annotation
  symbols</a> and <a Comment>comments</a>.
  </p>

  <p>
  Scids PGN window displays the contents of the current game in
  standard PGN representation. In the move text, comments appear {in
     braces} and variations appear (in parentheses).
  </p>

  <h3>Actions in the PGN window</h3>
  <p>
  You can use the PGN window to navigate around the game: clicking the
  left mouse button on a move will jump to that move. Click the left
  mouse button on a comment will edit it.  The arrow keys and
  (<b>v</b> and <b>z</b> keys for entering or leaving variations) work
  for game navigation just as in the main window.  As in the main
  window, hitting v will cause the <term>Variation</term> window to
  pop up allowing to select a variation using the cursor keys. Setting
  Options / Moves / Show variation window will pop up this window
  automatically every time a move with a variation is found while
  navigating through the game using the cursor keys. In the variation
  window one can enter the variation by selecting it with the up/down
  cursor keys and hitting enter or clicking on it with the mouse. This
  allows for navigation through the game with the cursor keys only.
  Clicking on a move with middle mouse button will display a small
  board. Clicking on right mouse button will popup a contextual menu.
  </p>
  <p>
  From the context menu the following functions are available
  <ul>
     <li><term>Delete Variation:</term>
     Deletes the current variation
     </li>
     <li><term>Make First Variation:</term>
     Moves the current variation to the first position of all
     variations on that level
     </li>
     <li><term>Promote Variation to Mainline</term>
     Promotes the current variation to the mainline and demotes the
     current mainline to a variation.
     </li>
     <li><term>Strip:Moves from the beginning</term>
     </li>
     <li><term>Strip:Moves to the End</term>
     </li>
     <li><term>Strip:Comments</term>
     Removes all comments
     </li>
     <li><term>Strip:Variations</term>
     Removes all variations
     </li>
  </ul>
  </p>

  <h3>PGN display options</h3>
  <p>
  The PGN window menus contain options that affect the PGN window display.
  Scid can display the game in color or plain text -- see the
  <menu>Display</menu> menu in the PGN window.
  The color display is easier to read, and allows you to select moves and
  comments using the mouse, but it is much slower to update. For very long
  games, you may want to select plain text display.
  </p>
  <p>
  You can also alter the format of comments and variations, choosing
  to display them indented on a separate line for greater visibility.
  </p>
  <p>
  The PGN display options, and the size of the PGN window, are saved to the
  options file whenever you <b>Save Options</b> from the <menu>Options</menu>
  menu of the main window.
  </p>

  <h3>Editting PGN directly</h3>
  <p>
  You cannot use the PGN window to edit the current game, but you can
  still edit its PGN representation using the <a Import>Import game</a> window.
  Just open it (shortcut key: <b>Control+Shift+I</b>) and then press the
  <b>Paste current game</b> button, then edit the game, then press <b>Import</b>.
  </p>

  <p><footer>Updated: Scid 3.6.26, October 2008</footer></p>
}


####################
### Piece Tracker help:

set helpTitle(PTracker) "Piece tracker"
set helpText(PTracker) {<h1>The Piece Tracker Window</h1>
  <p>
  The <term>Piece Tracker</term> is a tool that tracks the movements
  of a particular piece in all games in the current filter, and
  generates a "footprint" showing how often each square has been
  visited by the piece.
  </p>
  <p>
  To use the Piece Tracker, first make sure the filter contains the
  games you are interested in, such as games reaching a particular
  opening position or all games where a certain player had the white pieces.
  Then, select the piece to track and set other tracking options; these are
  explained below. Then press the <b>Update</b> button.
  </p>
  <p>
  The tracked piece movement information is displayed in two ways: a
  graphical "footprint", and a text list with one line of data per square.
  </p>

  <h3>Selecting the tracked piece</h3>
  <p>
  The chess pieces are displayed as in the standard chess starting position
  below the footprint chart. A single piece (such as the White b1 knight or
  the Black d7 pawn) can be selected with the left mouse button, and all
  pieces of the same type and color (such as all White pawns or both Black
  rooks) can be selected using the right mouse button.
  </p>

  <h3>Other piece tracker settings</h3>
  <p>
  The move number range controls when tracking should start and stop in
  each game. The default range of 1-20 (meaning tracking should stop after
  Black's 20th move) is appropriate for examining opening themes, but (for
  example) a range like 15-35 would be better when looking for middlegame
  trends.
  </p>
  <p>
  There are two types of statistic the tracker can generate:
  <ul>
  <li> <b>% games with move to square</b>: shows what proportion of filter
  games contain a move by the tracked piece to each square. This is
  the default setting and usually the most suitable choice.
  <li> <b>% time in each square</b>: shows the proportion of time the
  tracked piece has spent on each square.
  </ul>
  </p>

  <h3>Hints</h3>
  <p>
  There are (at least) three good uses for the Piece Tracker: opening
  preparation, middlegame themes, and player preparation.
  </p>
  <p>
  For opening preparation, use the piece tracker with the <a Tree>Tree</a>
  opened. By tracking pieces you can see trends in the current opening
  such as common pawn pushes, knight outposts, and where the bishops are
  most often placed. You may find it useful to set the move number range
  to start after the current move in the game, so the moves made to reach
  the current position are not included in the statistics.
  </p>
  <p>
  For middlegame themes, the piece tracker can be useful when the filter
  has been set to contain a certain ECO range (using a
  <a Searches Header>Header search</a>) or perhaps a pattern such as a
  White IQP (using a <a Searches Material>Material/pattern search</a>).
  Set the move range to something suitable (such as 20-40), and track
  pieces to see pawn pushes in the late middlegame or early endgame,
  for example.
  </p>
  <p>
  For player preparation, use a <a Searches Header>Header search</a> or
  the <a PInfo>Player information</a> window to find all games by a
  certain player with one color. The Piece Tracker can then be used to
  discover how likely the player is to fianchetto bishops, castle
  queenside, or set up a d5 or e5 pawn wedge, for example.
  </p>

  <p><footer>Updated: Scid 3.6.2, December 2006</footer></p>
}


####################
### Repertoire editor help:

set helpTitle(Repertoire) "Repertoire editor"
set helpText(Repertoire) {<h1>The Repertoire Editor</h1>
<p>The Repertoire Editor has been removed since Scid vs. PC 4.2.
<br>
Simlilar and more powerful features are available in the <a TreeMasks>Masks for Trees</a> window.
</p>

  <p><footer>Updated: Scid vs. PC 4.2, November 2010</footer></p>
}

####################
### Tree window help:

set helpTitle(Tree) "Tree Window"
set helpText(Tree) {<h1>Tree Window</h1>
  <p>
  The <run ::tree::make><green>Tree Window</green></run>
  is an advanced Scid feature. The idea is to
  show the most successful moves continuing from the current position.
  </p>
  <p>
  The Tree is updated whenever the
  main board changes. This can require lots of CPU time,
  and be slow for large databases, but dynamic updates
  can be disabled deselecting the <b>Refresh</b> check-box.
  </p>
  <p>
  The <a Searches Filter>filter</a> will also be changed 
  if <b>Adjust Filter</b> is checked. In this event, only games containing the
  current position will be shown in the filter.
</p>
  <p>
  Clicking the left mouse button on a move in the tree window adds
  that move to the game.
  </p>
<p>
  <i>Be wary of doing filter operations while the Tree Window is open,
  as <b>THE TREE MAY OVERRIDE THE FILTER</b>. To perform searches, and open new bases,
it is best to close the Tree Window first.</i>
  </p>
  <h3>Opening a Tree</h3>
  <p>To open the Tree Window one can either first open a
  database and then choose <b>Windows--<gt>Tree Window</b> menu,
  use the <b>Control-t</b> short-cut, or <b>Open Base as Tree</b> right from the file menu.
  This last method means games in Database A can be examined with the tree from a different database.</p>

  <h3>Tree Statistics</h3>
  <p>
  The tree window shows the <a ECO>ECO code</a> (if any), frequency,
  and score of each move.
  The <term>score</term> is always computed from the <b>White</b>
  perspective, so 100% means all White wins and 0% means all Black
  wins. Scores are highlighted for moves that have good (green) or bad
  (red) results. On average a move should score 53.8% for white,
  highlighting appears if a move scores more than 3% better or worse
  than this average and if at least 15 games are contained in the
  database. The <term>AvElo</term> (average Elo) corresponds to the
  player's on move and <term>Perf</term> (performance) represents the
  opponent's strength. Additionally, <term>AvYear</term> shows the
  average year of games played in this move and <term>%Draws</term>
  gives the percentage of draws for the line displayed. All these
  values are calculated for the database displayed in the tree, and
  therefore depend of course on the games in this database.
  </p>
  <p>
  The moves in the tree window can be sorted by move (alphabetically),
  ECO code, frequency, or score. You can change the sort method using
    the <menu>Sort</menu> menu.
    </p>
  <h3>Tree Masks</h3>
  <p> Tree Masks
  provide additional information beyond pure statistical data, and can be
  imagined as a transparent layer above the current tree that holds additional
  data. For more info see <a TreeMasks>here</a>.
  </p>
  </h3>
  <h3><name Best>Best Games Window</name></h3>
  <p>
  This button <button b_list> will show the <term>Best games</term> widget.
  This is a list of the highest-rated games in the current tree.  The games
  are listed in order of average rating, and you can restrict the list
  to show games with a particular result and also limit the number of
  games shown in this list.
  </p>

  <h3><name Graph>Tree Graph Window</name></h3>
  <p>
  The <b>Tree Graph</b> <button b_bargraph> presents a graphical display of the
  <b>performance</b> of each move in the current tree.  Only
  moves that have been played at least 1% of the time, and on 5 occasions
  are displayed.  Percentage scores are always from White's
  perspective even when it is Black to move. The graphs can be saved
  in PostScript format via the file menu.
  </p>
  <p>
  In the tree graph, a red line is plotted showing the mean over all games
  from the current position, and the area between 50 and 55% (where most
  standard openings are expected to score) is colored blue
  to assist comparison of moves. Note that white usually scores around 55%
  in master level chess.
  </p>

  <h3><name Lock>Locking the Tree Window</name></h3>
  <p>
  Each tree window is associated with a specific base, that is, if
  several bases are opened simultaneously, several tree windows may
  exist. If the <term>Lock</term> button in the tree window is
  enabled, closing the tree window will also close the database
  associated with this specific tree. Additionally, this also closes
  associated graph or best games windows. If the <term>Lock</term>
  button is not checked closing the tree will leave all these windows
  opened and just close the tree view of the base.
  </p>
  <p>
  Note that opening a base as tree from the file menu will
  automatically lock the database by default.
  </p>

  <h3><name Training>Training</name></h3>
  <p>
  When the <term>Training</term> checkbox in the tree window is selected,
  Scid will randomly make a move every time you add a move to the game.
  The move Scid chooses depends on database statistics, so a move played
  in 80% of database games will be chosen by Scid with 80% probability.
  Turning on this feature, then hiding (or iconifying) the Tree window and
  playing openings against a large database, is a great way to test your
  knowledge of your opening repertoire. Another option to train an
  opening offers <a OpeningTrainer>Training / Openings</a>.
  </p>

  <h3>Caching for faster results</h3>
  <p>
  Scid maintains a cache of tree search results for the positions with the
  most matching games. If you move forward and back in a game in tree mode,
  you will see the tree window update almost instantly when the position
  being searched for is in the cache.
  </p>
  <p>
  The tree window has a file menu command named <term>Save Cache</term>.
  When you select this, the current contents of the tree cache in memory
  are written to a file (with the suffix <b>.stc</b>) to speed up future
  use of Tree mode with this database.
  </p>
  <p>
  The <term>Fill cache file</term> command in the file menu of the tree
  window fills the cache file with data for many opening positions.
  It does a tree search for about 100 of the most common opening positions,
  then saves the cache file.
  </p>
  <p>
  The maximum number of lines in the Cache can be configured by File /
  Cache size. The default are up to 1000 lines.
  </p>
  <p>
  Alternatively, one can fill the cache also with the content of a
  base or a game by choosing File / Fill Cache with base and File /
  Fill Cache with game, respectively. The cache will be filled with
  the contents of these including all variations. This is most helpful
  if one has one or more repertoire bases that can serve as input. (See
  also <a OpeningTrainer> about this type of bases.)
  <p>
  Tree refresh can be dramatically enhanced if the database is sorted
  by ECO code then compacted (see the <a Maintenance>maintenance</a>
  window). Once this is achieved (the whole process can last several
  hours), turn on the option <term>Fast mode</term>. The refresh of
  the Tree window will be 20 times faster in average at the cost of
  some inaccuracies (games not in current filter will not be taken
  into account). By turning off the <term>Fast mode</term> option you
  will see the difference in the number of games when all the
  transpositions are taken into account.  If you want to get a preview
  of statistics then get a precise Tree, use the option <term>Fast and
  slow mode</term> 
  </p>
  <p>
  Note that a tree cache (.stc) file is completely redundant; you can remove
  it without affecting the database, and in fact it is removed by Scid
  whenever an action occurs that could leave it out of date -- for example,
  adding or replacing a game, or sorting the database.
  </p>

  <p><footer>Updated: Scid vs. PC 4.2, November 2010</footer></p>
}

set helpTitle(TreeMasks) "Masks for Trees"
set helpText(TreeMasks) {<h1>Masks for Trees</h1>
  <p>
  The <a Tree>The Tree window</a> displays information on all the moves
  made from the current position in games in the database.
  </p>
  <p>
  To add additional informations beyond pure statistical data a
  <term>Mask</term> can be defined. One can imagine a
  <term>Mask</term> as a transparent layer above the current tree, that
  holds additional data e.g. commentaries for moves or positions, own
  evaluations and ones own opening repertoir. <term>Masks</term> are
  stored in a Mask file (.stm) and thus are independent of the
  databases to be used with. That is, one can define a
  <term>Mask</term> once and use it with various databases by just
  loading it from the <term>Tree</term> windows menu.
  </p>
  <p>
  As soon as a <term>Mask</term> file is opened, the displays of
  the <term>Tree</term> window change. First of all, all moves from
  the current position that are present in the mask are highlighted.
  Additionally, NAGs and markers may show up in front of a move or
  commentaries concerning the move will show up at the end of its
  line. Finally, the current postition may also hold a comment.
  </p>
  <p>
  <b>Note</b>: The indepencence of <term>Masks</term> from a database
  make them a very powerfull tool to handle opening repertoirs.
  Contrary to the traditional way of opening lines, <term>Masks</term>
  have the advantage to handle transpositions transparently, simply
  cause they are based on the current positions instead of a line
  leading to it.
  </p>
  <h3>Using a Masks</h3>
  <p>
  As <term>Masks</term> operate on the tree view of a given database,
  first of all the tree view has to be opened either by <menu>Window /
  Tree window</menu> or the shortcut <b>ctrl-t</b>. For starting out
  it makes sense to open a larger reference database as this
  simplifies the addition of moves to a <term>Mask</term>. However,
  Masks work with every database, even the <term>Clipbase</term>, that
  is one could also import a collection of games from a PGN file to
  the Clipbase to set up a <term>Mask</term>.
  </p>
  <p>
  Now, a mask file has to be created or loaded. These files use the
  extension .stm. To create a new mask file select <menu>Mask /
  New</menu> from the <term>Tree</term> windows menu. Similarly, an
  existing mask can be opened using <menu>Mask / Open</menu>. Finally,
  <menu>Mask / Open recent</menu> is a shortcut to the recently used
  <term>Mask</term> files. 
  </p>
  <p>
  Once a Mask file is opened new commentary can be added to this
  specific mask. Note again, that the Mask is independent of database
  used for its creation. It can later applied to any database of ones
  liking. For an opening repertoir it might thus make sense to
  generate two masks, one for the White and one for the Black
  openings.
  </p>
  <p>
  To add markers or comments to moves, first add the move
  to the mask by choosing <term>Add to mask</term> from the context
  menu available by clicking on the line with the right mouse button.
  After a line was added, it is highlighted in <blue>blue</blue>
  within the tree window. Similarly, a move can be removed from the
  mask by <menu>Remove from mask</menu> from the context menu.
  </p>
  <p>
  <b>Note</b>: If the move to be added is not displayed in the tree
  window Scid offers a list of all possible moves by means of the
  context menu. As this might be quite a bunch of moves, they are
  split into several context menu items at the end of the available
  choices. All are labled by <menu>Add this move to mask</menu> and in
  case necessary numbered. Just select a move from one of those lists
  if it does not show up in the tree anyway.
  <p>
  After a move was added to the <term>Mask</term> and one can select
  the following markers from the context menu. These markers will show
  up left to the move annotated:
  <ul>
  <li><term>NAG</term> symbols are the simplest annotation symbol. The
  menu displays only those nags sensible for a move (not a position)
  which results in the following symbols possible <term>!!, !, !?, ?!,
  ?, ??, ~</term>
  </li>
  <li>By selecting <menu>Marker 1</menu> and <menu>Marker 2</menu> up
  to two additional graphical markers can be attached to a move. They
  are mainly meant to handle opening repertoirs. The available options
  are:
     <ul>
     <li> <img ::rep::_tb_include> Include line in repertoire</li>
     <li> <img ::rep::_tb_exclude> Exclude line from repertoire</li>
     <li> <img ::tree::mask::imageMainLine> Main Line</li>
     <li> <img tb_bkm> Bookmark</li>
     <li> <img ::tree::mask::imageWhite> White</li>
     <li> <img ::tree::mask::imageBlack> Black</li>
     <li> <img tb_new> New line</li>
     <li> <img tb_rfilter> To be verified by further analysis</li>
     <li> <img tb_msearch> To train</li>
     <li> <img tb_help> Dubious line</li>
     <li> <img tb_cut> To remove</li>
     </ul>
	  To remove a marker just select the item <menu>No marker</menu>.
  </li>
  <li><term>Color</term> Allows to add a little coloured square in
  front of the move for ones own highlighting. To remove it again
  select <menu>White</menu></li>
  <li><term>Comment move</term> allows to add a textual comment for
  the line. This comment is shown  right to the line it is
  associated. Note that only a part of the first line shows up there
  to give some visual feedback that commentary exists. The whole
  comment shows up in a tooltip once the mouse is moved over the line
  in question.
  </li>
  <li><term>Comment position</term> can be used to add a comment for the
  current position. This comment is shown on top of <term>Tree</term>
  window once the commented position is reached. Note that Scid
  displays only the first line of the comment to save space in the
  <term>Tree</term> window. However, if the mouse is moved over that
  line the whole commentary shows up in a tooltip.
  </li>
  </ul>
  Don't forget to save the Mask! You will be prompted to do it
  if you close a Mask that has been modified or if a <term>Tree</term>
  window is closed.
  </p>
  <p>
  To search for commentary, symbols etc. use <menu>Masks /
  Search</menu>. Here one can select various check boxes that use the
  selected search option as criterion. After selecting
  <button>Search</button> a list of all positions found is displayed
  in <term>FEN</term> notation followed by the move in question and
  the commentary if any.
  </p>
  <p>
  <menu>Display mask</menu> will display the current Mask in a line
  style. Stating at the current position all subsequent moves are
  sorted into some unfoldable tree to give an overview of the current
  lines of play similar to what is found in many repertoir books.
  Note that not all information are displayed (e.g. comments are
  shorted to fit the display). Additionally, as <term>Masks</term>
  work on positions rather than move sequences they may contain loops
  (ie. transpositions) which can not be unfolded in a line wise
  display perfectly. That is, this display may be cut at a certain
  point.
  </p>
  <h3>Conversion to Masks</h3>
  <p>
  Setting up a mask can be a tendious taks especially for complex
  opening repertoirs. However, if such a repertoir is available as a
  Scid Database or a number of PGN games, or lines stored in usual
  chess games, Scid can use that information to set up suitable
  <term>Masks</term> automatically.
  </p>
  <p>
  First of all one has to load the information into a Scid Database.
  In case the information is already available as a Scid Database this
  is as easy as opening it. In case a PGN file is use it should be
  either imported into a Scid Database or one can use the
  <term>Clipbase</term> to import it temporarily. In that case one
  should make sure that the <term>Clipbase</term> is empty before
  importing. (<menu>Edit / Empty Clipbase</menu>).
  </p>
  <p>
  The next step is to open the tree for the just opened Scid Database.
  Then a new <term>Mask</term> should be created or an existing one
  opened. <b>Note</b> that this function may be used to consolidate
  serveral bases into a single <term>Mask</term>.
  </p>
  <p>
  Now, the <term>Mask</term> can be filled automatically with the game
  content of the database. In this process, comments within the games
  will be converted to move comments (appending to those existing
  eventually) in the <term>Mask</term>. <term>NAG</term> symbols will
  be added as well. To initiate this process one can chose either
  <menu>Masks / Fill with game</menu> to fill the <term>Mask</term>
  with the contents of a single game, or <menu>Fill with
  Database</menu> to loop over all games in the database.
  </p>
  <p>
  <b>Note</b>: especially filling a <term>Mask</term> with an entire
  base can be quite time consuming.
  </p>
  <p>
  <b>Note</b>: The <term>mask</term> is filled with all moves till the
  end of the game including all variations within a game. Therefore,
  it is sensible to use only bases for this procedure that end the
  games as soon as the middle game is reached.
  </p>

  <p><footer>(Updated: Scid 4.3, November 2010)</footer></p>
}



####################
### Compaction help:

set helpTitle(Compact) "Database compaction"
set helpText(Compact) {<h1>Database Compaction</h1>
  <p>
  Database <term>compaction</term> is a specific type of
  <a Maintenance>maintenance</a> that keeps a database as small and
  efficient as possible.
  Compacting a database means removing any unused space in its files.
  There are two types: name file and game file compaction.
  </p>

  <h3>Name File compaction</h3>
  <p>
  Over time, you may find a database starts to contain a number of player,
  event, site or round names that are no longer used in any game. This will
  often happen after you spellcheck names. The unused names waste space in
  the name file, and can slow down name searches.
  Name File compaction removes all names that are not used in any games.
  </p>

  <h3>Game File compaction</h3>
  <p>
  Whenever a game is replaced or deleted, wasted space is left in the game
  file (the largest of the three files in a Scid Database). Game File
  compaction removes all wasted space, leaving no deleted games in the
  database. Note that this operation is irreversible: after compaction,
  the deleted games are gone forever!
  </p>
  <p>
  Game File compaction is also recommended after <a Sorting>sorting</a> a
  database, to keep the order of the game file consistent with the sorted
  Index File.
  </p>

  <p><footer>Updated: Scid 3.6.2, December 2006</footer></p>
}


####################
### Database maintenance tools help:

set helpTitle(Maintenance) "Database Maintenance"
set helpText(Maintenance) {<h1>Database Maintenance</h1>
  <p>
  Scid provides a number of tools for maintaining databases,
  available from the Scid <a Menus File>File</a> menu. The
  database <a Compact>compaction</a> and <a Sorting>sorting</a>
  functions are explained in separate help pages.
  </p>

  <h3>Maintenance window</h3>
  <p>
  Most Scid database maintenance can be done from the Maintenance
  window, which can be opened from the <menu>File: Maintenance</menu>
  or <menu>Windows</menu> menus or the shortcut key <b>Ctrl+M</b>.
  </p>
  <p>
  You can use this window to maintain <a Flags>game flags</a>,
  spellcheck names, <a Compact>compact</a> or <a Sorting>sort</a>
  a database. Note that any operations that are not available
  for the current database (for example, because it may be read-only
  or a PGN file) will be grayed out.
  </p>

  <h3><name Twins>Deleting twin games</name></h3>
  <p>
  The Delete twin games feature (accesible from the
  <b>Maintenance</b> menu) enables deleting extra
  copies, or twins, in the database.  It finds all pairs
  that are twins and flags one as deleted.
  </p>
  <p>
  Two games are considered to be twins if their players, and
  any other tags that you can optionally specify, exactly
  match.  If you specify the "<b>same moves</b>" option (which
  is strongly recommended), each pair of games must have the
  same actual moves up to the length of the shorter game (or
  move 60, whichever comes first) to be twins.
  </p>
  <p>
  When you have identified twins, it is a good idea to
  <b>confirm each game</b> really is a copy of another.  By
  selecting the "Set filter to all deleted games" option in
  the Delete Twins dialog box, the filter will contain all
  deleted games, and you can browse through them (using the
  arrow keys) with the <term>twins checker</term> window.
  Use the "1", "2" and "u" keys to
  toggle the delete fields of one or both games.
  </p>

  <h3><name Editing>Editing player, event, site and round names</name></h3>
  <p>
  You may find mis-spelt names in your databases and want to correct them.
  You can do this in Scid with the <term>Name editor</term> window
  (shortcut key: <b>Control+Shift+N</b>),
  available from the <menu>File: Maintenance</menu> submenu.
  </p>
  <p>
  Each unique name is only stored once in the name file, so changing a name
  actually changes all occurrences of it.
  </p>

  <h3><name Spellcheck>Spellchecking names</name></h3>
  <p>
  Scid comes with a <term>spellcheck</term> file named <b>spelling.ssp</b>,
  for correction of player, event, site and round names.
  Scid will try to load the spellcheck file whenever it starts up; if it
  does not load, you can load it from the <menu>Options</menu> menu.
  </p>
  <p>
  Once the spellcheck file is loaded, you can use it on a
  a Scid Database using the spellcheck commands in the
  <menu>File: Maintenance</menu> menu, or from the maintenance window.
  </p>
  <p>
  When you spellcheck a database, Scid produces a list of corrections that you
  can edit before actually making any corrections, so you can remove any
  corrections you do not want to make.
  </p>
  <p>
  Spellchecking is especially useful for standardizing a database so all
  instances of a particular player are spelt the same way.
  For example, with the standard spellcheck file, the names "Kramnik,V.",
  "Vladimir Kramnik", and "V. Kramnik" would all be corrected
  to "Kramnik, Vladimir".
  </p>
  <p>
  The spellcheck file has one
  additional use: when it is loaded, its player data is
  used to enhance the <a PInfo>player information</a> window and the
  <a Crosstable>crosstable</a> window:
  you will see FIDE master title
  (<b>gm</b> = International Grandmaster, <b>im</b> = International Master, etc)
  and country information for any player that is
  listed in the spellcheck file. Over 6500 strong players of the past and
  present are listed in the <b>spelling.ssp</b> file that comes with Scid.
  </p>

  <h3><name Ratings>Adding Elo ratings to games</name></h3>
  <p>
  The "Add Elo ratings..." button in the Maintenance window causes Scid
  to search the current database for games where a player does not have
  a rating, but the spellcheck file has an Elo rating listed for that
  player at the date of the game. Scid will add all such ratings
  automatically. This is very useful for a database of master-level games
  which has few ratings.
  </p>
  <p>
  The spellcheck file "spelling.ssp" that comes with Scid does not contain
  the Elo rating information needed for this function, but a larger version
  of it called "ratings.ssp" is available from the <url
  http://scid.sourceforge.net/>Scid website</url>.
  </p>

  <h3><name Cleaner>The Cleaner</name></h3>
  <p>
  The Scid <term>Cleaner</term> (available from the Maintenance window) is
  a tool for doing a number of maintenance tasks on a database in one
  action. You can choose which tasks you want to do, and Scid will
  perform them on the current database without requiring user interaction.
  This is especially useful for maintenance of large databases.
  </p>

  <h3>Setting the database autoload game</h3>
  <p>
  The <term>autoload</term> game of a database is the game automatically
  loaded whenever that database is opened. To change the autoload game of
  a database, use the "Autoload game number..." button. If you always want
  the last game of a database to be opened (regardless of the actual number
  of games in the database), just set it to a very high number such as
  9999999.
  </p>

  <h3>Repair a base</h3>
  <p>
  In the rare cases that a Scid Database is corrupted one might try to
  repair it using File / Maintanance / Repair base. For this to work,
  the base in question must not be opened (which is not possible in
  most cases anyway). Scid will then try its best to get the database
  back in a consistent and usable state.
  </p>

  <p><footer>Updated: Scid vs. PC 4.1, August 2010</footer></p>
}

####################
### Sorting help:

set helpTitle(Sorting) "Sorting a database"
set helpText(Sorting) {<h1>Sorting a Database</h1>
  <p>
  The <term>sorting</term> function sorts all games in a database.
  You can select a number of sort criteria.
  When two games are equal according to the the first criteria, they
  are sorted using the second criteria, and so on.
  </p>

  <h3>Sort criteria</h3>
  <p>
  The available sorting criteria are:
  </p>
  <ul>
  <li> Date (oldest games first)
  <li> Year (same as date, but using the year only)
  <li> Event name
  <li> Site name
  <li> Country (last 3 letters of Site name)
  <li> Round name
  <li> White name
  <li> Rating (average of White and Black ratings, highest first)
  <li> Black name
  <li> Result (White wins, then draws, then Black wins)
  <li> Length (number of full moves in the game)
  <li> ECO (the <a ECO>Encyclopedia of Chess Openings code</a>)
  </ul>

  <h3>Sort results</h3>
  <p>
  When you sort a Scid Database that is not read-only, the sort
  results are saved so the order of games in the database is
  permanently changed.  If you want to the sort results to be
  temporary, make the database read-only first using the <b>File:
  Read-only</b> menu command.
  </p>
  <p>
  When you sort a database that is read-only or is actually a PGN
  file, the sort results cannot be saved so the sorted order of games
  will be lost when the file is closed.
  </p>
  <p>
  Note that sorting a database resets the <a Searches Filter>search
  filter</a> to contain all games.
  </p>

  <h3>Important note about sorting databases:</h3>
  <p>
  When a database is sorted, the Index File is altered but the game file
  is not changed. This means sorting a database will leave the game file
  records in a scrambled order relative to the Index File. This can
  really <b>slow down</b> <a Tree>tree</a>, position and material/pattern
  <a Searches>searches</a>, so you should reorder the game file by
  <a Compact>compacting</a> it after sorting the database to maintain
  good search performance.
  </p>
  <p>
  Note that only a database sorted by <a ECO>ECO</a> codes can use the fast
  tree search modes. This however, also requires to compact the
  database after the sort procedure!
  </p>

  <p><footer>Updated: Scid 3.6.26, October 2008</footer></p>
}

####################
### Flags help:

set helpTitle(Flags) "Game Flags"
set helpText(Flags) {<h1>Game Flags</h1>

  <p>
  A <term>flag</term> is an indicator of some chess characteristic
  that can be turned on or off for each game in the database.
  There are 13 user-settable flags that you can directly set for
  each game. Of these, only the Delete flag has any special
  significance: games with the Delete flag turned on are marked
  for deletion and will removed when the database is
  <a Compact>compacted</a>.
  </p>
  <p>
  The other 12 user-settable flags and their symbols are:
  </p>

  <ul>
  <li>White opening (W)</li>
  <li>Black opening (B)</li>
  <li>Middlegame (M)</li>
  <li>Endgame (E)</li>
  <li>Novelty (N)</li>
  <li>Pawn structure (P)</li>
  <li>Tactics (T)</li>
  <li>Queenside play (Q)</li>
  <li>Kingside play (K)</li>
  <li>Brilliancy (!)</li>
  <li>Blunder (?)</li>
  <li>User-defined (U)</li>
  </ul>

  <p>
  A flag can be set for the current game, all filter games, or all
  database games using the <a Maintenance>maintenance</a> window.
  </p>
  <p>
  You can use a <a Searches Header>header search</a> to find all
  games in a database that have a particular flag turned on or off,
  or use flags as part of more complex searches.
  </p>
  <p>
  Since all the user-settable flags (except the Delete flag) have
  no significance to Scid, you can use them for any purpose that
  suits your needs. For example, you could use the Kingside (K)
  flag for kingside pawn storms, or kingside heavy piece attacks,
  or even for endgames with all pawns on the kingside.
  </p>
  <p>
  Note, that sensible handling of flags can speed up searches
  significantly!
  </p>
  <p>
  The following functions of Scid set or require flags:
  <ul>
     <li><a OpeningTrainer>Opening Trainer</a>: can evaluate the (B) and (W) flags
     <li><a Analysis Annotate>Find best move</a>: evaluates the (T) flag
     <li><a Analysis Annotate>Find tactical exercise</a>: sets the (T) flag
  </ul>

  <p><footer>Updated: Scid 3.6.26, October 2008</footer></p>
}

####################
### Analysis window help:

set helpTitle(Analysis) "Analysis window"
set helpText(Analysis) {<h1>Analysis Windows</h1>
  <p> 
  The Analysis window shows study of the current position by a
chess engine.  It is accessed and configured from the <a Analysis List>Analysis
Engines</a> widget, or by using the F2 , F3 or F4 hotkeys.
  </p>

  <p>
  At the bottom of the window is found some general info,
  and move predictions occupy the main text window.
  </p>

  <p>
  It is possible to have multiple analysis windows open simultaneously, each
  running different engines!
  </p>

  <h3>Buttons</h3>
  <p>
  At the top you'll find many cryptic buttons...
  <ul>

  <li> <button tb_pause><b>Pause</b>  temporarily interrupt engine analysis.</li>
  <li> <button tb_play><b>Play</b>  restarts the engine.
  <i>Note: This will cause most engines 
  to restart their analysis, forgetting previous lines.
  Only few engines are able to reuse the
  results they have calculated till the analysis was stopped.</i> </li>
  <li> <button tb_lockengine> <b>Lock Analysis</b> lock analysis to a certain position.
  <i>This also sets <a Moves Trial>Trial mode</a>.
  Then, to add the this analysis as a variation, first press the <b>Pause</b>
  button, then <b>Add Varation</b></i>.</li>

  <li> <button tb_addmove><b>Add Move</b> 
  adds the engine's best move to the current game.</li>
  <li> <button tb_addvar><b>Add Variation</b>  adds the
  whole main line.</li>
  <li> <button tb_addallvars><b>Multi-PV</b>  if the engine supports multi-pv, add all principal variations.</li>

  <li><button tb_engine><b>Show Info</b> show additional information.</li>
  <li><button tb_cpu><b>Low CPU priority</b> 
  give the engine a low priority for CPU
  scheduling. On Windows, engines are run on low priority by default.
  On Unix systems the engines priority can not be set back to normal.  </li>
  <li><button tb_coords><b>Show Board</b> displays a small working board.</li>
  <li><button finish_off><b>Shoot out</b>, or "demo", mode allows the engine to play out the game. </li>
  <li><button tb_annotate><b>Annotate</b> game (see below).</li>
  <li><button tb_training><b>Training</b> feature (see below).</li>
  </ul>
  </p>

  <p>
  <i>The output of the current analysis can be hidden/shown
  by clicking with the right mouse button into the analysis window. In
  this mode only the current evaluation is shown in the status line.</i>
  </p>

  <h3>Move details</h3>
  <p>
   In the main text widget is all sorts of move information.
   The first number prefixed with a <b>+/-</b> is a move score.
  It is measured in pawn units
  from the perspective of White - a positive score means White is ahead, a negative score means Black.
  <br><b>Depth:</b> shows the search depth already reached by
  the engines calculations in half moves.
  <br><b>Nodes:</b> gives the number of positions analysed for the current
  result while the number of positions per second (kn/s) is shown in
  brackets.
  <br><b>Time:</b> finally shows the amount of time spent for
  the current analysis.
  </p>

  <p>
  <i>Additional information used be accessed using the 
  engineinfo button, but has been removed for space reasons.
  Info shown includes the number of tablebase hits, a
  more exact number of nodes analysed per second, the watermark of the
  engines hash and the current cpu load. This option can be enabled by
  editting the scid gui and setting showEngineInfo 1</i>
  </p>
  <p>
  If the engine only analyses the line it considers the main
  continuation, the lower frame in the window (with the scrollbar)
  shows the history of evaluations produced by the engine for the
  current position, so you can see how the assessment has changed.
  </p>
  <p>
  Many recent <term>UCI</term> engines however allow to analyse
  several lines at once. Using this <term>Multi-PV</term> feature, the
  user can also see what the engine thinks is the second or third best
  continuation.  The best line is always on top and highlighted to
  ease reading.  If an engine allows for <term>Multi-PV
  analysis</term>, the spin box below the analysis lines can be used
  to set the number of principal variations that should be calculated
  and shown. In this case, instead of the calculation history, only
  the resulting principal lines are shown. However, if the number of
  principal lines is set to 1, one can again observe the evaluation
  history. The spin box is disabled, if an engine does offer this
  feature.
  </p>
  <p>

  <h1><name List>Configuring Engines</name></h1>
  <p>
  The <run ::enginelist::choose><green>Tools--<gt>Analysis Engines</green></run>
  widget is where you can <b>Configure</b>, <b>Add</b>, and <b>Start</b> Chess Engines.
  </p>

<p>
  Scid vs. PC installs a few engines by default but it is also possible to install new ones
  To do so you'll need to know the program's <b>Command</b>, any <b>Parameters</b> it takes,
  whether it is uses the <b>UCI or Xboard</b> protocol, and also the
  <b>Directory</b> it should be run in.
  This sounds complicated, but is not too hard :-)
  Sticking points are likely to be the choice of
  which directory to use, and whether it's UCI or not.</p>

  <h3>Details</h3>
<p> Many engines require an
  initialization or opening book file in their start directory to run
  properly.  Other engines, like Crafty and Phalanx, write log files to the
  directory they start in, so write access will be required.
  If the directory setting for an engine
  is ".", Scid will just start the engine in the current directory.
  </p>

  <p>
  If an engine fails to start, try
  changing its directory setting. To avoid engines creating log files
  in many different directories, I recommend trying the <b>~/.scdivspc</b>
  button. Engines necessitating opening books and/or .ini files, will need
  a directory of their own however.
  </p>
  <p>
  UCI and Xboard (also known as Winboard) are two protocols
  for communicating with engines, and it is necessary to set this flag accordingly.
  If you're not sure, try one then the other, as nothing will break. Some chess
engines support both formats.
  </p>
  <p>
  If an engine needs additional parameters for startup (e.g. a
  specific opening book) they can be specified in the
  <b>Parameters</b> field. ... Please refer to the engines documentation.
  </p>
  <p><b>Webpage</b> allows you to set the engines homepage. This
  comes in handy to check for updates e.g. or to have a look at recent
  developments. Pressing the <term>Open...</term> button will open
  this page in the web browser.
  </p>

  <p>
  Finally, If the engine uses the <b>UCI</b> protocol 
  , it can be configured by pressing the <b>Configure</b> button.
  A dialog will be shown where all engine parameters can be tuned to the users
  liking.
  </p>


  <h3>Training</h3>
  <p>
  With the <b>Training</b> button <button tb_training>, you can play moves against the analysis
  engine. The time for each move is fixed, and the analysis results are
  not shown when training mode is on.
  </p>

  <h3><name Annotating>Annotating a game</name></h3>
  <p>
  The "variation" and "add all variation" buttons add the
  current score and best line of play as a new variation in
  the game.  This can also be <b>done automatically</b> using
  the <b>Annotate</b> <button tb_annotate> feature.</p>

  <p>It will automatically add comments , <a Moves Informant>Informants
  </a> and best-lines to a game, and can also be performed
  on  <b>multiple games</b>.</p>

  <p>After configuring options and pressing OK, <b>autoplay
  mode is enabled</b> and the engine starts its analysis.
  A variation containing the score and best line of play is
  automatically added for each position as autoplay mode moves
  through the game.  Only positions from the current position
  until the end of the game (or until you exit autoplay mode)
  are annotated, so you can skip annotation of opening moves
  by moving to a middle-game position before starting autoplay.
  To cancel annotation at any time, just turn off autoplay mode
  </p>
  <p><i>
  The <b>Annotate</b> feature of Scid vs. PC can be used with any engine,
  but be sure not to open any other anaylsis windows while
annotation is in progress!
  </i></p>

  <p>Options:
  <ul>
     <li><term>Time between moves</term>
     number of seconds engine spends on analysing each move.</li>
     <li><term>Add variations...</term> 
     Select which side (or both) should be annotated.
     <li><term>Annotate...</term>
     Additionally, one can add an annotation only if the game
     move is a blunder, or not the best move.
     The "Blunder Threshold" is given in units of pawns (i.e. 0.2 means 
     an evaluation drop of more than 2 pawns).  </li>

     <li><term>Annotate variations</term> will include variations
     within the game in the analysis by the engine.</li>
     <li><term>Short annotations</term> will only add minimal
     annotations, that is the pure lines and NAG codes without the
     engines names and usually without the current scores.</li>
     <li><term>Add score to annotations</term> will add the engines
     evaluation in pawn units to the annotations. This information can
     be used later on to draw a <a Score>Score Graph</a> of the game
     as a visualisation of the positions reached.
     </li>
     <li><term>Add annotator tag</term> will add an "Annotator" tag to
     the game header. This is meant for the <term>Short
     annotations</term> mode which does not signify which engine was
     used to gain the current evaluations and lines.
     </li>
     <li><term>Use book</term> allows the specification of an opening
     book. Moves that are contained in this opening book are skipped
     in the annotation process, and the annotation starts in the middle game.</li>
     <li><term>Annotate several games</term> 
     Will automatically annotate a sequence of games,
storing the annotations into the database.
     </li>
     <li><term>Find opening errors</term> will check the opening phase
     up to the move specified for blunders. Additionally, the
     Annotator-tag gets an entry "opBlunder X" where X is the move the
     blunder occurred.
     </li>
     <li><term>Mark tactical exercises</term> This can be used to
     generate exercises for the training function <a FindBestMove>Find
     best move</a>. This option is only available for <term>UCI</term>
     engines.
     </li>
  </ul>

  <p><footer>Updated: Scid vs. PC 4.1, July 2010</footer></p>
}

####################
### Computer Tournament 
set helpTitle(Tourney) "Computer Tournament"
set helpText(Tourney) {<h1>Computer Tournament</h1>
  <p>Scid vs. PC now has an automated
  <run ::compInit><green>Computer Tournament</green></run> feature.
  Any engine configured via the
  <run ::enginelist::choose><green>Tools--<gt>Analysis Engines</green></run>
  widget can be added.
</p>
<p>
  Support for different engines is, afaik, good, but <b>a few old engines won't work</b>.
  For more information about various engines see below.
  </p>
  <p>
  Make sure you <b>open a database</b> so the results can be saved, then select
  the number of competitors, tournament name and move period, and Press "OK".
  <b>Games are saved</b> after each is completed.
  </p>
  <p>
  Though there's been some testing, it's probably still possible for single games to hang.
To address this, there is a <b>Seconds for Timeout</b> value, which determines the
maximum time that any one move should take before the game is ended automatically.
In this case, the game is still saved , and game result can be edited manually later.
  </p>
  <p>
  If a game drags on for any reason, pressing the <b>End Game</b> button will save the game, and
progress to the next.
  </p>
  <p>
  Once the tournament is completed, make sure to have a look at the 
  <run ::crosstab::Open><green>Crosstable</green></run> window
  to see the results in a nice format.
  </p>

  <h3>Known Issues</h3>
<br>
  * The tournament currently implements a <b>per-move time limit</b> instead of a more sophisticated
time control. This is slightly crude, but engine analysis is (now) continuous through-out.
<br>
  * <b>Xboard/Winboard</b> protocol support is not as solid as for <b>UCI</b> (see below).
  The xboard <b>resign</b> request is supported.
<br>
  * In the uncommon event of a game engine crashing, unfortunately the tournament will be ended.
<br>
  <h3>Engines</h3>
<p>
The author has tested quite a few engines under <b>Linux</b>, with good results. These include:
<br>
<br>
Arasanx<br>
Crafty<br>
Faile<br>
Glaurung<br>
Gnu Chess 5<br>
Hoi Chess<br>
Homer<br>
Phalanx<br>
RobboLito<br>
Scidlet<br>
Scorpio<br>
Shredder Classic 4<br>
Sjeng<br>
Spike<br>
Stockfish 1.6.2<br>
Stockfish 1.7.1<br>
Toga 131 (Fruit)<br>
XChenard<br>
Zct<br>
<br>
Arasan, Spike, Sjeng, Homer and XChenard have issues relating to time control.
Sjeng and XChenard are issued the "hard" command, and seem to work.
Gaviota-0.74 runs in analysis/xboard mode, but will not play tournaments.
Pervious versions of Phalanx had no time control, but it now works well.
Gnu Chess needs the "-xboard" parameter.
Faile seems not to issue "move" under some circumstances, despite being in xboard mode.
</p>
<p>
Testing under <b>Windows</b> has not been terribly extensive, and considering
the number of engines available, unforseen issues will probably arise.  </p>

  <p><footer>Updated: Scid vs. PC 4.1, July 2010</footer></p>

}

####################
### Calvar window help:

set helpTitle(CalVar) "Calculation of variation"
set helpText(CalVar) {<h1>The Calculation of Variation Window</h1>
  <p>
   This training exercise is also known as the Stoyko exercise.  Its
   purpose is to analyse a complex position and evaluate as many sound
   lines as possible, and give a correct evaluation for each of them.
  </p> 
  <h3>Configuration</h3></p>
  <p>
  Three parameters are set :
  <ul>
     <li>The UCI engine that will analyse various lines</li>
     <li>The time, in seconds, the engine will use to analyse the position</li>
     <li>The time, in seconds, the engine will use to analyse each line entered by the user</li>
  </ul>
  </p>

  <h3>Entering lines</h3></p>
  <p>
  Moves are entered as usual with mouse clicks on the board but they
  will not be displayed. At the end of a line the user needs to provide
  an evaluation by clicking on one of the buttons with NAG codes.
  </p>

  <h3>Evaluation verification</h3>
  <p>
  Each time an evaluation is given to a line the engine calculates its
  value and append the line and score just below the user ones.
  </p>

  <h3>Done with position</h3>
  <p>
   When  the user thinks he found all best lines, pressing <term>Done with
   position</term> will append to the game (with the comment <term>Missed
   line</term>), the lines that have a score higher than the best line
   entered by the user.
  </p>

  <p><footer>Updated: Scid 3.6.21, December 2007</footer></p>
}


####################
### EPD files help:

set helpTitle(EPD) "EPD files"
set helpText(EPD) {<h1>EPD Files</h1>
  <p>
  An EPD (extended position description) file is a collection of positions,
  where each position has some associated text. Like <a PGN>PGN</a>, it
  is a common standard for chess information.
  </p>
  <p>
  An EPD file has a number of defined <term>opcodes</term> (fields)
  which are stored separated by semicolons (<b>;</b>) in the file
  but are shown on separate lines in a Scid EPD window to make editing easier.
  A semicolon within an EPD field is stored as "<b>\s</b>" by Scid to
  distinguish it from an end-of-field marker.
  Each position and its associated opcodes are stored on one single line
  in the EPD file.
  </p>
  <p>
  Standard EPD opcodes include:
  <ul>
  <li> <b>acd</b> Analysis count: depth searched.</li>
  <li> <b>acn</b> Analysis count: number of nodes searched.</li>
  <li> <b>acs</b> Analysis count: search time in seconds.</li>
  <li> <b>bm</b> Best moves: move(s) judged best for some reason.</li>
  <li> <b>ce</b> Centipawn evaluation: evaluation in hundredths of a
  pawn from the perspective of the <b>side to move</b> -- note this
  differs from the Analysis window which shows evaluations in pawns from
  Whites perspective. </li>
  <li> <b>cX</b> Comment (where <b>X</b> is a digit, 0-9).</li>
  <li> <b>eco</b> <a ECO>ECO</a> system opening code.</li>
  <li> <b>id</b> Unique Identification for this position.</li>
  <li> <b>nic</b> <i>New In Chess</i> system opening code.</li>
  <li> <b>pm</b> Predicted move: the first move of the PV.</li>
  <li> <b>pv</b> Predicted variation: the line of best play.</li>
  </ul>

  <p>
  EPD files have a number of uses: Scid uses an EPD file to classify
  games according to the <a ECO>Encyclopedia of Chess Openings</a> (ECO)
  system, and you can create an EPD file for your opening repertoire,
  adding comments for positions you regularly reach in games.
  </p>
  <p>
  You can create a new EPD file or open an existing one, from the
  <menu>New</menu> and <menu>Open</menu> commands of the
  <menu>File</menu> menu. At most four EPD files can be open at any time.
  </p>

  <h3>EPD windows</h3>
  <p>
  For each open EPD file, you will see a window which shows the text for
  the current position. You do not have to press the Store button to store
  any changes you make to a positions text; the text will be stored whenever
  you move to a different position in the game.
  </p>

  <h3>Navigating EPD files</h3>
  <p>
  To browse through the positions in a EPD file, use the
  <menu>Next position</menu> and <menu>Previous position</menu> commands
  from the EPD window <menu>Tools</menu> menu, or use the shortcut
  keys <b>Ctrl+DownArrow</b> and <b>Ctrl+UpArrow</b>.
  These commands move to the next/previous position in the file, clearing
  the current game and setting its start position.
  </p>

  <h3>Annotating</h3>
  <p>
  EPD-files can be automatically annotated by selecting Tools /
  Annotate position. The upcoming dialogue asks for the time that
  should be used for the analysis, then the <a Analysis List>engine
  list</a> is opened for selection of an engine to be used. <b>Note</b> If an
  analysis window is already opened, the analysis is done using this
  engine without asking the user beforehand. Then the engine is
  started and the result added to the EPD. The EPD tags used are :
  acd, acn, ce and pv.
  </p>
  <p>

  <h3>Stripping out EPD fields</h3>
  <p>
  EPD files you find on the Internet may contain fields that do not
  interest you, and they can waste a lot of space in the file.
  For example, an EPD file of computer evaluations might have ce, acd,
  acn, pm, pv and id fields but you may only need the ce and pv fields.
  </p>
  <p>
  You can strip out an EPD opcode from all positions in the EPD file using
  the <menu>Strip out EPD field</menu> from the EPD window <menu>Tools</menu>
  menu.
  </p>

  <h3>The EPD window status bar</h3>
  <p>
  The status bar of each EPD window shows:
  <ul>
  <li>- the file status (<b>--</b> means unchanged, <b>XX</b> means
  changed, and <b>%%</b> means read-only); </li>
  <li>- the file name; </li>
  <li>- the number of positions in the file; </li>
  <li>- legal moves from the current position reach another position
  in this EPD file.</li>
  </ul>

  <p><footer>Updated: Scid 3.6.26, October 2008</footer></p>
}

####################
### Email window help:

set helpTitle(Email) "Email window"
set helpText(Email) {<h1>The Email Window</h1>
  <p>
  Scids email manager window provides a way for you to manage correspondence
  chess games played by email.
  If you do not play email chess, this will be of no interest to you.
  But if you play correspondence chess by email, you can send your email
  messages directly from Scid!
  </p>
  <p>
  To use the email manager:
  <ul>
  <li><b>1)</b> Create the game(s) for your opponent in the
  database. </li>
  <li><b>2)</b> In the email manager window, select <b>Add</b> and enter
  your opponents details: name, email address, and the game numbers in the
  database. </li>
  <li><b>3)</b> Select <b>Send email</b> in the email window each time you
  have added moves to the game(s) and want to send a message. </li>
  </ul>

  <p>
  When you send an email message, Scid generates the message with the games
  in PGN format <b>without</b> any comments, annotations or variations, since
  you would not usually want your opponent to see your analysis.
  You can edit the message before sending it to add conditional moves or
  other text.
  </p>
  <p>
  For each opponent, you may have any number of games; one or two is most
  common. Note that Scid does not check if game numbers change, so after
  setting up the details of your opponents, be careful to avoid deleting games
  or sorting your database of email games, since this will rearrange games
  and the game numbers for each opponent will be incorrect.
  </p>

  <h3>Limitations</h3>
  <p>
  Scid does not have any capability to check your email folder yet, so you
  still need to add your opponents moves to the games manually.
  </p>

  <h3>Configuration</h3>
  <p>
  A copy of each email message sent by Scid is stored in the file
  <b>~/.scid/scidmail.log</b>. If you want them to be stored
  in a different file, you will need to edit the file <b>tcl/start.tcl</b>
  and recompile Scid.
  </p>
  <p>
  Scid can send email messages using an SMTP server or sendmail.
  User the <b>Settings</b> button in the Email Manager to specify which
  you want to use.
  </p>
  <p>
  Scid stores the opponent details for a database in a file
  with the same name as the database and the suffix <b>.sem</b>.
  </p>

  <p><footer>Updated: Scid 3.6.2, December 2006</footer></p>
}

####################
### Reports help:

set helpTitle(Reports) "Reports"
set helpText(Reports) {<h1>Reports</h1>
  <p>
  A <term>Report</term> in Scid is a document containing information about
  a particular position and/or player. There are two types of report Scid can
  generate: Opening Reports and Player Reports.
  </p>

  <h3><name Opening>Opening Reports</name></h3>
  <p>
  Scid can produce an <term>opening report</term> that displays interesting
  facts about an opening position. To generate an opening report, first make
  sure the displayed position is the one you want a report for, then select
  <b>Opening Report</b> from the <b>Tools</b> menu.
  </p>
  <p>
  The <term>Opening Report</term> window displays the results of the report
  Scid generated. The <b>File</b> menu has commands to save the report
  to a file in plain text, HTML or <a LaTeX>LaTeX</a> format.
  </p>
  <p>
  The first sections of the report present information on the games that
  reach the report position, and moves played from the position. You can
  see if the opening is becoming more popular, if it has many short draws,
  and what move orders (transpositions) are used to reach it.
  </p>
  <p>
  The Positional Themes section reports the frequency of certain common
  positional themes in the report games. For this, the first 20 moves of
  each game (hence the first 40 positions of each game after the starting
  position) are examined. To be counted as containing a theme, a game must
  contain that particular theme in at least 4 positions of its first 20
  moves. This avoids the brief occurrence of a theme (such as an isolated
  Queen pawn which is quickly captured) distorting results.
  </p>
  <p>
  The final and largest part of the report is the theory table. When saving
  the report to a file, you can choose to save just the theory table, a compact
  report without the theory table, or the whole report.
  </p>
  <p>
  Almost all the report sections can be turned on or off or adjusted in
  the opening report options, so you can customize a report to only show
  the information that interests you.
  </p>
  <p>
  Most items of information in the report window that are shown in color,
  invoke some action when selected with the left mouse button. For example,
  you can click on a game reference to load that game, or click on a
  positional theme to set the filter to contain only the report games where
  that theme occurred.
  </p>
  <p>
  Choosing <term>Merge Games</term> will merge the games from the
  opening report into the currently displayed game. This merges in
  the whole games as variations to the game, including the full
  reference.
  </p>

  <h4>Favorites</h4>
  <p>
  The <menu>Favorites</menu> menu in the report window lets you maintain a
  collection of favorite opening report positions and generate the opening
  reports for all those positions easily. Selecting "Add Report..." from
  the Favorites menu will add the current position as a favorite report
  position; you will be prompted to enter a name that will be used as
  the filename when favorite reports are generated.
  </p>
  <p>
  Select "Generate Reports..." from the Favorites menu to generate a report
  for each of your favorite reports using the current database. A dialog
  box will appear allowing you to specify the report type and format, and
  a directory where report files will be saved. A suitable suffix for the
  format you selected (e.g. ".html" for HTML format) will be added to each
  report file name.
  </p>

  <h3><name Player>Player Reports</name></h3>
  <p>
  A <term>Player Report</term> is very similar to an opening report, but it
  contains information about the games of a single player with the white or
  black pieces. You can generate a player report from the Tools menu, or from
  the <a PInfo>Player Info</a> window.
  </p>
  <p>
  A player report can be generated either for all games by the specified player
  with the specified pieces, or for only the subset of those games which reach
  the current position on the main window chessboard.
  </p>

  <h3>Limits</h3>
  <p>
  There is a limit of 2000 games for most data generated by reports, so
  if the report position occurs in more than 2000 games, some results may
  be slightly incorrect.
  </p>
  <p>
  Also, there is a limit of 500 games for the theory table. If the report
  position occurs in more than 500 games, only the 500 games with the highest
  average Elo rating are used to generate the theory table. You can adjust the
  number of games used to generate the theory table in the Report options.
  </p>

  <p><footer>Updated: Scid 3.6.26, October 2008</footer></p>
}


####################
### Player List help:

set helpTitle(PList) "Player Finder window"
set helpText(PList) {<h1>The Player Finder Window</h1>
  <p>
  The <term>Player Finder</term> window displays a list of names of
  players in the current database. Selecting a player will open the
  <a PInfo>Player Info</a> window to display more detailed information
  about that player.
  </p>
  <p>
  Five columns are displayed showing each player's name, peak Elo
  rating, number of games played and the year of their oldest and
  newest game.
  Click on any column title at the top of the list to sort the
  list by that column.
  </p>
  <p>
  The controls below the list allow you to filter the list contents.
  You can alter the maximum list size, enter a case-insensitive player
  name prefix (such as "ada" to search for "Adams"), and restrict the
  ranges of Elo rating and number of games played.
  </p>

  <p><footer>Updated: Scid 3.6.2, December 2006</footer></p>
}

####################
### Player Info help:

set helpTitle(PInfo) "Player Info window"
set helpText(PInfo) {<h1>The Player Info Window</h1>
  <p>

  The <term>Player Information</term> window shows information from the Spellcheck
  file. It includes ratings, country of origin and official titles.</p>

  <p><b>Please use with caution. The names it contains may not be unique, and player initials may be
  incorrectly identified.</b></p>

  <p>Also displayed are statistics about
  success with White and Black, favorite openings (by <a ECO>ECO code</a>),
  and rating history.
  All percentages displayed are an expected score (success rate), from the
  player's perspective -- so higher is always better for the player, whether they
  are White or Black.
  </p>

  <p>
  You can see the player's rating history in a graph by pressing the
  <a Graphs Rating>Rating graph</a> button.
  </p>
  <p>
  Any number printed in red can be clicked with the left mouse button to set
  the <a Searches Filter>filter</a> to the games it represents.
  </p>

  <p><footer>Updated: Scid 3.6.26.9, April 2010</footer></p>
}

####################
### Graphs help:

set helpTitle(Graphs) "Graph windows"
set helpText(Graphs) {<h1>Graph Windows</h1>
  <p>
  Scid has a number of windows which display information graphically.
  They are explained below.
  </p>

  <h3><name Filter>Relative and absolute Filter Graph windows</name></h3>
  <p>
  The <term>relative Filter Graph</term> window shows trends by date or by
  Elo rating for the games in the current filter, compared to the
  entire database. For example, it is useful when the <a Tree>tree</a>
  is open as a tool showing how the current opening position has changed
  in popularity in recent years or decades, or whether it is especially
  popular among higher-rated players such as grandmasters.
  Each point on the graph represents the number of games in the filter
  per 1000 games in the entire database, for a particular date or Elo
  rating range.
  </p>
  <p>
  The second Filter graph window is the <term>absolute Filter
  Graph</term> window. This graph shows the absolute quantity of games
  in the filter according the selecte criteria. It is possible to select
  the criteria: Decade, Year, Rating and Moves.<br>
  The small button near the Close-Button opens the dialog to configure
  the graph. You can select the range (from, to) and the size of
  intervall for the x-axes. The "decade"-criteria can't be configured,
  use Year insteed. If "Estimate" selected a missing rating will be
  estimate like described below. In other case no estimation is done
  and missing ratings are count as zero. This matches the Min. Elo
  evaluation in the statistic-window. Use "Update" to start a new
  evaluation with the actual value without closing the dialog.
  </p>
  <p>
  Please note: The calculation can be need some time on large ranges and
  small intervalls, in addition the readability degreases. 
  </p>
  <p>
  When plotting the Filter graph by rating, Scid uses the average (mean)
  rating for each game. Estimate ratings (such as those in the spelling file)
  are not used. If one player in a game has a rating but the opponent
  does not, the opponent is presumed to have the same up to a limit of 2200.
  For example, if one player is rated 2500 and the opponent has no rating,
  the mean rating is (2500+2200)/2=2350.
  </p>

  <h3><name Rating>Rating Graph window</name></h3>
  <p>
  The <term>Rating Graph</term> window shows the rating history of one
  player or the two players of the current game.
  You can produce the graph for a single player by pressing the
  <b>Rating graph</b> button in the <a PInfo>player information</a>
  window, or produce it for the two players of the current game by
  selecting <b>Rating graph</b> from the <menu>Tools</menu> menu.
  </p>

  <h3><name Score>Score Graph window</name></h3>
  <p>
  The <term>Score Graph</term> window shows the numeric evaluations (scores)
  stored in the comments of the current game as a graph.
  You can click the left mouse button anywhere in the score graph to go to the
  corresponding position in the game.
  </p>
  <p>
  Two types of evaluation comment are recognized: those produced by
  the Scid <a Analysis>analysis</a> window (which have the format
  <ul>
  <li><b>1.e4 {"+0.25 ...."}</b></li>
  </ul>
  and are always scores from White's perspective) and those produced
  by the Crafty annotate command (which have the format
  <ul>
  <li><b>1.e4 ({9:+0.25} ....)</b></li>
  </ul>
  and are also scores from White's perspective).
  </p>
  <p>
  In case the scores are not given from whites perspective, one can
  choose the perspective to use from the options menu to correct for
  this.
  ###--- Checking both ??? ---###
  </p>

  <h3><name Tree>Tree Graph window</name></h3>
  <p>
  The <term>Tree Graph</term> window is available from the tree
  window. It shows the performance of the most popular moves from the
  current position. More information is available from the
  <a Tree Graph>Tree</a> help page.
  </p>

  <p><footer>Updated: Scid 3.6.26, October 2008</footer></p>
}

####################
### Tablebases help:

set helpTitle(TB) "Tablebases"
set helpText(TB) {<h1>Tablebases</h1>

  <p>
  A <term>tablebase</term> is a file containing the perfect result
  information about all positions of a particular material setup,
  such as King and Rook versus King and Pawn. Tablebases for all
  material situations up to five men (including the Kings) have been
  generated, and some simple 6-men tablebases are also available.
  </p>
  <p>
  Scid can use Nalimov-format tablebases that are used by many modern
  chess engines. These often end with the file suffix <b>.nbw.emd</b>
  or <b>.nbb.emd</b>. All 3-, 4- and 5-men Nalimov tablebases can be
  used in Scid.
  </p>

  <h3>Using tablebases in Scid</h3>
  <p>
  To use tablebase files in Scid, simply set their directories by
  selecting <b>Tablebase directory...</b> from the <menu>Options</menu> menu.
  You can select up to 4 directories where your tablebase files are stored.
  You can press a <b>...</b> button to the right of an entry to choose a
  file, to specify that the directory of that file should be used.
  </p>
  <p>
  When a position found in a tablebase file is reached, the game information
  area (below the chessboard) will show tablebase information. You can
  configure the amount of information shown by clicking the right-mouse
  button in that area or selecting <b>Game information</b> from the
  <menu>Options</menu> menu. Selecting the "result and best moves" option
  gives the most useful information, but is much often slower than
  the "result only" option.
  </p>

  <h3>The Tablebase window</h3>
  <p>
  You can get even more tablebase information about the current position
  by opening the <term>Tablebase window</term> (<menu>Windows</menu> menu,
  shortcut: Ctrl+Shift+=). This window shows the result with perfect play
  of all legal moves from the current position.
  </p>
  <p>
  The window has two main parts. The summary frame (on the left) shows
  which tablebases Scid found on your computer and a summary for each
  tablebase. The results frame (on the right) shows optimal results for
  all moves from the current position displayed in the main window.
  </p>

  <h4>The summary frame</h4>
  <p>
  The top part of the summary frame lets you select a particular
  tablebase. Those you have available are shown in blue and unavailable
  tablebases are shown in gray, but you can select any tablebase.
  The lower part of the summary frame shows summary information for the
  selected tablebase. (Not all tablebases have a summary recorded in
  Scid yet.)
  </p>
  <p>
  The summary includes the frequency (how many games per million reach a
  position with this material, computed from a database of more than
  600,000 master-level games), a longest mate for either side, and the
  number of mutual (or "reciprocal") zugzwangs. A mutual zugwang is a
  position where white to move draws and black to move loses, or where
  white to move loses and black to move draws, or where whoever moves
  loses.
  </p>
  <p>
  For some tablebases with mutual zugzwangs, the summary also includes
  a list of all of the zugwang positions or a selection of them. A full
  list for every tablebase is not feasible since some tablebases have
  thousands of mutual zugzwangs.
  </p>
  <p>
  You can set up a random position from the selected tablebase by pressing
  the <b>Random</b> button.
  </p>

  <h4>The results frame</h4>
  <p>
  The results frame is updated whenever the chessboard in the main window
  changes. The first line shows how many moves win (+), draw (=), lose (-),
  or have an unknown result (?). The rest of the frame gives a more detailed
  list of results, ranking them from shortest to longest mates, then draws,
  then longest to shortest losses. All distances are to checkmate.
  </p>

  <h4>The results board</h4>
  <p>
  In a tablebase position, it is often useful what the tablebase results
  would be if all the pieces in the current position were on their
  current squares but one particular piece was moved somewhere else.
  For example, you may want to determine how close a king has to be to
  a passed pawn to win or draw a particular position. In endgame books
  this information is often called the <i>winning zone</i> or
  <i>drawing zone</i> of a piece in a position.
  </p>
  <p>
  You can find this information in Scid by pressing the button with an
  image of a chessboard, to show the <term>results board</term> in the
  tablebase window.
  When you press the left mouse button on any piece in this board, a
  symbol is drawn in each empty square showing what the tablebase result
  would be (with the same side to move as the current main window position)
  if the selected piece was on that square.
  </p>
  <p>
  There are five different symbols a square can have:
  a white <b>#</b> means White wins;
  a black <b>#</b> means Black wins;
  a blue <b>=</b> means the position is drawn;
  a red <b>X</b> means the position is illegal (because the kings are
  adjacent or the side to move is giving check); and
  a red <b>?</b> means the result is unknown because the necessary
  tablebase file is not available.
  </p>

  <h3>Obtaining Tablebase files</h3>
  <p>
  See the <a Related>related links</a> section for help on finding
  tablebase files on the Internet.
  </p>

  <p><footer>Updated: Scid 3.6.2, December 2006</footer></p>
}

####################
### Bookmarks help:

set helpTitle(Bookmarks) "Bookmarks"
set helpText(Bookmarks) {<h1>Bookmarks</h1>
  <p>
  Scid allows you to <term>bookmark</term> important games for easy
  future reference. The bookmarks menu is available from the
  <menu>File</menu> menu, the toolbar, or the <B>Ctrl+B</b> shortcut key.
  </p>
  <p>
  When you select a bookmarked game from the Bookmarks menu, Scid will
  open its database if necessary, find that game, and move to the game
  position at which it was bookmarked.
  </p>
  <p>
  Only games in a Scid format database (not a PGN file or the clipbase)
  can be bookmarked.
  </p>
  <p>
  If the database of a bookmarked game is sorted or compacted, the bookmark
  details may become out of date. When that happens, Scid will search the
  database for the best matching game (comparing player names, site, etc)
  when the bookmark is selected, so the bookmarked game should still be
  loaded. However, if details of the bookmarked game change, it is possible
  that a different game will match the bookmark details better and be
  loaded instead. So it is a good idea to re-bookmark a game if you edit
  its players, site, result, round or year.
  </p>

  <h3>Editing bookmarks</h3>
  <p>
  With the bookmark editor, you can change the menu text displayed for
  each bookmarked game and add folders to categorize bookmarks.
  </p>

  <h3>Hints</h3>
  <p>
  You can use bookmarks for fast access to databases you use often
  by bookmarking a game from each database. Another good use for
  bookmarks is to add important games you find when studying a
  particular chess opening.
  </p>
  <p>
  The bookmarks menu contains an entry for controlling the display of
  bookmark folders: they can be shown as submenus (useful when there are
  many bookmarks), or as a single list.
  </p>

  <p><footer>Updated: Scid 3.6.2, December 2006</footer></p>
}

####################
### Command-line options help:

set helpTitle(Cmdline) "Command-line options"
set helpText(Cmdline) {<h1>Command-line Options</h1>
  <p>
  When you start Scid from a shell or console, there are command-line
  options you can specify. Scid-format databases (with or without a
  file suffix such as ".si4") and PGN files to be opened can be given,
  for example:
  <ul>
  <li>scid mybase newgames.pgn</li>
  </ul>
  will start Scid and open the Scid Database called mybase and the
  PGN file named newgames.pgn.
  </p>
  <p>
  There are also optional arguments to control which files Scid should
  search for and use when it starts. You can turn off the use of
  <a TB>tablebases</a> with the <b>-xtb</b> (or <b>-xt</b>) option,
  avoid loading the <a ECO>ECO openings classification</a> file with
  <b>-xeco</b> or <b>-xe</b>, and avoid loading the
  <a Maintenance Spellcheck>spelling</a> file
  with <b>-xspell</b> or <b>-xs</b>. Also, the option <b>-fast</b>
  or <b>-f</b> does all three, so <b>scid -f</b> is equivalent
  to <b>scid -xeco -xspell -xtb</b>.
  </p>

  <p>
  Additionally, a filter file (.sso) can be used on the command line.
  <ul>
  <li>scid mybase myfilter</li>
  </ul>
  will open mybase and run myfilter immediately against it to select a
  set of games. This can e.g. be used to select a list of unfinished
  games in a pgn file.
  </p>

  <p><footer>Updated: Scid 3.6.26, October 2008</footer></p>
}

####################
### Pgnscid help:

set helpTitle(Pgnscid) "Pgnscid"
set helpText(Pgnscid) {<h1>Pgnscid</h1>
  <p>
  <term>Pgnscid</term> is the separate program that you need to use to
  convert PGN (portable game notation) files into Scid Databases.
  </p>
  <p>
  To convert a file named <i>myfile.pgn</i>, simply type:
  <ul>
  <li> <b>pgnscid myfile.pgn</b> </li>
  </ul>
  and the scid database (consisting of <i>myfile.si4</i>, <i>myfile.sg4</i>
  and <i>myfile.sn4</i>) will be created.
  Any errors or warnings will be written to the file <i>myfile.err</i>.
  </p>
  <p>
  If you want the database to be created in a different directory or have
  a different name, you can add the database name to the command line,
  for example:
  <ul>
  <li> <b>pgnscid myfile.pgn mybase</b> </li>
  </ul>
  will create a database consisting of the files <i>mybase.si4</i>,
  <i>mybase.sg4</i> and <i>mybase.sn4</i>.
  </p>
  <p>
  Note that pgnscid (and scid) can read Gzipped PGN files
  (e.g. <b>mybase.pgn.gz</b>)
  directly, so if you have a large PGN file compressed with Gzip to save
  disk space, you do not have to un-gzip it first.
  </p>

  <h3>Options</h3>
  <p>
  There are two optional arguments pgnscid can accept before the filename:
  <b>-f</b> and <b>-x</b>.
  </p>
  <p>
  The <b>-f</b> option forces overwriting of an existing database; by
  default, pgnscid will not convert to a database that already exists.
  </p>
  <p>
  The <b>-x</b> option causes pgnscid to ignore all text between games.
  By default, text between games is stored as a pre-game comment of the
  game that follows. This option only affects text between games; standard
  comments inside each game are still converted and stored.
  </p>

  <h3>Formatting player names</h3>
  <p>
  To reduce the number of multiple spellings of names that refer to the
  same player, some basic formatting of player names is done by pgnscid.
  For example, the number of spaces after each comma is standardized to one,
  any spaces at the start and end of a name are removed, and a dot at the
  end of a name is removed.
  Dutch prefixes such as "van den" and "Van Der" are also normalized to have
  a capital V and small d.
  </p>
  <p>
  You can edit (and even spellcheck) player, event, site and round names in
  Scid; see the <a Maintenance Editing>Maintenance</a> help page for details.
  </p>

  <p><footer>Updated: Scid 3.6.2, December 2006</footer></p>
}


####################
### File formats help:

set helpTitle(Formats) "File Formats"
set helpText(Formats) {<h1>Scid File Formats</h1>
  <p>
  Scid Databases consist of three files - an index file (file suffix .si4), a name file (.sn4) and a game file (.sg4).
</p>

  <h3>The Index File (.si4)</h3>
  <p>
  The Index File contains a description for the database and a small fixed-size
  entry for each game. Each game entry includes essential information such as the result,
  date, player/event/site name IDs (the actual names are in the
  Name File), and some redundant but useful information 
  that is used to speed up searches (see <a Formats Fast>fast searches</a> for more information).
  </p>

  <h3>The Name File (.sn4)</h3>
  <p>
  Contains all Player, Event, Site and Round names used in the
  database. Each name is stored only once even if it occurs in many games, and there is
  a database restriction on the number of unique names. The limits are - 
</p>
<ul><ul>
    <li>Player names:	2^20 - 1</li>
    <li>Event  names:	2^19 - 1</li>
    <li>Site   names:	2^19 - 1</li>
    <li>Round  names:	2^18 - 1</li>
</ul></ul>
  and are defined in <b>namebase.h</b>
  The name file is usually the smallest of the three database files.
  </p>

  <h3>The Game File (.sg4)</h3>
  <p>
  This file contains the actual moves, variations and comments of each game.
  The move encoding format is very compact: most moves take only a single byte!
  </p>
  <p>
  When a game is *replaced* a new version is - in fact - created,
  so wasted space does accumulate over time. The database may
  be restored to its minimal size by <a Compact>compaction</a>.
  </p>

  <h3>Other file formats</h3>
  <p>
  An <a EPD>EPD</a> file (<b>.epd</b>)
  contains a number of chess positions, each with a text comment.
  The EPD file format is described in the <a Related>PGN Standard</a>.
  </p>
  <p>
  An email (<b>.sems</b>) file for a database stores details of the opponents
  you send email messages to.
  </p>
  <p>
  A SearchOptions (<b>.sso</b>) file contains Scid
  <a Searches Header>header</a> or
  <a Searches Material>material/pattern</a> search settings.
  </p>

  <h3><name Fast>Fast searches in Scid</name></h3>
  <p>
  The Index File stores some redundant but useful
  information about each game to speed up position or material searches.
  </p>
  <p>
  For example, the material of the final position is stored. If you search
  for rook and pawn endings, then all games that end with a queen, bishop
  or knight on the board (and have no pawn promotions) will be quickly
  skipped over.
  </p>
  <p>
  Another useful piece of information stored is the order in which pawns
  leave their home squares (by moving, or by being captured). This is used
  to speed up tree or exact position searches, especially for opening
  positions. For example, when searching for the starting position of the
  French Defence (1.e4 e6), every game starts with 1.e4 c5, or 1.d4, etc, will
  be skipped, but games starting with 1.e4 e5 will still need to be searched.
  </p>

  <p><footer>Updated: Scid vs. PC 4.2 November 2010 </footer></p>
}

####################
### Options and Fonts help:

set helpTitle(Options) "Options"
set helpText(Options) {<h1>Options and Preferences</h1>
  <p>
  Many Scid options and preferences (such as the board size, colors, fonts,
  and default settings) are adjustable from the <menu>Options</menu> menu.
  All these (and more, such as the last directory you loaded a database from
  and the sizes of some windows) are saved to an options file when
  you select <b>Save Options</b> from the Options menu.
  The options file is loaded whenever you start Scid.
  </p>
  <p>
  If you use Windows, the options file is <b>scid.opt</b> in the directory
  where the Scid program file <b>scid.exe</b> is located. For users of Unix
  operating systems (such as Solaris or Linux) the file
  is <b>~/.scid/scidrc</b>.
  </p>

  <h3><name MyPlayerNames>Setting your player names</name></h3>
  <p>
  There may be a player name (or several names) for whom, whenever a game
  is loaded, you would like the main window chessboard to be displayed from
  the perspective of that player. You can configure a list of such names
  using <b>My Player Names...</b> from the <menu>Options/Chessboard</menu>
  menu. In the dialog box that appears, enter one player name on each line.
  Wildcard characters ("<b>?</b>" for exactly one character and "<b>*</b>"
  for a sequence of zero or more characters) can be used.
  </p>

  <h3><name Fonts>Setting Fonts</name></h3>
  <p>
  Scid has three basic fonts it uses in most of its windows, and you can
  customize all of them. They are called <b>regular</b>, <b>small</b> and
  <b>fixed</b>.
  </p>
  <p>
  The fixed font should be a fixed-width (not proportional) font. It is used
  for the <a Tree>tree</a> and <a Crosstable>crosstable</a> windows.
  </p>

  <p><footer>Updated: Scid 3.6.2, December 2006</footer></p>
}

####################
### NAG values help:

set helpTitle(NAGs) "NAG values"
set helpText(NAGs) {<h1>Standard NAG Values</h1>
  <p>
  Standard NAG (Numeric Annotation Symbol) values defined in the
  <a Related>PGN Standard</a> are:
  </p>
  <cyan>
  <ul>
  <li>  1   Good move (!) </li>
  <li>  2   Poor move (?) </li>
  <li>  3   Excellent move (!!) </li>
  <li>  4   Blunder (??) </li>
  <li>  5   Interesting move (!?) </li>
  <li>  6   Dubious move (?!) </li>
  <li>  7   Forced move </li>
  <li>  8   Singular move; no reasonable alternatives </li>
  <li>  9   Worst move </li>
  <li> 10   Drawish position (=) </li>
  <li> 11   Equal chances, quiet position (=) </li>
  <li> 12   Equal chances, active position (=) </li>
  <li> 13   Unclear position (~) </li>
  <li> 14   White has a slight advantage (+=) </li>
  <li> 15   Black has a slight advantage (=+) </li>
  <li> 16   White has a moderate advantage (+/-) </li>
  <li> 17   Black has a moderate advantage (-/+) </li>
  <li> 18   White has a decisive advantage (+-) </li>
  <li> 19   Black has a decisive advantage (-+) </li>
  <li> 20   White has a crushing advantage (+-) </li>
  <li> 21   Black has a crushing advantage (-+) </li>
  <li> 22   White is in zugzwang </li>
  <li> 23   Black is in zugzwang </li>
  <li> 24   White has a slight space advantage </li>
  <li> 25   Black has a slight space advantage </li>
  <li> 26   White has a moderate space advantage </li>
  <li> 27   Black has a moderate space advantage </li>
  <li> 28   White has a decisive space advantage </li>
  <li> 29   Black has a decisive space advantage </li>
  <li> 30   White has a slight time (development) advantage </li>
  <li> 31   Black has a slight time (development) advantage </li>
  <li> 32   White has a moderate time (development) advantage </li>
  <li> 33   Black has a moderate time (development) advantage </li>
  <li> 34   White has a decisive time (development) advantage </li>
  <li> 35   Black has a decisive time (development) advantage </li>
  <li> 36   White has the initiative </li>
  <li> 37   Black has the initiative </li>
  <li> 38   White has a lasting initiative </li>
  <li> 39   Black has a lasting initiative </li>
  <li> 40   White has the attack </li>
  <li> 41   Black has the attack </li>
  <li> 42   White has insufficient compensation for material deficit </li>
  <li> 43   Black has insufficient compensation for material deficit </li>
  <li> 44   White has sufficient compensation for material deficit </li>
  <li> 45   Black has sufficient compensation for material deficit </li>
  <li> 46   White has more than adequate compensation for material deficit </li>
  <li> 47   Black has more than adequate compensation for material deficit </li>
  <li> 48   White has a slight center control advantage </li>
  <li> 49   Black has a slight center control advantage </li>
  <li> 50   White has a moderate center control advantage </li>
  <li> 51   Black has a moderate center control advantage </li>
  <li> 52   White has a decisive center control advantage </li>
  <li> 53   Black has a decisive center control advantage </li>
  <li> 54   White has a slight kingside control advantage </li>
  <li> 55   Black has a slight kingside control advantage </li>
  <li> 56   White has a moderate kingside control advantage </li>
  <li> 57   Black has a moderate kingside control advantage </li>
  <li> 58   White has a decisive kingside control advantage </li>
  <li> 59   Black has a decisive kingside control advantage </li>
  <li> 60   White has a slight queenside control advantage </li>
  <li> 61   Black has a slight queenside control advantage </li>
  <li> 62   White has a moderate queenside control advantage </li>
  <li> 63   Black has a moderate queenside control advantage </li>
  <li> 64   White has a decisive queenside control advantage </li>
  <li> 65   Black has a decisive queenside control advantage </li>
  <li> 66   White has a vulnerable first rank </li>
  <li> 67   Black has a vulnerable first rank </li>
  <li> 68   White has a well protected first rank </li>
  <li> 69   Black has a well protected first rank </li>
  <li> 70   White has a poorly protected king </li>
  <li> 71   Black has a poorly protected king </li>
  <li> 72   White has a well protected king </li>
  <li> 73   Black has a well protected king </li>
  <li> 74   White has a poorly placed king </li>
  <li> 75   Black has a poorly placed king </li>
  <li> 76   White has a well placed king </li>
  <li> 77   Black has a well placed king </li>
  <li> 78   White has a very weak pawn structure </li>
  <li> 79   Black has a very weak pawn structure </li>
  <li> 80   White has a moderately weak pawn structure </li>
  <li> 81   Black has a moderately weak pawn structure </li>
  <li> 82   White has a moderately strong pawn structure </li>
  <li> 83   Black has a moderately strong pawn structure </li>
  <li> 84   White has a very strong pawn structure </li>
  <li> 85   Black has a very strong pawn structure </li>
  <li> 86   White has poor knight placement </li>
  <li> 87   Black has poor knight placement </li>
  <li> 88   White has good knight placement </li>
  <li> 89   Black has good knight placement </li>
  <li> 90   White has poor bishop placement </li>
  <li> 91   Black has poor bishop placement </li>
  <li> 92   White has good bishop placement </li>
  <li> 93   Black has good bishop placement </li>
  <li> 94   White has poor rook placement </li>
  <li> 95   Black has poor rook placement </li>
  <li> 96   White has good rook placement </li>
  <li> 97   Black has good rook placement </li>
  <li> 98   White has poor queen placement </li>
  <li> 99   Black has poor queen placement </li>
  <li>100   White has good queen placement </li>
  <li>101   Black has good queen placement </li>
  <li>102   White has poor piece coordination </li>
  <li>103   Black has poor piece coordination </li>
  <li>104   White has good piece coordination </li>
  <li>105   Black has good piece coordination </li>
  <li>106   White has played the opening very poorly </li>
  <li>107   Black has played the opening very poorly </li>
  <li>108   White has played the opening poorly </li>
  <li>109   Black has played the opening poorly </li>
  <li>110   White has played the opening well </li>
  <li>111   Black has played the opening well </li>
  <li>112   White has played the opening very well </li>
  <li>113   Black has played the opening very well </li>
  <li>114   White has played the middlegame very poorly </li>
  <li>115   Black has played the middlegame very poorly </li>
  <li>116   White has played the middlegame poorly </li>
  <li>117   Black has played the middlegame poorly </li>
  <li>118   White has played the middlegame well </li>
  <li>119   Black has played the middlegame well </li>
  <li>120   White has played the middlegame very well </li>
  <li>121   Black has played the middlegame very well </li>
  <li>122   White has played the ending very poorly </li>
  <li>123   Black has played the ending very poorly </li>
  <li>124   White has played the ending poorly </li>
  <li>125   Black has played the ending poorly </li>
  <li>126   White has played the ending well </li>
  <li>127   Black has played the ending well </li>
  <li>128   White has played the ending very well </li>
  <li>129   Black has played the ending very well </li>
  <li>130   White has slight counterplay </li>
  <li>131   Black has slight counterplay </li>
  <li>132   White has moderate counterplay </li>
  <li>133   Black has moderate counterplay </li>
  <li>134   White has decisive counterplay </li>
  <li>135   Black has decisive counterplay </li>
  <li>136   White has moderate time control pressure </li>
  <li>137   Black has moderate time control pressure </li>
  <li>138   White has severe time control pressure </li>
  <li>139   Black has severe time control pressure </li>
  </ul>
  </cyan>

  <p>
  Other proposed NAG values for Chess Informant publication symbols include:
  </p>
  <cyan>
  <ul>
  <li>140   With the idea ... </li>
  <li>141   Aimed against ... </li>
  <li>142   Better move </li>
  <li>143   Worse move </li>
  <li>144   Equivalent move </li>
  <li>145   Editor's Remark ("RR") </li>
  <li>146   Novelty ("N") </li>
  <li>147   Weak point </li>
  <li>148   Endgame </li>
  <li>149   Line </li>
  <li>150   Diagonal </li>
  <li>151   White has a pair of Bishops </li>
  <li>152   Black has a pair of Bishops </li>
  <li>153   Bishops of opposite color </li>
  <li>154   Bishops of same color </li>
  </ul>
  </cyan>

  <p>
  Other suggested values are:
  </p>
  <cyan>
  <ul>
  <li>190   Etc. </li>
  <li>191   Doubled pawns </li>
  <li>192   Isolated pawn </li>
  <li>193   Connected pawns </li>
  <li>194   Hanging pawns </li>
  <li>195   Backwards pawn </li>
  </ul>
  </cyan>

  <p>
  Symbols defined by Scid for its own use are:
  </p>
  <cyan>
  <ul>
  <li>201   Diagram ("D", sometimes denoted "#") </li>
  </ul>
  </cyan>

  <p><footer>Updated: Scid 3.6.2, December 2006</footer></p>
}


set helpTitle(ECO) "ECO guide"
set helpText(ECO) {<h1>ECO Openings Classification</h1>
  <p>
  Scid can classify chess games according to the <b>ECO</b>
  (Encyclopedia of Chess Openings) chess openings classification.
  An standard ECO code consists of a letter (A..E) followed by two
  digits, so there are 500 distinct standard ECO codes.
  </p>

  <h3>Scid extensions to the ECO system</h3>
  <p>
  The ECO system is very limited and not sufficient for modern games:
  some of the 500 codes are almost never seen any more, while some
  are seen very often. To improve this situation, Scid allows an optional
  extension to the basic ECO codes: each code can be extended with a
  letter (a..z), with a further extension (another digit, 1..4) being
  possible but not used in the standard Scid ECO file yet.
  So an extended Scid ECO code looks like "<b>A41e</b>" or "<b>E99b2</b>".
  Many of the most common ECO codes found in modern master-level games have
  extensions defined in the Scid ECO file.
  </p>

  <h3><name Browser>The ECO Browser window</name></h3>
  <p>
  The <term>ECO Browser</term> window shows you the positions that are
  used to classify each ECO code, and the frequency and performance of
  ECO codes in the current database.
  </p>
  <p>
  The upper pane shows the frequency of each ECO code in the current
  database. The bars in the graph have three sections: the lowest
  (lightest color) is the number of White wins, the middle is the
  number of draws, and the highest (darkest) is the number of Black wins.
  This lets you see at a glance the characteristics of an opening: for
  example, if White is scoring very well, or if draws are very common.
  </p>
  <p>
  To go to a deeper ECO level, click the left mouse button
  on a bar in the graph (or type the
  letter or digit it corresponds to). To go back to the higher level,
  click the right mouse button anywhere in the graph, or press the left
  arrow (or delete or backspace) key.
  </p>
  <p>
  The lower pane shows the positions that comprise a particular ECO code,
  according to the ECO file you have loaded.
  </p>

  <h3>Loading the Scid ECO file</h3>
  <p>
  The ECO file that comes with Scid is called <b>scid.eco</b>,
  and Scid tries to load this when it starts up.
  If Scid cannot find it, you will need to do the following to enable ECO
  classification:
  <ul>
  <li>(a) In Scid, use the menu command
  <menu>Options: Load ECO file</menu>
  and select the file <b>scid.eco</b>. </li>
  <li>(b) Save options (from the <menu>Options</menu> menu). </li>
  </ul>
  After you do this, the ECO file will be loaded every time you start Scid.
  </p>

  <h3><name Codes>ECO code system</name></h3>
  <p>
  The basic structure of the ECO system is:
  </p>
  <p>
  <b><blue><run ::windows::eco::Refresh A>A</run></blue></b>
  1.d4 Nf6 2...;  1.d4 ...;  1.c4;  1.various
  <ul>
  <li>  <b>A0</b>  1.<i>various</i>
  (<b>A02-A03</b> 1.f4: <i>Bird's Opening</i>,
  <b>A04-A09</b>  1.Nf3: <i>Reti, King's Indian Attack</i>) </li>
  <li>  <b>A1</b>  1.c4 ...: <i>English</i> </li>
  <li>  <b>A2</b>  1.c4 e5: <i>King's English</i> </li>
  <li>  <b>A3</b>  1.c4 c5: <i>English, Symmetrical </i> </li>
  <li>  <b>A4</b>  1.d4 ...: <i>Queen's Pawn</i> </li>
  <li>  <b>A5</b>  1.d4 Nf6 2.c4 ..: <i>Indian Defence </i> </li>
  <li>  <b>A6</b>  1.d4 Nf6 2.c4 c5 3.d5 e6: <i>Modern Benoni</i> </li>
  <li>  <b>A7</b>  A6 + 4.Nc3 exd5 5.cxd5 d6 6.e4 g6 7.Nf3 </li>
  <li>  <b>A8</b>  1.d4 f5: <i>Dutch Defence</i> </li>
  <li>  <b>A9</b>  1.d4 f5 2.c4 e6: <i>Dutch Defence</i> </li>
  </ul>

  <p>
  <b><blue><run ::windows::eco::Refresh B>B</run></blue></b>
  1.e4 c5;  1.e4 c6;  1.e4 d6;  1.e4 <i>various</i>
  <ul>
  <li>  <b>B0</b>  1.e4 ...
  (<b>B02-B05</b>  1.e4 Nf6: <i>Alekhine Defence</i>;
  <b>B07-B09</b>  1.e4 d6: <i>Pirc</i>) </li>
  <li>  <b>B1</b>  1.e4 c6: <i>Caro-Kann</i> </li>
  <li>  <b>B2</b>  1.e4 c5: <i>Sicilian Defence </i> </li>
  <li>  <b>B3</b>  1.e4 c5 2.Nf3 Nc6: <i>Sicilian</i> </li>
  <li>  <b>B4</b>  1.e4 c5 2.Nf3 e6: <i>Sicilian</i> </li>
  <li>  <b>B5</b>  1.e4 c5 2.Nf3 d6: <i>Sicilian</i> </li>
  <li>  <b>B6</b>  B5 + 3.d4 cxd4 4.Nxd4 Nf6 5.Nc3 Nc6 </li>
  <li>  <b>B7</b>  B5 + 4.Nxd4 Nf6 5.Nc3 g6: <i>Sicilian Dragon</i> </li>
  <li>  <b>B8</b>  B5 + 4.Nxd4 Nf6 5.Nc3 e6: <i>Sicilian Scheveningen</i> </li>
  <li>  <b>B9</b>  B5 + 4.Nxd4 Nf6 5.Nc3 a6: <i>Sicilian Najdorf</i> </li>
  </ul>

  <p>
  <b><blue><run ::windows::eco::Refresh C>C</run></blue></b>
  1.e4 e5;  1.e4 e6
  <ul>
  <li>  <b>C0</b>  1.e4 e6: <i>French Defence</i> </li>
  <li>  <b>C1</b>  1.e4 e6 2.d4 d5 3.Nc3: <i>French, Winawer/Classical</i> </li>
  <li>  <b>C2</b>  1.e4 e5: <i>Open Game</i> </li>
  <li>  <b>C3</b>  1.e4 e5 2.f4: <i>King's Gambit</i> </li>
  <li>  <b>C4</b>  1.e4 e5 2.Nf3: <i>Open Game</i> </li>
  <li>  <b>C5</b>  1.e4 e5 2.Nf3 Nc6 3.Bc4: <i>Italian; Two Knights</i> </li>
  <li>  <b>C6</b>  1.e4 e5 2.Nf3 Nc6 3.Bb5: <i>Spanish (Ruy Lopez)</i> </li>
  <li>  <b>C7</b>  1.e4 e5 2.Nf3 Nc6 3.Bb5 a6 4.Ba4: <i>Spanish</i> </li>
  <li>  <b>C8</b>  C7 + 4...Nf6 5.O-O: <i>Spanish, Closed and Open</i>
  (<b>C80-C83</b>  5.O-O Nxe4: <i>Spanish, Open System</i>;
  <b>C84-C89</b>  5.O-O Be7: <i>Spanish, Closed System</i>) </li>
  <li>  <b>C9</b>  C8 + 5...Be7 6.Re1 b5 7.Bb3 d6: <i>Spanish, Closed</i> </li>
  </ul>

  <p>
  <b><blue><run ::windows::eco::Refresh D>D</run></blue></b>
  1.d4 d5; 1.d4 Nf6 2.c4 g6 with 3...d5
  <ul>
  <li>  <b>D0</b>   1.d4 d5: <i>Queen's Pawn</i> </li>
  <li>  <b>D1</b>   1.d4 d5 2.c4 c6: <i>Slav Defence</i> </li>
  <li>  <b>D2</b>  1.d4 d5 2.c4 dxc4: <i>Queen's Gambit Accepted (QGA)</i> </li>
  <li>  <b>D3</b>  1.d4 d5 2.c4 e6: <i>Queen's Gambit Declined (QGD)</i> </li>
  <li>  <b>D4</b>  D3 + 3.Nc3 Nf6 4.Nf3 c5/c6: <i>Semi-Tarrasch; Semi-Slav</i> </li>
  <li>  <b>D5</b>  D3 + 3.Nc3 Nf6 4.Bg5: <i>QGD Classical</i> </li>
  <li>  <b>D6</b>  D5 + 4...Be7 5.e3 O-O 6.Nf3 Nbd7: <i>QGD Orthodox</i> </li>
  <li>  <b>D7</b>  1.d4 Nf6 2.c4 g6 with 3...d5: <i>Grunfeld</i> </li>
  <li>  <b>D8</b>  1.d4 Nf6 2.c4 g6 3.Nc3 d5: <i>Grunfeld</i> </li>
  <li>  <b>D9</b>  1.d4 Nf6 2.c4 g6 3.Nc3 d5 4.Nf3: <i>Grunfeld</i> </li>
  </ul>

  <p>
  <b><blue><run ::windows::eco::Refresh E>E</run></blue></b>
  1.d4 Nf6 2.c4 e6; 1.d4 Nf6 2.c4 g6 </li>
  <ul>
  <li>  <b>E0</b>  1.d4 Nf6 2.c4 e6: <i>Catalan, etc</i> </li>
  <li>  <b>E1</b>  1.d4 Nf6 2.c4 e6 3.Nf3 (b6): <i>Queen's Indian, etc</i> </li>
  <li>  <b>E2</b>  1.d4 Nf6 2.c4 e6 3.Nc3 (Bb4): <i>Nimzo-Indian, etc</i> </li>
  <li>  <b>E3</b>  E2 + 4.Bg5 or 4.Qc2: <i>Nimzo-Indian</i> </li>
  <li>  <b>E4</b>  E2 + 4.e3: <i>Nimzo-Indian, Rubinstein</i> </li>
  <li>  <b>E5</b>  E4 + 4...O-O 5.Nf3: <i>Nimzo-Indian, main line</i> </li>
  <li>  <b>E6</b>  1.d4 Nf6 2.c4 g6: <i>King's Indian</i> </li>
  <li>  <b>E7</b>  1.d4 Nf6 2.c4 g6 3.Nc3 Bg7 4.e4: <i>King's Indian</i> </li>
  <li>  <b>E8</b>  E7 + 4...d6 5.f3: <i>King's Indian, Samisch</i> </li>
  <li>  <b>E9</b>  E7 + 4...d6 5.Nf3: <i>King's Indian, main lines</i> </li>
  </ul>

  <p><footer>Updated: Scid 3.6.2, December 2006</footer></p>
}


set helpTitle(Author) "About"
set helpText(Author) "<h1>Scid vs. PC</h1>
  <ht><img splash></ht>
  <p>
  <ul> <ul> <ul> <ul> <ul> <ul> <ul>
  <li>Scid vs. PC  version $::scidVersion</li>
  <br>
  <li>(C) Steven Atkinson, stevenaaus@yahoo.com</li>
  <br>
  <li><url http://scidvspc.sourceforge.net/>http://scidvspc.sourceforge.net/</url></li>
  <br>
  <li>Based on: Shane's Chess Information Database 3.6.26</li>
  <li>, including many updates from mainline Scid.</li>
  <br>
  <li>Authors: Shane Hudson and Pascal Georges.</li>
  <li>(C) Shane Hudson, Pascal Georges and others.</li>
  <br>
  <li>Licenced under the GNU General Public License.</li>
  <br>
  <li>Using Tcl/Tk version [info patchlevel]</li>

</ul> </ul> </ul> 
  <p><footer>(Project Updated: $::scidVersion, $::scidVersionDate)</footer></p>
  </p>
"

set helpTitle(Related) "Links"
set helpText(Related) {<h1>Related Links</h1>
  <p>
  <ul>
  <li><url http://scidvspc.sourceforge.net/>http://scidvspc.sourceforge.net/</url> --
  Scid vs. PC</li>
  <br>
  <li><url http://scid.sourceforge.net/>http://scid.sourceforge.net/</url> --
  Scid Web Page</li>
  <li><url http://sourceforge.net/mailarchive/forum.php?forum_name=scid-users>http://sourceforge.net/mailarchive/forum.php...</url>-- Scid Mailing List</url> 
  <li><url http://www.freechess.org>www.freechess.org</url> -- Fics homepage</li>
  <br>
  <li><url www.saremba.de/chessgml/standards/pgn/pgn-complete.htm>www.saremba.de/chessgml/standards/pgn...</url> -- The PGN Standard,
  created by Steven J. Edwards in 1994, explains the PGN and EPD formats in detail.</li>
  <br>
  <li> <url www.chessvibes.com>www.chessvibes.com </url></li>
  <li> <url www.chessbase.com/index.asp>www.chessbase.com/index.asp </url></li>
  <li> <url www.chesscenter.com/twic/>www.chesscenter.com/twic/</url> 
-- A few popular chess portals. </li>
<br>

  <li><url www.pgnmentor.com/files.html#players>www.pgnmentor.com/files.html#players</url> --
  Pgn archive of famous players.</li>
  <li><url www.pgnmentor.com/files.html#events>www.pgnmentor.com/files.html#events</url> --
  Pgn archive of events.</li>

  <li><url www.virtualpieces.net>www.virtualpieces.net</url> --
  Professional quality chess icons, providing this project's new logo.</li>
  </ul>
<p><footer>Updated: Scid vs PC 4.0, June 2010</footer></p>
}

# Book window help
set helpTitle(Book) "Book Window"
set helpText(Book) {<h1>Book Window</h1>
  <p>
  A list of all book files present in Scid's books directory is
  presented in the drop down list on top of the window. To specify the
  directory where Scid shoul search for opening books select Options /
  Books directory from the menu. The active book can be selected
  easily from that list.
  </p>
  <p>
  The format of books is the one used by Polyglot and the engines like
  Fruit and Toga, their usual extension is .bin. Currently, to build
  new books one has to use <term>polyglot</term> on the command line.
  Please refer to polyglots documentation about how to create a book.
  </p>
  <p>
  For each position, the book window displays all possible moves it
  contains and their relative weights in percent. When a move is
  entered, the book window is updated. Clicking on a move in the book
  window will play that move in current position.
  </p>
  <p>
  The book in use can be selected from the drop down list in the
  book window.
  </p>
  <p><footer>Updated: Scid 3.6.26, October 2008</footer></p>
}

# Tactical game window help
set helpTitle(TacticalGame) "Tactical Game Window"
set helpText(TacticalGame) {<h1>Tactical Game</h1>

<p> Scid offers several ways to play the computer at chess. The most convenient
is the <run ::tacgame::config><green>Play--<gt>Tactical Game</green></run> menu item. Here you'll find the option to start a new game (or Fischer Chess game), against a flexible computer opponent whose skill you can select. Skill levels vary between 1200 (a bright teenager with some experience), to 2200 (a National Master).
</p><p>
Your opponent is played by the <b>Phalanx</b> engine, and there is also a
computer coach (<b>Toga II</b>) watching the game who will indicate any
blunders Phalanx makes.  </p>

<p>
<i>Other computer opponents can be found in the
<a SeriousGame>Serious Game</a> and <a Analysis>Analysis</a> features</i>.
</p>

<h3>Starting the Game</h3>
  <p>
  The following parameters must be configured :
  <ul>
  <li><term>Fixed level</term>: sets a fixed ELO rating for the opponent</li>
  <li><term>Random level</term>: chooses a random level between the
  minimum and maximum level specified by the left and right slider
  respectively.
  </li>
  <li><term>Opening:</term>
  <ul>
     <li><term>Start new game</term>: starts a new game choosing a
     random opening.</li>
     <li><term>Start from current position</term>: let the game begin
     with the current board position.</li>
     <li><term>Play Fischer Chess</term>: Fischer Chess is a variant (named
for Bobby Fischer) where the first and last rows of pieces are
pseudo-randomnly arranged. Scid vs. PC does not properly implement a few
rules.. notably, castling <b>is</b> allowed in Fischer Chess, but not in
our game.</li>
     <li><term>Random Pawns</term>: will randomly place pawns on the second and third ranks.</li>
     <li><term>Specific opening</term>: the opponent will play a
     specific opening, that can be chosen from the list below. This is
     useful for opening training.</li>
  </ul>
  <li><term>Limit engine analysis time</term> allows to limit the time used by the
  coach to check the players moves for errors. If this time is not
  limited the coach is allowed to think in the background.</li>
  </ul>

<p><footer>Updated: Scid vs. PC 4.0, May 2010</footer></p>
}

# Opening Trainer window help
set helpTitle(OpeningTrainer) "Opening Trainer"
set helpText(OpeningTrainer) {<h1>Opening Trainer</h1>
  <p>
  A Scid Database can be used as a repertoire, each game representing
  an opening line. The games can contain variations and may also
  contain NAG values to specify values for each line, and thus
  allowing to mark preferred or dubious lines. To be a valid database
  for the opening trainer it is also required to be of proper type.
  That is, if openings for white are to be trained, the database has
  to be of type <term>Openings for White</term> (similar for Black and
  both colours). The type can be set via the <a Maintenance>Maintenance
  window</a> by selecting the icon or via the database switchers
  context menu.
  </p>
  <p>
  To use the opening trainer first of all open a repertoire database
  of the proper type. Then choose Play / Training / Opening Trainer.
  The upcoming dialogue offers some choices about the next training
  session
  <ul>
      <li><term>white</term>/<term>black</term>/<term>both</term> is
      used to select the side of the opening to train
      </li>
      <li><term>Allow only best moves</term> will treat lower rated moves
      as error. The rating of a line is given by NAG values.</li>
      <li><term>Opponent plays best moves</term> Scid will always play
      the best continuation according to the repertoire database. If
      unchecked Scid is allowed to choose also lower rated
      continuations. This is helpful to learn the refutations as well.
      </li>
      <li><term>Only flagged lines</term> Scid will only play lines
      from games flagged as <term>Opening for White</term> or
      <term>Opening for Black</term>.
      </li>
      <li><term>Reset statistics</term> will reset the statistics
      before the training session.</li>
  </ul>
  Press the <term>Continue</term> button to proceed with the training.
  </p>
  <p>
  The actual opening trainer will show up. Here one can display
  possible candidate moves (hidden by default) and also display their
  values by just enabling these functions. If <term>Show
  statistics</term> is enabled, the current statistics is shown in the
  colour coded fields below the checkbox. Otherwise the overall
  statistics can be accessed by the button <term>Show report</term>

  <h3>Opening trainer statistics</h3>
  <p>
  Four numbers are displayed showing statistics for current position:
  <ul>
  <li><term>Green</term> the number of moves played by the user that
  are good moves</li>
  <li><term>Yellow</term> the number of dubious moves played that are
  in the repertoire</li>
  <li><term>Red</term> the number of moves played that are not in the
  repertoire</li>
  <li><term>White</term> the number of times the position was
  encountered</li>
  </ul>
  </p>

  <h3>The report</h3>
  <p>
  The report shows statistics for the whole repertoire and gives
  information about user's knowledge :
  <ul>
  <li><term>Positions in repertoire</term> the total number of
  positions in the repertoire (all lines in database)</li>
  <li><term>Positions not played</term> the positions that were never
  encountered</li>
  <li><term>Positions played</term> the positions that were played and
  the sum of the number of times they were encountered. Note that this
  figure represents the sum of occurrences of a position in all
  opening lines: this number can quickly become big for positions
  that are close to the start position</li>
  <li><term>Success</term> the number of good moves made by the player</li>
  <li><term>Dubious moves</term> the number of weak moves made by the
  player</li>
  <li><term>Out of repertoire</term> the number of moves made by the
  player that were not in repertoire</li>
  </ul>
  </p> 
  <p><footer>Updated: Scid 3.6.26, October 2008</footer></p>
}

####################
### Correspondence Chess help:
set helpTitle(Correspondence) "Correspondence Chess"
set helpText(Correspondence) {<h1>Correspondence Chess</h1>

<p>
Scid offers currently two main functionalities for correspondence
chess.
</p>
<ul>
   <li><b>eMail Chess</b> proceeds by sending the current game via eMail
   to your opponet once you made your move. To this end an eMail message
   is created in your prefered email program with the current game
   attached to it in PGN format. Of course all comments and
   variations are stripped off before.
   </li>
   <li><b>Correspondence Chess Servers</b> are supported by means of the
   Xfcc protocol. Here external tools are used to fetch the games from
   your account(s) and deliver them to Scid for synchronisation. After
   you made your move this move is sent to your opponent also by means of
   Xfcc. The fetch and send tool are implemented as external tools for
   easy extension if other protocols arise.
   </li>
</ul>
<p>
If any of the correspondence chess functions are accessed from the
menu a new window opens up. It can be opened manually from the window
menu. This window contains the neccessary buttons to navigate through
ongoing games, shortcut keys to fetch games by means of the Xfcc
protocol and sync in eMail based games as well as a console stating
which messages where sent or retrieved. Additionally this window
conatins a list of ongoing games retrieved from your Inbox directory.
</p>

<p>
To use the correspondence chess features a database of the type
"Correspondence chess" has to be opened before calling any
correspondence chess functions. If you do not have such a database
yet, just create a new database an set its type to "Correspondence
chess" by means of the <a Maintenance>Maintenance</a> function.
Setting the type is important as Scid will recognise the database for
synchronisation by this type. As this database is empty after the
creation Scid will treat all correspondence chess games it receives at
first synchronisation as new games and append them to this database.
</p>

<p>
If no database of the type "Correspondence chess" is currently opened
Scid will remid you of doing so. However, do not open more than one
database of this type as Scid then can not recognise the one to use.
</p>

<h3>Basic functionality</h3>

<p>
If everything is set up correctly the usage of the correspondence
chess functions can easily accessed by the follwoing buttons:
<ul>
   <li><button tb_CC_Retrieve> Retrieve the correspondence chess games.
   To this end the external fetch tool is called and all games retrieved
   via that way as well as all other games that are stored in Scids Inbox
   (see below) are synchronised into the current correspondence chess
   database.
   </li>
   <li><button tb_CC_Prev> Goes to the previous game in Scids Inbox
   </li>
   <li><button tb_CC_Next> Goes to the next game in Scids Inbox
   </li>
   <li><button tb_CC_Send> Sends your move to the opponent by either
   creating a new eMail message in your prefered mail program or by
   sending the move to a chess server in case of Xfcc.
   </li>
   <li><button tb_CC_delete> empties your In- and Outbox directories.
   </li>
   <li><button tb_CC_online> is shown if the game list was refreshed
   from the server within the current Scid session. The tool tip for
   this icon shows date and time of the last refresh.
   </li>
   <li><button tb_CC_offline> indicates, that Xfcc status icons are
   restored from saved results. No update has taken place in the
   current Scid session. The tool tip for this icon shows date and
   time of the last refresh.
   </li>
</ul>
</p>
<p>
See also the list of <a CCIcons>Icons and Status Indicators</a>.
</p>

<h3>Configuration</h3>

<p>
Correspondence Chess within Scid is based upon a normal Scid
database that holds the games and some helpers external to Scid that
handle the "non-chess-parts". These tools and parameters must be set
up once, and are stored afterwards for future use.
</p>

<p>
To access the configuration dialog choose <menu>Play</menu>
<menu>Correspondence Chess</menu><menu>Configure</menu> from the
menu. The details are described in <a CCSetupDialog>Correspondence
Chess Setup</a>. Quitting this dialog by the <b>[Ok]</b> button will
automatically store your options.
</p>

<h3>Retrieving the games</h3>
<p>
Depending wether you play correspondence chess via eMail or via a
chess server the actual retrieval process differs slightly. Generally
it results in a set of games in PGN format located in Scids Inbox
directory. This offers also the possibility of automatic retrieval via
external software.
</p>
<p>
Once the games are in Scids Inbox invoking <menu>Process Inbox</menu>
from the menu will work though the Inbox and add new moves to the
games already in the database. Additionally it will add games not
found in the current correspondence chess database as new games.
</p>

<p><a CCeMailChess>Correspondence Chess via eMail</a> describes the
details for the usage of eMail, while in <a CCXfcc>Correspondence
Chess via Chess Servers</a> describes the same for correspondence
chess servers.
</p>

<h3>Stepping through games</h3>
<p>
After games are retrieved they are loaded to Scids clipboard database
and new moves are added and stored in the correspondence chess
database opened. The most convenient way to step through the games is
by the two buttons <button tb_CC_Prev> and <button tb_CC_Next> which
go to the previous and the next game, respectively. The difference to
the functions from the <menu>Games</menu> menu is, that these two
buttons scroll only between the games in Scids Inbox which are
supposed to be your actually ongoing games. Of course the
Correspondence Chess database might contain much more games, but
normally you do not want to go through all these to find out what your
opponent moved in a current game.
</p>
<p>
Note that a header search is required incorporating some fields that
are not indexed by Scid. Hence, storing your correspondence chess
games in a huge reference database might not be advisable as the
search times may be quite long. If you play a lot and your own
database gets quite large, search times can be reduced by moving
finished games to an archive database, or by just createing a new
database for the ongoing games. Scid will treat all games not existing
in the correspondence chess database already as new games and add them
automatically. Hence, it is sufficient to open an empty database of
type "Correspondence chess" and call <menu>Process Inbox</menu> to
import all currently ongoing games.
</p>
<p>
Equivalent to the two buttons mentinoned are the items <menu>Previous
Game</menu> and <menu>Next Game</menu> from the <menu>Correpondence
Chess</menu> menu.
</p>
<p>
An alternate way to jump to a specific game is by double clicking on
it within the game list.
</p>
<p>
Note that if you set up your player names correctly (by means of
<menu>My Player Names</menu>) Scid will rotate the board for you to
play always upwards. You can have multiple player names. See also <a
Options MyPlayerNames>My Player Names</a> for details.
</p>

<h3>Analyse and make a move</h3>
<p>
All analysis features can be used for correspondence chess games.
Variations, annotations etc. can be added just like in normal game
analysis. Once finished, Scid will take the last half move added to
the game and treat it as the current move to send. No checking wether
only one half a move was added or which side to move is done here,
hence, only one half move to the mainline must be added!  In case a
chess server is used Scid also sends the last comment added to the
server which might be usefull for communication with the opponent. In
eMail chess this can be done by the normal mail message, so there all
commments are stripped off.
</p>
<p>
Pressing the Send button <button tb_CC_Send> will have Scid to
determine the type of the correspondence chess game displayed (eMail or
a server game) and call either your eMail program or the external send
tool to submit your move. Calling <menu>Send move</menu> is equivalent
to this button. Alternatively, <menu>Mail move</menu> can be used to
send the current game via eMail. In case of an eMail game this
function is equivalent to <menu>Send move</menu>. In case of a server
based game an eMail message is generated. Note however, that it will
not necessarily contain a proper recipient as eMail addresses are not
exchanged in server based correspondence chess.
</p>


<p><footer>Updated: Scid 3.6.25, August 2008</footer></p>
}

set helpTitle(CCIcons) "Correspondence Chess Icons and Status Indicators"
set helpText(CCIcons) {
<h1>Icons and Status Indicators</h1>
<p>
To shorten the display, a set of icons is used in the game list. Some
of them are only present in certain circumstances, some are only valid
for Xfcc based games, some for eMail based games. These indicators are
stored internally and are restored to the last update from the server
if no interet connection is available.
</p>
<ul>
   <li><button tb_CC_online> is shown if the game list was refreshed
   from the server within the current Scid session. The tool tip for
   this icon shows date and time of the last refresh.
   </li>
   <li><button tb_CC_offline> indicates, that Xfcc status icons are
   restored from saved results. No update has taken place in the
   current Scid session. The tool tip for this icon shows date and
   time of the last refresh.
   </li>
   <li><button tb_CC_envelope> This is an eMail based game. In those
   games many of the status flags used in Xfcc-based games are not
   available due to the limitation of the medium.
   </li>
   <li><button tb_CC_yourmove>
   Its your move. Note: this status is only updated if you
   synchronise your games with the server, that is, it always refers
   to the servers status at last syncronisation.
   </li>
   <li><button tb_CC_oppmove>
   Its the opponents move. Note: this status is only updated if you
   synchronise your games with the server, that is, it always refers
   to the servers status at last syncronisation.
   </li>
   <li><button tb_CC_draw>
   Peace was agreed by a draw.
   </li>
   <li><button tb_CC_book>
   The use of opening books is allowed for this game.
   </li>
   <li><button tb_CC_database>
   The use of databases is allowed for this game.
   </li>
   <li><button tb_CC_tablebase>
   The use of endgame tablebases (e.g. Nalimov tablebases etc.) is
   allowed for this game.
   </li>
   <li><button tb_CC_engine>
   Chess Engines are allowed for this game. Sometimes these games are
   also refered to as "Advanced Chess".
   </li>
   <li><button tb_CC_outoftime>
   Your opponent ran out of time. You may claim a win on time.
   </li>
   <li><button tb_CC_message>
   Your oppenent sent a message along with his last move. Check the
   game notation.
   </li>
</ul>

<p>
In Xfcc games, each opponents country may be displayed by the
associated flag, if the server provides that information. For eMail
based games this can be achieved by adding additional PGN tags for
<i>whiteCountry</i> and <i>blackCountry</i>, each followed by the
international three letter country code according to ISO 3166-1
(e.g. "EUR" <button flag_eur>, "USA" <button flag_usa>, "GBR" <button
flag_gbr>, "FRA" <button flag_fra>, "RUS" <button flag_rus>, "CHN"
<button flag_chn>...).
</p>

<p>
See also the chapter <a Correspondence>Correspondence Chess</a> for
general information.
</p>
}



set helpTitle(CCXfcc) "Correspondence Chess Servers"
set helpText(CCXfcc) {<h1>Correspondence Chess Servers</h1>

<p>
There exist several correspondence chess servers throughout the
internet. Generally, they are used by means of a web browser, so no
specific software is required. However many of them also offer an
interface to specialised chess software via a protocoll called Xfcc.
The integration of Xfcc is done in Scid via external helper tools set
in the <a CCSetupDialog>Configuration</a> dialog for correspondence
chess.
</p>

<h3>Start a new game</h3>
<p>
Xfcc does not allow to start a new game itself. Searching for an
opponent and starting a game is instead handled by the chess server
on their web site. Once the game is started however, Scid can be used to
retrieve the moves of the opponent, add them to the internal database,
analyse them and so on. All features of Scid are to the users disposal
though certain modes of play may not allow them (e.g.  normal games
usually do not permit the usage of chess engines for analysis).
</p>

<h3>Retrieve games</h3>
<p>
Open a database that holds correspondence chess games. This database
has to be of type "Correspondence chess". 
</p>

Notes: 
<ul>
   <li>If Scid does not find a correspondence chess database it will
   inform you to open one.
   </li>
   <li>If the database does not hold the games that are fetchted from
   the server they are treated as new games and added to the database
   automatically.
   </li>
   <li>Scid will use the first database of type "Correspondence Chess"
   that is currently open. For this reason only one such DB should be
   opened at a time.
   </li>
</ul>
<p>
Xfcc always retrieves all games hosted on a specified server for your
user ID at once. To retrieve the games just press the <button
tb_CC_Retrieve> icon or select <menu>Retrieve Games</menu> from the
<menu>Correspondence Chess</menu> menu. As a server connection is
required to fetch new games be sure that the system has network
access. Scid will call the fetch tool configured in the <a
CCSetupDialog>Configuration</a> dialog which will place the games in
PGN format in Scids inbox. It may take some time to retrieve the
answer, so be patient. After the games are retrieved the
correspondence chess database is updated accordingly.
</p>

<p>
<b>Note</b>By using the <button tb_CC_delete> you can empty your whole
In- and Outbox directories.
</p>

<p>
Once the games are retrieved their counterpart is searched within the
correspondence chess db and new moves are added accordingly. As Xfcc
servers may offer various ways to insert moves (via web or mobile or
other programs...) it might well be that Scid will have to add half of
the game to the db. This poses no problem. Scid will add all moves
returned in the game from the server. Scid will however not replace
the game from the beginning as then all your analysis may be lost.
Hence it is <b>important to note</b> that you must not insert moves to
the main line beyond your own last move! To add continuations please
use variations!
</p>
<p>
Xfcc base games offer extensive status display within the games list.
This information, however, is only available if Scids internal Xfcc
support is used.  The follwoing icon are for visual display:
<ul>
   <li><button tb_CC_draw> A draw was agreed with the last move.
   </li>
   <li><button tb_CC_yourmove> You're on the move.
   </li>
   <li><button tb_CC_oppmove> Your opponent is on the move.
   </li>
   <li><button tb_CC_book> This game allows the use of opening books.
   </li>
   <li><button tb_CC_database> This game allows the use of databases.
   </li>
   <li><button tb_CC_tablebase> This game allows the use of tablebases.
   </li>
   <li><button tb_CC_engine> This game allows the use of chess engines.
   </li>
</ul>
<p>
Additonally Scid will display the clock for both parties <b>at the
time of sync</b> as well as the chess variant played. Note however
that Scid currently only supports standard chess.
</p>
<p>
Note: only if the proper icon (book, database, tablebase, engine)
is dispalyed, the useage of these tools is allowed. It is forbidden
otherwise. Be fair and respect these rules.
</p>
<p>
Note: if other sources have placed games in your inbox (e.g. from
your eMail correspondence chess) they are also synchronised in the
retrieval step into the database as the whole Inbox is worked through.
This allows for adding eMail games to the Inbox, then switch to Scid,
hit <button tb_CC_Retrieve> and all games are up to date.  Games that are not
yet found in the database are treated as new games and appended to the
database.
</p>
<p>
<b>Note</b>By using the <button tb_CC_delete> you can empty your whole
In- and Outbox directories.
</p>
<p>
<b>Note for programmers</b>: the fetch tool is called with the Inbox path as
parameter. It is thought to work through all server accounts and place
properly formatted PGN files in the path passed to it. These files
should contain additional header fields as they are known by the cmail
tool. (See <a CCeMailChess>Correspondence Chess via eMail</a> for
information about the fields required.)
</p>

<p><footer>Updated: Scid 3.6.23, March 2008</footer></p>
}

#############
# eMail Chess:
set helpTitle(CCeMailChess) "Correspondence Chess via eMail"
set helpText(CCeMailChess) {<h1>Correspondence Chess via eMail</h1>

<p>
eMail offers a very convenient way ot play correspondence chess. The
standard application in the Un*x world for this till today is xboard
together with its cmail helper. As it allows for almost automatic
handling of correspondence chess eMails and additonally does not add
anything not conforming to PGN it is also the model for Scid to handle
eMail chess. By just preserving the whole PGN header such games can be
played with any opponent who has a tool to handle PGN.
</p>

<h3>eMail Chess</h3>
<p>
Scid can handle eMail correspondence chess games almost automatically.
The way how this is done is kept compatible to the cmail utility that
comes with xboard on Un*x systems. (Having said this implies that you
can play against an opponent using cmail/xboard.) It works by sending
the games as whole PGN files too and fro as mail attachements, while
the header contains certain tags that allows them to be recognised and
sorted together. For this reason the user has to be careful with
editing of the header fields.  Note that fields with explicit values have
to be set to exactly this value for eMail chess. Starting a game with
Scid will do this automatically, but you <b>must not</b> overwrite
or delete them!
</p>
<p>
Essential header fields are:
</p>
<ul>
   <li><term>Event</term>: by default "Email correspondence game"
   </li>
   <li><term>Site</term>: has to be "NET"
   </li>
   <li><term>Mode</term>: has to be "EM"
   </li>
   <li><term>WhiteNA</term>: contains the eMail address of the white player. Note
   that only the bare address is stored there in the form
   <term>user@host.org</term>.
   </li>
   <li><term>BlackNA</term>: contains the eMail address of the black player
   similar to WhiteNA.
   </li>
   <li><term>CmailGameName</term>: Contains a <b>unique</b> identifier for
   the game. This is used to sort the games together.
   <p>
   While Scid could use some database index this is not possible for
   non-DB-based tools like cmail. For this reason the
   <term>CmailGameName</term> parameter is user suppied. It must be
   unique! The easiest way is something of the form
   <term>xx-yy-yyyymmdd</term> where xx is a shortcut for the white
   player, yy one for the black player, and yyyymmdd the current date.
   </p>
   <p>For Xfcc-based games this field has also to be set to a unique
   identifier but there the server name and the unique game number on
   this server can be used, that is this identifier is of the form
   <term>MyXfccServer-12345</term>.
   </p>
   </li>
</ul>
<p>
eMail based chess does not contain that extended status codes as Xfcc.
These games show the <button tb_CC_envelope> icon to notify them as
eMail based.
</p>

<h3>Start a new game</h3>
<p>
This opens a dialog for the input of the own and the opponents name as
they should appear in the header as well as the eMail addresses of
both parties. Additionally a <b>unique</b> game ID has to be inserted.
The easiest way for this ID is something of the form
<term>xx-yy-yyyymmdd</term> where xx is a shortcut for the white
player, yy one for the black player, and yyyymmdd the current date.
This id is a text and it is important to identify the games uniquely.
Users of cmail will also know this ID as <i>game name</i>. It must
only contain letters and numbers, the minus sign and the underscore.
Please avoid other characters.
</p>
<p>
After the dialog is quit by pressing the <b>[Ok]</b> button a new
game is appended to the currently loaded correspondence chess database
and the PGN header is set properly. Just make your move and send it as
mentioned below.
</p>

<h3>Retrieve games</h3>

<p>
Scid does not handle your mailbox automatically. This would,
considering the wide range of possible mail setups these days, involve
a huge amount of code. For this reason Scid relies on your normal
eMail program which is far more suitable for this purpose than Scid
can ever be. To get a game into Scid just save the attached PGN file
to Scid's inbox and process the inbox by either <menu>Retrieve
Games</menu> or the <button tb_CC_Retrieve> button or
<menu>Process Inbox</menu>. The difference between the two is that
the first one will also fetch and populate the Inbox additionally with
games from another source (say Xfcc) by either the internal Xfcc
support or an external fetch tool called. Hence <button
tb_CC_Retrieve> is the most convenient way if you use both types of
correspondence chess games.
</p>
<p>
<b>Note</b> The <menu>Retrieve Games</menu> menu or the <button
tb_CC_Retrieve> button do <b>not</b> fetch your eMail messages! You
have to save your PGN files to Scids Inbox by hand. Probably this can
be automatised by your eMail program (on Un*x systems setting up a
mime handler is easy enough by means of <term>.mailcap</term>).
</p>
<p>
<b>Note</b>By using the <button tb_CC_delete> you can empty your whole
In- and Outbox directories.
</p>

<h3>Send the response</h3>

<p>
After making your move send it by either the <menu>Mail Move</menu>
item from the menu via <menu>Send move</menu> which is equivalent to
<button tb_CC_Send>. The latter will Scid have to recognise the game
as eMail correspondence and send it by mail while the former method
will force Scid to generate an eMail message.
</p>
<p>
Of course Scid strips the the game bare of any comments and variations
before attaching it to the outgoing eMail as you probably do not want to send
your analysis along.
</p>
<p>
If a GUI-mailer is used, its usual compose window is opened. The
address of your opponent is filled in as well as a generic subject
containing the game id for easy filtering and the bcc address if
specified in the <a CCSetupDialog>Configuraion</a> dialog. The mail
body is set to contain the FEN of the final position and the list of
moves made so far. This way the opponent can quickly look up your
move. Finally, Scid attaches the current game including your move in
PGN format to the mail message.
</p>
<p>
When using a mailx compatible tool no window is opened and the mail is
sent invisibly by invoking the tool specified in the background. In
this case the generated mail contains the PGN also in the mail body.
</p>
<p>
Note that as eMail chess works by sending the whole PGN file you must
not add more than your half move. Scid does not check here wether
more than one half move was added to the mainline, simply as Scid does
not know which move it was, when you sent yours.
</p>
<p><footer>Updated: Scid 3.6.23, March 2008</footer></p>
}

#############
# Correspondence Chess setup dialog help:
set helpTitle(CCSetupDialog) "Correspondence Chess Setup"
set helpText(CCSetupDialog) {<h1>Correspondence Chess Setup</h1>

<p>
The entries in the configuration dialog are preset to some default
parameters but those must not match the reality on your system, so
adoption will surely be necessary. All parameters are stored in the
configuration file automatically once the dialog is closed via the
<b>[Ok]</b> button. The parameters are effective immediately.
</p>

<p><b>Note</b> that Scid will use the defaults until this setup dialog
is called and quit by selecting the <term>OK</term> button. The
default values are never stored in Scids internal config file until
then. Additionally, if Scid can not find a valid config, it will try
to set up the correspondence chess functions automatically. By default
it will store all data in the <term>data</term> subdir of Scids
configuration. Here also a valid DB as well as the necessary
In/Outboxes are created.
</p>

<p>
<b>Default Database</b>:
This defines the default database for
correspondence chess games. It can be accessed easily via
<menu>Open Database</menu> in the <menu>Correspondence Chess</menu>
menu. The advantage of this method is, that this database does not
show up in the <i>recent databases</i> lists and that you can have a
specific file for this. This database <b>has to be</b> of type
"Correspondence chess". Opening a database of this type by any other
means is also ok, so probably you may want to ignore this setting
(e.g. if you call Scid with your correspondence chess database on
startup.)
</p>

<p>
<b>Inbox (path)</b>:
In this directory Scid will look for correspondence chess games stored
in PGN format. These games are used for the synchronisation of the
correspondence chess database. Generally, Scid does not care how the
games come to this directory. It will just work through all PGN files
located there. This offers the possibility to use some external tools
to fetch games to this location. Additionally, in eMail chess one
should just save the PGN files received from the opponent in this
directory.
</p>
<p>
Scid will not read a mailbox of whatever sort, it just handles
all PGN files placed in that directory. Also note, that it will
synchronise games with the current database. However, if a game
from this directory does not yet exist in the database it is
treated as new game and appended to the database.
</p>
<p>
For the synchronisation process to work the PGN files must contain
some additional header information that are in perfect agreement with
the PGN Standard. Please have a look at <a CCeMailChess>Correspondence
Chess via eMail</a> if you want to create your own tool or if you are
migrating data from some other system.
</p>

<p>
<b>Outbox (path)</b>:
The inverse of the <i>Inbox</i>. Scid places here PGN files of the
outgoing games. For eMail chess this is essential as the PGN files have
to be attached to an eMail message.  For Xfcc, where only the move is
sent, this would not be necessary, however the Outbox directory offers
a convenient way to link up to your PDA or for any other usage as the
PGN files contained in the Outbox will also contain your last move.
</p>

<p>
<b>Use internal Xfcc support</b>:
If checked Scid will not use the external tools specified as external
protocol handlers but use its internal Xfcc support to fetch games and
send moves. This will be the most convenient way to access an Xfcc
server and should be used as default.
</p>
<p>
This feature requires http and tDOM support for TCL to be installed.
Usually, these modules are distributed with your TCL installation,
however, on some systems they have to be installed explicitly. If
either one is not found this function is disabled.
</p>
<p>
<b>Xfcc Configuration</b>:
Give the path and filename of the config file for the xfcc protocol
handler. This path is also passed on to the external protocol handlers
to be used by them.
</p>

<p>
<b>Fetch Tool</b>:
This program is called to retrieve correspondence chess
games from a correspondence chess server. This helper just has to
fetch the games from whatever source it likes, generate a proper PGN
file containing the necessary PGN header. Tools for fetching games
from Xfcc-servers exist as external programs and these are the natural
tools to set up here. For future protocols one could easily generate
an external fetch tool that handles this protocol. Also automatisation
is possible if this functionality is done externally.
</p>
<p>
Note: This tool is <b>not</b> called for retrieval of eMail chess
messages!
</p>

<p>
<b>Send Tool</b>: 
This is the inverse of the fetch tool, primarily also ment for Xfcc
support or any future protocol that might come up. The send tool,
however, is called from Scid with several parameters where the call
looks like:
<term>
SendTool Outbox Name GameID MoveCount Move "Comment" resign claimDraw offerDraw acceptDraw
</term>
</p>

<p>
The meaning of the parameters is as follows:
   <ul>
      <li><term>Outbox</term>: The Outbox path set in this dialog. The
      send tool is meant to generate a correctly formatted PGN file
      there.
      </li>
      <li><term>Name</term>: The name of the player to move as stated
      in the PGN header. For Xfcc this would be the login name. It is
      identical to the player name in the PGN header.
      </li>
      <li><term>MoveCount</term>: The move number to send.
      </li>
      <li><term>Move</term>: The actual move in SAN.
      </li>
      <li><term>"Comment"</term>: A comment sent to the opponent. Scid
      inserts the last comment of the game. That is these comments are
      treated as comments to the opponent. Note that the comment is
      quoted, so multiline comments should be possible.
      </li>
      <li><term>resign</term>: 0 or 1, specifying wether the user
      wants to resign. Set to 1 if the user invokes
      <menu>Resign</menu> from the <menu>Correspondence Chess</menu>
      menu.
      </li>
      <li><term>claimDraw</term>: 0 or 1, specifying wether the user
      wants to claim a draw. Set to 1 if the user invokes
      <menu>Claim Draw</menu> from the <menu>Correspondence Chess</menu>
      menu.
      </li>
      <li><term>offerDraw</term>: 0 or 1, specifying wether the user
      wants to offer a draw. Set to 1 if the user invokes <menu>Offer
      Draw</menu> from the <menu>Correspondence Chess</menu> menu.
      </li>
      <li><term>acceptDraw</term>: 0 or 1, specifying wether the user
      wants to accept a draw offered by the opponent. Set to 1 if the
      user invokes <menu>Accept Draw</menu> from the
      <menu>Correspondence Chess</menu>
      menu.
      </li>
   </ul>
</p>
<p>
Note: This tool is <b>not</b> called for eMail chess!
</p>

<p>
<b>Mail program</b>:
This gives the path to your prefered eMail program. This program is
called for eMail chess to compose the message to the opponent.
</p>

<p>
<b>(B)CC Address</b>:
A copy of the outgoing message is sent to this address as blind copy.
Note however, that if a GUI mailer is used it has normally its own
outgoing mail handling. Hence, setting this address might duplicate
messages. It can be used to transfer a game to another address though.
</p>

<p>
<b>Mode</b>:
Unfortunately there exists a wide range of mail clients and they use
very different calling conventions. Some common conventions, and
examples of programs that use them, are listed here. The mailprogram
will be called with the convention selected. In case it is not known
which convention is used one of those offered might match and do the
trick. Note however that quite a number of mail programs are not
capable of sending attachements when called from another program. In
this case you will have to either change your mail client or add the
attachement placed in Scids Outbox by hand.
</p>
<p>Hint: mailx or one of its many clones should be available as a
command line application on almost any platform as an easy to set up
tool. In case none of the conventions work with your preferred
client or this client can not handle mails with attachements by calls
from the command line, installing mailx would be an option.
</p>
<p>Hint: mutt uses the systems mail transport (aka
sendmail/exim/postfix). To hook up with those (arguably) not easy to
set up tools mutt is a perfect option. On a decent Un*x with a proper
setup it should be the most painless way to handle eMail chess.
(Though not many properly set up systems exist, especially in the
Linux world.)
</p>
<p>
<b>Attachement parameter</b>: 
This parameter is used to specify an attachement. It is <b>only</b>
used in <term>mailx</term> mode.
</p>
<p>
<b>Subject parameter</b>:
This parameter is used to specify the subject of the mail message. It
is <b>only</b> used in <term>mailx</term> mode.
</p>
<p><footer>Updated: Scid 3.6.24, March 2008</footer></p>
}

#############
# Correspondence Chess setup dialog help:
set helpTitle(CCXfccSetupDialog) "Xfcc Server Setup"
set helpText(CCXfccSetupDialog) {<h1>Xfcc Server Setup</h1>
<p>
The Xfcc Server Setup dialog reads in the currently specified xfcc
configuration and displays all servers specified in the config file.
The dialog is separated in two parts: the upper half lists all server
names defined, while the lower part lists all currently set
configuration values for these files.
</p>
<h2>Necessary entries</h2>
<ul>
<li><term>Server name</term>: This specifies the name used for this specific
server and to generate unique game IDs. The name should consist of a
single word containing only characters (a-z and A-Z), numbers and the
characters "-" and "_". It is treated case sensitive.
</li>
<li><term>Login name</term>: specifies the name used to log into a
specific server. It is a wise custom to use only characters, numbers
and "-" as well as "_" in this name.
</li>
<li><term>Password</term>: defines the password used for login. The
same rules apply as for the Login name. <b>Note</b> Scid currently
stores your passwords on the hardisc in unencrypted form. For this
reason keep the directory safe.
</li>
<li><term>URL</term>: This is the base URL for the Xfcc interface of the
correspondence chess server. It can be found at the servers homepage.
Some examples for common servers are:
<ul>
	<li>SchemingMind: <url
	http://www.schemingmind.com/xfcc/xfccbasic.asmx>
	http://www.schemingmind.com/xfcc/xfccbasic.asmx</url>
	</li>
	<li>ICCF: 
	<url http://www.iccf-webchess.com/XfccBasic.asmx>
	http://www.iccf-webchess.com/XfccBasic.asmx</url>
	</li>
	<li>MeinSchach.de / MyChess.de:
	<url http://www.myChess.de/xfcc/xfccbasic.php4>
	http://www.myChess.de/xfcc/xfccbasic.php4</url>
	</li>
</ul>
</li>
</ul>
<p>
To switch between the individual server settings just select the
server to change from the upper listbox. Its current values will then
be displayed in the entry fields and can be adopted. Clicking on
another server in the list will activate the new settings.
</p>
<p>
To add a new server, just hit the <term>Add</term> button. A new entry
will be created that is prefilled with some text to replace. Please
keep in mind that the server name has to be unique in your setup.
</p>
<p>
To delete a server select it from the list and press the
<term>Delete</term> button. All values for this specific server will
be prepended by a hash mark (#) marking this entry as deleted.
Therefore, if a server was deleted by accident, just remove the hash
marks in front of the entries.
</p>
<p>
Hitting <term>OK</term> will Scid have to store your current setup. At
this point all servers marked as deleted are deleted, all new servers
are added to the setup. By pressing <term>Cancel</term> all changes
are lost, the old setup stays in place.
</p>

<p><footer>Updated: Scid 3.6.24, May 2008</footer></p>
}

# Serious game window help
set helpTitle(SeriousGame) "Serious Game"
set helpText(SeriousGame) {<h1>Serious Game</h1>
  <p>
  Serious games can be played against any <term>UCI</term> engine set
  up for the usage with Scid. A list of all possible opponents is
  given on top of the <term>Game configuration</term> window. The
  button <term>Configure UCI engine</term> additionally gives access
  to the engines parameters. By default, they are set such as in the
  <a Analysis List>engine configuration</a>.
  </p>
  <p>
  Next, the book that should be used can be chosen from those opening
  books available to Scid. Unchecking the <term>Use book</term> box
  will disable the use of an opening book and the engine will start
  calculating moves right from the beginning.
  </p>
  <p>
  The section <term>Time mode</term> allows to set the timing used for
  the engine. Various settings are possible here:
  <ul>
     <li><term>Time + bonus</term> specifies the time for the whole
     game and a possible increment per move (Fisher clock). The
     default is set to 5 minutes per game and 10 seconds increment per
     move which is a usual setting for Blitz games. Note, that the
     times for Black and White can be set independently. This allows
     to set a short amount of time for the engine and give a longer
     time of thinking to the player, and thus strengthening the
     players analysing possibilities while weakening the engines
     abilities in case of <term>Permanent thinking</term> is off (see
     below).
     </li>

     <li><term>Fixed depth</term> does not set the time per game but
     the depth the engine will calculate in half moves. As this
     disables the ability to calculate deeper if necessary, the
     computer will not see certain mates and combinations, the engine
     may play weaker and thus offer a better partner for training
     purposes.
     <p>
     <b>Note</b>: some, especially commercial, engines also offer to
     weaken their strength in ELO units. Most likely this will offer a
     more suitable algorithm than limiting the search depth. In Scid,
     such games are also offered as <a TacticalGame>Tactical games</a>
     against the free Phalanx engine.
     </p>
     </li>

     <li><term>Nodes</term> is similar to limiting the search depth,
     but here the engine has to move after the evaluation of a certain
     number of positions. (The default is 10,000.)
     </li>

     <li><term>Seconds per move</term> allows the engine to spend a
     certain amount of time at maximum for a given position. Some
     engines will move faster in certain circumstances, but they will
     not exceed the time limit set here. As <term>Fixed depth</term>
     and <term>Nodes</term> this also limits the engines playing
     strength, but also gives a pretty responsive game play.
     </li>
  </ul>
  </p>
  <p>
  Serious games can start from the current board position if the box
  <term>Start from current position</term> is checked. This allows
  e.g. to play out defined middle game positions that arise from an
  opening.
  </p>
  <p>
  <term>Permanent thinking</term> (sometimes also called ponder)
  allows the engine to calculate on the players time. If unchecked, the
  engine will stop analysing the position if the player has the move.
  If the game is set for a fixed time per move, this will weaken the
  engine. On the other hand, the engine might move immediately, if the
  player made the move it was analysing on the players time.
  </p>
  <p>
  <term>Coach is watching</term> will open a dialogue offering to take
  back a move if the player made a blunder (due to the engines
  evaluation of his last move).
  </p>
  <p>
  For training of openings <term>Specific opening</term> can be
  checked. In the list below one can choose the opening to play. The
  player then should follow the line chosen, otherwise Scid will ask
  if the move should be taken back.
  </p>

  <p>
  After setting all parameters of the game and hitting the Play
  button, Scid will set up the opponent engine show the clocks and
  start the game. The player must not make a move till the clocks
  appear. Note that it might take some time for the chess engine to
  start up and initialise properly.
  </p>

  <p><footer>Updated: Scid 3.6.26, October 2008</footer></p>
}

# Tactics Trainer
# Renamed to Puzzles S.A
set helpTitle(TacticsTrainer) "Mate in ... Puzzles"
set helpText(TacticsTrainer) {<h1>Mate in ... Puzzles</h1>
  <p>
  Scid's
<run ::tactics::config><green>Mate in ...</green></run> widget
  is a handy way to improve your chess skills. And waste some time!
  The feature is fairly straight forward, though not especially polished.
</p>
  <h3>Configuration</h3>
  <p>
  The <term>Engine analysis time</term> slider limits Toga's
  time to solve the puzzle (which are generated on-the-fly).
  Five seconds should generally
  be enough as most puzzles contain forced continuations.
  It does not describe how long one has to solve any puzzle.
  </p>
<p>
  Scid stores data about solved puzzles within the database.
  Clicking the <term>Reset scores</term> button will reset this
  information marking all puzzles as unsolved. And unless care is taken, 
<b>reinstalling Scid will overwrite puzzles solved</b>!
  </p>

  <h3>Playing</h3>
  <p>
  If you get stuck, select <term>Show Solution</term> to add the solution as
  <run ::pgn::OpenClose><green>PGN</green></run>
  (where it can be easily examined). Unclicking the button will reset the puzzle for another try.
  </p>
  <p>
  Clicking the <term>Next</term> button allows the user to skip any
  puzzle, and individual exercises can be opened via the
<run ::windows::gamelist::Open><green>Game List</green></run> widget.
  </p>
  <p>
  Some exercises do not end in a mate, with the
  solution only giving a clear advantage. If one wants to play out these
  scenarios and only count the exercise solved in case of a win, just
  check the <term>Win won game</term> option. This option has no
  meaning in case of a clear mate solution.
  </p>
  <p>
  The clock is only for the user to check how long he thought about the
  position at hand. No evaluation is done on the time required to solve a problem.
  </p>

  <h3>Other notes</h3>
  <p>
  This feature is implemented using special databases containing the puzzles
  , installed in Scid's default <term>Bases</term> directory.
  If for any reason this directory option has been changed , it can be specified in
  <run setTacticsBasesDir><green>Options--<gt>Bases Directory</green></run>.
  </p>
  <p>
  Unlike other bases, puzzle bases do not contain full games; only starting positions.
  Any puzzle book can be converted to a trainings base by setting up the
  positions and storing the new database into
  the <term>Bases</term> directory. (It is also recommended to set the new base type
  to <term>Tactics</term>, by means of the <a Maintenance>Maintenance</a> window).
  </p>
  <p>
  To avoid cheating, it is advisable to close the PGN window and check
  <term>Hide Next Move</term> in Scid's right-click menu.
  <p>
  <p><footer>Updated: Scid vs. PC 4.1, July 2010</footer></p>
}

# Find best move 
set helpTitle(FindBestMove) "Training: Find best move"
set helpText(FindBestMove) {<h1>Training: Find Best Move</h1>
  <p>
  When annotating games with a chess engine, the engine can search for
  tactical opportunities within a game. This can be achieve by setting
  <term>Mark Tactical Exercise</term> in the <a
  Analysis>Annotation</a> window accessible from analysis. In case a
  tactical opportunity is found, Scid will then flag the game with the
  <term>T</term> flag (Tactics) and add a special comment that is
  evaluated in this exercise.
  </p>
  <p>
  To use this training method, a properly prepared database is
  required. This can be achieved by batch annotating a set of games or
  one can just download them from the <url
  http://scid.sourceforge.net/>Scid website</url>.
  After opening a properly prepared database, just select Play /
  Training / Find best move. Scid will then jump to the next location
  of a tactical blow from the current game position. If necessary a
  suitable new game will be loaded and Scid will display the critical
  position. The user is now required to find the best continuation.
  To jump to the next tactical position one can just right click on
  the goto end of game button.
  </p>
  <p>
  For this exercise it is advisable to close the PGN window and set
  <term>Hide next move</term> from the status areas context menu.
  </p>
  <p><footer>Updated: Scid 3.6.26, October 2008</footer></p>
}

# FICS Login
set helpTitle(FICSlogin) "Fics Login"
set helpText(FICSlogin) {<h1>Fics Login</h1>

<p><i>Fics supports anonymous login, but you'll find more people to play if you visit
<url http://www.freechess.org>www.freechess.org</url> first and create an account.
If you're having problems logging in, try deselecting "timeseal".</i></p>
  <ul>
      <li><term>Username</term> This is your login name on the Fics
      server. To login anonymously, use the "Login as guest" button </li>
      <li><term>Password:</term> Note: this password is not displayed when you type,
      but it is <b>stored in plain text</b> within Scids configuration. If you are
      using a publicly accessible system please make sure to assign
      proper rights to Scids config directory.
      </li>
      <li><term>Time seal</term> If checked, all connections to the
      Fics server are routed through the (optional) timeseal
program. Its purpose is to cope with network lags and keep the clocks in
correct order, which can otherwise create problems on slow network
connections.

Timeseal is available from the
<url http://sourceforge.net/projects/scidvspc>Scid vs. PC project page</url>.
  </li>

      <li><term>Server port</term> specifies the port on the server.
      The default is 5000 and should be ok for almost all needs.</li>
      <li><term>Timeseal port</term> specifies the port where the
      <term>timeseal</term> program is listening. The default is 5001
      and should be ok for almost all needs.</li>
   </ul>

  <p><footer>Updated: Scid vs. PC 3.4.1, September 2010</footer></p>
}

# FICS Find Opponent
set helpTitle(FICSfindopp) "Finding an Opponent"
set helpText(FICSfindopp) {<h1>Finding an Opponent</h1>
  <p>
  There are several ways to start playing. The two easiest are the
<b>Find Opponent</b>
  and
<b>Offers Graph</b>
widgets.
  </p>

  <h3>Find Opponent</h3>

  <p>
  Click on the <b>Find Opponent</b> button, and you'll see a dialogue from
  which you can challenge other players for a game.
  Select how long you'd like to play for, and other options, then 
  press the <term>Make Offer</term> button.

Options:
  <br>
  <ul>

      <li><term>Time</term> Base time for game in minutes.</li>
      <li><term>Increment</term> Seconds added to your time with each move.</li>
      <li><term>Rated game</term> The result of rated games affect your rating.
      Unrated games make no adjustment.</li>
      <li><term>Confirm manually</term> Allows you to confirm or deny a challenge.</li>
      <li><term>Color</term> Select whether to play White or Black or Auto.</li>
      <li><term>Limit rating between</term> Only play those with a given rating interval.</li>
      <li><term>Filter with formula</term> On Fics every player can
      set a formula that describes what challenges will be denied
      automatically. This formula can be enabled by checking this box.
      </li>
   </ul>
  </p>

  <h3>Offers Graph</h3>

    <p>The <term>Offers graph</term> shows all current game offers. Hovering
your mouse over a node will show it's details, and clicking a node will
(attempt to) start a new game. Sometimes you'll have to be quick though, as
Fics can be quite busy.</p>

<p> On the graph itself, The y-axis shows the ELO rating of the opponent -
higher number means stronger player , while x-axis of the graph plots the time
allowed for the game. The first grey line marks standard <term>Blitz</term>
timing (5 min., no increment) while the second red line marks the standard
<term>Rapid</term> timing (15 min., no increment).
<p>
Additionally, the offers use the following coding:
    <ul>
       <li><green>Green</green>: offers from human opponents</li>
       <li><blue>Blue</blue>: offers from computer opponents</li>
       <li><red>Red</red>: games with a total time of more than 1 hour</li>
       <li><gray>Gray</gray>: anonymous offers, i.e. offers from guest logins</li>
       <li>Boxes: unrated games</li>
       <li>Circles: rated games</li>
    </ul>
  </p>

<p>
<i>
Note Fics also offers a bunch of chess variants like bughouse or crazyhouse but
Scid does not support any of these variations.
</i></p>

  <p><footer>Updated: Scid vs. PC 3.4.1, September 2010</footer></p>
}

set helpTitle(FICSwidget) "Fics: Play on the Internet"
set helpText(FICSwidget) {<h1>Using Fics</h1>
  <p>
Once you have <a FICSlogin>logged in</a>, the main Fics widget shows a
console window, some command buttons, and clocks.</p>

  <h3>Fics Console</h3>

  <p>
  This is the main interface with the Fics server.

<p> Interaction is via commands entered in the entry box, or by 
the Command Buttons. For an outline of popular commands see the
<a FICScommands><term>Commands</term></a> section.</p>

<p>
Normal messages are written in green; messages from other
players appear in red.  It can be a little confusing, but
toggling the <b>Tells</b> and <b>Shouts</b> boxes will make
it quieter.
</p>

  <h3>Buttons</h3>
  <p>
  On the right hand side of the clocks appear the command buttons. They are
fairly self explanatory, the most notable being the <a FICSfindopp><term>Find
Opponent</term> and <term>Offers Graph</term></a> buttons. Other buttons include:
  <br>
  <ul>
    <li><term>Tells</term> Show messages from channel tells</li>
    <li><term>Shouts</term> Show messages from shouts and cshouts</li>
    <li><term>Clear</term> Clear console of previous messages</li>
    <li><term>Rematch</term> Request a rematch with previous opponent</li>
  </ul>

<br>
  <p><footer>Updated: Scid vs. PC 3.4.1, September 2010</footer></p>
}

set helpTitle(FICScommands) {Fics Commands and Variables}
set helpText(FICScommands) {<h1>Fics Commands and Variables</h1>

<p>
Fics' command line interface is fairly confusing,
but below you'll find an outline of popular commands and
variables.
</p>

<p><i>
As well as on-line, help can also be got from the command line.
Use <term>help COMMAND</term>, or <term>help v_VARIABLE</term>
for info about specific commands and variables.
</i></p>

<h3>Commands</h3>
<ul>
    <li><term>match</term> PLAYER - Issue game request to a specific person</li>
    <li><term>finger</term> PLAYER - Get info about a specific person</li>
    <li><term>play</term> GAMENUMBER - Respond to a game request from another player</li>
    <li><term>resume</term>   Issue challenges to users with whom you have a stored or interupted game</li>
    <li><term>tell</term> CHANNEL MESSAGE - Send a message to chat channel</li>
    <li><term>tell</term> PLAYER  MESSAGE - Send a message to a specific person</li>
    <li><term>say</term> MESSAGE - Send a message to opponent</li>
    <li><term>shout</term> MESSAGE - Shout message</li>
    <li><term>flag</term>   Call time if your opponent has run out of time, and autoflag is disabled</li>
    <li><term>=channel</term>   Show channels player is listening to</li>
    <li><term>+channel</term> NUMBER - Listen to channel NUMBER</li>
    <li><term>-channel</term> NUMBER - Stop listening to channel</li>
    <li><term>news</term>   Show Fics news</li>
</ul>

<h3>Variables</h3>
<p><i>To change settings use <term>set</term> VARIABLE VALUE. Often VALUE is a boolean 1 or 0.</i></p>

<ul>
<li><term>seek</term>	Show game requests</li>
<li><term>silence</term>	Turn off shouts, cshouts and channel tells while you play, examine or observe a game</li>
<li><term>gin</term>	Notify when games begin or end</li>
<li><term>autoflag</term>	Automatically flag opponent as losing when his time runs out</li>

<li><term>1</term>	Footnote 1 to player's personal information</li>
<li><term>2</term>	Footnote 2 to player's personal information ....</li>
</ul>

<h3>Channels</h3>
<p>Popular channels are:</p>
<ul>
<li><term>1</term>	Server Help and Assistance</li>
<li><term>2</term>	General discussions about FICS</li>
<li><term>4</term>	Guests</li>
<li><term>49</term>	Mamer tournament channel</li>
<li><term>50</term>	The Chat channel</li>
</ul>
</p>

<h3>Aliases</h3>
<ul>
<li><term>f</term>	finger</li>
<li><term>n</term>	next</li>
<li><term>t</term>	tell</li>
</ul>


<h3>More Information</h3>

<p>
Visit Freechess.org for info about
<url http://www.freechess.org/Help/HelpFiles/variables.html/>Variables</url>
or 
<url http://www.freechess.org/Help/HelpFiles/commands.html/>Commands</url>
<br>
  <p><footer>Updated: Scid vs. PC 3.4.1, September 2010</footer></p>
}

set helpTitle(FICStraining) {Fics: Other Features}
set helpText(FICStraining) {<h1>Other Fics Features</h1>

  <h3><name Observe>Observing Games</h3>

  <p>
  From time to time FICS <term>relays</term> major events in
  international chess. In these cases one can observe the games life
  on the server and discuss them with other users on FICS. To find out
  what games are currently relayed (if any) one can ask the relay for
  a list by <term>relay listgames</term>. As FICS expects the terminal
  to have 80 chars width it might be necessary to resize Scids FICS
  window to get a nice table. The entries in the table are, first the
  game number, colon, than the opponents, the result of the game (*
  signifying an ongoing game as usual) and the <a ECO>ECO code</a> of
  the opening. To observe a specific game one can just <term>observe
  gamenumber</term>. Scid will then display the current board
  position, the clocks will display the proper values sent by the
  relay and it will fetch all moves of the game so far plus the usual
  PGN header fields. If a player moves this move is performed in Scid
  as usual. For discussing the game with other observers,
  <term>whisper</term> and <term>kibitz</term> can be used. Please
  refer to the online help of these commands. All these conversations
  can be read in the console.
  </p>
  <p>
  Note that only one game can be observed within Scid.
  </p>

  <h3>Lectures</h3>

  <p>
  FICS offers several options for chess training. One of the more
  prominent once are the lecture bots <term>LectureBot</term> and
  <term>WesBot</term>. They run all the time on FICS and offer various
  training sessions that can be visited using Scid. The start of each
  session is announced on <term>Channel 67</term> of FICS. Therefore,
  to see these announcements one should first add this channel to the
  personal observation list. This can be done by <term>+channel
  67</term> (it can be removed again by <term>-channel 67</term>).
  Once e.g. LectureBot announces a training session, one can take part
  by issuing <term>observe lecturebot</term>. Please refer to the
  online documentation of FICS for additional features of the Bots and
  also other bots available.
  </p>

  <p><footer>Updated: Scid vs. PC 3.6.26.9, April 2010</footer></p>
}

# Book tuning
set helpTitle(BookTuning) "Book tuning"
set helpText(BookTuning) {<h1>Book Tuning</h1>
   <p>
   For each book move a percentage is given stating the probability
   that Scid will use this move. Using <term>Book tuning</term> one
   can adjust these values. First, the position where the lines should
   be adopted has to be set up. After calling Tools / Book tuning one
   gets a small window stating the moves in book and their percentage
   in a spin box. Note, that only integer values are shown, therefore
   a 0 may appear signifying that this move has a probability of "less
   than 1%". (Most likely this happens in automatically generated
   books from game collections.) All numbers add up to 100% of course.
   </p>
   <p>
   To navigate through the branches of the book one can just click on
   the line in the book tuning window or move around the game as usual
   in Scid.
   </p>
   <p>
   To adjust the probability, e.g. rise the probability of a certain
   variation, one can just increase its value. Though the other values
   stay the same, Scid will recalculate once <term>Save</term> is
   pressed.
   </p>
   <p>
   Choosing <term>Export</term> will export a branch of the book from
   the current position onwards into a single game. The continuation
   with the highest probability will make up the main line while all
   others are stored in variations. This allows for semi manually
   selecting lines to be included in a new book to be created. Note,
   that Scid can handle 3000 moves in a single game, therefore it will
   most likely not be possible (nor will it be very sensible) to
   export a whole opening book into one game. Also note that export
   can be done incrementally. That is, new lines are added to already
   existing ones. This also allows to merge several books.
   </p>
  <p><footer>Updated: Scid 3.6.26, October 2008</footer></p>
}

# Novag Citrine
set helpTitle(Novag) "Connecting the Novag Citrine Chess board"
set helpText(Novag) {<h1>Connecting the Novag Citrine Chess Board</h1>
   <p>
   The Novag Citrine is a wooden chess board that can be interfaced
   from a PC by means of a serial connection. It can be used with Scid
   to enter games, play against a computer opponent or on FICS
   offering a "natural" chess interface.
   </p>
   <p>
   Before the board can be used, one has to configure the port to use
   (Tools / Novag Citrine / Configure). On Linux systems these ports
   are called /dev/ttyS0, /dev/ttyS1 and so on for serial ports,
   /dev/ttyUSB0, /dev/ttyUSB1 and so on for USB connections. On
   Windows the names COM1:, COM2: and so on are common. 
   </p>
   <p>
   Once the proper port is set, choose Tools / Novag Citrine / Connect
   to hook up the board.
   ###--- Detailed description needed ---###
   </p>
  <p><footer>Updated: Scid 3.6.26, October 2008</footer></p>
}

set helpTitle(Changelog) "Scid vs PC Changelog"
set helpText(Changelog) {<h1>Scid vs. PC</h1>

<h4>4.1 (October 10, 2010)</h4>
<ul>
<li> Quite a few FICs tweaks, including new help pages and D.O.S. attack fixes</li>
<li> Numerous Gamelist improvements (see below)</li>
<li> Tree widget improvements: next move is highlighted, main filter is now independant of Tree filter, wheel mouse bindings.</li>
<li> Tactics feature fixed up: Renamed "Puzzle" , and Problem Solutions can now be browsed in-game</li>
<li> Analysis window "add variation" now *appends* variations if at var end</li>
<li> Comment Editor has undo and redo bindings</li>
<li> Main board grid colour can be changed</li>
<li> Setup board can rotate and flip the board</li>
<li> Clicking on moves in the gameinfo area shows Comment Editor</li>
<li> Better window raising/focusing</li>
<li> Kill analysis window after batch annotations</li>
<li> New marble tile theme and colour themes</li>
<li> Some menu re-ordering</li>
<li> Recent Files menu is basename only</li>
<li> Remove Control+V game paste binding .... too dangerous</li>
<li> Further refinements of Switcher widget and Icons</li>
<li> ttk comboboxes are no longer grey</li>
<li> Analysis widget scrolling will pause to allow backwards review</li>
<li> Splash widget changes, and remove pop-up for missing Bases and Book directories</li>
<li> Rewritten Help items</li>
<li></li>

<li> Gamelist improvements -</li>
<ul>
<li>Field order rearranged</li>
<li>Columns now sort in both directions, with arrow depicting direction</li>
<li>Deleting items works better</li>
<li>Can be sorted by ELO</li>
<li>Draws sorted alongside no-result</li>
<li>Delete and Compact buttons disable better</li>
</ul>

<li> Bugfixes -</li>
<ul>
<li> Twinchecker PGN text diff-ing was sometimes broken</li>
<li> Phalanx observes tournament feature time control</li>
<li> Fix "Show Suggested Move" feature</li>
<li> Fix occasionaly issue with erroneously selecting squares, then being unable to reselect them</li>
<li> Ignore crafty's resignations which caused X-window flash events</li>
<li> No context menu if dragging a piece</li>
<li> RobboLito (and others ?) had uppercase piece promotion which occasionally broke</li>
<li> "Show Suggested Move" was broken</li>
<li> Gamelist sometimes left off the last or first item</li>
</ul>

<li> Widget tidies -</li>
<ul>
<li> Analysis engine config widget</li>
<li> Maintenance tweaks</li>
<li> Game save widget made better</li>
<li> Parent Date widget</li>
<li> Delete twins</li>
<li> Database Switcher changes, including new icons</li>
<li> Finder now has three columns (and other changes)</li>
<li> Player finder + Tournament Finder sub-widgets alligned</li>
<li> Statistics window restructured</li>
</ul>
</ul>

<h4>4.0 (July 1, 2010)</h4>
<ul>
<li>Computer Chess tournament feature</li>
<li>The Gamelist widget has been rewritten to work with huge databases. Other new features include a case insensitive search, deleted items are greyed out, and there's a "Compact" button to empty trash with</li>
<li>Add a background colour option that applies to many text widgets, including gameinfo, pgn window and help window</li>
<li>Restructured the analysis widgets, putting toolbar on top, tiny board at bottom, tweaking toolbar icons and reparenting analysis died error dialog</li>
<li>Update the book and book-tuning windows (untested, from SCID)</li>
<li>Add a new logo, and some wm title tweaks</li>
<li>Board Screenshot feature (Control+F12)</li>
<li>Bind mouse wheel to move progression (and widget resize) for the little browser windows</li>
<li>Change all comboboxes to ttk::combobox</li>
<li>Allow xboard lowercase promotion moves (eg while g7g8Q always worked, g7g8q previously failed)</li>
<li>Enable hovering over toolbar help pop-ups</li>
<li>Fix up analysis widget "lock to position" feature</li>
<li>All analysis windows can now use annotation, and autoplay feature</li>
<li>Bind F4 to start another analysis window</li>
<li>Various C fixes from SCID</li>
<li>Sync the tools::connect-hardware feature with SCID (untested)</li>
<li>When using the setup board widget, do a sanity check about the FEN's castling field</li>
<li>Some minor version fixes anticipating tcl8.6</li>
<li>Small bugfix: variation pop-up could previously throw errors if moving through movs fast</li>
<li>F1 *toggles* help window</li>
<li>[Remove space-only lines from project - they mess up vim's paragraph traversal feature]</li>
<li>Fics "withdraws offer" fix</li>
<li>Toolbar icons tweak</li>
<li>Allow databses to have "." in their name</li>
<li>Tactical Game stores game result</li>
<li>Set Game Info widget includes Site field</li>
<li>Small "update idletasks" in main.tcl improves main board responsiveness</li>
<li>Fix up the history limit of combobox-es (especially the setup board FEN combo)</li>
<li>UCI kludges for Prodeo and Rybka from SCID (untested)</li>
<li>Turn off craftys egtb (end game tablebook) for the analysis widget</li>
<li>Comment editor bugfix - unbind left/right from main board</li>
<li>Fix for matsig.cpp overflow (unapplied? , untested)</li>
<li>Key binding for first/last game is now Control+Home/End instead of Control+Shift+Up/Down</li>
<li>Perform a db refresh after importing PGN file(s)</li>
</ul>
<h4>3.6.26.9 (April 19, 2010)</h4>
<ul>
<li> Added a random pawns feature to tacgame </li>
<li> Added magnetic chess pieces </li>
<li> _Some_ tcl speed optimisations to the main board and material board (and htext.tcl) </li>
<li> Move the crosstable menu item from "tools" to "windows" </li>
<li> Centralise procedures called when switching between DBs </li>
<li> Crosstable: make options persistant, tweak menus, fix html export blank fields </li>
<li> Crosstable: allow spelling.ssp to match initalized christian names, include a Font button, fix parenting </li>
<li> Change the toplevel "wm title" to show "White v. Black [database]" </li>
<li> Fics: Make a new Received Offers dialog which allows for proper handling of multiple challenges </li> </li>
<li> Fics: Tweak the Make Offer dialog </li>
<li> Fics: update help files, and add a Font button </li>
<li> Fics: some fixes from SCID </li>
<li> Move the side-to-move  indicator to left of main board </li>
<li> Make font dialogs resizable, add a "default" feature, a new "fixed" default, and small overhaul (hard work!) </li>
<li> (Add a "Font" button to the help and crosstable widgets) </li>
<li> Fix focus issues with the Set Game Info widget </li>
<li> Reorganise Scid start-up (includes reading font info _before_ drawing splash widget, removing unused old logo and start-up checks) </li>
<li> Remove quite a few "" statements from all over (to allow for custom coloured backgrounds in future) </li>
<li> Fix up padding issues with the analysis widget's small text widget </li>
<li> Player Info got a fair bit of tweaking - nicer info display (spellchk.cpp, tkscid.cpp) with full country names, and tcl widget tweaked too </li>
<li> Upgrade to toga 131 </li>
<li> Remove pocket and help directories </li>
<li> Changed a heap of menus (for example) PGN::File is now PGN::PGN, to avoid confusion with the Scid::File menu </li>
<li> Player Report configuration widget reniced. </li>
<li> Menu name and key-bindings changes for PGN and FEN import </li>
<li> Swapped key bindings for "Goto Move Number" (now ctrl+g) and "Goto Game Number" (now ctrl+u) </li>
<li> Include the highlight previous move feature from SCID (and add a context menu) </li>
<li> (Promise to) fix the Gamelist widget, and implement a Comp vs Comp tournament feature for next release</li>
</ul>

<h4>3.6.26.8 (December 19, 2009)</h4>
<ul>
<li> The Fics widgets have been redone, including buttons, the graph and labels, config windows, and console tweaks</li>
<li> Made a few friendly help menus, as well as adding a "Forward" button to the help interface</li>
<li> Fixed up the "Show Material" widget. It can now be flipped and resized, and draws pieces either side of halfway according to colour </li>
<li> The main board area has a modest new right click menu for configuring a few Game Info items</li>
<li> Configure Informant Values widget reniced</li>
<li> Tacgame now has a "Stalemate" dialog</li>
<li> Fics now show a warning when game board is out of sync</li>
<li> A few fixes from Scid; not duplicating variations unnecessarily; Fics socket fixes; Uci responsiveness at game end </li>
<li> The analysis engines now support RobboLito, and an unlimited number of engines</li>
<li> The File::Open menus have had quite a bit of debugging </li>
<li> Some new tile themes </li>
<li> The pause mechanism for tacgame has be restructured to allow for use with Fics too</li>
<li> Some optimisations to the oft used tcl in htext.tcl</li>
<li> The piece and size menus in the Options widget have been replaced by text buttons (and the merida2 pieces removed)</li>
<li> Bugfixes:</li>
<li> A hack to fix wayward comments (Scid)</li>
<li> Don't let fischer chess (try to) castle </li>
<li> Don't raise all windows with double click... (Very bad for Fics blitz) </li>
<li> Minor PGN window/comment strip fix </li>
<li> Some widget reparenting </li>
</ul>

<h4>3.6.26.7 (October 25, 2009)</h4>
<ul>
<li> Include a mac configuration patch </li>
<li> Back out broken Fics autoflag code </li>
<li> Fix sometime-issue with material widget outline </li>
<li> Small change to Tacgame about getMyPlayerName </li>
</ul>
<h4>3.6.26.6 (August 16, 2009)</h4>
<ul>
<li> The Setup Board widget now shows tiles (when the main board uses
tiles) and has improved functionality.  It also properly inits the
     move number, enpassant + castling widgets, and side to move radiobuttons.  </li>
<li> Fixed phalanx's illegal castling, and sorted out issues with it's
     opening book and the analysis window </li>
<li> Replaced the hardly used side-to-move and coords buttons with
     toggle-menu, toggle-gameinfo buttons (Removing the redundant
     gameinfo right-click menu) </li>
<li> Fixed up the toolbar cofniguration widget, and re-did a few little images </li>
<li> Variation pop-ups now center over the main window, and enable
     KeyPress-1, KeyPress-2, etc bindings </li>
<li> Added a changelog (help) widget </li>
<li> Allow up to five analysis engines to run simultaneously </li>
<li> Fix the MyPlayerNames widget. (No autoscrollframe, no grab
     (interfered with Help)) </li>
<li> Add MyPlayerName info to Tacgame </li>
<li> Tacgame show a modest checkmate widget when game is over (for the
     first time) </li>
<li> A few menu/hint fixes in menu.tcl, and a new tile theme </li>
<li> Help window maintenance, including proper positioning, and removing
     the awful yellow highlighting </li>
<li> Speed optimisations for updating main board </li>
<li> Bug fix for  sometime  issue with gamelist widget initialisation
     (thanks Alex) </li>
<li> De-stupidify Save Game dialog (::game::ConfirmDiscard2) </li>
<li> Fix up Paste Clipboard widget a little </li>
<li> Reorder the Options::Chessboard menus a little, giving
     MyPlayerNames its own entry </li>
<li> Several configuration windows appear centered over main window </li>
<li> Add Control-m binding for toggling the menubar
</ul>

<h4>3.6.26.5 (July 17, 2009)</h4>
<ul>
<li> Revamped the main button bar, making it a little larger too.  </li>
<li> Fixed installation issues with tacgame/toga/phalanx on unix systems </li>
<li> Restructured workings of the Analysis widget, - the F2 and F3 key
     bindings can now be set specifically </li>
<li> More functionality added to the gamelist widget.  </li>
<li> Re-sampled the Alpha bitmaps (thanks to Chessdb), and added support
     for 75 pixel bitmaps </li>
<li> Quick fixes for the repetitive nature of the "Draw" and "I Resign"
     messages from tacgame.  </li>
<li> Other minor changes: Control-WheelMouse == Sizeup/Sizedown,
     Variation buttons swap position, Spellcheck installation fix. </li>
</ul>

<h4>3.6.26.4 (July 5, 2009)</h4>
<ul>
<li> New Gamelist widget. It's much more powerful than the old one, but
     is not quite yet feature complete.  </li>
<li> Many changes to the Gameinfo widget, </li>
<li> , including a new "Set Game Information" widget.  </li>
<li> Stop game from crashing with languages other than English.  </li>
<li> Window placement is now relative the main window, rather than
     absolute +x+y </li>
<li> The Options::Chessboard menu now also includes the pieces menus </li>
<li> The 3 line PGN header is now colour </li>
<li> Home directory is now $HOME/.scidvspc (instead of $HOME/.scid).  </li>
<li> Pawn promotion dialog size now corresponds to board size, and
     overlays promoted pawn.  </li>
<li> Control-I toggles gameinfo panel. Control-b toggles
     Options::Chessboard widget, Control-L toggles gamelist widget.  </li>
<li> Other minor changes to fics, -O2, "exec tkscid" correctness, font
     and menu tweaks </li>
</ul>

<h4>3.6.26.3 (June 22, 2009)</h4>
<ul>
<li> Replaced most all of the old colour schemes and tiles.  </li>
<li> New Usual and Maya pieces.  </li>
<li> Rewrote (again) the option::chessboard::board_style widget.
     Changes are now made dynamically to the main board.  </li>
<li> Tweaked the pgn save menu, included a "Save Pgn" menu item in the
     "File" menu, and other pgn window bindings.  </li>
<li> Added a Fics autoflag option (for logging in as guest), and other
     Fics tweaks.  </li>
<li> Don't allow null entry of "Elo" field in analysis engine customisation.</li>
</ul>

<h4>3.6.26.2 (June 2009)</h4>
<ul>
<li> Game info panel restructured ;> </li>
<li> New Berlin, Spatial chess pieces </li>
<li> Fics and Fischer chess changes </li>
<li> Overhauled comment editor widget, including key bindings </li>
<li> More tacgame bug-fixes.  </li>
<li> Removed the right_click::take_back_move... This is just too
     dangerous for Fics (which really gets stuffed up). Mouse wheel
     bindings remain.  </li>
<li> Fixed more bugs in the tactical game feature.  </li>
<li> Allow the main window to use wish-8.5 native fullscreen mode.  </li>
<li> Bug fixed the scidvspc setup board.  </li>
<li> Little Fischer chess tweaks and bishop setup fixed.  </li>
<li> Gave the show_material canvas a little more space </li>
</ul>
<h4>3.6.26.1 (May 2009)</h4>
<ul>
<li> Overhauling the tactical game feature, including a Fischer chess option.  </li>
<li> Overhauling the tools::analysis widget.  </li>
<li> Some re-organization of menu widgets, including tear-off menus.  </li>
<li> Rewritten board style widget.  </li>
<li> Fix parenting of some pop-ups, including the splash widget </li>
<li> Clock widgets placed side-by-side.  </li>
<li> Remember fics widget size.  </li>
<li> Last move displayed in bold. </li>
</ul>
}
