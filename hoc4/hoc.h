/* symbol table entry */
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

/* interpreter stack type */
typedef union Datum {
	double val;
	Symbol *sym;
} Datum;
Datum pop(void);

/* machine instruction */
typedef void (*Inst)();
#define STOP (Inst) 0

extern Inst prog[];
#undef div
void eval(void), add(void), sub(void), mul(void), divide(void), mod(void), negate(void), power(void);
void assign(void), bltin(void), varpush(void), constpush(void), print(void);

void execerror(char *, char *);
