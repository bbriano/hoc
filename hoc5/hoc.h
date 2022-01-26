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
typedef void (*Inst)(void);
#define STOP (Inst) 0

extern Inst prog[], *progp, *code(Inst);
void eval(void), add(void), sub(void), mul(void), divide(void), mod(void), negate(void), power(void);
void assign(void), bltin(void), varpush(void), constpush(void), print(void), prexpr(void);
void gt(void), lt(void), eq(void), ge(void), le(void), ne(void);
void and(void), or(void), not(void), ifcode(void), whilecode(void);

/* code.c */
void initcode(void);
void execute(Inst *);
Inst *code(Inst);

/* hoc.y */
void execerror(char *, char *);

/* init.c */
void init(void);

/* math.c */
double Pow(double, double);
