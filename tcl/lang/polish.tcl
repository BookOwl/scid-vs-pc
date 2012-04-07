
### Polish menus for Scid.
# Contributed by Michal Rudolf and Adam Umiastowski.

addLanguage P Polish 0 iso8859-2

proc setLanguage_P {} {

menuText P File "Plik" 0
menuText P FileNew "Nowy..." 0 {Tw�rz nowa baz� Scid}
menuText P FileOpen "Otw�rz..." 0 {Otw�rz istniej�c� baz� Scid}
menuText P FileClose "Zamknij" 0 {Zamknij aktywn� baz� Scid}
menuText P FileFinder "Poszukiwacz plik�w" 0 {Otw�rz okno poszukiwacza plik�w}
menuText P FileSavePgn "Zapisz PGN" 0 {Zapisz baz� w formacie PGN}
menuText P FileBookmarks "Zak�adki" 2 {Menu zak�adek (klawisz: Ctrl+B)}
menuText P FileBookmarksAdd "Dodaj zak�adk�" 0 \
  {Dodaj zak�adk� do aktualnej bazy i pozycji}
menuText P FileBookmarksFile "Wstaw zak�adk�" 0 \
  {Wstaw do wybranego katalogu zak�adk� do aktualnej bazy i pozycji}
menuText P FileBookmarksEdit "Edycja zak�adek..." 0 \
  {Edytuj menu zak�adek}
menuText P FileBookmarksList "Wy�wietlaj katalogi jako list�" 0 \
  {Wy�wietlaj katalogi zak�adek jako list�, nie jako zagnie�d�one menu}
menuText P FileBookmarksSub "Wy�wietl katalogi jako menu" 0 \
  {Wy�wietlaj katalogi zak�adek jako zagnie�d�one menu, nie jako list�}
menuText P FileMaint "Obs�uga" 1 {Narz�dzia obs�ugi bazy Scid}
menuText P FileMaintWin "Obs�uga" 0 \
  {Otw�rz/zamknij obs�ug� bazy Scid}
menuText P FileMaintCompact "Porz�dkuj baz�..." 0 \
  {Porz�dkuj baz�, usuwaj�c skasowane partie i nieu�ywane nazwiska}
menuText P FileMaintClass "Klasyfikacja debiutowa partii..." 0 \
  {Przelicz klasyfikacj� debiutowa wszystkich partii}
menuText P FileMaintSort "Sortuj baz�..." 0 \
  {Sortuj wszystkie partie w bazie}
menuText P FileMaintDelete "Usu� podw�jne partie..." 0 \
  {Szukaj podw�jnych partii i oznacz je do skasowania}
menuText P FileMaintTwin "Wyszukiwanie podw�jnych partii" 0 \
  {Otw�rz/uaktualnij wyszukiwanie podw�jnych partii}
menuText P FileMaintName "Pisownia" 0 \
  {Edycja nazw/nazwisk i kontrola pisowni}
menuText P FileMaintNameEditor "Edytor nazwisk" 0 \
  {Otw�rz/zamknij edytor nazwisk}
menuText P FileMaintNamePlayer "Sprawd� pisowni� nazwisk..." 17 \
  {Sprawd� pisowni� nazwisk przy pomocy pliku nazwisk}
menuText P FileMaintNameEvent "Sprawd� pisowni� nazw zawod�w..." 22 \
  {Sprawd� pisowni� nazw zawod�w przy pomocy pliku turniej�w}
menuText P FileMaintNameSite "Sprawd� pisowni� nazw miejscowo�ci..." 22 \
  {Sprawd� pisowni� nazw miejscowo�ci przy pomocy pliku miejscowo�ci}
menuText P FileMaintNameRound "Sprawd� numery rund..." 15 \
  {Sprawd� numery rund przy pomocy pliku}
menuText P FileReadOnly "Tylko do odczytu..." 0 \
  {Zabezpiecz baz� przed zapisem}
menuText P FileSwitch "Prze��cz baz�" 1 \
  {Prze��cz na inn� otwart� baz�} 
menuText P FileExit "Koniec" 0 {Zamknij Scida}
menuText P FileMaintFixBase "Napraw baz�" 0 {Spr�buj naprawi� uszkodzon� baz�}

menuText P Edit "Edytuj" 0
menuText P EditAdd "Dodaj wariant" 0 {Dodaj wariant do ruchu w partii}
menuText P EditPasteVar "Wklej wariant" 0
menuText P EditDelete "Usu� wariant" 0 {Usu� wariant dla tego posuni�cia}
menuText P EditFirst "Tw�rz pierwszy wariant" 0 \
  {Przesu� wariant na pierwsze miejsce na li�cie}
menuText P EditMain "Zmie� wariant na tekst partii" 0 \
   {Zamie� wariant i tekst partii}
menuText P EditTrial "Sprawd� wariant" 0 \
  {W��cz/wy��cz tryb sprawdzania wariant�w}
menuText P EditStrip "Usu�" 2 \
  {Usu� komentatarze i warianty}
# ====== TODO To be translated ======
menuText P EditUndo "Undo" 0 {Undo last game change}
menuText P EditStripComments "Komentarze" 0 \
  {Usu� wszystkie komentarze z aktualnej partii}
menuText P EditStripVars "Warianty" 0 \
  {Usu� wszystkie warianty z aktualnej partii}
menuText P EditStripBegin "Poprzednie posuni�cia" 0 \
  {Usu� wszystkie posuni�cia do bie��cej pozycji}
menuText P EditStripEnd "Nast�pne posuni�cia" 0 \
  {Usu� wszystkie posuni�cia od bie��cej pozycji do ko�ca partii}
menuText P EditReset "Opr�nij schowek" 0 \
  {Opr�nij schowek bazy}
menuText P EditCopy "Kopiuj parti� do schowka" 0 \
  {Kopiuj parti� do schowka}
menuText P EditPaste "Wklej aktywn� parti� ze schowka" 0 \
  {Wklej aktywn� parti� ze schowka}
menuText P EditPastePGN "Wklej tekst ze schowka jako parti� PGN..." 10 \
  {Zinterpretuj zawarto�� schowka jako parti� w formacie PGN i wklej j� tutaj}
menuText P EditSetup "Ustaw pozycj� pocz�tkow�..." 6 \
  {Ustaw pozycj� pocz�tkow� partii}
menuText P EditCopyBoard "Kopiuj pozycj�" 7 \
  {Kopiuj aktualn� pozycj� w notacji FEN do schowka}
menuText P EditCopyPGN "Kopiuj PGN" 0 {}
menuText P EditPasteBoard "Ustaw pozycj� ze schowka" 3 \
  {Ustaw pozycj� ze schowka}

menuText P Game "Partia" 1
menuText P GameNew "Opu�� parti�" 0 \
  {Opu�� parti�, rezygnuj�c z wszelkich zmian}
menuText P GameFirst "Pierwsza partia" 2 {Wczytaj pierwsz� parti� z filtra}
menuText P GamePrev "Poka� poprzedni� parti�" 0 \
  {Wczytaj poprzedni� wyszukan� parti�}
menuText P GameReload "Wczytaj ponownie aktualn� parti�"  10 \
  {Wczytaj parti� ponownie, rezygnuj�c z wszelkich zmian}
menuText P GameNext "Nast�pna partia" 0 \
  {Wczytaj nast�pn� wyszukan� parti�}
menuText P GameLast "Ostatnia partia" 5 {Wczytaj ostatni� parti� z filtra}
menuText P GameRandom "Losowa partia z filtra" 8 {Wczytaj losow� parti� z filtra}
menuText P GameNumber "Wczytaj parti� numer..." 17 \
  {Wczytaj parti� wprowadzaj�c jej numer}
menuText P GameReplace "Zapisz: zast�p parti�..." 3 \
  {Zapisz parti�, zast�p poprzedni� wersj�}
menuText P GameAdd "Zapisz: dodaj now� parti�..." 8 \
  {Zapisz t� parti� jako nowa parti� w bazie}
menuText P GameInfo "Ustaw informacje o partii" 0
menuText P GameBrowse "Przegl�daj partie" 0
menuText P GameList "Lista partii" 0
menuText P GameDeepest "Rozpoznaj debiut" 0 \
  {Przejd� do najd�u�szego wariantu z ksi��ki debiutowej}
menuText P GameGotoMove "Przejd� do posuni�cia nr..." 13 \
  {Przejd� do posuni�cia o podanym numerze}
menuText P GameNovelty "Znajd� nowink�..." 7 \
  {Znajd� pierwsze posuni�cie partii niegrane wcze�niej}

menuText P Search "Szukaj" 0
menuText P SearchReset "Resetuj filtr" 0 \
  {Wstaw wszystkie partie do filtra}
menuText P SearchNegate "Odwr�� filtr" 0 {Zamie� partie w filtrze i poza nim}
menuText P SearchEnd "Przejdz do ostatniego filtra" 0
menuText P SearchCurrent "Aktualna pozycja..." 0 \
  {Szukaj aktualnej pozycji}
menuText P SearchHeader "Nag��wek..." 0 \
  {Szukaj informacji o nag��wkach (nazwiska, nazwy turnieju itp.)}
menuText P SearchMaterial "Materia�/wzorzec..." 0 \
  {Szukaj wed�ug materia�u lub wzorca}
menuText P SearchUsing "Stosuj plik poszukiwania..." 0 \
  {Szukaj stosuj�c plik z opcjami poszukiwania}

menuText P Windows "Okna" 1
menuText P WindowsGameinfo {Poka� informacje o partii} 0 {Otw�rz/zamknij okno informacji o partii}
menuText P WindowsComment "Edytor komentarzy" 0 \
  {Otw�rz/zamknij edytor komentarzy}
menuText P WindowsGList "Lista partii" 0 {Otw�rz/zamknij list� partii}
menuText P WindowsPGN "Okno PGN" 0 {Otw�rz/zamknij (zapis partii) PGN }
menuText P WindowsCross "Tabela turniejowa" 0 {Poka� tabel� turniejow� dla aktualnej partii}
menuText P WindowsPList "Zawodnicy" 2 {Otw�rz/zamknij przegl�dark� zawodnik�w}
menuText P WindowsTmt "Turnieje" 0 {Otw�rz/zamknij przegl�dark� turniej�w}
menuText P WindowsSwitcher "Prze��cznik baz" 12 \
  {Otw�rz/zamknij prze��cznik baz}
menuText P WindowsMaint "Zarz�dzanie baz�" 0 \
  {Otw�rz/zamknij okno zarz�dzania baz�}
menuText P WindowsECO "Przegl�darka kod�w debiutowych" 0 \
  {Otw�rz/zamknij przegl�dark� kod�w debiutowych}
menuText P WindowsStats "Statystyka" 0 \
  {Otw�rz/zamknij statystyk�}
menuText P WindowsTree "Drzewo wariant�w" 0 {Otw�rz/zamknij drzewo wariant�w}
menuText P WindowsTB "Tablica ko�c�wek" 8 \
  {Otw�rz/zamknij okno tablicy ko�c�wek}
menuText P WindowsBook "Ksi��ka debiutowa" 0 {Otw�rz/zamknij ksi��k� debiutow�}
menuText P WindowsCorrChess "Gra korespondencyjna" 0 {Otw�rz/zamknij okno gry korespondencyjnej}

menuText P Tools "Narz�dzia" 0
menuText P ToolsAnalysis "Program analizuj�cy..." 8 \
  {Uruchom/zatrzymaj program analizuj�cy}
menuText P ToolsAnalysis2 "Program analizuj�cy 2..." 21 \
  {Uruchom/zatrzymaj program analizuj�cy}
menuText P ToolsEmail "Zarz�dzanie poczt� e-mail" 0 \
  {Otw�rz/zamknij zarz�dzanie adresami e-mail}
menuText P ToolsFilterGraph "U�redniony wykres filtra" 7 \
  {Otw�rz/zamknij wykres filtra w przeliczeniu na 1000 partii}
menuText P ToolsAbsFilterGraph "Wykres filtra" 7 {Otw�rz/zamknij wykres filtra}
menuText P ToolsOpReport "Raport debiutowy" 0 \
  {Utw�rz raport debiutowy dla aktualnej pozycji}
menuText P ToolsOpenBaseAsTree "Otw�rz baz� jako drzewo" 0   {Otw�rz baz� i u�yj jej jako drzewa}
menuText P ToolsOpenRecentBaseAsTree "Otw�rz ostatnio otwieran� baz� jako drzewo" 0   {Otw�rz ostatnio otwieran� baz� i u�yj jej jako drzewa}
menuText P ToolsTracker "�ledzenie figur"  1 {Otw�rz/zamknij okno �ledzenia figur} 
menuText P ToolsTraining "Trening"  0 {Narz�dzia do treningu taktyki i debiut�w}
menuText P ToolsComp "Turniej komputerowy" 2 {Turniej program�w komputerowych}
menuText P ToolsComp "Turniej komputerowy" 2 {Turniej program�w komputerowych}
menuText P ToolsTacticalGame "Partia taktyczna"  0 {Rozegraj parti� z taktyk�}
menuText P ToolsSeriousGame "Partia turniejowa"  1 {Rozegraj parti� turniejow�}
menuText P ToolsTrainTactics "Taktyka"  0 {Rozwi�zuj zadania taktyczne}
menuText P ToolsTrainCalvar "Liczenie wariant�w"  0 {�wicz liczenie wariant�w}
menuText P ToolsTrainFindBestMove "Znajd� najlepszy ruch"  0 {Znajd� najlepszy ruch}
menuText P ToolsTrainFics "Internet"  0 {Graj w szachy na freechess.org}
menuText P ToolsBookTuning "Konfiguracja ksi��ki debiutowej" 0 {Konfiguruj ksi��k� debiutow�}
menuText P ToolsConnectHardware "Pod��cz urz�dzenie" 0 {Pod��cz zewn�trzne urz�dzenie}
menuText P ToolsConnectHardwareConfigure "Konfiguruj..." 0 {Konfiguruj zewn�trzne urz�dzenie i po��czenie}
menuText P ToolsConnectHardwareNovagCitrineConnect "Pod��cz Novag Citrine" 0 {Pod��cz Novag Citrine}
menuText P ToolsConnectHardwareInputEngineConnect "Pod��cz urz�dzenie wej�ciowe" 0 {Pod��cz urz�dzenie wej�ciowe, na przyk�ad DGT}
menuText P ToolsNovagCitrine "Novag Citrine" 0 {Novag Citrine}
menuText P ToolsNovagCitrineConfig "Konfiguracja" 0 {Konfiguracja Novag Citrine}
menuText P ToolsNovagCitrineConnect "Pod��cz" 0 {Pod��cz Novag Citrine}
menuText P ToolsPInfo "Informacje o zawodniku"  0 \
  {Otw�rz/od�wie� okno informacji o zawodniku}
menuText P ToolsPlayerReport "Raport o graczu" 9 \
  {Utw�rz raport o graczu} 
menuText P ToolsRating "Wykres rankingu" 0 \
  {Wykres historii rankingu graj�cych parti�}
menuText P ToolsScore "Wykres wynik�w" 1 {Poka� wykres wynik�w}
menuText P ToolsExpCurrent "Eksportuj parti�" 0 \
  {Zapisz parti� do pliku tekstowego}
menuText P ToolsExpCurrentPGN "Do pliku PGN..." 9 \
  {Zapisz parti� do pliku PGN}
menuText P ToolsExpCurrentHTML "Do pliku HTML..." 9 \
  {Zapisz parti� do pliku HTML}
menuText P ToolsExpCurrentHTMLJS "Eksportuj parti� do HTML z JavaScriptem..." 15 {Zapisz aktualn� parti� do pliku HTML z JavaScriptem}  
menuText P ToolsExpCurrentLaTeX "Do pliku LaTeX-a..." 9 \
  {Zapisz parti� do pliku LaTeX-a}
menuText P ToolsExpFilter "Eksportuj wyszukane partie" 1 \
  {Zapisz wyszukane partie do pliku tekstowego}
menuText P ToolsExpFilterPGN "Do pliku PGN..." 9 \
  {Zapisz wyszukane partie do pliku PGN}
menuText P ToolsExpFilterHTML "Do pliku HTML..." 9 \
  {Zapisz wyszukane partie do pliku HTML}
menuText P ToolsExpFilterHTMLJS "Eksportuj filtr do HTML z Javascriptem..." 17 {Zapisz wszystkie partie w filtrze do pliku HTML z Javascriptem}  
menuText P ToolsExpFilterLaTeX "Do pliku LaTeX..." 9 \
  {Zapisz wyszukane partie do pliku LaTeX}
menuText P ToolsImportOne "Wklej parti� w formacie PGN..." 0 \
  {Pobierz parti� z pliku PGN}
menuText P ToolsImportFile "Importuj plik PGN..." 2 \
  {Pobierz partie z pliku PGN}
menuText P ToolsStartEngine1 "Uruchom program 1" 0  {Uruchom program 1}
menuText P ToolsStartEngine2 "Uruchom program 2" 0  {Uruchom program 2}
menuText P ToolsScreenshot "Zrzut ekranu" 0

menuText P Play "Gra" 0
menuText P CorrespondenceChess "Szachy korespondencyjne" 0 {Funkcje do gry korespondencyjnej przez e-mail i Xfcc}
menuText P CCConfigure "Konfiguruj..." 0 {Konfiguruj ustawienia i narz�dzia zewn�trzne}
menuText P CCConfigRelay "Konfiguruj obserwowane..." 1 {Konfiguruj obserwowane partie}
menuText P CCOpenDB "Otw�rz baz�..." 0 {Otw�rz domy�ln� baz� korespondencyjn�}
menuText P CCRetrieve "Pobierz partie" 0 {Pobierz partie zewn�trznym narz�dziem Xfcc}
menuText P CCInbox "Przetw�rz skrzynk� wej�ciow�" 0 {Przetw�rz wszystkie pliki w skrzynce wej�ciowej}
menuText P CCSend "Wy�lij posuni�cie" 0 {Wy�lij posuni�cie przez e-mail lub zewn�trzne narz�dzie Xfcc}
menuText P CCResign "Poddaj si�" 0 {Poddaj si� (nie przez e-mail)}
menuText P CCClaimDraw "Reklamuj remis" 0 {Wy�lij posuni�cie i reklamuj remis (nie przez e-mail)}
menuText P CCOfferDraw "Zaproponuj remis" 0 {Wy�lij posuni�cie i zaproponuj remis (nie przez e-mail)}
menuText P CCAcceptDraw "Przyjmij remis" 0 {Przyjmij propozycj� remisu (nie przez e-mail)}
menuText P CCNewMailGame "Nowa partia e-mail..." 0 {Rozpocznij now� parti� e-mail}
menuText P CCMailMove "Wy�lij posuni�cie przez e-mail..." 0 {Wy�lij posuni�cie przez e-mail}
menuText P CCGamePage "Strona partii..." 0 {Otw�rz stron� partii w przegl�darce}
menuText P CCEditCopy "Kopiuj list� partii do schowka" 0 {Skopiuj list� partii w formacie CSV do schowka}

menuText P Options "Opcje" 0
menuText P OptionsBoard "Szachownica" 0 {Konfiguracja wygl�du szachownicy}
menuText P OptionsColour "Kolor t�a" 0 {Domy�lny kolor t�a}
menuText P OptionsNames "Moje nazwiska" 0 {Modyfikuj list� moich graczy}
menuText P OptionsExport "Eksport" 0 {Zmie� opcje eksportu tekstu}
menuText P OptionsFonts "Czcionka" 0 {Zmie� czcionk�}
menuText P OptionsFontsRegular "Podstawowa" 0 {Zmie� podstawow� czcionk�}
menuText P OptionsFontsMenu "Menu" 0 {Zmie� czcionk� menu} 
menuText P OptionsFontsSmall "Ma�a" 0 {Zmie� ma�� czcionk�}
menuText P OptionsFontsFixed "Sta�a" 0 {Zmie� czcionk� sta�ej szeroko�ci}
menuText P OptionsGInfo "Informacje o partii" 0 {Spos�b wy�wietlania informacji o partii}
menuText P OptionsFics "FICS" 0
menuText P OptionsLanguage "J�zyk" 0 {Wybierz j�zyk}
menuText P OptionsMovesTranslatePieces "T�umacz oznaczenia figur" 0 {T�umacz pierwsze litery figur}
menuText P OptionsMovesHighlightLastMove "Pod�wietl ostatnie posuni�cie" 0 {Pod�wietl ostatnie posuni�cie}
menuText P OptionsMovesHighlightLastMoveDisplay "Poka�" 0 {Poka� ostatnie posuni�cie}
menuText P OptionsMovesHighlightLastMoveWidth "Width" 0 {Grubo�� linii}
menuText P OptionsMovesHighlightLastMoveColor "Kolor" 0 {Kolor linii}
menuText P OptionsMoves "Posuni�cia" 0 {Wprowadzanie posuni��}
menuText P OptionsMovesAsk "Zapytaj przed zast�pieniem posuni��" 0 \
  {Zapytaj przed zast�pieniem aktualnych posuni��}
menuText P OptionsMovesAnimate "Szybko�� animacji" 1 \
  {Ustaw czas przeznaczony na animacj� jednego posuni�cia} 
menuText P OptionsMovesDelay "Automatyczne przegl�danie..." 0 \
  {Ustaw op�nienie przy automatycznym przegl�daniu partii}
menuText P OptionsMovesCoord "Posuni�cia w formacie \"g1f3\"" 0 \
  {Akceptuj posuni�cia wprowadzone w formacie "g1f3"}
menuText P OptionsMovesSuggest "Poka� proponowane posuni�cia" 1 \
  {W��cz/wy��cz proponowanie posuni��}
menuText P OptionsShowVarPopup "Poka� okno wariant�w" 0 {W��cz/wy��cz wy�wietlanie okna wariant�w}  
menuText P OptionsMovesSpace "Dodaj spacj� po numerze posuni�cia" 0 {Dodawaj spacj� po numerze posuni�cia}  
menuText P OptionsMovesKey "Automatyczne dope�nianie posuni��" 1 \
  {W��cz/wy��cz automatyczne dope�nianie posuni�� wprowadzanych z klawiatury}
menuText P OptionsMovesShowVarArrows "Poka� strza�ki wariant�w" 0 {W��cz/wy��cz strza�ki pokazuj�ce ruchy wariant�w}
menuText P OptionsNumbers "Format zapisu liczb" 0 {Wybierz format zapisu liczb}
menuText P OptionsStartup "Start" 0 {Wybierz okna, kt�re maj� by� widoczne po uruchomieniu programu}
menuText P OptionsWindows "Okna" 0 {Opcje okien}
menuText P OptionsWindowsIconify "Minimalizuj wszystkie okna" 0 \
  {Schowaj wszystkie okna przy minimalizacji g��wnego okna}
menuText P OptionsWindowsRaise "Automatyczne uaktywnianie" 0 \
  {Automatycznie uaktywniaj niekt�re okna (np. pasek post�pu), gdy s� zas�oni�te}
menuText P OptionsSounds "D�wi�ki..." 0 {Konfiguruj d�wi�ki zapowiadaj�ce ruchy}
menuText P OptionsToolbar "Pasek narz�dziowy" 6 \
  {Schowaj/poka� pasek narz�dziowy}
menuText P OptionsECO "Wczytaj ksi��k� debiutow�..." 16 \
  {Wczytaj plik z klasyfikacja debiut�w}
menuText P OptionsSpell "Wczytaj plik sprawdzania pisowni..." 13 \
  {Wczytaj plik do sprawdzania pisowni nazwisk i nazw}
menuText P OptionsTable "Katalog z baz� ko�c�wek..." 10 \
  {Wybierz baz� ko�c�wek; u�yte zostan� wszystkie bazy z tego katalogu}
menuText P OptionsRecent "Ostatnie pliki..." 0 \
  {Zmie� liczb� ostatnio otwartych plik�w, wy�wietlanych w menu Plik} 

menuText P OptionsBooksDir "Katalog ksi��ek debiutowych..." 0 {Ustaw katalog ksi��ek debiutowych}
menuText P OptionsTacticsBasesDir "Katalog baz..." 0 {Ustaw katalog baz treningowych}
menuText P OptionsSave "Zapami�taj opcje" 0 \
  "Zapami�taj wszystkie ustawienia w pliku $::optionsFile"
menuText P OptionsAutoSave "Automatycznie zapisuj opcje" 0 \
  {Automatycznie zapisz opcje przy zamykaniu programu}

menuText P Help "Pomoc" 2
menuText P HelpContents "Spis tre�ci" 0 {Poka� spis tre�ci pomocy} 
menuText P HelpIndex "Spis tre�ci" 0 {Poka� indeks pomocy}
menuText P HelpGuide "Kr�tki przewodnik" 0 {Poka� kr�tki przewodnik}
menuText P HelpHints "Podpowiedzi" 0 {Poka� podpowiedzi}
menuText P HelpContact "Informacja o autorze" 0 \
  {Poka� informacj� o autorze i stronie Scid-a}
menuText P HelpTip "Porada dnia" 0 {Poka� porad� Scida}
menuText P HelpStartup "Okno powitalne" 2 {Pokazuj okno startowe}
menuText P HelpAbout "O programie" 0 {Informacje o programie Scid}

# Game info box popup menu:
menuText P GInfoHideNext "Ukryj nast�pne posuni�cie" 0
menuText P GInfoMaterial "Poka� materia�" 0
menuText P GInfoFEN "Poka� pozycj� w formacie FEN" 16
menuText P GInfoMarks "Pokazuj kolorowe pola i strza�ki" 5 
menuText P GInfoWrap "Zawijaj d�ugie linie" 0
menuText P GInfoFullComment "Poka� ca�y komentarz" 6
menuText P GInfoPhotos "Poka� zdj�cia" 5
menuText P GInfoTBNothing "Tablica ko�c�wek: nic" 0
menuText P GInfoTBResult "Tablica ko�c�wek: tylko wynik" 18
menuText P GInfoTBAll "Tablica ko�c�wek: wszystko" 18
menuText P GInfoDelete "Usu�/przywr�� t� parti�" 0
menuText P GInfoMark "W��cz/wy��cz zaznaczenie tej partii" 0
menuText P GInfoInformant "Konfiguruj oceny Informatora" 0

# Main window buttons:
helpMsg P .button.start {Id� do pocz�tku partii (klawisz: Home)}
helpMsg P .button.end {Id� na koniec partii  (klawisz: End)}
helpMsg P .button.back {Cofnij o jedno posuni�cie  (klawisz: strza�ka w lewo)}
helpMsg P .button.forward {Jedno posuni�cie do przodu (klawisz: strza�ka w prawo)}
helpMsg P .button.intoVar {Wejd� w wariant (klawisz skr�tu: v)}
helpMsg P .button.exitVar {Opu�� wariant (klawisz skr�tu: z)}
helpMsg P .button.flip {Obr�� szachownic�  (klawisz skr�tu: .)}
helpMsg P .button.coords {Prze��cz wy�wietlanie opisu szachownicy  (klawisz skr�tu: 0)}
helpMsg P .button.stm {Prze��cz wy�wietlanie ikony koloru strony na posuni�ciu} 
helpMsg P .button.autoplay \
  {Automatyczne przestawianie bierek (klawisz skr�tu: Ctrl+Z)}

# General buttons:
translate P Back {Z powrotem}
translate P Browse {Przegl�daj}
translate P Cancel {Anuluj}
translate P Continue {Kontynuuj}
translate P Clear {Wyczy��}
translate P Close {Zamknij}
translate P Contents {Spis tre�ci}
translate P Defaults {Domy�lne}
translate P Delete {Usu�}
translate P Graph {Wykres}
translate P Help {Pomoc}
translate P Import {Pobierz}
translate P Index {Indeks}
translate P LoadGame {Wczytaj parti�}
translate P BrowseGame {Przegl�daj parti�}
translate P MergeGame {Do��cz parti�}
translate P MergeGames {Po��cz partie}
translate P Preview {Podgl�d}
translate P Revert {Odwr��}
translate P Save {Zapisz}
translate P Search {Szukaj}
translate P Stop {Stop}
translate P Store {Zapami�taj}
translate P Update {Uaktualnij}
translate P ChangeOrient {Zmie� po�o�enie okna}
translate P ShowIcons {Poka� ikony}
translate P None {Brak}
translate P First {Pierwsza}
translate P Current {Aktualn�}
translate P Last {Ostatni�}

# General messages:
translate P game {partia}
translate P games {partie}
translate P move {posuni�cie}
translate P moves {pos.}
translate P all {wszystkie}
translate P Yes {Tak}
translate P No {Nie}
translate P Both {Oba}
translate P King {Kr�l}
translate P Queen {Hetman}
translate P Rook {Wie�a}
translate P Bishop {Goniec}
translate P Knight {Skoczek}
translate P Pawn {Pion}
translate P White {Bia�e}
translate P Black {Czarne}
translate P Player {Gracz}
translate P Rating {Ranking}
translate P RatingDiff {R�nica ranking�w}
translate P AverageRating {�redni ranking}
translate P Event {Turniej}
translate P Site {Miejsce}
translate P Country {Kraj}
translate P IgnoreColors {Ignoruj kolory}
translate P Date {Data}
translate P EventDate {Turniej data}
translate P Decade {Dekada} 
translate P Year {Rok}
translate P Month {Miesi�c}
translate P Months {Stycze� Luty Marzec Kwiecie� Maj Czerwiec Lipiec Sierpie� Wrzesie� Pa�dziernik Listopad Grudzie�}
translate P Days {N Pn Wt �r Cz Pt So}
translate P YearToToday {Ostatni rok}
translate P Result {Wynik}
translate P Round {Runda}
translate P Length {D�ugo��}
translate P ECOCode {Kod ECO}
translate P ECO {ECO}
translate P Deleted {Usuni�ta}
translate P SearchResults {Wyniki wyszukiwania}
translate P OpeningTheDatabase "Otwieranie bazy"
translate P Database {Bazy}
translate P Filter {Filtr}
translate P noGames {brak partii}
translate P allGames {wszystkie partie}
translate P empty {brak}
translate P clipbase {schowek}
translate P score {punkty}
translate N Start {Pozycja}
translate P StartPos {Pozycja pocz�tkowa}
translate P Total {Razem}
translate P readonly {tylko do odczytu}

# Standard error messages:
translate P ErrNotOpen {To nie jest otwarta baza.} 
translate P ErrReadOnly {Ta baza jest tylko do odczytu; nie mo�na jej zmieni�.}
translate P ErrSearchInterrupted {Wyszukiwanie zosta�o przerwane. Wyniki b�d� niepe�ne.}

# Game information:
translate P twin {powt�rzona}
translate P deleted {usuni�ta}
translate P comment {komentarz}
translate P hidden {ukryte}
translate P LastMove {Poprzednie}
translate P NextMove {nast�pne}
translate P GameStart {Pocz�tek partii}
translate P LineStart {Pocz�tek wariantu}
translate P GameEnd {Koniec partii}
translate P LineEnd {Koniec wariantu}

# Player information:
translate P PInfoAll {Wyniki - <b>wszystkie</b> partie}
translate P PInfoFilter {Wyniki - partie z <b>filtra</b>}
translate P PInfoAgainst {Wyniki - }
translate P PInfoMostWhite {Najcz�stsze debiuty bia�ymi}
translate P PInfoMostBlack {Najcz�stsze debiuty czarnymi}
translate P PInfoRating {Historia rankingu}
translate P PInfoBio {Biografia}
translate P PInfoEditRatings {Modyfikuj rankingi} 

# Tablebase information:
translate P Draw {remis}
translate P stalemate {pat}
translate P withAllMoves {po dowolnym posuni�ciu}
translate P withAllButOneMove {po dowolnym posuni�ciu opr�cz}
translate P with {po}
translate P only {tylko}
translate P lose {przegrywaj�}
translate P loses {przegrywa}
translate P allOthersLose {inne posuni�cia przegrywaj�}
translate P matesIn {matuj� w}
translate P hasCheckmated {matuj�}
translate P longest {najlepsze}
translate P WinningMoves {Wygrywaj�ce posuni�cia}
translate P DrawingMoves {Remisuj�ce posuni�cia} 
translate P LosingMoves {Przegrywaj�ce posuni�cia} 
translate P UnknownMoves {Posuni�cia o nieznanej ocenie} 

# Tip of the day:
translate P Tip {Porada}
translate P TipAtStartup {Poka� porad� przy starcie}

# Tree window menus:
menuText P TreeFile "Plik" 0
menuText P TreeFileFillWithBase "Wype�nij bufor baz�" 0 {Wype�nij plik bufora wszystkimi partiami w aktualnej bazie}
menuText P TreeFileFillWithGame "Wype�nij bufor parti�" 0 {Wype�nij plik bufora aktualn� parti�}
menuText P TreeFileSetCacheSize "Wielko�� bufora" 0 {Ustaw wielko�� bufora}
menuText P TreeFileCacheInfo "Informacje o buforze" 0 {Wy�wietl informacje o wykorzystaniu bufora}
menuText P TreeFileSave "Zapisz bufor" 7 {Zapisz plik bufora (.stc)}
menuText P TreeFileFill "Tw�rz standardowy plik cache" 0 {Wstaw typowe pozycje debiutowe do bufora}
menuText P TreeFileBest "Najlepsze partie" 0 {Poka� list� najlepszych partii}
menuText P TreeFileGraph "Poka� wykres" 0 {Poka� wykres dla tej ga��zi drzewa}
menuText P TreeFileCopy "Kopiuj drzewo do schowka" 0 \
  {Skopiuj drzewo ze statystykami do schowka}
menuText P TreeFileClose "Zamknij" 0 {Zamknij okno drzewa}
menuText P TreeMask "Maska" 0
menuText P TreeMaskNew "Nowa" 0 {Nowa maska}
menuText P TreeMaskOpen "Otw�rz" 0 {Otw�rz mask�}
menuText P TreeMaskOpenRecent "Otw�rz ostatni� mask�" 0 {Otw�rz ostatni� mask�}
menuText P TreeMaskSave "Zapisz" 0 {Zapisz mask�}
menuText P TreeMaskClose "Zamknij" 0 {Zamknij mask�}
menuText P TreeMaskFillWithGame "Wype�nij mask� parti�" 0 {Wype�nij mask� parti�}
menuText P TreeMaskFillWithBase "Wype�nij mask� baz�" 0 {Wype�nij mask� wszystkimi partiami w bazie}
menuText P TreeMaskInfo "Informacje" 0 {Poka� statystyk� aktualnej maski}
menuText P TreeMaskDisplay "Poka� map� maski" 0 {Poka� dane maski jako drzewo}
menuText P TreeMaskSearch "Znajd�" 0 {Znajd� w aktualnej masce}
menuText P TreeSort "Sortowanie" 0
menuText P TreeSortAlpha "Alfabetycznie" 0
menuText P TreeSortECO "Kod ECO" 0
menuText P TreeSortFreq "Cz�sto��" 0
menuText P TreeSortScore "Punkty" 0
menuText P TreeOpt "Opcje" 0
menuText P TreeOptSlowmode "Tryb dok�adny" 0 {Wolne uaktualnianie (du�a dok�adno��)}
menuText P TreeOptFastmode "Tryb szybki" 0 {Tryb szybki (bez transpozycji)}
menuText P TreeOptFastAndSlowmode "Tryb mieszany" 0 {Tryb szybki, a potem dok�adne uaktualnienie}
menuText P TreeOptStartStop "Automatyczne od�wie�anie" 0 {W��cz/wy��cz automatyczne od�wie�anie drzewa}
menuText P TreeOptLock "Blokada" 0 {Zablokuj/odblokuj drzewo na aktualnej bazie}
menuText P TreeOptTraining "Trening" 0 {W��cz/wy��cz tryb treningowy}
menuText P TreeOptAutosave "Automatyczny zapis bufora" 0 \
  {Automatycznie zapisz plik bufora przy wyj�ciu}
menuText P TreeHelp "Pomoc" 2
menuText P TreeHelpTree "Drzewo" 0
menuText P TreeHelpIndex "Spis tre�ci" 0

translate P SaveCache {Zapisz bufor}
translate P Training {Trening}
translate P LockTree {Blokada}
translate P TreeLocked {zablokowane}
translate P TreeBest {Najlepsze}
translate P TreeBestGames {Najlepsze partie}
# Note: the next message is the tree window title row. After editing it,
# check the tree window to make sure it lines up with the actual columns.
translate P TreeTitleRow \
  {    Pos.   ECO       Cz�sto��     Wynik  Rav   Rperf Rok   %Remis}
# {    Move   ECO       Frequency    Score  AvElo Perf AvYear %Draws}
translate P TreeTotal {RAZEM}
translate P DoYouWantToSaveFirst {Zapisa� najpierw}
translate P AddToMask {Dodaj do maski}
translate P RemoveFromMask {Usu� z maski}
translate P Nag {Kod NAG}
translate P Marker {Znacznik}
translate P Include {Do��cz}
translate P Exclude {Wyklucz}
translate P MainLine {Wariant g��wny}
translate P Bookmark {Zak�adka}
translate P NewLine {Nowy wariant}
translate P ToBeVerified {Do sprawdzenia}
translate P ToTrain {Do prze�wiczenia}
translate P Dubious {W�tpliwe}
translate P ToRemove {Do usuni�cia}
translate P NoMarker {Bez znacznika}
translate P ColorMarker {Kolor}
translate P WhiteMark {Bia�y}
translate P GreenMark {Zielony}
translate P YellowMark {��ty}
translate P BlueMark {Niebieski}
translate P RedMark {Czerwony}
translate P CommentMove {Komentuj posuni�cie}
translate P CommentPosition {Komentuj pozycj�}
translate P AddMoveToMaskFirst {Najpierw dodaj posuni�cie do maski}
translate P OpenAMaskFileFirst {Najpierw otw�rz plik maski}
translate P Positions {Pozycje}
translate P Moves {Posuni�cia}

# Finder window:
menuText P FinderFile "Plik" 0
menuText P FinderFileSubdirs "Przeszukuj podkatalogi" 0
menuText P FinderFileClose "Zamknij wyszukiwacza plik�w" 0
menuText P FinderSort "Sortowanie" 0
menuText P FinderSortType "Typ" 0
menuText P FinderSortSize "Rozmiar" 0
menuText P FinderSortMod "Zmieniony" 0
menuText P FinderSortName "Nazwa" 0
menuText P FinderSortPath "�cie�ka" 0
menuText P FinderTypes "Typy" 0
menuText P FinderTypesScid "Bazy Scid-a" 0
menuText P FinderTypesOld "Bazy Scid-a (stary format)" 1
menuText P FinderTypesPGN "Pliki PGN" 0
menuText P FinderTypesEPD "Ksi��ki debiutowe EPD" 0
menuText P FinderHelp "Pomoc" 2
menuText P FinderHelpFinder "Pomoc poszukiwacza plik�w" 1
menuText P FinderHelpIndex "Spis tre�ci" 0
translate P FileFinder {Poszukiwacz plik�w}
translate P FinderDir {Katalog}
translate P FinderDirs {Katalogi}
translate P FinderFiles {Pliki}
translate P FinderUpDir {wy�ej}
translate P FinderCtxOpen {Otw�rz}
translate P FinderCtxBackup {Utw�rz kopi�}
translate P FinderCtxCopy {Kopiuj}
translate P FinderCtxMove {Przenie�}
translate P FinderCtxDelete {Usu�}

# Player finder:
menuText P PListFile "Plik" 0
menuText P PListFileUpdate "Uaktualnij" 0
menuText P PListFileClose "Zamknij przegl�dark� zawodnik�w" 0
menuText P PListSort "Sortowanie" 0
menuText P PListSortName "Nazwisko" 0
menuText P PListSortElo "Elo" 0
menuText P PListSortGames "Partie" 0
menuText P PListSortOldest "Najstarsza" 0
menuText P PListSortNewest "Najnowsza" 0

# Tournament finder:
menuText P TmtFile "Plik" 0
menuText P TmtFileUpdate "Uaktualnij" 0
menuText P TmtFileClose "Zamknij turnieje" 0
menuText P TmtSort "Sortowanie" 0
menuText P TmtSortDate "Data" 0
menuText P TmtSortPlayers "Zawodnicy" 0
menuText P TmtSortGames "Partie" 0
menuText P TmtSortElo "Elo" 0
menuText P TmtSortSite "Miejsce" 0
menuText P TmtSortEvent "Turniej" 0
menuText P TmtSortWinner "Zwyci�zca" 0
translate P TmtLimit "Wielko�� listy"
translate P TmtMeanElo "Min. �rednie ELO"
translate P TmtNone "Nie znaleziono turniej�w."

# Graph windows:
menuText P GraphFile "Plik" 0
menuText P GraphFileColor "Zapisz jako kolorowy PostScript" 12
menuText P GraphFileGrey "Zapisz jako zwyk�y PostScript..." 0
menuText P GraphFileClose "Zamknij okno" 6
menuText P GraphOptions "Opcje" 0
menuText P GraphOptionsWhite "Bia�e" 0
menuText P GraphOptionsBlack "Czarne" 0
menuText P GraphOptionsBoth "Oba kolory" 1
menuText P GraphOptionsPInfo "Gracz z Informacji o graczu" 0
translate P GraphFilterTitle "Filtr: cz�sto�� na 1000 partii" 
translate P GraphAbsFilterTitle "Wykres filtra: cz�sto�� partii"
translate P ConfigureFilter {Konfiguruj o� X: rok, ranking i posuni�cia}
translate P FilterEstimate "Oszacuj"
translate P TitleFilterGraph "Scid: wykres filtra"

# Analysis window:
translate P AddVariation {Dodaj wariant}
translate P AddAllVariations {Dodaj wszystkie warianty}
translate P AddMove {Dodaj posuni�cie}
translate P Annotate {Komentuj}
translate P ShowAnalysisBoard {Poka� pozycj� ko�cow�}
translate P ShowInfo {Poka� informacje o programie}
translate P FinishGame {Zako�cz parti�}
translate P StopEngine {Zatrzymaj program}
translate P StartEngine {Uruchom program}
translate P LockEngine {Zablokuj program na analizie aktualnej pozycji}
translate P AnalysisCommand {Program do analizy}
translate P PreviousChoices {Poprzednie programy}
translate P AnnotateTime {Czas mi�dzy ruchami (w sekundach)}
translate P AnnotateWhich {Dodaj warianty}
translate P AnnotateAll {Dla obu stron}
translate P AnnotateAllMoves {Wszystkie}
translate P AnnotateWhite {Dla bia�ych}
translate P AnnotateBlack {Dla czarnych}
translate P AnnotateNotBest {Tylko posuni�cia lepsze ni� w partii}
translate P AnnotateBlundersOnly {Tylko oczywiste b��dy}
translate P AnnotateBlundersOnlyScoreChange {Tylko b��dy ze zmian� oceny z/na: }
# ====== TODO To be translated ======
translate P AnnotateTitle {Konfiguracja komentarza}
translate P AnnotateWith {Format komentarza}
translate P AnnotateWhichMoves {Komentowane posuni�cia}
translate P AnnotateComment {Dodaj pole komentatora}
translate P BlundersThreshold {Granica b��du}
translate P LowPriority {Niski priorytet CPU} 
translate P ClickHereToSeeMoves {Kliknij, by zobaczy� posuni�cia}
translate P ConfigureInformant {Konfiguruj oceny Informatora}
translate P Informant!? {Ciekawe posuni�cie}
translate P Informant? {B��d}
translate P Informant?? {Powa�ny b��d}
translate P Informant?! {W�tpliwe posuni�cie}
translate P Informant+= {Niewielka przewaga}
translate P Informant+/- {Wyra�na przewaga}
translate P Informant+- {Rozstrzygaj�ca przewaga}
translate P Informant++- {Wygrana}
translate P Book {Ksi��ka debiutowa}

# Analysis Engine open dialog:
translate P EngineList {Programy szachowe}
translate P EngineName {Nazwa}
translate P EngineCmd {Polecenie}
translate P EngineArgs {Parametry} 
translate P EngineDir {Katalog}
translate P EngineElo {Elo}
translate P EngineTime {Data}
translate P EngineNew {Dodaj}
translate P EngineEdit {Edytuj}
translate P EngineRequired {Pola wyt�uszczone s� konieczne; reszta opcjonalna} 

# Stats window menus:
menuText P StatsFile "Plik" 0
menuText P StatsFilePrint "Zapisz do pliku..." 7
menuText P StatsFileClose "Zamknij" 0
menuText P StatsOpt "Opcje" 0

# PGN window menus:
menuText P PgnFile "Plik" 0
menuText P PgnFileCopy "Kopiuj parti� do schowka" 0
menuText P PgnFilePrint "Zapisz do pliku..." 7
menuText P PgnFileClose "Zamknij" 0
menuText P PgnOpt "Wygl�d" 0
menuText P PgnOptColor "Wy�wietlanie w kolorach" 0
menuText P PgnOptShort "Kr�tki (3-wierszowy) nag��wek" 0
menuText P PgnOptSymbols "Symbole Informatora" 0
menuText P PgnOptIndentC "Wcinaj komentarze" 7
menuText P PgnOptIndentV "Wcinaj warianty" 7
menuText P PgnOptColumn "Kolumny (jedno posuni�cie w wierszu)" 0
menuText P PgnOptSpace "Spacja po numerze ruchu" 0
menuText P PgnOptStripMarks "Usu� kody kolorowych p�l i strza�ek" 0
menuText P PgnOptChess "U�yj czcionki szachowej" 0
menuText P PgnOptScrollbar "Pasek przewijania" 0
menuText P PgnOptBoldMainLine "Wyt�u�� tekst partii" 2
menuText P PgnColor "Kolory" 0
menuText P PgnColorHeader "Nag��wek..." 0
menuText P PgnColorAnno "Uwagi..." 3
menuText P PgnColorComments "Komentarze..." 0
menuText P PgnColorVars "Warianty..." 0
menuText P PgnColorBackground "T�o..." 0
menuText P PgnColorMain "G��wny wariant..." 0
menuText P PgnColorCurrent "T�o aktualnego posuni�cia..." 1
menuText P PgnColorNextMove "T�o nast�pnego posuni�cia..." 0
menuText P PgnHelp "Pomoc" 2
menuText P PgnHelpPgn "PGN" 0
menuText P PgnHelpIndex "Spis tre�ci" 0
translate P PgnWindowTitle {Tekst partii - partia  %u}

# Crosstable window menus:
menuText P CrosstabFile "Plik" 0
menuText P CrosstabFileText "Zapisz w pliku tekstowym..." 15
menuText P CrosstabFileHtml "Zapisz w pliku HTML..." 15
menuText P CrosstabFileLaTeX "Zapisz w pliku LaTeX-a..." 15
menuText P CrosstabFileClose "Zamknij" 0
menuText P CrosstabEdit "Edytuj" 0
menuText P CrosstabEditEvent "Turniej" 0
menuText P CrosstabEditSite "Miejsce" 0
menuText P CrosstabEditDate "Data" 0
menuText P CrosstabOpt "Wy�wietlanie" 0
menuText P CrosstabOptAll "Turniej ko�owy" 0
menuText P CrosstabOptSwiss "Szwajcar" 0
menuText P CrosstabOptKnockout "Knockout" 0
menuText P CrosstabOptAuto "Automatycznie" 0
# todo
menuText P CrosstabOptThreeWin "3 Points for Win" 1
menuText P CrosstabOptAges "Wiek" 0
menuText P CrosstabOptNats "Narodowo��" 0
menuText P CrosstabOptRatings "Ranking" 0
menuText P CrosstabOptTitles "Tytu�" 0
menuText P CrosstabOptBreaks "Punkty pomocnicze" 1
menuText P CrosstabOptDeleted "Uwzgl�dniaj usuni�te partie" 0
menuText P CrosstabOptColors "Kolory (tylko szwajcar)" 0
menuText P CrosstabOptColumnNumbers "Numerowane kolumny (tylko turniej ko�owy)" 0
menuText P CrosstabOptGroup "Grupuj po liczbie punkt�w" 0
menuText P CrosstabSort "Sortowanie" 0
menuText P CrosstabSortName "Nazwisko" 0
menuText P CrosstabSortRating "Ranking" 0
menuText P CrosstabSortScore "Punkty" 0
menuText P CrosstabSortCountry "Kraj" 0
menuText P CrosstabColor "Kolor" 0
menuText P CrosstabColorPlain "Zwyk�y tekst" 0
menuText P CrosstabColorHyper "Hipertekst" 0
menuText P CrosstabHelp "Pomoc" 2
menuText P CrosstabHelpCross "Tabela turniejowa" 0
menuText P CrosstabHelpIndex "Spis tre�ci" 0
translate P SetFilter {Ustaw filtr}
translate P AddToFilter {Dodaj do filtra}
translate P Swiss {Szwajcar}
translate P Category {Kategoria} 

# Opening report window menus:
menuText P OprepFile "Plik" 0
menuText P OprepFileText "Zapisz w pliku tekstowym..." 15
menuText P OprepFileHtml "Zapisz w pliku HTML..." 15
menuText P OprepFileLaTeX "Zapisz w pliku LaTeX-a..." 15
menuText P OprepFileOptions "Opcje" 2
menuText P OprepFileClose "Zamknij okno raportu" 0
menuText P OprepFavorites "Ulubione" 1 
menuText P OprepFavoritesAdd "Dodaj raport..." 0 
menuText P OprepFavoritesEdit "Modyfikuj ulubione..." 0
menuText P OprepFavoritesGenerate "Tw�rz raporty..." 0 
menuText P OprepHelp "Pomoc" 2
menuText P OprepHelpReport "Pomoc raportu debiutowego" 0
menuText P OprepHelpIndex "Spis tre�ci" 0

# Header search:
translate P HeaderSearch {Wyszukiwanie wg nag��wka}
translate P EndSideToMove {Strona na posuni�ciu po zako�czeniu partii}
translate P GamesWithNoECO {Partie bez ECO?}
translate P GameLength {D�ugo��}
translate P FindGamesWith {Znajd� partie}
translate P StdStart {ca�a partia}
translate P Promotions {z promocj�}
translate P Comments {Komentarze}
translate P Variations {Warianty}
translate P Annotations {Uwagi}
translate P DeleteFlag {Usuwanie}
translate P WhiteOpFlag {Debiut - bia�e}
translate P BlackOpFlag {Debiut - czarne}
translate P MiddlegameFlag {Gra �rodkowa}
translate P EndgameFlag {Ko�c�wka}
translate P NoveltyFlag {Nowinka}
translate P PawnFlag {Struktura pionowa}
translate P TacticsFlag {Taktyka}
translate P QsideFlag {Gra na skrzydle hetma�skim}
translate P KsideFlag {Gra na skrzydle kr�lewskim}
translate P BrilliancyFlag {Nagroda za pi�kno��}
translate P BlunderFlag {Podstawka}
translate P UserFlag {Inne}
translate P PgnContains {PGN zawiera tekst}

# Game list window:
translate P GlistNumber {Numer}
translate P GlistWhite {Bia�e}
translate P GlistBlack {Czarne}
translate P GlistWElo {B-Elo}
translate P GlistBElo {C-Elo}
translate P GlistEvent {Turniej}
translate P GlistSite {Miejsce}
translate P GlistRound {Runda}
translate P GlistDate {Data}
translate P GlistYear {Rok}
translate P GlistEDate {Turniej-Data}
translate P GlistResult {Wynik}
translate P GlistLength {D�ugo��}
translate P GlistCountry {Kraj}
translate P GlistECO {ECO}
translate P GlistOpening {Debiut}
translate P GlistEndMaterial {Materia�}
translate P GlistDeleted {Usuni�ta}
translate P GlistFlags {Oznaczenie}
translate P GlistVars {Warianty}
translate P GlistComments {Komentarze}
translate P GlistAnnos {Uwagi}
translate P GlistStart {Pozycja pocz�tkowa}
translate P GlistGameNumber {Numer partii}
translate P GlistFindText {Znajd� tekst}
translate P GlistMoveField {Przesu�}
translate P GlistEditField {Konfiguruj}
translate P GlistAddField {Dodaj}
translate P GlistDeleteField {Usu�}
translate P GlistWidth {Szeroko��}
translate P GlistAlign {Wyr�wnanie}
translate P GlistColor {Kolor}
translate P GlistSep {Separator}
translate P GlistRemoveThisGameFromFilter  {Usu� t� parti� z filtra}
translate P GlistRemoveGameAndAboveFromFilter  {Usu� t� i poprzednie partie z filtra}
translate P GlistRemoveGameAndBelowFromFilter  {Usu� t� i nast�pne partie z filtra}
translate P GlistDeleteGame {Usu�/przywr�� t� parti�} 
translate P GlistDeleteAllGames {Usu� wszystkie partie z filtra} 
translate P GlistUndeleteAllGames {Przywr�� wszystkie partie z filtra} 

# Maintenance window:
translate P DatabaseName {Nazwa bazy:}
translate P TypeIcon {Ikona:}
translate P NumOfGames {Liczba partii:}
translate P NumDeletedGames {Liczba usuni�tych partii:}
translate P NumFilterGames {Liczba partii w filtrze:}
translate P YearRange {Data:}
translate P RatingRange {Ranking:}
translate P Description {Opis} 
translate P Flag {Oznaczenie:}
translate P CustomFlags {Flagi u�ytkownika}
translate P DeleteCurrent {Usu� aktualn� parti�}
translate P DeleteFilter {Usu� partie z filtra}
translate P DeleteAll {Usu� wszystkie partie}
translate P UndeleteCurrent {Odzyskaj aktualn� parti�}
translate P UndeleteFilter {Odzyskaj partie z filtra}
translate P UndeleteAll {Odzyskaj wszystkie partie}
translate P DeleteTwins {Usu� powt�rzone partie}
translate P MarkCurrent {Zaznacz aktualn� parti�}
translate P MarkFilter {Zaznacz partie z filtra}
translate P MarkAll {Zaznacz wszystkie partie z filtra}
translate P UnmarkCurrent {Usu� zaznaczenie aktualnej partii}
translate P UnmarkFilter {Usu� zaznaczenie partii z filtra}
translate P UnmarkAll {Usu� zaznaczenie wszystkich partii}
translate P Spellchecking {Pisownia}
translate P Players {Zawodnicy}
translate P Events {Turnieje}
translate P Sites {Miejsca}
translate P Rounds {Rundy}
translate P DatabaseOps {Operacje bazodanowe}
translate P ReclassifyGames {Klasyfikacja debiutowa}
translate P CompactDatabase {Uporz�dkuj baz�}
translate P SortDatabase {Sortuj baz�}
translate P AddEloRatings {Dodaj rankingi ELO}
translate P AutoloadGame {Domy�lna partia}
translate P StripTags {Usu� znaczniki PGN} 
translate P StripTag {Usu� znacznik}
translate P CheckGames {Sprawd� partie}
translate P Cleaner {Zestaw zada�}
translate P CleanerHelp {
Zestaw zada� pozwala wykona� od razu kilka operacji porz�dkowania bazy. Operacje wybrane z listy
zostan� wykonane na aktualnej bazie.

Do klasyfikacji debiutowej i usuwania powt�rzonych partii u�yte zostan� aktualne ustawienia.
}
translate P CleanerConfirm {
Kiedy wykonanie zestawu zada� zostanie rozpocz�te, nie b�dzie mo�na ju� go przerwa�.

Na du�ej bazie mo�e to zaj�� du�o czasu (zale�y to r�wnie� od wybranego zestawu zada� i ich
ustawie�).

Na pewno wykona� wybrane zadania?
}
translate P TwinCheckUndelete {�eby prze��czy�; "u" przywraca obie)}
translate P TwinCheckprevPair {Poprzednia para}
translate P TwinChecknextPair {Nast�pna para}
translate P TwinChecker {Scid: wyszukiwarka powt�rzonych partii}
translate P TwinCheckTournament {Partie w turnieju:}
translate P TwinCheckNoTwin {Bez powt�rze�  }
translate P TwinCheckNoTwinfound {Brak powt�rze� tej partii.\n�eby zobaczy� powt�rzone partie, u�yj najpierw funkcji "Znajd� powt�rzone partie...". }
translate P TwinCheckTag {Dziel znaczniki...}
translate P TwinCheckFound1 {Scid znalaz� $result powt�rzonych partii}
translate P TwinCheckFound2 { i ustawi� ich flag� usuni�cia}
translate P TwinCheckNoDelete {W tej bazie brak partii do usuni�cia.}
translate P TwinCriteria1 { Aktualne ustawienia do wyszukiwania powt�rze� mog� spowodowa�\noznaczenie r�nych partii o podobnym przebiegu jako powt�rze�.}
translate P TwinCriteria2 {Przy ustawieniu "Nie" dla "tych samych posuni��", zaleca si� wybranie "Tak" dla koloru, turnieju, miejsca, rundy, roku i miesi�ca.\nCzy kontynuowa� i usun�� powt�rzone partie? }
translate P TwinCriteria3 {Zaleca si� wybranie "Tak" przynajmniej dla dw�ch z opcji: "to samo miejsce", "ta sama runda" i "ten sam rok".\nCzy kontynuowa� i usun�� powt�rzone partie?}
translate P TwinCriteriaConfirm {Scid: potwierd� ustawienia wyszukiwania powt�rze�}
translate P TwinChangeTag "Zmie� nast�puj�ce znaczniki:\n\n"
translate P AllocRatingDescription "To polecenie u�ywa aktualnego pliku do sprawdzania pisowni, �eby doda� rankingi Elo do partii w bazie. Je�li gracz nie ma przypisanego rankingu, ale plik pisowni zawiera potrzebne informacje, ranking zostanie dodany."
translate P RatingOverride "Zast�pi� istniej�ce rankingi?"
translate P AddRatings "Dodaj rankingi do:"
translate P AddedRatings {Scid doda� $r ranking�w Elo w $g partiach.}
translate P NewSubmenu "Nowe podmenu"

# Comment editor:
translate P AnnotationSymbols  {Symbole:}
translate P Comment {Komentarz:}
translate P InsertMark {Wstaw znak}
translate P InsertMarkHelp {
Dodaj/usu� znacznik: wybierz kolor, typ i pole.
Dodaj/usu� strza�k�: kliknij prawym przyciskiem na dw�ch polach.
} 

# Nag buttons in comment editor:
translate P GoodMove {Silne posuni�cie}
translate P PoorMove {S�abe posuni�cie}
translate P ExcellentMove {Znakomite posuni�cie}
translate P Blunder {Podstawka}
translate P InterestingMove {Ciekawe posuni�cie}
translate P DubiousMove {W�tpliwe posuni�cie}
translate P WhiteDecisiveAdvantage {Bia�e maj� decyduj�c� przewag�} 
translate P BlackDecisiveAdvantage {Czarne maj� decyduj�c� przewag�} 
translate P WhiteClearAdvantage {Bia�e maj� wyra�n� przewag�} 
translate P BlackClearAdvantage {Czarne  maj� wyra�n� przewag�} 
translate P WhiteSlightAdvantage {Bia�e maj� niewielk� przewag�} 
translate P BlackSlightAdvantage {Czarne maj� niewielk� przewag�}
translate P Equality {R�wnowaga} 
translate P Unclear {Niejasna pozycja}
translate P Diagram {Diagram}

# Board search:
translate P BoardSearch {Wyszukiwanie wg pozycji}
translate P FilterOperation {Operacje na aktualnym filtrze:}
translate P FilterAnd {I (ogranicz filtr)}
translate P FilterOr {LUB (dodaj do filtra)}
translate P FilterIgnore {NOWY (ignoruj poprzedni filtr)}
translate P SearchType {Typ wyszukiwania:}
translate P SearchBoardExact {Identyczna pozycja (bierki na tych samych polach)}
translate P SearchBoardPawns {Pionki (ten sam materia�, pionki na tych samych polach)}
translate P SearchBoardFiles {Kolumny (ten sam materia�, pionki na tych samych kolumnach)}
translate P SearchBoardAny {Materia� (ten sam materia�, pozycja dowolna)}
# ====== TODO To be translated ======
translate P SearchInRefDatabase { Search in base }
translate P LookInVars {Przeszukuj warianty}

# Material search:
translate P MaterialSearch {Wyszukiwanie wg materia�u}
translate P Material {Materia�}
translate P Patterns {Wzorce}
translate P Zero {Brak}
translate P Any {Dowolny}
translate P CurrentBoard {Aktualna pozycja}
translate P CommonEndings {Typowe ko�c�wki}
translate P CommonPatterns {Typowe wzorce}
translate P MaterialDiff {Przewaga materialna}
translate P squares {pola}
translate P SameColor {jednopolowe}
translate P OppColor {r�nopolowe}
translate P Either {dowolne}
translate P MoveNumberRange {Zakres posuni��}
translate P MatchForAtLeast {Pasuje min.}
translate P HalfMoves {p�ruchy}

# Common endings in material search:
translate P EndingPawns {Ko�c�wki pionowe} 
translate P EndingRookVsPawns {Wie�a na pion(y)} 
translate P EndingRookPawnVsRook {Wie�a i pion na wie��}
translate P EndingRookPawnsVsRook {Wie�a i pion(y) na wie��}
translate P EndingRooks {Ko�c�wki wie�owe}
translate P EndingRooksPassedA {Ko�c�wki wie�owe z wolnym pionem a}
translate P EndingRooksDouble {Ko�c�wki czterowie�owe}
translate P EndingBishops {Ko�c�wki go�cowe}
translate P EndingBishopVsKnight {Ko�c�wki goniec na skoczka}
translate P EndingKnights {Ko�c�wki skoczkowe}
translate P EndingQueens {Ko�c�wki hetma�skie}
translate P EndingQueenPawnVsQueen {Hetman i pion na hetmana}
translate P BishopPairVsKnightPair {Dwa go�ce na dwa skoczki w grze �rodkowej}

# Common patterns in material search:
translate P PatternWhiteIQP {Izolowany pion u bia�ych} 
translate P PatternWhiteIQPBreakE6 {Izolowowany pion u bia�ych: prze�om d4-d5 przy pionku e6}
translate P PatternWhiteIQPBreakC6 {Izolowowany pion u bia�ych: prze�om d4-d5 przy pionku c6}
translate P PatternBlackIQP {Izolowany pion u czarnych}
translate P PatternWhiteBlackIQP {Izolowane piony u obu stron}
translate P PatternCoupleC3D4 {Wisz�ce bia�e piony c3+d4}
translate P PatternHangingC5D5 {Wisz�ce czarne piony c5+d5}
translate P PatternMaroczy {Struktura Maroczego (piony na c4 i e4)} 
translate P PatternRookSacC3 {Ofiara wie�y na c3}
translate P PatternKc1Kg8 {R�nostronne roszady (Kc1 i Kg8)}
translate P PatternKg1Kc8 {R�nostronne roszady (Kg1 i Kc8)}
translate P PatternLightFian {Bia�opolowe fianchetto (Gg2 i Gb7)}
translate P PatternDarkFian {Czarnopolowe fianchetto (Gb2 i Gg7)}
translate P PatternFourFian {Poczw�rne fianchetto (go�ce na b2, g2, b7, g7)}

# Game saving:
translate P Today {Dzisiaj}
translate P ClassifyGame {Klasyfikacja debiutowa}

# Setup position:
translate P EmptyBoard {Pusta szachownica}
translate P InitialBoard {Pozycja pocz�tkowa}
translate P SideToMove {Na posuni�ciu}
translate P MoveNumber {Posuni�cie nr}
translate P Castling {Roszada}
translate P EnPassantFile {Bicie w przelocie}
translate P ClearFen {Kopiuj FEN}
translate P PasteFen {Wklej pozycj� FEN}
translate P SaveAndContinue {Zapisz i kontynuuj}
translate P DiscardChangesAndContinue {Porzu� zmiany\ni kontynuuj}
translate P GoBack {Anuluj}

# Replace move dialog:
translate P ReplaceMove {Zmie� posuni�cie}
translate P AddNewVar {Dodaj wariant}
translate P NewMainLine {Nowy wariant g��wny}
translate P ReplaceMoveMessage {Posuni�cie ju� istnieje.

Mo�esz je zast�pi�, usuwaj�c dalszy ci�g partii lub doda� nowy wariant.

(Mo�na wy��czy� to ostrze�enie, wy��czaj�c opcj�  "Zapytaj przed zast�pieniem posuni��" w menu
Opcje:Posuni�cia)}

# Make database read-only dialog:
translate P ReadOnlyDialog {Je�li zabezpieczysz t� baz� przed zapisem, zmiany b�d� zablokowane
�adna partia nie b�dzie zapisana ani zmodyfikowana, �adne flagi nie b�d� zmienione.
Sortowanie i klasyfikacja debiutowa b�d� tylko tymczasowe.

�eby usun�� zabezpieczenie przez zapisem, wystarczy zamkn�� baz� i otworzy� j� ponownie.

Na pewno zabezpieczy� baz� przed zapisem?}

# Clear game dialog:
translate P ClearGameDialog {Partia zosta�a zmieniona.

Na pewno kontynuowa�, rezygnuj�c z wszelkich zmian?
}

# Exit dialog:
translate P ExitDialog {Na pewno zako�czy� prac� z programem?}
translate P ExitUnsaved {Nast�puj�ce bazy zawieraj� niezapisane zmiany. Je�li zamkniesz program teraz, zmiany zostan� utracone.} 

# Import window:
translate P PasteCurrentGame {Wklej aktualn� parti�}
translate P ImportHelp1 {Wprowad� lub wklej parti� w formacie PGN w poni�sz� ramk�.}
translate P ImportHelp2 {Tu b�d� wy�wietlane b��dy przy importowaniu partii.}
translate P OverwriteExistingMoves {Zast�pi� istniej�ce posuni�cia?}

# ECO Browser:
translate P ECOAllSections {Wszystkie kody ECO}
translate P ECOSection {Cz�� ECO}
translate P ECOSummary {Podsumowanie dla}
translate P ECOFrequency {Cz�sto�ci kod�w dla}

# Opening Report:
translate P OprepTitle {Raport debiutowy}
translate P OprepReport {Raport}
translate P OprepGenerated {Utworzony przez}
translate P OprepStatsHist {Statystyka i historia}
translate P OprepStats {Statystyka}
translate P OprepStatAll {Wszystkie partie}
translate P OprepStatBoth {Obaj zawodnicy z Elo}
translate P OprepStatSince {Od}
translate P OprepOldest {Najdawniejsze partie}
translate P OprepNewest {Ostatnie partie}
translate P OprepPopular {Popularno��}
translate P OprepFreqAll {Cz�sto�� w ca�ej bazie:         }
translate P OprepFreq1   {W ostatnim roku:                }
translate P OprepFreq5   {W ostatnich pi�ciu latach:      }
translate P OprepFreq10  {W ostatnich dziesi�ciu latach:  }
translate P OprepEvery {co %u partii}
translate P OprepUp {wi�cej o %u%s ni� w ca�ej bazie}
translate P OprepDown {mniej o %u%s ni� w ca�ej bazie}
translate P OprepSame {jak w ca�ej bazie}
translate P OprepMostFrequent {Gracze najcz�ciej stosuj�cy wariant}
translate P OprepMostFrequentOpponents {Przeciwnicy} 
translate P OprepRatingsPerf {Rankingi i wyniki}
translate P OprepAvgPerf {�rednie rankingi i wyniki}
translate P OprepWRating {Ranking bia�ych}
translate P OprepBRating {Ranking czarnych}
translate P OprepWPerf {Wynik bia�ych}
translate P OprepBPerf {Wynik czarnych}
translate P OprepHighRating {Partie graczy o najwy�szym �rednim rankingu}
translate P OprepTrends {Wyniki}
translate P OprepResults {D�ugo�� partii i cz�sto�ci}
translate P OprepLength {D�ugo�� partii}
translate P OprepFrequency {Cz�sto��}
translate P OprepWWins {Zwyci�stwa bia�ych:  }
translate P OprepBWins {Zwyci�stwa czarnych: }
translate P OprepDraws {Remisy:              }
translate P OprepWholeDB {ca�a baza}
translate P OprepShortest {Najkr�tsze zwyci�stwa}
translate P OprepMovesThemes {Posuni�cia i motywy}
translate P OprepMoveOrders {Posuni�cia prowadz�ce do badanej pozycji}
translate P OprepMoveOrdersOne \
  {Badana pozycja powstawa�a jedynie po posuni�ciach:}
translate P OprepMoveOrdersAll \
  {Badana pozycja powstawa�a na %u sposob�w:}
translate P OprepMoveOrdersMany \
  {Badana pozycja powstawa�a na %u sposob�w. Najcz�stsze %u to:}
translate P OprepMovesFrom {Posuni�cia w badanej pozycji}
translate P OprepMostFrequentEcoCodes {Najcz�stsze kody ECO} 
translate P OprepThemes {Motywy pozycyjne}
translate P OprepThemeDescription {Cz�sto�� motyw�w w pierwszych %u posuni�ciach partii} 
translate P OprepThemeSameCastling {Jednostronne roszady}
translate P OprepThemeOppCastling {R�nostronne roszady}
translate P OprepThemeNoCastling {Obie strony bez roszady}
translate P OprepThemeKPawnStorm {Atak pionowy na skrzydle kr�lewskim}
translate P OprepThemeQueenswap {Wymiana hetman�w}
translate P OprepThemeWIQP {Izolowany pion bia�ych} 
translate P OprepThemeBIQP {Izolowany pion czarnych}
translate P OprepThemeWP567 {Bia�y pion na 5/6/7 linii}
translate P OprepThemeBP234 {Czarny pion na 2/3/4 linii}
translate P OprepThemeOpenCDE {Otwarta kolumna c/d/e}
translate P OprepTheme1BishopPair {Jedna ze stron ma par� go�c�w}
translate P OprepEndgames {Ko�c�wki}
translate P OprepReportGames {Partie raportu}
translate P OprepAllGames {Wszystkie partie}
translate P OprepEndClass {Materia� w pozycji ko�cowej}
translate P OprepTheoryTable {Teoria}
translate P OprepTableComment {Utworzono z %u partii o najwy�szym �rednim rankingu.}
translate P OprepExtraMoves {Dodatkowe posuni�cia w przypisach}
translate P OprepMaxGames {Maksymalna liczba partii w teorii}
translate P OprepViewHTML {�r�d�o HTML} 
translate P OprepViewLaTeX {�r�d�o LaTeX} 

# Player Report:
translate P PReportTitle {Raport o graczu}
translate P PReportColorWhite {bia�ymi}
translate P PReportColorBlack {czarnymi}
translate P PReportMoves {po %s}
translate P PReportOpenings {Debiuty}
translate P PReportClipbase {Wyczy�� schowek i skopiuj do niego wybrane partie}

# Piece Tracker window:
translate P TrackerSelectSingle {Lewy przycisk wybiera t� figur�.}
translate P TrackerSelectPair {Lewy przycisk wybiera t� figur�; prawy obie takie figury.}
translate P TrackerSelectPawn {Lewy przycisk wybiera tego piona; prawy wszystkie 8 pion�w.}
translate P TrackerStat {Statystyka}
translate P TrackerGames {% partie z posuni�ciem na tym pole}
translate P TrackerTime {% czasu na tym polu}
translate P TrackerMoves {Posuni�cia}
translate P TrackerMovesStart {Podaj numer posuni�cia, od kt�rego zacz�� �ledzenie.}
translate P TrackerMovesStop {Podaj numer posuni�cia, na kt�rym sko�czy� �ledzenie.}

# Game selection dialogs:
translate P SelectAllGames {Wszystkie partie w bazie}
translate P SelectFilterGames {Partie w filtrze}
translate P SelectTournamentGames {Tylko partie z aktualnego turnieju}
translate P SelectOlderGames {Tylko wcze�niejsze partie}

# Delete Twins window:
translate P TwinsNote {Partie zostan� uznane za identyczne, je�li zosta�y rozegrane przez tych samych graczy i spe�niaj� ustawione poni�ej kryteria. Kr�tsza z partii zostanie usuni�ta. Uwaga: dobrze przez wyszukaniem powt�rzonych partii sprawdzi� pisowni� nazwisk.}
translate P TwinsCriteria {Kryteria: co musi by� jednakowe w obu partiach?}
translate P TwinsWhich {Przeszukiwane partie}
translate P TwinsColors {Kolory}
translate P TwinsEvent {Turniej:}
translate P TwinsSite {Miejsce:}
translate P TwinsRound {Runda:}
translate P TwinsYear {Rok:}
translate P TwinsMonth {Miesi�c:}
translate P TwinsDay {Dzie�:}
translate P TwinsResult {Wynik:}
translate P TwinsECO {Kod ECO:}
translate P TwinsMoves {Posuni�cia:}
translate P TwinsPlayers {Por�wnywanie nazwisk:}
translate P TwinsPlayersExact {Dok�adne}
translate P TwinsPlayersPrefix {Tylko pierwsze 4 litery}
translate P TwinsWhen {Usuwanie znalezionych powt�rzonych partii}
translate P TwinsSkipShort {Pomija� partie kr�tsze ni� 5 posuni��?}
translate P TwinsUndelete {Odzyska� wszystkie partie przed poszukiwaniem?}
translate P TwinsSetFilter {Wstawi� wszystkie usuni�te partie do filtra?}
translate P TwinsComments {Zawsze zachowywa� partie komentowane?}
translate P TwinsVars {Zawsze zachowywa� partie z wariantami?}
translate P TwinsDeleteWhich {Kt�r� parti� usun��:} 
translate P TwinsDeleteShorter {Kr�tsz�} 
translate P TwinsDeleteOlder {O ni�szym numerze}
translate P TwinsDeleteNewer {O wy�szym numerze}
translate P TwinsDelete {Usu� partie}

# Name editor window:
translate P NameEditType {Nazwa do wyboru}
translate P NameEditSelect {Partie do edycji}
translate P NameEditReplace {Zast�p}
translate P NameEditWith {przez}
translate P NameEditMatches {Pasuj�ce: Ctrl+1 do Ctrl+9 wybiera}
translate P CheckGames {Sprawd� partie}
translate P CheckGamesWhich {Sprawd� partie}
translate P CheckAll {Wszystkie}
translate P CheckSelectFilterGames {Tylko partie z filtra}

# Classify window:
translate P Classify {Przyporz�dkowanie ECO}
translate P ClassifyWhich {Partie do przyporz�dkowania ECO}
translate P ClassifyAll {Wszystkie partie (zmiana starych kod�w ECO)}
translate P ClassifyYear {Wszystkie partie z ostatniego roku}
translate P ClassifyMonth {Wszystkie partie z ostatniego miesi�ca}
translate P ClassifyNew {Tylko partie bez kodu ECO}
translate P ClassifyCodes {Kody ECO}
translate P ClassifyBasic {Tylko podstawowe ("B12", ...)}
translate P ClassifyExtended {Rozszerzone kody Scida ("B12j", ...)}

# Compaction:
translate P NameFile {Plik nazw}
translate P GameFile {Plik z partiami}
translate P Names {Nazwy}
translate P Unused {Nieu�ywane}
translate P SizeKb {Rozmiar (kb)}
translate P CurrentState {Status}
translate P AfterCompaction {Po uporz�dkowaniu}
translate P CompactNames {Uporz�dkuj nazwy}
translate P CompactGames {Uporz�dkuj partie}
translate P NoUnusedNames "Brak nieu�ywanych nazw, plik nazw jest ju� uporz�dkowany."
translate P NoUnusedGames "Plik partii jest ju� uporz�dkowany."
translate P NameFileCompacted {Plik nazw dla bazy "[file tail [sc_base filename]]" zosta� uporz�dkowany.}
translate P GameFileCompacted {Plik partii dla bazy "[file tail [sc_base filename]]" zosta� uporz�dkowany.}

# Sorting:
translate P SortCriteria {Kryteria sortowania}
translate P AddCriteria {Dodaj kryteria}
translate P CommonSorts {Standardowe kryteria}
translate P Sort {Sortuj}

# Exporting:
translate P AddToExistingFile {Doda� partie do pliku?}
translate P ExportComments {Eksportowa� komentarze?}
translate P ExportVariations {Eksportowa� warianty?}
translate P IndentComments {Wcinaj komentarze?}
translate P IndentVariations {Wcinaj warianty?}
translate P ExportColumnStyle {Kolumny (jedno posuni�cie w wierszu)?}
translate P ExportSymbolStyle {Styl znak�w komentarza:}
translate P ExportStripMarks {Usuwa� z komentarzy kody kolorowania p�l/strza�ek?} 

# Goto game/move dialogs:
translate P LoadGameNumber {Podaj numer partii do wczytania:}
translate P GotoMoveNumber {Id� do posuni�cia nr:}

# Copy games dialog:
translate P CopyGames {Kopiuj partie}
translate P CopyConfirm {
 Czy na pewno skopiowa�
 [::utils::thousands $nGamesToCopy] partii z filtra
 w bazie "$fromName"
 do bazy "$targetName"?
}
translate P CopyErr {Nie mo�na skopiowa� partii}
translate P CopyErrSource {baza �r�d�owa}
translate P CopyErrTarget {baza docelowa}
translate P CopyErrNoGames {nie ma partii w filtrze}
translate P CopyErrReadOnly {jest tylko do odczytu}
translate P CopyErrNotOpen {nie jest otwarta}

# Colors:
translate P LightSquares {Jasne pola}
translate P DarkSquares {Ciemne pola}
translate P SelectedSquares {Wybrane pola}
translate P SuggestedSquares {Wybrane posuni�cie}
# todo
translate P Grid {Grid}
translate P Previous {Poprzednie}
translate P WhitePieces {Bia�e figury}
translate P BlackPieces {Czarne figury}
translate P WhiteBorder {Kontur bia�ych figur}
translate P BlackBorder {Kontur czarnych figur}
translate P ArrowMain   {Main Arrow}
translate P ArrowVar    {Var Arrows}

# Novelty window:
translate P FindNovelty {Znajd� nowink�}
translate P Novelty {Nowinka}
translate P NoveltyInterrupt {Poszukiwanie nowinki przerwano}
translate P NoveltyNone {Nie znaleziono nowinki w partii}
translate P NoveltyHelp {
Scid znajdzie pierwsze posuni�cie w partii, po kt�rym powstanie pozycja niewyst�puj�ca ani w bazie, ani w ksi��ce debiutowej.
}

# Sounds configuration:
translate P SoundsFolder {Katalog plik�w d�wi�kowych}
translate P SoundsFolderHelp {Katalog powinien zawiera� pliki King.wav, a.wav, 1.wav itd.}
translate P SoundsAnnounceOptions {Ustawienia og�aszania posuni��}
translate P SoundsAnnounceNew {Og�aszaj nowe posuni�cia}
translate P SoundsAnnounceForward {Og�aszaj posuni�cia przy przegl�daniu}
translate P SoundsAnnounceBack {Og�aszaj posuni�cia przy cofaniu}

# Upgrading databases:
translate P Upgrading {Konwersja}
translate P ConfirmOpenNew {
Ta baza jest zapisana w starym formacie (Scid 2) i nie mo�e zosta� otwarta w nowszej wersji
Scid-a. Baza zosta�a ju� automatycznie przekonwertowana do nowego formatu.

Czy otworzy� now� wersj� bazy?
}
translate P ConfirmUpgrade {
Ta baza jest zapisana w starym formacie (Scid 2) i nie mo�e zosta� otwarta w nowszej wersji Scid-a. �eby m�c otworzy� baz�, trzeba przekonwertowa� j� do nowego formatu.

Konwersja utworzy now� wersj� bazy - stara wersja nie zostanie zmieniona ani usuni�ta.

Mo�e to zaj�� troch� czasu, ale jest to operacja jednorazowa. Mo�esz j� przerwa�, je�li potrwa za d�ugo.

Przekonwertowa� baz�?
}

# Recent files options:
translate P RecentFilesMenu {Liczba ostatnich plik�w w menu Plik} 
translate P RecentFilesExtra {Liczba ostatnich plik�w w dodatkowym podmenu} 

# My Player Names options:
translate P MyPlayerNamesDescription {
Podaj list� preferowanych nazwisk graczy, po jednym w wierszu. W nazwiskach mo�na stosowa� znaki specjalne (np. "?" - dowolny znak, "*" - dowolna sekwencja znak�w).

Wszystkie partie grane przez jednego z graczy z listy b�d� wy�wietlane z jego perspektywy.
}
translate P showblunderexists {poka� b��d}
translate P showblundervalue {poka� wag� b��du}
translate P showscore {poka� ocen�}
translate P coachgame {partia treningowa}
translate P configurecoachgame {konfiguruj parti� treningow�}
translate P configuregame {Konfiguracja partii}
translate P Phalanxengine {Program Phalanx}
translate P Coachengine {Program treningowy}
translate P difficulty {poziom trudno�ci}
translate P hard {wysoki}
translate P easy {niski}
translate P Playwith {Graj}
translate P white {bia�ymi}
translate P black {czarnymi}
translate P both {oboma kolorami}
translate P Play {Gra}
translate P Noblunder {Bez b��d�w}
translate P blunder {b��d}
translate P Noinfo {-- Brak informacji --}
translate P PhalanxOrTogaMissing {Brak programu Phalanx lub Toga}
translate P moveblunderthreshold {move is a blunder if loss is greater than}
translate P limitanalysis {ogranicz czas analizy}
translate P seconds {sekund}
translate P Abort {Przerwij}
translate P Resume {Wzn�w}
translate P OutOfOpening {Po debiucie}
translate P NotFollowedLine {Nie gra�e� wariantu}
translate P DoYouWantContinue {Na pewno kontynuowa�?}
translate P CoachIsWatching {Trener si� przygl�da}
translate P Ponder {Ci�g�e my�lenie}
translate P LimitELO {Ogranicz si�� Elo}
translate P DubiousMovePlayedTakeBack {Zagra�e� w�tpliwe posuni�cie, chcesz je cofn��?}
translate P WeakMovePlayedTakeBack {Zagra�e� s�abe posuni�cie, chcesz je cofn��?}
translate P BadMovePlayedTakeBack {Zagra�e� bardzo s�abe posuni�cie, chcesz je cofn��?}
translate P Iresign {Poddaj� si�}
translate P yourmoveisnotgood {twoje posuni�cie nie jest dobre}
translate P EndOfVar {Koniec wariantu}
translate P Openingtrainer {Trening debiutowy}
translate P DisplayCM {Poka� ruchy-kandydaty}
translate P DisplayCMValue {Poka� ocen� ruch�w-kandydat�w}
translate P DisplayOpeningStats {Poka� statystyk�}
translate P ShowReport {Poka� raport}
translate P NumberOfGoodMovesPlayed {liczba dobrych posuni��}
translate P NumberOfDubiousMovesPlayed {liczba w�tpliwych posuni��}
translate P NumberOfTimesPositionEncountered {liczba wyst�pie� pozycji}
translate P PlayerBestMove  {Tylko najlepsze posuni�cia}
translate P OpponentBestMove {Przeciwnik gra najlepsze posuni�cia}
translate P OnlyFlaggedLines {Tylko zaznaczone warianty}
translate P resetStats {Wyczy�� statystyk�}
translate P Movesloaded {Posuni�cia wczytane}
translate P PositionsNotPlayed {Pozycje nie rozgrywane}
translate P PositionsPlayed {Pozycje rozgrywane}
translate P Success {Sukces}
translate P DubiousMoves {W�tpliwe posuni�cia}
translate P ConfigureTactics {Konfiguruj taktyk�}
translate P ResetScores {Wyczy�� punkty}
translate P LoadingBase {Wczytaj baz�}
translate P Tactics {Taktyka}
translate P ShowSolution {Poka� rozwi�zanie}
translate P Next {Nast�pne}
translate P ResettingScore {Czyszczenie punkt�w}
translate P LoadingGame {Wczytywanie partii}
translate P MateFound {Znaleziono mata}
translate P BestSolutionNotFound {Nie znaleziono rozwi�zania!}
translate P MateNotFound {Nie znaleziono mata}
translate P ShorterMateExists {Istnieje kr�tsze rozwi�zanie}
translate P ScorePlayed {Ocena zagranego posuni�cia}
translate P Expected {oczekiwana ocena}
translate P ChooseTrainingBase {Wybierz baz� treningow�}
translate P Thinking {Analiza}
translate P AnalyzeDone {Analiza zako�czona}
translate P WinWonGame {Wygraj wygran� parti�}
translate P Lines {Warianty}
translate P ConfigureUCIengine {Konfiguruj program UCI}
translate P SpecificOpening {Wybrany program}
translate P StartNewGame {Rozpocznij now� parti�}
translate P FixedLevel {Sta�y poziom}
translate P Opening {Debiut}
translate P RandomLevel {Losowy poziom}
translate P StartFromCurrentPosition {Rozpocznij od aktualnej pozycji}
translate P FixedDepth {Sta�a g��boko��}
translate P Nodes {Pozycje} 
translate P Depth {G��boko��}
translate P Time {Czas} 
translate P SecondsPerMove {Sekundy na posuni�cie}
translate P Engine {Program}
translate P TimeMode {Tempo gry}
translate P TimeBonus {Czas + inkrement}
translate P TimeMin {min}
translate P TimeSec {s}
translate P AllExercisesDone {Wszystkie zadania zako�czone}
translate P MoveOutOfBook {Posuni�cie spoza ksi��ki debiutowej}
translate P LastBookMove {Ostatnie posuni�cie w ksi��ce debiutowej}
translate P AnnotateSeveralGames {Komentuj kilka partii\nod aktualnej do:}
translate P FindOpeningErrors {Znajd� b��dy debiutowe}
translate P MarkTacticalExercises {Oznacz zadania taktyczne}
translate P UseBook {U�yj ksi��ki debiutowej}
translate P MultiPV {Wiele wariant�w}
translate P Hash {Pami�� bufora}
translate P OwnBook {U�yj ksi��ki debiutowej programu}
translate P BookFile {Ksi��ka debiutowa}
translate P AnnotateVariations {Komentuj warianty}
translate P ShortAnnotations {Skr�cone komentarze}
translate P addAnnotatorTag {Dodaj znacznik komentatora}
translate P AddScoreToShortAnnotations {Dodaj ocen� do skr�conych komentarzy}
translate P Export {Eksportuj}
translate P BookPartiallyLoaded {Ksi��ka cz�ciowo wczytana}
translate P Calvar {Liczenie wariant�w}
translate P ConfigureCalvar {Konfiguracja}
translate P Reti {Debiut Reti}
translate P English {Partia angielska}
translate P d4Nf6Miscellaneous {1.d4 Nf6 inne}
translate P Trompowsky {Trompowsky}
translate P Budapest {Gambit budapeszte�ski}
translate P OldIndian {Obrona staroindyjska}
translate P BenkoGambit {Gambit wo��a�ski}
translate P ModernBenoni {Modern Benoni}
translate P DutchDefence {Obrona holenderska}
translate P Scandinavian {Obrona skandynawska}
translate P AlekhineDefence {Obrona Alechina}
translate P Pirc {Obrona Pirca}
translate P CaroKann {Obrona Caro-Kann}
translate P CaroKannAdvance {Obrona Caro-Kann, 3.e5}
translate P Sicilian {Obrona sycylijska}
translate P SicilianAlapin {Obrona sycylijska, wariant A�apina}
translate P SicilianClosed {Obrona sycylijska, wariant zamkni�ty}
translate P SicilianRauzer {Obrona sycylijska, wariant Rauzera}
translate P SicilianDragon {Obrona sycylijska, wariant smoczy}
translate P SicilianScheveningen {Obrona sycylijska, wariant Scheveningen}
translate P SicilianNajdorf {Obrona sycylijska, wariant Najdorfa}
translate P OpenGame {Debiuty otwarte}
translate P Vienna {Partia wiede�ska}
translate P KingsGambit {Gambit kr�lewski}
translate P RussianGame {Partia rosyjska}
translate P ItalianTwoKnights {Partia w�oska/obrona dw�ch skoczk�w}
translate P Spanish {Partia hiszpa�ska}
translate P SpanishExchange {Partia hiszpa�ska, wariant wymienny}
translate P SpanishOpen {Partia hiszpa�ska, wariant otwarty}
translate P SpanishClosed {Partia hiszpa�ska, wariant zamkni�ty}
translate P FrenchDefence {Obrona francuska}
translate P FrenchAdvance {Obrona francuska, 3.e5}
translate P FrenchTarrasch {Obrona francuska, wariant Tarrascha}
translate P FrenchWinawer {Obrona francuska, wariant Winawera}
translate P FrenchExchange {Obrona francuska, wariant wymienny}
translate P QueensPawn {Debiut piona hetma�skiego}
translate P Slav {Obrona s�owia�ska}
translate P QGA {Przyj�ty gambit hetma�ski}
translate P QGD {Nieprzyj�ty gabit hetma�ski}
translate P QGDExchange {Gambit hetma�ski, wariant wymienny}
translate P SemiSlav {Obrona p�s�owia�ska}
translate P QGDwithBg5 {Gambit hetma�ski z Bg5}
translate P QGDOrthodox {Gambit hetma�ski, wariant ortodoksalny}
translate P Grunfeld {Obrona Gr�nfelda}
translate P GrunfeldExchange {Obrona Gr�nfeld, wariant wymienny}
translate P GrunfeldRussian {Obrona Gr�nfelda, wariant rosyjski}
translate P Catalan {Partia katalo�ska}
translate P CatalanOpen {Partia katalo�ska, wariant otwarty}
translate P CatalanClosed {Partia katalo�ska, wariant zamkni�ty}
translate P QueensIndian {Obrona hetma�sko-indyjska}
translate P NimzoIndian {Obrona Nimzowitscha}
translate P NimzoIndianClassical {Obrona Nimzowitscha, wariant klasyczny}
translate P NimzoIndianRubinstein {Obrona Nimzowitscha, wariant Rubinsteina}
translate P KingsIndian {Obrona kr�lewsko-indyjska}
translate P KingsIndianSamisch {Obrona kr�lewsko-indyjska, wariant S�mischa}
translate P KingsIndianMainLine {Obrona kr�lewsko-indyjska, wariant g��wny}

# FICS todo
translate P ConfigureFics {Konfiguruj FICS}
translate P FICSLogin {Zaloguj si�}
translate P FICSGuest {Zaloguj si� jako go��}
translate P FICSServerPort {Port serwera}
translate P FICSServerAddress {Adres IP}
translate P FICSRefresh {Od�wie�}
translate P FICSTimeseal {Timeseal}
translate P FICSTimesealPort {Port Timeseal}
translate P FICSSilence {Filtr konsoli}
translate P FICSOffers {Propozycje}
translate P FICSGames {Partie}
translate P FICSFindOpponent {Znajd� przeciwnika}
translate P FICSTakeback {Cofnij}
translate P FICSTakeback2 {Cofnij 2}
translate P FICSInitTime {Czas (min)}
translate P FICSIncrement {Inkrement (sec)}
translate P FICSRatedGame {Partia liczona do rankingu}
translate P FICSAutoColour {Automatycznie}
translate P FICSManualConfirm {Potwierd� r�cznie}
translate P FICSFilterFormula {Filtruj przy u�yciu formu�y}
translate P FICSIssueSeek {Szukaj przeciwnika}
translate P FICSAccept {Akceptuj}
translate P FICSDecline {Odrzu�}
translate P FICSColour {Kolor}
translate P FICSSend {Wy�lij}
translate P FICSConnect {Po��cz}

translate P CCDlgConfigureWindowTitle {Konfiguruj gr� korespondencyjn�}
translate P CCDlgCGeneraloptions {Ustawienia og�lne}
translate P CCDlgDefaultDB {Domy�lna baza:}
translate P CCDlgInbox {Skrzynka odbiorcza (�cie�ka):}
translate P CCDlgOutbox {Skrzynka nadawcza (�cie�ka):}
translate P CCDlgXfcc {Konfiguracja Xfcx:}
translate P CCDlgExternalProtocol {Zewn�trzna obs�uga protoko��w (np. Xfcc)}
translate P CCDlgFetchTool {Narz�dzie pobierania:}
translate P CCDlgSendTool {Narz�dzie wysy�ania:}
translate P CCDlgEmailCommunication {Komunikacja e-mail}
translate P CCDlgMailPrg {Program pocztowy:}
translate P CCDlgBCCAddr {Adres (U)DW:}
translate P CCDlgMailerMode {Tryb:}
translate P CCDlgThunderbirdEg {np. Thunderbird, Mozilla Mail, Icedove...}
translate P CCDlgMailUrlEg {np. Evolution}
translate P CCDlgClawsEg {np Sylpheed Claws}
translate P CCDlgmailxEg {np. mailx, mutt, nail...}
translate P CCDlgAttachementPar {Parametr za��cznika:}
translate P CCDlgInternalXfcc {U�yj wbudowanej obs�ugi Xfcc}
translate P CCDlgConfirmXfcc {Potwierd� posuni�cia}
translate P CCDlgSubjectPar {Parametr tematu:}
translate P CCDlgDeleteBoxes {Opr�nij skrzynki nadawcz� i odbiorcz�}
translate P CCDlgDeleteBoxesText {Na pewno opr�ni� foldery nadawczy i odbiorczy dla szach�w korespondencyjnych? To wymaga synchronizacji, by wy�wietli� aktualny stan Twoich partii}
translate P CCDlgConfirmMove {Potwierd� posuni�cie}
translate P CCDlgConfirmMoveText {Je�li potwierdzisz, nast�puj�ce posuni�cie i komentarz zostan� wys�ane na serwer:}
translate P CCDlgDBGameToLong {Niezgodny wariant g��wny}
translate P CCDlgDBGameToLongError {Wariant g��wny w Twojej bazie jest d�u�szy ni� w skrzynce odbiorczej. Je�li skrzynka odbiorcza zawiera aktualny stan partii, posuni�cia zosta�y b��dnie dodanoe do g��wnej bazy.\nW takim wypadku prosz� skr�ci� wariant g��wny co najmniej do posuni�cia\n}
translate P CCDlgStartEmail {Rozpocznij now� parti� e-mail}
translate P CCDlgYourName {Imi� i nazwisko:}
translate P CCDlgYourMail {Adres e-mail:}
translate P CCDlgOpponentName {Imi� i nazwisko przeciwnika:}
translate P CCDlgOpponentMail {Adres e-mail przeciwnika:}
translate P CCDlgGameID {Unikatowy identyfikator partii:}
translate P CCDlgTitNoOutbox {Scid: skrzynka nadawcza}
translate P CCDlgTitNoInbox {Scid: skrzynka odbiorcza}
translate P CCDlgTitNoGames {Scid: brak partii korespondencyjnych}
translate P CCErrInboxDir {Katalog odbiorczy szach�w korespondencyjnych:}
translate P CCErrOutboxDir {Katalog nadawczy szach�w korespondencyjnych:}
translate P CCErrDirNotUsable {nie istnieje lub jest niedost�pny.\nProsz� sprawdzi� i poprawi� ustawienia.}
translate P CCErrNoGames {nie zawiera �adnych partii!\nProsz� najpierw je pobra�.}
translate P CCDlgTitNoCCDB {Scid: brak bazy korespondencyjnej}
translate P CCErrNoCCDB {Nie otwarto bazy typu 'Szachy korespondencyjne'. Prosz� otworzy� j� przed u�yciem funkcji do gry korespondencyjnej.}
translate P CCFetchBtn {Pobierz partie z serwera i przetw�rz skrzynk� odbiorcz�}
translate P CCPrevBtn {Przejd� do poprzedniej partii}
translate P CCNextBtn {Przejd� do nast�pnej partii}
translate P CCSendBtn {Wy�lij posuni�cie}
translate P CCEmptyBtn {Opr�nij skrzynk� odbiorcz� i nadawcz�}
translate P CCHelpBtn {Pomoc dla ikon i znacznik�w stanu.\nProsz� wcisn�� F1, by zobaczy� og�ln� pomoc.}
translate P CCDlgServerName {Nazwa serwera:}
translate P CCDlgLoginName  {Nazwa u�ytkownika:}
translate P CCDlgPassword   {Has�o:}
translate P CCDlgURL        {Adres Xfcc:}
translate P CCDlgRatingType {Typ rankingu:}
translate P CCDlgDuplicateGame {Nieunikatowy identyfikator partii}
translate P CCDlgDuplicateGameError {Ta partia jest powt�rzona w bazie danych. Prosz� usun�� wszystkie powt�rzenia i uporz�dkowa� plik bazy  delete (Plik/Obs�uga/Uporz�dkuj).}
translate P CCDlgSortOption {Sortowanie:}
translate P CCDlgListOnlyOwnMove {Tylko partie, gdzie jestem na posuni�ciu}
translate P CCOrderClassicTxt {Miejsce, turniej, runda, wynik, bia�e, czarne}
translate P CCOrderMyTimeTxt {M�j czas}
translate P CCOrderTimePerMoveTxt {Czas na posuni�cie do nast�pnej kontroli}
translate P CCOrderStartDate {Data rozpocz�cia}
translate P CCOrderOppTimeTxt {Czas przeciwnika}
translate P CCDlgConfigRelay {Konfiguruj obserwowanie ICCF}
translate P CCDlgConfigRelayHelp {Przejd� na stron� partii na http://www.iccf-webchess.com i wy�wietl parti� do obserwowania. Je�li widzisz szachownic�, skopiuj adres z przegl�darki do listy poni�ej (jeden adres na wiersz).\nPrzyk�ad: http://www.iccf-webchess.com/MakeAMove.aspx?id=266452}
translate P ExtHWConfigConnection {Konfiguruj urz�dzenie zewn�trzne}
translate P ExtHWPort {Port}
translate P ExtHWEngineCmd {Polecenie programu}
translate P ExtHWEngineParam {Parametr programu}
translate P ExtHWShowButton {Poka� przycisk}
translate P ExtHWHardware {Sprz�t}
translate P ExtHWNovag {Novag Citrine}
translate P ExtHWInputEngine {Program wej�ciowy}
translate P ExtHWNoBoard {Brak szachownicy}
translate P IEConsole {Terminal programu wej�ciowego}
translate P IESending {Posuni�cia wys�ane do}
translate P IESynchronise {Synchronizuj}
translate P IERotate  {Obr��}
translate P IEUnableToStart {Nie mo�na uruchomi� programu wej�ciowego:}
translate P DoneWithPosition {Pozycja zako�czona}
}

### Tips of the day in Polish:

set tips(P) {
  {
    Scid ma ponad 30 <a Index>stron pomocy</a> i w wi�kszo�ci okien Scida
    naci�ni�cie klawisza <b>F1</b> spowoduje wy�wietlenie odpowiedniej
    strony.
  }
  {
    Niekt�re okna Scida (np. informacje pod szachownic�,
    <a Switcher>prze��cznik baz</a>) maj� menu przywo�ywane prawym przyciskiem
    myszy. Spr�buj nacisn�� prawy przycisk myszy w ka�dym oknie, by
    sprawdzi�, czy menu jest dost�pne i jakie funkcje zawiera.
  }
  {
    Scid pozwala wprowadza� posuni�cia na kilka r�nych sposob�w.
    Mo�esz u�y� myszy (z wy�wietlaniem mo�liwych posuni�� lub bez)
    albo klawiatury (z opcjonalnym automatycznym dope�nianiem).
    Wi�cej informacji mo�na znale�� na stronie pomocy
    <a Moves>Wprowadzenie posuni��</a>.
  }
  {
    Je�li masz kilka baz, kt�re otwierasz cz�sto, dodaj
    <a Bookmarks>zak�adk�</a> dla ka�dej z nich. Umo�liwi to �atwe
    otwieranie baz z menu.
  }
  {
    Mo�esz obejrze� wszystkie posuni�cia w aktualnej partii
    (z wariantami i komentarzami lub bez) w <a PGN>Oknie PGN</a>.
    W oknie PGN mo�esz przej�� do dowolnego posuni�cia, klikaj�c
    na nim lewym przyciskiem myszy oraz u�y� �rodkowego lub prawego
    przycisku myszy do obejrzenia aktualnej pozycji.
  }
  {
    Mo�esz kopiowa� partie z bazy do bazy przeci�gaj�c je lewym
    przyciskiem myszy w oknie <a Switcher>Prze��cznika baz</a>.
  }
  {
    Scid mo�e otwiera� pliki PGN, nawet je�li s� one skompresowane
    Gzip-em (z rozszerzeniem .gz). Pliki PGN mog� by� jedynie
    czytane, wi�c je�li chcesz co� zmieni�, utw�rz now� baz� Scida
    i skopiuj do niej partie z pliku PGN.
  }
  {
    Je�li masz du�� baz� i cz�sto u�ywasz okna <a Tree>Drzewa wariant�w</a>,
    warto wybra� polecenie <b>Tw�rz standardowy plik cache/b>
    z menu Plik okna Drzewo wariant�w. Statystyki dla najpopularniejszych
    pozycji debiutowych zostan� zapami�tane w pliku, co przyspieszy
    dzia�anie drzewa.
  }
  {
    <a Tree>Drzewo wariant�w</a> mo�e pokaza� wszystkie posuni�cia
    z aktualnej pozycji, ale je�li chcesz zobaczy� wszystkie kolejno�ci
    posuni�� prowadz�ce do aktualnej pozycji, mo�esz u�y�
    <a OpReport>Raportu debiutowego</a>.
  }
  {
    W <a GameList>li�cie partii</a> kliknij lewym lub prawym przyciskiem
    myszy na nag��wku wybranej kolumny, by zmieni� jej szeroko��.
  }
  {
    W oknie <a PInfo>Informacja o graczu</a> (kliknij na nazwisku gracza
    w polu pod szachownic�, by je otworzy�) mo�esz �atwo ustawi�
    <a Searches Filter>filtr</a> zawieraj�cy wszystkie partie danego
    gracza zako�czeone wybranym wynikiem, klikaj�c na dowolnej warto�ci
    wy�wietlanej na <red>czerowono</red>.
  }
  {
    Podczas pracy nad debiutem warto u�y� funkcji
    <a Searches Board>wyszukiwania pozycji</a> z opcj� <b>Pionki</b> lub
    <b>Kolumny</b>. Pozowli to znale�� inne warianty debiutowe z t�
    sam� struktur� pionow�.
  }
  {
    W polu informacji o partii (pod szachownic�) mo�na u�y� prawego
    przycisku myszy, by wy�wietli� menu konfiguracji pola. Mo�na
    np. ukry� nast�pne posuni�cie, co jest przydatne przy rozwi�zywaniu
    zada�.
  }
  {
    Je�li cz�sto u�ywasz funkcji <a Maintenance>obs�ugi</a> na du�ej
    bazie, mo�esz u�y� okna <a Maintenance Cleaner>Zestaw zada�</a>
    do wykonania kilka funkcji naraz.
  }
  {
    Je�li masz du�� baz�, w kt�rej wi�kszo�� partii ma ustawiony
    znacznik EventDate, mo�esz <a Sorting>posortowa�</a> j�
    wg tego znacznika (zamiast Daty). Dzi�ki temu wszystkie partie
    z jednego turnieju znajd� si� ko�o siebie.
  }
  {
    Przed u�yciem funkcji <a Maintenance Twins>usuwania podw�jnych partii</a>
    dobrze jest <a Maintenance Spellcheck>sprawdzi� pisowni�</a>
    nazwisk w bazie, co usprawni wyszukiwanie powt�rze�.
  }
  {
    <a Flags>Flagi</a> s� przydatne do oznaczania partii, kt�re
    zawieraj� wa�ne motywy taktyczne, strkutury pionowe, nowinki itd.
    Potem mo�esz znale�� takie partie
    <a Searches Header>wyszukiwaniem wg nag��wka</a>.
  }
  {
    Je�li przegl�dasz parti� i chcesz sprawdzi� jaki� wariant nie
    zmieniaj�c partii, mo�esz w��czy� tryb testowania wariantu
    (klawisz <b>Ctrl+spacja</b> lub ikona na pasku narz�dziowym).
    Po wy��czeniu trybu testowania powr�cisz do pozycji z partii.
  }
  {
    �eby znale�� najwa�niejsze partie (z najsilniejszymi przeciwnikami),
    w kt�rych powsta�a aktualna pozycja, otw�rz <a Tree>Drzewo wariant�w</a>
    i wybierz list� najlepszych partii. Mo�esz nawet wybra� tylko
    partie zako�czone konkretnym wynikiem.
  }
  {
    Dobr� metod� na nauk� debiutu przy u�yciu du�ej bazy jest
    w��czenie trybu treningu w <a Tree>Drzewie wariant�w</a>
    i gra z programem. Pozwala to sprawdzi�, kt�re posuni�cia s�
    grane najcz�ciej.
  }
  {
    Je�li masz otwarte dwie bazy i chcesz obejrze�
    <a Tree>Drzewo wariant�w</a> dla pierwszej bazy, przegl�daj�c
    parti� z drugiej, kliknij przycisk <b>Blokada</b> na drzewie,
    by zablokowa� je na pierwszej bazie, a nast�pnie prze��cz si�
    do drugiej bazy.
  }
  {
    Okno <a Tmt>Turnieje</a> jest przydatne nie tylko do znajdowania
    turniej�w, ale pozwala tak�e sprawdzi�, w jakich turniejach gra�
    ostatnio dany zawodnik i jakie turnieje s� rozgrywane w wybranym
    kraju.
  }
  {
    Mo�esz u�y� jednego z wielu typowych wzorc�w w oknie
    <a Searches Material>Wyszukiwania wg materia�u</a> do znalezienia
    partii do studiowania debiut�w lub gry �rodkowej.
  }
  {
    W oknie <a Searches Material>Wyszukiwanie wg materia�u</a>, mo�esz
    ograniczy� liczb� znajdowanych partii przez warunek, by
    podany stosunek materia�u utrzymywa� si� przynajmniej przez
    kilka p�ruch�w.
  }
  {
    Je�li masz wa�n� baz�, kt�rej nie chcesz przez przypadek zmieni�,
    w��cz <b>Tylko do odczytu...</b> w menu <b>Plik</b> po jej otwarciu
    (albo zmie� prawa dost�pu do pliku).
  }
  {
    Je�li u�ywasz XBoard-a lub WinBoard-a (albo programu szachowego,
    kt�ry pozwala na skopiowania pozycji w notacji FEN do schowka)
    i chcesz skopiowa� aktualn� pozycj� do Scid-a, wybierz
    <b>Copy position</b> w menu File programu XBoard/Winboard, a potem
    <b>Wklej aktywn� parti� ze schowka</b> z menu Edycja Scid-a.
  }
  {
    W oknie <a Searches Header>Wyszukiwanie wg nag��wka</a>,
    szukane nazwy graczy/turnieju/miejsca/rundy s� znajdowane niezale�nie
    od wielko�ci liter i r�wnie� wewn�trz nazw.
    Zamiast tego mo�esz u�y� poszukiwania z symbolami wieloznacznymi
    (gdzie "?" oznacza dowolny znak, za� "*" - 0 lub wi�cej znak�w),
    wpisuj�c szukany tekst w cudzys�owie. Wielko�� liter zostanie
    uwzgl�dniona. Na przyk�ad "*BEL" znajdzie wszystkie turnieje grane
    w Belgii (ale nie w Belgradzie).
  }
  {
    Je�li chcesz poprawi� posuni�cie nie zmieniaj�c nast�pnych,
    otw�rz okno <a Import>Pobierz parti�</a>, wci�nij
    <b>Wklej aktualn� parti�</b>, zmie� b��dne posuni�cie i wci�nij
    <b>Pobierz</b>.
  }
  {
    Je�li plik klasyfikacji debiutowej ECO jest wczytany, mo�esz przej��
    do ostatniej sklasyfikowanej pozycji w partii za pomoc� polecenia
    <b>Rozpoznaj debiut</b> w menu <b>Partia</b> (klawisz Ctrl+Shift+D).
  }
  {
    Je�li chcesz sprawdzi� wielko�� lub dat� modyfikacji pliku
    przed jego otwarciem, u�yj okna <a Finder>Poszukiwacza plik�w</a>.
  }
  {
    <a OpReport>Raport debiutowy</a> pozwala dowiedzie� si� wi�cej
    o konkretnej pozycji. Mo�esz zobaczy� wyniki, nazwiska najcz�ciej
    graj�cych j� zawodnik�w, typowe motywy pozycyjne itd.
  }
  {
    Mo�esz doda� wi�kszo�� typowych symboli (!, !?, += itd.) do
    aktualnego posuni�cia lub pozycji za pomoc� skr�t�w klawiszowych,
    bez potrzeby otwierania okna <a Comment>Edytora komentarzy</a>
    -- np. wci�ni�cie "!" i Enter spowoduje dodanie symbolu "!".
    Na stronie <a Moves>Wprowadzanie posuni��</a> mo�na znale��
    wi�cej informacji.
  }
  {
    Mo�esz �atwo przegl�da� debiuty w bazie w oknie
    <a Tree>Drzewo wariant�w</a>. W oknie Statystyka (klawisz Ctrl+I)
    mo�na znale�� informacje o ostatnich wynikach w wariancie oraz
    o partiach granych przez silnych graczy.
  }
  {
    Mo�esz zmieni� wielko�� szachownicy, naciskaj�c <b>lewo</b> lub <b>prawo</b>
    przy wci�ni�tych klawiszach <b>Ctrl</b> i <b>Shift</b>.
  }
  {
    Po <a Searches>wyszukiwaniu</a> mo�esz �atwo przegl�da� wszystkie
    znalezione partie, naciskaj�c klawisz <b>g�ra</b> lub <b>d�</b>
    przy wci�ni�tym <b>Ctrl</b> by obejrze� poprzedni�/nast�pn� parti�
    w filtrze.
  }
}

# end of polish.tcl




