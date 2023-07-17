# GNU make makefile
# This makefile uses GNU make specific conditionals.
#
# make arch=XXX
# where XXX is the architecture type as specified Matlab mex extensions
# examples:
#	mexsg64		64 bit SGI 
#	mexhp7		Helwett Packard
#	mexsol		Sun Solaris
#	dll		Microsoft win32
# These names are subject to change, consult your Matlab external
# interface guide for details.
#
# If you do not have GNU make on your system and do not want to
#	install it, simply remove the ifeq/else/endif directives
#	leaving the appropriate conditional code.
#
# Note - some system administrators install GNU make as gmake.

# Make sure we know what platform to build for.
ifndef arch
$(error ERROR - architecture symbol mandatory - i.e. "make arch=dll")
endif

ifndef NIST
NIST = $(HOME)/speech/nist
endif

NISTLIBDIR = $(NIST)/lib/$(arch)
CCFLAGS =  -g -Ilib -I$(NIST)/include

DEBUG=-g
LIBNAME=sigproc
LIBFILE=lib$(LIBNAME).a
LIBDIR=lib
LIBFILEPATH=$(LIBDIR)/$(arch)/$(LIBFILE)

ifeq ($(arch),dll)

# Windows
CC=mex.bat
OBJ=obj
LIBLINKCMD=lib/$(arch)/libsigproc.lib $(NISTLIBDIR)/libendpoint.lib $(NISTLIBDIR)/libsnr.lib $(NISTLIBDIR)/libsp.lib $(NISTLIBDIR)/libutil.lib 

else

# UNIX - hooray!
CC=mex
LIBLINKCMD=-L$(NISTLIBDIR) -Llib/$(arch) -lsigproc -lendpoint -lsnr -lutil -lm 
OBJ=o

endif

.SUFFIXES: .$(arch)

.c.$(arch) :
	$(CC) $(CCFLAGS) $(DEBUG) $< $(LIBLINKCMD)


all : spEnergyLevels.$(arch) spEndpointKubala.$(arch) spPartition.$(arch)

spEnergyLevels.$(arch) : spEnergyLevels.c $(LIBFILEPATH)

spEndpointKubala.$(arch) : spEndpointKubala.c $(LIBFILEPATH)

spPartition.$(arch) : spPartition.c $(LIBFILEPATH)

.PHONY : clean $(LIBDIR)

$(LIBFILEPATH) : $(LIBDIR)

$(LIBDIR) :
	$(MAKE) -C $(LIBDIR) $(arch)/$(LIBFILE)

clean :
	rm spEnergyLevels.$(arch) spEndpoint.$(arch)
