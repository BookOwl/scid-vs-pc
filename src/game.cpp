//////////////////////////////////////////////////////////////////////
//
//  FILE:       game.cpp
//              Game class methods
//
//  Part of:    Scid (Shane's Chess Information Database)
//  Version:    3.5
//
//  Notice:     Copyright (c) 2000-2003  Shane Hudson.  All rights reserved.
//
//  Author:     Shane Hudson (sgh@users.sourceforge.net)
//
//////////////////////////////////////////////////////////////////////


#include "common.h"
#include "error.h"
#include "game.h"
#include "gfile.h"
#include "position.h"
#include "pgnparse.h"
#include "naglatex.h"
#include "nagtext.h"

#include "bytebuf.h"
#include "textbuf.h"
#include "stored.h"

// Include header for math
#include <math.h>

// Include header file for memcpy():
#ifdef WIN32
#  include <memory.h>
#else
#  include <string.h>
#endif

// Piece letters translation
// (not all languages have piece translation)

int language = 0; // default to english
//  0 = en,
//  1 = fr, 2 = es, 3 = de,
//  4 = it, 5 = ne, 6 = cz
//  7 = hu, 8 = no, 9 = sw, 10 = gk
//  format is P?K?Q?R?B?N?  (Pawn King Queen Rook Bishop kNight)
//  where ? is replaced by an ascii char in the new language
//  see 'case INFO_LANGUAGE' in tkscid.cpp

const char * langPieces[] = { "",
"PPKRQDRTBFNC", "PPKRQDRTBANC", "PBKKQDRTBLNS",
"PPKRQDRTBANC", "PpKKQDRTBLNP", "PPKKQDRVBSNJ",
"PGKKQVRBBFNH", "PBKKQDRTBLNS", "PBKKQDRTBLNS", "PSKPQBR[BANI" };

// Translate pieces (moves) from english to another language

void transPieces(char *s) {

  if (language == 0) return;
  char * ptr = s;
  int i;

  while (*ptr) {
    if (*ptr >= 'A' && *ptr <= 'Z') {
      for (i=0; i<12; i+=2) {
        if (*ptr == langPieces[language][i]) {
          *ptr = langPieces[language][i+1];
          break;
        }
      }
    }
    ptr++;
  }
}

char transPiecesChar(char c) {
  char ret = c;
  if (language == 0) return c;
  for (int i=0; i<12; i+=2) {
    if (c == langPieces[language][i]) {
      ret = langPieces[language][i+1];
      break;
      }
    }
  return ret;
}
// ============ PG : destructor that frees all memory ===============
    Game::~Game() {
#ifdef WINCE
     if (!LowMem) {
        while (MoveChunk->next != NULL) {
            moveChunkT * tempChunk = MoveChunk->next;
            my_Tcl_Free((char *)MoveChunk);
            MoveChunk = tempChunk;
          }
          my_Tcl_Free((char*)MoveChunk);
     } else {
        while (MoveChunkLowMem->next != NULL) {
          moveChunkLowMemT * tempChunk = MoveChunkLowMem->next;
          my_Tcl_Free((char *)MoveChunkLowMem);
          MoveChunkLowMem = tempChunk;
        }
        my_Tcl_Free((char*)MoveChunkLowMem);
     }
#else
    while (MoveChunk->next != NULL) {
        moveChunkT * tempChunk = MoveChunk->next;
        delete MoveChunk;
        MoveChunk = tempChunk;
      }
    delete MoveChunk;
#endif

#ifdef WINCE
        if (WhiteStr) { my_Tcl_Free( WhiteStr); }
        if (BlackStr) { my_Tcl_Free( BlackStr); }
        if (EventStr) { my_Tcl_Free( EventStr); }
        if (SiteStr)  { my_Tcl_Free( SiteStr);  }
        if (RoundStr) { my_Tcl_Free( RoundStr); }
#else
        if (WhiteStr) { delete[] WhiteStr; }
        if (BlackStr) { delete[] BlackStr; }
        if (EventStr) { delete[] EventStr; }
        if (SiteStr)  { delete[] SiteStr;  }
        if (RoundStr) { delete[] RoundStr; }
#endif
        // Delete the comment string allocator object:
        delete StrAlloc;
#ifdef WINCE
        if (!LowMem) delete CurrentPos;
#else
        // Delete the Current position:
        delete CurrentPos;
#endif
        // Delete the saved position:
        if (SavedPos) { delete SavedPos; }
        // Delete the start position:
        if (StartPos) { delete StartPos; }
    }

// =================================================
// PG : returns the variation number of current move
// returns 0 if in main line
uint Game::GetVarNumber() {
		moveT *     move;
		moveT *			parent;
		uint varNumber = 0;
		ASSERT(CurrentMove != NULL && CurrentMove->prev != NULL);
		move = CurrentMove;
    if (VarDepth == 0) { // not in a variation!
        return 0;
    }

    while (move->prev->marker != START_MARKER) {
        move = move->prev;
    }
	  move = move->prev;
    // Now CurrentMove == the start marker.
    ASSERT (move != NULL);
    ASSERT (move->varParent != NULL);
    parent = move->varParent;

    while (parent->varChild != move) {
    	ASSERT (parent->varChild != NULL);
    	parent = parent->varChild;
    	ASSERT (parent->marker == START_MARKER);
    	varNumber++;
    }
    return varNumber;
}
// ===================================================

const char * ratingTypeNames [17] = {
    "Elo", "Rating", "Rapid", "ICCF", "USCF", "DWZ", "ECF",
    // Reserved for future use:
    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    // End of array marker:
    NULL
};

uint
strGetRatingType (const char * name) {
    uint i = 0;
    while (ratingTypeNames[i] != NULL) {
        if (strEqual (name, ratingTypeNames[i])) { return i; }
        i++;
    }
    return 0;
}

typedef Game * GamePtr;


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// printNag(): converts a numeric NAG to its string equivalent.
//    The parameter <str> should point to a string at least 10 bytes long.
// TODO
//    replace < and > in NAG codes by <lt> and <gt>
void
game_printNag (byte nag, char * str, bool asSymbol, gameFormatT format)
{
    ASSERT (str != NULL);

    if (nag == 0) {
        *str = 0;
        return;
    }

    if (asSymbol) {
       if (format == PGN_FORMAT_Latex) {
         if (nag < (sizeof evalNagsLatex / sizeof (const char *)))
           strcpy (str, evalNagsLatex[nag]);
         else
           strcpy (str , "");
       } else {
         if (nag < (sizeof evalNagsRegular / sizeof (const char *)))
	   strcpy (str, evalNagsRegular[nag]);
         else
           sprintf (str, "$%i", nag);
       }
       if (nag == NAG_Diagram) {
          if (format == PGN_FORMAT_Latex) {
              strcpy (str, evalNagsLatex[nag]);
          } else if (format == PGN_FORMAT_HTML) {
              strcpy(str, "<i>(D)</i>");
          } else {
              str[0] = 'D'; str[1] = 0;
          }
       }
       return;
    } else {
    sprintf (str, "%s$%d", format == PGN_FORMAT_Latex ? "\\" : "", nag);
    }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// game_parseNag():
//      Parses an annotation symbol into its numeric equivalent.
//      Accepts numeric format ($51) or symbols such as
//      !, ?, +=, -/+, N, etc.
//
byte
game_parseNag (const char * str)
{
    ASSERT (str != NULL);
    if (*str == '$') {
        str++;
        return (byte) strGetUnsigned(str);
    }
    if ((*str <= '9'  &&  *str >= '0')) {
        return (byte) strGetUnsigned(str);
    }

    if (*str == '!') {
        // Must be "!", "!!", "!?", or invalid:
        str++;
        if (*str == 0) { return NAG_GoodMove; }            // !      $1
        if (*str == '!') { return NAG_ExcellentMove; }     // !!     $3
        if (*str == '?') { return NAG_InterestingMove; }   // !?     $5
        return 0;
    }

    if (*str == '?') {
        // Must be "?", "??", "?!", or invalid:
        str++;
        if (*str == 0) { return NAG_PoorMove; }            // ?      $2
        if (*str == '?') { return NAG_Blunder; }           // ??     $4
        if (*str == '!') { return NAG_DubiousMove; }       // ?!     $6
        return 0;
    }

    if (*str == '+') {
        // Must be "+=", "+/=", "+/-", "+-", "+--", "+>" or invalid:
        str++;
        if (*str == '=') { return NAG_WhiteSlight; }      // +=      $14
        if (*str == '-' && str[1] == 0) {                 // +-      $18
           return NAG_WhiteDecisive; }
        if (*str == '>') { return NAG_WithAttack; }       // +>      $40
        if (*str == '/'  &&  str[1] == '-') {             // +/-     $16
           return NAG_WhiteClear; }
        if (*str == '/'  &&  str[1] == '=') {             // +/=     $14
           return NAG_WhiteSlight; }
        if (*str == '-'  &&  str[1] == '-') {             // +--     $20
           return NAG_WhiteCrushing; }
        return 0;
    }

    if (*str == '=') {
        // Must be "=" (equal), "=+", "=/+", "=/&" or invalid:
        str++;
        if (*str == 0) { return NAG_Equal; }              // =       $10
        if (*str == '+') { return NAG_BlackSlight; }      // =+      $15
        if (*str == '/'  &&  str[1] == '+') {             // =/+     $15
           return NAG_BlackSlight; }
        if (*str == '/'  &&  str[1] == '&') {             // =/&     $44
           return NAG_Compensation; }
        return 0;
    }

    if (*str == '-') {
        // Must be "-+", "-/+" or "--+", "->":
        str++;
        if (*str == '+') { return NAG_BlackDecisive; }     // -+     $19
        if (*str == '>') { return NAG_WithBlackAttack; }   // ->     $41
        if (*str == '/'  &&  str[1] == '+') {              // -/+    $17
           return NAG_BlackClear; }
        if (*str == '-'  &&  str[1] == '+') {              // --+    $21
           return NAG_BlackCrushing; }
        if (*str == '-'  &&  str[1] == 0) {                // --     $210
           return NAG_See; }
        return 0;
    }

    if (*str == '/') {
        // Must be "/\" or "/"
        str++;
        if (*str == 0)    { return NAG_Diagonal; }         // /      $150
        if (*str == '\\') { return NAG_WithIdea; }         // Tri    $140
        return 0;
    }

    if (*str == 'R') {
        // Must be "R", "RR"
        str++;
        if (*str == 0)   { return NAG_VariousMoves; }      // R      $144
        if (*str == 'R') { return NAG_Comment; }           // RR     $145
        return 0;
    }

    if (*str == 'z') {
        // Must be "zz"
        str++;
        if (*str == 'z') { return NAG_BlackZugZwang; }     // zz     $23
        return 0;
    }
    if (*str == 'Z') {
        // Must be "ZZ"
        str++;
        if (*str == 'Z') { return NAG_ZugZwang; }          // ZZ     $22
        return 0;
    }

    if (*str == 'B') {
        // Must be "BB", "Bb"
        str++;
        if (*str == 'B') { return NAG_BishopPair; }        // BB     $151
        if (*str == 'b') { return NAG_OppositeBishops; }   // Bb     $153
        return 0;
    }

    if (*str == 'o') {
        // Must be "BB", "Bb"
        str++;
        if (*str == '-'  &&  str[1] == 'o') {              // o-o    $192
           return NAG_SeparatedPawns; }
        if (*str == 'o'  &&  str[1] == 0)   {              // [+]    $193
           return NAG_UnitedPawns; }
        if (*str == '^'  &&  str[1] == 0)   {              // o^     $212
           return NAG_PassedPawn; }
        return 0;
    }

    if (*str == '(') {
        // Must be (_)
        str++;
        if (*str == '_'  &&  str[1] == ')') {             // (_)     $142
           return NAG_BetterIs; }
        return 0;
    }

    if (*str == '[') {
        // Must be (_)
        str++;
        if (*str == ']'  &&  str[1] == 0) {                // []     $8
           return NAG_OnlyMove; }
        if (*str == '+'  &&  str[1] == ']') {              // [+]    $48
           return NAG_SlightCentre; }
        if (*str   == '+' &&
            str[1] == '+' && str[2] == ']') {              // [++]   $50
           return NAG_Centre; }
        return 0;
    }

    if (*str == '_') {
        // must be _|_ or _|
        str++;
        if (*str == '|'  &&  str[1] == '_') {              // _|_    $148
           return NAG_Ending; }
        if (*str == '|'  &&  str[1] == 0) {                // _|     $215
           return NAG_Without; }
        return 0;
    }

    if (*str == '|') {
        // must be ||, |_
        str++;
        if (*str == '|' ) { return NAG_Etc; }             // ||      $190
        if (*str == '_') { return NAG_With; }             // |_      $214
        return 0;
    }

    if (*str == '>') {
        // must be >, >>, >>>
        str++;
        if (*str == 0) { return NAG_SlightKingSide; }     // >       $54
        if (*str == '>'  &&  str[1] == 0) {               // >>      $56
           return NAG_ModerateKingSide; }
        if (*str == '>'  &&  str[1] == '>') {             // >>>     $58
           return NAG_KingSide; }
        return 0;
    }

    if (*str == '<') {
        // must be <, <<, <<<, <=>
        str++;
        if (*str == 0) { return NAG_SlightQueenSide; }   // <        $60
        if (*str == '<'  &&  str[1] == 0) {              // <<       $62
           return NAG_ModerateQueenSide; }
        if (*str   == '<'  &&                            // <<<      $64
            str[1] == '<' && str[2] == 0) { return NAG_QueenSide; }
        if (*str == '='  &&                              // <=>      $149
            str[1] == '>' && str[2] == 0) { return NAG_File; }
        if (*str == '+' &&                               // <+>      $130
            str[1] == '>' && str[2] == 0) { return NAG_SlightCounterPlay; }
        if (*str == '-' &&                               // <->      $131
              str[1] == '>' && str[2] == 0) { return NAG_BlackSlightCounterPlay; }
        if (*str == '+' &&                               // <++>     $132
              str[1] == '+' && str[2] == '>' && str[3] == 0) { return NAG_CounterPlay; }
        if (*str == '-' &&                               // <-->     $133
              str[1] == '-' && str[2] == '>' && str[3] == 0) { return NAG_BlackCounterPlay; }
        if (*str == '+' &&                               // <+++>    $134
              str[1] == '+' && str[2] == '+' && str[3] == '>') { return NAG_DecisiveCounterPlay; }
        if (*str   == '-' &&                             // <--->    $135
            str[1] == '-' && str[2] == '-' && str[3] == '>') { return NAG_BlackDecisiveCounterPlay; }
        return 0;
    }

    if (*str == '~' && *(str+1) == '=') {                // ~=       $44
       // alternative Compensation symbol:
        return NAG_Compensation;
    }

    if (*str == '~') {                                   // ~        $13
       // Unclear symbol:
        return NAG_Unclear;
    }

    if (*str == 'x') {                                   // x        $147
        return NAG_WeakPoint;
    }

    if (str[0] == 'N'  &&  str[1] == 0) {                // N        $146
       // Novelty symbol:
        return NAG_Novelty;
    }

    if (str[0] == 'D'  &&  str[1] == 0) {                // D        $201
       // Diagram symbol:
        return NAG_Diagram;
    }
    return 0;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Game::SaveState():
//      Save the current game state (location), so that after an
//      operation that alters the location (e.g. stepping through
//      all moves printing them) is done, the current move can be
//      set back to its original location.
//
void
Game::SaveState ()
{
    if (!SavedPos) { SavedPos = new Position; }
    SavedPos->CopyFrom (CurrentPos);
    SavedMove = CurrentMove;
    SavedPlyCount = CurrentPlyCount;
    SavedVarDepth = VarDepth;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Game::RestoreState():
//      Restores the game state to what it was when SaveState()
//      was called.
errorT
Game::RestoreState ()
{
    if (SavedMove) {
        ASSERT (SavedPos != NULL);
        CurrentPos->CopyFrom (SavedPos);
        CurrentMove = SavedMove;
        CurrentPlyCount = SavedPlyCount;
        VarDepth = SavedVarDepth;
        return OK;
    }
    return ERROR;
}

//////////////////////////////////////////////////////////////////////
//  PUBLIC FUNCTIONS
//////////////////////////////////////////////////////////////////////


#define MAX_MOVES 5000          // Maximum moves per game.
#define MAX_VARS_PER_MOVE 10    // Maximum variations per move.


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Move allocation:
//      moves are allocated in chunks to save memory and for faster
//      performance.
//

void
Game::AllocateMoreMoves ()
{
#ifdef WINCE
    if (!LowMem) {
      moveChunkT * newChunk = (moveChunkT *) my_Tcl_Alloc(sizeof(moveChunkT));
      newChunk->numFree = MOVE_CHUNKSIZE;
      newChunk->next = MoveChunk;
      MoveChunk = newChunk;
    } else {
      moveChunkLowMemT * newChunk = (moveChunkLowMemT *) my_Tcl_Alloc(sizeof(moveChunkLowMemT));
      newChunk->numFree = MOVE_CHUNKSIZE_LOWMEM;
      newChunk->next = MoveChunkLowMem;
      MoveChunkLowMem = newChunk;
    }
#else
    moveChunkT * newChunk = new moveChunkT;
    newChunk->numFree = MOVE_CHUNKSIZE;
    newChunk->next = MoveChunk;
    MoveChunk = newChunk;
#endif
}

inline moveT *
Game::NewMove ()
{
    if (FreeList) {
        moveT * tempMove = FreeList;
        FreeList = FreeList->next;
        return tempMove;
    }

#ifdef WINCE
    if (!LowMem) {
      if (MoveChunk == NULL  ||  MoveChunk->numFree == 0) {
        AllocateMoreMoves();
      }
      MoveChunk->numFree--;
      return &(MoveChunk->moves[MoveChunk->numFree]);
    } else {
      if (MoveChunkLowMem == NULL  ||  MoveChunkLowMem->numFree == 0) {
          AllocateMoreMoves();
      }
      MoveChunkLowMem->numFree--;
      return &(MoveChunkLowMem->moves[MoveChunkLowMem->numFree]);
    }
#else
    if (MoveChunk == NULL  ||  MoveChunk->numFree == 0) {
        AllocateMoreMoves();
    }
    MoveChunk->numFree--;
    return &(MoveChunk->moves[MoveChunk->numFree]);
#endif
}

// Freeing a move: it is added to the free list so it can be reused.

inline void
Game::FreeMove (moveT * move)
{
    move->next = FreeList;
    FreeList = move;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Game::Init(): initialise the game object
void
Game::Init()
{
    // Allocate initial chunk of moves:
#ifdef WINCE
    MoveChunkLowMem = NULL;
#endif
    MoveChunk = NULL;
    AllocateMoreMoves();
    StartPos = NULL;
#ifdef WINCE
    if (!LowMem)
      CurrentPos = new Position;
#else
    CurrentPos = new Position;
#endif
    KeepDecodedMoves = true;
    SavedPos = NULL;
    SavedMove = NULL;
    SavedPlyCount = 0;
    SavedVarDepth = VarDepth = 0;
    NextGame = NULL;
    Altered = false;

    NBase = NULL;
    WhiteStr = BlackStr = EventStr = SiteStr = RoundStr = NULL;
    Date = ZERO_DATE;
    EventDate = ZERO_DATE;
    Result = RESULT_None;
    EcoCode = 0;
    WhiteElo = BlackElo = 0;
    WhiteRatingType = BlackRatingType = RATING_Elo;
    ScidFlags[0] = 0;

    // Initialise compact String allocator for game comments:
    // Allocate space for game comments in chinks of about 8 Kb.
    StrAlloc = new StrAllocator (8000);

    NumTags = 0;
    PgnStyle = PGN_STYLE_TAGS | PGN_STYLE_VARS | PGN_STYLE_COMMENTS;
    PgnFormat = PGN_FORMAT_Plain;
    HtmlStyle = 0;
    PgnLastMovePos = PgnNextMovePos = 0;

    Clear();
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Game::ClearExtraTags(): clear any nonstandard tags.
void
Game::ClearExtraTags ()
{
    for (uint i=0; i < NumTags; i++) {
#ifdef WINCE
        my_Tcl_Free((char*)TagList[i].tag);
        my_Tcl_Free((char*)TagList[i].value);
#else
        delete[] TagList[i].tag;
        delete[] TagList[i].value;
#endif
    }
    NumTags = 0;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Game::ClearMoves(): clear all moves.
void
Game::ClearMoves ()
{
    NumHalfMoves = 0;
    CurrentPlyCount = 0;
    StartPlyCount = 0;
    VarDepth = 0;
    NonStandardStart = false;
    ToMove = WHITE;
    PromotionsFlag = false;
    UnderPromosFlag = false;
    // Delete any chunks of moves except the first:
#ifdef WINCE
    if (!LowMem) {
    while (MoveChunk->next != NULL) {
        moveChunkT * tempChunk = MoveChunk->next;
        my_Tcl_Free((char*) MoveChunk);
        MoveChunk = tempChunk;
      }
    MoveChunk->numFree = MOVE_CHUNKSIZE;
    } else {
    while (MoveChunkLowMem->next != NULL) {
        moveChunkLowMemT * tempChunk = MoveChunkLowMem->next;
        my_Tcl_Free((char*) MoveChunkLowMem);
        MoveChunkLowMem = tempChunk;
      }
    MoveChunkLowMem->numFree = MOVE_CHUNKSIZE_LOWMEM;
    }
#else
    while (MoveChunk->next != NULL) {
        moveChunkT * tempChunk = MoveChunk->next;
        delete MoveChunk;
        MoveChunk = tempChunk;
    }
    MoveChunk->numFree = MOVE_CHUNKSIZE;
#endif

    FreeList = NULL;

    // Delete any comments:
    StrAlloc->DeleteAll();

    // Initialise FirstMove: start and end of movelist markers
    FirstMove = NewMove();
    InitMove (FirstMove);
    FirstMove->marker = START_MARKER;
    FirstMove->next = NewMove();
    InitMove (FirstMove->next);
    FirstMove->next->marker = END_MARKER;
    FirstMove->next->prev = FirstMove;
    CurrentMove = FirstMove->next;
    FinalMatSig = MATSIG_StdStart;

    // Set up standard start
    CurrentPos->StdStart();
    KeepDecodedMoves = true;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Game::Clear():
//      Reset the game to its normal empty state.
//
void
Game::Clear()
{
    GameNumber = 0;
    SavedMove = NULL;
    KeepDecodedMoves = true;

    StrAlloc->DeleteAll();

    // CommentsFlag = NagsFlag = VarsFlag = 0;
    PromotionsFlag = false;
    UnderPromosFlag = false;

    ClearStandardTags();
    ClearExtraTags();
    ClearMoves();
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Game::PgnFormatFromString():
//      Converts a string to a gameFormatT, returning true on success
//      or false on error.
//      The string should be a case-insensitive unique prefix of
//      "plain" (or "pgn"), "HTML", "Latex", or "Color".
bool
Game::PgnFormatFromString (const char * str, gameFormatT * fmt)
{
    if (strIsCasePrefix (str, "Plain")) {
        *fmt = PGN_FORMAT_Plain;
    } else if (strIsCasePrefix (str, "PGN")) {
        *fmt = PGN_FORMAT_Plain;
    } else if (strIsCasePrefix (str, "HTML")) {
        *fmt = PGN_FORMAT_HTML;
    } else if (strIsCasePrefix (str, "Latex")) {
        *fmt = PGN_FORMAT_Latex;
    } else if (strIsCasePrefix (str, "Color")) {
        *fmt = PGN_FORMAT_Color;
    } else {
        return false;
    }
    return true;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Game::SetPgnFormatFromString():
//      Sets the PgnFormat from the provided string.
//      Returns true if the PgnFormat was successfully set.
bool
Game::SetPgnFormatFromString (const char * str)
{
    return PgnFormatFromString (str, &PgnFormat);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Game::SetStartPos():
//      Setup a start position.
//
void
Game::SetStartPos (Position * pos)
{
    // We should not have any moves:
    if (CurrentMove != FirstMove->next  ||
          CurrentMove->marker != END_MARKER) {
        ClearMoves();
    }
    VarDepth = 0;
    if (!StartPos) { StartPos = new Position; }
    StartPos->CopyFrom (pos);
    CurrentPos->CopyFrom (pos);
    // Now make the material signature:
    FinalMatSig = matsig_Make (StartPos->GetMaterial());
    NonStandardStart = true;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Game::SetStartFen():
//      Setup the start position from a FEN string.
//      I might remove this, so the only way to set the start position
//      is with the above method, SetStartPos().
//
errorT
Game::SetStartFen (const char * fenStr)
{
    // First try to read the position:
    Position * pos = new Position;
    errorT err = pos->ReadFromFEN (fenStr);
    if (err != OK) { delete pos; return err; }

    // We should not have any moves:
    if (CurrentMove != FirstMove->next  ||
          CurrentMove->marker != END_MARKER) {
        ClearMoves();
    }
    VarDepth = 0;
    if (StartPos) { delete StartPos; }
    StartPos = pos;
    CurrentPos->CopyFrom (StartPos);
    // Now make the material signature:
    FinalMatSig = matsig_Make (StartPos->GetMaterial());
    NonStandardStart = true;
    return OK;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Game::AddPgnTag(): Add a PGN Tag.
//
void
Game::AddPgnTag (const char * tag, const char * value)
{
    ASSERT (NumTags < MAX_TAGS);
    // First, try to replace an existing tag:
    for (uint i=0; i < NumTags; i++) {
        if (strEqual (tag, TagList[i].tag)) {
#ifdef WINCE
            my_Tcl_Free((char*) TagList[i].value);
#else
            delete[] TagList[i].value;
#endif
            TagList[i].value = strDuplicate (value);
            return;
        }
    }
    // It does not already exist, so add a new tag:
    TagList[NumTags].tag = strDuplicate (tag);
    TagList[NumTags].value = strDuplicate (value);
    if (strlen((char *) TagList[NumTags].tag) > MAX_TAG_LEN) {
        TagList[NumTags].tag[MAX_TAG_LEN] = '\0';
    }
    NumTags++;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Game::FindExtraTag():
//   Finds and returns an extra PGN tag if it
//   exists, or NULL if it does not exist.
const char *
Game::FindExtraTag (const char * tag)
{
    for (uint i=0; i < NumTags; i++) {
        if (strEqual (tag, TagList[i].tag)) { return TagList[i].value; }
    }
    return NULL;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Game::RemoveExtraTag():
//   Remove an extra PGN tag if it exists.
bool
Game::RemoveExtraTag (const char * tag)
{
    bool removed = false;
    for (uint i=0; i < NumTags; i++) {
        if (strEqual (tag, TagList[i].tag)) {
            // Found the specified tag, so delete it:
#ifdef WINCE
            my_Tcl_Free((char*) TagList[i].tag);
            my_Tcl_Free((char*) TagList[i].value);
#else
            delete[] TagList[i].tag;
            delete[] TagList[i].value;
#endif
            NumTags--;
            for (uint j = i; j < NumTags; j++) {
                TagList[j].tag = TagList[j+1].tag;
                TagList[j].value = TagList[j+1].value;
            }
            removed = true;
        }
    }
    return removed;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Game::SetMoveData():
//      Sets the move data for a move. Inline for speed.
inline void
Game::SetMoveData (moveT * m, simpleMoveT * sm)
{
    ASSERT (m != NULL && sm != NULL);

    // We only copy the fields set in AddLegalMove in position.cpp, since
    // other fields are meaningless at this stage.

    simpleMoveT * newsm = &(m->moveData);
    newsm->pieceNum = sm->pieceNum;
    newsm->movingPiece = sm->movingPiece;
    newsm->from = sm->from;
    newsm->to = sm->to;
    newsm->capturedPiece = sm->capturedPiece;
    newsm->promote = sm->promote;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Game::SetMoveComment():
//      Sets the comment for a move. A comment before the game itself
//      is stored as a comment of FirstMove.
//
void
Game::SetMoveComment (const char * comment)
{
    ASSERT (CurrentMove != NULL  &&  CurrentMove->prev != NULL);
    moveT * m = CurrentMove->prev;
    if (m->comment != NULL) { StrAlloc->Delete (m->comment); }
    if (comment == NULL) {
        m->comment = NULL;
    } else {
        m->comment = StrAlloc->Duplicate (comment);
        // CommentsFlag = 1;
    }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Game::MoveForward():
//      Move current position forward one move.
//
errorT
Game::MoveForward (void)
{
    ASSERT (CurrentMove != NULL);
    if (CurrentMove->marker == END_MARKER) {
        return ERROR_EndOfMoveList;
    }
    CurrentPos->DoSimpleMove (&(CurrentMove->moveData));
    CurrentMove = CurrentMove->next;
    CurrentPlyCount++;
    return OK;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Game::MoveBackup():
//      Backup one move.
//
errorT
Game::MoveBackup (void)
{
    ASSERT (CurrentMove  &&  CurrentMove->prev);
    if (CurrentMove->prev->marker == START_MARKER) {
        return ERROR_StartOfMoveList;
    }
    CurrentMove = CurrentMove->prev;
    CurrentPos->UndoSimpleMove (&(CurrentMove->moveData));
    CurrentPlyCount--;
    return OK;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Game::MoveToPly():
//       Move to a specified mainline ply in the game.
//
void
Game::MoveToPly (ushort hmNumber)
{
    CurrentMove = FirstMove->next;
    VarDepth = 0;
    if (NonStandardStart) {
        CurrentPos->CopyFrom (StartPos);
    } else {
        CurrentPos->StdStart();
    }
    CurrentPlyCount = 0;
    for (ushort i=0; i < hmNumber; i++) {
        if (CurrentMove->marker != END_MARKER) { MoveForward(); }
    }
    return;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Game::MoveIntoVariation():
//      Move into a subvariation. Variations are numbered from 0.
//
errorT
Game::MoveIntoVariation (uint varNumber)
{
    ASSERT(CurrentMove != NULL);
    if (CurrentMove->marker == END_MARKER) {
        return ERROR_EndOfMoveList;
    }
    if (varNumber >= CurrentMove->numVariations) {
        return ERROR_NoVariation;  // there is no such variation
    }
    // Follow the linked list to the variation:
    for (uint i=0; i <= varNumber; i++) {
        ASSERT (CurrentMove->varChild);
        CurrentMove = CurrentMove->varChild;
        ASSERT (CurrentMove->marker == START_MARKER);
    }
    CurrentMove = CurrentMove->next; // skip the START_MARKER
    VarDepth++;
    return OK;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Game::MoveExitVariation():
//      Move out of a variation, to the parent.
//
errorT
Game::MoveExitVariation (void)
{
    ASSERT (CurrentMove != NULL  &&  CurrentMove->prev != NULL);
    if (VarDepth == 0) { // not in a variation!
        return ERROR_NoVariation;
    }

    // Algorithm: go back previous moves as far as possible, then
    // go up to the parent of the variation.
    while (CurrentMove->prev->marker != START_MARKER) {
        MoveBackup();
    }
    CurrentMove = CurrentMove->prev;

    // Now CurrentMove == the start marker.
    ASSERT (CurrentMove->varParent != NULL);
    CurrentMove = CurrentMove->varParent;
    VarDepth--;
    return OK;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Game::AddMove():
//      Add a move at current position and do it.
//      The parameter 'san' can be NULL. If it is provided, it is stored
//      with the move to speed up PGN printing.
//
errorT
Game::AddMove (simpleMoveT * sm, char * san)
{
    ASSERT (CurrentMove != NULL  &&  sm != NULL);
    // We must be at the end of a game/variation to add a move:
    if (CurrentMove->marker != END_MARKER) {
        // truncate the game!
        CurrentMove->numVariations = 0;
        CurrentMove->marker = END_MARKER;
    }
    moveT * newMove = NewMove();
    InitMove (newMove);
    newMove->next = CurrentMove;
    newMove->prev = CurrentMove->prev;
    CurrentMove->prev->next = newMove;
    CurrentMove->prev = newMove;
    SetMoveData (newMove, sm);

    if (sm->promote != EMPTY  &&  VarDepth == 0) {
        // The move is a promotion in the game (not a variation) so
        // update the promotions flag:
        PromotionsFlag = true;
        if (piece_Type(sm->promote) != QUEEN) {
            UnderPromosFlag = true;
        }
    }
    if (san != NULL) { strcpy (newMove->san, san); }
    CurrentPos->DoSimpleMove (&(newMove->moveData));

    CurrentPlyCount++;
    if (VarDepth == 0) {
        NumHalfMoves = CurrentPlyCount;
        FinalMatSig = matsig_Make(CurrentPos->GetMaterial());
    }
    return OK;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Game::AddVariation():
//      Add a variation for the current move.
//      Also moves into the variation.
//
errorT
Game::AddVariation ()
{
    ASSERT (CurrentMove->prev != NULL);
    moveT * parent = CurrentMove->prev;
    if (parent->marker == START_MARKER) {
        return ERROR_StartOfMoveList;
    }
    // No longer any limit on number of variations per move:
    //if (parent->numVariations == MAX_VARS_PER_MOVE) {
    //    return ERROR_VariationLimit;
    //}

    // Add the child start marker and end marker:
    moveT * child = NewMove();
    InitMove (child);
    child->varParent = parent;
    child->marker = START_MARKER;
    child->next = NewMove();
    InitMove (child->next);
    child->next->prev = child;
    child->next->marker = END_MARKER;
    //  VarsFlag = 1;

    // Update the board representation:
    CurrentPos->UndoSimpleMove (&(parent->moveData));
    CurrentPlyCount--;
    CurrentMove = child->next;
    VarDepth++;

    // Now add to the tail of the list of children of m:
    moveT * m = parent;
    for (uint i=0; i < (uint) parent->numVariations; i++) {
        m = m->varChild;
    }
    m->varChild = child;
    parent->numVariations += 1;
    return OK;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Game::FirstVariation():
//      Promotes a variation to being the first variation of this
//      move. Variations are numbered from 0.
errorT
Game::FirstVariation (uint varNumber)
{
    if (varNumber >= CurrentMove->numVariations) {
        return ERROR_NoVariation;
    }

    if (varNumber == 0) {
        // Already the first variation! Nothing to do:
        return OK;
    }

    moveT * parent = CurrentMove;
    moveT * firstVar = CurrentMove->varChild;
    moveT * m = CurrentMove->varChild;

    // Remove the numbered variation from the linked list:
    for (uint i=0; i < varNumber; i++) {
        ASSERT (m->varParent == CurrentMove  &&  m->marker == START_MARKER);
        parent = m;
        m = m->varChild;
    }
    parent->varChild = m->varChild;

    // Now reinsert it as the first variation:
    m->varChild = firstVar;
    CurrentMove->varChild = m;

    return OK;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Game::MainVariation():
//    Like FirstVariation, but promotes the variation to the main line,
//    demoting the main line to be the first variation.
//
//    This function was implemented by Manuel Hoelss, with a few fixes
//    added by myself (Shane Hudson).
errorT
Game::MainVariation (uint varNumber)
{
    if (varNumber >= CurrentMove->numVariations) {
        return ERROR_NoVariation;
    }

    moveT * parent = CurrentMove;
    moveT * firstVar = CurrentMove->varChild;
    moveT * m = CurrentMove->varChild;

    if (varNumber > 0) {
        // Move the selected variation to the front, as in FirstVariation()

        // Remove the numbered variation from the linked list:
        for (uint i=0; i < varNumber; i++) {
            ASSERT (m->varParent == CurrentMove && m->marker == START_MARKER);
            parent = m;
            m = m->varChild;
        }
        parent->varChild = m->varChild;

        // Now reinsert it as the first variation:
        m->varChild = firstVar;
        CurrentMove->varChild = m;
    }

    // Now exchange the next move of the main line with the
    // next move of the variation:

    moveT buffer;

    buffer.moveData  = CurrentMove->moveData;
    buffer.comment   = CurrentMove->comment;
    buffer.next      = CurrentMove->next;
    buffer.nagCount  = CurrentMove->nagCount;
    memcpy (buffer.san, CurrentMove->san, sizeof buffer.san);
    memcpy (buffer.nags, CurrentMove->nags, sizeof buffer.nags);

    m = CurrentMove->varChild->next; // first move in first variation

    CurrentMove->moveData  = m->moveData;
    CurrentMove->comment   = m->comment;
    CurrentMove->next      = m->next;
    CurrentMove->nagCount  = m->nagCount;
    memcpy (CurrentMove->san, m->san, sizeof CurrentMove->san);
    memcpy (CurrentMove->nags, m->nags, sizeof CurrentMove->nags);

    m->moveData  = buffer.moveData;
    m->comment   = buffer.comment;
    m->next      = buffer.next;
    m->nagCount  = buffer.nagCount;
    memcpy (m->san, buffer.san, sizeof m->san);
    memcpy (m->nags, buffer.nags, sizeof m->nags);

    CurrentMove->next->prev = CurrentMove;
    m->next->prev = m;

    // Now, the information about the material at the end of the
    // game, pawn promotions, will be wrong if the variation was
    // promoted to an actual game move, so call MakeHomePawnList()
    // so go through the game moves and ensure it is correct.
    SaveState ();
    MakeHomePawnList (NULL);
    RestoreState ();

    return OK;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Game::DeleteVariation():
//      Deletes a variation. Variations are numbered from 0.
//      Note that for speed and simplicity, freed moves are not
//      added to the free list. This means that repeatedly adding and
//      deleting variations will waste memory until the game is cleared.
//
errorT
Game::DeleteVariation (uint varNumber)
{
    if (varNumber >= CurrentMove->numVariations) {
        return ERROR_NoVariation;
    }
    moveT * parent = CurrentMove;
    moveT * m = CurrentMove->varChild;

    // Remove the numbered variation from the linked list:
    for (uint i=0; i < varNumber; i++) {
        ASSERT (m->varParent == CurrentMove  &&  m->marker == START_MARKER);
        parent = m;
        m = m->varChild;
    }
    parent->varChild = m->varChild;
    CurrentMove->numVariations -= 1;
    return OK;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Game::DeleteVariationAndFree():
//      Deletes a variation. Variations are numbered from 0.
//      Note that for speed and simplicity, moves are
//      added to the free list.
errorT
Game::DeleteVariationAndFree (uint varNumber)
{
    if (varNumber >= CurrentMove->numVariations) {
        return ERROR_NoVariation;
    }
    moveT * parent = CurrentMove;
    moveT * m = CurrentMove->varChild;

    // Remove the numbered variation from the linked list:
    for (uint i=0; i < varNumber; i++) {
        ASSERT (m->varParent == CurrentMove  &&  m->marker == START_MARKER);
        parent = m;
        m = m->varChild;
    }
    parent->varChild = m->varChild;

    // free moves starting at m
    moveT * tmp = NULL;
    while (m->marker != END_MARKER && m != NULL) {
      tmp = m->next;
      FreeMove(m);
      m = tmp;
    }

    if (m != NULL)
      FreeMove(m);

    CurrentMove->numVariations -= 1;
    return OK;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Game::Truncate():
//      Truncate game at the current move.
//      For speed and simplicity, moves and comments are not freed.
//      So repeatedly adding moves and truncating a game will waste
//      memory until the game is cleared.
//
void
Game::Truncate (void)
{
    ASSERT (CurrentMove != NULL);
    CurrentMove->marker = END_MARKER;
    CurrentMove->varChild = NULL;
    CurrentMove->next = NULL;
    CurrentMove->numVariations = 0;
    return;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Game::TruncateAndFree():
//      Truncate game at the current move and free moves
//
// These two procs currently UNUSED - S.A.
// I added TruncateAndFreeMove to allow for recursive removal of variatinos, which were previously unhandled.

void
Game::TruncateAndFree (void)
{
    TruncateAndFreeMove (CurrentMove);
}

void
Game::TruncateAndFreeMove (moveT * thisMove)
{
    ASSERT (thisMove != NULL);

    moveT * move = thisMove->next;
    moveT * tmp = NULL;
    while (move->marker != END_MARKER && move != NULL) {

      // free variations
      moveT * var = move->varChild;
      while (var) {
	var = (move->varChild)->varChild;
	TruncateAndFreeMove (move->varChild);
      }

      tmp = move->next;
      FreeMove(move);
      move = tmp;
    }

    if (move != NULL)
      FreeMove(move);

    thisMove->marker = END_MARKER;
    thisMove->varChild = NULL;
    thisMove->next = NULL;
    thisMove->numVariations = 0;
    return;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Game::TruncateStart():
//      Truncate all moves leading to current position.
//      todo: copy comments (in WritePGN?)
void
Game::TruncateStart (void)
{
    ASSERT (CurrentMove != NULL);
    while (MoveExitVariation() == OK);  // exit variations
    if (!StartPos) { StartPos = new Position; }
    StartPos->CopyFrom (CurrentPos);
    NonStandardStart = true;
    CurrentMove->prev->marker = END_MARKER;
    FirstMove->next = CurrentMove;
    CurrentMove->prev = FirstMove;
    TextBuffer tb;
    tb.SetBufferSize (TBUF_SIZE);
    tb.SetWrapColumn (TBUF_SIZE);
    gameFormatT gfmt = PgnFormat;
    SetPgnFormat (PGN_FORMAT_Plain);
    // we need to switch off short header style or PGN parsing will not work
    uint  old_style = GetPgnStyle ();
    if (PgnStyle & PGN_STYLE_SHORT_HEADER)
      SetPgnStyle (PGN_STYLE_SHORT_HEADER, false);
    WriteToPGN (&tb);
    Init();
    PgnParser parser (tb.GetBuffer());
    parser.ParseGame (this);
    SetPgnFormat (gfmt);
    MoveToPly(0);
    if (old_style & PGN_STYLE_SHORT_HEADER)
      SetPgnStyle (PGN_STYLE_SHORT_HEADER, true);
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Game::MakeHomePawnList():
//    Is passed an array of 9 bytes and fills it with the game's
//    home pawn delta information.
//    This function also ensures that other information about the
//    game that will be stored in the index file and used to speed
//    up searches (material at end of game, etc) is up to date.

uint
Game::MakeHomePawnList (byte * pbPawnList)
{
    // Use a temporary dummy array if none was provided:
    byte tempPawnList [9];
    if (pbPawnList == NULL) {
        pbPawnList = tempPawnList;
    }

    // If nonstandard start, we do not make the list:
    if (NonStandardStart) {
        pbPawnList[0] = 0; return 0;
    }

    uint count = 0;
    uint hpOld, hpNew;
    uint halfByte = 0;
    errorT err = OK;
    byte * pbList = pbPawnList;
    hpOld = HPSIG_StdStart;    // All 16 pawns are on their home squares.

    // We zero out the list first:
    for (count = 0; count < 9; count++) {
        *pbList = 0; pbList++;
    }
    count = 0;
    pbList = pbPawnList; pbList++;

    NumHalfMoves = 0;
    PromotionsFlag = false;
    UnderPromosFlag = false;
    MoveToPly(0);

    while (err == OK) {
        hpNew = CurrentPos->GetHPSig();
        if (hpNew != hpOld) {
            byte changeValue = (byte) (log2 (hpOld - hpNew));
            if (halfByte == 0) {
                *pbList = (changeValue << 4);  halfByte = 1;
            } else {
                *pbList |= (changeValue & 15);  pbList++;  halfByte = 0;
            }
            hpOld = hpNew;
            count++;
        }
        if (CurrentMove->marker != END_MARKER) {
            if (CurrentMove->moveData.promote != EMPTY) {
                PromotionsFlag = true;
                if (piece_Type(CurrentMove->moveData.promote) != QUEEN) {
                    UnderPromosFlag = true;
                }
            }
        }
        err = MoveForward();
        if (err == OK) { NumHalfMoves++; }
    }
    FinalMatSig = matsig_Make(CurrentPos->GetMaterial());

    // First byte in pawnlist array stores the count:
    pbPawnList[0] = (byte) count;
    return count;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// calcHomePawnMask():
//      Computes the homePawn mask for a position.
//
inline int
calcHomePawnMask (pieceT pawn, pieceT * board)
{
    ASSERT (pawn == WP  ||  pawn == BP);
    register pieceT * bd = &(board[ (pawn == WP ? H2 : H7) ]);
    register int result = 0;
    if (*bd == pawn) { result |= 128; }  bd--;   // H-fyle pawn
    if (*bd == pawn) { result |=  64; }  bd--;   // G-fyle pawn
    if (*bd == pawn) { result |=  32; }  bd--;   // F-fyle pawn
    if (*bd == pawn) { result |=  16; }  bd--;   // E-fyle pawn
    if (*bd == pawn) { result |=   8; }  bd--;   // D-fyle pawn
    if (*bd == pawn) { result |=   4; }  bd--;   // C-fyle pawn
    if (*bd == pawn) { result |=   2; }  bd--;   // B-fyle pawn
    if (*bd == pawn) { result |=   1; }          // A-fyle pawn
    return result;
}

// updateHomePawnMask:
//      Clears one fyle from a home pawn mask.
//
inline uint
updateHomePawnMask (uint oldMask, fyleT f)
{
    register uint newMask = oldMask;
    newMask &= ~((uint) 1 << f);
    return newMask;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// patternsMatch():
//      Used by Game::MaterialMatch() to test patterns.
//      Returns 1 if all the patterns in the list match, 0 otherwise.
//
int
patternsMatch (Position * pos, patternT * ptn)
{
    pieceT * board = pos->GetBoard();
    while (ptn != NULL) {
        if (ptn->rankMatch == NO_RANK) {

            if (ptn->fyleMatch == NO_FYLE) { // Nothing to test!
            } else {  // Test this fyle:
                squareT sq = square_Make (ptn->fyleMatch, RANK_1);
                int found = 0;
                for (uint i=0; i < 8; i++, sq += 8) {
                    if (board[sq] == ptn->pieceMatch) { found = 1; break; }
                }
                if (found != ptn->flag) { return 0; }
            }

        } else { // rankMatch is a rank from 1 to 8:

            if (ptn->fyleMatch == NO_FYLE) { // Test the whole rank:
                int found = 0;
                squareT sq = square_Make (A_FYLE, ptn->rankMatch);
                for (uint i=0; i < 8; i++, sq++) {
                    if (board[sq] == ptn->pieceMatch) { found = 1; break; }
                }
                if (found != ptn->flag) { return 0; }
            } else {  // Just test one square:
                squareT sq = square_Make(ptn->fyleMatch, ptn->rankMatch);
                int found = 0;
                if (board[sq] == ptn->pieceMatch) { found = 1; }
                if (found != ptn->flag) { return 0; }
            }
        }

        // If we get this far, this pattern matched. Try the next one:
        ptn = ptn->next;
    }

    // If we reach here, all patterns matched:
    return 1;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Game::MaterialMatch(): Material search test.
//      The parameters min and max should each be an array of 15
//      counts, to specify the maximum and minimum number of counts
//      of each type of piece.
//
bool
Game::MaterialMatch (ByteBuffer * buf, byte * min, byte * max,
                     patternT * patterns, int minPly, int maxPly,
                     int matchLength, bool oppBishops, bool sameBishops,
                     int minDiff, int maxDiff)
{
    // If buf is NULL, the game is in memory. Otherwise, Decode only
    // the necessary moves:
    errorT err = OK;

    if (buf == NULL) {
        // This was previously unused, but now used to search the end position
        // MoveToPly(0);
    } else {
        Clear();
        err = DecodeStart (buf);
        KeepDecodedMoves = false;
    }

    ASSERT (matchLength >= 1);

    int matchesNeeded = matchLength;
    int matDiff;
    uint plyCount = 0;
    while (err == OK) {
        bool foundMatch = false;
        byte wMinor, bMinor;

        // If current pos has LESS than the minimum of pawns, this
        // game can never match so return false;
        if (CurrentPos->PieceCount(WP) < min[WP]) { return false; }
        if (CurrentPos->PieceCount(BP) < min[BP]) { return false; }

        // If not in the valid move range, go to the next move or return:
        if ((int)plyCount > maxPly) { return false; }
        if ((int)plyCount < minPly) { goto Next_Move; }

// For these comparisons, we really could only do half of them each move,
// according to which side just moved.
        // For non-pawns, the count could be increased by promotions:
        if (CurrentPos->PieceCount(WQ) < min[WQ]) { goto Check_Promotions; }
        if (CurrentPos->PieceCount(BQ) < min[BQ]) { goto Check_Promotions; }
        if (CurrentPos->PieceCount(WR) < min[WR]) { goto Check_Promotions; }
        if (CurrentPos->PieceCount(BR) < min[BR]) { goto Check_Promotions; }
        if (CurrentPos->PieceCount(WB) < min[WB]) { goto Check_Promotions; }
        if (CurrentPos->PieceCount(BB) < min[BB]) { goto Check_Promotions; }
        if (CurrentPos->PieceCount(WN) < min[WN]) { goto Check_Promotions; }
        if (CurrentPos->PieceCount(BN) < min[BN]) { goto Check_Promotions; }
        wMinor = CurrentPos->PieceCount(WB) + CurrentPos->PieceCount(WN);
        bMinor = CurrentPos->PieceCount(BB) + CurrentPos->PieceCount(BN);
        if (wMinor < min[WM]) { goto Check_Promotions; }
        if (bMinor < min[BM]) { goto Check_Promotions; }

        // Now test maximum counts:
        if (CurrentPos->PieceCount(WQ) > max[WQ]) { goto Next_Move; }
        if (CurrentPos->PieceCount(BQ) > max[BQ]) { goto Next_Move; }
        if (CurrentPos->PieceCount(WR) > max[WR]) { goto Next_Move; }
        if (CurrentPos->PieceCount(BR) > max[BR]) { goto Next_Move; }
        if (CurrentPos->PieceCount(WB) > max[WB]) { goto Next_Move; }
        if (CurrentPos->PieceCount(BB) > max[BB]) { goto Next_Move; }
        if (CurrentPos->PieceCount(WN) > max[WN]) { goto Next_Move; }
        if (CurrentPos->PieceCount(BN) > max[BN]) { goto Next_Move; }
        if (CurrentPos->PieceCount(WP) > max[WP]) { goto Next_Move; }
        if (CurrentPos->PieceCount(BP) > max[BP]) { goto Next_Move; }
        if (wMinor > max[WM]) { goto Next_Move; }
        if (bMinor > max[BM]) { goto Next_Move; }

        // If both sides have ONE bishop, we need to check if the search
        // was restricted to same-color or opposite-color bishops:
        if (CurrentPos->PieceCount(WB) == 1
                && CurrentPos->PieceCount(BB) == 1) {
            if (!oppBishops  ||  !sameBishops) { // Check the restriction:
                colorT whiteBishCol = NOCOLOR;
                colorT blackBishCol = NOCOLOR;

                // Search for the white and black bishop, to find their
                // square color:
                pieceT * bd = CurrentPos->GetBoard();
                for (squareT sq = A1; sq <= H8; sq++) {
                    if (bd[sq] == WB) {
                        whiteBishCol = BOARD_SQUARECOLOR [sq];
                    } else if (bd[sq] == BB) {
                        blackBishCol = BOARD_SQUARECOLOR [sq];
                    }
                }
                // They should be valid colors:
                ASSERT (blackBishCol != NOCOLOR  &&  whiteBishCol != NOCOLOR);

                // If the square colors do not match the restriction,
                // then this game cannot match:
                if (oppBishops  &&  blackBishCol == whiteBishCol) {
                    return false;
                }
                if (sameBishops  &&  blackBishCol != whiteBishCol) {
                    return false;
                }
            }
        }

        // Now check if the material difference is in-range:
        matDiff = (int)CurrentPos->MaterialValue(WHITE) -
                  (int)CurrentPos->MaterialValue(BLACK);
        if (matDiff < minDiff  ||  matDiff > maxDiff) { goto Next_Move; }

        // At this point, the Material matches; do the patterns match?
        if (patterns == NULL  ||  patternsMatch (CurrentPos, patterns)) {
            foundMatch = true;
            matchesNeeded--;
            if (matchesNeeded <= 0) { return true; }
        }
        // No? well, keep trying...
        goto Next_Move;

      Check_Promotions:
        // We only continue if this game has promotion moves:
        if (! PromotionsFlag) { return false; }

      Next_Move:
        if (buf == NULL) {
	    err = MoveForward();
        } else {
            err = DecodeNextMove (buf, NULL);
        }
        plyCount++;
        if (! foundMatch) { matchesNeeded = matchLength; }
    }

    // End of game reached, and no match:
    return false;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Game::ExactMatch():
//      Exact position search test.
//      If sm is not NULL, its from, to, promote etc will be filled with
//      the next move at the matching position, if there is one.
//      If neverMatch is non-NULL, the boolean it points to is set to
//      true if the game could never match even with extra moves.
//
bool
Game::ExactMatch (Position * searchPos, ByteBuffer * buf, simpleMoveT * sm,
                  gameExactMatchT searchType, bool * neverMatch)
{
    // If buf is NULL, the game is in memory. Otherwise, Decode only
    // the necessary moves:
    errorT err = OK;

    if (buf == NULL) {
        MoveToPly(0);
    } else {
        Clear ();
        err = DecodeStart (buf);
        KeepDecodedMoves = false;
    }

    uint plyCount = 0;
    //uint skip = 0;    // Just for statistics on number of moves skipped.
    uint search_whiteHPawns = 0;
    uint search_blackHPawns = 0;
    uint current_whiteHPawns, current_blackHPawns;
    bool check_pawnMaskWhite, check_pawnMaskBlack;
    bool doHomePawnChecks = false;

    uint wpawnFyle [8] = {0, 0, 0, 0, 0, 0, 0, 0};
    uint bpawnFyle [8] = {0, 0, 0, 0, 0, 0, 0, 0};;

    if (searchType == GAME_EXACT_MATCH_Fyles) {
        pieceT * board = searchPos->GetBoard();
        uint fyle = 0;
        for (squareT sq = A1; sq <= H8; sq++, board++) {
            if (*board == WP) {
                wpawnFyle[fyle]++;
            } else if (*board == BP) {
                bpawnFyle[fyle]++;
            }
            fyle = (fyle + 1) & 7;
        }
    }

    // If neverMatch is null, point it at a dummy value
    bool dummy;
    if (neverMatch == NULL) { neverMatch = &dummy; }
    *neverMatch = false;

    if (searchType == GAME_EXACT_MATCH_Exact  ||
        searchType == GAME_EXACT_MATCH_Pawns) {
        doHomePawnChecks = true;
        search_whiteHPawns = calcHomePawnMask (WP, searchPos->GetBoard());
        search_blackHPawns = calcHomePawnMask (BP, searchPos->GetBoard());
    }
    check_pawnMaskWhite = check_pawnMaskBlack = false;

    while (err == OK) {
        pieceT * currentBoard = CurrentPos->GetBoard();
        pieceT * board = searchPos->GetBoard();
        pieceT * b1 = currentBoard;
        pieceT * b2 = board;
        bool found = true;

        // If NO_SPEEDUPS is defined, a slower search is done without
        // optimisations that detect insufficient material.
#ifndef NO_SPEEDUPS
        // Insufficient material optimisation:
        if (searchPos->GetCount(WHITE) > CurrentPos->GetCount(WHITE)  ||
            searchPos->GetCount(BLACK) > CurrentPos->GetCount(BLACK)) {
            *neverMatch = true;
            return false;
        }
        // Insufficient pawns optimisation:
        if (searchPos->PieceCount(WP) > CurrentPos->PieceCount(WP)  ||
            searchPos->PieceCount(BP) > CurrentPos->PieceCount(BP)) {
            *neverMatch = true;
            return false;
        }

        // HomePawn mask optimisation:
        // If current pos doesn't have a pawn on home rank where
        // the search pos has one, it can never match.
        // This happens when (current_xxHPawns & search_xxHPawns) is
        // not equal to search_xxHPawns.
        // We do not do this optimisation for a pawn files search,
        // because the exact pawn squares are not important there.

        if (searchType != GAME_EXACT_MATCH_Fyles) {
            if (check_pawnMaskWhite) {
                current_whiteHPawns = calcHomePawnMask (WP, currentBoard);
                if ((current_whiteHPawns & search_whiteHPawns)
                        != search_whiteHPawns) {
                    *neverMatch = true;
                    return false;
                }
            }
            if (check_pawnMaskBlack) {
                current_blackHPawns = calcHomePawnMask (BP, currentBoard);
                if ((current_blackHPawns & search_blackHPawns)
                        != search_blackHPawns) {
                    *neverMatch = true;
                    return false;
                }
            }
        }
#endif  // #ifndef NO_SPEEDUPS

        // Not correct color: skip to next move
        if (searchPos->GetToMove() != CurrentPos->GetToMove()) {
            //skip++;
            goto Move_Forward;
        }

        // Extra material: skip to next move
        if (searchPos->GetCount(WHITE) < CurrentPos->GetCount(WHITE)  ||
            searchPos->GetCount(BLACK) < CurrentPos->GetCount(BLACK)) {
            //skip++;
            goto Move_Forward;
        }
        // Extra pawns/pieces: skip to next move
        if (searchPos->PieceCount(WP) != CurrentPos->PieceCount(WP)  ||
            searchPos->PieceCount(BP) != CurrentPos->PieceCount(BP)  ||
            searchPos->PieceCount(WN) != CurrentPos->PieceCount(WN)  ||
            searchPos->PieceCount(BN) != CurrentPos->PieceCount(BN)  ||
            searchPos->PieceCount(WB) != CurrentPos->PieceCount(WB)  ||
            searchPos->PieceCount(BB) != CurrentPos->PieceCount(BB)  ||
            searchPos->PieceCount(WR) != CurrentPos->PieceCount(WR)  ||
            searchPos->PieceCount(BR) != CurrentPos->PieceCount(BR)  ||
            searchPos->PieceCount(WQ) != CurrentPos->PieceCount(WQ)  ||
            searchPos->PieceCount(BQ) != CurrentPos->PieceCount(BQ)) {
            //skip++;
            goto Move_Forward;
        }

        // NOW, compare the actual boards piece-by-piece.
        if (searchType == GAME_EXACT_MATCH_Exact) {
            if (searchPos->HashValue() == CurrentPos->HashValue()) {
                for (squareT sq = A1;  sq <= H8;  sq++, b1++, b2++) {
                    if (*b1 != *b2) { found = false; break; }
                }
            } else {
                found = false;
            }
        } else if (searchType == GAME_EXACT_MATCH_Pawns) {
            if (searchPos->PawnHashValue() == CurrentPos->PawnHashValue()) {
                for (squareT sq = A1;  sq <= H8;  sq++, b1++, b2++) {
                    if (*b1 != *b2  &&  (*b1 == WP  ||  *b1 == BP)) {
                        found = false;
                        break;
                    }
                }
            } else {
                found = false;
            }
        } else if (searchType == GAME_EXACT_MATCH_Fyles) {
            for (fyleT f = A_FYLE; f <= H_FYLE; f++) {
                if (searchPos->FyleCount(WP,f) != CurrentPos->FyleCount(WP,f)
                      || searchPos->FyleCount(BP,f) != CurrentPos->FyleCount(BP,f)) {
                    found = false;
                    break;
                }
            }
        } else {
            // searchType == GAME_EXACT_Match_Material, so do nothing.
        }

        if (found) {
            // Found a match! Set the returned next-move:
            if (sm) {  // We need to decode the next move.
                if (buf == NULL) {
                    MoveForward();
                    if (CurrentMove->marker == END_MARKER) {
                        // Position matched at last move in the game.
                        sm->from = sm->to = NULL_SQUARE;
                        sm->promote = EMPTY;
                    } else {
                        *sm = CurrentMove->prev->moveData;
                        MoveBackup();
                    }
                } else {
                    err = DecodeNextMove (buf, sm);
                    if (err != OK) {
                        // Position matched at last move in the game.
                        sm->from = sm->to = NULL_SQUARE;
                        sm->promote = EMPTY;
                    } else {
                        // Backup to the matching position:
                        CurrentPos->UndoSimpleMove (sm);
                        CurrentPlyCount--;
                    }
                }
            }
            return true;
        }

    Move_Forward:
#ifndef NO_SPEEDUPS
        if (doHomePawnChecks) {
            check_pawnMaskWhite = false;
            check_pawnMaskBlack = false;
            rankT rTo = square_Rank (CurrentMove->moveData.to);
            rankT rFrom = square_Rank (CurrentMove->moveData.from);
            // We only re-check the home pawn masks when something moves
            // to or from the 2nd/7th rank:
            if (rTo == RANK_2  ||  rFrom == RANK_2) {
                check_pawnMaskWhite = true;
            }
            if (rTo == RANK_7  ||  rFrom == RANK_7) {
                check_pawnMaskBlack = true;
            }
        }
#endif
        if (buf == NULL) {
	    err = MoveForward();
        } else {
            err = DecodeNextMove (buf, NULL);
            if (err != OK  &&  err != ERROR_EndOfMoveList) {
                return false;
            }
        }
        plyCount++;
    }
    return false;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Game::VarExactMatch():
//    Like ExactMatch(), but also searches in variations.
//    This is much slower than ExactMatch(), since it will
//    search every position until a match is found.
bool
Game::VarExactMatch (Position * searchPos, gameExactMatchT searchType)
{
    uint wpawnFyle [8] = {0, 0, 0, 0, 0, 0, 0, 0};
    uint bpawnFyle [8] = {0, 0, 0, 0, 0, 0, 0, 0};;

    if (searchType == GAME_EXACT_MATCH_Fyles) {
        pieceT * board = searchPos->GetBoard();
        uint fyle = 0;
        for (squareT sq = A1; sq <= H8; sq++, board++) {
            if (*board == WP) {
                wpawnFyle[fyle]++;
            } else if (*board == BP) {
                bpawnFyle[fyle]++;
            }
            fyle = (fyle + 1) & 7;
        }
    }

    errorT err = OK;
    while (err == OK) {
        // Check if this position matches:
        bool match = false;
        if (searchPos->GetToMove() == CurrentPos->GetToMove()
            &&  searchPos->GetCount(WHITE) == CurrentPos->GetCount(WHITE)
            &&  searchPos->GetCount(BLACK) == CurrentPos->GetCount(BLACK)
            &&  searchPos->PieceCount(WP) == CurrentPos->PieceCount(WP)
            &&  searchPos->PieceCount(BP) == CurrentPos->PieceCount(BP)
            &&  searchPos->PieceCount(WN) == CurrentPos->PieceCount(WN)
            &&  searchPos->PieceCount(BN) == CurrentPos->PieceCount(BN)
            &&  searchPos->PieceCount(WB) == CurrentPos->PieceCount(WB)
            &&  searchPos->PieceCount(BB) == CurrentPos->PieceCount(BB)
            &&  searchPos->PieceCount(WR) == CurrentPos->PieceCount(WR)
            &&  searchPos->PieceCount(BR) == CurrentPos->PieceCount(BR)
            &&  searchPos->PieceCount(WQ) == CurrentPos->PieceCount(WQ)
            &&  searchPos->PieceCount(BQ) == CurrentPos->PieceCount(BQ)) {
            match = true;
            pieceT * b1 = CurrentPos->GetBoard();
            pieceT * b2 = searchPos->GetBoard();
            if (searchType == GAME_EXACT_MATCH_Pawns) {
                for (squareT sq = A1;  sq <= H8;  sq++, b1++, b2++) {
                    if (*b1 != *b2  &&  (*b1 == WP  ||  *b1 == BP)) {
                        match = false; break;
                    }
                }
            } else if (searchType == GAME_EXACT_MATCH_Fyles) {
                uint wpf[8] = { 0, 0, 0, 0, 0, 0, 0, 0 };
                uint bpf[8] = { 0, 0, 0, 0, 0, 0, 0, 0 };
                uint fyle = 0;
                for (squareT sq = A1;  sq <= H8;  sq++, b1++) {
                    if (*b1 == WP) {
                        wpf[fyle]++;
                        if (wpf[fyle] > wpawnFyle[fyle]) { match = false; break; }
                    } else if (*b1 == BP) {
                        bpf[fyle]++;
                        if (bpf[fyle] > bpawnFyle[fyle]) { match = false; break; }
                    }
                    fyle = (fyle + 1) & 7;
                }
            } else if (searchType == GAME_EXACT_MATCH_Exact) {
                if (searchPos->HashValue() == CurrentPos->HashValue()) {
                    for (squareT sq = A1;  sq <= H8;  sq++, b1++, b2++) {
                        if (*b1 != *b2) { match = false; break; }
                    }
                } else {
                    match = false;
                }
            } else {
                // searchType == GAME_EXACT_MATCH_Material, so do nothing.
            }
        }
        if (match) { return true; }

        // Now try searching each variation in turn:
        for (uint i=0; i < CurrentMove->numVariations; i++) {
            MoveIntoVariation (i);
            match = VarExactMatch (searchPos, searchType);
            MoveExitVariation();
            if (match) { return true; }
        }
        // Continue down this variation:
	err = MoveForward();
    }
    return false;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Game::GetPartialMoveList():
//      Write the first few moves of a game.
//
errorT
Game::GetPartialMoveList (DString * outStr, uint plyCount)
{
    // First, copy the relevant data so we can leave the game state
    // unaltered:

    SaveState ();

    MoveToPly(0);
    char temp [80];
    for (uint i=0; i < plyCount; i++) {
        if (CurrentMove->marker == END_MARKER) {
            break;
        }
        if (i != 0) { outStr->Append (" "); }
        if (i == 0  ||  CurrentPos->GetToMove() == WHITE) {
            sprintf (temp, "%d%s", CurrentPos->GetFullMoveCount(),
                     (CurrentPos->GetToMove() == WHITE ? "." : "..."));
            outStr->Append (temp);
        }
        moveT * m = CurrentMove;
        if (m->san[0] == 0) {
            CurrentPos->MakeSANString(&(m->moveData),
                                      m->san, SAN_CHECKTEST);
        }
        outStr->Append (m->san);
        MoveForward();
    }

    // Now reconstruct the original game state:
    RestoreState();
    return OK;
}


// Search a game for matching move(s)
// (based on Game::GetPartialMoveList)

bool
Game::MoveMatch (int m_argc, char **m_argv, uint plyCount, bool wToMove, bool bToMove, int checkTest)
{
    MoveToPly(0);
    for (uint i=0; i < plyCount; i++) {
        moveT * m;
        int j;

        // todo: Assert end of game exists
        if (CurrentMove->marker == END_MARKER) {
	    return false;
        }

	if (CurrentPos->GetToMove() == WHITE) {
            if (!wToMove) goto skipmove;
        } else {
            if (!bToMove) goto skipmove;
        }

        m = CurrentMove;
        j = 1;

        if (m->san[0] == 0) {
            CurrentPos->MakeSANString(&(m->moveData), m->san, checkTest);
        }
        if (strcmp(m->san, m_argv[0]) == 0) {
            bool found = 1;
            // Examine following moves to see all match
            while (j < m_argc) {
              if (! m->next) {
		  found = 0;
                  break;
              }
              if (j == 1) SaveState();
	      MoveForward();
	      m = CurrentMove;
	      if (m->san[0] == 0) {
		  CurrentPos->MakeSANString(&(m->moveData), m->san, checkTest);
	      }
	      if (m_argv[j][0] != '?' && strcmp(m->san, m_argv[j]) != 0) {
                  j++;
		  found = 0;
                  break;
              } else {
		  j++;
              }
            }
	    if (j > 1) RestoreState();

            if (found) {
	      return true;
           }
        }
skipmove:
        MoveForward();
    }

    return false;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Game::GetSAN():
//      Print the SAN representation of the current move to a string.
//      Prints an empty string ("") if not at a move.
void
Game::GetSAN (char * str)
{
    ASSERT (str != NULL);
    moveT * m = CurrentMove;
    if (m->marker == START_MARKER  ||  m->marker == END_MARKER) {
        str[0] = 0;
        return;
    }
    if (m->san[0] == 0) {
        CurrentPos->MakeSANString (&(m->moveData), m->san, SAN_MATETEST);
    }
    strcpy (str, m->san);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Game::GetPrevSAN():
//      Print the SAN representation of the current move to a string.
//      Prints an empty string ("") if not at a move.
void
Game::GetPrevSAN (char * str)
{
    ASSERT (str != NULL);
    moveT * m = CurrentMove->prev;
    if (m->marker == START_MARKER  ||  m->marker == END_MARKER) {
        str[0] = 0;
        return;
    }
    if (m->san[0] == 0) {
        MoveBackup();
        CurrentPos->MakeSANString (&(m->moveData), m->san, SAN_MATETEST);
        MoveForward();
    }
    strcpy (str, m->san);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Game::GetPrevMoveUCI():
//      Print the UCI representation of the current move to a string.
//      Prints an empty string ("") if not at a move.
void
Game::GetPrevMoveUCI (char * str)
{
    ASSERT (str != NULL);
    moveT * m = CurrentMove->prev;

    if (m->marker == START_MARKER  ||  m->marker == END_MARKER) {
        str[0] = 0;
        return;
    }
//     if (m->san[0] == 0) {
        MoveBackup();
        CurrentPos->MakeUCIString (&(m->moveData), str);
        MoveForward();
//     }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Game::GetNextMoveUCI():
//      Print the UCI representation of the next move to a string.
//      Prints an empty string ("") if not at a move.
void
Game::GetNextMoveUCI (char * str)
{
  ASSERT (str != NULL);
  moveT * m = CurrentMove;

  if (m->marker == START_MARKER  ||  m->marker == END_MARKER) {
    str[0] = 0;
    return;
  }
  //MoveBackup();
  CurrentPos->MakeUCIString (&(m->moveData), str);
  //MoveForward();
}

//    Called by WriteMoveList to check there is really
//    something to print given display options.
//    comment is supposed to be non null
bool
Game::CommentEmpty ( const char * comment)
{
    char * s = NULL;
    bool ret = false;

    if (comment == NULL)
      return true;

    if (comment[0] == '\0')
      return true;

    if (PgnStyle & PGN_STYLE_STRIP_MARKS) {
      s = strDuplicate (comment);
      strTrimMarkCodes (s);
      char * tmp = s;
      bool empty = true;
      while (tmp[0] != 0) {
        if (tmp[0] != ' ') {
          empty = false;
          break;
        }
        tmp++;
      }
      ret = empty;

      delete[] s;
    }

    return ret;
}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// writeComment:
//    Called by WriteMoveList to write a single comment.
void
Game::WriteComment (TextBuffer * tb, const char * preStr,
              const char * comment, const char * postStr)
{

    char * s = NULL;

    if (PgnStyle & PGN_STYLE_STRIP_MARKS) {
      s = strDuplicate (comment);
      strTrimMarkCodes (s);
    } else {
      if (PgnStyle & PGN_STYLE_STRIP_BRACES) {
	s = strDuplicate (comment);
	strConvertBraces (s);
      } else {
	s = (char *) comment;
      }
    }

    if (s[0] != '\0') {

      if (IsColorFormat()) {
	  tb->PrintString ("<c_");
	  tb->PrintInt (NumMovesPrinted);
	  tb->PrintChar ('>');
      }

      if (IsColorFormat()) {
	  // Translate "<", ">" in comments:
	  tb->AddTranslation ('<', "<lt>");
	  tb->AddTranslation ('>', "<gt>");
	  // S.A any issues ?
	  tb->NewlinesToSpaces (0);
	  tb->PrintString (s);
	  tb->ClearTranslation ('<');
	  tb->ClearTranslation ('>');
      } else {
	  tb->PrintString (preStr);
	  tb->PrintString (s);
	  tb->PrintString (postStr);
      }
      if (IsColorFormat()) { tb->PrintString ("</c>"); }
    }

    if (PgnStyle & PGN_STYLE_STRIP_MARKS)
        delete[] s;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//      Write the moves, variations and comments in PGN notation.
//      Recursive; calls itself to write variations.

errorT
Game::WriteMoveList (TextBuffer *tb, uint plyCount,
                     moveT * oldCurrentMove, bool printMoveNum, bool inComment)
{
    char tempTrans[10];
    const char * preCommentStr = "{";
    const char * postCommentStr = "}";
    const char * startTable = "\n";
    const char * startColumn = "\t";
    const char * nextColumn = "\t";
    const char * endColumn = "\n";
    const char * endTable = "\n";
    const char * newline = "\n";
    bool printDiagrams = false;

    // Needed for the odd case concerning comments/nullmoves/variations
    static uint inNullMove = 0;

    if (IsHtmlFormat()) {
        preCommentStr = "{";
        postCommentStr = "}";
        startTable = "<table width=\"50%\" cellpadding=5>\n";
        startColumn = "<tr align=left>\n  <td width=\"15%\"><b>";
        nextColumn = "</b></td>\n  <td width=\"45%\" align=left><b>";
        endColumn = "</b></td>\n</tr>\n";
        endTable = "</table>\n";
        newline = "<br>\n";
        printDiagrams = true;
    }

    if (IsColorFormat()) {
        startTable = "<br>";
        newline = "<br>";
        endColumn = "<br>";
    }

    if (IsHtmlFormat()  &&  VarDepth == 0) { tb->PrintString ("<b>"); }
    if ((PgnStyle & PGN_STYLE_COLUMN)  &&  VarDepth == 0) {
        tb->PrintString (startTable);
    }

    if (IsPlainFormat()  &&  inComment) {
        preCommentStr = "";
        postCommentStr = "";
    }
    moveT * m = CurrentMove;

    // Print null moves:
    if ((isNullMove(m) && PgnStyle & PGN_STYLE_NO_NULL_MOVES) && !inComment &&
            IsPlainFormat()) {
        if (!inNullMove) inNullMove = VarDepth;
        inComment = true;
        tb->PrintString(preCommentStr);
        preCommentStr = "";
        postCommentStr = "";
    }

    // If this is a variation and it starts with a comment, print it:
    if ((VarDepth > 0 || CurrentMove->prev == FirstMove) &&
            CurrentMove->prev->comment != NULL) {
        if (PgnStyle & PGN_STYLE_COMMENTS) {
            WriteComment (tb, preCommentStr, CurrentMove->prev->comment,
                          postCommentStr);
            tb->PrintSpace();
            if (!VarDepth) {
                tb->ClearTranslation ('\n');
                tb->NewLine();
                if (IsColorFormat()) {
                    tb->NewLine();
                }
            }
        }
    }

    while (CurrentMove->marker != END_MARKER) {
        moveT *m = CurrentMove;
        bool commentLine = false;

        // If the move being printed is the game's "current move" then
        // set the current PGN position accordingly:

        if (m == oldCurrentMove) {
            PgnNextMovePos = NumMovesPrinted;
        }

        // Stop the output if a specified stopLocation was given and has
        // been reached:
        if (StopLocation > 0  &&  NumMovesPrinted >= StopLocation) {
            return OK;
        }

        if (m->san[0] == 0) {
            CurrentPos->MakeSANString (&(m->moveData), m->san, SAN_MATETEST);
        }

        bool printThisMove = true;
        if (isNullMove(m)) {
            // Null moves are not printed in HTML:
            if (IsHtmlFormat()) {
                printThisMove = false;
                printMoveNum = true;
            }
            // If Plain PGN format, check whether to convert the
            // null move and remainder of the line to a comment:
            if ((PgnStyle & PGN_STYLE_NO_NULL_MOVES)  &&  IsPlainFormat()) {
                if (!inComment) {
                    // Enter inComment mode to convert rest of line
                    // to a comment:
                    inComment = true;
		    if (!inNullMove) inNullMove = VarDepth;
                    tb->PrintString(preCommentStr);
                    preCommentStr = "";
                    postCommentStr = "";
                }
                printThisMove = false;
                printMoveNum = true;
            }
        }
#ifdef WINCE
        int colWidth = 6;
#else
        int colWidth = 12;
#endif
        NumMovesPrinted++;

        if (printThisMove) {
	    // Print the move number and following dots if necessary:
	    if (IsColorFormat()) {
		tb->PrintString ("<m_");
		tb->PrintInt (NumMovesPrinted);
		tb->PrintChar ('>');
	    }
	    if (printMoveNum  ||  (CurrentPos->GetToMove() == WHITE)) {
		if ((PgnStyle & PGN_STYLE_COLUMN)  &&  VarDepth == 0) {
		    tb->PrintString (startColumn);
		    char temp [10];
		    sprintf (temp, "%4u.", CurrentPos->GetFullMoveCount());
		    tb->PrintString (temp);
		    if (CurrentPos->GetToMove() == BLACK) {
			tb->PauseTranslations();
			tb->PrintString (nextColumn);
			tb->PrintString ("...");
			if (IsPlainFormat()  ||  IsColorFormat()) {
			    tb->PrintString ("        ");
			}
			tb->ResumeTranslations();
		    }
		} else {
		    if (PgnStyle & PGN_STYLE_MOVENUM_SPACE) {
			tb->PrintInt(CurrentPos->GetFullMoveCount(), (CurrentPos->GetToMove() == WHITE ? "." : ". ..."));
		    } else {
			tb->PrintInt(CurrentPos->GetFullMoveCount(), (CurrentPos->GetToMove() == WHITE ? "." : "..."));
		    }

		    if (PgnStyle & PGN_STYLE_MOVENUM_SPACE) {
			    tb->PrintChar (' ');
		    }
		}
		printMoveNum = false;
	    }

	    if (m == oldCurrentMove->prev) { PgnLastMovePos = NumMovesPrinted; }
	    if (m == oldCurrentMove) { PgnNextMovePos = NumMovesPrinted; }

	    // Now print the move: only regenerate the SAN string if necessary.

	    if ((PgnStyle & PGN_STYLE_COLUMN)  &&  VarDepth == 0) {
		tb->PauseTranslations();
		tb->PrintString (nextColumn);
		tb->ResumeTranslations();
	    }
		if (IsColorFormat() && (PgnStyle & PGN_STYLE_UNICODE)) {
			char buf[100];
			char* q = buf;

			for (char const* p = m->san; *p; ++p) {
				ASSERT(q - buf < sizeof(buf) - 4);

				switch (*p) {
					case 'K':	q = strncpy(q, "\xe2\x99\x94", 3) + 3; break;
					case 'Q':	q = strncpy(q, "\xe2\x99\x95", 3) + 3; break;
					case 'R':	q = strncpy(q, "\xe2\x99\x96", 3) + 3; break;
					case 'B':	q = strncpy(q, "\xe2\x99\x97", 3) + 3; break;
					case 'N':	q = strncpy(q, "\xe2\x99\x98", 3) + 3; break;
					case 'P':	q = strncpy(q, "\xe2\x99\x99", 3) + 3; break;
					default:	*q++ = *p; break;
				}

			}
			*q = '\0';
			tb->PrintWord (buf);
		} else {
			// translate pieces
			strcpy(tempTrans, m->san);
			transPieces(tempTrans);
			//tb->PrintWord (m->san);
			tb->PrintWord (tempTrans);
	    }
		colWidth -= strLength (m->san);
		if (IsColorFormat()) {
			tb->PrintString ("</m>");
		}
        }

        bool endedColumn = false;

        // Print NAGs and comments if the style indicates:

        if (PgnStyle & PGN_STYLE_COMMENTS) {
            bool printDiagramHere = false;
            if (IsColorFormat()  &&  m->nagCount > 0) {
                tb->PrintString ("<nag>");
            }
            for (uint i = 0; i < (uint) m->nagCount; i++) {
                char temp[20];
                game_printNag (m->nags[i], temp, PgnStyle & PGN_STYLE_SYMBOLS,
                               PgnFormat);

                // Do not print a space before the Nag if it is the
                // first nag and starts with "!" or "?" -- those symbols
                // look better printed next to the move:

                if (i > 0  ||  (temp[0] != '!'  &&  temp[0] != '?')) {
                    tb->PrintSpace();
                    colWidth--;
                }
                if (printDiagrams  &&  m->nags[i] == NAG_Diagram) {
                    printDiagramHere = true;
                }
                tb->PrintWord (temp);
                colWidth -= strLength(temp);

            }
            if (IsColorFormat()  &&  m->nagCount > 0) {
                tb->PrintString ("</nag>");
            }
            tb->PrintSpace();
            colWidth--;
            if ((PgnStyle & PGN_STYLE_COLUMN)  &&  VarDepth == 0) {
                if (IsPlainFormat()  ||  IsColorFormat()) {
                    while (colWidth-- > 0) { tb->PrintSpace(); }
                }
            }

            if (printDiagramHere) {
                if ((PgnStyle & PGN_STYLE_COLUMN)  &&  VarDepth == 0) {
                    if (! endedColumn) {
                        if (CurrentPos->GetToMove() == WHITE) {
                            tb->PauseTranslations ();
                            tb->PrintString (nextColumn);
                            tb->ResumeTranslations ();
                        }
                        tb->PrintString (endColumn);
                        tb->PrintString (endTable);
                        endedColumn = true;
                    }
                }
                if (IsHtmlFormat()  &&  VarDepth == 0) {
                    tb->PrintString ("</b>");
                }
                MoveForward ();
                DString * dstr = new DString;
                if (IsHtmlFormat()) {
                    CurrentPos->DumpHtmlBoard (dstr, HtmlStyle, NULL);
                }
                MoveBackup ();
                tb->PrintString (dstr->Data());
                delete dstr;
                if (IsHtmlFormat()  &&  VarDepth == 0) {
                    tb->PrintString ("<b>");
                }
                printMoveNum = true;
            }

            if (m->comment != NULL && ! CommentEmpty(m->comment) ) {
                if (!inComment && IsPlainFormat()  &&
                    (PgnStyle & PGN_STYLE_NO_NULL_MOVES)) {
                    // If this move has no variations, but the next move
                    // is a null move, enter inComment mode:
                    if (isNullMove(m->next)  &&
                          ((!(PgnStyle & PGN_STYLE_VARS))  ||
                            (CurrentMove->next->numVariations == 0))) {
                        inComment = true;
			if (!inNullMove) inNullMove = VarDepth;
                        tb->PrintString(preCommentStr);
                        preCommentStr = "";
                        postCommentStr = "";
                    }
                }

/* Code commented to remove extra lines
                if ((PgnStyle & PGN_STYLE_COLUMN)  &&  VarDepth == 0) {
                       if (! endedColumn) {
                           if (CurrentPos->GetToMove() == WHITE) {
                               tb->PauseTranslations ();
                               tb->PrintString (nextColumn);
                               tb->ResumeTranslations ();
                           }
                           tb->PrintString (endColumn);
                           tb->PrintString (endTable);
                           endedColumn = true;
                       }
                }
*/
		if (IsHtmlFormat()  &&  VarDepth == 0) {
		    if (PgnStyle & PGN_STYLE_INDENT_COMMENTS)
			tb->PrintString ("</b><dl><dd>");
		    else
			tb->PrintString ("</b>");
		}
                if ((PgnStyle & PGN_STYLE_INDENT_COMMENTS) && VarDepth == 0) {
                    if (IsColorFormat()) {
                        tb->PrintString ("<br><ip1>");
                    } else {
		      tb->SetIndent (tb->GetIndent() + 4); tb->Indent();
                    }
                }

                WriteComment (tb, preCommentStr, m->comment, postCommentStr);

                if ((PgnStyle & PGN_STYLE_INDENT_COMMENTS) && VarDepth == 0) {
                    if (IsColorFormat()) {
                        tb->PrintString ("</ip1><br>");
                        commentLine = true;
                    } else {
                        tb->SetIndent (tb->GetIndent() - 4); tb->Indent();
                    }
                } else {
                    tb->PrintSpace();
                }
                if (printDiagrams  &&  strIsPrefix ("#", m->comment)) {
                    MoveForward ();
                    DString * dstr = new DString;
                    if (IsHtmlFormat()) {
                        CurrentPos->DumpHtmlBoard (dstr, HtmlStyle, NULL);
                    }
                    MoveBackup ();
                    tb->PrintString (dstr->Data());
                    delete dstr;
                }
                if (IsHtmlFormat() && VarDepth == 0) {
		    if (PgnStyle & PGN_STYLE_INDENT_COMMENTS)
			tb->PrintString ("</dl></b>");
		    else
			tb->PrintString ("<b>");
                }
                printMoveNum = true;
            }
        } else {
            tb->PrintSpace();
        }
        if (StopLocation > 0  &&  NumMovesPrinted >= StopLocation) {
            MoveForward();
            return OK;
        }

        // Print any variations if the style indicates:

        if ((PgnStyle & PGN_STYLE_VARS)  &&  (m->numVariations > 0)) {
            if ((PgnStyle & PGN_STYLE_COLUMN)  &&  VarDepth == 0) {
                if (! endedColumn) {
                    if (CurrentPos->GetToMove() == WHITE) {
                        tb->PauseTranslations ();
                        tb->PrintString (nextColumn);
                        tb->ResumeTranslations ();
                    }
		    // Doesn't seem wanted!! S.A (see a few lines below)
                    // tb->PrintString (endColumn);
                    tb->PrintString (endTable);
                    endedColumn = true;
                }
            }
            if (IsColorFormat()  &&  VarDepth == 0) { tb->PrintString ("<var>"); }
            // Doesn't indent first var in column mode properly
            // if including !(PgnStyle & PGN_STYLE_COLUMN) here.
            // But as-is, depth 3 vars don't indent in COLUMN mode (bug)
            if (PgnStyle & PGN_STYLE_INDENT_VARS) {
                if ( !commentLine ) {
		    if (IsColorFormat())
			  tb->PrintString ("<br>");
		    if (IsHtmlFormat())
			  tb->PrintString (newline);
                }
            }
            for (uint i=0; i < m->numVariations; i++) {
                if (PgnStyle & PGN_STYLE_INDENT_VARS) {
                    if (IsColorFormat()) {
                        switch (VarDepth) {
                            case 0: tb->PrintString ("<ip1>"); break;
                            case 1: tb->PrintString ("<ip2>"); break;
                            case 2: tb->PrintString ("<ip3>"); break;
                            case 3: tb->PrintString ("<ip4>"); break;
                        }
                    } else {
			if (IsHtmlFormat())
			    tb->PrintString ("<dl><dd>");
                        tb->SetIndent (tb->GetIndent() + 4); tb->Indent();
                    }
                }
                if (IsHtmlFormat()) {
                    if (VarDepth == 0) { tb->PrintString ("</b>"); }
                }
                if (IsColorFormat()) { tb->PrintString ("<blue>"); }

                // Note tabs in column mode don't work after this VarDepth>1 for some reason
                // this VarDepth check is redundant i think
				tb->PrintChar ('(');

                MoveIntoVariation (i);
                NumMovesPrinted++;
                tb->PrintSpace();

                // Recursively print the variation:

                WriteMoveList (tb, plyCount, oldCurrentMove, true, inComment);
                if (StopLocation > 0  &&  NumMovesPrinted >= StopLocation) {
                    return OK;
                }
                MoveExitVariation();
				tb->PrintChar (')');
                if (IsColorFormat())
                  tb->PrintString ("<blue>");
                if (IsHtmlFormat()) {
                    if (VarDepth == 0) { tb->PrintString ("<b>"); }
                }
                if (PgnStyle & PGN_STYLE_INDENT_VARS) {
                    if (IsColorFormat()) {
                        switch (VarDepth) {
                            case 0: tb->PrintString ("</ip1><br>"); break;
                            case 1: tb->PrintString ("</ip2><br>"); break;
                            case 2: tb->PrintString ("</ip3><br>"); break;
                            case 3: tb->PrintString ("</ip4><br>"); break;
                        }
                    } else {
			if (IsHtmlFormat())
			    tb->PrintString ("</dl>");
			tb->SetIndent (tb->GetIndent() - 4); tb->Indent();
                    }
                } else { tb->PrintSpace(); }
                printMoveNum = true;
            }
            if (IsColorFormat()  &&  VarDepth == 0) {
                tb->PrintString ("</var>");
            }
        }

        if ((PgnStyle & PGN_STYLE_COLUMN)  &&  VarDepth == 0) {
            if (endedColumn) { tb->PrintString(startTable); }
            if (!endedColumn  &&  CurrentPos->GetToMove() == BLACK) {
                tb->PrintString (endColumn);
                endedColumn = true;
            }
        }


        MoveForward();
        plyCount++;
        if (CurrentMove == oldCurrentMove->prev) {
            PgnLastMovePos = NumMovesPrinted;
        }
        if (CurrentMove == oldCurrentMove) {
            PgnNextMovePos = NumMovesPrinted;
        }
    }
    if (inComment) {
      if (!inNullMove || inNullMove >= VarDepth || !PGN_STYLE_NO_NULL_MOVES)
        tb->PrintString ("}");
    }
    if (inNullMove == VarDepth)
      inNullMove = 0;
    if (IsHtmlFormat()  &&  VarDepth == 0) { tb->PrintString ("</b>"); }
    if ((PgnStyle & PGN_STYLE_COLUMN)  &&  VarDepth == 0) {
        tb->PrintString(endTable);
    }
    return OK;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Game::WritePGN():
//      Write a game in PGN to a textbuffer.  If stopLocation is
//      non-zero, it indicates a byte count at which the output should
//      stop, leaving the game at that position. If it is zero, the
//      entire game is printed and the game position prior to the
//      WritePGN() call is restored.  So a nonzero stopLocation is used
//      to move to a position in the game.
//
errorT
Game::WritePGN (TextBuffer * tb, uint stopLocation)
{
    char temp [1024];
    char dateStr [20];
    const char * newline = "\n";
    tb->NewlinesToSpaces (false);
    if (IsHtmlFormat()) { newline = "<br>\n"; }
    if (IsLatexFormat()) {
		  return WritePGNtoLaTeX(tb, stopLocation);
    }
    if (IsColorFormat()) {
        newline = "<br>";
    }

    if (PgnStyle & PGN_STYLE_COLUMN) {
        PgnStyle |= PGN_STYLE_INDENT_COMMENTS;
        PgnStyle |= PGN_STYLE_INDENT_VARS;
    }

    // First: is there a pre-game comment? If so, print it:
//    if (FirstMove->comment != NULL && (PgnStyle & PGN_STYLE_COMMENTS)
//        &&  ! strIsAllWhitespace (FirstMove->comment)) {
//        tb->AddTranslation ('\n', newline);
//        char * s = FirstMove->comment;
//        if (PgnStyle & PGN_STYLE_STRIP_MARKS) {
//            s = strDuplicate (FirstMove->comment);
//            strTrimMarkCodes (s);
//        }
//        if (IsColorFormat()) {
//            sprintf (temp, "<c_%u>", NumMovesPrinted);
//            tb->PrintString (temp);
//            tb->AddTranslation ('<', "<lt>");
//            tb->AddTranslation ('>', "<gt>");
//            tb->PrintString (s);
//            tb->ClearTranslation ('<');
//            tb->ClearTranslation ('>');
//            tb->PrintLine ("</c>");
//        } else {
//            tb->PrintLine (s);
//        }
//        if (PgnStyle & PGN_STYLE_STRIP_MARKS) { delete[] s; }
//        tb->ClearTranslation ('\n');
//        tb->NewLine();
//    }

    date_DecodeToString (Date, dateStr);
    if (IsHtmlFormat()) { tb->PrintLine("<p><b>"); }

//    if (IsColorFormat()) {
//        tb->AddTranslation ('<', "<lt>");
//        tb->AddTranslation ('>', "<gt>");
//    }

    if (PgnStyle & PGN_STYLE_SHORT_HEADER) {
        // Print tags in short, 3-line format:

        if (IsHtmlFormat())
           tb->PrintString ("<center>");
        if (PgnFormat==PGN_FORMAT_Color) {tb->PrintString ("<tag>"); }
        tb->PrintString (WhiteStr);
        if (WhiteElo > 0) {
            sprintf (temp, "  (%u)", WhiteElo);
            tb->PrintString (temp);
        }
        switch (PgnFormat) {
        case PGN_FORMAT_HTML:
            tb->PrintString (" &nbsp;&nbsp; -- &nbsp;&nbsp; ");
            break;
        default:
            tb->PrintString ("   --   ");
            break;
        }
        tb->PrintString (BlackStr);
        if (BlackElo > 0) {
            sprintf (temp, "  (%u)", BlackElo);
            tb->PrintString (temp);
        }
        if (IsHtmlFormat())
           tb->PrintString ("<br>");
        tb->PrintString (newline);

        tb->PrintString (EventStr);
        if (!strEqual (RoundStr, "")  &&  !strEqual (RoundStr, "?")) {
            tb->PrintString (IsHtmlFormat() ? "&nbsp;&nbsp;(Round&nbsp;" : "  (Round ");
            tb->PrintString (RoundStr);
            tb->PrintString (")");
        }
        tb->PrintString (IsHtmlFormat() ? "&nbsp;&nbsp; " : "  ");
        if (!strEqual (SiteStr, "")  &&  !strEqual (SiteStr, "?")) {
            tb->PrintString (SiteStr);
            tb->PrintString (IsHtmlFormat() ? " &nbsp; &nbsp; " : "  ");
        }

        // Remove ".??" or ".??.??" from end of dateStr, then print it:
        if (dateStr[4] == '.'  &&  dateStr[5] == '?') { dateStr[4] = 0; }
        if (dateStr[7] == '.'  &&  dateStr[8] == '?') { dateStr[7] = 0; }
        tb->PrintString (dateStr);

        // Print ECO code:
        tb->PrintString (IsHtmlFormat() ? " &nbsp; &nbsp; " : "  ");
        tb->PrintString (RESULT_LONGSTR[Result]);
        if (EcoCode != 0) {
            tb->PrintString (IsHtmlFormat() ? " &nbsp; &nbsp; " : "  ");
            ecoStringT ecoStr;
            eco_ToExtendedString (EcoCode, ecoStr);
            tb->PrintString (ecoStr);
        }
        tb->PrintString (newline);
        if (PgnFormat==PGN_FORMAT_Color) {tb->PrintString ("</tag>"); }

        // Print FEN if non-standard start:

        if (NonStandardStart) {
	        DString dstr;
	        char fenStr [256];
	        StartPos->PrintFEN (fenStr, FEN_ALL_FIELDS);

            if (IsHtmlFormat()) {
		       dstr.Append ("<br>");
		       dstr.Append (fenStr);
               StartPos->DumpHtmlBoard (&dstr, HtmlStyle, NULL);
               tb->PrintString (dstr.Data());
            } else {
               sprintf (temp, "Position: %s%s", fenStr, newline);
               tb->PrintString (temp);
            }
        }
        if (IsHtmlFormat())
	    tb->PrintString ("</center>");
    } else {
        // Print tags in standard PGN format, one per line:
        // Note: we want no line-wrapping when printing PGN tags
        // so set it to a huge value for now:
        uint wrapColumn = tb->GetWrapColumn();
        tb->SetWrapColumn (99999);
        if (IsColorFormat()) { tb->PrintString ("<tag>"); }
        sprintf (temp, "[Event \"%s\"]%s", EventStr, newline);
        tb->PrintString (temp);
        sprintf (temp, "[Site \"%s\"]%s", SiteStr, newline);
        tb->PrintString (temp);
        sprintf (temp, "[Date \"%s\"]%s", dateStr, newline);
        tb->PrintString (temp);
        sprintf (temp, "[Round \"%s\"]%s", RoundStr, newline);
        tb->PrintString (temp);
        sprintf (temp, "[White \"%s\"]%s", WhiteStr, newline);
        tb->PrintString (temp);
        sprintf (temp, "[Black \"%s\"]%s", BlackStr, newline);
        tb->PrintString (temp);
        sprintf (temp, "[Result \"%s\"]%s", RESULT_LONGSTR[Result], newline);
        tb->PrintString (temp);

        // Print all tags, not just the standard seven, if applicable:
        if (PgnStyle & PGN_STYLE_TAGS) {
            if (WhiteElo > 0) {
                sprintf (temp, "[White%s \"%u\"]%s",
                         ratingTypeNames [WhiteRatingType], WhiteElo, newline);
                tb->PrintString (temp);
            }
            if (BlackElo > 0) {
                sprintf (temp, "[Black%s \"%u\"]%s",
                         ratingTypeNames [BlackRatingType], BlackElo, newline);
                tb->PrintString (temp);
            }
            if (EcoCode != 0) {
                ecoStringT ecoStr;
                eco_ToExtendedString (EcoCode, ecoStr);
                sprintf (temp, "[ECO \"%s\"]%s", ecoStr, newline);
                tb->PrintString (temp);
            }
            if (EventDate != ZERO_DATE) {
                char edateStr [20];
                date_DecodeToString (EventDate, edateStr);
                sprintf (temp, "[EventDate \"%s\"]%s", edateStr, newline);
                tb->PrintString (temp);
            }

            if (PgnStyle & PGN_STYLE_SCIDFLAGS  &&  *ScidFlags != 0) {
                sprintf (temp, "[ScidFlags \"%s\"]%s", ScidFlags, newline);
                tb->PrintString (temp);
            }

            // Now print other tags
            for (uint i=0; i < NumTags; i++) {
                sprintf (temp, "[%s \"%s\"]%s",
                         TagList[i].tag, TagList[i].value, newline);
                tb->PrintString (temp);
            }
        }
        // Finally, write the FEN tag if necessary:
        if (NonStandardStart) {
            char fenStr [256];
            StartPos->PrintFEN (fenStr, FEN_ALL_FIELDS);
            sprintf (temp, "[FEN \"%s\"]%s", fenStr, newline);
            tb->PrintString (temp);
        }
        if (IsColorFormat()) { tb->PrintString ("</tag>"); }
        // Now restore the linewrap column:
        tb->SetWrapColumn (wrapColumn);
    }

//    if (IsColorFormat()) {
//        tb->ClearTranslation ('<');
//        tb->ClearTranslation ('>');
//    }

    if (IsHtmlFormat()) { tb->PrintLine("</b></p>"); }
    tb->PrintString (newline);

    // Now print the move list. First, we note the current position and
    // move, so we can reconstruct the game state afterwards:
    moveT * oldCurrentMove = CurrentMove;
    if (stopLocation == 0) { SaveState(); }
    MoveToPly(0);
    PgnLastMovePos = PgnNextMovePos = 1;

    if (IsHtmlFormat()) { tb->PrintString ("<p>"); }
    NumMovesPrinted = 1;
    StopLocation = stopLocation;
    WriteMoveList (tb, StartPlyCount, oldCurrentMove, true, false);
    if (IsHtmlFormat()) { tb->PrintString ("<b>"); }
    if (IsColorFormat()) { tb->PrintString ("<tag>"); }
    tb->PrintWord (RESULT_LONGSTR [Result]);
    if (IsHtmlFormat()) { tb->PrintString ("</b><hr></p>"); }
    if (IsColorFormat()) { tb->PrintString ("</tag>"); }
    tb->NewLine();

    // Now reset the current position and move:
    if (stopLocation == 0) { RestoreState(); }
    return OK;
}

// Draw Latex Score Graph

errorT
Game::WritePGNGraphToLatex(TextBuffer * tb)
{
	char temp [255];

  	MoveToPly(0);
	PgnLastMovePos = PgnNextMovePos = 1;
	moveT * m = CurrentMove;

	double scores[NumHalfMoves];
	char events[NumHalfMoves];
	for (int i = 0; i < NumHalfMoves; i++) {
		scores[i] = 0;
		events[i] = ' ';
	}

	double maxScore = 0;
	double minScore = 0;
	int numScoresFound = 0;
	int minScoresRequired = 3;
	bool scoresFound = false;

	int x = 0;
	// Handle gaps in scores using average curve or lastscore
	// to fill the missing score
	double lastScore = HUGE_VAL;
	while (m->marker != END_MARKER) {
	    if (m->comment != NULL) {
		if (strIsScore(m->comment)) {
				numScoresFound++;
		    double possibleScore = strGetScore(m->comment);
		    if (possibleScore == 0.0) {
			if (lastScore==HUGE_VAL) {
			    // since this is the first score it is okay and more probable to stay 0.0
			    // latter it might make more sense to check if starting move is white
			    // and starting move = first move and match most engine analysis by giving
			    // white a slight punch of say 0.1 instead.
			} else {
			    // More probably here since this not the first score in the game
			    // That it is really a missing score so set to lastScore if the delta
			    // is > 0.1 an improvement can be made here of doing a lookahead at the
			    // next score and if it is in range average them difference instead
			    // however this will more reflect the actuals from the computer
			    // We could instead plot a smooth curve through the data as a seperate line
			    possibleScore = (fabs(lastScore-possibleScore) > 0.1) ? lastScore : possibleScore;
			}
		    } else {
			if (possibleScore == HUGE_VAL || possibleScore == -HUGE_VAL) {
			    // Score is out of range
			    if (lastScore != HUGE_VAL) {
				// Not the first score so correct via Last Score
				possibleScore = lastScore;
			    } else {
				// Very first score is out of wack so normalize it
				possibleScore = 0.0;
			    }
			}
		    }
		    scores[x] = possibleScore;
		    lastScore = possibleScore;
		    // get maxes later because of new compressions on y scales
		    // maxScore = (scores[x] > maxScore) ? scores[x] : maxScore;
		    // minScore = (scores[x] < minScore) ? scores[x] : minScore;
		}
		if (strstr(m->comment, "BLUNDER") != NULL) {
			events[x] = 'B';
		}
	    }
	    MoveForward();
	    m = CurrentMove;
	    x++;
	}

    // Need a minimum # of scores before a chart will make sense
    if (numScoresFound >= minScoresRequired) {
       scoresFound = true;
    }

    // As it is a whole move graph lets continue the score on a half move
    int scoreHalfMoves = x;
    if (scoreHalfMoves % 2) {
    	scores[scoreHalfMoves] = lastScore;
	scoreHalfMoves++;
    }

    // Most analysis scores are roughly in centipawns where 1.0 = Pawn, 3.0 = Minor piece
    // But analysis includes much more than material differences and scores can very
    // greatly for example when an enigne starts see most paths leading to decisive
    // winning positions it isn't uncommond for an analysis score to swing into the hundreds
    // This adds a challenge when graphing to allow the details to be seen in lower
    // scales while allowing details to also be seen in higher scales.
    //
    // New multi teir y scaling
    // 0 - 3 Natural Y scale
    // 3 - 10 Compressed Y scale covering 3 - 20
    // 10 - 15 Compressed Y scale covering 20 - 50
    // New cap on Y scall of 50
    // Compress secondary and tertiary Y scales and cap Y scale
    for (int i=0; i<scoreHalfMoves; i++) {
	double y = scores[i];
	double ynew = fabs(y);  // absolute
	double sign = (y > 0) ? 1 : ((y < 0) ? -1 : 0);
	if (ynew>3 && ynew<=20) {
	   double oldrange = 20-3;
	   double newrange = 10-3;
	   ynew = ((ynew-3) * newrange / oldrange) + 3;
	} else {
	  if (ynew>20 && ynew<=50) {
	     double oldrange = 50-20;
	     double newrange = 15-10;
	     ynew = ((ynew-20) * newrange / oldrange) + 10;
	  }
	}
	if (ynew > 50) ynew = 15;
	ynew = ynew * sign;
	maxScore = (ynew > maxScore) ? ynew : maxScore;
	minScore = (ynew < minScore) ? ynew : minScore;
	scores[i] = ynew;
     }

	// Getting maxX from the number of half moves is a little awkward
	// int maxX = ((NumHalfMoves / 10) + 1) * 5;
	int xTick = 5;
	int lastX = (scoreHalfMoves / 2) + 1; // Number of Moves to Cover
	int maxX = ((lastX + xTick - 1) / xTick) * xTick;
	bool finalTick = false;
	/*
	if (maxX - lastX > 2) {
	   finalTick = true;
	}
	*/

	int maxY = 5;
	int minY = -5;
	int minX = 1;

	double yscale=0.014;

	if (maxScore > 10) {
	   maxY = 15;
	   yscale+=0.008;
	} else {
	   if (maxScore > 3) {
	      maxY = 10;
	      yscale+=0.004;
	   }
	}

	if (minScore < -10) {
	   minY = -15;
	   yscale+=0.008;
	} else {
	   if (minScore < -3) {
	      minY = -10;
	      yscale+=0.004;
	   }
	}

	// Is the graph more landscape or portrait?
	// float latexUnitSize = maxX > (maxY - minY) ? maxX : (maxY - minY);
	float latexUnitSize = maxX > lastX ? lastX : maxX;
	// latexUnitSize is how many divisions of the text width, not an absolute measurement
	latexUnitSize = 1.0/latexUnitSize;

	if (scoresFound) {
		sprintf(temp, "\\begin{minipage}{\\textwidth}\n");
		tb->PrintString(temp);
		tb->PrintString("Analysis Scoregraph:\n{\n\\center\n");
		sprintf(temp, "\\psset{linewidth=0.7pt, yunit=%0.4f\\paperheight, xunit=%0.4f\\textwidth}\n", yscale, latexUnitSize );
		tb->PrintString(temp);
		sprintf(temp, "\\pspicture[](%d,%d)(%d,%d)\n", minX-1, minY, ((lastX > maxX) ? lastX : maxX), maxY);
		tb->PrintString(temp);
		sprintf(temp, "\\psframe*[fillstyle=solid,fillcolor=EvenGameColor,linecolor=EvenGameColor](1,-3)(%d,3)\n", lastX);
		tb->PrintString(temp);
		sprintf(temp, "\\psgrid[gridwidth=0pt,gridcolor=GridColor,griddots=1,subgriddiv=1,subgridwidth=10,gridlabels=0pt](1,0)(1,%d)(%d,-4)\n", minY, lastX);
		tb->PrintString(temp);
		sprintf(temp, "\\psgrid[gridwidth=0pt,gridcolor=GridColor,griddots=1,subgriddiv=1,subgridwidth=10,gridlabels=0pt](1,0)(1,4)(%d,%d)\n", lastX, maxY);
		tb->PrintString(temp);
		sprintf(temp, "\\psaxes[linewidth=1pt,linecolor=GridColor,tickstyle=bottom,Dy=5,labels=x,Dx=5,Ox=0](1,0)(1,%d)(%d,%d)\n", minY, lastX, maxY);
		tb->PrintString(temp);
		sprintf(temp, "\\rput(0,0){0}\\rput(0,-5){-5}\\rput(0,5){5}");
		tb->PrintString(temp);
		if (maxY > 5) {
		    sprintf(temp, "\\rput(0,10){20}");
		    tb->PrintString(temp);
		}
		if (maxY > 10) {
		    sprintf(temp, "\\rput(0,15){50}");
		    tb->PrintString(temp);
		}
		if (minY < -5) {
		    sprintf(temp, "\\rput(0,-10){-20}");
		    tb->PrintString(temp);
		}
		if (maxY < -10) {
		    sprintf(temp, "\\rput(0,-15){-50}");
		    tb->PrintString(temp);
		}
		if (finalTick) {
		    sprintf(temp, "\\rput(%d,-1.30){%d}\\psline(%d,0)(%d,-0.5)",lastX,lastX,lastX,lastX);
		    tb->PrintString(temp);
		}
		for (int x = 1; x < NumHalfMoves; x++) {
			if (events[x] != ' ') {
				if (events[x] == 'B') {
					sprintf(temp, "\n\\pscircle[linecolor=red](%d,%.2f){%0.2f}\n", x/2+1, scores[x], (scores[x] - scores[x - 1]) / 3);
					tb->PrintString(temp);
				}
			}
		}

		sprintf(temp, "\n\\psline[linewidth=1.5pt,linecolor=%s](1,0)", (scores[1] > 0) ? "WhitePiecesGraphColor" : "BlackPiecesGraphColor");
		tb->PrintString(temp);
		for (int x = 1; x < scoreHalfMoves; x++) {
			if ((scores[x - 1] >= 0) && (scores[x] < 0)) {
				tb->PrintString("\n\\psline[linewidth=1.5pt,linewidth=1pt,linecolor=BlackPiecesGraphColor]");
				sprintf(temp, "(%.1f,%.2f)", ((float)x - 1)/2+1, scores[x - 1]);
				tb->PrintString(temp);
			}
			if ((scores[x - 1] < 0) && (scores[x] >= 0)) {
				tb->PrintString("\n\\psline[linewidth=1.5pt,linewidth=1pt,linecolor=WhitePiecesGraphColor]");
				sprintf(temp, "(%.1f,%.2f)", ((float)x - 1)/2+1, scores[x - 1]);
				tb->PrintString(temp);
			}
			sprintf(temp, "(%.1f,%.2f)", (float)x/2+1, scores[x]);
			tb->PrintString(temp);
		}

		tb->PrintString("\n\\endpspicture\n\\\\[1ex]}\n");
		sprintf(temp, "\\end{minipage}\n");
		tb->PrintString(temp);
	}
	tb->PrintString("\\hrulefill\n\\\\\n");
	tb->PrintString("\\end{@twocolumnfalse}\n]\n");

	return OK;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//      Write a game in PGN to a textbuffer for LaTeX output.  If stopLocation is
//      non-zero, it indicates a byte count at which the output should
//      stop, leaving the game at that position. If it is zero, the
//      entire game is printed and the game position prior to the
//      WritePGN() call is restored.  So a nonzero stopLocation is used
//      to move to a position in the game.
//
//      There's been an extensive rewrite of the code for writing PGN
//      to LaTeX in order to capitalise on the features offered by the
//      xskak package; mostly this involves letting LaTeX do what LaTeX
//      does best (formatting) and just worrying about dumping the
//      right content into the right tags in the output file. If the
//      user wants fancier formatting, LaTeX is pretty much the gold
//      standard for that - so why reinvent the wheel?
//
errorT
Game::WritePGNtoLaTeX(TextBuffer * tb, uint stopLocation)
{
	char temp [255];
	char dateStr [20];
//	const char * newline = "\\\\\n";
	const char * preCommentStr = "";
	const char * postCommentStr = "\\\\[1ex]\n";
	const char * preVariationStr = "\\textcolor{VariationColor}{\\variation{";
	const char * postVariationStr = "}}\n\\\\[1ex]\n";
	const char * diagramStr = "\\begin{center}\n\\vspace{1ex}\n\\chessboard\n\\vspace{1ex}\n\\end{center}\n";
	const char * diagramStrStart = "\\begin{center}\n\\vspace{1ex}\n\\chessboard[";
	const char * diagramStrStop = "]\\vspace{1ex}\n\\end{center}\n";

	bool printDiagrams = true;
	bool diagramPrinted = false;
	bool inMainline = false;

	tb->NewlinesToSpaces(false);

	tb->AddTranslation('#', "\\#");
	tb->AddTranslation('%', "\\%");
	tb->AddTranslation('<', "$<$");
	tb->AddTranslation('>', "$>$");
	tb->AddTranslation('_', "\\_");
	tb->AddTranslation('&', "\\&");
	// tb->AddTranslation ('[', "$[$");
	// tb->AddTranslation (']', "$]$");
	// tb->AddTranslation ('(', "\\(");
	// tb->AddTranslation (')', "\\)");

	date_DecodeToString(Date, dateStr);
	tb->PrintString("\\twocolumn[\n\\begin{@twocolumnfalse}\n");
	tb->PrintLine("{\n\\center\n\\begin{tabularx}{0.9\\textwidth}{rllXr}\n");
	tb->PrintString("White:");
	tb->PauseTranslations();
	tb->PrintString(" & ");
	tb->ResumeTranslations();
	tb->PrintString(WhiteStr);
	tb->PauseTranslations();
	tb->PrintString(" & ");
	tb->ResumeTranslations();
	if (WhiteElo > 0) {
		sprintf(temp, "(%u)", WhiteElo);
		tb->PrintString(temp);
	}
	tb->PauseTranslations();
	tb->PrintString(" & & ");
	tb->ResumeTranslations();
	tb->PrintString(EventStr);
	if (!strEqual(RoundStr, "") && !strEqual(RoundStr, "?")) {
		tb->PrintString(" (");
		tb->PrintString(RoundStr);
		tb->PrintString(")");
	}
	tb->PrintString("\\\\\n");
	tb->PrintString("Black:");
	tb->PauseTranslations();
	tb->PrintString(" & ");
	tb->ResumeTranslations();
	tb->PrintString(BlackStr);
	tb->PauseTranslations();
	tb->PrintString(" & ");
	tb->ResumeTranslations();
	if (BlackElo > 0) {
		sprintf(temp, "(%u)", BlackElo);
		tb->PrintString(temp);
	}
	tb->PauseTranslations();
	tb->PrintString(" & & ");
	tb->ResumeTranslations();
	if (!strEqual(SiteStr, "") && !strEqual(SiteStr, "?")) {
		tb->PrintString(SiteStr);
	}
	tb->PrintString("\\\\\n");
	if (EcoCode != 0) {
		tb->PrintString("Opening ECO:");
		tb->PauseTranslations();
		tb->PrintString(" & ");
		tb->ResumeTranslations();
		ecoStringT ecoStr;
		eco_ToExtendedString(EcoCode, ecoStr);
		tb->PrintString(ecoStr);
		tb->PauseTranslations();
		tb->PrintString(" & & & ");
		tb->ResumeTranslations();
	} else {
		tb->PauseTranslations();
		tb->PrintString(" & & & & ");
		tb->ResumeTranslations();
	}
	// Remove ".??" or ".??.??" from end of dateStr, then print it:
	if (dateStr[4] == '.' && dateStr[5] == '?') {
		dateStr[4] = 0;
	}
	if (dateStr[7] == '.' && dateStr[8] == '?') {
		dateStr[7] = 0;
	}
	tb->PrintString(dateStr);
	tb->PrintString("\\\\\n");
	tb->PrintString("Result:");
	tb->PauseTranslations();
	tb->PrintString(" & ");
	tb->ResumeTranslations();
	tb->PrintString(RESULT_LONGSTR[Result]);
	tb->PrintString("\\\\\n");
	tb->PrintString("\\end{tabularx}\n\\\\[1ex]");
	tb->PrintLine("}\n\\newchessgame\n");

	// Note the current position and
	// move, so we can reconstruct the game state afterwards:
	moveT * oldCurrentMove = CurrentMove;
	if (stopLocation == 0) {
		SaveState();
	}

	WritePGNGraphToLatex(tb);

	MoveToPly(0);
	moveT * m = CurrentMove;
	moveT * v = NULL;

	// Print FEN if non-standard start:
	if (NonStandardStart) {
		char fenStr [256];
		StartPos->PrintFEN(fenStr, FEN_ALL_FIELDS);
		tb->PrintString(preCommentStr);

		// Hmm - How do we place this on a single line 
		uint wrapColumn = tb->GetWrapColumn();
		tb->SetWrapColumn (99999);
		tb->PrintString("Fen: ");
		tb->PrintString(fenStr);
		tb->PrintString(postCommentStr);
		tb->SetWrapColumn (wrapColumn);

		sprintf(temp, "moveid=%d%c,setfen=%s",StartPos->GetFullMoveCount(),(StartPos->GetToMove() == WHITE ? 'w' : 'b'),fenStr);

		tb->PrintString("\\newchessgame[");
		tb->PrintString(temp);
		tb->PrintString("]\n");
		tb->PrintString(diagramStr);
	}

	PgnLastMovePos = PgnNextMovePos = 1;	

	while (m->marker != END_MARKER) {
		diagramPrinted = false;

		if (m->san[0] == 0) {
			CurrentPos->MakeSANString(&(m->moveData), m->san, SAN_MATETEST);
		}

		// Print the move number and following dots if necessary:
		if (!inMainline) {
			tb->PrintString("\\mainline{");
			tb->PrintInt(CurrentPos->GetFullMoveCount(), (CurrentPos->GetToMove() == WHITE ? ". " : "... "));
			inMainline = true;
		} else {
			if (CurrentPos->GetToMove() == WHITE) 
				tb->PrintInt(CurrentPos->GetFullMoveCount(), "." );
		}

		strcpy(temp, m->san);
		transPieces(temp);
		tb->PrintWord(temp);

		for (uint i = 0; i < (uint)m->nagCount; i++) {
			if (printDiagrams && m->nags[i] == NAG_Diagram) {
			    if (strncmp(m->san, "O-O", 3) == 0) {
				printf ("Latex chessboard can't display castling. No diagram.\n");
				// The problem is the movefrom and moveto fields, which now both hold two squares
			    } else {

if (inMainline) {
				tb->PrintString("}\n");
}
				inMainline = false;
				if (!diagramPrinted) {
					diagramPrinted = true;
					tb->PrintString(diagramStrStart);
					tb->PrintString("lastmoveid,pgfstyle=border,color=gray,");
					tb->PrintString("markfields={\\xskakget{moveto},\\xskakget{movefrom}},");
					tb->PrintString("pgfstyle=straightmove,markmove=\\xskakget{movefrom}-\\xskakget{moveto}");
					tb->PrintString(diagramStrStop);
				}
				//square_Print(m->moveData.from, from);
				//square_Print(m->moveData.to, to);
				//if (CurrentPos->GetToMove() == WHITE) {
				//	tb->PrintString("\\psset{linecolor=WhitePiecesGraphColor}\n");
				//} else {
				//	tb->PrintString("\\psset{linecolor=BlackPiecesGraphColor}\n");
				//}
				//sprintf(temp, "\\highlight{%s,%s}\n", from, to);
				//tb->PrintString(temp);
				//sprintf(temp, "\\printarrow{%s}{%s}\n", from, to);
				//tb->PrintString(temp);
				//tb->PrintString("\\psset{linecolor=black}\n");
			    }
			} else {
				game_printNag(m->nags[i], temp, true, PGN_FORMAT_Latex);
				tb->PrintWord(temp);
			}
		}

		if (m->comment != NULL && ! CommentEmpty(m->comment) ) {
			if (inMainline) 
				tb->PrintString("}\n");
			inMainline = false;

			if (PgnStyle & PGN_STYLE_INDENT_COMMENTS)
				tb->PrintString("\n");

			WriteComment (tb , preCommentStr, m->comment, postCommentStr);

		} else if (CurrentPos->GetToMove() == WHITE) {
			tb->PrintString(" ");
		} else {
			tb->PrintString("  ");
		}


		// Rewrite Richards var processing
		// One level only - S.A.

		if (m->numVariations > 0) {

		    if (inMainline) {
			tb->PrintString("}\n");
			inMainline = false;
		    }
		    if (strncmp(m->san, "O-O", 3) == 0) {
		      printf ("Latex chessboard cant't display castling. No diagram.\n");
		      // The problem is the movefrom and moveto fields, which now both hold two squares
                    } else {
		      tb->PrintString(diagramStrStart);
		      tb->PrintString("lastmoveid,pgfstyle=border,color=gray,");
		      tb->PrintString("markfields={\\xskakget{moveto},\\xskakget{movefrom}},");
		      tb->PrintString("pgfstyle=straightmove,markmove=\\xskakget{movefrom}-\\xskakget{moveto}");

/*
		    // TODO Adding Variation markers to diagram with xskak
		    for (uint i=0; i < m->numVariations; i++) {
				MoveIntoVariation (i);

				char from[] = "    ";
				char to[] = "    ";
				square_Print(CurrentMove->moveData.from, from);
				square_Print(CurrentMove->moveData.to, to);
				tb->PrintString("\\psset{linecolor=VariationColor}\n");
				sprintf(temp, "\\highlight{%s,%s}\n", from, to);
				tb->PrintString(temp);
				sprintf(temp, "\\printarrow{%s}{%s}\n", from, to);
				tb->PrintString(temp);
				tb->PrintString("\\psset{linecolor=black}\n");

				MoveExitVariation();
		    }
*/

		      tb->PrintString(diagramStrStop);
		    }

		    for (uint i=0; i < m->numVariations; i++) {
				tb->PrintString(preVariationStr);
				MoveIntoVariation (i);

				if (piece_Color(CurrentMove->moveData.movingPiece) == BLACK) {
					tb->PrintInt(CurrentPos->GetFullMoveCount(), "... ");
				}

				while (CurrentMove->marker != END_MARKER) {
					
					int vMoveNo = CurrentPos->GetFullMoveCount();
					v = CurrentMove;


					if (piece_Color(v->moveData.movingPiece) == WHITE) {
						tb->PrintInt(vMoveNo, ". ");
					}

					if (v->san[0] == 0) {
					    CurrentPos->MakeSANString (&(v->moveData), v->san, SAN_MATETEST);
					}
					strcpy(temp, v->san);
					transPieces(temp);
					tb->PrintWord(temp);

					for (uint i = 0; i < (uint)v->nagCount; i++) {
					    game_printNag(v->nags[i], temp, true, PGN_FORMAT_Latex);
					    tb->PrintString(temp);
					}
					/*  in-var comments aren't decoded / working
					    if (v->comment != NULL && ! CommentEmpty(v->comment) ) {
						if (PgnStyle & PGN_STYLE_INDENT_COMMENTS)
							tb->PrintString("\n");

						WriteComment (tb , preCommentStr, v->comment, postCommentStr);
					    }
					*/

					if (piece_Color(v->moveData.movingPiece) == WHITE) {
						tb->PrintString(" ");
					} else {
						tb->PrintString("  ");
					}
					MoveForward();
				}
				tb->PrintString(postVariationStr);
				MoveExitVariation();
		    }
	    }

	    MoveForward();
	    m = CurrentMove;
	}

	if (inMainline) {
		tb->PrintString("}\n");
		inMainline = false;
	}

	tb->PrintString("\n{\\textbf ");
	tb->PrintWord(RESULT_LONGSTR [Result]);
	tb->PrintString("}\n \\hrule ");
	tb->NewLine();

	// Reset the current position and move:
	CurrentMove = oldCurrentMove;
	if (stopLocation == 0) {
		RestoreState();
	}
	return OK;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Game::WriteToPGN():
//      Just calls Game::WritePGN() with a zero stopLocation (to print
//      the entire game).
//
errorT
Game::WriteToPGN (TextBuffer * tb)
{
    return WritePGN (tb, 0);
}

errorT
Game::MoveToLocationInPGN (TextBuffer * tb, uint stopLocation)
{
    return WritePGN (tb, stopLocation);
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Game::CopyStandardTags():
//      Sets the standard tag values for this game, given another
//      game to copy the values from.
void
Game::CopyStandardTags (Game * fromGame)
{
    ASSERT (fromGame != NULL);
    SetEventStr (fromGame->GetEventStr());
    SetSiteStr (fromGame->GetSiteStr());
    SetWhiteStr (fromGame->GetWhiteStr());
    SetBlackStr (fromGame->GetBlackStr());
    SetRoundStr (fromGame->GetRoundStr());

    SetDate (fromGame->GetDate());
    SetEventDate (fromGame->GetEventDate());
    SetWhiteElo (fromGame->GetWhiteElo());
    SetBlackElo (fromGame->GetBlackElo());
    SetWhiteRatingType (fromGame->GetWhiteRatingType());
    SetBlackRatingType (fromGame->GetBlackRatingType());
    SetResult (fromGame->GetResult());
    SetEco (fromGame->GetEco());
    strCopy (ScidFlags, fromGame->ScidFlags);
    return;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Game::LoadStandardTags():
//      Sets the standard tag values for this game, given an
//      index file entry and a namebase that stores the
//      player/site/event/round names.
//
errorT
Game::LoadStandardTags (IndexEntry * ie, NameBase * nb)
{
    ASSERT (ie != NULL  &&  nb != NULL);
    SetEventStr (ie->GetEventName (nb));
    SetSiteStr (ie->GetSiteName (nb));
    SetWhiteStr (ie->GetWhiteName (nb));
    SetBlackStr (ie->GetBlackName (nb));
    SetRoundStr (ie->GetRoundName (nb));
    SetDate (ie->GetDate());
    SetEventDate (ie->GetEventDate());
    SetWhiteElo (ie->GetWhiteElo());
    SetBlackElo (ie->GetBlackElo());
    WhiteEstimateElo = nb->GetElo (ie->GetWhite());
    BlackEstimateElo = nb->GetElo (ie->GetBlack());
    SetWhiteRatingType (ie->GetWhiteRatingType());
    SetBlackRatingType (ie->GetBlackRatingType());
    SetResult (ie->GetResult());
    SetEco (ie->GetEcoCode());
    ie->GetFlagStr (ScidFlags, NULL);
    return OK;
}

eloT
Game::GetAverageElo ()
{
    eloT white = WhiteElo;
    eloT black = BlackElo;
    if (white == 0) { white = WhiteEstimateElo; }
    if (black == 0) { black = BlackEstimateElo; }
    return (white + black) / 2;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// setString(): used to set an event/site/white/black/round string.
//
static inline void
setString (char ** toPtr, const char * from)
{
#ifdef WINCE
    if (*toPtr) { my_Tcl_Free( *toPtr); }
#else
    if (*toPtr) { delete[] *toPtr; }
#endif
    *toPtr = strDuplicate (from);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Game::SetEventStr(), SetSiteStr(), etc:
//
void Game::SetEventStr (const char * str)  { setString ( &EventStr, str); }
void Game::SetSiteStr  (const char * str)  { setString ( &SiteStr, str); }
void Game::SetWhiteStr (const char * str)  { setString ( &WhiteStr, str); }
void Game::SetBlackStr (const char * str)  { setString ( &BlackStr, str); }
void Game::SetRoundStr (const char * str)  { setString ( &RoundStr, str); }


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Game::ClearStandardTags():
//      Clears all of the standard tags.
//
void
Game::ClearStandardTags ()
{
#ifdef WINCE
    if (WhiteStr) { my_Tcl_Free( WhiteStr); } WhiteStr = strDuplicate ("?");
    if (BlackStr) { my_Tcl_Free( BlackStr); } BlackStr = strDuplicate ("?");
    if (EventStr) { my_Tcl_Free( EventStr); } EventStr = strDuplicate ("?");
    if (SiteStr)  { my_Tcl_Free( SiteStr);  } SiteStr  = strDuplicate ("?");
    if (RoundStr) { my_Tcl_Free( RoundStr); } RoundStr = strDuplicate ("?");
#else
    if (WhiteStr) { delete[] WhiteStr; } WhiteStr = strDuplicate ("?");
    if (BlackStr) { delete[] BlackStr; } BlackStr = strDuplicate ("?");
    if (EventStr) { delete[] EventStr; } EventStr = strDuplicate ("?");
    if (SiteStr)  { delete[] SiteStr;  } SiteStr  = strDuplicate ("?");
    if (RoundStr) { delete[] RoundStr; } RoundStr = strDuplicate ("?");
#endif
    Date = ZERO_DATE;
    EventDate = ZERO_DATE;
    EcoCode = 0;
    Result = RESULT_None;
    WhiteElo = BlackElo = 0;
    WhiteEstimateElo = BlackEstimateElo = 0;
    WhiteRatingType = BlackRatingType = RATING_Elo;
    ScidFlags[0] = 0;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Game::WriteExtraTags():
//      Print the nonstandard tags in PGN notation to a file.
//
#ifdef WINCE
errorT
Game::WriteExtraTags (/*FILE **/ Tcl_Channel fp)
{
    char buf [1024];
    for (uint i=0; i < NumTags; i++) {
        sprintf (buf, "[%s \"%s\"]\n", TagList[i].tag, TagList[i].value);
        my_Tcl_Write(fp, buf, strlen(buf) );
        //fprintf (fp, "[%s \"%s\"]\n", TagList[i].tag, TagList[i].value);
    }
    return OK;
}
#else
errorT
Game::WriteExtraTags (FILE * fp)
{
    for (uint i=0; i < NumTags; i++) {
        fprintf (fp, "[%s \"%s\"]\n",
                 TagList[i].tag, TagList[i].value);
    }
    return OK;
}
#endif

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// makeMoveByte(): inline routine used for encoding most moves.
//
static inline byte
makeMoveByte (byte pieceNum, byte value)
{
    ASSERT (pieceNum <= 15  &&  value <= 15);
    return (byte)((pieceNum & 15) << 4)  |  (byte)(value & 15);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// encodeKing(): encoding of King moves.
//
static inline void
encodeKing (ByteBuffer * buf, simpleMoveT * sm)
{
    // Valid King difference-from-old-square values are:
    // -9, -8, -7, -1, 1, 7, 8, 9, and -2 and 2 for castling.
    // To convert this to a val in the range [1-10], we add 9 and
    // then look up the val[] table.
    // Coded values 1-8 are one-square moves; 9 and 10 are Castling.

    ASSERT(sm->pieceNum == 0);  // Kings MUST be piece Number zero.
    int diff = (int) sm->to - (int) sm->from;
    static const byte val[] = {
    /* -9 -8 -7 -6 -5 -4 -3 -2 -1  0  1   2  3  4  5  6  7  8  9 */
        1, 2, 3, 0, 0, 0, 0, 9, 4, 0, 5, 10, 0, 0, 0, 0, 6, 7, 8
    };

    // If target square is the from square, it is the null move, which
    // is represented as a king move to its own square and is encoded
    // as the byte value zero.
    if (sm->to == sm->from) {
        buf->PutByte (makeMoveByte (0, 0));
        return;
    }

    // Verify we have a valid King move:
    ASSERT(diff >= -9  &&  diff <= 9  &&  val[diff+9] != 0);
    buf->PutByte (makeMoveByte (0, val [diff + 9]));
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// decodeKing(): decoding of King moves.
//
static inline errorT
decodeKing (byte val, simpleMoveT * sm)
{
    static const int sqdiff[] = {
        0, -9, -8, -7, -1, 1, 7, 8, 9, -2, 2
    };

    if (val == 0) {
      sm->to = sm->from;  // Null move
        return OK;
    }

    if (val < 1  ||  val > 10) { return ERROR_Decode; }
    sm->to = sm->from + sqdiff[val];
    return OK;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// encodeKnight(): encoding Knight moves.
//
static inline void
encodeKnight (ByteBuffer * buf, simpleMoveT * sm)
{
    // Valid Knight difference-from-old-square values are:
    // -17, -15, -10, -6, 6, 10, 15, 17.
    // To convert this to a value in the range [1-8], we add 17 to
    // the difference and then look up the val[] table.

    int diff = (int) sm->to - (int) sm->from;
    static const byte val[] = {
    /* -17 -16 -15 -14 -13 -12 -11 -10 -9 -8 -7 -6 -5 -4 -3 -2 -1  0 */
        1,  0,  2,  0,  0,  0,  0,  3,  0, 0, 0, 4, 0, 0, 0, 0, 0, 0,

    /*  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 */
        0, 0, 0, 0, 0, 5, 0, 0, 0, 6, 0, 0, 0, 0, 7, 0, 8
    };

    // Verify we have a valid knight move:
    ASSERT (diff >= -17  &&  diff <= 17  &&  val[diff + 17] != 0);
    buf->PutByte (makeMoveByte (sm->pieceNum, val [diff + 17]));
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// decodeKnight(): decoding Knight moves.
//
static inline errorT
decodeKnight (byte val, simpleMoveT * sm)
{
    static const int sqdiff[] = {
        0, -17, -15, -10, -6, 6, 10, 15, 17
    };
    if (val < 1  ||  val > 8) { return ERROR_Decode; }
    sm->to = sm->from + sqdiff[val];
    return OK;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// encodeRook(): encoding rook moves.
//
static inline void
encodeRook (ByteBuffer * buf, simpleMoveT * sm)
{
    // Valid Rook moves are to same rank, OR to same fyle.
    // We encode the 8 squares on the same rank 0-8, and the 8
    // squares on the same fyle 9-15. This means that for any particular
    // rook move, two of the values in the range [0-15] will be
    // meaningless, as they will represent the from-square.

    ASSERT (sm->from <= H8  &&  sm->to <= H8);
    byte val;

    // Check if the two squares share the same rank:
    if (square_Rank(sm->from) == square_Rank(sm->to)) {
        val = square_Fyle(sm->to);
    } else {
        val = 8 + square_Rank(sm->to);
    }
    buf->PutByte (makeMoveByte (sm->pieceNum, val));
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// decodeRook(): decoding Rook moves.
//
static inline errorT
decodeRook (byte val, simpleMoveT * sm)
{
    if (val >= 8) {
        // This is a move along a Fyle, to a different rank:
        sm->to = square_Make (square_Fyle(sm->from), (val - 8));
    } else {
        sm->to = square_Make (val, square_Rank(sm->from));
    }
    return OK;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// encodeBishop(): encoding Bishop moves.
//
static inline void
encodeBishop (ByteBuffer * buf, simpleMoveT * sm)
{
    // We encode a Bishop move as the Fyle moved to, plus
    // a one-bit flag to indicate if the direction was
    // up-right/down-left or vice versa.

    ASSERT (sm->to <= H8  &&  sm->from <= H8);
    byte val;
    val = square_Fyle(sm->to);
    int rankdiff = (int)square_Rank(sm->to) - (int)square_Rank(sm->from);
    int fylediff = (int)square_Fyle(sm->to) - (int)square_Fyle(sm->from);

    // If (rankdiff * fylediff) is negative, it's up-left/down-right:
    if (rankdiff * fylediff < 0) { val += 8; }

    buf->PutByte (makeMoveByte (sm->pieceNum, val));
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// decodeBishop(): decoding Bishop moves.
//
static inline errorT
decodeBishop (byte val, simpleMoveT * sm)
{
    byte fyle = (val & 7);
    int fylediff = (int)fyle - (int)square_Fyle(sm->from);
    if (val >= 8) {
        // It is an up-left/down-right direction move.
        sm->to = sm->from - 7 * fylediff;
    } else {
        sm->to = sm->from + 9 * fylediff;
    }
    if (sm->to > H8) { return ERROR_Decode;}
    return OK;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// encodeQueen(): encoding Queen moves.
//
static inline void
encodeQueen (ByteBuffer * buf, simpleMoveT * sm)
{
    // We cannot fit all Queen moves in one byte, so Rooklike moves
    // are in one byte (encoded the same way as Rook moves),
    // while diagonal moves are in two bytes.

    ASSERT (sm->to <= H8  &&  sm->from <= H8);
    byte val;

    if (square_Rank(sm->from) == square_Rank(sm->to)) {
        // Rook-horizontal move:

        val = square_Fyle(sm->to);
        buf->PutByte (makeMoveByte (sm->pieceNum, val));

    } else if (square_Fyle(sm->from) == square_Fyle(sm->to)) {
        // Rook-vertical move:

        val = 8 + square_Rank(sm->to);
        buf->PutByte (makeMoveByte (sm->pieceNum, val));

    } else {
        // Diagonal move:
        ASSERT (dirIsDiagonal [sqDir [sm->from][sm->to]]);

        // First, we put a rook-horizontal move to the from square (which
        // is illegal of course) to indicate it is NOT a rooklike move:

        val = square_Fyle(sm->from);
        buf->PutByte (makeMoveByte (sm->pieceNum, val));

        // Now we put the to-square in the next byte. We add a 64 to it
        // to make sure that it cannot clash with the Special tokens (which
        // are in the range 0 to 15, since they are special King moves).

        buf->PutByte (sm->to + 64);
    }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// decodeQueen(): decoding Queen moves.
//
static inline errorT
decodeQueen (ByteBuffer * buf, byte val, simpleMoveT * sm)
{
    if (val >= 8) {
        // Rook-vertical move:
        sm->to = square_Make (square_Fyle(sm->from), (val - 8));

    } else if (val != square_Fyle(sm->from)) {
        // Rook-horizontal move:
        sm->to = square_Make (val, square_Rank(sm->from));

    } else {
        // Diagonal move: coded in TWO bytes.
        val = buf->GetByte();
        if (val < 64  ||  val > 127) { return ERROR_Decode; }
        sm->to = val - 64;
    }
    return OK;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// encodePawn(): encoding Pawn moves.
//
static inline void
encodePawn (ByteBuffer * buf, simpleMoveT * sm)
{
    // Pawn moves require a promotion encoding.
    // The pawn moves are:
    // 0 = capture-left,
    // 1 = forward,
    // 2 = capture-right (all no promotion);
    //    3/4/5 = 0/1/2 with Queen promo;
    //    6/7/8 = 0/1/2 with Rook promo;
    //  9/10/11 = 0/1/2 with Bishop promo;
    // 12/13/14 = 0/1/2 with Knight promo;
    // 15 = forward TWO squares.

    byte val;
    int diff = (int)(sm->to) - (int)(sm->from);

    if (diff < 0) { diff = -diff; }
    if (diff == 16) { // Move forward two squares
        val = 15;
        ASSERT (sm->promote == EMPTY);

    } else {
        if (diff == 7) { val = 0; }
        else if (diff == 8) { val = 1; }
        else {  // diff is 9:
            ASSERT (diff == 9);
            val = 2;
        }
        if (sm->promote != EMPTY) {
            // Handle promotions.
            // sm->promote must be Queen=2,Rook=3, Bishop=4 or Knight=5.
            // We add 3 for Queen, 6 for Rook, 9 for Bishop, 12 for Knight.

            ASSERT (sm->promote >= QUEEN  &&  sm->promote <= KNIGHT);
            val += 3 * ((sm->promote) - 1);
        }
    }
    buf->PutByte (makeMoveByte (sm->pieceNum, val));
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// decodePawn(): decoding Pawn moves.
//
static inline errorT
decodePawn (byte val, simpleMoveT * sm, colorT toMove)
{
    static const int
    toSquareDiff [16] = {
        7,8,9, 7,8,9, 7,8,9, 7,8,9, 7,8,9, 16
    };

    static const pieceT
    promoPieceFromVal [16] = {
        EMPTY,EMPTY,EMPTY,
        QUEEN,QUEEN,QUEEN,
        ROOK,ROOK,ROOK,
        BISHOP,BISHOP,BISHOP,
        KNIGHT,KNIGHT,KNIGHT,
        EMPTY
    };

    if (toMove == WHITE) {
        sm->to = sm->from + toSquareDiff[val];
    } else {
        sm->to = sm->from - toSquareDiff[val];
    }

    sm->promote = promoPieceFromVal[val];

    return OK;
}


// Special-move tokens:
// Since king-move values 1-10 are taken for actual King moves, only
// 11-15 (and zero) are available for non-move information.

#define ENCODE_NAG          11
#define ENCODE_COMMENT      12
#define ENCODE_START_MARKER 13
#define ENCODE_END_MARKER   14
#define ENCODE_END_GAME     15

#define ENCODE_FIRST        11
#define ENCODE_LAST         15

// The end-game and end-variation tokens could be the same single token,
// but having two different tokens allows for detecting corruption, since
// a game must end with the end-game token.


// The inline routine  isSpecialMoveCode() returns true is a byte value
// has the value of a special non-move token:
inline bool
isSpecialMoveCode (byte val)
{
    return (val <= ENCODE_LAST  &&  val >= ENCODE_FIRST);
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// decodeMove():
//      Decode a move from a bytebuffer. Assumes the byte val is an
//      actual move, not the value of a "special" (non-move) token.
//      This function needs to be passed the bytebuffer because some
//      moves (only Queen diagonal moves) are encoded in two bytes, so
//      it may be necessary to read the next byte as well.
//
static errorT
decodeMove (ByteBuffer * buf, simpleMoveT * sm, byte val, Position * pos)
{
    // First, get the moving piece:
    sm->pieceNum = (val >> 4);

    squareT * sqList = pos->GetList (pos->GetToMove());
    sm->from = sqList[sm->pieceNum];
    if (sm->from > H8) { return ERROR_Decode; }

    pieceT * board = pos->GetBoard();
    sm->movingPiece = board[sm->from];

    sm->capturedPiece = EMPTY;
    sm->promote = EMPTY;

    errorT err = OK;
    pieceT pt = piece_Type (sm->movingPiece);
    switch (pt) {
    case PAWN:
        err = decodePawn (val & 15, sm, pos->GetToMove());
        break;
    case KNIGHT:
        err = decodeKnight (val & 15, sm);
        break;
    case ROOK:
        err = decodeRook (val & 15, sm);
        break;
    case BISHOP:
        err = decodeBishop (val & 15, sm);
        break;
    case KING:
        err = decodeKing (val & 15, sm);
        break;
    // For queen moves: Rook-like moves are in 1 byte, diagonals are in 2.
    case QUEEN:
        err = decodeQueen (buf, val & 15, sm);
        break;
    default:
        err = ERROR_Decode;
    }
    return err;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Game::EncodeMove():
//  Encode one move and output it to the bytebuffer.
//
static void
encodeMove (ByteBuffer * buf, moveT * m)
{
    simpleMoveT * sm = &(m->moveData);
    pieceT pt = piece_Type(sm->movingPiece);

    typedef void encodeFnType (ByteBuffer *, simpleMoveT *);
    static encodeFnType * encodeFn[] = {
        NULL         /* 0 */,
        encodeKing   /*1=KING*/,
        encodeQueen  /*2=QUEEN*/,
        encodeRook   /*3=ROOK*/,
        encodeBishop /*4=BISHOP*/,
        encodeKnight /*5=KNIGHT*/,
        encodePawn   /*6=PAWN*/
    };
    ASSERT (pt >= KING  &&  pt <= PAWN);
    (encodeFn[pt]) (buf, sm);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// encodeVariation(): Used by Encode() to encode the game's moves.
//      Recursive; calls itself to encode subvariations.
//
static errorT
encodeVariation (ByteBuffer * buf, moveT * m, uint * subVarCount,
                 uint * nagCount, uint depth)
{
    ASSERT (m != NULL);

    // Check if there is a pre-game or start-of-variation comment:
    if (m->prev->comment != NULL) {
        buf->PutByte (ENCODE_COMMENT);
    }

    while (m->marker != END_MARKER) {
        encodeMove (buf, m);
        for (uint i=0; i < (uint) m->nagCount; i++) {
            buf->PutByte (ENCODE_NAG);
            buf->PutByte (m->nags[i]);
            *nagCount += 1;
        }
        if (m->comment != NULL) {
            buf->PutByte (ENCODE_COMMENT);
        }
        if (m->numVariations > 0) {
            moveT * subVar = m->varChild;
            for (uint i=0; i < m->numVariations; i++) {
                *subVarCount += 1;
                buf->PutByte (ENCODE_START_MARKER);
                encodeVariation (buf, subVar->next, subVarCount, nagCount, depth+1);
                subVar = subVar->varChild;
            }
        }
        m = m->next;
    }
    // At end, we output the end-variation or end-game token.
    if (depth == 0) {
        buf->PutByte (ENCODE_END_GAME);
    } else {
        buf->PutByte (ENCODE_END_MARKER);
    }
    return buf->Status();
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// defaultComment is what a move's comment is set to when a comment
// is detected. It is changed to the actual comment later when the
// comments are decoded.

char* defaultComment = (char *)"";


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Game::DecodeVariation():
//      Decodes the game moves. Recursively decodes subvariations.
//
errorT
Game::DecodeVariation (ByteBuffer * buf, byte flags, uint level)
{
    simpleMoveT sm;
    errorT err;
    byte b = buf->GetByte ();
    while (b != ENCODE_END_GAME  &&  b != ENCODE_END_MARKER) {
        switch (b) {
        case ENCODE_START_MARKER:
            err = AddVariation();
            if (err != OK) { return err; }
            err = DecodeVariation (buf, flags, level + 1);
            if (err != OK) { return err; }
            err = MoveExitVariation();
            if (err != OK) { return err; }
            err = MoveForward();
            if (err != OK) { return err; }
            break;

        case ENCODE_NAG:
            AddNag (buf->GetByte ());
            break;

        case ENCODE_COMMENT:
            if (flags & GAME_DECODE_COMMENTS) {
                // Mark this comment as needing to be read
                CurrentMove->prev->comment = defaultComment;
            }
            break;

        default:  // It is a regular move
            err = decodeMove (buf, &sm, b, CurrentPos);
            if (err != OK)  { return err; }
            AddMove (&sm, NULL);
        }

        b = buf->GetByte ();
        if (buf->Status() != OK) { return buf->Status(); }
    }

    if (level == 0  &&  b != ENCODE_END_GAME) { return ERROR_Decode; }
    if (level > 0  &&  b != ENCODE_END_MARKER) { return ERROR_Decode; }
    return buf->Status();
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Common tags are encoded in one byte, as a value over 240.
//       This means that the maximum length of a non-common tag is 240
//       bytes, and the maximum number of common tags is 15.
//
const char *
commonTags [255 - MAX_TAG_LEN] =
{
    // 241, 242: Country
    "WhiteCountry", "BlackCountry",
    // 243: Annotator
    "Annotator",
    // 244: PlyCount
    "PlyCount",
    // 245: EventDate (plain text encoding)
    "EventDate",
    // 246, 247: Opening, Variation
    "Opening", "Variation",
    // 248-250: Setup and Source
    "Setup", "Source", "SetUp",
    // 252-254: spare for future use
    NULL, NULL, NULL, NULL,
    // 255: Reserved for compact EventDate encoding
    NULL
};


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// encodeTags():
//      Encodes the non-standard tags.
//
static errorT
encodeTags (ByteBuffer * buf, tagT * tagList, uint numTags)
{
    uint length;
    for (uint i=0; i < numTags; i++) {
        char * tag = tagList[i].tag;
        uint tagnum = 1;
        const char ** common = commonTags;
        while (*common != NULL) {
            if (strEqual (tag, *common)) {
                buf->PutByte ((byte) MAX_TAG_LEN + tagnum);
                break;
            } else {
                common++;
                tagnum++;
            }
        }
        if (*common == NULL) {   // This is not a common tag.
            length = strLength (tag);
            buf->PutByte ((byte) length);
            buf->PutFixedString (tag, length);
        }

        length = strLength (tagList[i].value);
        buf->PutByte ((byte) length);
        buf->PutFixedString (tagList[i].value, length);
    }
    buf->PutByte (0);
    return buf->Status();
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Game::DecodeTags():
//      Decodes the non-standard tags of the game.
//
errorT
Game::DecodeTags (ByteBuffer * buf, bool storeTags)
{
    byte b;
    char tag [255];
    char value [255];

    b = buf->GetByte ();
    while (b != 0  &&  buf->Status() == OK) {
        if (b == 255) {
            // Special binary 3-byte encoding of EventDate:
            dateT date = 0;
            b = buf->GetByte(); date = (date << 8) | b;
            b = buf->GetByte(); date = (date << 8) | b;
            b = buf->GetByte(); date = (date << 8) | b;
            SetEventDate (date);
            //char dateStr[20];
            //date_DecodeToString (date, dateStr);
            //if (storeTags) { AddPgnTag ("EventDate", dateStr); }
        } else if (b > MAX_TAG_LEN) {
            // A common tag name, not explicitly stored:
            char * ctag = (char *) commonTags[b - MAX_TAG_LEN - 1];
            b = buf->GetByte ();
            buf->GetFixedString (value, b);
            value[b] = '\0';
            if (storeTags) { AddPgnTag (ctag, value); }
        } else {
            buf->GetFixedString (tag, b);
            tag[b] = '\0';
            b = buf->GetByte ();
            buf->GetFixedString (value, b);
            value[b] = '\0';
            if (storeTags) { AddPgnTag (tag, value); }
        }
        b = buf->GetByte();
    }
   return buf->Status();
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// skipTags():
//      Called instead of DecodeTags() to skip over the tags of the
//      game when decoding it. Called from DecodeStart() since the
//      nonstandard tags are not needed for searches.
//
static errorT
skipTags (ByteBuffer * buf)
{
    byte b;
    b = buf->GetByte ();
    while (b != 0  &&  buf->Status() == OK) {
        if (b == 255) {
            // Special 3-byte binary encoding of EventDate:
            buf->Skip (3);
        } else {
            if (b > MAX_TAG_LEN) {
                // Do nothing.
            } else {
                buf->Skip (b);
            }
            b = buf->GetByte ();
            buf->Skip (b);
        }
        b = buf->GetByte();
    }
    return buf->Status ();
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// encodeComments():
//      Encode the comments of the game. Recurses the moves of the game
//      and writes the comment whenever a move with a comment is found.
//
static errorT
encodeComments (ByteBuffer * buf, moveT * m, uint * commentCounter)
{
    ASSERT(buf != NULL  &&  m != NULL);

    while (m->marker != END_MARKER) {
        if (m->comment != 0) {
            buf->PutTerminatedString (m->comment);
            *commentCounter += 1;
        }
        if (m->numVariations) {
           moveT * subVar = m->varChild;
            for (uint i=0; i < m->numVariations; i++) {
                encodeComments (buf, subVar, commentCounter);
                subVar = subVar->varChild;
            }
        }
        m = m->next;
    }
    return buf->Status();
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// decodeComments():
//      Decodes the comments of the game. When decoding the moves, the
//      comment field of each move that has a comment is marked (made
//      non-NULL), so this function recurses the movelist and subvariations
//      and allocates each comment to its move.
//
static errorT
decodeComments (StrAllocator * strAlloc, ByteBuffer * buf, moveT * m)
{
    ASSERT (buf != NULL  &&  m != NULL);

    while (m->marker != END_MARKER) {
        if (m->comment != 0) {
            ASSERT (m->comment == defaultComment);
            char * str;
            buf->GetTerminatedString(&str);
            m->comment = strAlloc->Duplicate (str);
        }

        if (m->numVariations) {
           moveT * subVar = m->varChild;
            for (uint i=0; i < m->numVariations; i++) {
                decodeComments (strAlloc, buf, subVar);
                subVar = subVar->varChild;
            }
        }
        m = m->next;
    }
    return buf->Status();
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Game::Encode(): Encode the game to a buffer for disk storage.
//      If passed a NON-null IndexEntry pointer, it will fill in the
//      following fields of that index entry, which are computed as
//      the game is encoded:
//       -  result, ecoCode, whiteElo, blackElo
//       -  promotion flag
//       -  nMoves: the number of halfmoves
//       -  finalMatSig: the material signature of the final position.
//       -  homePawnData: the home pawn change list.
//
errorT
Game::Encode (ByteBuffer * buf, IndexEntry * ie)
{
    ASSERT (buf != NULL);
    errorT err;

    buf->Empty();
    // First, encode info not already stored in the index
    // This will be the non-STR (non-"seven tag roster") PGN tags.
    err = encodeTags (buf, TagList, NumTags);
    if (err != OK) { return err; }
    // Now the game flags:
    byte flags = 0;
    if (NonStandardStart) { flags += 1; }
    if (PromotionsFlag)   { flags += 2; }
    if (UnderPromosFlag)  { flags += 4; }
    buf->PutByte (flags);
    // Now encode the startBoard, if there is one.
    if (NonStandardStart) {
        char tempStr [256];
        StartPos->PrintFEN (tempStr, FEN_ALL_FIELDS);
        buf->PutTerminatedString (tempStr);
    }


    // Now the movelist:
    uint varCount = 0;
    uint nagCount = 0;
    err = encodeVariation (buf, FirstMove->next, &varCount, &nagCount, 0);
    if (err != OK) { return err; }

    // Now do the comments
    uint commentCount = 0;

    err = encodeComments (buf, FirstMove, &commentCount);

    // Set the fields in the IndexEntry:
    if (ie != NULL) {
        ie->SetDate (Date);
        ie->SetEventDate (EventDate);
        ie->SetResult (Result);
        ie->SetEcoCode (EcoCode);
        ie->SetWhiteElo (WhiteElo);
        ie->SetBlackElo (BlackElo);
        ie->SetWhiteRatingType (WhiteRatingType);
        ie->SetBlackRatingType (BlackRatingType);

        ie->SetStartFlag (NonStandardStart);
        ie->SetCommentCount (commentCount);
        ie->SetVariationCount (varCount);
        ie->SetNagCount (nagCount);
        ie->SetFlagStr (ScidFlags);

        // Make the home pawn change list:
        MakeHomePawnList (ie->GetHomePawnData());

        // Set other data updated by MakeHomePawnList():
        ie->SetPromotionsFlag (PromotionsFlag);
        ie->SetUnderPromoFlag (UnderPromosFlag);
        ie->SetFinalMatSig (FinalMatSig);
        ie->SetNumHalfMoves (NumHalfMoves);

        // Find the longest matching stored line for this game:
        ushort storedLineCode = 0;
        if (!NonStandardStart) {
            uint longestMatch = 0;
            uint storedLineCount = StoredLine::Count();
            for (ushort i = 1; i <= storedLineCount; i++) {
                Game * g = StoredLine::GetGame (i);
                moveT * gameMove = FirstMove->next;
                moveT * lineMove = g->FirstMove->next;
                uint matchLength = 0;
                while (lineMove->marker != END_MARKER) {
                    if (gameMove->marker == END_MARKER
                        ||  gameMove->moveData.from != lineMove->moveData.from
                        ||  gameMove->moveData.to != lineMove->moveData.to)
                    {
                        matchLength = 0; break;
                    }
                    gameMove = gameMove->next;
                    lineMove = lineMove->next;
                    matchLength++;
                }
                if (matchLength > longestMatch) {
                    longestMatch = matchLength;
                    storedLineCode = i;
                }
            }
        }
        ie->SetStoredLineCode (storedLineCode);
    }

    // as each game entry length is coded on 17 bits, and game must fit in a block
    // return an error if there is an overflow
    if (buf->GetByteCount() > MAX_GAME_LENGTH || buf->GetByteCount() > GF_BLOCKSIZE) {
      err = ERROR_GameFull;
    }

    return err;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Game::DecodeNextMove():
//      Decodes one more mainline move of the game from the bytebuffer.
//      Used in searches for speed, since it is usually possible to
//      determine if a game matches the search criteria without decoding
//      all of it.
//      If the game flag KeepDecodedMoves is true, the move decodes is
//      added normally. If it is false, only the current position is
//      updated and the list of moves is not updated -- this is done
//      in searches for speed.
//      Returns OK if a move was found, or ERROR_EndOfMoveList if all the
//      moves have been decoded. Returns ERROR_Game if some corruption was
//      detected.
//
errorT
Game::DecodeNextMove (ByteBuffer * buf, simpleMoveT * sm)
{
    ASSERT (buf != NULL);
    errorT err;
    byte b;
    while (1) {
        b = buf->GetByte ();
        if (buf->Status() != OK) { return ERROR_Game; }
        switch (b) {
        case ENCODE_NAG:
            // We ignore NAGS but have to read it from the buffer
            b = buf->GetByte();
            break;

        case ENCODE_COMMENT:  // We also ignore comments
            break;

        case ENCODE_START_MARKER:
            // Find the end of this variation and its children
            uint nestCount;
            nestCount= 1;
            while (nestCount > 0) {
                b = buf->GetByte();
                if (buf->Status() != OK) { return ERROR_Game; }
                if (b == ENCODE_NAG) { buf->GetByte(); }
                else if (b == ENCODE_START_MARKER) { nestCount++; }
                else if (b == ENCODE_END_MARKER) { nestCount--; }
                else if (b == ENCODE_END_GAME) {
                    // Open var at end of game: should never happen!
                    return ERROR_Game;
                }
            }
            break;

        case ENCODE_END_MARKER:  // End marker in main game: error!
            return ERROR_Game;

        case ENCODE_END_GAME:  // We reached the end of the game:
            return ERROR_EndOfMoveList;

        default:  // It's a move in the game; decode it:
            simpleMoveT tempMove;
            if (!sm) { sm = &tempMove; }
            err = decodeMove (buf, sm, b, CurrentPos);
            if (err != OK)  { return err; }
            if (KeepDecodedMoves) {
                AddMove (sm, NULL);
            } else {
                CurrentPos->DoSimpleMove (sm);
                CurrentPlyCount++;
            }
            return OK;
        }
    }

    // We never reach here:
    ASSERT(0);
    return ERROR_Game;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Game::DecodeStart():
//      Decodes the starting information from the game's on-disk
//      representation in the bytebuffer. After this is called,
//      DecodeNextMove() can be called to decode each successive
//      mainline move.
//
errorT
Game::DecodeStart (ByteBuffer * buf)
{
    ASSERT (buf != NULL);
    errorT err = buf->Status();
    if (err != OK) { return err; }

    // First the tags: just skip them for speed.
    //--// removed due to Gerds Hints
	 //--// NumTags = 0;
    err = skipTags (buf);
    if (err != OK) { return err; }

    // Now the flags:
    byte flags = buf->GetByte();
    if (flags & 1) { NonStandardStart = true; }
    if (flags & 2) { PromotionsFlag = true; }
    if (flags & 4) { UnderPromosFlag = true; }

    // Now decode the startBoard, if there is one.
    if (NonStandardStart) {
        char * tempStr;
        buf->GetTerminatedString (&tempStr);
        if ((err = buf->Status()) != OK) {
            NonStandardStart = 0;
            return err;
        }
        if (!StartPos) { StartPos = new Position; }
        err = StartPos->ReadFromFEN (tempStr);
        if (err != OK) {
            NonStandardStart = 0;
            return err;
        }
        CurrentPos->CopyFrom (StartPos);
    }

    return err;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Game::Decode():
//      Decodes a game from its on-disk representation in a bytebuffer.
//      Decodes all the information: comments, variations, non-standard
//      tags, etc, or selectively can ignore comments and/or tags for
//      speed if the argument "flags" indicates.
//
errorT
Game::Decode (ByteBuffer * buf, byte flags)
{
    ASSERT (buf != NULL);
    errorT err;

    Clear();

    // First the nonstandard tags: decode or skip them.
    if (flags & GAME_DECODE_TAGS) {
        err = DecodeTags (buf, true);
    } else {
        err = skipTags (buf);
    }
    if (err != OK) { return err; }

    byte gflags = buf->GetByte();
    if (gflags & 1) { NonStandardStart = true; }
    if (gflags & 2) { PromotionsFlag = true; }
    if (gflags & 4) { UnderPromosFlag = true; }

    // Now decode the startBoard, if there is one.
    if (NonStandardStart) {
        char * tempStr;
        buf->GetTerminatedString (&tempStr);
        if ((err = buf->Status()) != OK) {
            NonStandardStart = 0;
            return err;
        }
        if (!StartPos) { StartPos = new Position; }
        err = StartPos->ReadFromFEN (tempStr);
        if (err != OK) {
            NonStandardStart = 0;
            return err;
        }
        *CurrentPos = *StartPos;
    }

    err = DecodeVariation (buf, flags, 0);

    if (err != OK) { return err; }

    // Last of all, decode the comments:
    if (flags & GAME_DECODE_COMMENTS) {
        err = decodeComments (StrAlloc, buf, FirstMove);
        if (err != OK) { return err; }
    }

    return buf->Status();
}

//////////////////////////////////////////////////////////////////////
//  EOF:    game.cpp
//////////////////////////////////////////////////////////////////////
