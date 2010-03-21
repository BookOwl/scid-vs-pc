#ifndef NOTATION_H
#define NOTATION_H

#include "position.h"

char* FldToStr(FLD f, char* str);
char* MoveToStrLong(Move mv, char* str);
char* MoveToStrShort(Move mv, const MoveList& pos, char* str);
FLD   StrToFld(const char* str);
Move  StrToMove(const char* str, const Position& pos);

#endif

