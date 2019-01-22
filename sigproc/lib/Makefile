# GNU make makefile
# This makefile uses GNU make specific conditionals.
#
# make arch=XXX
# where XXX is the architecture type as specified Matlab mex extensions
# examples:
#	mexsg64		64 bit SGI 
#	mexhp7		Helwett Packard
#	mexglx		GNU/Linux
#	dll		Microsoft win32
# These names are subject to change, consult your Matlab external
# interface guide for details.
#
# If you do not have GNU make on your system and do not want to
#	install it, simply remove the if.../else/endif directives
#	leaving the appropriate conditional code.
#
# Note - some system administrators install GNU make as gmake.

# Make sure we know what platform to build for.
ifndef arch
$(error ERROR - architecture symbol mandatory - i.e. "make arch=dll")
endif

# NIST speech libraries
NISTDIR=$(HOME)/speech/nist

LIBNAME=sigproc
LIBFILE=$(OBJDIR)/lib$(LIBNAME).a
# keep .o/.obj in architecture dependent directories
OBJDIR=$(arch)
CCFLAGS = -c -g -I$(NISTDIR)/include -outdir $(OBJDIR)

ifeq ($(arch),dll)

# Windows
.SUFFIXES: .obj
CC=mex.bat
OBJ=obj
AR = lib
ARFLAGS= /out:$(LIBFILE)

else

# UNIX - hooray!
CC=mex
OBJ=o
AR=ar 
ARFLAGS=-ru $(LIBFILE)
PLATFORM_SPECIFIC_OJBECTS= 
ARCHDIR_PLATFORM_SPECIFIC_LIBS= 
endif

vpath %.$(OBJ) $(OBJDIR)

$(OBJDIR)/%.obj : %.c
	$(CC) $(CCFLAGS) $<

$(OBJDIR)/%.o : %.c
	$(CC) $(CCFLAGS) $<

# Build up list of objects with appropriate directory and suffix.
OBJECTS= $(addprefix $(OBJDIR)/, $(addsuffix .$(OBJ), \
	CreateEndpointed CreateEndpointedComplement \
	CreateEndpointedFrameEnergy ExtractFrameTimings Frame))

# library depends on general object files + platform specific object files
$(LIBFILE) : $(OBJDIR) $(OBJECTS) 
	$(AR) $(ARFLAGS) $(OBJECTS) $(ARCHDIR_PLATFORM_SPECIFIC_LIBS)

# for dependency rules, VPATH does not work on the target, only on
# the predecessors, so we must specify the object directories on the
# left hand side.

$(OBJDIR)/CreateEndpointedFrameEnergy.$(OBJ) : \
	CreateEndpointedFrameEnergy.c CreateEndpointedFrameEnergy.h

$(OBJDIR)/Frame.$(OBJ) : Frame.c

.PHONY : clean

# - => Don't treat as a failure if directory already exists.
$(OBJDIR) :
	-mkdir $(OBJDIR)

# .pdb files produced by on some Windows platforms
clean :
	rm -f $(OBJDIR)/*.$(OBJ) $(OBJDIR)/*.pdb *~
