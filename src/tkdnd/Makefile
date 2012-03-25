THR_SUPPORT = -DDONT_USE_SYNC_BUILTIN
HAVE_XFT		= -DHAVE_XFT

AR          = ar
ARFLAGS     = rc
RANLIB      = ranlib
X_INCLUDE	= 

.PHONY : clean
.PRECIOUS:

EXTRA_CFLAGS  	= -pipe -Wno-format-security -fno-stack-protector

.SUFFIXES: .c
.PRECIOUS:

INCLUDE	= $(TCL_INCLUDE) $(TK_INCLUDE) $(X_INCLUDE) -I../tk$(TCL_VERSION)
CFLAGS	+= $(OPTIMIZE) $(C_DEBUG) $(PROFILING)

SRC	= unix/TkDND_XDND.c
OBJS	= $(SRC:.c=.o)
LIB	= libtkDnd

all: $(LIB).a

clean:
	@rm -f $(LIB).a TkDND_XDND.o

depend:
#	makedepend -fMakefile -Y -- -I../tk$(TCL_VERSION) -- -w1 $(SRC) 2>/dev/null
#	@if [ -h Makefile.bak ]; then \
#		cp Makefile Makefile.bak; \
#		mv Makefile.bak Makefile; \
#	fi

$(LIB).a: $(OBJS)
	@echo "Building $(LIB).a"
	@$(AR) $(ARFLAGS) $(LIB).a TkDND_XDND.o
	@$(RANLIB) $(LIB).a

.c.o:
	@echo "Compiling `awk 'BEGIN { printf "%-30s", "$<" }'`  [$(CFLAGS:  = )]"
	@$(CC) -c $(CFLAGS) $(EXTRA_CFLAGS) $(INCLUDE) $<

