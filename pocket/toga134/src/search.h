
// search.h

#ifndef SEARCH_H
#define SEARCH_H

// includes

#include <csetjmp>

#include "board.h"
#include "list.h"
#include "move.h"
#include "util.h"

// constants

const int MultiPVMax = 10;

const int DepthMax = 64;
const int HeightMax = 256;

const int SearchNormal = 0;
const int SearchShort  = 1;

const int SearchUnknown = 0;
const int SearchUpper   = 1;
const int SearchLower   = 2;
const int SearchExact   = 3;

// types

struct search_multipv_t {
   int mate;
   int depth;
   int max_depth;
   int value;
   double time;
   sint64 node_nb;
   char pv_string[512];

};

struct search_param_t {
   int move;
   int best_move;
   int threat_move;
   bool reduced;
	bool extended;
	bool capture;
	int eval_value;
};

struct search_input_t {
   board_t board[1];
   list_t list[1];
   bool infinite;
   bool depth_is_limited;
   int depth_limit;
   int multipv;
   bool time_is_limited;
   double time_limit_1;
   double time_limit_2;
};

struct search_info_t {
   jmp_buf buf;
   bool can_stop;
   bool stop;
   int check_nb;
   int check_inc;
   double last_time;
};

struct search_root_t {
   list_t list[1];
   int depth;
   int move;
   int move_pos;
   int move_nb;
   int last_value;
   bool bad_1;
   bool bad_2;
   bool change;
   bool easy;
   bool flag;
};

struct search_best_t {
   int move;
   int value;
   int flags;
   int depth;
   mv_t pv[HeightMax];
};

struct search_current_t {
   board_t board[1];
   my_timer_t timer[1];
   int max_depth;
   int max_extensions; // Thomas
   int multipv;
   sint64 node_nb;
   double time;
   double speed;
   double cpu;
};

// variables

extern bool trans_endgame;
extern search_param_t SearchStack[HeightMax]; // Thomas
extern search_input_t SearchInput[1];
extern search_info_t SearchInfo[1];
extern search_best_t SearchBest[MultiPVMax];
extern search_root_t SearchRoot[1];
extern search_current_t SearchCurrent[1];

// functions

extern bool depth_is_ok           (int depth);
extern bool height_is_ok          (int height);

extern void search_clear          ();
extern void search                ();

extern void search_update_best    ();
extern void search_update_root    ();
extern void search_update_current ();

extern void search_check          ();

#endif // !defined SEARCH_H

// end of search.h

