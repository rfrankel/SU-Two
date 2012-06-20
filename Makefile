ARCH=linux

include Makedefs.$(ARCH)

LIBS = $(ARCH_LIBS) -ltcl7.6 -ltk4.2 -lX11 -lm -lpthread

MAKEFILE = Makefile

CFLAGS = -Wall -Wno-import -g -O -I .  
LFLAGS = -g -O  -L/usr/lib -L/usr/lib/gcc-lib/i486-linux/2.7.2.3/  -L/usr/X11R6/lib/

.SUFFIXES: .m .o
.m.o:
	$(ARCH_CC) $(CFLAGS) -o ./$*.o -c $*.m

CLASSES= qvect.m qlongt.m group.m axang.m aagrp.m appear.m decor.m
CMDS = initcmds.m gencmds.m objcmds.m comcmds.m
HEADERS=$(CLASSES:.m=.h) $(ARCH_CLASSES:.m=.h)
CMDSH =  $(CMDS:.m=.h)
OBJS=$(CLASSES:.m=.o) $(ARCH_CLASSES:.m=.o)
CMDSO = $(CMDS:.m=.o)
 
tclmain: tclmain.o  $(MAKEFILE) $(HEADERS) $(OBJS) $(CMDSH) $(CMDSO)
	($(ARCH_LINK) -o ./$@ $(LFLAGS) ./$(OBJS) ./$(CMDSO) ./tclmain.o  $(LIBS))

products: products.o $(MAKEFILE) $(HEADERS) $(OBJS)
	($(ARCH_LINK) -o ./$@ $(LFLAGS) ./$(OBJS) ./products.o $(LIBS))

basicSU2: basicinit.o $(MAKEFILE) $(HEADERS) $(OBJS)
	($(ARCH_LINK) -o ./$@ $(LFLAGS) ./$(OBJS) ./basicinit.o $(LIBS))

tclinit: tclinit.o  $(MAKEFILE) $(HEADERS) $(OBJS)
	($(ARCH_LINK) -o ./$@ $(LFLAGS) ./$(OBJS) ./tclinit.o $(LIBS))

aatest: aatest.o  $(MAKEFILE) $(HEADERS) $(OBJS)
	($(ARCH_LINK) -o ./$@ $(LFLAGS) ./$(OBJS) ./aatest.o $(LIBS))


all: products basicSU2 tclinit aatest

install:
	make list

lint:
	lint *.c

clean:
	rm *~ *.o *%
