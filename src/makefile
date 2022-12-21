@:
	lex project.lex
	yacc project.yacc
	yacc -d project.yacc
	gcc -Wall -c lex.yy.c
	gcc -Wall y.tab.c lex.yy.o -lfl -o analyzer
clean:
	rm -f *.c *.h *.o analyzer
