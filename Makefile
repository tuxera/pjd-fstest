# $FreeBSD: src/tools/regression/fstest/Makefile,v 1.1 2007/01/17 01:42:07 pjd Exp $

#CFLAGS+=-DHAS_LCHMOD
#CFLAGS+=-DHAS_CHFLAGS
#CFLAGS+=-DHAS_LCHFLAGS
#CFLAGS+=-DHAS_TRUNCATE64
#CFLAGS+=-DHAS_STAT64
CFLAGS+=-DHAS_ACL

all:	fstest

fstest:	fstest.c
	gcc -Wall ${CFLAGS} fstest.c -o fstest -lacl

clean:
	rm -f fstest
