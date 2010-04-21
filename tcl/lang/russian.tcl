### russian.tcl:
#  Russian language support for Scid.
#  Contributed by Alex Sedykh.
#  Untranslated messages are marked with a "***" comment.
#  Untranslated help page sections are in <NEW>...</NEW> tags.

addLanguage R Russian 1 iso8859-5

proc setLanguage_R {} {

# File menu:
menuText R File "����" 0
menuText R FileNew "�����..." 0 {������� ����� ���� ������ Scid}
menuText R FileOpen "�������..." 0 {������� ���� ������ Scid}
menuText R FileClose "�������" 0 {������� �������� ���� ������ Scid}
menuText R FileFinder "�����" 0 {������� ���� ������ �����}
menuText R FileSavePgn "Save Pgn..." 0 {}
menuText R FileBookmarks "��������" 2 {���� �������� (����������: Ctrl+B)}
menuText R FileBookmarksAdd "�������� ��������" 0 \
  {�������� ������ ��� ������� � ������� ���� ������}
menuText R FileBookmarksFile "������������ ��������" 0 \
  {������������ �������� ��� ������� ������ ��� �������}
menuText R FileBookmarksEdit "������������� ��������..." 0 \
  {������������� ���� ��������}
menuText R FileBookmarksList "�������� ����� ��� ������� ������" 0 \
  {�������� ����� ��������, ��� ������� ������, � �� �������}
menuText R FileBookmarksSub "�������� ����� ��� �������" 1 \
  {�������� ����� �������� ��� �������, � �� ������� ������}
menuText R FileMaint "���������" 2 {����������� ��������� ���� ������ Scid}
menuText R FileMaintWin "���� ���������" 0 \
  {�������/������� ���� ��������� ���� ������ Scid}
menuText R FileMaintCompact "����� ���� ������..." 0 \
  {����� ����� ���� ������, �������� ��������� ������ � �������������� �����}
menuText R FileMaintClass "ECO-������������� ������..." 0 \
  {������������� ���� ECO ��� ���� ������}
menuText R FileMaintSort "����������� ���� ������..." 2 \
  {����������� ��� ������ � ���� ������}
menuText R FileMaintDelete "������� ������-��������..." 0 \
  {����� ������-�������� � �������� �� ��� ��������}
menuText R FileMaintTwin "���� �������� ���������" 14 \
  {�������/�������� ���� �������� ���������}
menuText R FileMaintName "������������ ����" 0 {�������������� ���� � ����������� ������������}
menuText R FileMaintNameEditor "�������� ����" 0 \
  {�������/������� ���� ��������� ����}
menuText R FileMaintNamePlayer "�������� ���� �������..." 9 \
  {�������� ���� ������� � ������� ����� ������������}
menuText R FileMaintNameEvent "�������� �������� ��������..." 18 \
  {�������� �������� �������� � ������� ����� ������������}
menuText R FileMaintNameSite "�������� �������� ����..." 18 \
  {�������� �������� ���� � ������� ����� ������������}
menuText R FileMaintNameRound "�������� �������� �������..." 20 \
  {�������� �������� ������� � ������� ����� ������������}
menuText R FileReadOnly "������ ��� ������..." 0 \
  {���������� ������� ���� ������ ��� ������ ��� ������, ������������� ���������}
menuText R FileSwitch "����������� ���� ������" 6 \
  {����������� �� ������ �������� ���� ������}
menuText R FileExit "�����" 0 {����� �� Scid}
# ====== TODO To be translated ======
menuText R FileMaintFixBase "Fix corrupted base" 0 {Try to fix a corrupted base}

# Edit menu:
menuText R Edit "��������������" 0
menuText R EditAdd "�������� �������" 0 {�������� ������� � ����� ���� ������}
menuText R EditDelete "������� �������" 0 {������� ������� ��� ����� ����}
menuText R EditFirst "������� ������� ������" 0 \
  {���������� ������� �� ������ ����� � ������}
menuText R EditMain "�������� �������� ����� ���������" 0 \
  {������� ������� �������� ������ ������}
menuText R EditTrial "����������� �������" 0 \
  {���������/��������� ������� �����, ��� �������� ���� �� �����}
menuText R EditStrip "������" 1 {������ ����������� ��� �������� �� ������}
menuText R EditStripComments "�����������" 0 \
  {������ ��� ����������� � ��������� �� ���� ������}
menuText R EditStripVars "��������" 0 {������ ��� �������� �� ���� ������}
menuText R EditStripBegin "Moves from the beginning" 1 \
  {Strip moves from the beginning of the game}
menuText R EditStripEnd "Moves to the end" 0 \
  {Strip moves to the end of the game}
menuText R EditReset "�������� " 0 \
  {��������� �������� �������� ����}
menuText R EditCopy "����������� ��� ������ � �������� ����" 1 \
  {����������� ��� ������ � �������� ����}
menuText R EditPaste "�������� ��������� ������ �� �������� ����" 0 \
  {�������� �������� ������ �� �������� ���� �����}
# ====== TODO To be translated ======
menuText R EditPastePGN "Paste Clipboard text as PGN game..." 18 \
  {Interpret the clipboard text as a game in PGN notation and paste it here}
menuText R EditSetup "���������� �������..." 2 \
  {���������� ��������� ������� ��� ���� ������}
menuText R EditCopyBoard "���������� �������" 4 \
  {���������� ������� ������� � ������� FEN � ��������� ����� (�����)}
menuText R EditPasteBoard "�������� ��������� �������" 3 \
  {�������� ��������� ������� �� �������� ���������� ������ (������)}

# Game menu:
menuText R Game "������" 0
menuText R GameNew "����� ������" 0 \
  {���������� ������ � ��������� ���������, �������� ��� ���������}
menuText R GameFirst "��������� ������ ������" 0 {��������� ������ ��������������� ������}
menuText R GamePrev "��������� ���������� ������" 1 {��������� ���������� ��������������� ������}
menuText R GameReload "������������� ������� ������" 1 \
  {������������� ��� ������, ������� ��� ��������� ���������}
menuText R GameNext "��������� ��������� ������" 2 {��������� ��������� ��������������� ������}
menuText R GameLast "��������� ��������� ������" 3 {��������� ��������� ��������������� ������}
menuText R GameRandom "��������� ��������� ������" 4 {��������� ��������� ��������������� ������}
menuText R GameNumber "��������� ������ �����..." 6 \
  {��������� ������, ������ �� �����}
menuText R GameReplace "���������: �������� ������..." 0 \
  {��������� ��� ������, ������� ������ ������}
menuText R GameAdd "���������: �������� ����� ������..." 2 \
  {��������� ��� ������, ��� ����� � ���� ������}
menuText R GameDeepest "���������� �����" 0 \
  {����� ����� ������� ������� ������, ��������� � ����� ECO}
menuText R GameGotoMove "������� � ���� �����..." 5 \
  {������� � ������������� ���� ������� ������}
menuText R GameNovelty "����� �������..." 2 \
  {����� ������ ��� � ���� ������, ������� ������ �� ����������}

# Search Menu:
menuText R Search "�����" 0
menuText R SearchReset "�������� ������" 0 {�������� ������, ������ ��� ������ ��������}
menuText R SearchNegate "�������� ������" 0 {�������� ������,  �������� ������ ����������� ������}
menuText R SearchCurrent "������� �������..." 0 {����� ������� �������}
menuText R SearchHeader "���������..." 0 {����� �� ��������� (�����, ������, � �.�.)}
menuText R SearchMaterial "��������/�����..." 0 {����� �� ��������� ��� �������� �������}
menuText R SearchUsing "��������� ���� ������..." 0 {����� � �������������� ����� � ����������� ������}

# Windows menu:
menuText R Windows "����" 0
menuText R WindowsGameinfo "Game Info" 0 {Show/hide the game info panel}
menuText R WindowsComment "�������� ������������" 0 {�������/������� �������� ������������}
menuText R WindowsGList "������ ������" 0 {�������/������� ���� ������ ������}
menuText R WindowsPGN "���� PGN" 0 {�������/������� ���� PGN (������� ������)}
menuText R WindowsCross "��������� �������" 0 {�������� ��������� ������� ��� ���� ������}
menuText R WindowsPList "����� ������" 2 {�������/������� ���� ������ ������}
menuText R WindowsTmt "����� ��������" 0 {�������/������� ���� ������ ��������}
menuText R WindowsSwitcher "������������� ��� ������" 1 \
  {�������/������� ���� ������������� ��� ������}
menuText R WindowsMaint "���� ���������" 1 \
  {�������/������� ���� ���������}
menuText R WindowsECO "�������� ECO" 4 {�������/������� ���� ��������� ECO}
menuText R WindowsRepertoire "�������� ����������" 2 \
  {�������/������� ���� ��������� ���������� �������}
menuText R WindowsStats "���� ����������" 2 \
  {�������/������� ���� ������������� ����������}
menuText R WindowsTree "���� ������" 10 {�������/������� ���� ������}
menuText R WindowsTB "���� ������ ��������" 10 \
  {�������/������� ���� ������ ��������}
# ====== TODO To be translated ======
menuText R WindowsBook "Book Window" 0 {Open/close the Book window}
# ====== TODO To be translated ======
menuText R WindowsCorrChess "Correspondence Window" 0 {Open/close the Correspondence window}

# Tools menu:
menuText R Tools "�����������" 0
menuText R ToolsAnalysis "������������� ������..." 0 \
  {���������/���������� ��������� ������������� ������}
menuText R ToolsAnalysis2 "������������� ������ �2..." 22 \
  {���������/���������� ������ ��������� ������������� ������}
menuText R ToolsEmail "�������� �����" 0 \
  {�������/������� ���� ���������� ��������� �����}
menuText R ToolsFilterGraph "������������� ���������" 0 \
  {�������/������� ���� ������������� ���������}
# ====== TODO To be translated ======
menuText R ToolsAbsFilterGraph "Abs. Filter Graph" 7 {Open/close the filter graph window for absolute values}
menuText R ToolsOpReport "�������� �����" 0 \
  {������������� �������� ����� ��� ������� �������}
# ====== TODO To be translated ======
menuText R ToolsOpenBaseAsTree "Open base as tree" 0   {Open a base and use it in Tree window}
# ====== TODO To be translated ======
menuText R ToolsOpenRecentBaseAsTree "Open recent base as tree" 0   {Open a recent base and use it in Tree window}
menuText R ToolsTracker "��������� ������"  4 {������� ���� ��������� ������}
# ====== TODO To be translated ======
menuText R ToolsTraining "Training"  0 {Training tools (tactics, openings,...) }
# ====== TODO To be translated ======
menuText R ToolsTacticalGame "Tactical game"  0 {Play a game with tactics}
# ====== TODO To be translated ======
menuText R ToolsSeriousGame "Serious game"  0 {Play a serious game}
# ====== TODO To be translated ======
menuText R ToolsTrainOpenings "Openings"  0 {Train with a repertoire}
# ====== TODO To be translated ======
menuText R ToolsTrainTactics "Tactics"  0 {Solve tactics}
# ====== TODO To be translated ======
menuText R ToolsTrainCalvar "Calculation of variations"  0 {Calculation of variations training}
# ====== TODO To be translated ======
menuText R ToolsTrainFindBestMove "Find best move"  0 {Find best move}
# ====== TODO To be translated ======
menuText R ToolsTrainFics "Internet"  0 {Play on freechess.org}
# ====== TODO To be translated ======
menuText R ToolsBookTuning "Book tuning" 0 {Book tuning}
# ====== TODO To be translated ======
menuText R ToolsConnectHardware "Connect Hardware" 0 {Connect external hardware}
# ====== TODO To be translated ======
menuText R ToolsConnectHardwareConfigure "Configure..." 0 {Configure external hardware and connection}
# ====== TODO To be translated ======
menuText R ToolsConnectHardwareNovagCitrineConnect "Connect Novag Citrine" 0 {Connect Novag Citrine}
# ====== TODO To be translated ======
menuText R ToolsConnectHardwareInputEngineConnect "Connect Input Engine" 0 {Connect Input Engine (e.g. DGT)}
# ====== TODO To be translated ======
menuText R ToolsNovagCitrine "Novag Citrine" 0 {Novag Citrine}
# ====== TODO To be translated ======
menuText R ToolsNovagCitrineConfig "Configuration" 0 {Novag Citrine configuration}
# ====== TODO To be translated ======
menuText R ToolsNovagCitrineConnect "Connect" 0 {Novag Citrine connect}
menuText R ToolsPInfo "���������� �� ������"  1 \
  {�������/�������� ���� ���������� �� ������}
menuText R ToolsPlayerReport "Player Report" 3 \
  {Generate a player report}
menuText R ToolsRating "��������� ��������" 1 \
  {��������� ������� �������� ��� ������� ������� ������}
menuText R ToolsScore "��������� �����" 2 {�������� ���� ��������� �����}
menuText R ToolsExpCurrent "������� ������� ������" 0 \
  {�������� ������� ������ � ��������� ����}
menuText R ToolsExpCurrentPGN "������� ������ � ���� PGN..." 0 \
  {�������� ������� ������ � ���� PGN}
menuText R ToolsExpCurrentHTML "������� ������ � ���� HTML..." 1 \
  {�������� ������� ������ � ���� HTML}
# ====== TODO To be translated ======
menuText R ToolsExpCurrentHTMLJS "Export Game to HTML and JavaScript File..." 15 {Write current game to a HTML and JavaScript file}  
menuText R ToolsExpCurrentLaTeX "������� ������ � ���� LaTeX..." 2 \
  {�������� ������� ������ � ���� LaTeX}
menuText R ToolsExpFilter "������� ���� ��������������� ������" 11 \
  {�������� ��� ��������������� ������ � ��������� ����}
menuText R ToolsExpFilterPGN "������� ��������������� ������ � ���� PGN..." 1 \
  {�������� ��� ��������������� ������ � ���� PGN}
menuText R ToolsExpFilterHTML "������� ��������������� ������ � ���� HTML..." 2 \
  {�������� ��� ��������������� ������ � ���� HTML}
# ====== TODO To be translated ======
menuText R ToolsExpFilterHTMLJS "Export Filter to HTML and JavaScript File..." 17 {Write all filtered games to a HTML and JavaScript file}  
menuText R ToolsExpFilterLaTeX "������� ��������������� ������ � ���� LaTeX..." 3 \
  {�������� ��� ��������������� ������ � ���� LaTeX}
menuText R ToolsImportOne "������ ����� ������ PGN..." 0 \
  {������ ������ �� ���������� ����� PGN}
menuText R ToolsImportFile "������ ����� ������ PGN..." 9 \
  {������ ������ �� ����� PGN}
# ====== TODO To be translated ======
menuText R ToolsStartEngine1 "Start engine 1" 0  {Start engine 1}
# ====== TODO To be translated ======
menuText R ToolsStartEngine2 "Start engine 2" 0  {Start engine 2}
# ====== TODO To be translated ======
menuText R Play "Play" 0
# ====== TODO To be translated ======
menuText R CorrespondenceChess "Correspondence Chess" 0 {Functions for eMail and Xfcc based correspondence chess}
# ====== TODO To be translated ======
menuText R CCConfigure "Configure..." 0 {Configure external tools and general setup}
# ====== TODO To be translated ======
menuText R CCOpenDB "Open Database..." 0 {Open the default Correspondence database}
# ====== TODO To be translated ======
menuText R CCRetrieve "Retrieve Games" 0 {Retrieve games via external (Xfcc-)helper}
# ====== TODO To be translated ======
menuText R CCInbox "Process Inobx" 0 {Process all files in scids Inbox}
# ====== TODO To be translated ======
menuText R CCPrevious "Previous Game" 0 {Go to previous game in Inbox}
# ====== TODO To be translated ======
menuText R CCNext "Next Game" 0 {Go to next game in Inbox}
# ====== TODO To be translated ======
menuText R CCSend "Send Move" 0 {Send your move via eMail or external (Xfcc-)helper}
# ====== TODO To be translated ======
menuText R CCResign "Resign" 0 {Resign (not via eMail)}
# ====== TODO To be translated ======
menuText R CCClaimDraw "Claim Draw" 0 {Send move and claim a draw (not via eMail)}
# ====== TODO To be translated ======
menuText R CCOfferDraw "Offer Draw" 0 {Send move and offer a draw (not via eMail)}
# ====== TODO To be translated ======
menuText R CCAcceptDraw "Accept Draw" 0 {Accept a draw offer (not via eMail)}
# ====== TODO To be translated ======
menuText R CCNewMailGame "New eMail Game..." 0 {Start a new eMail game}
# ====== TODO To be translated ======
menuText R CCMailMove "Mail Move..." 0 {Send the move via eMail to the opponent}

# Options menu:
menuText R Options "���������" 0
menuText R OptionsBoard "Chessboard" 0 {Chess board appearance options}
menuText R OptionsNames "My Player Names..." 0 {Edit my player names}
menuText R OptionsExport "�������" 0 {�������� ��������� ��������}
menuText R OptionsFonts "������" 0 {�������� ������}
menuText R OptionsFontsRegular "����������" 0 {�������� ���������� ������}
menuText R OptionsFontsMenu "����" 0 {�������� ������ ����}
menuText R OptionsFontsSmall "�����" 1 {�������� ����� ������}
menuText R OptionsFontsFixed "�������������" 0 {�������� ������������� ������}
menuText R OptionsGInfo "���������� � ������" 0 {��������� ���������� � ������}
menuText R OptionsLanguage "����" 0 {���� ������ �����}
# ====== TODO To be translated ======
menuText R OptionsMovesTranslatePieces "Translate pieces" 0 {Translate first letter of pieces}
# ====== TODO To be translated ======
menuText R OptionsMovesHighlightLastMove "Highlight last move" 0 {Highlight last move}
# ====== TODO To be translated ======
menuText R OptionsMovesHighlightLastMoveDisplay "Show" 0 {Display last move Highlight}
# ====== TODO To be translated ======
menuText R OptionsMovesHighlightLastMoveWidth "Width" 0 {Thickness of line}
# ====== TODO To be translated ======
menuText R OptionsMovesHighlightLastMoveColor "Color" 0 {Color of line}
menuText R OptionsMoves "����" 0 {��������� ��� �����}
menuText R OptionsMovesAsk "�������� ����� ������� �����" 0 \
  {�������� ����� ����������� ����� �����}
menuText R OptionsMovesAnimate "����� ��������" 1 \
  {���������� ���������� �������, ������������ ��� �������� �����}
menuText R OptionsMovesDelay "��������� �������� ��������..." 0 \
  {���������� ����� �������� ��� ������ ��������}
menuText R OptionsMovesCoord "���������� �����" 1 \
  {������� ����� ������ ����� � ������������ ("g1f3")}
menuText R OptionsMovesSuggest "�������� ���������� ����" 0 \
  {��������/��������� ������ � ����}
# ====== TODO To be translated ======
menuText R OptionsShowVarPopup "Show variations window" 0 {Turn on/off the display of a variations window}  
# ====== TODO To be translated ======
menuText R OptionsMovesSpace "Add spaces after move number" 0 {Add spaces after move number}  
menuText R OptionsMovesKey "������������ ����������" 0 \
  {��������/��������� �������������� ������������ �����}
menuText R OptionsNumbers "�������� ������" 0 {������� �������� ������}
menuText R OptionsStartup "������" 0 {������� ����, ������������� ��� �������}
menuText R OptionsWindows "����" 0 {��������� ����}
menuText R OptionsWindowsIconify "����-����������" 0 \
  {������������� ��� ����, ����� ������������� �������� ����}
menuText R OptionsWindowsRaise "����-����������" 1 \
  {����������� ������������ ���� (��������, ������ ���������) ������ ���, ����� ��� ������}
# ====== TODO To be translated ======
menuText R OptionsSounds "Sounds..." 2 {Configure move announcement sounds}
menuText R OptionsToolbar "���������������� ������" 0 {������������ ���������������� ������ ��������� ����}
menuText R OptionsECO "��������� ���� ECO..." 2 { ��������� ���� ������������� ECO}
menuText R OptionsSpell "��������� ���� �������� ������������..." 4 \
  {��������� Scid ���� �������� ������������}
menuText R OptionsTable "���������� ������..." 15 \
  {������� ���� �������; ��� ������� � ���� ���������� ����� ������������}
menuText R OptionsRecent "������� ������������ �����..." 2 \
  {�������� ���������� ������� ������������ ������ � ���� ����}
# ====== TODO To be translated ======
menuText R OptionsBooksDir "Books directory..." 0 {Sets the opening books directory}
# ====== TODO To be translated ======
menuText R OptionsTacticsBasesDir "Bases directory..." 0 {Sets the tactics (training) bases directory}
menuText R OptionsSave "��������� ���������" 0 \
  "��������� ��� ��������� � ���� $::optionsFile"
menuText R OptionsAutoSave "�������������� ��������� ��� ������" 0 \
  {�������������� ���� ��������� ��� ������ �� ���������}

# Help menu:
menuText R Help "������" 0
menuText R HelpContents "Contents" 0 {Show the help contents page}
menuText R HelpIndex "������" 0 {�������� �������� �������� ������}
menuText R HelpGuide "������� ���" 0 {�������� �������� �������� ���� ������}
menuText R HelpHints "������" 0 {�������� �������� �������}
menuText R HelpContact "���������� ����������" 0 {�������� ���������� ����������}
menuText R HelpTip "��������� ���" 2 {�������� �������� ���������}
menuText R HelpStartup "���� �������" 1 {�������� ���� �������}
menuText R HelpAbout "� Scid" 0 {���������� � Scid}

# Game info box popup menu:
menuText R GInfoHideNext "�������� ��������� ���" 0
menuText R GInfoMaterial "�������� ������������ ������" 0
menuText R GInfoFEN "�������� FEN" 1
menuText R GInfoMarks "�������� ������ ���� � �������" 3
menuText R GInfoWrap "��������� ������� ������" 0
menuText R GInfoFullComment "�������� ������ �����������" 7
menuText R GInfoPhotos "�������� ����" 9
menuText R GInfoTBNothing "��������� ����: ������" 0
menuText R GInfoTBResult "��������� ����: ������ ���������" 5
menuText R GInfoTBAll "��������� ����: ��������� � ������ ����" 7
menuText R GInfoDelete "(������������)������� ��� ������" 1
menuText R GInfoMark "(����� �������)�������� ��� ������" 2
# ====== TODO To be translated ======
menuText R GInfoInformant "Configure informant values" 0

# Main window buttons:
helpMsg R .button.start {������� � ������ ������  (�������: Home)}
helpMsg R .button.end {������� � ����� ������  (�������: End)}
helpMsg R .button.back {���� ��� �����  (�������: LeftArrow)}
helpMsg R .button.forward {���� ��� ������ (�������: RightArrow)}
helpMsg R .button.intoVar {������� � ��������  (�������: v)}
helpMsg R .button.exitVar {����� �� �������� �������� (�������: z)}
helpMsg R .button.flip {����������� ����� (�������: .)}
helpMsg R .button.coords {��������/��������� ����������  (�������: 0)}
helpMsg R .button.stm {��������/��������� ������ ����������� ����}
helpMsg R .button.autoplay {�������������� ���������� �����  (�������: Ctrl+Z)}

# General buttons:
translate R Back {�����}
translate R Browse {Browse}
translate R Cancel {��������}
# ====== TODO To be translated ======
translate R Continue {Continue}
translate R Clear {��������}
translate R Close {�������}
translate R Contents {Contents}
translate R Defaults {�� ���������}
translate R Delete {�������}
translate R Graph {������}
translate R Help {������}
translate R Import {������}
translate R Index {������}
translate R LoadGame {��������� ������}
translate R BrowseGame {����������� ������}
translate R MergeGame {��������� ������}
# ====== TODO To be translated ======
translate R MergeGames {Merge Games}
translate R Preview {��������������� ��������}
translate R Revert {������������}
translate R Save {���������}
translate R Search {������}
translate R Stop {����������}
translate R Store {��������}
translate R Update {��������}
translate R ChangeOrient {�������� ���������� ����}
# ====== TODO To be translated ======
translate R ShowIcons {Show Icons}
translate R None {���}
translate R First {������}
translate R Current {�������}
translate R Last {���������}

# General messages:
translate R game {������}
translate R games {������}
translate R move {���}
translate R moves {�����}
translate R all {���}
translate R Yes {��}
translate R No {���}
translate R Both {���}
translate R King {������}
translate R Queen {�����}
translate R Rook {�����}
translate R Bishop {����}
translate R Knight {����}
translate R Pawn {�����}
translate R White {�����}
translate R Black {������}
translate R Player {�����}
translate R Rating {�������}
translate R RatingDiff {������� ��������� (����� - ������)}
translate R AverageRating {������� �������}
translate R Event {������}
translate R Site {�����}
translate R Country {������}
translate R IgnoreColors {������������ �����}
translate R Date {����}
translate R EventDate {���� �������}
translate R Decade {������}
translate R Year {���}
translate R Month {�����}
translate R Months {������ ������� ���� ������ ��� ���� ���� ������ �������� ������� ������ �������}
translate R Days {��� ��� ��� ��� ��� ��� ���}
translate R YearToToday {������� ���}
translate R Result {���������}
translate R Round {�����}
translate R Length {�����}
translate R ECOCode {��� ECO}
translate R ECO {ECO}
translate R Deleted {�������}
translate R SearchResults {����� �����������}
translate R OpeningTheDatabase {�������� ���� ������}
translate R Database {���� ������}
translate R Filter {������}
translate R noGames {��� ������}
translate R allGames {��� ������}
translate R empty {�����}
translate R clipbase {���������}
translate R score {����}
translate N Start {���������}
translate R StartPos {��������� �������}
translate R Total {�����}
# ====== TODO To be translated ======
translate R readonly {read-only}

# Standard error messages:
translate R ErrNotOpen {��� ���� ������ �� �������.}
translate R ErrReadOnly {��� ���� ������ ������ ��� ������; ��� �� ����� ���� ��������.}
translate R ErrSearchInterrupted {����� ��� �������; ���������� �� ������.}

# Game information:
translate R twin {�������}
translate R deleted {�������}
translate R comment {�����������}
translate R hidden {�������}
translate R LastMove {��������� ���}
translate R NextMove {���������}
translate R GameStart {������ ������}
translate R LineStart {������ ������}
translate R GameEnd {����� ������}
translate R LineEnd {����� ������}

# Player information:
translate R PInfoAll {���������� <b>����</b> ������}
translate R PInfoFilter {���������� <b>���������������</b> ������}
translate R PInfoAgainst {���������� ������}
translate R PInfoMostWhite {�������� ������ ������ �� �����}
translate R PInfoMostBlack {�������� ������ ������ �� ������}
translate R PInfoRating {������� ��������}
translate R PInfoBio {���������}
translate R PInfoEditRatings {Edit Ratings}

# Tablebase information:
translate R Draw {�����}
translate R stalemate {���}
translate R withAllMoves {�� ����� ������}
translate R withAllButOneMove {�� ����� ����� ������ ����}
translate R with {�}
translate R only {������}
translate R lose {���������}
translate R loses {���������}
translate R allOthersLose {��� ��������� ���������}
translate R matesIn {��� ��}
translate R hasCheckmated {���������}
translate R longest {����� �������}
translate R WinningMoves {��������� ����}
translate R DrawingMoves {�������� ����}
translate R LosingMoves {����������� ����}
translate R UnknownMoves {����, ���������� � ������������ ����������}

# Tip of the day:
translate R Tip {�����}
translate R TipAtStartup {����� ��� ��������}

# Tree window menus:
menuText R TreeFile "����" 0
# ====== TODO To be translated ======
menuText R TreeFileFillWithBase "Fill Cache with base" 0 {Fill the cache file with all games in current base}
# ====== TODO To be translated ======
menuText R TreeFileFillWithGame "Fill Cache with game" 0 {Fill the cache file with current game in current base}
# ====== TODO To be translated ======
menuText R TreeFileSetCacheSize "Cache size" 0 {Set the cache size}
# ====== TODO To be translated ======
menuText R TreeFileCacheInfo "Cache info" 0 {Get info on cache usage}
menuText R TreeFileSave "��������� ��� ����" 0 {��������� ��� ���� ������ (.stc)}
menuText R TreeFileFill "��������� ��� ����" 0 \
  {���������� ��� ���� � ������ ��������� ���������}
menuText R TreeFileBest "������ ������ ������" 1 {�������� ������ ������ ������ ������}
menuText R TreeFileGraph "���� �������" 0 {�������� ������ ��� ����� ����� ������}
menuText R TreeFileCopy "����������� ����� ������ � �����" 1 \
  {����������� ���������� ������ � �����}
menuText R TreeFileClose "������� ���� ������" 4 {������� ���� ������}
# ====== TODO To be translated ======
menuText R TreeMask "Mask" 0
# ====== TODO To be translated ======
menuText R TreeMaskNew "New" 0 {New mask}
# ====== TODO To be translated ======
menuText R TreeMaskOpen "Open" 0 {Open mask}
# ====== TODO To be translated ======
menuText R TreeMaskSave "Save" 0 {Save mask}
# ====== TODO To be translated ======
menuText R TreeMaskClose "Close" 0 {Close mask}
# ====== TODO To be translated ======
menuText R TreeMaskFillWithGame "Fill with game" 0 {Fill mask with game}
# ====== TODO To be translated ======
menuText R TreeMaskFillWithBase "Fill with base" 0 {Fill mask with all games in base}
# ====== TODO To be translated ======
menuText R TreeMaskInfo "Info" 0 {Show statistics for current mask}
menuText R TreeSort "����������" 0
menuText R TreeSortAlpha "����������" 0
menuText R TreeSortECO "�� ���� ECO" 3
menuText R TreeSortFreq "�� �������" 3
menuText R TreeSortScore "�� ����������" 3
menuText R TreeOpt "���������" 0
# ====== TODO To be translated ======
menuText R TreeOptSlowmode "slow mode" 0 {Slow mode for updates (high accuracy)}
# ====== TODO To be translated ======
menuText R TreeOptFastmode "Fast mode" 0 {Fast mode for updates (no move transposition)}
# ====== TODO To be translated ======
menuText R TreeOptFastAndSlowmode "Fast and slow mode" 0 {Fast mode then slow mode for updates}
menuText R TreeOptLock "�����������" 0 {(���)����������� ������ ��� ������� ����}
menuText R TreeOptTraining "����������" 0 {��������/��������� ����� ����������}
menuText R TreeOptAutosave "�������������� ����� ����" 0 \
  {�������������� ����� ����, ����� ����������� ���� ������}
menuText R TreeHelp "������" 0
menuText R TreeHelpTree "������ �� ������" 0
menuText R TreeHelpIndex "������ ������" 0
translate R SaveCache {��������� ���}
translate R Training {����������}
translate R LockTree {����������}
translate R TreeLocked {�������������}
translate R TreeBest {������}
translate R TreeBestGames {������ ������ ������}
# Note: the next message is the tree window title row. After editing it,
# check the tree window to make sure it lines up with the actual columns.
translate R TreeTitleRow \
  {    ���    ECO       �������     ����   ��Elo ���� �����  %������}
translate R TreeTotal {TOTAL}
# ====== TODO To be translated ======
translate R DoYouWantToSaveFirst {Do you want to save first}
# ====== TODO To be translated ======
translate R AddToMask {Add to Mask}
# ====== TODO To be translated ======
translate R RemoveFromMask {Remove from Mask}
# ====== TODO To be translated ======
translate R Nag {Nag code}
# ====== TODO To be translated ======
translate R Marker {Marker}
# ====== TODO To be translated ======
translate R Include {Include}
# ====== TODO To be translated ======
translate R Exclude {Exclude}
# ====== TODO To be translated ======
translate R MainLine {Main line}
# ====== TODO To be translated ======
translate R Bookmark {Bookmark}
# ====== TODO To be translated ======
translate R NewLine {New line}
# ====== TODO To be translated ======
translate R ToBeVerified {To be verified}
# ====== TODO To be translated ======
translate R ToTrain {To train}
# ====== TODO To be translated ======
translate R Dubious {Dubious}
# ====== TODO To be translated ======
translate R ToRemove {To remove}
# ====== TODO To be translated ======
translate R NoMarker {No marker}
# ====== TODO To be translated ======
translate R ColorMarker {Color}
# ====== TODO To be translated ======
translate R WhiteMark {White}
# ====== TODO To be translated ======
translate R GreenMark {Green}
# ====== TODO To be translated ======
translate R YellowMark {Yellow}
# ====== TODO To be translated ======
translate R BlueMark {Blue}
# ====== TODO To be translated ======
translate R RedMark {Red}
# ====== TODO To be translated ======
translate R CommentMove {Comment move}
# ====== TODO To be translated ======
translate R CommentPosition {Comment position}
# ====== TODO To be translated ======
translate R AddMoveToMaskFirst {Add move to mask first}
# ====== TODO To be translated ======
translate R OpenAMaskFileFirst {Open a mask file first}
# ====== TODO To be translated ======
translate R Positions {Positions}
# ====== TODO To be translated ======
translate R Moves {Moves}

# Finder window:
menuText R FinderFile "����" 0
menuText R FinderFileSubdirs "�������� � ��������������" 0
menuText R FinderFileClose "������� ����� ������" 0
menuText R FinderSort "����������" 0
menuText R FinderSortType "���" 0
menuText R FinderSortSize "������" 0
menuText R FinderSortMod "���������������" 0
menuText R FinderSortName "���" 0
menuText R FinderSortPath "����" 0
menuText R FinderTypes "����" 0
menuText R FinderTypesScid "���� ������ Scid" 0
menuText R FinderTypesOld "������ ������ ���� ������ Scid" 0
menuText R FinderTypesPGN "����� PGN" 0
menuText R FinderTypesEPD "����� EPD" 1
menuText R FinderTypesRep "����� ����������" 6
menuText R FinderHelp "������" 0
menuText R FinderHelpFinder "������ �� ������ ������" 0
menuText R FinderHelpIndex "������ ������" 0
translate R FileFinder {����� ������}
translate R FinderDir {����������}
translate R FinderDirs {����������}
translate R FinderFiles {�����}
translate R FinderUpDir {�����}
# ====== TODO To be translated ======
translate R FinderCtxOpen {Open}
# ====== TODO To be translated ======
translate R FinderCtxBackup {Backup}
# ====== TODO To be translated ======
translate R FinderCtxCopy {Copy}
# ====== TODO To be translated ======
translate R FinderCtxMove {Move}
# ====== TODO To be translated ======
translate R FinderCtxDelete {Delete}

# Player finder:
menuText R PListFile "����" 0
menuText R PListFileUpdate "��������" 0
menuText R PListFileClose "������� ����� ������" 0
menuText R PListSort "����������" 0
menuText R PListSortName "���" 0
menuText R PListSortElo "Elo" 0
menuText R PListSortGames "������" 0
menuText R PListSortOldest "���������" 1
menuText R PListSortNewest "��������" 0

# Tournament finder:
menuText R TmtFile "����" 0
menuText R TmtFileUpdate "��������" 0
menuText R TmtFileClose "������� ����� �������" 0
menuText R TmtSort "����������" 0
menuText R TmtSortDate "����" 0
menuText R TmtSortPlayers "������" 0
menuText R TmtSortGames "������" 0
menuText R TmtSortElo "Elo" 0
menuText R TmtSortSite "�����" 0
menuText R TmtSortEvent "������" 0
menuText R TmtSortWinner "����������" 2
translate R TmtLimit "������������ ������"
translate R TmtMeanElo "���������� �������� Elo"
translate R TmtNone "�� ������ ������� �� �������."

# Graph windows:
menuText R GraphFile "����" 0
menuText R GraphFileColor "��������� ��� ������� PostScript..." 14
menuText R GraphFileGrey "��������� ��� �����-����� PostScript..." 14
menuText R GraphFileClose "������� ����" 6
menuText R GraphOptions "���������" 0
menuText R GraphOptionsWhite "�����" 0
menuText R GraphOptionsBlack "������" 0
menuText R GraphOptionsBoth "���" 0
menuText R GraphOptionsPInfo "����� - ���������� �� ������" 0
translate R GraphFilterTitle "������ �������: ������� �� 1000 ������"
# ====== TODO To be translated ======
translate R GraphAbsFilterTitle "Filter Graph: frequency of the games"
# ====== TODO To be translated ======
translate R ConfigureFilter {Configure X-Axes for Year, Rating and Moves}
# ====== TODO To be translated ======
translate R FilterEstimate "Estimate"
# ====== TODO To be translated ======
translate R TitleFilterGraph "Scid: Filter Graph"

# Analysis window:
translate R AddVariation {�������� �������}
# ====== TODO To be translated ======
translate R AddAllVariations {Add All Variations}
translate R AddMove {�������� ���}
translate R Annotate {���������}
# ====== TODO To be translated ======
translate R ShowAnalysisBoard {Show analysis board}
# ====== TODO To be translated ======
translate R ShowInfo {Show engine info}
# ====== TODO To be translated ======
translate R FinishGame {Finish game}
# ====== TODO To be translated ======
translate R StopEngine {Stop engine}
# ====== TODO To be translated ======
translate R StartEngine {Start engine}
# ====== TODO To be translated ======
translate R LockEngine {Lock engine to current position}
translate R AnalysisCommand {������� �������}
translate R PreviousChoices {���������� ������}
translate R AnnotateTime {���������� ����� ����� ������ � ��������}
translate R AnnotateWhich {�������� ��������}
translate R AnnotateAll {��� ����� ����� ������}
# ====== TODO To be translated ======
translate R AnnotateAllMoves {Annotate all moves}
translate R AnnotateWhite {������ ��� ����� �����}
translate R AnnotateBlack {������ ��� ����� ������}
translate R AnnotateNotBest {����� ��� � ������ �� ����� ������ ���}
# ====== TODO To be translated ======
translate R AnnotateBlundersOnly {When game move is an obvious blunder}
# ====== TODO To be translated ======
translate R AnnotateBlundersOnlyScoreChange {Analysis reports blunder, with score change from/to: }
# ====== TODO To be translated ======
translate R BlundersThreshold {Threshold}
translate R LowPriority {������ ��������� CPU}
# ====== TODO To be translated ======
translate R ClickHereToSeeMoves {Click here to see moves}
# ====== TODO To be translated ======
translate R ConfigureInformant {Configure Informant}
# ====== TODO To be translated ======
translate R Informant!? {Interesting move}
# ====== TODO To be translated ======
translate R Informant? {Poor move}
# ====== TODO To be translated ======
translate R Informant?? {Blunder}
# ====== TODO To be translated ======
translate R Informant?! {Dubious move}
# ====== TODO To be translated ======
translate R Informant+= {White has a slight advantage}
# ====== TODO To be translated ======
translate R Informant+/- {White has a moderate advantage}
# ====== TODO To be translated ======
translate R Informant+- {White has a decisive advantage}
# ====== TODO To be translated ======
translate R Informant++- {The game is considered won}
# ====== TODO To be translated ======
translate R Book {Book}

# Analysis Engine open dialog:
translate R EngineList {������ ������������� �������}
translate R EngineName {��������}
translate R EngineCmd {�������}
translate R EngineArgs {���������}
translate R EngineDir {����������}
translate R EngineElo {Elo}
translate R EngineTime {����}
translate R EngineNew {�����}
translate R EngineEdit {��������}
translate R EngineRequired {����, ���������� ������ �������, ��������� �����������, ��������� �� �������}

# Stats window menus:
menuText R StatsFile "����" 0
menuText R StatsFilePrint "�������� � ����..." 0
menuText R StatsFileClose "������� ����" 0
menuText R StatsOpt "���������" 0

# PGN window menus:
menuText R PgnFile "����" 0
menuText R PgnFileCopy "Copy Game to Clipboard" 0
menuText R PgnFilePrint "�������� � ����..." 0
menuText R PgnFileClose "������� ���� PGN" 0
menuText R PgnOpt "�����������" 0
menuText R PgnOptColor "������� �����������" 0
menuText R PgnOptShort "�������� (������������) ���������" 0
menuText R PgnOptSymbols "������������� ���������" 0
menuText R PgnOptIndentC "����������� � ��������" 2
menuText R PgnOptIndentV "�������� � ��������" 0
menuText R PgnOptColumn "� ������� (���� ��� �� �������)" 4
menuText R PgnOptSpace "������ ����� ������ ����" 0
menuText R PgnOptStripMarks "������� ���� ������� �����/�������" 0
menuText R PgnOptBoldMainLine "Use Bold Text for Main Line Moves" 4
menuText R PgnColor "�����" 0
menuText R PgnColorHeader "���������..." 0
menuText R PgnColorAnno "���������..." 0
menuText R PgnColorComments "�����������..." 0
menuText R PgnColorVars "��������..." 0
menuText R PgnColorBackground "���..." 0
# ====== TODO To be translated ======
menuText R PgnColorMain "Main line..." 0
# ====== TODO To be translated ======
menuText R PgnColorCurrent "Current move background..." 1
# ====== TODO To be translated ======
menuText R PgnColorNextMove "Next move background..." 0
menuText R PgnHelp "������" 0
menuText R PgnHelpPgn "������ �� PGN" 0
menuText R PgnHelpIndex "������" 0
translate R PgnWindowTitle {Game Notation - game %u}

# Crosstable window menus:
menuText R CrosstabFile "����" 0
menuText R CrosstabFileText "�������� � ��������� ����..." 11
menuText R CrosstabFileHtml "�������� � HTML ����..." 11
menuText R CrosstabFileLaTeX "�������� � LaTeX ����..." 11
menuText R CrosstabFileClose "������� ���� ��������� �������" 0
menuText R CrosstabEdit "��������" 0
menuText R CrosstabEditEvent "������" 0
menuText R CrosstabEditSite "�����" 0
menuText R CrosstabEditDate "����" 0
menuText R CrosstabOpt "�����������" 0
menuText R CrosstabOptAll "��� ������ ����" 0
menuText R CrosstabOptSwiss "����������� �������" 0
menuText R CrosstabOptKnockout "�� �����" 0
menuText R CrosstabOptAuto "����" 0
menuText R CrosstabOptAges "�������� � �����" 2
menuText R CrosstabOptNats "��������������" 2
menuText R CrosstabOptRatings "�������" 0
menuText R CrosstabOptTitles "�����" 0
menuText R CrosstabOptBreaks "���� ���-������" 0
menuText R CrosstabOptDeleted "�������� ��������� ������" 1
menuText R CrosstabOptColors "����� (������ ��� ����������� �������)" 0
menuText R CrosstabOptColumnNumbers "�������� ������� (������ ��� ���� ������ ����)" 2
menuText R CrosstabOptGroup "��������� ����" 0
menuText R CrosstabSort "����������" 0
menuText R CrosstabSortName "���" 0
menuText R CrosstabSortRating "�������" 0
menuText R CrosstabSortScore "����" 0
menuText R CrosstabColor "����" 0
menuText R CrosstabColorPlain "������� �����" 0
menuText R CrosstabColorHyper "����������" 0
menuText R CrosstabHelp "������" 0
menuText R CrosstabHelpCross "������ �� ��������� �������" 0
menuText R CrosstabHelpIndex "������ ������" 0
translate R SetFilter {���������� ������}
translate R AddToFilter {�������� � �������}
translate R Swiss {����������� �������}
translate R Category {���������}

# Opening report window menus:
menuText R OprepFile "����" 0
menuText R OprepFileText "�������� � ��������� ����..." 11
menuText R OprepFileHtml "�������� � HTML ����..." 11
menuText R OprepFileLaTeX "�������� � LaTeX ����..." 11
menuText R OprepFileOptions "���������..." 0
menuText R OprepFileClose "������� ���� �������" 0
menuText R OprepFavorites "Favorites" 1
menuText R OprepFavoritesAdd "Add Report..." 0
menuText R OprepFavoritesEdit "Edit Report Favorites..." 0
menuText R OprepFavoritesGenerate "Generate Reports..." 0
menuText R OprepHelp "������" 0
menuText R OprepHelpReport "������ �� �������� �������" 0
menuText R OprepHelpIndex "������ ������" 0

# Repertoire editor:
menuText R RepFile "����" 0
menuText R RepFileNew "�����" 0
menuText R RepFileOpen "�������..." 0
menuText R RepFileSave "���������.." 0
menuText R RepFileSaveAs "��������� ���..." 2
menuText R RepFileClose "������� ����" 0
menuText R RepEdit "��������" 0
menuText R RepEditGroup "�������� ������" 9
menuText R RepEditInclude "�������� ���������� ������" 9
menuText R RepEditExclude "�������� ����������� ������" 9
menuText R RepView "���" 0
menuText R RepViewExpand "���������� ��� ������" 0
menuText R RepViewCollapse "����� ��� ������" 0
menuText R RepSearch "�����" 0
menuText R RepSearchAll "��� ����������..." 0
menuText R RepSearchDisplayed "���������� ������ ������..." 0
menuText R RepHelp "������" 4
menuText R RepHelpRep "������ �� ����������" 0
menuText R RepHelpIndex "������ ������" 0
translate R RepSearch "����� ����������"
translate R RepIncludedLines "���������� ������"
translate R RepExcludedLines "����������� ������"
translate R RepCloseDialog {� ���� ���������� �� ��������� ���������.

�� ������������� ������ ���������� �� �������� ��� ���������, ������� �� �������?
}

# Header search:
translate R HeaderSearch {����� �� ���������}
# ====== TODO To be translated ======
translate R EndSideToMove {Side to move at end of game}
translate R GamesWithNoECO {������ ��� ECO?}
translate R GameLength {����� ������}
translate R FindGamesWith {����� ������ � �������}
translate R StdStart {������������� ������}
translate R Promotions {�����������}
translate R Comments {�����������}
translate R Variations {��������}
translate R Annotations {���������}
translate R DeleteFlag {������� ����}
translate R WhiteOpFlag {����� �����}
translate R BlackOpFlag {����� ������}
translate R MiddlegameFlag {�����������}
translate R EndgameFlag {��������}
translate R NoveltyFlag {�������}
translate R PawnFlag {�������� ���������}
translate R TacticsFlag {�������}
translate R QsideFlag {���� �� �������� ������}
translate R KsideFlag {���� �� ����������� ������}
translate R BrilliancyFlag {�����������}
translate R BlunderFlag {������}
translate R UserFlag {������������}
translate R PgnContains {����� PGN}

# Game list window:
translate R GlistNumber {�����}
translate R GlistWhite {�����}
translate R GlistBlack {������}
translate R GlistWElo {�-Elo}
translate R GlistBElo {�-Elo}
translate R GlistEvent {������}
translate R GlistSite {�����}
translate R GlistRound {�����}
translate R GlistDate {����}
translate R GlistYear {���}
translate R GlistEDate {���� �������}
translate R GlistResult {���������}
translate R GlistLength {�����}
translate R GlistCountry {������}
translate R GlistECO {ECO}
translate R GlistOpening {�����}
translate R GlistEndMaterial {�������� ��������}
translate R GlistDeleted {���������}
translate R GlistFlags {�����}
translate R GlistVars {��������}
translate R GlistComments {�����������}
translate R GlistAnnos {���������}
translate R GlistStart {�����}
translate R GlistGameNumber {����� ������}
translate R GlistFindText {����� �����}
translate R GlistMoveField {�����������}
translate R GlistEditField {������������}
translate R GlistAddField {��������}
translate R GlistDeleteField {�������}
translate R GlistWidth {������}
translate R GlistAlign {������������}
translate R GlistColor {����}
translate R GlistSep {�����������}
# ====== TODO To be translated ======
translate R GlistRemoveThisGameFromFilter  {Remove this game from Filter}
# ====== TODO To be translated ======
translate R GlistRemoveGameAndAboveFromFilter  {Remove game (and all above it) from Filter}
# ====== TODO To be translated ======
translate R GlistRemoveGameAndBelowFromFilter  {Remove game (and all below it) from Filter}
# ====== TODO To be translated ======
translate R GlistDeleteGame {(Un)Delete this game} 
# ====== TODO To be translated ======
translate R GlistDeleteAllGames {Delete all games in filter} 
# ====== TODO To be translated ======
translate R GlistUndeleteAllGames {Undelete all games in filter} 

# Maintenance window:
translate R DatabaseName {�������� ���� ������:}
translate R TypeIcon {��� ������:}
translate R NumOfGames {������:}
translate R NumDeletedGames {��������� ������:}
translate R NumFilterGames {������ � �������:}
translate R YearRange {�������� �����:}
translate R RatingRange {�������� ��������:}
translate R Description {��������}
translate R Flag {����}
translate R DeleteCurrent {������� ������� ������}
translate R DeleteFilter {������� ��������������� ������}
translate R DeleteAll {������� ��� ������}
translate R UndeleteCurrent {������������ ������� ������}
translate R UndeleteFilter {������������ ��������������� ������}
translate R UndeleteAll {������������ ��� ������}
translate R DeleteTwins {������� ������� ������}
translate R MarkCurrent {�������� ������� ������}
translate R MarkFilter {�������� ��������������� ������}
translate R MarkAll {�������� ��� ������}
translate R UnmarkCurrent {����� ������� � ������� ������}
translate R UnmarkFilter {����� ������� � ��������������� ������}
translate R UnmarkAll {����� ������� �� ���� ������}
translate R Spellchecking {�������� ������������}
translate R Players {������}
translate R Events {�������}
translate R Sites {�����}
translate R Rounds {������}
translate R DatabaseOps {�������� � ����� ������}
translate R ReclassifyGames {������ � ����������������� ECO}
translate R CompactDatabase {������ ���� ������}
translate R SortDatabase {������������� ���� ������}
translate R AddEloRatings {�������� �������� Elo}
translate R AutoloadGame {������������ ������ ������}
translate R StripTags {������� ���� PGN}
translate R StripTag {������� ����}
translate R Cleaner {����������}
translate R CleanerHelp {
���������� Scid ���������� ��� �������������� ��������, ������� �� ������� � ������ ����, ��� ������� ����� ������.

������� ��������� ������������� ECO � ������� ������� �������� ����� ���������, ���� �� �������� ��� �������.
}
translate R CleanerConfirm {
���� ��������� ����������� ����������, ��� �� ����� ���� ��������!

��� ����� ������ ����� ������� �� ������� ���� ������, � ����������� �� �������, ������� �� ������� � �� ������� ���������.

�� �������, ��� ������ ������ ��������� �������, ������� �� �������?
}
# ====== TODO To be translated ======
translate R TwinCheckUndelete {to flip; "u" undeletes both)}
# ====== TODO To be translated ======
translate R TwinCheckprevPair {Previous pair}
# ====== TODO To be translated ======
translate R TwinChecknextPair {Next pair}
# ====== TODO To be translated ======
translate R TwinChecker {Scid: Twin game checker}
# ====== TODO To be translated ======
translate R TwinCheckTournament {Games in tournament:}
# ====== TODO To be translated ======
translate R TwinCheckNoTwin {No twin  }
# ====== TODO To be translated ======
translate R TwinCheckNoTwinfound {No twin was detected for this game.\nTo show twins using this window, you must first use the "Delete twin games..." function. }
# ====== TODO To be translated ======
translate R TwinCheckTag {Share tags...}
# ====== TODO To be translated ======
translate R TwinCheckFound1 {Scid found $result twin games}
# ====== TODO To be translated ======
translate R TwinCheckFound2 { and set their delete flags}
# ====== TODO To be translated ======
translate R TwinCheckNoDelete {There are no games in this database to delete.}
# ====== TODO To be translated ======
translate R TwinCriteria1 { Your settings for finding twin games are potentially likely to\ncause non-twin games with similar moves to be marked as twins.}
# ====== TODO To be translated ======
translate R TwinCriteria2 {It is recommended that if you select "No" for "same moves", you should select "Yes" for the colors, event, site, round, year and month settings.\nDo you want to continue and delete twins anyway? }
# ====== TODO To be translated ======
translate R TwinCriteria3 {It is recommended that you specify "Yes" for at least two of the "same site", "same round" and "same year" settings.\nDo you want to continue and delete twins anyway?}
# ====== TODO To be translated ======
translate R TwinCriteriaConfirm {Scid: Confirm twin settings}
# ====== TODO To be translated ======
translate R TwinChangeTag "Change the following game tags:\n\n"
# ====== TODO To be translated ======
translate R AllocRatingDescription "This command will use the current spellcheck file to add Elo ratings to games in this database. Wherever a player has no currrent rating but his/her rating at the time of the game is listed in the spellcheck file, that rating will be added."
# ====== TODO To be translated ======
translate R RatingOverride "Overwrite existing non-zero ratings?"
# ====== TODO To be translated ======
translate R AddRatings "Add ratings to:"
# ====== TODO To be translated ======
translate R AddedRatings {Scid added $r Elo ratings in $g games.}
# ====== TODO To be translated ======
translate R NewSubmenu "New submenu"

# Comment editor:
translate R AnnotationSymbols  {������� ���������:}
translate R Comment {�����������:}
translate R InsertMark {�������� ��������}
translate R InsertMarkHelp {
Insert/remove mark: Select color, type, square.
Insert/remove arrow: Right-click two squares.
}

# Nag buttons in comment editor:
translate R GoodMove {Good move}
translate R PoorMove {Poor move}
translate R ExcellentMove {Excellent move}
# ====== TODO To be translated ======
translate R Blunder {Blunder}
translate R InterestingMove {Interesting move}
translate R DubiousMove {Dubious move}
translate R WhiteDecisiveAdvantage {White has a decisive advantage}
translate R BlackDecisiveAdvantage {White has a decisive advantage}
translate R WhiteClearAdvantage {White has a clear advantage}
translate R BlackClearAdvantage {White has a clear advantage}
translate R WhiteSlightAdvantage {White has a slight advantage}
translate R BlackSlightAdvantage {White has a slight advantage}
translate R Equality {Equality}
translate R Unclear {Unclear}
translate R Diagram {Diagram}

# Board search:
translate R BoardSearch {����� �������}
translate R FilterOperation {�������� ��� ������� ��������:}
translate R FilterAnd {AND (�������������� ������)}
translate R FilterOr {OR (�������� � �������)}
translate R FilterIgnore {IGNORE (�������� ������)}
translate R SearchType {��� ������:}
translate R SearchBoardExact {������ ������� (��� ������ �� ��� �� �����)}
translate R SearchBoardPawns {����� (��� �� ��������, ��� ����� �� ��� �� �����)}
translate R SearchBoardFiles {���� (��� �� ��������, ��� ����� �� ��� �� �����)}
translate R SearchBoardAny {����� (��� �� ��������, ����� � ������ � ����� �����)}
translate R LookInVars {���������� � ���������}

# Material search:
translate R MaterialSearch {����� ���������}
translate R Material {��������}
translate R Patterns {�������}
translate R Zero {����}
translate R Any {�����}
translate R CurrentBoard {������� �������}
translate R CommonEndings {����� ��������}
translate R CommonPatterns {����� �������}
translate R MaterialDiff {������������ �������}
translate R squares {����}
translate R SameColor {��� �� ����}
translate R OppColor {��������������� ����}
translate R Either {���}
translate R MoveNumberRange {�������� ������� �����}
translate R MatchForAtLeast {��������� �� ������� ����}
translate R HalfMoves {���������}
# ====== TODO To be translated ======
translate R EndingPawns {Pawn endings}
# ====== TODO To be translated ======
translate R EndingRookVsPawns {Rook vs. Pawn(s)}
# ====== TODO To be translated ======
translate R EndingRookPawnVsRook {Rook and 1 Pawn vs. Rook}
# ====== TODO To be translated ======
translate R EndingRookPawnsVsRook {Rook and Pawn(s) vs. Rook}
# ====== TODO To be translated ======
translate R EndingRooks {Rook vs. Rook endings}
# ====== TODO To be translated ======
translate R EndingRooksPassedA {Rook vs. Rook endings with a passed a-pawn}
# ====== TODO To be translated ======
translate R EndingRooksDouble {Double Rook endings}
# ====== TODO To be translated ======
translate R EndingBishops {Bishop vs. Bishop endings}
# ====== TODO To be translated ======
translate R EndingBishopVsKnight {Bishop vs. Knight endings}
# ====== TODO To be translated ======
translate R EndingKnights {Knight vs. Knight endings}
# ====== TODO To be translated ======
translate R EndingQueens {Queen vs. Queen endings}
# ====== TODO To be translated ======
translate R EndingQueenPawnVsQueen {Queen and 1 Pawn vs. Queen}
# ====== TODO To be translated ======
translate R BishopPairVsKnightPair {Two Bishops vs. Two Knights middlegame}
# ====== TODO To be translated ======
translate R PatternWhiteIQP {White IQP}
# ====== TODO To be translated ======
translate R PatternWhiteIQPBreakE6 {White IQP: d4-d5 break vs. e6}
# ====== TODO To be translated ======
translate R PatternWhiteIQPBreakC6 {White IQP: d4-d5 break vs. c6}
# ====== TODO To be translated ======
translate R PatternBlackIQP {Black IQP}
# ====== TODO To be translated ======
translate R PatternWhiteBlackIQP {White IQP vs. Black IQP}
# ====== TODO To be translated ======
translate R PatternCoupleC3D4 {White c3+d4 Isolated Pawn Couple}
# ====== TODO To be translated ======
translate R PatternHangingC5D5 {Black Hanging Pawns on c5 and d5}
# ====== TODO To be translated ======
translate R PatternMaroczy {Maroczy Center (with Pawns on c4 and e4)}
# ====== TODO To be translated ======
translate R PatternRookSacC3 {Rook Sacrifice on c3}
# ====== TODO To be translated ======
translate R PatternKc1Kg8 {O-O-O vs. O-O (Kc1 vs. Kg8)}
# ====== TODO To be translated ======
translate R PatternKg1Kc8 {O-O vs. O-O-O (Kg1 vs. Kc8)}
# ====== TODO To be translated ======
translate R PatternLightFian {Light-Square Fianchettos (Bishop-g2 vs. Bishop-b7)}
# ====== TODO To be translated ======
translate R PatternDarkFian {Dark-Square Fianchettos (Bishop-b2 vs. Bishop-g7)}
# ====== TODO To be translated ======
translate R PatternFourFian {Four Fianchettos (Bishops on b2,g2,b7,g7)}

# Game saving:
translate R Today {�������}
translate R ClassifyGame {������������������ ������}

# Setup position:
translate R EmptyBoard {������ �����}
translate R InitialBoard {��������� �������}
translate R SideToMove {������� ����}
translate R MoveNumber {����� ����}
translate R Castling {���������}
translate R EnPassantFile {���������� ����}
translate R ClearFen {�������� FEN}
translate R PasteFen {�������� FEN}
# ====== TODO To be translated ======
translate R SaveAndContinue {Save and continue}
# ====== TODO To be translated ======
translate R DiscardChangesAndContinue {Discard changes\nand continue}
# ====== TODO To be translated ======
translate R GoBack {Go back}

# Replace move dialog:
translate R ReplaceMove {�������� ���}
translate R AddNewVar {�������� ����� �������}
# ====== TODO To be translated ======
translate R NewMainLine {New Main Line}
translate R ReplaceMoveMessage {����� ��� ���� ���.

�� ������ �������� ���, ��������� ��� ���� ����� ����, ��� �������� ��� ���, ��� ����� �������.

(�� ������ �������� ��������� ����� ��������� � �������, �������� ��������� "�������� ����� �������� �����" � ���� ���������:���� �����.)}

# Make database read-only dialog:
translate R ReadOnlyDialog {���� �� �������� ��� ���� ������ ������ ��� ������, �� ����� ��������� ������� ���������.
������ �� ����� ���� �������� ��� ��������, � ��������� ����� �� ����� ���� ��������.
���������� ����� ���������� � ������������� ECO ����� ����������.

�� ������ ����� ������� ���� ������ �������������� � ������� �������� � ������������.

�� ������������� ������� ������� ��� ���� ������ ������ ��� ������?}

# Clear game dialog:
translate R ClearGameDialog {��� ������ ���� ��������.

�� ������������� ������� ����������, ������� ��� ��������� ���������?
}

# Exit dialog:
translate R ExitDialog {�� ������������� ������ ����� �� Scid?}
translate R ExitUnsaved {��������� ���� ������ ����� �� ����������� ���������� ������. ���� �� ������� ������, ��������� ����� �������.}

# Import window:
translate R PasteCurrentGame {�������� ������� ������}
translate R ImportHelp1 {������ ��� �������� ������ � ������� PGN � ������� ����.}
translate R ImportHelp2 {��� ������ �������������� ������ ����� �������� �����.}
# ====== TODO To be translated ======
translate R OverwriteExistingMoves {Overwrite existing moves ?}

# ECO Browser:
translate R ECOAllSections {��� ������ ECO}
translate R ECOSection {������ ECO}
translate R ECOSummary {����� ���}
translate R ECOFrequency {������� �������� ���}

# Opening Report:
translate R OprepTitle {�������� �����}
translate R OprepReport {�����}
translate R OprepGenerated {���������������}
translate R OprepStatsHist {���������� � �������}
translate R OprepStats {����������}
translate R OprepStatAll {��� �������� ������}
translate R OprepStatBoth {��� � ���������}
translate R OprepStatSince {�}
translate R OprepOldest {��������� ������}
translate R OprepNewest {�������� ������}
translate R OprepPopular {������� ����������}
translate R OprepFreqAll {������� �� ��� ����:   }
translate R OprepFreq1   {� ��������� ���: }
translate R OprepFreq5   {� ��������� ���� ���: }
translate R OprepFreq10  {� ��������� ������ ���: }
translate R OprepEvery {���� ��� ������ %u ������}
translate R OprepUp {���� - %u%s �� ���� ���}
translate R OprepDown {���� - %u%s �� ���� ���}
translate R OprepSame {��� ��������� ������ ���� �����}
translate R OprepMostFrequent {�������� ����� � �������}
translate R OprepMostFrequentOpponents {Most frequent opponents}
translate R OprepRatingsPerf {�������� � ������������������}
translate R OprepAvgPerf {������� �������� � ������������������}
translate R OprepWRating {������� �����}
translate R OprepBRating {������� ������}
translate R OprepWPerf {������������������ �����}
translate R OprepBPerf {������������������ ������}
translate R OprepHighRating {������ � ���������� ������� ���������}
translate R OprepTrends {�������������� ���������}
translate R OprepResults {�������������� ����� � �������}
translate R OprepLength {����� ������}
translate R OprepFrequency {�������}
translate R OprepWWins {����� ��������: }
translate R OprepBWins {������ ��������: }
translate R OprepDraws {�����:      }
translate R OprepWholeDB {��� ���� ������}
translate R OprepShortest {����� �������� ������}
translate R OprepMovesThemes {���� � ����}
translate R OprepMoveOrders {������� �����  ��� ���������� �������� �������}
translate R OprepMoveOrdersOne \
  {������ ������ ���� ������� ����� ��� ���������� �������� �������:}
translate R OprepMoveOrdersAll \
  {������� %u �������� �����  ��� ���������� �������� �������:}
translate R OprepMoveOrdersMany \
  {������� %u �������� �����  ��� ���������� �������� �������. ������� %u:}
translate R OprepMovesFrom {���� �� �������� �������}
translate R OprepMostFrequentEcoCodes {Most frequent ECO codes}
translate R OprepThemes {����������� ����}
translate R OprepThemeDescription {Frequency of themes in the first %u moves of each game}
translate R OprepThemeSameCastling {������������� ���������}
translate R OprepThemeOppCastling {���������������� ���������}
translate R OprepThemeNoCastling {��� ������ �� ����������}
translate R OprepThemeKPawnStorm {����� ������������ �������}
translate R OprepThemeQueenswap {�������� ������}
translate R OprepThemeWIQP {White Isolated Queen Pawn}
translate R OprepThemeBIQP {Black Isolated Queen Pawn}
translate R OprepThemeWP567 {����� ����� �� 5/6/7 �����������}
translate R OprepThemeBP234 {������ ����� �� 2/3/4 �����������}
translate R OprepThemeOpenCDE {������� c/d/e ���������}
translate R OprepTheme1BishopPair {������ ���� ������� ����� �������� ����}
translate R OprepEndgames {��������}
translate R OprepReportGames {�������� ������}
translate R OprepAllGames    {��� ������}
translate R OprepEndClass {�������� � ����� ������ ������}
translate R OprepTheoryTable {������������� �������}
translate R OprepTableComment {������������� �� %u ����������������� ������.}
translate R OprepExtraMoves {������� ������� � ����� � ������������� �������}
translate R OprepMaxGames {�������� ������ � ������������� �������}
translate R OprepViewHTML {View HTML}
translate R OprepViewLaTeX {View LaTeX}

# Player Report:
translate R PReportTitle {Player Report}
translate R PReportColorWhite {with the White pieces}
translate R PReportColorBlack {with the Black pieces}
translate R PReportMoves {after %s}
translate R PReportOpenings {Openings}
translate R PReportClipbase {Empty clipbase and copy matching games to it}

# Piece Tracker window:
translate R TrackerSelectSingle {����� ������ ����� �������� ��� ������.}
translate R TrackerSelectPair {����� ������ ����� �������� ��� ������; ������ �������� ��� ���������� ������.}
translate R TrackerSelectPawn {����� ������ ����� �������� ��� ������; ������ �������� ��� 8 �����.}
translate R TrackerStat {����������}
translate R TrackerGames {% ������ � ������ �� ��� ����}
translate R TrackerTime {% ������� �� ������ ����}
translate R TrackerMoves {����}
translate R TrackerMovesStart {������� ����� ����, � �������� ����������� ����������.}
translate R TrackerMovesStop {������� ����� ����, ������� ����������� �������������.}

# Game selection dialogs:
translate R SelectAllGames {��� ������ � ���� ������}
translate R SelectFilterGames {������ ��������������� ������}
translate R SelectTournamentGames {������ ������ �������� �������}
translate R SelectOlderGames {������ ������ ������}

# Delete Twins window:
translate R TwinsNote {����� ���� ���������, ��� ������ ������ ��� ������� ����� ��� �� �������, � ��������, ������� �� ���������� ����. ����� ���� ��������� �������, ����� �������� ������ ���������. ���������: ����� ������� ��������� ����� ��������� ������������, ��� �������� ����� ���������. }
translate R TwinsCriteria {��������: �������� ������ �����...}
translate R TwinsWhich {�������� ����� ������}
translate R TwinsColors {����� ������ ��� �� ������?}
translate R TwinsEvent {��� �� ������?}
translate R TwinsSite {�� �� �����?}
translate R TwinsRound {��� �� �����?}
translate R TwinsYear {��� �� ���?}
translate R TwinsMonth {��� �� �����?}
translate R TwinsDay {��� �� ����?}
translate R TwinsResult {��� �� ���������?}
translate R TwinsECO {��� �� ��� ECO?}
translate R TwinsMoves {�� �� ����?}
translate R TwinsPlayers {�������� ����� �������:}
translate R TwinsPlayersExact {������ ����������}
translate R TwinsPlayersPrefix {������ ������ 4 �����}
translate R TwinsWhen {����� ������� ������� ������}
translate R TwinsSkipShort {������������ ��� ������, ��� ������ 5 �����?}
translate R TwinsUndelete {������������ ��� ������ �������?}
translate R TwinsSetFilter {���������� ������ ��� ���� �������� ���������?}
translate R TwinsComments {������ ������� ������ � �������������?}
translate R TwinsVars {������ ������� ������ � ����������?}
translate R TwinsDeleteWhich {������� ����� ������:}
translate R TwinsDeleteShorter {����� �������� ������}
translate R TwinsDeleteOlder {������� ����� ������}
translate R TwinsDeleteNewer {������� ����� ������}
translate R TwinsDelete {������� ������}

# Name editor window:
translate R NameEditType {��� ����� ��� ��������������}
translate R NameEditSelect {������ ��� ��������������}
translate R NameEditReplace {��������}
translate R NameEditWith {�}
translate R NameEditMatches {����������: ������� Ctrl+1 - Ctrl+9 ��� ������}

# Classify window:
translate R Classify {����������������}
translate R ClassifyWhich {������ � ������������������ ECO}
translate R ClassifyAll {��� ������ (���������� ������ ECO)}
translate R ClassifyYear {��� ������, ��������� �� ��������� ���}
translate R ClassifyMonth {��� ������, ��������� �� ��������� �����}
translate R ClassifyNew {������ ������ ��� ���� ECO}
translate R ClassifyCodes {���� ECO ��� �������������}
translate R ClassifyBasic {������ �������� ���� ("B12", ...)}
translate R ClassifyExtended {Scid ���������� ("B12j", ...)}

# Compaction:
translate R NameFile {���� ����}
translate R GameFile {���� ������}
translate R Names {�����}
translate R Unused {�� ������������}
translate R SizeKb {������ (kb)}
translate R CurrentState {������� ���������}
translate R AfterCompaction {����� ������}
translate R CompactNames {������ ���� ����}
translate R CompactGames {������ ���� ������}
# ====== TODO To be translated ======
translate R NoUnusedNames "There are no unused names, so the name file is already fully compacted."
# ====== TODO To be translated ======
translate R NoUnusedGames "The game file is already fully compacted."
# ====== TODO To be translated ======
translate R NameFileCompacted {The name file for the database "[file tail [sc_base filename]]" was compacted.}
# ====== TODO To be translated ======
translate R GameFileCompacted {The game file for the database "[file tail [sc_base filename]]" was compacted.}

# Sorting:
translate R SortCriteria {��������}
translate R AddCriteria {�������� ��������}
translate R CommonSorts {����� ����������}
translate R Sort {����������}

# Exporting:
translate R AddToExistingFile {�������� ������ � ������������ ����?}
translate R ExportComments {�������������� �����������?}
translate R ExportVariations {�������������� ��������?}
translate R IndentComments {����������� � ��������?}
translate R IndentVariations {�������� � ��������?}
translate R ExportColumnStyle {� ������� (���� ��� �� ������)?}
translate R ExportSymbolStyle {����� ������������� ���������:}
translate R ExportStripMarks {������� ������������� ���� �����/������� �� ������������?}

# Goto game/move dialogs:
translate R LoadGameNumber {������� ����� ������ ��� ��������:}
translate R GotoMoveNumber {������� � ���� �����:}

# Copy games dialog:
translate R CopyGames {����������� ������}
translate R CopyConfirm {
 �� ������������� ������� �����������
 [::utils::thousands $nGamesToCopy] ��������������� ������
 �� ���� ������ "$fromName"
 � ���� ������ "$targetName"?
}
translate R CopyErr {�� ���� ����������� ������}
translate R CopyErrSource {�������� ���� ������}
translate R CopyErrTarget {������� ���� ������}
translate R CopyErrNoGames {has no games in its filter}
translate R CopyErrReadOnly {������ ��� ������}
translate R CopyErrNotOpen {�� �������}

# Colors:
translate R LightSquares {������� ����}
translate R DarkSquares {������ ����}
translate R SelectedSquares {��������� ����}
translate R SuggestedSquares {���� ������������ �����}
translate R WhitePieces {����� ������}
translate R BlackPieces {������ ������}
translate R WhiteBorder {����� �������}
translate R BlackBorder {������ �������}

# Novelty window:
translate R FindNovelty {����� �������}
translate R Novelty {�������}
translate R NoveltyInterrupt {����� ������� �������}
translate R NoveltyNone {� ���� ������ ������� �� �������}
translate R NoveltyHelp {Scid ������ ������ ��� � ������� ������, ������� �������� � �������, ������������� � ������� ���� ������ � �������� �����.}
# ====== TODO To be translated ======
translate R SoundsFolder {Sound Files Folder}
# ====== TODO To be translated ======
translate R SoundsFolderHelp {The folder should contain the files King.wav, a.wav, 1.wav, etc}
# ====== TODO To be translated ======
translate R SoundsAnnounceOptions {Move Announcement Options}
# ====== TODO To be translated ======
translate R SoundsAnnounceNew {Announce new moves as they are made}
# ====== TODO To be translated ======
translate R SoundsAnnounceForward {Announce moves when moving forward one move}
# ====== TODO To be translated ======
translate R SoundsAnnounceBack {Announce when retracting or moving back one move}

# Upgrading databases:
translate R Upgrading {�����������}
translate R ConfirmOpenNew {
��� ������ ������ (Scid 2) ���� ������, ������� �� ����� ���� ������ � Scid 3, �� ������ ����� ������ (Scid 3) ��� ����� ���� ������.

�� ������� ������� ������ ������ ������� ���� ������?
}
translate R ConfirmUpgrade {
��� ������ ������ (Scid 2) ���� ������. ����� ������ ���� ������ ������ ���� ������ ����� ��� ��� ������������ ��� � Scid 3.

���������� ������� ����� ������ ���� ������; ��� �� ������� � �� ������ ������������ �����.

��� ����� ������ �����, �� ��� �������� ������ ���� ���. �� ������ ��������, ���� ��� �������� ������� ����� �������.

�� ������� �������� ���� ������ ������?
}

# Recent files options:
translate R RecentFilesMenu {����� ������� ����������� ������ � �������� ����}
translate R RecentFilesExtra {����� ������� ����������� ������ �� ������� �������}

# My Player Names options:
translate R MyPlayerNamesDescription {
Enter a list of preferred player names below, one name per line. Wildcards (e.g. "?" for any single character, "*" for any sequence of characters) are permitted.

Every time a game with a player in the list is loaded, the main window chessboard will be rotated if necessary to show the game from that players perspective.
}
# ====== TODO To be translated ======
translate R showblunderexists {show blunder exists}
# ====== TODO To be translated ======
translate R showblundervalue {show blunder value}
# ====== TODO To be translated ======
translate R showscore {show score}
# ====== TODO To be translated ======
translate R coachgame {coach game}
# ====== TODO To be translated ======
translate R configurecoachgame {configure coach game}
# ====== TODO To be translated ======
translate R configuregame {Game configuration}
# ====== TODO To be translated ======
translate R Phalanxengine {Phalanx engine}
# ====== TODO To be translated ======
translate R Coachengine {Coach engine}
# ====== TODO To be translated ======
translate R difficulty {difficulty}
# ====== TODO To be translated ======
translate R hard {hard}
# ====== TODO To be translated ======
translate R easy {easy}
# ====== TODO To be translated ======
translate R Playwith {Play with}
# ====== TODO To be translated ======
translate R white {white}
# ====== TODO To be translated ======
translate R black {black}
# ====== TODO To be translated ======
translate R both {both}
# ====== TODO To be translated ======
translate R Play {Play}
# ====== TODO To be translated ======
translate R Noblunder {No blunder}
# ====== TODO To be translated ======
translate R blunder {blunder}
# ====== TODO To be translated ======
translate R Noinfo {-- No info --}
# ====== TODO To be translated ======
translate R PhalanxOrTogaMissing {Phalanx or Toga not found}
# ====== TODO To be translated ======
# ====== TODO To be translated ======
# ====== TODO To be translated ======
translate R moveblunderthreshold {move is a blunder if loss is greater than}
# ====== TODO To be translated ======
translate R limitanalysis {limit engine analysis time}
# ====== TODO To be translated ======
translate R seconds {seconds}
# ====== TODO To be translated ======
translate R Abort {Abort}
# ====== TODO To be translated ======
translate R Resume {Resume}
# ====== TODO To be translated ======
translate R OutOfOpening {Out of opening}
# ====== TODO To be translated ======
translate R NotFollowedLine {You did not follow the line}
# ====== TODO To be translated ======
translate R DoYouWantContinue {Do you want yo continue ?}
# ====== TODO To be translated ======
translate R CoachIsWatching {Coach is watching}
# ====== TODO To be translated ======
translate R Ponder {Permanent thinking}
# ====== TODO To be translated ======
translate R LimitELO {Limit ELO strength}
# ====== TODO To be translated ======
translate R DubiousMovePlayedTakeBack {Dubious move played, do you want to take back ?}
# ====== TODO To be translated ======
translate R WeakMovePlayedTakeBack {Weak move played, do you want to take back ?}
# ====== TODO To be translated ======
translate R BadMovePlayedTakeBack {Bad move played, do you want to take back ?}
# ====== TODO To be translated ======
translate R Iresign {I resign}
# ====== TODO To be translated ======
translate R yourmoveisnotgood {your move is not good}
# ====== TODO To be translated ======
translate R EndOfVar {End of variation}
# ====== TODO To be translated ======
translate R Openingtrainer {Opening trainer}
# ====== TODO To be translated ======
translate R DisplayCM {Display candidate moves}
# ====== TODO To be translated ======
translate R DisplayCMValue {Display candidate moves value}
# ====== TODO To be translated ======
translate R DisplayOpeningStats {Show statistics}
# ====== TODO To be translated ======
translate R ShowReport {Show report}
# ====== TODO To be translated ======
translate R NumberOfGoodMovesPlayed {good moves played}
# ====== TODO To be translated ======
translate R NumberOfDubiousMovesPlayed {dubious moves played}
# ====== TODO To be translated ======
translate R NumberOfMovesPlayedNotInRepertoire {moves played not in repertoire}
# ====== TODO To be translated ======
translate R NumberOfTimesPositionEncountered {times position encountered}
# ====== TODO To be translated ======
translate R PlayerBestMove  {Allow only best moves}
# ====== TODO To be translated ======
translate R OpponentBestMove {Opponent plays best moves}
# ====== TODO To be translated ======
translate R OnlyFlaggedLines {Only flagged lines}
# ====== TODO To be translated ======
translate R resetStats {Reset statistics}
# ====== TODO To be translated ======
translate R Repertoiretrainingconfiguration {Repertoire training configuration}
# ====== TODO To be translated ======
translate R Loadingrepertoire {Loading repertoire}
# ====== TODO To be translated ======
translate R Movesloaded {Moves loaded}
# ====== TODO To be translated ======
translate R Repertoirenotfound {Repertoire not found}
# ====== TODO To be translated ======
translate R Openfirstrepertoirewithtype {Open first a repertoire database with icon/type set to the right side}
# ====== TODO To be translated ======
translate R Movenotinrepertoire {Move not in repertoire}
# ====== TODO To be translated ======
translate R PositionsInRepertoire {Positions in repertoire}
# ====== TODO To be translated ======
translate R PositionsNotPlayed {Positions not played}
# ====== TODO To be translated ======
translate R PositionsPlayed {Positions played}
# ====== TODO To be translated ======
translate R Success {Success}
# ====== TODO To be translated ======
translate R DubiousMoves {Dubious moves}
# ====== TODO To be translated ======
translate R OutOfRepertoire {OutOfRepertoire}
# ====== TODO To be translated ======
# ====== TODO To be translated ======
# ====== TODO To be translated ======
# ====== TODO To be translated ======
translate R ConfigureTactics {Configure tactics}
# ====== TODO To be translated ======
translate R ResetScores {Reset scores}
# ====== TODO To be translated ======
translate R LoadingBase {Loading base}
# ====== TODO To be translated ======
translate R Tactics {Tactics}
# ====== TODO To be translated ======
translate R ShowSolution {Show solution}
# ====== TODO To be translated ======
translate R Next {Next}
# ====== TODO To be translated ======
translate R ResettingScore {Resetting score}
# ====== TODO To be translated ======
translate R LoadingGame {Loading game}
# ====== TODO To be translated ======
translate R MateFound {Mate found}
# ====== TODO To be translated ======
translate R BestSolutionNotFound {Best solution NOT found !}
# ====== TODO To be translated ======
translate R MateNotFound {Mate not found}
# ====== TODO To be translated ======
translate R ShorterMateExists {Shorter mate exists}
# ====== TODO To be translated ======
translate R ScorePlayed {Score played}
# ====== TODO To be translated ======
translate R Expected {expected}
# ====== TODO To be translated ======
translate R ChooseTrainingBase {Choose training base}
# ====== TODO To be translated ======
translate R Thinking {Thinking}
# ====== TODO To be translated ======
translate R AnalyzeDone {Analyze done}
# ====== TODO To be translated ======
translate R WinWonGame {Win won game}
# ====== TODO To be translated ======
translate R Lines {Lines}
# ====== TODO To be translated ======
translate R ConfigureUCIengine {Configure UCI engine}
# ====== TODO To be translated ======
translate R SpecificOpening {Specific opening}
# ====== TODO To be translated ======
translate R StartNewGame {Start new game}
# ====== TODO To be translated ======
translate R FixedLevel {Fixed level}
# ====== TODO To be translated ======
translate R Opening {Opening}
# ====== TODO To be translated ======
translate R RandomLevel {Random level}
# ====== TODO To be translated ======
translate R StartFromCurrentPosition {Start from current position}
# ====== TODO To be translated ======
translate R FixedDepth {Fixed depth}
# ====== TODO To be translated ======
translate R Nodes {Nodes} 
# ====== TODO To be translated ======
translate R Depth {Depth}
# ====== TODO To be translated ======
translate R Time {Time} 
# ====== TODO To be translated ======
translate R SecondsPerMove {Seconds per move}
# ====== TODO To be translated ======
translate R Engine {Engine}
# ====== TODO To be translated ======
translate R TimeMode {Time mode}
# ====== TODO To be translated ======
translate R TimeBonus {Time + bonus}
# ====== TODO To be translated ======
# ====== TODO To be translated ======
translate R TimeMin {min}
# ====== TODO To be translated ======
translate R TimeSec {sec}
# ====== TODO To be translated ======
# ====== TODO To be translated ======
# ====== TODO To be translated ======
translate R AllExercisesDone {All exercises done}
# ====== TODO To be translated ======
translate R MoveOutOfBook {Move out of book}
# ====== TODO To be translated ======
translate R LastBookMove {Last book move}
# ====== TODO To be translated ======
translate R AnnotateSeveralGames {Annotate several games\nfrom current to :}
# ====== TODO To be translated ======
translate R FindOpeningErrors {Find opening errors}
# ====== TODO To be translated ======
translate R MarkTacticalExercises {Mark tactical exercises}
# ====== TODO To be translated ======
translate R UseBook {Use book}
# ====== TODO To be translated ======
translate R MultiPV {Multiple variations}
# ====== TODO To be translated ======
translate R Hash {Hash memory}
# ====== TODO To be translated ======
translate R OwnBook {Use engine book}
# ====== TODO To be translated ======
translate R BookFile {Opening book}
# ====== TODO To be translated ======
translate R AnnotateVariations {Annotate variations}
# ====== TODO To be translated ======
translate R ShortAnnotations {Short annotations}
# ====== TODO To be translated ======
translate R addAnnotatorTag {Add annotator tag}
# ====== TODO To be translated ======
translate R AddScoreToShortAnnotations {Add score to short annotations}
# ====== TODO To be translated ======
translate R Export {Export}
# ====== TODO To be translated ======
translate R BookPartiallyLoaded {Book partially loaded}
# ====== TODO To be translated ======
translate R Calvar {Calculation of variations}
# ====== TODO To be translated ======
translate R ConfigureCalvar {Configuration}
# ====== TODO To be translated ======
# ====== TODO To be translated ======
translate R Reti {Reti}
# ====== TODO To be translated ======
translate R English {English}
# ====== TODO To be translated ======
translate R d4Nf6Miscellaneous {1.d4 Nf6 Miscellaneous}
# ====== TODO To be translated ======
translate R Trompowsky {Trompowsky}
# ====== TODO To be translated ======
translate R Budapest {Budapest}
# ====== TODO To be translated ======
translate R OldIndian {Old Indian}
# ====== TODO To be translated ======
translate R BenkoGambit {Benko Gambit}
# ====== TODO To be translated ======
translate R ModernBenoni {Modern Benoni}
# ====== TODO To be translated ======
translate R DutchDefence {Dutch Defence}
# ====== TODO To be translated ======
translate R Scandinavian {Scandinavian}
# ====== TODO To be translated ======
translate R AlekhineDefence {Alekhine Defence}
# ====== TODO To be translated ======
translate R Pirc {Pirc}
# ====== TODO To be translated ======
translate R CaroKann {Caro-Kann}
# ====== TODO To be translated ======
translate R CaroKannAdvance {Caro-Kann Advance}
# ====== TODO To be translated ======
translate R Sicilian {Sicilian}
# ====== TODO To be translated ======
translate R SicilianAlapin {Sicilian Alapin}
# ====== TODO To be translated ======
translate R SicilianClosed {Sicilian Closed}
# ====== TODO To be translated ======
translate R SicilianRauzer {Sicilian Rauzer}
# ====== TODO To be translated ======
translate R SicilianDragon {Sicilian Dragon}
# ====== TODO To be translated ======
translate R SicilianScheveningen {Sicilian Scheveningen}
# ====== TODO To be translated ======
translate R SicilianNajdorf {Sicilian Najdorf}
# ====== TODO To be translated ======
translate R OpenGame {Open Game}
# ====== TODO To be translated ======
translate R Vienna {Vienna}
# ====== TODO To be translated ======
translate R KingsGambit {King's Gambit}
# ====== TODO To be translated ======
translate R RussianGame {Russian Game}
# ====== TODO To be translated ======
translate R ItalianTwoKnights {Italian/Two Knights}
# ====== TODO To be translated ======
translate R Spanish {Spanish}
# ====== TODO To be translated ======
translate R SpanishExchange {Spanish Exchange}
# ====== TODO To be translated ======
translate R SpanishOpen {Spanish Open}
# ====== TODO To be translated ======
translate R SpanishClosed {Spanish Closed}
# ====== TODO To be translated ======
translate R FrenchDefence {French Defence}
# ====== TODO To be translated ======
translate R FrenchAdvance {French Advance}
# ====== TODO To be translated ======
translate R FrenchTarrasch {French Tarrasch}
# ====== TODO To be translated ======
translate R FrenchWinawer {French Winawer}
# ====== TODO To be translated ======
translate R FrenchExchange {French Exchange}
# ====== TODO To be translated ======
translate R QueensPawn {Queen's Pawn}
# ====== TODO To be translated ======
translate R Slav {Slav}
# ====== TODO To be translated ======
translate R QGA {QGA}
# ====== TODO To be translated ======
translate R QGD {QGD}
# ====== TODO To be translated ======
translate R QGDExchange {QGD Exchange}
# ====== TODO To be translated ======
translate R SemiSlav {Semi-Slav}
# ====== TODO To be translated ======
translate R QGDwithBg5 {QGD with Bg5}
# ====== TODO To be translated ======
translate R QGDOrthodox {QGD Orthodox}
# ====== TODO To be translated ======
translate R Grunfeld {Gr?nfeld}
# ====== TODO To be translated ======
translate R GrunfeldExchange {Gr?nfeld Exchange}
# ====== TODO To be translated ======
translate R GrunfeldRussian {Gr?nfeld Russian}
# ====== TODO To be translated ======
translate R Catalan {Catalan}
# ====== TODO To be translated ======
translate R CatalanOpen {Catalan Open}
# ====== TODO To be translated ======
translate R CatalanClosed {Catalan Closed}
# ====== TODO To be translated ======
translate R QueensIndian {Queen's Indian}
# ====== TODO To be translated ======
translate R NimzoIndian {Nimzo-Indian}
# ====== TODO To be translated ======
translate R NimzoIndianClassical {Nimzo-Indian Classical}
# ====== TODO To be translated ======
translate R NimzoIndianRubinstein {Nimzo-Indian Rubinstein}
# ====== TODO To be translated ======
translate R KingsIndian {King's Indian}
# ====== TODO To be translated ======
translate R KingsIndianSamisch {King's Indian S?misch}
# ====== TODO To be translated ======
translate R KingsIndianMainLine {King's Indian Main Line}
# ====== TODO To be translated ======
translate R CCDlgConfigureWindowTitle {Configure Correspondence Chess}
# ====== TODO To be translated ======
translate R CCDlgCGeneraloptions {General Options}
# ====== TODO To be translated ======
translate R CCDlgDefaultDB {Default Database:}
# ====== TODO To be translated ======
translate R CCDlgInbox {Inbox (path):}
# ====== TODO To be translated ======
translate R CCDlgOutbox {Outbox (path):}
# ====== TODO To be translated ======
translate R CCDlgXfcc {Xfcc Configuration:}
# ====== TODO To be translated ======
translate R CCDlgExternalProtocol {External Protocol Handler (e.g. Xfcc)}
# ====== TODO To be translated ======
translate R CCDlgFetchTool {Fetch Tool:}
# ====== TODO To be translated ======
translate R CCDlgSendTool {Send Tool:}
# ====== TODO To be translated ======
translate R CCDlgEmailCommunication {eMail Communication}
# ====== TODO To be translated ======
translate R CCDlgMailPrg {Mail program:}
# ====== TODO To be translated ======
translate R CCDlgBCCAddr {(B)CC Address:}
# ====== TODO To be translated ======
translate R CCDlgMailerMode {Mode:}
# ====== TODO To be translated ======
translate R CCDlgThunderbirdEg {e.g. Thunderbird, Mozilla Mail, Icedove...}
# ====== TODO To be translated ======
translate R CCDlgMailUrlEg {e.g. Evolution}
# ====== TODO To be translated ======
translate R CCDlgClawsEg {e.g Sylpheed Claws}
# ====== TODO To be translated ======
translate R CCDlgmailxEg {e.g. mailx, mutt, nail...}
# ====== TODO To be translated ======
translate R CCDlgAttachementPar {Attachment parameter:}
# ====== TODO To be translated ======
translate R CCDlgInternalXfcc {Use internal Xfcc support}
# ====== TODO To be translated ======
translate R CCDlgSubjectPar {Subject parameter:}
# ====== TODO To be translated ======
translate R CCDlgStartEmail {Start new eMail game}
# ====== TODO To be translated ======
translate R CCDlgYourName {Your Name:}
# ====== TODO To be translated ======
translate R CCDlgYourMail {Your eMail Address:}
# ====== TODO To be translated ======
translate R CCDlgOpponentName {Opponents Name:}
# ====== TODO To be translated ======
translate R CCDlgOpponentMail {Opponents eMail Address:}
# ====== TODO To be translated ======
translate R CCDlgGameID {Game ID (unique):}
# ====== TODO To be translated ======
translate R CCDlgTitNoOutbox {Scid: Correspondence Chess Outbox}
# ====== TODO To be translated ======
translate R CCDlgTitNoInbox {Scid: Correspondence Chess Inbox}
# ====== TODO To be translated ======
translate R CCDlgTitNoGames {Scid: No Correspondence Chess Games}
# ====== TODO To be translated ======
translate R CCErrInboxDir {Correspondence Chess inbox directory:}
# ====== TODO To be translated ======
translate R CCErrOutboxDir {Correspondence Chess outbox directory:}
# ====== TODO To be translated ======
translate R CCErrDirNotUsable {does not exist or is not accessible!\nPlease check and correct the settings.}
# ====== TODO To be translated ======
translate R CCErrNoGames {does not contain any games!\nPlease fetch them first.}
# ====== TODO To be translated ======
translate R CCDlgTitNoCCDB {Scid: No Correspondence Database}
# ====== TODO To be translated ======
translate R CCErrNoCCDB {No Database of type 'Correspondence' is opened. Please open one before using correspondence chess functions.}
# ====== TODO To be translated ======
translate R CCFetchBtn {Fetch games from the server and process the Inbox}
# ====== TODO To be translated ======
translate R CCPrevBtn {Goto previous game}
# ====== TODO To be translated ======
translate R CCNextBtn {Goto next game}
# ====== TODO To be translated ======
translate R CCSendBtn {Send move}
# ====== TODO To be translated ======
translate R CCEmptyBtn {Empty In- and Outbox}
# ====== TODO To be translated ======
translate R CCHelpBtn {Help on icons and status indicators.\nFor general Help press F1!}
# ====== TODO To be translated ======
translate R ExtHWConfigConnection {Configure external hardware}
# ====== TODO To be translated ======
translate R ExtHWPort {Port}
# ====== TODO To be translated ======
translate R ExtHWEngineCmd {Engine command}
# ====== TODO To be translated ======
translate R ExtHWEngineParam {Engine parameter}
# ====== TODO To be translated ======
translate R ExtHWShowButton {Show button}
# ====== TODO To be translated ======
translate R ExtHWHardware {Hardware}
# ====== TODO To be translated ======
translate R ExtHWNovag {Novag Citrine}
# ====== TODO To be translated ======
translate R ExtHWInputEngine {Input Engine}
# ====== TODO To be translated ======
translate R ExtHWNoBoard {No board}
# ====== TODO To be translated ======
translate R IEConsole {Input Engine Console}
# ====== TODO To be translated ======
translate R IESending {Moves sent for}
# ====== TODO To be translated ======
translate R IESynchronise {Synchronise}
# ====== TODO To be translated ======
translate R IESyncrhonise {Synchronise}
# ====== TODO To be translated ======
translate R IERotate  {Rotate}
# ====== TODO To be translated ======
translate R IEUnableToStart {Unable to start Input Engine:}
# ====== TODO To be translated ======
translate R DoneWithPosition {Done with position}
# ====== TODO To be translated ======
}
# end of russian.tcl















