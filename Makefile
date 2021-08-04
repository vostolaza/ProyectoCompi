# Makefile

OBJS	= bison.o lex.o main.o

CC	= g++
CFLAGS	= -g -Wall -ansi -pedantic

cES:		$(OBJS)
		$(CC) $(CFLAGS) $(OBJS) -o cES -lfl

lex.o:		lex.c
		$(CC) $(CFLAGS) -c lex.c -o lex.o

lex.c:		cES.l 
		flex cES.l
		cp lex.yy.c lex.c

bison.o:	bison.c
		$(CC) $(CFLAGS) -c bison.c -o bison.o

bison.c:	cES.y
		bison -d -v cES.y
		cp cES.tab.c bison.c
		cmp -s cES.tab.h tok.h || cp cES.tab.h tok.h 

main.o:		main.cc
		$(CC) $(CFLAGS) -c main.cc -o main.o

lex.o bison.o main.o	: heading.h
lex.o main.o			: tok.h

clean:
	rm -f *.o *~ lex.c lex.yy.c bison.c tok.h cES.tab.c cES.tab.h cES.output cES
