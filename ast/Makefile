CC = gcc -Wall -std=gnu17 -c -o
LD = gcc -o

LIBS = -lfl

all: api.tab.c api_lex.c
	

api.tab.c: api.y
	bison -Wother -Wcounterexamples -d $< -b api

api_lex.c: api.l
	flex -o $@ $<