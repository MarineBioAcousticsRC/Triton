# GNU make makefile
# This makefile uses GNU make specific conditionals.
#
# make arch=XXX
# where XXX is the architecture type as specified Matlab mex extensions
# examples:
#	mexsg64					64 bit SGI 
#	mexhp7					Helwett Packard
#	mexw32 or mexw64		Microsoft windows 32 or 64 bit
#
# To select the correct name for your system, type "mexext" at the 
# Maltab command line.  Mathworks has changed the names of these files
# over time, consult the Matlab interface guide if you have difficulties.
#
# If you do not have GNU make on your system and do not want to
#	install it, simply remove the ifeq/else/endif directives
#	leaving the appropriate conditional code.
#
# Note - some system administrators install GNU make as gmake.

# Make sure we know what platform to build for.
ifndef arch
$(error ERROR - architecture symbol mandatory - i.e. "make arch=mexw64" Use "mexext" at Matlab prompt to determine correct architecture.)
endif

DEBUG=-g -O
CCFLAGS=-I../include $(DEBUG)
LIBDIR=lib
LIBNAME=stat
LIBOBJ=$(LIBDIR)/lib$(LIBNAME).a

ifeq ($(arch),mexw32) 

# Windows 32
.SUFFIXES: .obj
CC=mex.bat
LIB=$(LIBOBJ)
OBJ=obj

else ifeq ($(arch), mexw64)

# Windows 64
.SUFFIXES: .obj
CC=mex.bat
LIB=$(LIBOBJ)
OBJ=obj

else

# UNIX - hooray!
CC=mex
LIB=-L$(LIBDIR) -l$(LIBNAME)

endif

OBJECTS = $(addsuffix .$(arch), stMA stDiscreteDrawAux stQuickSelect)

.SUFFIXES: .$(arch)

.c.$(arch) :
	$(CC) $(CCFLAGS) $< 

.cpp.$(arch) :
	$(CC) $(CCFLAGS) $< 

# Change to the following if library functions added later...
#	$(CC) $(DEBUG) $< $(LIB)

all : $(OBJECTS)

stMA.$(arch) : stMA.c

stDiscreteDrawAux.$(arch) : stDiscreteDrawAux.c

stQuickSelect.$(arch) : stQuickSelect.cpp


