### deutsch.tcl:
#  German language support for Scid.
#  Contributors: Bernhard Bialas, J�rgen Clos et al.
#  Untranslated messages are marked with a "***" comment.
#
#  Hinweis (aus tcl/lang/english.tcl):
#
# (4) [...]
#
#     A menu command has the format:
#         menuText L tag "Name..." underline {HelpMessage...}
#
#     [...]
#
#     where "L" is the language letter, "tag" is the name of the menu entry
#     or the button widget name, and "underline" is the index of the letter
#     to underline, counting from zero as the first letter. Two menu entries
#     that appear in the same menu should have a different underlined letter.

addLanguage D Deutsch 0 iso8859-1

proc setLanguage_D {} {

# File menu:
menuText D File "Datei" 0
menuText D FileNew "Neu..." 0 {Neue Scid-Datenbank anlegen}
menuText D FileOpen "�ffnen..." 0 {Existierende Scid-Datenbank �ffnen}
menuText D FileClose "Schlie�en" 0 {Aktive Scid-Datenbank schlie�en}
menuText D FileFinder "Finder" 0 {Dateifinderfenster �ffnen}
menuText D FileSavePgn "Save Pgn..." 0 {}
menuText D FileOpenBaseAsTree "�ffne DB als Baum" 0   {�ffne DB und verwende sie im Zugbaum-Fenster}
menuText D FileOpenRecentBaseAsTree "Letzte DB als Baum" 0   {�ffne zuletzt verwendete DB im Zugbaum-Fenster}
menuText D FileBookmarks "Lesezeichen" 0 {Lesezeichenmen� (Tasten: Strg+B)}
menuText D FileBookmarksAdd "Lesezeichen zur Liste hinzuf�gen" 0 \
  {Lesezeichen f�r die aktuelle Partie und Datenbank}
menuText D FileBookmarksFile "Lesezeichen hinzuf�gen in Verzeichnis" 26 \
  {Lesezeichen f�r die aktuelle Stellung und Partie zum Verzeichnis hinzuf�gen}
menuText D FileBookmarksEdit "Lesezeichen editieren..." 12 \
  {Lesezeichen bearbeiten}
menuText D FileBookmarksList "Listenansicht" 1 \
  {Lesezeichen als Liste zeigen, ohne Unterverzeichnisse}
menuText D FileBookmarksSub "Verzeichnisansicht" 3 \
  {Lesezeichen in Verzeichnissen zeigen, nicht als Gesamtliste}
menuText D FileReadOnly "Schreibschutz..." 3 \
  {Datenbank als schreibgesch�tzt behandeln, �nderungen verhindern}
menuText D FileSwitch "Datenbank wechseln" 0 \
  {Zu einer anderen ge�ffneten Datenbank umschalten}
menuText D FileExit "Ende" 0 {Scid beenden}

# Edit menu:
menuText D Edit "Bearbeiten" 0
menuText D EditAdd "Variante hinzuf�gen" 0 \
  {F�ge zu diesem Zug eine Variante hinzu}
menuText D EditPasteVar "Paste Variation" 0
menuText D EditDelete "Variante l�schen" 9 \
  {L�sche eine Variante zu diesen Zug}
menuText D EditFirst "Als erste Variante setzen" 4 \
  {Variante an erste Stelle in der Liste setzten}
menuText D EditMain "Variante als Partiefortsetzung" 13 \
  {Variante zur Partiefolge machen (und umgekehrt)}
menuText D EditTrial "Variante testen" 9 \
  {Testmodus starten/stoppen, um eine Idee am Brett auszuprobieren}
menuText D EditStrip "Entfernen" 1 \
   {Kommentare oder Varianten aus der Partie entfernen}
menuText D EditUndo "R�ckg�ngig" 0 {Macht die letzte �nderung r�ckg�ngig}
# todo
menuText D EditRedo "Redo" 0
menuText D EditStripComments "Kommentare" 0 \
  {Alle Kommentare und Kommentarzeichen aus dieser Partie entfernen}
menuText D EditStripVars "Varianten" 0 \
  {Alle Varianten aus der Partie entfernen}
menuText D EditStripBegin "Z�ge ab Anfang" 8 \
  {Entferne Z�ge ab Partieanfang}
menuText D EditStripEnd "Z�ge bis Ende" 9 \
  {Entferne Z�ge bis Partieende}
menuText D EditReset "Ablage leeren" 0 \
   {Inhalt der Ablage-Datenbank l�schen}
menuText D EditCopy "Partie in Ablage kopieren" 17 \
  {Diese Partie in die Ablage-Datenbank kopieren}
menuText D EditPaste "Partie aus Ablage einf�gen" 19 \
  {Aktive Partie aus der Ablage hier einf�gen}
menuText D EditPastePGN "PGN-Partie aus Ablage einf�gen..." 1 \
  {Interpretiere den Inhalt der Zwischenablage als PGN-Notation und f�ge ihn hier ein}
menuText D EditSetup "Stellungseingabe..." 0 \
  {Neue Stellung eingeben (FEN oder manuell)}
menuText D EditCopyBoard "Stellung kopieren" 10 \
  {Aktuelle Brettposition in die Zwischenablage kopieren (im FEN-Format)}
menuText D EditCopyPGN "Stellung PGN" 10 {}
menuText D EditPasteBoard "Stellung einf�gen" 12 \
  {Stellung aus der Zwischenablage (im FEN-Format) einf�gen}

# Game menu:
menuText D Game "Partie" 0
menuText D GameNew "Neue Partie" 5 \
  {Neue Partie beginnen, dabei alle �nderungen verwerfen}
menuText D GameFirst "Erste Partie laden" 0 {Erste Partie im Filter laden}
menuText D GamePrev "Vorherige Partie laden" 0 \
  {Vorherige Partie im Filter laden}
menuText D GameReload "Partie neu laden" 7 \
  {Diese Partie erneut laden, dabei alle �nderungen verwerfen}
menuText D GameNext "N�chste Partie laden" 0 {N�chste Partie im Filter laden}
menuText D GameLast "Letzte Partie laden" 0 {Letzte Partie im Filter laden}
menuText D GameRandom "Zuf�llige Partie laden" 1 \
  {Zuf�llig ausgew�hlte Partie im Filter laden}
menuText D GameNumber "Lade Partie Nummer..." 14 \
  {Partie durch Angabe der Nummer laden}
menuText D GameReplace "Partie ersetzen..." 8 \
  {Diese Partie sichern, dabei alte Version �berschreiben}
menuText D GameAdd "Partie speichern..." 7 \
  {Diese Partie als neue Partie in der Datenbank sichern}
menuText D GameInfo "Set Game Information" 9
menuText D GameBrowse "Spiele durchsuchen" 0
menuText D GameList "Alle Spiele" 0
menuText D GameDelete "Spiel l�schen" 0
menuText D GameDeepest "Er�ffnung identifizieren" 10 \
  {Zur Position der l�ngstm�glichen Zugfolge nach ECO-Klassifikation gehen}
menuText D GameGotoMove "Zugnummer..." 0 \
  {Zur angegebenen Zugnummer in der aktuellen Partie gehen}
menuText D GameNovelty "Finde Neuerung..." 0 \
  {Ersten Zug dieser Partie finden, der vorher noch nie gespielt wurde}

# Search menu:
menuText D Search "Suchen" 0
menuText D SearchReset "Filter zur�cksetzen" 0 \
  {Alle Partien in den Filter einschlie�en}
menuText D SearchNegate "Filter invertieren" 7 {Alle ausgeschlossenen Partien in den Filter nehmen}
menuText D SearchEnd "Umzug nach Last-Filter" 0
menuText D SearchCurrent "Brett..." 0 \
  {Aktuelle Brettposition suchen}
menuText D SearchHeader "Partiedaten..." 0 \
  {Partiedaten (Spieler, Turnier etc.) suchen}
menuText D SearchMaterial "Material/Muster..." 0 \
  {Nach Material- oder Stellungsmustern suchen}
menuText D SearchMoves {Z�ge} 0 {}
menuText D SearchUsing "Mit Suchoptionsdatei..." 4 \
  {Mit Suchoptionsdatei suchen}

# Windows menu:
menuText D Windows "Fenster" 0
menuText D WindowsGameinfo "Partieinformation anzeigen" 0 {Partieinformation anzeigen}
menuText D WindowsComment "Kommentareditor" 0 {Kommentareditor �ffnen/schlie�en}
menuText D WindowsGList "Partieliste" 6 {Partieliste �ffnen/schlie�en}
menuText D WindowsPGN "PGN-Fenster" 0 {PGN-Fenster (Partienotation) �ffnen/schlie�en}
menuText D WindowsCross "Kreuztabelle" 0 {Kreuztabelle f�r diese Partie anzeigen}
menuText D WindowsPList "Spielersuche" 0 {Spielerfinder �ffnen/schlie�en}
menuText D WindowsTmt "Turniersuche" 0 {Turnierfinder �ffnen/schlie�en}
menuText D WindowsSwitcher "Datenbank-Umschalter" 0 \
  {Datenbank-Umschalter �ffnen/schlie�en}
menuText D WindowsMaint "Wartungsfenster" 0 {(Datenbank-)Wartungsfenster �ffnen/schlie�en}
menuText D WindowsECO "ECO-Auswertung" 0 {ECO-Auswertung �ffnen/schlie�en}
menuText D WindowsStats "Statistik" 4 {Filterstatistik �ffnen/schlie�en}
menuText D WindowsTree "Zugbaum" 0 {Zugbaum �ffnen/schlie�en}
menuText D WindowsTB "Endspieltabellen..." 1 {Endspieltabellen �ffnen/schlie�en}
menuText D WindowsBook "Buchfenster" 0 {Buchfenster �ffnen/schlie�en}
menuText D WindowsCorrChess "Fernschachfenster" 0 {�ffnet/schlie�t das Fernschachfenster}

# Tools menu:
menuText D Tools "Werkzeuge" 0
menuText D ToolsAnalysis "Analyse-Engine..." 0 \
  {Schachanalyse-Programm starten/beenden}
menuText D ToolsEmail "E-Mail-Manager" 7 \
  {E-Mail-Manager �ffnen/schlie�en}
menuText D ToolsFilterGraph "Rel. Filtergrafik" 0 \
  {Filtergrafik mit relativen Werten �ffnen/schlie�en}
menuText D ToolsAbsFilterGraph "Abs. Filtergrafik" 11 \
  {Filtergrafik mit absoluten Werten �ffnen/schlie�en}
menuText D ToolsOpReport "Er�ffnungsbericht" 0 \
  {Ausf�hrliche Er�ffnungs�bersicht f�r die aktuelle Position erstellen}
menuText D ToolsTracker "Figurenverteilung"  7 \
  {Figurenverteilungsfenster �ffnen}
menuText D ToolsTraining "Training"  0 {Trainingswerkzeuge (Taktik, Er�ffnungen,...) }
menuText D ToolsComp "Tournament" 2 {Chess engine tournament}
menuText D ToolsTacticalGame "Trainingspartie"  0 {Trainingspartie spielen}
menuText D ToolsSeriousGame "Ernste Partie"  0 {Ernste Partie spielen}
menuText D ToolsTrainTactics "Taktik"  0 {Taktische Stellungen l�sen}
menuText D ToolsTrainCalvar "Varianten berechnen"  0 {Training zum Berechnen von Varianten}
menuText D ToolsTrainFindBestMove "Besten Zug finden"  0 {Find best move}
menuText D ToolsTrainFics "Internetpartie"  0 {Internetpartie auf freechess.org}
menuText D ToolsBookTuning "Buch abstimmen" 0 {Buch abstimmen}
menuText D ToolsMaint "Wartung" 0 {Das Scid-Datenbankwartungsfenster}
menuText D ToolsMaintWin "Wartungfenster" 0 \
  {Datenbank-Wartungsfenster �ffnen/schlie�en}
menuText D ToolsMaintCompact "Datenbank komprimieren..." 10 \
  {Datenbank komprimieren, gel�schte Spiele und unbenutzte Namen entfernen}
menuText D ToolsMaintClass "Partien ECO-klassifizieren..." 8 \
{Neuklassifizierung aller Partien nach dem ECO-Code}
menuText D ToolsMaintSort "Sortieren..." 0 \
  {Alle Partien in der aktuellen Datenbank sortieren}
menuText D ToolsMaintDelete "Dubletten l�schen..." 0 \
  {Dubletten finden und L�schkennzeichen setzen}
menuText D ToolsMaintTwin "Dubletten pr�fen" 10 \
  {Dublettenfenster �ffnen/erneuern}
menuText D ToolsMaintNameEditor "Namenseditor" 0 \
  {Namenseditorfenster �ffnen/schlie�en}
menuText D ToolsMaintNamePlayer "Schreibkorrektur Spieler..." 17 \
  {Schreibkorrektur der Spielernamen mit Hilfe der .ssp-Datei}
menuText D ToolsMaintNameEvent "Schreibkorrektur Ereignis..." 17 \
  {Schreibkorrektur der Ereignisse mit Hilfe der .ssp-Datei}
menuText D ToolsMaintNameSite "Schreibkorrektur Ort..." 17 \
  {Schreibkorrektur der Orte mit Hilfe der .ssp-Datei}
menuText D ToolsMaintNameRound "Schreibkorrektur Runde..." 17 \
  {Schreibkorrektur der Runden mit Hilfe der .ssp-Datei}
menuText D ToolsMaintFixBase "Inkonsistenzen beseitigen" 0 {Versuche eine inkonsistente Datenbank zu reparieren}
menuText D ToolsConnectHardware "Hardware verbinden" 0 {Externe Hardware mit Scid verbinden}
menuText D ToolsConnectHardwareConfigure "Konfigurieren..." 0 {Hardware und Verbindung konfigurieren}
menuText D ToolsConnectHardwareNovagCitrineConnect "Novag Citrine verbinden" 0 {Novag Citrine mit Scid verbinden}
menuText D ToolsConnectHardwareInputEngineConnect "Input Engine verbinden" 0 {Input Engine (z.B. DGT Brett) mit Scid verbinden}
menuText D ToolsNovagCitrine "Novag Citrine" 0 {Novag Citrine}
menuText D ToolsNovagCitrineConfig "Einstellungen" 0 {Novag Citrine Einstellungen}
menuText D ToolsNovagCitrineConnect "Verbinden" 0 {Novag Citrine verbinden}
menuText D ToolsPInfo "Spielerinformation"  0 \
  {Spielerinformation �ffnen/schlie�en}
menuText D ToolsPlayerReport "Spielerbericht" 7 \
  {Erzeuge einen Spielerbericht}
menuText D ToolsRating "ELO-Zahl-Verlauf" 4 \
  {Wertungsverlauf beider Spieler grafisch darstellen}
menuText D ToolsScore "Partiebewertungsgraph" 0 {Partie-Bewertungsgraph zeigen}
menuText D ToolsExpCurrent "Partie exportieren" 8 \
  {Aktuelle Partie in eine Textdatei schreiben}
menuText D ToolsExpCurrentPGN "Partie in PGN-Datei exportieren..." 10 \
  {Aktuelle Partie in eine PGN-Datei schreiben}
menuText D ToolsExpCurrentHTML "Partie in HTML-Datei exportieren..." 10 \
  {Aktuelle Partie in eine HTML-Datei schreiben}
menuText D ToolsExpCurrentHTMLJS "Partie in HTML/JavaScript-Datei exportieren..." 15 {Aktuelle Partie wird in eine HTML und JavaScript Datei exportiert.}  
menuText D ToolsExpCurrentLaTeX "Partie in LaTeX-Datei exportieren..." 10 \
  {Aktuelle Partie in eine LaTeX-Datei schreiben}
# ====== TODO To be translated ======
menuText D ToolsExpFilter "Alles im Filter exportieren" 16 \
  {Alle Partien im Filter in eine Textdatei schreiben}
menuText D ToolsExpFilterPGN "Filter in PGN-Datei exportieren..." 10 \
  {Alle Partien im Filter in eine PGN-Datei schreiben}
menuText D ToolsExpFilterHTML "Filter in HTML-Datei exportieren..." 10 \
  {Alle Partien im Filter in eine HTML-Datei schreiben}
menuText D ToolsExpFilterHTMLJS "Filter in HTML/JavaScript exportieren..." 17 {Alle Partien im Filter werden in eine HTML und JavaScript Datei exportiert.}  
menuText D ToolsExpFilterLaTeX "Filter in LaTeX-Datei exportieren..." 10 \
  {Alle Partien im Filter in eine LaTeX-Datei schreiben}
# ====== TODO To be translated ======
# ====== TODO To be translated ======
menuText D ToolsExpFilterGames "Export Gamelist to Text" 19 {Print a formatted Gamelist.}
menuText D ToolsImportOne "Eine PGN-Partie importieren..." 16 \
  {Eine Partie im PGN-Format eingeben oder einf�gen}
menuText D ToolsImportFile "PGN-Partien importieren..." 0 \
  {Partien aus einer PGN-Datei lesen}
menuText D ToolsStartEngine1 "Starte Engine1" 0  {Starte Analyse von Analyse-Engine1}
menuText D ToolsStartEngine2 "Starte Engine2" 0  {Starte Analyse von Analyse-Engine2}
menuText D ToolsScreenshot "Foren-Screenshot" 0
#-----AW------
menuText D Play "Spielen" 0 {Partien spielen}
menuText D CorrespondenceChess "Fernschach" 0 {Funktionen f�r E-Mail und Xfcc basiertes Fernschach}
menuText D CCConfigure "Einstellungen..." 0 {Generelle Einstellungen und externe Werkzeuge}
menuText D CCConfigRelay "Beobachtete Partien..." 10 {Configure games to be observed}
menuText D CCOpenDB "Datenbank �ffnen..." 0 {�ffnet die Standarddatenbank f�r Fernschachpartien}
menuText D CCRetrieve "Partien synchronisieren" 0 {Synchronisiert Partien mit dem Posteingang und mittels (Xfcc-)Hilfsprogramm}
menuText D CCInbox "Posteingang synchronisieren" 12 {Synchronisiert alle Partien im Posteingang}
menuText D CCSend "Zug senden" 0 {Verschickt den letzten Zug via E-Mail oder exterem (Xfcc-)Hilfsprogramm}
menuText D CCResign "Aufgeben" 0 {Partie aufgeben (funktioniert nicht via E-Mail)}
menuText D CCClaimDraw "Remis erkl�ren" 1 {Zug senden und Partie Remis erkl�ren (funktioniert nicht via E-Mail)}
menuText D CCOfferDraw "Remis anbieten" 0 {Zug senden und Remis anbieten (funktioniert nicht via E-Mail)}
menuText D CCAcceptDraw "Remis annehmen" 10 {Remis annehmen (funktioniert nicht via E-Mail)}
menuText D CCNewMailGame "Neue E-Mail Partie..." 0 {Beginnt eine neue Partie via E-Mail}
menuText D CCMailMove "Zug per E-Mail senden..." 9 {Verschickt den letzten Zug per E-Mail}
menuText D CCGamePage "Partieseite (WWW)..." 13 {Ruft die Webseite der Partie auf}
menuText D CCEditCopy "Partieliste in Ablage" 0 {Kopiert die Parieliste als CSV in die Zwischenablage}
#-----AW------

# Options menu:
menuText D Options "Optionen" 0
menuText D OptionsBoard "Schachbrett" 6 {Schachbrettoptionen}
menuText D OptionsColour "Hintergrundfarbe" 0 {Default text widget color}
# ====== TODO To be translated ======
menuText D OptionsBackColour "Background" 0 {Default text widget color}
menuText D OptionsEnableColour "Einschalten" 0 {}
# ====== TODO To be translated ======
menuText D OptionsMainLineColour "Mainline Arrows" 0 {Mainline arrows}
# ====== TODO To be translated ======
menuText D OptionsVarLineColour "Variation Arrows" 0 {Variation arrows}
# ====== TODO To be translated ======
menuText D OptionsRowColour "Rows" 0 {Default tree/book row color}
# ====== TODO To be translated ======
menuText D OptionsSwitcherColour "Switcher" 0 {Default db switcher color}
# ====== TODO To be translated ======
menuText D OptionsProgressColour "Progressbar" 0 {Default progressbar color}
# ====== TODO To be translated ======
menuText D OptionsCrossColour "Crosstable rows" 0 {Default crosstable row color}
menuText D OptionsNames "Meine Spielernamen..." 0 {Editiere meine Spielernamen}
menuText D OptionsExport "Export" 1 {Textausgabeoptionen �ndern}
menuText D OptionsFonts "Schriftarten" 3 {Schriftart wechseln}
menuText D OptionsFontsRegular "Normal" 0 {Standardzeichensatz}
menuText D OptionsFontsMenu "Men�" 0 {Schriftart f�r Men�s}
menuText D OptionsFontsSmall "Klein" 0 {Kleine Zeichen}
menuText D OptionsFontsFixed "Fest" 0 {Schriftart mit fester Breite (nicht-proportional)}
menuText D OptionsGInfo "Partieinformation" 0 {Optionen f�r Informationsbereich}
menuText D OptionsFics "FICS" 0
# ====== TODO To be translated ======
menuText D OptionsFicsAuto "Autopromote K�nigin" 0
menuText D OptionsFicsColour "Textfarbe" 0
menuText D OptionsFicsSize "Brettgr��e" 0
# ====== TODO To be translated ======
menuText D OptionsFicsButtons "User Buttons" 0
menuText D OptionsFicsCommands "Startbefehle" 0
menuText D OptionsFicsNoRes "Keine Ergebnisse" 0
menuText D OptionsFicsNoReq "Keine Anfragen" 0
# ====== TODO To be translated ======
menuText D OptionsFicsPremove "Allow Premove" 0
menuText D OptionsLanguage "Sprache" 0 {Sprache w�hlen}
menuText D OptionsMovesTranslatePieces "Figurennamen �bersetzen" 0 {�bersetze den ersten Buchstaben der Figurenbezeichnung}
menuText D OptionsMovesHighlightLastMove "Letzen Zug hervorheben" 0 {Rahmt Start- und Zielfeld des letzten Zuges farbig ein}
menuText D OptionsMovesHighlightLastMoveDisplay "Anzeigen" 0 {Hervorhebung des letzen Zuges anzeigen}
menuText D OptionsMovesHighlightLastMoveWidth "Dicke" 0 {Dicke der Linie}
menuText D OptionsMovesHighlightLastMoveColor "Farbe" 0 {Farbe der Linie}
menuText D OptionsMoves "Z�ge" 0 {Zugeingabeoptionen}
menuText D OptionsMovesAsk "Fragen vor Ersetzen" 0 \
  {Vor �berschreiben existierender Z�ge nachfragen}
menuText D OptionsMovesAnimate "Animation" 0 \
  {Zeit f�r Zuganimation einstellen}
menuText D OptionsMovesDelay "Autom. Vorspielen..." 7 \
  {Zeit f�r automatisches Vorspielen einstellen}
menuText D OptionsMovesCoord "Tastatureingabe" 0 \
  {Zugeingabe �ber Koordinaten ("g1f3") akzeptieren}
menuText D OptionsMovesSuggest "Zugvorschlag zeigen" 0 \
  {Zugvorschlag ein-/ausschalten}
menuText D OptionsShowVarPopup "Variantenfenster zeigen" 0 { Anzeige des Variantenauswahlfensters ein/ausschalten}  
menuText D OptionsMovesSpace "Leerzeichen nach Zugnummer einf�gen" 0 {Leerzeichen nach Zugnummer einf�gen}  
menuText D OptionsMovesKey "Autom. Zugerg�nzung" 10 \
  {Automatische Zugerg�nzung ein-/ausschalten}
menuText D OptionsMovesShowVarArrows "Pfeile f�r Varianten anzeigen" 0 {Zeige Pfeile in Varianten an: ja/nein}
menuText D OptionsNumbers "Zahlenformat" 5 {Zahlenformat w�hlen}
menuText D OptionsStartup "Autostart" 1 {Fenster zum �ffnen bei Start ausw�hlen}
menuText D OptionsTheme "Design" 0 {Ver�ndert das Aussehen der Oberfl�che}
menuText D OptionsWindows "Fenster" 6 {Fenster-Optionen}
menuText D OptionsWindowsIconify "Autom. minimieren" 7 \
  {Alle Fenster mit dem Hauptfenster minimieren}
menuText D OptionsWindowsRaise "Autom. Verwaltung" 7 \
  {Bestimmte Fenster (z.B. Zustandsleiste) bei Bedarf �ffnen}
menuText D OptionsSounds "T�ne..." 0 {T�ne f�r Zugank�ndigung einstellen} ;# *** Hmm, :-|
menuText D OptionsWindowsDock "Fenster docken" 0 {Fenster docken}
menuText D OptionsWindowsSaveLayout "Layout speichern" 0 {Das Fensterlayout abspeichern}
menuText D OptionsWindowsRestoreLayout "Layout wiederherstellen" 0 {Das gespeicherte Fensterlayout wiederherstellen}
menuText D OptionsWindowsShowGameInfo "Partieinformationen" 0 {Partieinformation anzeigen}
menuText D OptionsWindowsAutoLoadLayout "Automatisch laden: 1. Layout" 0 {L�dt das erste definierte Layout automatisch beim Programmstart}
menuText D OptionsWindowsAutoResize "Brettgr��e autom. anpassen" 0 {}
# ====== TODO To be translated ======
menuText D OptionsWindowsFullScreen "Vollbild" 0 {Vollbild Modus umschalten}
menuText D OptionsToolbar "Werkzeugleiste" 0 {Werkzeug- bzw. Symbolleiste Ein/Aus}
menuText D OptionsECO "ECO-Datei laden..." 0 {ECO-Klassifikationsdatei laden}
menuText D OptionsSpell "Schreibkorrekturdatei laden..." 7 \
  {Datei f�r Scid-Rechtschreibpr�fung laden}
menuText D OptionsTable "Endspieltabellenverzeichnis..." 16 \
  {Eine Endspieltabellendatei w�hlen (und damit alle Tabellen in diesem Verzeichnis)}
menuText D OptionsRecent "Aktuelle Dateien..." 9 \
  {Anzahl der aktuellen Dateien im Dateimen� �ndern}
menuText D OptionsBooksDir "Buchverzeichnis..." 0 {Er�ffnungsbuchverzeichnis einstellen}
menuText D OptionsTacticsBasesDir "Bases Verzeichnis..." 0 {Verzeichnis f�r taktische Trainingsdatenbanken einstellen}
menuText D OptionsSave "Optionen speichern" 0 \
  "Alle einstellbaren Optionen in der Datei $::optionsFile sichern"
menuText D OptionsAutoSave "Autom. speichern bei Beenden" 0 \
  {Alle Optionen beim Beenden von Scid automatisch speichern}

# Help menu:
menuText D Help "Hilfe" 0
menuText D HelpContents "Inhalt" 0 {Gehe zum Inhaltsverzeichnis}
menuText D HelpIndex "Index" 4 {Gehe zum Hilfeindex}
menuText D HelpGuide "Kurzanleitung" 4 {Ein Scid-Schnelldurchgang}
menuText D HelpHints "Hinweise" 0 {Die Scid-Kurztips}
menuText D HelpContact "Kontaktinformation" 0 {Hilfe zur Kontaktinformation}
menuText D HelpTip "Tagestip" 0 {Zeigt einen n�tzlichen Tip an}
menuText D HelpStartup "Startfenster" 0 {Startfenster zeigen}
menuText D HelpAbout "�ber Scid" 0 {Informationen zu Scid}

# Game info box popup menu:
menuText D GInfoHideNext "N�chsten Zug verstecken" 13
menuText D GInfoShow "Zugrecht anzeigen" 0
menuText D GInfoCoords "Koordinaten anzeigen" 0
menuText D GInfoMaterial "Materialwerte zeigen" 0
menuText D GInfoFEN "FEN zeigen" 0
menuText D GInfoMarks "Gef�rbte Felder und Pfeile zeigen" 0
menuText D GInfoWrap "Umbruch bei langen Zeilen" 0
menuText D GInfoFullComment "Vollst�ndigen Kommentar zeigen" 14
menuText D GInfoPhotos "Fotos zeigen" 1
menuText D GInfoTBNothing "Endspieltabellen: nichts" 18
menuText D GInfoTBResult "Endspieltabellen: nur Ergebnis" 22
menuText D GInfoTBAll "Endspieltabellen: Ergebnis und bester Zug" 31
menuText D GInfoDelete "(Ent)L�sche diese Partie" 5
menuText D GInfoMark "(Un)Markiere diese Partie" 4
menuText D GInfoInformant "Informatorwerte konfigurieren" 0
translate D FlipBoard {Brett drehen}
# ====== TODO To be translated ======
translate D RaiseWindows {Raise windows}
translate D AutoPlay {Abspielen}
translate D TrialMode {Z�ge ausprobieren}

# General buttons:
# todo
translate D Apply {�bernehmen}
translate D Back {Zur�ck}
translate D Browse {Durchst�bern}
translate D Cancel {Abbrechen}
translate D Continue {Weiter}
translate D Clear {Leeren}
translate D Close {Schlie�en}
translate D Contents {Inhalt}
translate D Defaults {Standard}
translate D Delete {L�sche}
translate D Graph {Grafik}
translate D Help {Hilfe}
translate D Import {Importieren}
translate D Index {Index}
translate D LoadGame {Partie laden}
translate D BrowseGame {Partie betrachten}
translate D MergeGame {Partie kombinieren} ;# mischen?! einf�gen!?
translate D MergeGames {Partien kombinieren}
translate D Preview {Vorschau} ;# Voransicht!? (KDE)
translate D Revert {Umkehren}
translate D Save {Speichern}
# ====== TODO To be translated ======
translate D DontSave {Don't Save}
translate D Search {Suchen}
translate D Stop {Halt}
translate D Store {Speichern}
translate D Update {Aktualisieren}
translate D ChangeOrient {Fensterausrichtung �ndern}
translate D ShowIcons {Icons anzeigen} ;# ***
# ====== TODO To be translated ======
translate D ConfirmCopy {Confirm Copy}
translate D None {Keine}
translate D First {Erste}
translate D Current {Aktuelle}
translate D Last {Letzte}
# ====== TODO To be translated ======
translate D Font {Font}
# ====== TODO To be translated ======
translate D Change {Change}
# ====== TODO To be translated ======
translate D Random {Random}

# General messages:
translate D game {Partie}
translate D games {Partien}
translate D move {Zug}
translate D moves {Z�ge}
translate D all {Alle}
translate D Yes {Ja}
translate D No {Nein}
translate D Both {Beide}
translate D King {K�nig}
translate D Queen {Dame}
translate D Rook {Turm}
translate D Bishop {L�ufer}
translate D Knight {Springer}
translate D Pawn {Bauer}
translate D White {Wei�}
translate D Black {Schwarz}
translate D Player {Spieler}
translate D Rating {Elo}
translate D RatingDiff {Elo-Differenz (Wei� - Schwarz)}
translate D AverageRating {Elo-Durchschnitt}
translate D Event {Turnier}
translate D Site {Ort}
translate D Country {Land}
translate D IgnoreColors {Farben ignorieren}
# ====== TODO To be translated ======
translate D MatchEnd {End pos only}
translate D Date {Datum}
translate D EventDate {Turnierdatum}
translate D Decade {Dekade}
translate D Year {Jahr}
translate D Month {Monat}
translate D Months {Januar Februar M�rz April Mai Juni Juli August September Oktober November Dezember}
translate D Days {Son Mon Die Mit Don Fre Sam}
translate D YearToToday {Ein Jahr zur�ck}
translate D Result {Ergebnis}
translate D Round {Runde}
translate D Length {L�nge}
translate D ECOCode {ECO-Code}
translate D ECO {ECO}
translate D Deleted {Gel�scht}
translate D SearchResults {Suchergebnisse}
translate D OpeningTheDatabase {Datenbank �ffnen}
translate D Database {Datenbank}
translate D Filter {Filter}
translate D Reset {Zur�cksetzen}
translate D IgnoreCase {Ignoriert Gro�}
translate D noGames {keine Partien}
translate D allGames {alle Partien}
translate D empty {leer}
translate D clipbase {Ablage}
translate D score {Punkte}
translate D Start {Start}
translate D StartPos {Stellung}
translate D Total {Summe}
translate D readonly {schreibgesch�tzt}
translate D altered {ge�ndert}
# ====== TODO To be translated ======
translate D tagsDescript {Extra tags (eg: Annotator "Anand")}
# ====== TODO To be translated ======
translate D prevTags {Use previous}

# Standard error messages:
translate D ErrNotOpen {Dies ist keine ge�ffnete Datenbank.}
translate D ErrReadOnly \
  {Diese Datenbank ist schreibgesch�tzt; sie kann nicht ge�ndert werden.}
translate D ErrSearchInterrupted \
  {Suche wurde unterbrochen; Ergebnisse sind unvollst�ndig.}

# Game information:
translate D twin {Dublette}
translate D deleted {gel�scht}
translate D comment {Kommentar}
translate D hidden {versteckt}
translate D LastMove {Letzter Zug}
translate D NextMove {N�chster Zug}
translate D GameStart {Partieanfang}
translate D LineStart {Beginn der Zugfolge}
translate D GameEnd {Partieende}
translate D LineEnd {Ende der Zugfolge}

# Player information:
translate D PInfoAll {Alle Spiele}
translate D PInfoFilter {Filter-Spiele}
translate D PInfoAgainst {Ergebnisse gegen}
translate D PInfoMostWhite {H�ufigste Er�ffnungen als Wei�er}
translate D PInfoMostBlack {H�ufigste Er�ffnungen als Schwarzer}
translate D PInfoRating {ELO-Historie}
translate D PInfoBio {Biographie}
translate D PInfoEditRatings {Bewertung bearb.}
translate D PinfoEditName {Name �ndern}
translate D PinfoLookupName {Name suchen}

# Tablebase information:
translate D Draw {Remis}
translate D stalemate {Patt}
# ====== TODO To be translated ======
translate D checkmate {checkmate}
translate D withAllMoves {mit allen Z�gen}
translate D withAllButOneMove {mit allen au�er einem Zug}
translate D with {mit}
translate D only {nur}
translate D lose {verlieren}
translate D loses {verliert}
translate D allOthersLose {alle anderen verlieren}
translate D matesIn {setzt Matt in}
translate D longest {l�ngste}
translate D WinningMoves {Gewinnz�ge}
translate D DrawingMoves {Remisz�ge}
translate D LosingMoves {Verlustz�ge}
translate D UnknownMoves {Z�ge mit unbekanntem Resultat}

# Tip of the day:
translate D Tip {Tipp}
translate D TipAtStartup {Tipp beim Starten}

# Tree window menus:
menuText D TreeFile "Datei" 0
menuText D TreeFileFillWithBase "Cache mit Datenbank f�llen" 0 {Die Cache-Datei wird mit allen Partien der aktuellen Datenbank bef�llt.}
menuText D TreeFileFillWithGame "Cache mit Partie f�llen" 0 {Die Cache-Datei wird mit der aktuellen Partien bef�llt.}
menuText D TreeFileSetCacheSize "Cachegr��e" 0 {Cachegr��e ausw�hlen.}
menuText D TreeFileCacheInfo "Cache Informationen" 0 {Info �ber Cachenutzung anzeigen.}
menuText D TreeFileSave "Cache-Datei sichern" 12 \
  {Speichere die Zugbaum-Cache-Datei (.stc)}
menuText D TreeFileFill "Cache-Datei f�llen" 12 \
  {F�lle die Cache-Datei mit h�ufigen Er�ffnungspositionen}
menuText D TreeFileBest "Beste Partien" 0 \
  {Zeige die Liste bester Partien im Baum}
menuText D TreeFileGraph "Grafikfenster" 0 \
  {Zeige die Grafik f�r diesen Ast}
menuText D TreeFileCopy "Kopiere Baumfenster in Zwischenablage" 0 \
  {Kopiere die Zugbaum-Statistik in die Zwischenablage}
menuText D TreeFileClose "Baumfenster schlie�en" 12 {Schlie�e Zugbaum}
menuText D TreeMask "Maskieren" 0
menuText D TreeMaskNew "Neu" 0 {Neue Maske anlegen}
menuText D TreeMaskOpen "�ffnen" 0 {Maske �ffnen}
menuText D TreeMaskOpenRecent "Aktuelle Masken" 0 {Zuletzt ge�ffnete Masken erneut laden}
menuText D TreeMaskSave "Speichern" 0 {Maske speichern}
menuText D TreeMaskClose "Schlie�en" 0 {Maske schlie�en}
# ====== TODO To be translated ======
menuText D TreeMaskFillWithLine "Fill with line" 0 {Fill mask with all previous moves}
menuText D TreeMaskFillWithGame "Mit aktueller Partie f�llen" 0 {Maske mit der aktuellen Partie f�llen}
menuText D TreeMaskFillWithBase "Mit Datenbank f�llen" 0 {Maske mit Datenbankpartien f�llen}
menuText D TreeMaskInfo "Info" 0 {Statistik f�r die aktuelle Maske anzeigen}
menuText D TreeMaskDisplay "Maske als Baum" 0 {Zeigt den Inhalt der aktuellen Maske als Zugbaum}
menuText D TreeMaskSearch "Suchen" 0 {Suchen innerhalb der aktuellen Maske}
menuText D TreeSort "Sortieren" 0
menuText D TreeSortAlpha "Alphabetisch" 0
menuText D TreeSortECO "ECO-Code" 0
menuText D TreeSortFreq "H�ufigkeit" 0
menuText D TreeSortScore "Punkte" 0
menuText D TreeOpt "Optionen" 0
menuText D TreeOptSlowmode "Gr�ndliche Suche" 0 {Update mit hoher Genauigkeit, langsamer}
menuText D TreeOptFastmode "Schneller Modus" 0 {Schnelles Update (ignoriert Zugumstellungen)}
menuText D TreeOptFastAndSlowmode "Gr�ndlicher und Schneller Modus" 0 {Zun�chst schneller Updatemodus, dann nacharbeit im gr�ndlichen Modus}
menuText D TreeOptStartStop "Automatisch aktualisieren" 0 {Schaltet das automatische aktualisieren ein/aus}
menuText D TreeOptLock "Anbinden" 0 \
  {Zugbaum an aktive Datenbank anbinden(/l�sen)}
menuText D TreeOptTraining "Training" 0 {Trainingsmodus ein-/ausschalten}
# ====== TODO To be translated ======
menuText D TreeOptShort "Short Display" 0 {Don't show ELO information}
menuText D TreeOptAutosave "Autom. Cache-Datei sichern" 4 \
  {Beim Schlie�en des Zugbaums automatisch Cache-Datei sichern}
# ====== TODO To be translated ======
menuText D TreeOptAutomask "Auto-Load Mask" 0 "Auto-Load most recent mask with a tree open."
# ====== TODO To be translated ======
menuText D TreeOptShowBar "Show Progress Bar" 0 "Show tree progress bar."
# ====== TODO To be translated ======
menuText D TreeOptSortBest "Sort Best Games" 0 "Sort Best Games by ELO."
menuText D TreeHelp "Hilfe" 0
menuText D TreeHelpTree "Zugbaumhilfe" 0
menuText D TreeHelpIndex "Index" 0


translate D SaveCache {Cache sichern}
translate D Training {Training}
translate D LockTree {Anbinden}
translate D TreeLocked {angebunden}
translate D TreeBest {Beste}
translate D TreeBestGames {Beste Zugbaumpartien}
translate D TreeAdjust {Filter anpassen}
# Note: the next message is the tree window title row. After editing it,
# check the tree window to make sure it lines up with the actual columns.
translate D TreeTitleRow {    Zug       H�ufigkeit    Pkte Remis  Elo  Erflg Jahr ECO}
translate D TreeTitleRowShort {    Zug       H�ufigkeit    Pkte Remis}
translate D TreeTotal {SUMME}
translate D DoYouWantToSaveFirst {Soll zuerst gespeichert werden}
translate D AddToMask {Addiere zu Maske}
translate D RemoveFromMask {Entferne von Maske}
# TODO
translate D AddThisMoveToMask {Add Move to Mask}
translate D SearchMask {Suche in einer Maske}
translate D DisplayMask {Maske als Zugbaum}
translate D Nag {NAG Code}
translate D Marker {Marker}
translate D Include {Einbezogene Variante}
translate D Exclude {Ausgeschlossene Variante}
translate D MainLine {Hauptvariante}
translate D Bookmark {Lesezeichen}
translate D NewLine {Neue Variante}
translate D ToBeVerified {�berpr�fen}
translate D ToTrain {Trainieren}
translate D Dubious {Zweifelhaft}
translate D ToRemove {Entfernen}
translate D NoMarker {Keine Markierung}
translate D ColorMarker {Farbe}
translate D WhiteMark {Wei�}
translate D GreenMark {Gr�n}
translate D YellowMark {Gelb}
translate D BlueMark {Blau}
translate D RedMark {Rot}
translate D CommentMove {Zug kommentieren}
translate D CommentPosition {Position kommentieren}
translate D AddMoveToMaskFirst {Zug zuerst zur Maske hinzuf�ngen}
translate D OpenAMaskFileFirst {Zun�chst Maske �ffnen}
translate D Positions {Positionen}
translate D Moves {Z�ge}

# Finder window:
menuText D FinderFile "Datei" 0
menuText D FinderFileSubdirs "Unterverzeichnisse beachten" 0
menuText D FinderFileClose "Dateifinder schlie�en" 0
menuText D FinderSort "Sortieren" 0
menuText D FinderSortType "Typ" 0
menuText D FinderSortSize "Gr��e" 0
menuText D FinderSortMod "Modifiziert" 0
menuText D FinderSortName "Namen" 0
menuText D FinderSortPath "Pfad" 0
menuText D FinderTypes "Typen" 0
menuText D FinderTypesScid "Scid-Datenbanken" 0
menuText D FinderTypesOld "Datenbanken im alten Format" 0
menuText D FinderTypesPGN "PGN-Dateien" 0
menuText D FinderTypesEPD "EPD-Dateien" 0
menuText D FinderHelp "Hilfe" 0
menuText D FinderHelpFinder "Dateifinderhilfe" 0
menuText D FinderHelpIndex "Index" 0
translate D FileFinder {Dateifinder}
translate D FinderDir {Verzeichnis}
translate D FinderDirs {Verzeichnisse}
translate D FinderFiles {Dateien}
translate D FinderUpDir {hoch}
translate D FinderCtxOpen {�ffnen}
translate D FinderCtxBackup {Sicherungskopie}
translate D FinderCtxCopy {Kopieren}
translate D FinderCtxMove {Verschieben}
translate D FinderCtxDelete {L�schen}

# Player finder:
menuText D PListFile "Datei" 0
menuText D PListFileUpdate "Aktualisieren" 0
menuText D PListFileClose "Spielerfinder schlie�en" 7
menuText D PListSort "Sortieren" 0
menuText D PListSortName "Name" 0
menuText D PListSortElo "Elo" 0
menuText D PListSortGames "Partien" 0
menuText D PListSortOldest "�lteste" 0
menuText D PListSortNewest "Neueste" 0

# Tournament finder:
menuText D TmtFile "Datei" 0
menuText D TmtFileUpdate "Aktualisieren" 0
menuText D TmtFileClose "Turnierfinder schlie�en" 0
menuText D TmtSort "Sortieren" 0
menuText D TmtSortDate "Datum" 0
menuText D TmtSortPlayers "Spieler" 0
menuText D TmtSortGames "Partien" 0
menuText D TmtSortElo "Elo" 0
menuText D TmtSortSite "Ort" 0
menuText D TmtSortEvent "Turnier" 1
menuText D TmtSortWinner "Gewinner" 0
translate D TmtLimit "Listengrenze"
translate D TmtMeanElo "Unterster Elo-Durchschnitt"
translate D TmtNone "Keine zutreffenden Turniere gefunden."

# Graph windows:
menuText D GraphFile "Datei" 0
menuText D GraphFileColor "Als Farb-Postscript speichern..." 4
menuText D GraphFileGrey "Als Graustufen-Postscript speichern..." 4
menuText D GraphFileClose "Fenster schlie�en" 0
menuText D GraphOptions "Optionen" 0
menuText D GraphOptionsWhite "Wei�" 0
menuText D GraphOptionsBlack "Schwarz" 0
menuText D GraphOptionsBoth "Beide" 0
menuText D GraphOptionsPInfo "Spielerinfo Spieler" 1
translate D GraphFilterTitle "Filtergrafik: H�ufigkeit pro 1000 Partien"
translate D GraphAbsFilterTitle "Filtergrafik: H�ufigkeit der Partien"
translate D ConfigureFilter "X-Achse f�r Jahr, Elo und Z�ge konfigurieren"
translate D FilterEstimate "Sch�tzen"
translate D TitleFilterGraph "Scid: Filtergrafik"

# Analysis window:
translate D AddVariation {Variante hinzuf�gen}
translate D AddAllVariations {Alle Varianten hinzuf�gen}
translate D AddMove {Zug hinzuf�gen}
translate D Annotate {Autom. kommentieren}
translate D ShowAnalysisBoard {Analysebrett anzeigen}
translate D ShowInfo {Engine-Information anzeigen}
translate D FinishGame {Partie beenden}
translate D StopEngine {Engine anhalten}
translate D StartEngine {Engine starten}
translate D ExcludeMove {Zug ausschlie�en}
translate D LockEngine {Anbinden an aktuelle Position}
translate D AnalysisCommand {Analysebefehl}
translate D PreviousChoices {Vorherige Wahl}
translate D AnnotateTime {Zeit zwischen den Z�gen (in Sek.) einstellen}
translate D AnnotateWhich {Varianten hinzuf�gen}
translate D AnnotateAll {F�r Z�ge beider Seiten}
translate D AnnotateAllMoves {Alle Z�ge kommentieren}
translate D AnnotateWhite {Nur f�r Z�ge von Wei�}
translate D AnnotateBlack {Nur f�r Z�ge von Schwarz}
translate D AnnotateNotBest {Wenn der Partiezug nicht der beste Zug ist}
translate D AnnotateBlundersOnly {Wenn der Partiezug ein offensichtlicher Fehler ist}
# ====== TODO To be translated ======
translate D BlundersNotBest {Blunders/Not Best}
translate D AnnotateBlundersOnlyScoreChange {Analyse berichtet Fehler, Bewertungs�nderung von/nach: }
translate D AnnotateTitle {konfigurieren Annotation}
translate D BlundersThreshold {Grenze}
# ====== TODO To be translated ======
translate D ScoreFormat {Score format}
# ====== TODO To be translated ======
translate D CutOff {Cut Off}
translate D LowPriority {Niedrige CPU-Priorit�t}
translate D LogEngines {Log Gr��e}
# ====== TODO To be translated ======
translate D LogName {Namen hinzuf�gen}
# ====== TODO To be translated ======
translate D MaxPly {Max Ply}
translate D ClickHereToSeeMoves {Hier klicken um Z�ge anzuzeigen}
translate D ConfigureInformant {Informator konfigurieren}
translate D Informant!? {Interessanter Zug}
translate D Informant? {Schwacher Zug}
translate D Informant?? {Fehler}
translate D Informant?! {Zweifelhafter Zug}
translate D Informant+= {Wei� hat leichten Vorteil}
translate D Informant+/- {Wei� hat m��igen Vorteil}
translate D Informant+- {Wei� hat gro�en Vorteil}
translate D Informant++- {Partie wird gewonnen}
translate D Book {Buch}

# Analysis Engine open dialog:
translate D EngineList {Analyse-Engines}
# ====== TODO To be translated ======
translate D EngineKey {Key}
# ====== TODO To be translated ======
translate D EngineType {Type}
translate D EngineName {Name}
translate D EngineCmd {Befehl}
translate D EngineArgs {Parameter}
translate D EngineDir {Verzeichnis}
translate D EngineElo {Elo}
translate D EngineTime {Datum}
translate D EngineNew {Neu}
translate D EngineEdit {Bearbeiten}
translate D EngineRequired {Fettgedruckte Parameter erforderlich, andere optional}


# Stats window menus:
menuText D StatsFile "Datei" 0
menuText D StatsFilePrint "Drucken in Datei..." 0
menuText D StatsFileClose "Fenster schlie�en" 0
menuText D StatsOpt "Optionen" 0

# PGN window menus:
menuText D PgnFile "Datei" 0
menuText D PgnFileCopy "Kopiere Spiel in Zwischenablage" 0
menuText D PgnFilePrint "Drucken in Datei..." 0
menuText D PgnFileClose "PGN-Fenster schlie�en" 0
menuText D PgnOpt "Ausgabe" 0
menuText D PgnOptColor "Farbige Darstellung" 0
menuText D PgnOptShort "Kurzer (3-Zeilen) Vorspann (Header)" 8
menuText D PgnOptSymbols "Symbolische Darstellung" 0
menuText D PgnOptIndentC "Kommentare einr�cken" 0
menuText D PgnOptIndentV "Varianten einr�cken" 0
menuText D PgnOptColumn "Tabellarisch (ein Zug pro Zeile)" 0
menuText D PgnOptSpace "Leerzeichen nach Zugnummer" 0
menuText D PgnOptStripMarks "Farbfelder-/Pfeile-Zeichen entfernen" 27
menuText D PgnOptChess "Schachfiguren als Symbole" 6
menuText D PgnOptScrollbar "Bildlaufleiste" 0
menuText D PgnOptBoldMainLine "Partiez�ge in Fettdruck" 0
menuText D PgnColor "Farben" 0
menuText D PgnColorHeader "Vorspann..." 0
menuText D PgnColorAnno "Anmerkungen..." 0
menuText D PgnColorComments "Kommentare..." 0
menuText D PgnColorVars "Varianten..." 0
menuText D PgnColorBackground "Hintergrund..." 0
menuText D PgnColorMain "Partieverlauf..." 0
menuText D PgnColorCurrent "Hintergrund aktueller Zug..." 1
menuText D PgnColorNextMove "Hintergrund n�chter Zug..." 0
menuText D PgnHelp "Hilfe" 0
menuText D PgnHelpPgn "PGN-Hilfe" 0
menuText D PgnHelpIndex "Index" 0
translate D PgnWindowTitle {Partienotation - Partie %u}

# Crosstable window menus:
menuText D CrosstabFile "Datei" 0
menuText D CrosstabFileText "Ausgabe in Textdatei..." 11
menuText D CrosstabFileHtml "Ausgabe in HTML-Datei..." 11
menuText D CrosstabFileLaTeX "Ausgabe in LaTeX-Datei..." 11
menuText D CrosstabFileClose "Kreuztabelle schlie�en" 0
menuText D CrosstabEdit "Bearbeiten" 0
menuText D CrosstabEditEvent "Ereignis" 0
menuText D CrosstabEditSite "Ort" 0
menuText D CrosstabEditDate "Datum" 0
menuText D CrosstabOpt "Ausgabe" 0
menuText D CrosstabOptColorPlain "Text" 0
menuText D CrosstabOptColorHyper "Hypertext" 0
# ====== TODO To be translated ======
menuText D CrosstabOptTieWin "Tie-Break by wins" 1
# ====== TODO To be translated ======
menuText D CrosstabOptTieHead "Tie-Break by head-head" 1
# todo
menuText D CrosstabOptThreeWin "3 Punkte f�r Sieg" 1
menuText D CrosstabOptAges "Alter in Jahren" 0
menuText D CrosstabOptNats "Nationalit�t" 0
# todo
menuText D CrosstabOptTallies "Sieg/Niederlage/Unentschieden" 0
menuText D CrosstabOptRatings "Elo" 0
menuText D CrosstabOptTitles "Titel" 0
menuText D CrosstabOptBreaks "Stichkampfpunkte" 10
menuText D CrosstabOptDeleted "Inklusive gel�schte Partien" 10
menuText D CrosstabOptColors "Farben (nur Schweizer System)" 0
# ====== TODO To be translated ======
menuText D CrosstabOptColorRows "Color Rows" 0
menuText D CrosstabOptColumnNumbers "Numerierte Spalten (Nur jeder-gegen-jeden-Tabelle)" 2
menuText D CrosstabOptGroup "Punktgruppen" 5
menuText D CrosstabSort "Sortieren" 0
menuText D CrosstabSortName "Name" 0
menuText D CrosstabSortRating "Elo" 0
menuText D CrosstabSortScore "Punkte" 0
menuText D CrosstabSortCountry "Land" 0
# todo
menuText D CrosstabType "Format" 0
menuText D CrosstabTypeAll "Jeder gegen jeden" 0
menuText D CrosstabTypeSwiss "Schweizer System" 0
menuText D CrosstabTypeKnockout "K.o.-System" 0
menuText D CrosstabTypeAuto "Automatisch" 1
menuText D CrosstabHelp "Hilfe" 0
menuText D CrosstabHelpCross "Kreuztabelle-Hilfe" 0
menuText D CrosstabHelpIndex "Index" 0
translate D SetFilter {Filter setzen}
translate D AddToFilter {Zum Filter hinzuf�gen}
translate D Swiss {Schweizer}
translate D Category {Kategorie}

# Opening report window menus:
menuText D OprepFile "Datei" 0
menuText D OprepFileText "Ausgabe in Textdatei..." 11
menuText D OprepFileHtml "Ausgabe in HTML-Datei..." 11
menuText D OprepFileLaTeX "Ausgabe in LaTeX-Datei..." 11
menuText D OprepFileOptions "Optionen..." 0
menuText D OprepFileClose "Berichtsfenster schlie�en" 0
menuText D OprepFavorites "Favoriten" 0
menuText D OprepFavoritesAdd "Bericht hinzuf�gen..." 8
menuText D OprepFavoritesEdit "Favoritenbericht editieren..." 0
menuText D OprepFavoritesGenerate "Berichte erzeugen..." 9

menuText D OprepHelp "Hilfe" 0
menuText D OprepHelpReport "Er�ffnungsbericht-Hilfe" 0
menuText D OprepHelpIndex "Index" 0

# Header search:
translate D HeaderSearch {Partiedatensuche}
translate D EndSideToMove {Wer ist beim Partieende am Zug?}
translate D GamesWithNoECO {Partien ohne ECO?}
translate D GameLength {Partiel�nge}
translate D FindGamesWith {Finde Partien mit den Markierungen (Flags)}
translate D StdStart {Standardausgangsposition}
translate D Promotions {Umwandlungen}
# ====== TODO To be translated ======
translate D UnderPromo {Under Prom.}
translate D Comments {Kommentare}
translate D Variations {Varianten}
translate D Annotations {Anmerkungen}
translate D DeleteFlag {L�schkennzeichen}
translate D WhiteOpFlag {Er�ffnung Wei�}
translate D BlackOpFlag {Er�ffnung Schwarz}
translate D MiddlegameFlag {Mittelspiel}
translate D EndgameFlag {Endspiel}
translate D NoveltyFlag {Neuerung}
translate D PawnFlag {Bauernstruktur}
translate D TacticsFlag {Taktik}
translate D QsideFlag {Damenfl�gel}
translate D KsideFlag {K�nigsfl�gel}
translate D BrilliancyFlag {Gl�nzend}
translate D BlunderFlag {Grober Fehler}
translate D UserFlag {Benutzer}
translate D PgnContains {PGN enth�lt Text}

# Game list window:
translate D GlistNumber {Nummer}
translate D GlistWhite {Wei�}
translate D GlistBlack {Schwarz}
translate D GlistWElo {W-Elo}
translate D GlistBElo {S-Elo}
translate D GlistEvent {Turnier}
translate D GlistSite {Ort}
translate D GlistRound {Runde}
translate D GlistDate {Datum}
translate D GlistYear {Jahr}
translate D GlistEventDate {Turnierdatum}
translate D GlistResult {Ergebnis}
translate D GlistLength {L�nge}
translate D GlistCountry {Land}
translate D GlistECO {ECO}
translate D GlistOpening {Er�ffnung}
translate D GlistEndMaterial {Endmaterial}
translate D GlistDeleted {Gel�scht}
translate D GlistFlags {Markierungen}
translate D GlistVariations {Varianten}
translate D GlistComments {Kommentare}
translate D GlistAnnos {Anmerkungen}
translate D GlistStart {Stellung}
translate D GlistGameNumber {Partie Nummer:}
translate D GlistFindText {Text finden}
translate D GlistMoveField {Verschieben}
translate D GlistEditField {Konfigurieren}
translate D GlistAddField {Hinzuf�gen}
translate D GlistDeleteField {L�schen}
translate D GlistColor {Farbe}
# ====== TODO To be translated ======
translate D GlistSort {Sort database}
translate D GlistRemoveThisGameFromFilter  {Partie}
translate D GlistRemoveGameAndAboveFromFilter  {Partie (und alle oberhalb)}
translate D GlistRemoveGameAndBelowFromFilter  {Partie (und alle darunter)}
translate D GlistDeleteGame {(Ent)L�sche Partie}
translate D GlistDeleteAllGames {L�sche alle Partien im Filter} 
translate D GlistUndeleteAllGames {Entl�sche alle Partien im Filter} 
# ====== TODO To be translated ======
translate D GlistAlignL {Align left}
# ====== TODO To be translated ======
translate D GlistAlignR {Align right}
# ====== TODO To be translated ======
translate D GlistAlignC {Align center}

# Maintenance window:
translate D DatabaseName {Datenbankname:}
translate D TypeIcon {Symbol}
translate D NumOfGames {Partien:}
translate D NumDeletedGames {Gel�schte Partien:}
translate D NumFilterGames {Partien im Filter:}
translate D YearRange {Jahr-Spanne:}
translate D RatingRange {Elo-Spanne:}
translate D Description {Beschreibung}
translate D Flag {Markierung}
translate D CustomFlags {Benutzerdefinierte Markierungen}
translate D DeleteCurrent {L�sche aktuelle Partie}
translate D DeleteFilter {L�sche Partien im Filter}
translate D DeleteAll {L�sche alle Partien}
translate D UndeleteCurrent {Aktuelle Partie wiederherstellen}
translate D UndeleteFilter {Partien im Filter wiederherstellen}
translate D UndeleteAll {Alle Partien wiederherstellen}
translate D DeleteTwins {L�sche Dubletten}
translate D MarkCurrent {Markiere aktuelle Partie}
translate D MarkFilter {Markiere Partien im Filter}
translate D MarkAll {Markiere alle Partien}
translate D UnmarkCurrent {Entmarkiere aktuelle Partie}
translate D UnmarkFilter {Entmarkiere Partien im Filter}
translate D UnmarkAll {Entmarkiere alle Partien}
translate D Spellchecking {Schreibkorrektur}
translate D MakeCorrections {Korrekturen machen}
translate D Ambiguous {Mehrdeutig}
# ====== TODO To be translated ======
translate D Surnames {Surnames}
translate D Players {Spieler}
translate D Events {Ereignis}
translate D Sites {Ort}
translate D Rounds {Runde}
translate D DatabaseOps {Datenbankoperationen}
translate D ReclassifyGames {Partien ECO-klassifizieren}
translate D CompactDatabase {Datenbank komprimieren}
translate D SortDatabase {Datenbank sortieren}
translate D AddEloRatings {ELO-Zahlen hinzuf�gen}
translate D AutoloadGame {Automatisch Partie Nr. laden}
translate D StripTags {PGN-Markierungen entfernen}
translate D StripTag {Markierung entfernen}
translate D CheckGames {Konsistenzpr�fung}
translate D Cleaner {Bereiniger}
translate D CleanerHelp {
Der Scid-Bereiniger wird f�r die aktuelle Datenbank alle Wartungsarbeiten ausf�hren, welche aus der unten stehenden Liste ausgew�hlt werden.

Aktuelle Einstellungen in den Men�s "ECO-Klassifikation" und "Dubletten l�schen" werden angewendet, falls diese Funktionen ausgew�hlt sind.}
translate D CleanerConfirm {
Ist der Bereiniger einmal gestartet, kann er nicht mehr unterbrochen werden!

Dies kann lange dauern, speziell bei gro�en Datenbanken, abh�ngig von den
ausgew�hlten Funktionen und deren Einstellungen.

Sind Sie sicher, da� Sie die ausgew�hlten Wartungsarbeiten starten m�chten?
}
# Twinchecker
translate D TwinCheckUndelete { umdrehen; "u" beide entl�schen)}
translate D TwinCheckprevPair {Vorheriges Paar}
translate D TwinChecknextPair {N�chstes Paar}
translate D TwinChecker {Scid: Dublettenpr�fer}
translate D TwinCheckTournament {Partien im Turnier:}
translate D TwinCheckNoTwin {Keine Dublette}
translate D TwinCheckNoTwinfound {Kein Dublette f�r diese Partie gefunden.

Um Dubletten anzuzeigen, bitte zuerst die Funktion "L�sche Dubletten" benutzen.}
translate D TwinCheckTag {Nutze Tag...}
translate D TwinCheckFound1 {Scid hat $result Dubletten gefunden}
translate D TwinCheckFound2 { und das Gel�scht-Flag gesetzt}
translate D TwinCheckNoDelete {In dieser Datenbank sind keine Partien zu l�schen.}
translate D TwinCriteria1 {Ihre Auswahlkriterien der Dublettensuche haben eine hohe Wahrscheinlichkeit auch Partien mit �hnlichen Z�gen als Dubletten zu erkennen.
}
translate D TwinCriteria2 {Es wird empfohlen, dass bei der Auswahl "Nein" f�r "gleiche Z�ge" die Auswahl "Ja" f�r Farbe, Ereignis, Ort, Runde, Jahr und Monat ausgew�hlt wird.

Wollen Sie fortsetzen und mit dieser Auswahl die Dubletten l�schen? }
translate D TwinCriteria3 {Es wird empfohlen, dass bei der Auswahl "Ja" f�r mindestens 2 der Parameter "gleicher Ort", "gleiche Runde" und "gleiches Jahr" gesetzt werden.

Wollen Sie fortsetzen und mit dieser Auswahl die Dubletten l�schen?}
translate D TwinCriteriaConfirm {Scid: Best�tigen der Dublettensuchparameter}
translate D TwinChangeTag "�ndern der folgenden Partie-Tags:\n\n"
translate D AllocRatingDescription "Mit dieser Funktion werden die ELO-Werte aus der Schreibkorrekturdatei den Partien hinzugef�gt. Der Wert wird hinzugef�gt, wenn ein/e Spieler/in keinen aktuellen Wert in der Partie besitzt, aber in der Korrekturdatei ein Wert f�r den Zeitraum der Partie vorhanden ist."
translate D RatingOverride "Existierende ELO-Werte �berschreiben?"
translate D AddRatings "Elo-Werte hinzuf�gen:"
translate D AddedRatings {Scid hat $r Elo-Werte in $g Partien hinzugef�gt.}

#Bookmark editor
translate D NewSubmenu "Neues Untermen�"

# Comment editor:
translate D AnnotationSymbols  {Kommentarzeichen:}
translate D Comment {Kommentar:}
translate D InsertMark {Markierung einf�gen}
translate D InsertMarkHelp {
Markierung einf�gen/l�schen: Farbe, Typ, Feld w�hlen.
Pfeil einf�gen/l�schen: Rechtsklick auf zwei Felder.
}

# Nag buttons in comment editor:
translate D GoodMove {Guter Zug}
translate D PoorMove {Schwacher Zug}
translate D ExcellentMove {Ausgezeichneter Zug}
translate D Blunder {Grober Fehler}
translate D InterestingMove {Interessanter Zug}
translate D DubiousMove {Zweifelhafter Zug}
translate D WhiteDecisiveAdvantage {Wei� hat Vorteil}
translate D BlackDecisiveAdvantage {Schwarz hat Vorteil}
translate D WhiteClearAdvantage {Wei� hat klaren Vorteil}
translate D BlackClearAdvantage {Schwarz hat klaren Vorteil}
translate D WhiteSlightAdvantage {Wei� hat leichten Vorteil}
translate D BlackSlightAdvantage {Schwarz hat leichten Vorteil}
translate D Equality {Gleiche Chancen}
translate D Unclear {Unklar}
translate D Diagram {Diagramm}

# Board search:
translate D BoardSearch {Brettsuchen}
translate D FilterOperation {Durchf�hrung am aktuellen Filter:}
translate D FilterAnd {UND (Beschr�nke Filter)}
translate D FilterOr {ODER (Zum Filter hinzuf�gen)}
translate D FilterIgnore {IGNORIERE (Filter zur�cksetzen)}
translate D SearchType {Suche nach Typ:}
translate D SearchBoardExact {Exakte Position (alle Steine auf gleichen Feldern)}
translate D SearchBoardPawns {Bauern (gleiche Figuren, alle Bauern auf gleichen Feldern)}
translate D SearchBoardFiles {Linien (gleiches Material, alle Bauern auf gleichen Linien)}
translate D SearchBoardAny {Material (gleiches Material, Bauern und Figuren beliebig)}
translate D SearchInRefDatabase { In folgender Datenbank suchen }
translate D LookInVars {Schaue in Varianten}

# Material search:
translate D MaterialSearch {Materialsuchen}
translate D Material {Material}
translate D Patterns {Muster}
translate D Zero {Null}
translate D Any {Irgendeine}
translate D CurrentBoard {Aktuelle Stellung}
translate D CommonEndings {Endspiele}
translate D CommonPatterns {Gleiche Muster}
translate D MaterialDiff {Materialdifferenz}
translate D squares {Felder}
translate D SameColor {Gleichfarbige}
translate D OppColor {Ungleichfarbige}
translate D Either {Beides}
translate D MoveNumberRange {Zugnummernbereich}
translate D MatchForAtLeast {Zutreffend f�r mindestens}
translate D HalfMoves {Halbz�ge}

# Common endings in material search:
translate D EndingPawns {Bauernendspiele}
translate D EndingRookVsPawns {Turm gegen Bauer(n)}
translate D EndingRookPawnVsRook {Turm und 1 Bauer gegen Turm}
translate D EndingRookPawnsVsRook {Turm und Bauer(n) gegen Turm}
translate D EndingRooks {Turm gegen Turm}
translate D EndingRooksPassedA {Turm gegen Turm mit Freibauer}
translate D EndingRooksDouble {Doppelturm-Endspiele}
translate D EndingBishops {L�ufer gegen L�ufer}
translate D EndingBishopVsKnight {L�ufer gegen Springer}
translate D EndingKnights {Springer gegen Springer}
translate D EndingQueens {Dame gegen Dame} ;# *** Damenendspiele !?
translate D EndingQueenPawnVsQueen {Dame und 1 Bauer gegen Dame}
translate D BishopPairVsKnightPair {Zwei L�ufer gegen zwei Springer im Mittelspiel}

# Common patterns in material search:
translate D PatternWhiteIQP {Wei�er isolierter Damenbauer}
translate D PatternWhiteIQPBreakE6 {Wei�er Isolani: Durchbruch d4-d5 gegen e6}
translate D PatternWhiteIQPBreakC6 {Wei�er Isolani: Durchbruch d4-d5 gegen c6}
translate D PatternBlackIQP {Schwarzer isolierter Damenbauer}
translate D PatternWhiteBlackIQP {Wei�er gegen schwarzer Damenbauerisolani}
translate D PatternCoupleC3D4 {Isoliertes Bauernpaar c3+d4}
translate D PatternHangingC5D5 {H�ngende Bauern c5 und d5 von Schwarz}
translate D PatternMaroczy {Maroczy-Zentrum (mit Bauern auf c4 und e4)}
translate D PatternRookSacC3 {Turmopfer auf c3}
translate D PatternKc1Kg8 {0-0-0 gegen 0-0 (Kc1 gegen Kg8)}
translate D PatternKg1Kc8 {0-0 gegen 0-0-0 (Kg1 gegen Kc8)}
translate D PatternLightFian {Wei�feldrige Fianchettos (L�ufer g2 gegen L�ufer b7)}
translate D PatternDarkFian {Schwarzfeldrige Fianchettos (L�ufer b2 gegen L�ufer g7)}
translate D PatternFourFian {Beiderseitiges Doppelfianchetto (L�ufer auf b2,g2,b7,g7)}

# Game saving:
translate D Today {Heute}
translate D ClassifyGame {Partie klassifizieren}

# Setup position:
translate D EmptyBoard {Brett leeren}
translate D InitialBoard {Initialisiere Brett}
translate D SideToMove {Zugrecht}
translate D MoveNumber {Zugnummer}
translate D Castling {Rochade}
translate D EnPassantFile {EnPassant-Linie}
translate D ClearFen {FEN l�schen}
translate D PasteFen {FEN einf�gen}
translate D SaveAndContinue {Speichern und weiter}
translate D DiscardChangesAndContinue {Verwerfen und weiter}
translate D GoBack {Zur�ck}

# Replace move dialog:
translate D ReplaceMove {Zug ersetzen}
translate D AddNewVar {Neue Variante}
translate D NewMainLine {Neue Hauptvariante}
translate D ReplaceMoveMessage {Hier existiert bereits ein Zug.

Sie k�nnen diesen Zug ersetzen - unter Verlust aller nachfolgender Z�ge - oder mit dem Zug eine neue Variante hinzuf�gen.

(Sie k�nnen diese Anzeige vermeiden, indem Sie die Option "Fragen vor Ersetzen" im Men� Optionen:Z�ge deaktivieren)}

# Make database read-only dialog:
translate D ReadOnlyDialog {Wenn Sie diese Datenbank mit Schreibschutz
versehen, sind keine �nderungen m�glich. Es k�nnen keine Partien gespeichert
oder ersetzt und keine L�schkennzeichen ge�ndert werden. Alle Sortierungen oder
ECO-Klassifikationsergebnisse sind nur tempor�r.

Sie k�nnen den Schreibschutz einfach entfernen, indem Sie die Datenbank
schlie�en und wieder �ffnen.
Wollen Sie diese Datenbank wirklich schreibsch�tzen?}

# Exit dialog:
translate D ExitDialog {M�chten Sie Scid beenden?}
# ====== TODO To be translated ======
translate D ClearGameDialog {This game has been altered.\nDo you wish to save it?}
translate D ExitUnsaved {Die folgenden Datenbanken haben ungesicherte Partie�nderungen. Wenn Sie jetzt beenden, gehen diese �nderungen verloren.}

# Import window:
translate D PasteCurrentGame {Aktuelle Partie einf�gen}
translate D ImportHelp1 {Eingeben oder Einf�gen einer Partie im PGN-Format in den oberen Rahmen.}
translate D ImportHelp2 {Hier werden Fehler beim Importieren angezeigt.}
translate D OverwriteExistingMoves {Bestehende Z�ge �berschreiben?}

# ECO Browser:
translate D ECOAllSections {alle ECO-Gruppen}
translate D ECOSection {ECO-Gruppe}
translate D ECOSummary {Zusammenfassung f�r}
translate D ECOFrequency {H�ufigkeit der Untercodes f�r}

# Opening Report:
translate D OprepTitle {Er�ffnungsbericht}
translate D OprepReport {Bericht}
translate D OprepGenerated {Erzeugt durch}
translate D OprepStatsHist {Statistiken und Geschichte}
translate D OprepStats {Statistiken}
translate D OprepStatAll {Alle Berichtspartien}
translate D OprepStatBoth {Beide Spieler}
translate D OprepStatSince {Nach}
translate D OprepOldest {�lteste Partien}
translate D OprepNewest {Neueste Partien}
translate D OprepPopular {Popularit�t}
translate D OprepFreqAll {H�ufigkeit in allen Jahren: }
translate D OprepFreq1   {im letzten Jahr:            }
translate D OprepFreq5   {der letzten  5 Jahre:       }
translate D OprepFreq10  {der letzten 10 Jahre:       }
translate D OprepEvery {Eine pro %u Partien}
translate D OprepUp {mehr als %u%s von allen Jahren}
translate D OprepDown {weniger als %u%s von allen Jahren}
translate D OprepSame {keine �nderung in allen Jahren}
translate D OprepMostFrequent {H�ufigste Spieler}
translate D OprepMostFrequentOpponents {H�ufigste Gegner}
translate D OprepRatingsPerf {ELO und Performance}
translate D OprepAvgPerf {Durchschnitts-ELO und Performance}
translate D OprepWRating {ELO Wei�}
translate D OprepBRating {ELO Schwarz}
translate D OprepWPerf {Performance Wei�}
translate D OprepBPerf {Performance Schwarz}
translate D OprepHighRating {Spiele mit dem h�chsten ELO-Durchschnitt}
translate D OprepTrends {Ergebnistrend}
translate D OprepResults {Ergebnis nach L�ngen und H�ufigkeiten}
translate D OprepLength {Partiel�nge}
translate D OprepFrequency {H�ufigkeit}
translate D OprepWWins {Wei�siege:    }
translate D OprepBWins {Schwarzsiege: }
translate D OprepDraws {Remis:        }
translate D OprepWholeDB {ganze Datenbank}
translate D OprepShortest {K�rzester Sieg}
translate D OprepMovesThemes {Z�ge und Themen}
translate D OprepMoveOrders {Zugfolgen zum Erreichen der Berichtsposition}
translate D OprepMoveOrdersOne \
  {Es gab nur eine Zugfolge zur erreichten Position:}
translate D OprepMoveOrdersAll \
  {Es gab %u Zugfolgen zur erreichten Position:}
translate D OprepMoveOrdersMany \
  {Es gab  %u Zugfolgen zur erreichten Position. Die ersten %u sind:}
translate D OprepMovesFrom {Z�ge ab der Berichtsposition}
translate D OprepMostFrequentEcoCodes {H�ufigste ECO-Codes}
translate D OprepThemes {Themen}
translate D OprepThemeDescription {H�ufigkeit der Themen in den ersten %u Z�gen jeder Partie}
translate D OprepThemeSameCastling {Gleichseitige Rochaden}
translate D OprepThemeOppCastling {Verschiedenseitige Rochaden}
translate D OprepThemeNoCastling {Beide Seiten unrochiert}
translate D OprepThemeKPawnStorm {Bauernsturm auf K�nig}
translate D OprepThemeQueenswap {Damen getauscht}
translate D OprepThemeWIQP {Wei�er isolierter Damenbauer}
translate D OprepThemeBIQP {Schwarzer isolierter Damenbauer}
translate D OprepThemeWP567 {Wei�er Bauer auf Reihe 5/6/7}
translate D OprepThemeBP234 {Schwarzer Bauer auf Reihe 2/3/4}
translate D OprepThemeOpenCDE {Offene c/d/e-Linie}
translate D OprepTheme1BishopPair {Eine Seite hat L�uferpaar}
translate D OprepEndgames {Endspiele}
translate D OprepReportGames {Berichtspartien}
translate D OprepAllGames {Alle Partien}
translate D OprepEndClass {Materialklassifikation von Endspielstellungen}
translate D OprepTheoryTable {Theorietabelle}
translate D OprepTableComment {Erzeugt aus %u Partien mit h�chster ELO-Zahl.}
translate D OprepExtraMoves {Zus�tzliche Z�ge in Anmerkungen zur Theorietabelle}
translate D OprepMaxGames {Maximum an Partien in Theorietabelle}
translate D OprepViewHTML {Zeige HTML}
translate D OprepViewLaTeX {Zeige LaTeX}

# Player Report:
translate D PReportTitle {Spielerbericht}
translate D PReportColorWhite {mit den wei�en Steinen}
translate D PReportColorBlack {mit den schwarzen Steinen}
# ====== TODO To be translated ======
translate D PReportBeginning {Beginning with}
translate D PReportMoves {nach %s}
translate D PReportOpenings {Er�ffnungen}
translate D PReportClipbase {Leere Zwischenablage und kopiere gefundene Spiele}

# Piece Tracker window:
translate D TrackerSelectSingle {Linke Maustaste w�hlt diese Figur.}
translate D TrackerSelectPair \
  {Linke Maustaste w�hlt diese Figur; rechte Maustaste w�hlt das Figurenpaar.}
translate D TrackerSelectPawn \
  {Linke Maustaste w�hlt diesen Bauern; rechte Maustaste w�hlt alle 8 Bauern.}
translate D TrackerStat {Statistik}
translate D TrackerGames {% der Partien mit Zug auf das Feld}
translate D TrackerTime {% der Zeit auf jedem Feld}
translate D TrackerMoves {Z�ge}
translate D TrackerMovesStart \
  {Zugnummer, ab der die Verteilungsberechnung beginnen soll.}
translate D TrackerMovesStop \
  {Zugnummer, wo die Verteilungsberechnung enden soll.}

# Game selection dialogs:
translate D SelectAllGames {Alle Spiele in der Datenbank}
translate D SelectFilterGames {Nur Spiele im Filter}
translate D SelectTournamentGames {Nur Spiele des aktuellen Turniers}
translate D SelectOlderGames {Nur �ltere Spiele}

# Delete Twins window:
translate D TwinsNote {Damit zwei Spiele Dubletten sind, m�ssen diese mindestens die beiden selben Spieler haben und die folgenden Kriterien, die Sie ausw�hlen k�nnen, erf�llen. Wenn zwei Dubletten gefunden werden, so wird die k�rzere der beiden Spiele gel�scht. Tip: am besten f�hrt man erst eine Schreibkorrektur durch, da dadurch das Finden von Dubletten verbessert wird.}
translate D TwinsCriteria {Kriterium: Dubletten m�ssen haben ...}
translate D TwinsWhich {�berpr�fe, welche Spiele}
translate D TwinsColors {die gleichen Spielerfarben?}
translate D TwinsEvent {das gleich Ereignis?}
translate D TwinsSite {den gleichen Ort?}
translate D TwinsRound {die gleiche Runde?}
translate D TwinsYear {das gleiche Jahr?}
translate D TwinsMonth {den gleichen Monat?}
translate D TwinsDay {den gleichen Tag?}
translate D TwinsResult {das gleiche Ergebnis?}
translate D TwinsECO {den gleichen ECO-Code?}
translate D TwinsMoves {die gleichen Z�ge?}
translate D TwinsPlayers {Vergleich Spielernamen}
translate D TwinsPlayersExact {Exakte Treffer}
translate D TwinsPlayersPrefix {Nur erste 4 Buchstaben}
translate D TwinsWhen {Beim L�schen der Dubletten}
translate D TwinsSkipShort {Partien unter 5 Z�gen ignorieren?}
translate D TwinsUndelete {Zuerst alle Partien entl�schen?}
translate D TwinsSetFilter {Filter auf Dubletten setzen?}
translate D TwinsComments {Spiele mit Kommentar immer behalten?}
translate D TwinsVars {Spiele mit Varianten immer behalten?}
translate D TwinsDeleteWhich {Welche Partie l�schen:}
translate D TwinsDeleteShorter {K�rzere Partie}
translate D TwinsDeleteOlder {Kleinere Partienummer}
translate D TwinsDeleteNewer {Gr��ere Partienummer}
translate D TwinsDelete {L�sche Spiele}

# Name editor window:
translate D NameEditType {Namen �ndern von}
translate D NameEditSelect {Welche Spiele sollen ge�ndert werden?}
translate D NameEditReplace {Ersetze}
translate D NameEditWith {durch}
translate D NameEditMatches {Entsprechungen: Dr�cke Strg+1 bis Strg+9 zum Ausw�hlen}
translate D CheckGamesWhich {Konsistenzpr�fung}
translate D CheckAll {Alle Partien}
translate D CheckSelectFilterGames {Partien im Filter}

# Classify window:
translate D Classify {Klassifiziere}
translate D ClassifyWhich {ECO-klassifizieren}
translate D ClassifyAll {Alle Spiele (�berschreibe alte ECO-Codes)}
translate D ClassifyYear {Alle Spiele  aus dem letzten Jahr}
translate D ClassifyMonth {Alle Spiele aus dem letzten Monat}
translate D ClassifyNew {Nur Spiele ohne ECO-Code}
translate D ClassifyCodes {Verwende}
translate D ClassifyBasic {Normale ECO-Codes ("B12", ...)}
translate D ClassifyExtended {ECO-Codes mit Scid-Erweiterung ("B12j", ...)}

# Compaction:
translate D NameFile {Namendatenbank}
translate D GameFile {Partiendatenbank}
translate D Names {Namen}
translate D Unused {Unbenutzt}
translate D SizeKb {Gr��e (kB)}
translate D CurrentState {Momentaner Stand}
translate D AfterCompaction {nach Kompression}
translate D CompactNames {Komprimiere Namen}
translate D CompactGames {Komprimiere Partien}
translate D NoUnusedNames "Es gibt keine unbenutzen Namen, die Namensdatei ist vollst�ndig komprimiert."
translate D NoUnusedGames "Die Partiedatei ist vollst�ndig komprimiert."
translate D NameFileCompacted {Die Namesdatei der Datenbank "[file tail [sc_base filename]]" wurde komprimiert.}
translate D GameFileCompacted {Die Partiedatei der Datenbank "[file tail [sc_base filename]]" wurde komprimiert.}

# Sorting:
translate D SortCriteria {Kriterium}
translate D AddCriteria {F�ge Sortierkriterium hinzu}
translate D CommonSorts {�bliche Sortierkriterien}
translate D Sort {Sortiere}

# Exporting:
translate D AddToExistingFile {Anh�ngen an eine bestehende Datei?}
translate D ExportComments {Kommentare exportieren?}
translate D ExportVariations {Varianten exportieren?}
translate D IndentComments {Kommentare einr�cken?}
translate D IndentVariations {Varianten einr�cken?}
translate D ExportColumnStyle {Tabellarisch (ein Zug pro Zeile)?}
translate D ExportSymbolStyle {Symbolische Notation:}
translate D ExportStripMarks \
  {Felder-/Pfeilemarkierzeichen aus den Kommentaren entfernen?}

# Goto game/move dialogs:
translate D LoadGameNumber {Geben Sie die zu ladende Spielnr. ein:}
translate D GotoMoveNumber {Gehe zu Zugnr.:}

# Copy games dialog:
translate D CopyGames {Kopiere Spiele}
translate D CopyConfirm {
 M�chten sie wirklich die [::utils::thousands $nGamesToCopy]
 Spiele aus dem Filter
 in der Datenbank "$fromName"
 in die Datenbank "$targetName"
 kopieren?
}
translate D CopyErr {Kann Spiele nicht kopieren}
translate D CopyErrSource {Die Quelldatenbank}
translate D CopyErrTarget {Die Zieldatenbank}
translate D CopyErrNoGames {hat keine Spiele im Filter}
translate D CopyErrReadOnly {ist schreibgesch�tzt}
translate D CopyErrNotOpen {ist nicht ge�ffnet}

# Colors:
translate D LightSquares {Helle Felder}
translate D DarkSquares {Dunkle Felder}
translate D SelectedSquares {Ausgew�hlte Felder}
translate D SuggestedSquares {Zugvorschlagsfelder}
# todo
translate D Grid {Grid}
translate D Previous {Vorherige}
translate D WhitePieces {Wei�e Steine}
translate D BlackPieces {Schwarze Steine}
translate D WhiteBorder {Wei�e Umrandung}
translate D BlackBorder {Schwarze Umrandung}
translate D ArrowMain   {Main Arrow}
translate D ArrowVar    {Var Arrows}

# Novelty window:
translate D FindNovelty {Finde Neuerung}
translate D Novelty {Neuerung}
translate D NoveltyInterrupt {Neuerungensuche abgebrochen}
translate D NoveltyNone {In dieser Partie wurde keine Neuerung gefunden}
translate D NoveltyHelp {
Scid wird den ersten Zug aus der aktuellen Partie finden, welcher zu einer Position f�hrt, die nicht in der gew�hlten Datenbank oder in dem ECO-Er�ffnungsbuch enthalten ist.
}

# Sounds configuration:
translate D SoundsFolder {Sounddateien-Verzeichnis}
translate D SoundsFolderHelp {Das Verzeichnis sollte enthalten: King.wav, a.wav, 1.wav etc.}
translate D SoundsAnnounceOptions {Optionen f�r Zugank�ndigung}
	# *** Ist das so gemeint? Ich kann's nicht ausprobieren (keine Soundkarte...).
translate D SoundsAnnounceNew {K�ndige neue Z�ge an, wenn sie ausgef�hrt werden}
translate D SoundsAnnounceForward {K�nde Zug an beim Vorw�rtspielen}
translate D SoundsAnnounceBack {K�ndige Zug an beim Zur�ckgehen}

# Upgrading databases:
translate D Upgrading {Upgrading}
translate D ConfirmOpenNew {
Dies ist eine Datenbank im alten (Scid 2.x) Format, die nicht in Scid 3.x
ge�ffnet werden kann. Aber eine Version im neuen Format wurde schon erstellt.

Wollen Sie die Version der Datenbank im neuen Format �ffnen?
}
translate D ConfirmUpgrade {
Dies ist eine Datenbank im alten (Scid 2.x) Format. Vor der Verwendung in
Scid 3 mu� eine Version im neuen Format der Datenbank erstellt werden.

Beim Erstellen der neuen Version der Datenbank bleiben die Dateien der alten Version erhalten.

Dieser Vorgang kann eine Zeitlang dauern, mu� aber nur einmal durchgef�hrt
werden. Sie k�nnen jederzeit abbrechen, wenn es Ihnen zu lange dauert.

Soll das Erstellen der Datenbank im neuen Format jetzt durchgef�hrt werden?
}

# Recent files options:
translate D RecentFilesMenu {Anzahl der aktuellen Dateien im Dateimen�}
translate D RecentFilesExtra {Anzahl der aktuellen Dateien im zus�tzlichen Untermen�}

# My Player Names options:
translate D MyPlayerNamesDescription {
Geben Sie unten eine Liste der bevorzugten Spielernamen ein, ein Name pro Zeile. Platzhalterzeichen (z.B. "?" f�r ein beliebiges einzelnes Zeichen, "*" f�r jede beliebige Folge von Zeichen) sind erlaubt.

Jedesmal, wenn ein Spiel mit einem aufgelisteten Spielernamen geladen wird, wird das Schachbrett im Hauptfenster erforderlichenfalls gedreht, um das Spiel aus der Sicht des betreffenden Spielers zu zeigen.
}
translate D showblunderexists {Enginefehler anzeigen}
translate D showblundervalue {Fehlerwert anzeigen}
translate D showscore {Wert anzeigen}
translate D coachgame {Coach Partie}
translate D configurecoachgame {Trainingspartie konfigurieren}
translate D configuregame {Spiel konfigurieren}
translate D Phalanxengine {Phalanx engine}
translate D Coachengine {Coach Engine}
translate D difficulty {Schwierigkeit}
translate D hard {schwer}
translate D easy {leicht}
translate D Playwith {Spiel mit}
translate D white {Wei�}
translate D black {Schwarz}
translate D both {beide}
translate D Play {Spielen}
translate D Noblunder {Kein Fehler}
translate D blunder {Fehler}
translate D Noinfo {-- Keine Info --}
translate D moveblunderthreshold {fehlerhafter Zug, wenn Verlust gr��er als}
translate D limitanalysis {Analysezeit der Engine begrenzen}
translate D seconds {Sekunden}
translate D Abort {Abbrechen}
translate D Resume {Fortfahren}
translate D Restart {Neustart}
translate D OutOfOpening {Ende der Er�ffnung}
# TODO
translate D NotFollowedLine {You did not follow the line}
translate D DoYouWantContinue {M�chten sie fortfahren?}
translate D CoachIsWatching {Coach schaut zu}
translate D Ponder {Berechnen im Hintergrund}
translate D LimitELO {St�rke begrenzen (ELO)}
translate D DubiousMovePlayedTakeBack {Zweifelhafter Zug gespielt, wollen Sie ihn zur�cknehmen?}
translate D WeakMovePlayedTakeBack {Schacher Zug gespielt, wollen Sie ihn zur�cknehmen?}
translate D BadMovePlayedTakeBack {Schlechter Zug gespielt, wollen Sie ihn zur�cknehmen?}
translate D Iresign {Ich gebe auf}
translate D yourmoveisnotgood {Ihr Zug ist nicht gut}
translate D EndOfVar {Variantenende}
translate D Openingtrainer {Er�ffnungstrainer}
translate D DisplayCM {Kandidatenz�ge anzeigen}
translate D DisplayCMValue {Wert der Kandidatenz�ge anzeigen}
translate D DisplayOpeningStats {Statistik anzeigen}
translate D ShowReport {Bericht anzeigen}
translate D NumberOfGoodMovesPlayed {gute Z�ge gespielt}
translate D NumberOfDubiousMovesPlayed {zweischneidige Z�ge gespielt}
translate D NumberOfTimesPositionEncountered {Wiederholungen der Position}
translate D PlayerBestMove  {Nur beste Z�ge erlauben}
translate D OpponentBestMove {Gegner spielt besten Zug}
translate D OnlyFlaggedLines {Nur markierte Linien}
translate D resetStats {Statistik zur�cksetzen}
translate D Movesloaded {Z�ge geladen}
translate D PositionsNotPlayed {nicht gespielte Positionen}
translate D PositionsPlayed {gespielte Positionen}
translate D Success {Erfolgreich}
translate D DubiousMoves {Zweifelhafte Z�ge}
translate D ConfigureTactics {Taktik konfigurieren}
translate D ResetScores {Punkte zur�cksetzten}
translate D LoadingBase {Lade Datenbank}
translate D Tactics {Taktik}
translate D ShowSolution {L�sung zeigen}
translate D Next {N�chste}
translate D ResettingScore {Punkte zur�cksetzen}
translate D LoadingGame {Lade Partie}
translate D MateFound {Matt gefunden}
translate D BestSolutionNotFound {Beste L�sung NICHT gefunden!}
translate D MateNotFound {Matt nicht gefunden}
translate D ShorterMateExists {K�rzeres Matt existiert}
translate D ScorePlayed {Bewertung gepielt}
translate D Expected {erwarted}
translate D ChooseTrainingBase {Trainingsdatenbank ausw�hlen}
translate D Thinking {Denke...}
translate D AnalyzeDone {Analyse beendet}
translate D WinWonGame {Gewinne gewonnene Partie}
translate D Lines {Variantenzahl}
translate D ConfigureUCIengine {UCI Engine konfigurieren}
translate D SpecificOpening {Ausgew�hlte Er�ffnung}
translate D StartNewGame {Neue Partie}
translate D FixedLevel {Festgelegte St�rke}
translate D Opening {Er�ffnung}
translate D RandomLevel {Zufallsniveau}
translate D StartFromCurrentPosition {Von aktueller Position starten}
translate D FixedDepth {Feste Tiefe}
translate D Nodes {Knoten} 
translate D Depth {Tiefe}
translate D Time {Zeit} 
translate D SecondsPerMove {Sekunden pro Zug}
# ====== TODO To be translated ======
translate D DepthPerMove {Depth per move}
# ====== TODO To be translated ======
translate D MoveControl {Move Control}
translate D TimeLabel {Zeit pro Zug}
# ====== TODO To be translated ======
translate D AddVars {Add Variations}
# ====== TODO To be translated ======
translate D AddScores {Add Score}
translate D Engine {Engine}
translate D TimeMode {Zeitmodus}
translate D TimeBonus {Zeit + Bonus}
translate D TimeMin {min}
translate D TimeSec {s}
translate D AllExercisesDone {Alle �bungen gemacht}
translate D MoveOutOfBook {Zug nicht mehr im Buch}
translate D LastBookMove {Letzter Buchzug}
translate D AnnotateSeveralGames {Kommentiere mehrere Partien\nvon aktueller bis:}
translate D FindOpeningErrors {Er�ffnungsfehler finden}
translate D MarkTacticalExercises {Taktische �bungen markieren}
translate D UseBook {Buch benutzen}
translate D MultiPV {Multivariantenmodus}
translate D Hash {Hash Speicher}
translate D OwnBook {Engine Buch verwenden}
translate D BookFile {Er�ffnungsbuch}
translate D AnnotateVariations {Varianten kommentieren}
translate D ShortAnnotations {Kurze Kommentare}
translate D addAnnotatorTag {Kommentar Tag hinzuf�gen}
translate D AddScoreToShortAnnotations {Bewertung hinzuf�gen}
translate D Export {Export}
translate D BookPartiallyLoaded {Buch teilweise geladen}
# ====== TODO To be translated ======
translate D AddLine {Add Line}
# ====== TODO To be translated ======
translate D RemLine {Remove Line}
translate D Calvar {Training: Variantenberechnung}
translate D ConfigureCalvar {Konfiguration}
translate D Reti {Reti}
translate D English {Englische Er�ffnung}
translate D d4Nf6Miscellaneous {1.d4 Nf6 Verschiedene}
translate D Trompowsky {Trompowsky}
translate D Budapest {Budapest}
translate D OldIndian {Altindische Verteidigung}
translate D BenkoGambit {Benko Gambit}
translate D ModernBenoni {Moderne/Benoni-Verteidigung}
translate D DutchDefence {Holl�ndische Verteidigung}
translate D Scandinavian {Skandinavische Verteidigung}
translate D AlekhineDefence {Aljechin Verteidigung}
translate D Pirc {Pirc-Verteidigung}
translate D CaroKann {Caro-Kann}
translate D CaroKannAdvance {Caro-Kann Vorsto�variante}
translate D Sicilian {Sizilianisch}
translate D SicilianAlapin {Sizilianisch, Alapin Variante}
translate D SicilianClosed {Geschlossene Sizilianische Verteidigung}
translate D SicilianRauzer {Sizilianisch, Rauzer Angriff}
translate D SicilianDragon {Sizilianisch, Drachenvariante}
translate D SicilianScheveningen {Sizilianisch, Scheveningen}
translate D SicilianNajdorf {Sizilianisch, Najdorf}
translate D OpenGame {Offene Spiele}
translate D Vienna {Wiener Verteidigung}
translate D KingsGambit {K�nigsgambit}
translate D RussianGame {Russische Verteidigung}
translate D ItalianTwoKnights {Italienische Er�ffnung}
translate D Spanish {Spanisch Partie}
translate D SpanishExchange {Spanisch, Abtauschvariante}
translate D SpanishOpen {Spanisch, offene Systeme}
translate D SpanishClosed {Spanisch, geschlossene Systeme}
translate D FrenchDefence {Franz�sische Verteidigung}
translate D FrenchAdvance {Franz�sisch, Vorsto�variante}
translate D FrenchTarrasch {Franz�sisch, Tarrasch}
translate D FrenchWinawer {Franz�sisch, Winawer}
translate D FrenchExchange {Franz�sisch, Abtauschvariante}
translate D QueensPawn {Damenbauernspiel}
translate D Slav {Slavisch}
translate D QGA {Angenommenes Damengambit}
translate D QGD {Abgelehntes Damengambit}
translate D QGDExchange {Abgelehntes Damengambit, Abtauschvariante}
translate D SemiSlav {Semi-Slawisch}
translate D QGDwithBg5 {Abgelehntes Damengambit mit Lg5}
translate D QGDOrthodox {Abgelehntes Damengambit, Orthodoxe Variante}
translate D Grunfeld {Gr�nfeld-Verteidigung}
translate D GrunfeldExchange {Gr�nfeld, Abtauschvariante}
translate D GrunfeldRussian {Gr�nfeld-Verteidigung, Russische Variante}
translate D Catalan {Katalanische Verteidigung}
translate D CatalanOpen {Katalanisch, offen}
translate D CatalanClosed {Katalanisch, geschlossen}
translate D QueensIndian {Dameninsche Verteidigung}
translate D NimzoIndian {Nimzoindische Verteidigung}
translate D NimzoIndianClassical {Nimzoindisch, Klassische Variante}
translate D NimzoIndianRubinstein {Nimzoinsisch, Rubinstein}
translate D KingsIndian {K�nigsindische Verteidigung}
translate D KingsIndianSamisch {K�nigsinsisch, S�misch}
translate D KingsIndianMainLine {K�nigsinsisch, Hauptvariante}

translate D ConfigureFics {FICS Konfigurieren}
translate D FICSLogin {Login}
translate D FICSGuest {Gast Login}
translate D FICSServerPort {Serverport}
translate D FICSServerAddress {IP Adresse}
translate D FICSRefresh {Aktualisieren}
translate D FICSTimeseal {Timeseal}
translate D FICSTimesealPort {Timeseal Port}
translate D FICSSilence {Konsolenfilter}
translate D FICSOffers {Herausforderungen}
translate D FICSGames {laufende Partien}
translate D FICSFindOpponent {Gegner suchen}
translate D FICSTakeback {Zur�cknehmen}
translate D FICSTakeback2 {2 zur�cknehmen}
translate D FICSInitTime {Zeit (min)}
translate D FICSIncrement {Inkrement (s)}
translate D FICSRatedGame {Wertungspartie}
translate D FICSAutoColour {automatisch}
translate D FICSManualConfirm {manuell best�tigen}
translate D FICSFilterFormula {Filterformel anwenden}
translate D FICSIssueSeek {Partie anbieten}
translate D FICSAccept {Annehmen}
translate D FICSDecline {Ablehnen}
translate D FICSColour {Seite w�hlen:}
translate D FICSSend {senden}
translate D FICSConnect {Verbinden}
# ====== TODO To be translated ======
translate D FICSShouts {Shouts}
# ====== TODO To be translated ======
translate D FICSTells {Tells}
translate D FICSOpponent {Gegner Info}
translate D FICSInfo {Info}
translate D FICSDraw {Remis anbieten}
translate D FICSRematch {Revanche}
translate D FICSQuit {FICS beenden}
# ====== TODO To be translated ======
translate D FICSCensor {Censor}

# Correspondence Chess Dialogs:
translate D CCDlgConfigureWindowTitle {Einstellungen f�r Fernschach}
translate D CCDlgCGeneraloptions {Allgemeine Einstellungen}
translate D CCDlgDefaultDB {Standarddatenbank:}
translate D CCDlgInbox {Posteingang (Pfad):}
translate D CCDlgOutbox {Postausgang (Pfad):}
translate D CCDlgXfcc {Xfcc Einstellungen:}
translate D CCDlgExternalProtocol {Externe Protokolle (Xfcc)}
translate D CCDlgFetchTool {Hilfsprogramm zum Abholen:}
translate D CCDlgSendTool {Hilfsprogramm zum Senden:}
translate D CCDlgEmailCommunication {E-Mail Kommunikation}
translate D CCDlgMailPrg {E-Mail Programm:}
translate D CCDlgBCCAddr {Adresse f�r Ausgangskopie:}
translate D CCDlgMailerMode {Modus:}
translate D CCDlgThunderbirdEg {z.B. Thunderbird, Mozilla Mail, Icedove...}
translate D CCDlgMailUrlEg {z.B. Evolution}
translate D CCDlgClawsEg {z.B. Sylpheed Claws}
translate D CCDlgmailxEg {z.B. mailx, mutt, nail...}
translate D CCDlgAttachementPar {Parameter f�r Anhang:}
translate D CCDlgInternalXfcc {Interne Xfcc-Unterst�tzung verwenden}
translate D CCDlgConfirmXfcc {Z�ge best�tigen}
translate D CCDlgSubjectPar {Parameter f�r Betreff:}
translate D CCDlgDeleteBoxes {Leeren des Postein- und Ausgangs}
translate D CCDlgDeleteBoxesText {Wollen Sie wirklich Ihren Postein- und Ausgang leeren?\nDies erfordert ein erneutes Synchronisieren zum den aktuellen Zustand Ihrer Partien anzuzeigen.}
translate D CCDlgConfirmMove {Zug best�tigen}
translate D CCDlgConfirmMoveText {Durch best�tigen wird folgender Zug und Kommentar an den Server �bertragen:}
translate D CCDlgDBGameToLong {Inkonsistente Hauptvariante}
translate D CCDlgDBGameToLongError {Die Hauptvariante dieser Partie in der Datenbank enth�lt mehr Z�ge als in der Partie tats�chlich gespielt. Sofern die Partie im Posteingang vollst�ndig und aktuell ist (z. B. direkt nach einer Synchronisation) mu� die Hauptvariante in der Datenbank ensprechend gek�rzt werden. Der letzte Zug in der Partie ist Nr. \n}
translate D CCDlgStartEmail {Neue E-Mail Partie}
translate D CCDlgYourName {Ihr Name:}
translate D CCDlgYourMail {Ihre E-Mail Adresse:}
translate D CCDlgOpponentName {Name des Gegners:}
translate D CCDlgOpponentMail {E-Mail Adresse des Gegners:}
translate D CCDlgGameID {Partiekennung (eineindeutig):}
translate D CCDlgTitNoOutbox {Scid: Fernschach Postausgang}
translate D CCDlgTitNoInbox {Scid: Fernschach Posteingang}
translate D CCDlgTitNoGames {Scid: Keine Fernschachpartien}
translate D CCErrInboxDir {Der Posteingang f�r Fernschachpartien unter:}
translate D CCErrOutboxDir {Der Postausgang f�r Fernschachpartien unter:}
translate D CCErrDirNotUsable {existiert nicht oder ist nicht benutzbar!\nBitte �berpr�fen und die Einstellungen korrigieren.}
translate D CCErrNoGames {enth�lt keine Partien!\nBitte sychronisieren Sie zun�chst.}
translate D CCDlgTitNoCCDB {Scid: Keine Fernschach-Datenbank}
translate D CCErrNoCCDB {Es wurde keine Datenbank vom Typ 'Fernschach' ge�ffnet. Bitte �ffen Sie eine solche bevor Sie Funktionen des Fernschachmoduls benutzen.}
translate D CCFetchBtn {Partien vom Server abholen\nund Inbox bearbeiten}
translate D CCPrevBtn {Vorhergehende Partie}
translate D CCNextBtn {N�chste Partie}
translate D CCSendBtn {Zug versenden}
translate D CCEmptyBtn {Postein- und ausgang leeren}
translate D CCHelpBtn {Hilfe zu den Icons und Statusindikatoren\nF�r allgemeine Hilfe bitte F1!}
translate D CCDlgServerName {Server Name:}
translate D CCDlgLoginName  {Login Name:}
translate D CCDlgPassword   {Passwort:}
translate D CCDlgURL        {Xfcc-URL:}
translate D CCDlgRatingType {Wertungszahl:}
translate D CCDlgDuplicateGame {Nichteindeutige Partie}
translate D CCDlgDuplicateGameError {Diese Partie existiert mehr als einmal in der Datenbank. Bitte l�schen Sie alle Doubletten und komprimieren Sie die Datenbank (Datei/Wartung/Datenbank komprimieren).}
translate D CCDlgSortOption {Sortierung:}
translate D CCDlgListOnlyOwnMove {Partien mit anh�ngigen Z�gen}
translate D CCOrderClassicTxt {Ort, Turnier, Runde, Ergebnis, Wei�, Schwarz}
translate D CCOrderMyTimeTxt {Eigene Bedenkzeit}
translate D CCOrderTimePerMoveTxt {Zeit pro Zug bis zur n�chsten Zeitkontrolle}
translate D CCOrderStartDate {Startdatum}
translate D CCOrderOppTimeTxt {Gegnerische Bedenkzeit}
translate D CCDlgConfigRelay {Partien auf iccf-webchess beobachten}
translate D CCDlgConfigRelayHelp {Besuchen Sie http://www.iccf-webchess.com und lassen Sie die Partie anzeigen, die Sie beobachten wollen. Wenn das Brett sichtbar ist bitte die Adresse aus dem Browser in untenstehende Liste kopieren. Nur eine URL pro Zeile!\nBeispiel: http://www.iccf-webchess.com/MakeAMove.aspx?id=266452}


translate D ExtHWConfigConnection {Hardware Konfigurieren}
translate D ExtHWPort {Schnittstelle}
translate D ExtHWEngineCmd {Engine Kommando}
translate D ExtHWEngineParam {Engine Parameter}
translate D ExtHWShowButton {Knopf in Werzeugleiste anzeigen}
translate D ExtHWHardware {Hardware}
translate D ExtHWNovag {Novag Citrine}
translate D ExtHWInputEngine {Input Engine}
translate D ExtHWNoBoard {Kein Brett verbunden}
translate D IEConsole {Input Engine Konsole}
translate D IESending {Sende Z�ge f�r}
translate D IESynchronise {Synchronisieren}
translate D IERotate  {Brett drehen}
translate D IEUnableToStart {Input Engine konnte nicht gestartet werden:}
translate D DoneWithPosition {Positionsbearbeitung beendet}
translate D Board {Brett}
translate D showGameInfo {Partieinformation anzeigen}
translate D autoResizeBoard {Brettgr��e automatisch berechnen}
translate D DockTop {Nach oben}
translate D DockBottom {Nach unten}
translate D DockLeft {Nach links}
translate D DockRight {Nach rechts}
translate D Undock {Fenster befreien}
translate D ChangeIcon {Symbol �ndern}
# ====== TODO To be translated ======
translate D More {More}

# Drag & Drop
translate D CannotOpenUri {Die folgenden URI k�nnen nicht ge�ffnet werden:}
translate D InvalidUri {Der Drop-Inhalt ist keine g�ltige URI-Liste.}
translate D UriRejected	{Die folgenden Dateien wurden zur�ckgewiesen:}
translate D UriRejectedDetail {Nur die aufgelisteten Dateitypen k�nnen gehandhabt werden:}
translate D EmptyUriList {Der Drop-Inhalt ist leer.}
translate D SelectionOwnerDidntRespond {Zeit�berschreitung w�hrend der Drop-Aktion: der Eigent�mer des Drop-Inhalts antwortete nicht.}

}

##########
#
# ECO Opening name translations:

translateECO D {
  Accelerated {, Beschleunigt}
  {: Accelerated} Beschleunigt
  Accepted {, Angenommen}
  {: Accepted} Angenommen
  Advance Vorsto�
  {as Black} {mit Schwarz}
  Attack Angriff
  Bishop L�ufer
  Bishop's L�ufer
  Classical Klassisch
  Closed Geschlossen
  {Closed System} {Geschlossenes System}
  Counterattack Gegenangriff
  Countergambit Gegengambit
  Declined {, Abgelehnt}
  Defence Verteidigung
  deferred verz�gert
  Deferred {, verz�gert}
  Early Fr�he
  Exchange Abtausch
  Game Partie
  Improved verbessert
  King's K�nigs
  Knight Springer
  Line Variante
  {Main Line} Hauptvariante
  Open Offen
  Opening Er�ffnung
  Queen's Damen
  Queenswap Damentausch
  Symmetrical Symmetrisch
  Variation Variante
  Wing Fl�gel
  with mit
  without ohne

  Alekhine Aljechin
  Averbakh Awerbach
  Botvinnik Botwinnik
  Chigorin Tschigorin
  Polugaevsky Polugajewski
  Rauzer Rauser
  Sveshnikov Sweschnikow

  Austrian �sterreichisch
  Berlin Berliner
  Bremen Bremer
  Catalan Katalanisch
  Czech Tschechisch
  Dutch Holl�ndisch
  English Englisch
  French Franz�sisch
  Hungarian Ungarisch
  Indian Indisch
  Italian Italienisch
  Latvian Lettisch
  Meran Meraner
  Moscow Moskau
  Polish Polnisch
  Prague Prager
  Russian Russisch
  Scandinavian Skandinavisch
  Scheveningen Scheveninger
  Scotch Schottisch
  Sicilian Sizilianisch
  Slav Slawisch
  Spanish Spanisch
  Swedish Schwedisch
  Swiss Schweizer
  Vienna Wiener
  Yugoslav Jugoslawisch

  {Accelerated Fianchetto} {Beschleunigtes Fianchetto}
  {Accelerated Pterodactyl} {Beschleunigter Pterodactylus}
  {Alekhine Defence} Aljechin-Verteidigung
  {Alekhine Variation} Aljechin-Variante
  {Alekhine: S�misch Attack} {Aljechin: Wiener System (S�misch-Angriff)}
  {Anderssen Opening} Anderssen-Er�ffnung
  {Anti-King's Indian} Anti-K�nigsindisch
  {Austrian Attack} {�sterreichischer Angriff}
  {Benko Gambit} Wolga-Gambit
  {Benko Opening} Benk�-Er�ffnung
  {Berlin Defence} {Berliner Verteidigung}
  Chameleon Cham�leon
  Chelyabinsk Tscheljabinsk
  {Classical Defence} {Klassische Verteidigung}
  {Spanish: Classical Defence} {Spanisch: Klassische (Cordel-) Verteidigung}
  {Classical Exchange} {Klassischer Abtausch}
  {Classical Variation} {Klassische Variante}
  {Closed Berlin} {Geschlossener Berliner}
  {Open Berlin} {Offener Berliner}
  {Bird's,} {Bird,}
  {Bird's Defence} Bird-Verteidigung
  {Bird's Deferred} {Verz�gerte Bird}
  {Bishop's Opening} L�uferspiel
  {Botvinnik System} Botwinnik-System
  {Central Variation} Zentralvariante
  {Centre Attack} Zentrumsangriff
  {Centre Game} Mittelgambit
  {Danish Gambit} {Nordisches Gambit}
  Dragon Drachen
  {Dutch Variation} {Holl�ndische Variante}
  {Early Exchange} {Fr�her Abtausch}
  {Early Queenswap} {Fr�her Damentausch}
  {English Attack} {Englischer Angriff}
  {English: King's} {Englisch: K�nigsbauer}
  {English Variation} {Englische Variante}
  {Englund Gambit} Englund-Gambit
  {Exchange Variation} Abtauschvariante
  {Fianchetto Variation} Fianchettovariante
  {Flohr Variation} Flohr-Variante
  {Four Knights} Vierspringer
  {Four Knights Game} Vierspringerspiel
  {Four Pawns} Vierbauern
  {Four Pawns Attack} Vierbauernangriff
  {French Variation} {Franz�sische Variante}
  {From Gambit} {Froms Gambit}
  {Goring Gambit} {G�ring-Gambit}
  {Grob Gambit} {Grobs Gambit}
  {Hungarian Defence} {Ungarische Verteidigung}
  {Indian Variation} {Indische Variante}
  {Italian Game} {Italienische Partie}
  KGD {Abgel. K�nigsgambit}
  {Classical KGD} {Klassisches abgelehntes K�nigsgambit}
  {Keres Variation} Keres-Variante
  KGA {Angen. K�nigsgambit}
  {KGA: Bishop's Gambit} K�nigsl�ufergambit
  {KGA: King's Knight Gambit} K�nigsspringergambit
  {King's Gambit} K�nigsgambit
  {King's Gambit Accepted} {Angen. K�nigsgambit}
  {King's Gambit Accepted (KGA)} {Angen. K�nigsgambit}
  {King's Indian} K�nigsindisch
  KIA {K�nigsindischer Angriff}
  {King's Knight Gambit} K�nigsspringergambit
  {King's Pawn} K�nigsbauer
  {Lasker Variation} {Lasker-Variante}
  {Latvian Gambit} {Lettisches Gambit}
  {Maroczy Bind} {Maroczy-Aufbau}
  {Marshall Variation} Marshall-Variante
  {Modern Attack} {Moderner Angriff}
  {Modern Steinitz} {Moderne Steinitz}
  {Modern Variation} {Moderne Variante}
  {Moscow Variation} {Moskauer Variante}
  Nimzo-Indian Nimzoindisch
  {Old Benoni} {Klassisches Benoni}
  {Old Indian} Altindisch
  {Old Indian Attack} {Altindisch i.A.}
  {Old Steinitz} Steinitz-Verteidigung
  {Open Game} {Offene Partie}
  {Poisoned Pawn} {Vergifteter Bauer}
  {Polish Variation} {Polnische Variante}
  {Polugaevsky Variation} {Polugajewski-Variante}
  {Queen's Gambit} Damengambit
  {Queen's Gambit Accepted} {Angen. Damengambit}
  QGA {Angen. Damengambit}
  {Queen's Gambit Accepted (QGA)} {Angenommenes Damengambit}
  {Reversed QGA} {Angen. Damengambit i.A.}
  QGD {Abgel. Damengambit}
  {Queen's Gambit Declined (QGD)} {Abgelehntes Damengambit}
  {Reversed QGD} {Abgel. Damengambit i.A.}
  {Queen's Indian} Damenindisch
  {Queen's Pawn} Damenbauer
  {Queen's Pawn Game} Damenbauerspiel
  {Reversed Slav} {Slawisch i.A.}
  {Rubinstein Variation} Rubinstein-Variante
  {Russian Game} {Russische Partie}
  {Russian Game (Petroff Defence)} {Russische Partie}
  {Russian-Three Knights Game} {Russisches Dreispringerspiel}
  {Scandinavian (Centre Counter)} Skandinavisch
  Schliemann J�nisch
  {Schliemann (J�nisch)} {J�nisch-Gambit (Schliemann)}
  {Scotch Opening} {Schottische Er�ffnung}
  {Sicilian Defence} {Sizilianische Verteidigung}
  {Sicilian Variation} {Sizilianische Variante}
  {Slav Defence} {Slawische Verteidigung}
  Smith-Morra Morra
  {Smith-Morra Accepted} {Angenommenes Morra-Gambit}
  {Smith-Morra Gambit} Morra-Gambit
  {Spanish (Ruy Lopez)} {Spanische Partie}
  {Start position} Ausgangsstellung
  {Steinitz Deferred} Rubinstein-Aufbau
  {Swedish Variation} {Schwedische Variante}
  {Swiss Variation} {Schweizer Variante}
  {Tarrasch's Gambit} {Tarrasch-Gambit}
  {Three Knights} Dreispringer
  {3 Knights} Dreispringer
  {Three Knights Game} Dreispringerspiel
  {Three Pawns Attack} Dreibauernangriff
  {Two Knights} Zweispringer
  {Two Knights Defence} Zweispringer-Verteidigung
  {Two Knights Variation} Zweispringer-Variante
  {Two Pawns} Zweibauern
  {Two Pawns Attack} Zweibauernangriff
  {Wing Gambit} Fl�gel-Gambit
  {Yugoslav Attack} {Jugoslawischer Angriff}
}


### German help pages removed because they're too old :( S.A

### German tip of the day

set tips(D) {
  {
    Scid hat mehr als 30 <a Index>Hilfeseiten</a> und in den meisten
    Scid-Fenstern liefert die <b>F1</b>-Taste die Hilfeseite zu diesem
    Fenster.
  }
  {
    Einige Scid-Fenster (z.B. Informationsbereich und
    Datenbank-<a Switcher>Umschalter</a>) haben ein Kontextmenu.
    Dr�cken Sie einfach die rechte Maustaste in jedem Fenster, um zu
    sehen, ob es ein Men� hat und welche Funktionen zur Verf�gung
    stehen.
  }
  {
    Scid bietet Ihnen mehr als eine M�glichkeit, Schachz�ge einzugeben,
    und l��t Ihnen die Wahl, welche Ihnen am meisten zusagt. Sie k�nnen
    die Maus verwenden (mit oder ohne Zugvorschlag) oder die Tastatur
    (mit oder ohne Zugerg�nzung). F�r Details lesen Sie die Hilfeseite
    <a Moves>Z�ge eingeben</a>.
  }
  {
    Wenn Sie einige Datenbanken h�ufig �ffnen, f�gen Sie zu jeder ein
    <a Bookmarks>Lesezeichen</a> hinzu, dann k�nnen Sie sie schneller
    mit dem Lesezeichen-Men� �ffnen.
  }
  {
    Sie k�nnen alle Z�ge einer Partie (mit allen Varianten und
    Kommentaren) mit dem <a PGN>PGN-Fenster</a> betrachten. Im
    PGN-Fenster k�nnen Sie zu jedem beliebigen Zug gehen, indem Sie
    ihn mit der linken Maustaste anklicken oder mit der mittleren
    Maustaste eine Voransicht dieser Stellung erhalten.
  }
  {
    Sie k�nnen Partien mit der linken Maustaste per "Drag & Drop" im
    <a Switcher>Datenbank-Umschalter</a> von einer Datenbank in eine
    andere kopieren.
  }
  {
    Scid kann PGN-Dateien selbst dann �ffnen, wenn sie mit Gzip
    komprimiert wurden (Dateiname mit Erweiterung .gz). PGN-Dateien
    werden schreibgesch�tzt ge�ffnet. Wenn Sie also eine PGN-Datei
    editieren wollen, erstellen Sie eine neue Scid-Datenbank und
    kopieren die PGN-Datei mit dem <a Switcher>Datenbank-Umschalter</a>
    dorthin.
  }
  {
    Wenn Sie eine gro�e Datenbank haben, die Sie oftmals mit dem
    <a Tree>Zugbaumfenster</a> nutzen, lohnt es sich,
    <b>Cache-Datei f�llen</b> im Dateimen� des Zugbaumfensters zu
    w�hlen. Damit merken Sie sich Zugbaum-Statistiken f�r viele
    h�ufige Er�ffnungspositionen und beschleunigen den Zugriff auf
    den Zugbaum f�r die Datenbank.
  }
  {
    Das <a Tree>Zugbaum</a>-Fenster kann Ihnen alle Z�ge zeigen, die
    in der aktuellen Position gespielt wurden, aber wenn Sie auch alle
    Zugfolgen sehen wollen, mit denen diese Stellung erreicht wurde,
    finden Sie diese, wenn Sie einen <a Reports Opening>Er�ffnungsbericht</a>
    erstellen.
  }
  {
    Klicken Sie mit der linken oder rechten Maustaste auf die �berschrift
    einer Spalte im <a GameList>Partieliste</a>-Fenster , um ihre
    Breite anzupassen.
  }
  {
    Mit dem Fenster <a PInfo>Spielerinformation</a> (um es zu �ffnen,
    klicken Sie einfach auf einen Spielernamen im Informationsbereich
    unter dem Hauptfenster-Schachbrett) k�nnen Sie auf einfache Weise
    den <a Searches Filter>Filter</a> so einstellen, da� er alle Partien
    eines bestimmten Spielers mit einem bestimmten Ergebnis enth�lt,
    indem Sie auf irgendeinen <red>in Rot</red> dargestellten Wert
    klicken.
  }
  {
    Beim Er�ffnungsstudium kann es sehr hilfreich sein, f�r eine wichtige
    Position eine <a Searches Board>Brettsuche</a> mit der <b>Bauern</b>-
    oder <b>Linien</b>-Option durchzuf�hren, was andere Er�ffnungen
    entdecken k�nnte, die zur selben Bauernstruktur f�hren.
  }
  {
    Im Informationsbereich (unterhalb des Schachbretts) k�nnen Sie mit
    der rechten Maustaste ein Men� zur Gestaltung der Ausgabe aktivieren.
    Zum Beispiel k�nnen Sie Scid veranlassen, den n�chsten Zug zu
    verstecken, was n�tzlich ist, wenn man zum Trainieren eine Partie
    nachspielt und die Z�ge zu erraten versucht.
  }
  {
    Wenn Sie f�r eine gro�e Datenbank oftmals eine umfangreiche
    Datenbank-<a Maintenance>Wartung</a> durchf�hren, k�nnen Sie
    mehrere Wartungsarbeiten gleichzeitig mit dem
    <a Maintenance Cleaner>Bereiniger</a> ausf�hren.
  }
  {
    Wenn Sie eine gro�e Datenbank haben, wo die meisten Partien einen
    Turniereintrag besitzen und Sie wollen die Partien nach Datum
    sortiert haben, erw�gen Sie ein <a Sorting>Sortieren</a> nach
    Turnierdatum und Turnier anstatt nach Datum und Turnier, da
    Ihnen das hilft, Partien desselben Turniers mit unterschiedlichen
    Daten zusammen zu halten (nat�rlich unter der Voraussetzung, da�
    sie alle dasselbe Turnierdatum haben).
  }
  {
    Es ist eine gute Idee, vor einem <a Maintenance Twins>Dubletten
    l�schen</a> eine <a Maintenance Spellcheck>Schreibkorrektur</a>
    Ihrer Datenbank durchzuf�hren, da es dies Scid erm�glicht, mehr
    Dubletten zu finden und zum L�schen vorzumerken.
  }
  {
    <a Flags>Markierungen</a> sind n�tzlich, um Datenbankpartien mit
    Charakteristiken zu versehen, nach denen Sie zu einem sp�teren
    Zeitpunkt vielleicht suchen wollen, wie etwa Bauernstruktur, Taktik
    etc. Sie k�nnen mit der <a Searches Header>Partiedaten-Suche</a>
    nach Markierungen suchen.
  }
  {
    Wenn Sie eine Partie nachspielen und einige Z�ge ausprobieren
    wollen, ohne die Partie zu ver�ndern, schalten Sie einfach den
    Testmodus ein (mit der Tastenkombination <b>Strg+Leerzeichen</b>
    oder mit dem Symbol aus der Werkzeugleiste), und wenn Sie fertig
    sind, schalten Sie ihn wieder aus, um zur urspr�nglichen Partie
    zur�ckzukommen.
  }
  {
    Um die prominentesten Partien (Spieler mit hohen Elo-Zahlen)
    zu finden, die eine bestimmte Position erreicht haben, �ffnen
    Sie das <a Tree>Zugbaum</a>-Fenster und dort die Liste der
    besten Partien. Sie k�nnen sogar die Liste der besten Partien
    auf Partien mit einem bestimmten Ergebnis begrenzen.
  }
  {
    Eine ausgezeichnete Methode, eine Er�ffnung mit Hilfe einer gro�en
    Datenbank zu studieren, ist, den Trainingsmodus im
    <a Tree>Zugbaum</a>-Fenster zu aktivieren und dann gegen die
    Datenbank zu spielen, um zu sehen, welche Z�ge h�ufig vorkommen.
  }
  {
    Wenn Sie zwei Datenbanken ge�ffnet haben und die
    <a Tree>Zugbaum</a>-Statistik der ersten Datenbank sehen wollen,
    w�hrend Sie eine Partie der zweiten Datenbank untersuchen, dr�cken
    Sie einfach den Schalter <b>Anbinden</b> im Zugbaumfenster, um die
    Partie an die erste Datenbank zu binden, und wechseln dann zur
    zweiten Datenbank.
  }
  {
    Der <a Tmt>Turnierfinder</a> ist nicht nur zum Auffinden eines
    bestimmten Turniers n�tzlich, sondern auch um zu sehen, an welchen
    Turnieren ein bestimmter Spieler vor kurzem teilgenommen hat,
    oder um die Spitzenturniere in einem bestimmten Land zu betrachten.
  }
  {
    Es gibt eine Reihe h�ufiger Stellungsmuster, die im Fenster
    <a Searches Material>Material/Muster</a>-Suche definiert sind und
    die Ihnen beim Er�ffnungs- oder Mittelspielstudium n�tzlich sein
    k�nnen.
  }
  {
    Wenn Sie im Fenster <a Searches Material>Material/Muster</a>-Suche
    nach einer bestimmten Materialkonstellation suchen, ist es oftmals
    hilfreich, die Suche auf Partien zu beschr�nken, die mindestens f�r
    einige Halbz�ge auf das Suchmuster passen, um Partien auszusondern,
    wo die gesuchte Konstellation nur kurz vorkam.
  }
  {
    Wenn Sie eine wichtige Datenbank haben, die Sie nicht versehentlich
    ver�ndern wollen, w�hlen Sie <b>Schreibschutz...</b> im
    <b>Datei</b>-Men�, nachdem Sie sie ge�ffnet haben, oder �ndern Sie
    ihre Dateizugriffsrechte auf "nur Lesen".
  }
  {
    Wenn Sie XBoard oder WinBoard benutzen (oder ein anderes
    Schachprogramm, das Schachpositionen in FEN-Standardnotation in die
    Zwischenablage kopieren kann) und wollen dessen aktuelle
    Schachposition nach Scid kopieren, ist der schnellste und einfachste
    Weg, <b>Position sichern</b> im Dateimen� von XBoard/Winboard zu
    w�hlen, danach <b>Stellung einf�gen</b> in Scids Men� "Bearbeiten".
  }
  {
    Die <a Searches Header>Partiedaten-Suche</a> ignoriert bei
    Spieler/Turnier/Ort/Runden-Namen Gro�- und Kleinschreibung.  Sie
    k�nnen sie aber ber�cksichtigen und gleichzeitig
    Platzhalterzeichen verwenden (mit "?" = irgendein einzelnes
    Zeichen und "*" = null oder mehr Zeichen), wenn Sie den Suchtext
    in Anf�hrungszeichen ("...")  eingeben. Beispielsweise geben Sie
    "*BEL" (mit den Anf�hrungszeichen) im Ortsfeld ein, um alle in
    Belgien, nicht aber in Belgrad gespielten Partien zu finden.
  }
  {
    Wenn Sie einen Partiezug korrigieren wollen, ohne die danach
    gespielten Z�ge zu verlieren, �ffnen Sie das
    <a Import>Import</a>-Fenster, klicken auf <b>Aktuelle Partie
    einf�gen</b>, editieren den falschen Zug und w�hlen dann
    <b>Importieren</b>.
  }
  {
    Wenn Sie eine ECO-Klassifikationsdatei geladen haben, k�nnen Sie
    zur am weitest klassifizierten Position der aktuellen Partie mit
    <b>Er�ffnung identifizieren</b> im <b>Partie</b>-Men� gehen
    (Tastenkombination: Strg+Umsch+D).
  }
  {
    Wenn Sie vor dem �ffnen einer Datei ihre Gr��e oder das Datum ihrer
    letzten Modifikation �berpr�fen wollen, �ffnen Sie sie mit dem
    <a Finder>Dateifinder</a>.
  }
  {
    Eine <a Repertoire>Repertoire</a>-Datei ist eine ausgezeichnete
    Methode, Ihre favorisierten Er�ffnungsvarianten im Auge zu behalten
    und die Partien zu finden, wo diese Varianten gespielt wurden.
    Wenn Sie erst einmal Ihre Er�ffnungen in einer Repertoire-Datei
    gespeichert haben, k�nnen Sie jedesmal, wenn Sie eine neue Datei
    mit Partien haben, eine Repertoire-Suche durchf�hren und die Partien
    mit Ihren favorisierten Er�ffnungen betrachten.
  }
  {
    Mit einem <a Reports Opening>Er�ffnungsbericht</a> kann man sehr gut
    mehr �ber eine bestimmte Position lernen. Sie k�nnen die Erfolgsrate
    sehen, ob sie zu vielen Kurzremis f�hrt und die typischen
    positionellen Themen.
  }
  {
    Sie k�nnen die gebr�uchlichsten Kommentarsymbole (!, !?, += etc.)
    dem aktuellen Zug oder der aktuellen Stellung mit Tastenkombinationen
    hinzuf�gen, ohne den Kommentareditor benutzen zu m�ssen -- um
    beispielsweise ein "!" hinzuzuf�gen, tippen Sie "!" und danach die
    Eingabetaste. Zu den Details siehe die Hilfeseite <a Moves>Z�ge
    eingeben</a>.
  }
  {
    Wenn Sie Er�ffnungen in einer Datenbank mit dem <a Tree>Zugbaum</a>
    betrachten, k�nnen Sie eine n�tzlichen �bersicht erhalten, welche
    Erfolge mit der aktuellen Er�ffnung in der letzten Zeit und zwischen
    Spitzenspielern erzielt wurden, indem Sie das Statistikfenster
    �ffnen (Tastenkombination: Strg-I).
  }
  {
    Sie k�nnen die Gr��e des Hauptfensters �ndern, indem Sie die
    <b>Strg</b>-Taste gedr�ckt halten und dann die Cursortaste
    <b>Links</b> oder <b>Rechts</b> dr�cken.
  }
  {
    Nach einer <a Searches>Suche</a> k�nnen Sie leicht durch alle
    passenden Partien bl�ttern, indem Sie die <b>Strg</b>-Taste gedr�ckt
    halten und dann die Cursortaste <b>Auf</b> oder <b>Ab</b> dr�cken,
    um die vorherige bzw. n�chste Partie im <a Searches Filter>Filter</a>
    zu laden.
  }
  {
    �ber die Tasten <b>F2</b> und <b>F3</b> k�nnen direkt die letzten beiden Analyse-Engines gestartet werden, ohne dies nochmal ausw�hlen zu m�ssen. 
  }
}

### End of file: deutsch.tcl

