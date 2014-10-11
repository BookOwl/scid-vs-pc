/****************************
 * evaluate() function decides if given position is terminal (checkmate,
 * stalemate, ...) , if not, seeks it in the hash table, if not
 * present, calls dynamic (search()) or static (static_eval()) evaluation.
 * This also handles extensions.
 ******************/

#include "phalanx.h"

#define EXTENSION_BASE 60

#define NULL_MOVE_PRUNING 300

#define RECAPTURE_EXTENSIONS
#define PEE_EXTENSIONS     /* entering kings+pawns endgame extends */
#define CHECK_EXTENSIONS
#define PAWNPUSH_EXTENSIONS

#define minmv (P_VALUE)

/* 12 moves to draw: the static evaluation goes to zero */
#define RULE_50_CLOSE 24

/**
***   Phalanx uses very simple implementation of static-eval cache.
***   It eats 512 kB and makes it about 10% faster on a 486.
**/
#undef CACHE
#ifdef CACHE
unsigned * C; /* 64k entries of 4 bytes: 256kB */
#endif



void blunder( tmove *m, int *n )
{
int i;
int initp = Flag.easy;

/* quick look (small Depth) makes blunders */
initp -= Depth/10;

/* full board means more blunders */
initp += (G[Counter].mtrl+G[Counter].xmtrl) / 200;

if(Counter>2)
for( i=(*n)-1; i>=1 && (*n)>4; i-- )
{
	/* compute the probability this move is not seen */
	int p = initp;

	/* missing PV moves is unlikely */
	if( m[i].from==PV[0][Ply].from && m[i].to==PV[0][Ply].to )
	p -= 100;

	if( m[i].from==PV[Ply-1][Ply].from && m[i].to==PV[Ply-1][Ply].to )
	p -= 100;

	if( m[i].in2 ) /* captures - we tend to see this */
	{
		/* the more valuable the captured piece,
		 * the more likely we see the move. */
		p -= 10 + Values[ m[i].in2 >> 4 ] / 50;

		/* capture of last moved piece is spotted
		 * + extra bonus for recapture */
		if( m[i].to == G[Counter-1].m.to )
		{
			p -= 20 + Values[ m[i].in2 >> 4 ] / 50;
			if( G[Counter-1].m.in2 ) p -= 20; /* recapture */
		}

		/* very short captures */
		switch( dist[120*m[i].from+m[i].to].max )
		{
			case 0: case 1: p -= 30; break;
	  		case 2: p -= 20; break;
	  		case 3: p -= 10; break;
		}
	}
	else /* noncaptures - prune or reduce with power table info */
	{
		int pp=0;
		unsigned short pf = P[m[i].from], pt = P[m[i].to];
		unsigned short xpm, xbnm, xrm, xqm; /* enemy power masks */
		int mpv = Values[m[i].in1 >> 4]; /* moving piece value */

		if( Color == WHITE )
		{ xpm=BPM; xbnm=(BNM|BBM); xrm=BRM; xqm=BQM; }
		else
		{ xpm=WPM; xbnm=(WNM|WBM); xrm=WRM; xqm=WQM; }

		/* leaving an attacked square - reduce probability of
		 * the move being skipped */
		if( pf&xpm ) pp -= (5 + mpv - P_VALUE)/10;
		if( pf&xbnm && mpv >= N_VALUE ) pp -= (5 + mpv - N_VALUE)/10;
		if( pf&xrm && mpv >= R_VALUE ) pp -= (5 + mpv - R_VALUE)/10;
		if( pf&(xqm|xrm|xbnm|xpm) ) pp -= mpv/100;

		/* going to an attacked square - raise probability
		 * the move is skipped */
		if( pt&xpm ) pp += (10 + mpv - P_VALUE)/10;
		if( pt&xbnm && mpv >= N_VALUE ) pp += (10 + mpv - N_VALUE)/10;
		if( pt&xrm && mpv >= R_VALUE ) pp += (10 + mpv - R_VALUE)/10;
		if( pt&(xqm|xrm|xbnm|xpm) ) pp += mpv/50;

		p += pp;

		/* careless reductions to achieve depth at these low nps */
		if( pp>=0 ) m[i].dch += 50 + min( 2*pp, 90 );
	}

	/* We focus on the piece that moved 2 plies ago and see the
	 * moves of the same piece */
	if( m[i].from == G[Counter-2].m.to ) p -= 25;

	/* underpromotions? too precise! */
	if( m[i].in1 != m[i].in2a  &&  piece(m[i].in2a) != QUEEN )
	p += 15;
	else
	p -= 5;

	/* dont see long moves, especially diagonal ones */
	p += dist[120*m[i].from+m[i].to].taxi * 3;

	/* dont see some knight moves */
	if( piece(m[i].in1) == KNIGHT )
	p += 10;

	/* going backward?  (white)Bf6xc3 is much more difficult
	 * to see than (white)Bc3xf6 ***/
	if( Color==WHITE )
		p += 4 * ( m[i].to/10 - m[i].from/10 );
	else
		p += 4 * ( m[i].from/10 - m[i].to/10 );

	if( rand()%1000 < p )
	{ m[i] = m[(*n)-1]; (*n)--; }
}
}



void initcache(void)
{
#ifdef CACHE
C = malloc(0x10000*sizeof(unsigned)); /* 64k entries of 8 bytes: 512kB */
if( C==NULL ) { puts("cannot alloc static eval cache!"); exit(0); }
#endif
}


int psnl[MAXPLY];
int devi[MAXPLY];

static inline int approx_eval(void)
{
psnl[Ply] = - psnl[Ply-1];

devi[Ply] = devi[Ply-1]*2/3 + abs(psnl[Ply])/8;
if( G[Counter-1].m.in2 ) devi[Ply] += 60; else devi[Ply] += 40;

return G[Counter].mtrl - G[Counter].xmtrl + psnl[Ply];
}



int static_eval(void)
{

int positional;
int r50 = 100 - G[Counter].rule50;
int material = G[Counter].mtrl-G[Counter].xmtrl;

#ifdef CACHE
if( ( ( C[ 0x0000FFFF & G[Counter].hashboard ] ^ G[Counter].hashboard )
    & 0xFFFF0000 ) == 0 )
{
unsigned * cc = C + ( 0x0000FFFF & G[Counter].hashboard );
Wknow.prune = (((*cc)&0x00004FFF)!=0);
Bknow.prune = (((*cc)&0x00008FFF)!=0);
return ( (*cc) & 0x00003FFF ) ;
}
#endif

positional = score_position();

if( r50 < RULE_50_CLOSE )
{ positional = positional * r50 / RULE_50_CLOSE;
  material = material * r50 / RULE_50_CLOSE;
}

#undef RAISE
#ifdef RAISE
/* Inbalanced material: take positional bonus seriously */
if( abs(material) > 200 )
{
	int m = abs(material) - 200;
	if( m > 1000 ) m=1000;
#ifdef SCORING
	if( Scoring )
		printf(
		" (   ) inbalanced material, positional raised: %i -> %i\n",
		positional, positional + positional*m/500 );
#endif
	positional =        positional + positional*m/500;
}
#endif

#ifdef CACHE
{
unsigned * cc = C + ( 0x0000FFFF & G[Counter].hashboard );
*cc = ( 0xFFFF0000 & G[Counter].hashboard ) | ( material+positional );
if( Wknow.prune ) *cc |= 0x00004000; else *cc &= (0xFFFFFFFF-0x00004000);
if( Bknow.prune ) *cc |= 0x00008000; else *cc &= (0xFFFFFFFF-0x00008000);
}
#endif

psnl[Ply] = positional;
devi[Ply] = 0;

#undef debug
#ifdef debug
if(abs(positional)>600)
{ Scoring = 1; score_position(); Scoring = 0;
  printboard(); printf("[%i,%i,%i]",material,positional,score_position());
  getchar();
}
#endif

return material+positional;

}



inline int repetition( int n )
{
	int i;
	int r=0;
	unsigned board = G[Counter].hashboard;
	for( i=Counter-2; i>=0; i-=2 )
	{
		if( G[i].hashboard == board ) if( ++r == n ) return 1;
		if( G[i].rule50 <= 1 ) break;
	}
	return 0;
}



int material_draw( void )
{
	int i, n=2;

	for( i=L[WKP].next; i!=0; i=L[i].next )
	switch( B[i] )
	{	case WQ: case WR: case WP: return 0;
		default: n--; if( n==0 ) return 0;
	}

	for( i=L[BKP].next; i!=0; i=L[i].next )
	switch( B[i] )
	{	case BQ: case BR: case BP: return 0;
		default: n--; if( n==0 ) return 0;
	}

	return 1;
}



/*****************************************************************/

int evaluate( int Alpha, int Beta )
{

static int timeslice = 2000;
static int polslice = 4000;
int result;
tmove m[256]; int n;  /* moves and number of moves */
thashentry *t;
int check;
int lastiter;
int totmat = Totmat = G[Counter].mtrl+G[Counter].xmtrl;

if(Ply%2) lastiter = -LastIter; else lastiter = LastIter;

Nodes++;

if( Flag.level == fixedtime || Flag.level == timecontrol )
if( ( Nodes % timeslice ) == 0 && !Flag.analyze )
{
	extern long T1;
	int t = Flag.centiseconds - ptime() + T1;

	if( t < 0 ) { if( Flag.ponder >= 2 ) Flag.ponder = 3; else Abort = 2; }
	else
	if( t != Flag.centiseconds )
	timeslice =
	  Nodes * t / ( Flag.centiseconds - t ) * 2 / 3;

	if( timeslice > 5*Flag.centiseconds ) timeslice = 5*Flag.centiseconds;
	if( timeslice < 50 ) timeslice=50;
}

{
	static int64 lnodes = 0;
	if( lnodes + polslice < Nodes || Nodes == 1 )
	{
		static long lptime = 0;
		long nptime = ptime();

		if( nptime == lptime ) nptime++;

		if( nptime - lptime < 100 ) polslice = polslice*11/10;
		else { polslice = polslice*10/11; }

		lptime = nptime;

		if( Flag.post && !Flag.xboard ) verboseline( A_m, A_i, A_n );

if(Flag.polling)
{

#if defined(__GNUC__) && !defined(__MINGW32__)
  static fd_set readfds;
  static struct timeval tv;
  int data;

  FD_ZERO (&readfds);
  FD_SET (fileno(stdin), &readfds);
  tv.tv_sec=0;
  tv.tv_usec=0;
  select(16, &readfds, 0, 0, &tv);
  data=FD_ISSET(fileno(stdin), &readfds);
  if(data) interrupt(0);

#else

 /* Credit here goes to Dr Oliver Brausch for the code from his
  * program Olithink.  Some rewriting has been done by CMF, but not much
  * as I have absolutely no idea whatsoever what this does.
  * I think the original code is from Crafty by Prof. Robert Hyatt. [JA] */

  static int init = 0, pipe;
  static HANDLE inh;
  DWORD dw;

  /* If we're running under XBoard then we can't use _kbhit() as the input commands
   * are sent to us directly over the internal pipe */
  if (Flag.xboard>0) {
#if defined(FILE_CNT)
    if (stdin->_cnt > 0) return stdin->_cnt;
#endif
    if (!init) {
      init = 1;
      inh = GetStdHandle(STD_INPUT_HANDLE);
      pipe = !GetConsoleMode(inh, &dw);
      if (!pipe) {
        SetConsoleMode(inh, dw & ~(ENABLE_MOUSE_INPUT | ENABLE_WINDOW_INPUT));
        FlushConsoleInputBuffer(inh);
      }
    }
    if (pipe) {
      if (!PeekNamedPipe(inh, NULL, 0, NULL, &dw, NULL)) return 1;
      return dw;
    }
    else {
      GetNumberOfConsoleInputEvents(inh, &dw);
      return dw <= 1 ? 0 : dw;
    }
  }
  else return _kbhit();

#endif

}

/*
		if( Flag.analyze )
		printf("stat01: %d %d %d %d %d\n",0,Nodes,A_d,A_i,A_n);
*/

		lnodes = Nodes;
	}
}

if( Ply >= MAXPLY-2 )
{ PV[Ply][Ply].from=0; return G[Counter].mtrl-G[Counter].xmtrl; }

if( G[Counter].rule50 >= 100 ) /* 50 moves draw */
{ PV[Ply][Ply].from=0; return DRAW; }

/* insufficient material draw */
if( G[Counter].mtrl<400 && G[Counter].mtrl<400 )
if( material_draw() )
{ PV[Ply][Ply].from=0; return DRAW; }

if( G[Counter].rule50 >= 3 )
if( repetition(1) ) /* third rep. draw */
{
	int j;
	int ext=0;
	PV[Ply][Ply].from=0;

	for( j=Counter-1; j>Counter-Ply; j-=2 )
	{ ext += G[j-1].m.dch - G[j].m.dch; }

	if( ext > 0 )
	{
		if( ext > 500 ) ext=500;
		ext += Ply*20;
	}
	else if( ext < 0 )
	{
		if( ext < -500 ) ext=-500;
		ext -= Ply*20;
	}

	return ext/10+DRAW;
}

/********************************************************************
 *     Now it is time to look into the hashtable.
 ********************************************************************/
if( SizeHT == 0 || Depth<0 ) t = NULL;
else
if( (t=seekHT()) != NULL )
if( t->depth >= Depth || ( Depth<300 && abs(t->value)>CHECKMATE-1000 ) )
{
	int val = t->value;
	if( val > CHECKMATE-1000 ) val -= Ply;
	else if( val < -CHECKMATE+1000 ) val += Ply;

	switch( t->result )
	{
	case no_cut:                    /* `true value', good_score */
		PV[Ply][Ply].from=0;
		return val;
	break;
	case alpha_cut:                 /* `this or less', failed_low */
		if( val <= Alpha )
		{ PV[Ply][Ply].from=0; return val; }
		if( val < Beta ) Beta = val;
	break;
	case beta_cut:                  /* `this or more', failed_high */
		if( val >= Beta )
		{ PV[Ply][Ply].from=0; return val; }
		if( val > Alpha ) Alpha = val;
	break;
	}
}
/***** End of hashtable stuff *****/

#undef nodef
#ifdef nodef
{
static int64 int good=0, all=0;
if( t!=NULL && t->move!=0 ) good++;
all++;
if( all%100000 == 0 && all!=0 )
printf("hit percentage = %lld.%02lld%%\n",good*100/all,good*10000/all%100);
}
#endif

G[Counter].check = check = checktest(Color);

if( Depth>0 || check )
{

	if(Depth<=0) result = approx_eval();
	else         result = static_eval();


#ifdef NULL_MOVE_PRUNING
	if(
		result+100 >= Beta
		&& ( result >= Beta || Depth > NULL_MOVE_PRUNING )
		&& ! FollowPV
		&& ! check
		&& G[Counter].mtrl > Q_VALUE+B_VALUE        /* zugzwang fix */
/*		&& G[Counter-1].m.special != NULL_MOVE */  /* prev. node not nullm */
		&& ( t==NULL || t->depth <= Depth-NULL_MOVE_PRUNING
		  || t->result==beta_cut || t->value >= Beta )
	)
	{
		int value;
		int olddepth = Depth;
		int alpha = -Beta;

		tmove m[256]; int n;  /* moves and number of moves */

		G[Counter].m.in1 = 0; /* disable en passant */
		G[Counter].m.special = NULL_MOVE;
		G[Counter].m.to = 2;
		Counter ++; Ply ++;
		G[Counter].castling = G[Counter-1].castling;
		G[Counter].rule50 = G[Counter-1].rule50 + 1;
		G[Counter].hashboard =
			HASH_COLOR ^ G[Counter-1].hashboard;
		G[Counter].mtrl = G[Counter-1].xmtrl;
		G[Counter].xmtrl = G[Counter-1].mtrl;
		Color = enemy(Color);

		Depth -= NULL_MOVE_PRUNING;
		if( Depth <= 0 )
		{
			Depth = 0;
#ifdef QCAPSONLY
			generate_legal_captures(m,&n,0);
#else
			generate_legal_checks(m,&n);
#endif
		}
		else
		{
			generate_legal_moves( m, &n, 0 );
		}

		if( n!=0 )
		{
			add_killer( m, n, NULL );
			value = -search( m, n, alpha, alpha+1 );
		}
		else
		{ if(Depth!=0) value=Alpha; else value=result; }

		Color = enemy(Color);
		Counter --; Ply --;
		Depth = olddepth;
		Totmat = totmat;

		if( value >= Beta ) { result = value; goto end; }
	}
#endif

	generate_legal_moves(m,&n,check);

	/** Return, if there is no legal move - checkmate or stalemate **/
	if(n==0)
	{
		PV[Ply][Ply].from=0;
		if(check) return Ply-CHECKMATE;
		else return DRAW;
	}

#ifdef CHECK_EXTENSIONS
	if( check && Depth>0 )       /* extend the lines */
	{
		if( result>lastiter-50 && result>-250 )
		{
			int i, newdch = EXTENSION_BASE-20, inrow=0;

			if( Depth <= 100 ) newdch -= 30;
			else
			if( Depth <= 200 ) newdch -= 20;

			for( i=Counter-2; i>0 && G[i].check; i-=2 ) inrow++;
			switch( inrow ) /* number of checks in row */
			{
				case 0: break;
				case 1: newdch -= 10; break;
				default: newdch -= 30; break;
			}

			if(n>4)	newdch += 6*(n-5);
			else	newdch -= 20*(5-n);

			if( newdch > 60 ) newdch = 60;
			else if( newdch < -40 ) newdch = -40;

			for( i=0; i!=n; i++ )
				m[i].dch = newdch;
		}
		else  /* losing anyway */
		{ int i; for( i=0; i!=n; i++ ) m[i].dch = 60; }
	}
#endif

#ifdef PAWNPUSH_EXTENSIONS
	if( Totmat < 4000 )
	if(result<lastiter+50 && result<250)  /* winning anyway: dont extend */
	{
		int i;
		for( i=0; i!=n; i++ )
		if( piece(m[i].in2a) == PAWN
		 && m[i].special == 0
		 && ( ( Color==WHITE && m[i].to >= A6 )
		   || ( Color==BLACK && m[i].to <= H3 ) ) )
		{
			int j;
			int support=0;
			int newdch=EXTENSION_BASE;

			if( Color == WHITE )
			{

				for( j=m[i].to+10; j<=H7; j+=10 )
				if( B[j-1]==BP
				 || B[j]==BP
				 || B[j+1]==BP )
				goto no_push_extension;

				for( j=m[i].to; j<=H8; j+=10 )
				{
					if( B[j] ) support--;
					if( see(B,m[i].from,j) < 0 )
						support--;
					else	support++;
				}
			}
			else
			{
				for( j=m[i].to-10; j>=A2; j-=10 )
				if( B[j-1]==WP
				 || B[j]==WP
				 || B[j+1]==WP )
				goto no_push_extension;

				for( j=m[i].to; j>=A1; j-=10 )
				{
					if( B[j] ) support--;
					if( see(B,m[i].from,j) < 0 )
						support--;
					else	support++;
				}
			}

			newdch += Depth/20 + Totmat/100 - 30*support;

			switch( m[i].to/10 )
			{ case 8: case 3:
			  if(support>0) newdch -= 20*support+10; break; }

			if( newdch < m[i].dch )
			{ m[i].dch = newdch; }

			no_push_extension:;
		}
	}
#endif

#ifdef ETTC
if( Depth > 200 && SizeHT != 0 )
{
	extern void do_hash(tmove *), undo_hash(tmove *);

	int i;
	for( i=0; i!=n; i++ )
	{
		thashentry *t;
		do_hash(m+i);

		if( (t=seekHT()) != NULL )
		if( t->depth >= Depth )
		if( t->result != beta_cut )
		{
			int val = -t->value;
			if( val > CHECKMATE-100 ) val -= Ply;
			else if( val < -CHECKMATE+100 ) val += Ply;

			if( val > Alpha )
			{
				if( val >= Beta )
				{
					undo_hash(m+i);
					G[Counter].m = m[i];
					PV[Ply][Ply] = m[i];
					PV[Ply][Ply+1].from = 0;
					result = Beta; goto end;
				}
				Alpha=val;
			}
		}
		undo_hash(m+i);
	}
}
#endif

}
else
{	/*** Quiescence search ***/

	result = approx_eval();

	if( ( result < Beta+devi[Ply] && result > Alpha-devi[Ply] )
	 || Totmat<=(B_VALUE+P_VALUE) )
	result = static_eval();

	if( result >= Beta ) return result;

	if( result <= Alpha-(Q_VALUE+minmv) && Depth <= -100 )
	{ return Alpha; }

#ifdef QCAPSONLY
	generate_legal_captures(m,&n,Alpha-result-minmv);
#else
	/* What to generate? Only captures or also safe checks? */
	if(    G[Counter].mtrl-G[Counter].xmtrl < 400
	    && Depth > -100
	    && ( Color==WHITE ? ( Bknow.khung > 1 ) : ( Wknow.khung > 1 ) )
	)
		generate_legal_checks(m,&n);
	else
		generate_legal_captures(m,&n,Alpha-result-minmv);
#endif
}

#ifdef RECAPTURE_EXTENSIONS
	if( Depth>0 && G[Counter-1].m.in2 )
	if( result<lastiter+50 && result<250 )   /* winning anyway: dont */
	{
		int i, t=G[Counter-1].m.to;
		int v1 = Values[ G[Counter-1].m.in1 >> 4 ];
		int v2 = Values[ G[Counter-1].m.in2 >> 4 ];
		int newdch;

		if( Depth <= 200 )
			newdch = EXTENSION_BASE-30;
		else
			newdch = EXTENSION_BASE-20;

		if( min(v1,v2) > 400 || G[Counter].mtrl < Q_VALUE )
			newdch -= 70;
		else
		if( min(v1,v2) > 200 || G[Counter].mtrl < (Q_VALUE+N_VALUE) )
			newdch -= 45;

		/* recaptures depth bonus */
		for( i=0; i!=n; i++ )
		if( m[i].to == t )
		if( m[i].dch > newdch )
/*		if( Depth<=100 || see(B,m[i].from,m[i].to) >= v1 ) */
			m[i].dch = newdch;
	}
#endif

#ifdef PEE_EXTENSIONS
	if( Depth > 200
	 && G[Counter].mtrl <= (8*P_VALUE)
	 && G[Counter].xmtrl <= (8*P_VALUE+Q_VALUE)
	 && G[Counter-1].m.in2 > KNIGHT )
	{
		int i;
		int target=0;
		int cdch;

		for( i=L[L[Color].next].next; i!=0; i=L[i].next )
		if( B[i] >= KNIGHT ) goto nopee;

		for( i=L[L[enemy(Color)].next].next; i!=0; i=L[i].next )
		if( B[i] >= KNIGHT )
		{ if( target ) goto nopee; else target=i; }

		if( ! target ) goto nopee;

		if( G[Counter-1].m.in2 >= QUEEN ) cdch = min(Depth,450);
		else cdch = min(Depth*2/3,350);

		for( i=0; i!=n; i++ )
		if( m[i].to == target )
		{ m[i].dch -= cdch;
		  /* printboard(NULL); printm(m[i],NULL); getchar(); */ }

		nopee:;
	}
#endif

/*** Compute heuristic values of moves ***/
add_killer( m, n, t );

PV[Ply][Ply].from = 0;

if( Flag.nps )
{
	if( Flag.easy )
	{ if( n>10 && Flag.easy<=100 ) blunder(m,&n); }

	/* timecontrol fix */
	if( polslice > Flag.easy+200 ) polslice=Flag.easy+200;

	/* Now limit the NPS, lowest value is 100.
	 * For higher values of nps levels like 50000 nps, there's no need
	 * to check for the limit and call ptime() at every node,
	 * hence the condition below */
	if( Nodes%(1+Flag.nps/500)==0 )
	{
		int nps_actual = Nodes*100/max(ptime()-T1,1);
		if( nps_actual > Flag.nps ) usleep(100000);
	}
}

/*** Full-width search ***/
if( Depth>0 || check )
{
	result = search(m,n,Alpha,Beta);
}
else /*** Quiescence ***/
{
	if( result > Alpha )
		result = search(m,n,result,Beta);
	else
		result = search(m,n,Alpha,Beta);
}

end:

if( result>=Beta && Depth>0 )
	write_killer( G[Counter].m.from, G[Counter].m.to );

if( SizeHT != 0 && Depth >= 0 && Abort == 0 ) writeHT( result, Alpha, Beta );

/**
***    Check learning file.
***    This should be done before search.  It is here only for
***    timing heuristics stability problem that needs better
***    solution.
**/
if( Depth > 300 && Flag.learn )
if( Depth > 400 || Ply<3 )
{
	int lresult = rlearn();
	if( lresult != NOVALUE )
	{ PV[Ply][Ply].from=0;
	  if( lresult > CHECKMATE-1000 )  lresult -= Ply;
	  if( lresult < -CHECKMATE+1000 ) lresult += Ply;
	  result = lresult;
	}
}

return result;

}


