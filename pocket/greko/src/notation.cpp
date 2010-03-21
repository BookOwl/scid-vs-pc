#include <ctype.h>

#include "moves.h"
#include "notation.h"

char* FldToStr(FLD f, char* str)
{
	if (f == NF)
	{
		strcpy(str, "-");
		return str;
	}

	str[0] = 'a' + Col(f);
	str[1] = '8' - Row(f);
	str[2] = 0;

	return str;
}
////////////////////////////////////////////////////////////////////////////////

char* MoveToStrLong(Move mv, char* str)
{
	FldToStr(mv.From(), str);
	FldToStr(mv.To(), str + 2);

	switch (mv.Promotion())
	{
	case QUEENW:
	case QUEENB:
		strcat(str, "q");
		break;

	case ROOKW:
	case ROOKB:
		strcat(str, "r");
		break;

	case BISHOPW:
	case BISHOPB:
		strcat(str, "b");
		break;

	case KNIGHTW:
	case KNIGHTB:
		strcat(str, "n");
		break;

	default:
		break;
	}

	return str;
}
////////////////////////////////////////////////////////////////////////////////

char* MoveToStrShort(Move mv, const MoveList& mvlist, char* str)
{
	PIECE piece = mv.Piece();
	FLD from = mv.From();
	FLD to = mv.To();
	PIECE captured = mv.Captured();
	PIECE promotion = mv.Promotion();

	strcpy(str, "");

	if ((piece == PAWNW || piece == PAWNB))
	{
		if (captured)
		{
			FldToStr(from, str);
			str[1] = 'x';
			str[2] = 0;
		}

		char buf1[3];
		strcat(str, FldToStr(to, buf1));

		switch	(promotion)
		{
		case QUEENW:
		case QUEENB:
			strcat(str, "=Q");
			break;
		case ROOKW:
		case ROOKB:
			strcat(str, "=R");
			break;
		case BISHOPW:
		case BISHOPB:
			strcat(str, "=B");
			break;
		case KNIGHTW:
		case KNIGHTB:
			strcat(str, "=N");
			break;
		default:
			break;
		}

		return str;
	}
	else if (mv == Move(E1, G1, KINGW) || mv == Move(E8, G8, KINGB))
	{
		strcpy(str, "O-O");
		return str;
	}
	else if (mv == Move(E1, C1, KINGW) || mv == Move(E8, C8, KINGB))
	{
		strcpy(str, "O-O-O");
		return str;
	}

	switch (piece)
	{
	case KNIGHTW:
	case KNIGHTB:
		strcat(str, "N");
		break;
	case BISHOPW:
	case BISHOPB:
		strcat(str, "B");
		break;
	case ROOKW:
	case ROOKB:
		strcat(str, "R");
		break;
	case QUEENW:
	case QUEENB:
		strcat(str, "Q");
		break;
	case KINGW:
	case KINGB:
		strcat(str, "K");
		break;
	default:
		return MoveToStrLong(mv, str);
	}

	// resolve ambiguity

	int uniq_col = 1;
	int uniq_row = 1;
	int ambiguity = 0;

	int row0 = Row(from);
	int col0 = Col(from);

	for (int i = 0; i < mvlist.Size(); ++i)
	{
		Move mvi = mvlist[i];

		if (mvi.To() != to)
			continue;

		if (mvi.Piece() != piece)
			continue;

		if (mvi.From() == from)
			continue;

		ambiguity = 1; // two or more pieces of the same type can move to field

		int row1 = Row(mvi.From());
		int col1 = Col(mvi.From());

		if (row0 == row1)
			uniq_row = 0;

		if (col0 == col1)
			uniq_col = 0;
	}

	if (ambiguity)
	{
		char from_info[16];
		FldToStr(from, from_info);

		if (uniq_col)
			from_info[1] = 0;
		else if(uniq_row)
		{
			from_info[0] = from_info[1];
			from_info[1] = 0;
		}

		strcat(str, from_info);
	}

	if (captured)
		strcat(str, "x");

	char buf1[3];
	strcat(str, FldToStr(to, buf1));
	return str;
}
////////////////////////////////////////////////////////////////////////////////

FLD StrToFld(const char* s)
{
	if (strlen(s) != 2)
		return NF;

	int col = s[0] - 'a';
	int row = 7 - (s[1] - '1');

	if (col < 0 || col > 7 || row < 0 || row > 7)
		return NF;

	return (8 * row + col);
}
////////////////////////////////////////////////////////////////////////////////

Move StrToMove(const char* str, const Position& pos)
{
	const char* p = str;
	while (1)
	{
		if (isdigit(*p))
			break;

		if (*p == ' ' || *p == 0)
			return 0;

		++p;
	}

	MoveList mvlist;
	mvlist.GenAllMoves(pos);

	for (int n = 0; n < mvlist.Size(); ++n)
	{
		Move mv = mvlist[n];
		char buf[16];
		MoveToStrLong(mv, buf);
		if (strstr(str, buf) == str)
			return mv;
	}

	for (int n = 0; n < mvlist.Size(); ++n)
	{
		Move mv = mvlist[n];
		char buf[16];
		MoveToStrShort(mv, mvlist, buf);
		if (strstr(str, buf) == str)
			return mv;
	}

	return 0;
}
////////////////////////////////////////////////////////////////////////////////

