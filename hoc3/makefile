YFLAGS = -d # force creation of y.tab.h
OBJS = hoc.o init.o math.o symbol.o lex.o

hoc: $(OBJS)
	cc $(OBJS) -lm -ll -o hoc

hoc.o math.o: hoc.h
init.o symbol.o lex.o: hoc.h y.tab.h

y.tab.h y.tab.c: hoc.y
	yacc $(YFLAGS) hoc.y

clean:
	rm -rf $(OBJS) y.tab.[ch] hoc
