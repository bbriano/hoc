typedef struct Symbol {
	char *name;
	short type; /* VAR, BLTIN, UNDEF */
	union {
		double val; /* if VAR */
		double (*ptr)(); /* if BLTIN */
	} u;
	struct Symbol *next;
} Symbol;

Symbol *lookup(char *);
Symbol *install(char *, int, double);

void execerror(char *, char *);
