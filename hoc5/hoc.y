%{
#include <stdio.h>
#include <ctype.h>
#include <signal.h>
#include <setjmp.h>
#include "hoc.h"

#define code2(c1, c2) code(c1); code(c2)
#define code3(c1, c2, c3) code(c1); code(c2); code(c3)

int yylex(void);
void yyerror(char *);
void warning(char *, char *);
void fpecatch(int);
follow(int expect, int ifyes, int ifno);

char *progname;
int lineno = 1;
jmp_buf begin;
%}

%union {
	Symbol *sym; /* symbol table pointer */
	Inst *inst; /* machine instruction */
}

%token <sym> NUMBER VAR BLTIN UNDEF PRINT WHILE IF ELSE
%type <inst> stmt asgn expr stmtlist cond while if end
%right '='
%left OR
%left AND
%left GT GE LT LE EQ NE
%left '+' '-'
%left '*' '/' '%'
%left NOT
%left UNARYMINUS
%left UNARYPLUS
%right '^'

%%
list
	: /* nothing */
	| list '\n'
	| list asgn '\n' { code2((Inst)pop, STOP); return 1; }
	| list stmt '\n' { code(STOP); return 1; }
	| list expr '\n' { code2(print, STOP); return 1; }
	| list error '\n' { yyerrok; }
	;

asgn
	: VAR '=' expr { $$ = $3; code3(varpush, (Inst) $1, assign); }
	;

stmt
	: expr { code(pop); }
	| PRINT expr { code(prexpr); $$ = $2; }
	| while cond stmt end { 
		($1)[1] = (Inst)$3;
		($1)[2] = (Inst)$4;
	}
	| if cond stmt end {
		($1)[1] = (Inst)$3;
		($1)[3] = (Inst)$4;
	}
	| if cond stmt end ELSE stmt end {
		($1)[1] = (Inst)$3;
		($1)[2] = (Inst)$6;
		($1)[3] = (Inst)$7;
	}
	| '{' stmtlist '}' { $$ = $2; }

cond
	: '(' expr ')' { code(STOP); $$ = $2; }
	;

while
	: WHILE { $$ = code3(whilecode, STOP, STOP); }
	;

if
	: IF { $$ = code(ifcode); code3(STOP, STOP, STOP); }
	;

end
	: /* nothing */ { code(STOP); $$ = progp; }
	;

stmtlist
	: /* nothing */ { $$ = progp; }
	| stmtlist '\n'
	| stmtlist stmt
	;

expr
	: NUMBER { code2(constpush, (Inst) $1); }
	| VAR { code3(varpush, (Inst) $1, eval); }
	| asgn
	| BLTIN '(' expr ')' { code2(bltin, (Inst) $1->u.ptr); }
	| '(' expr ')' { $$ = $2; }
	| expr '+' expr { code(add); }
	| expr '-' expr { code(sub); }
	| expr '*' expr { code(mul); }
	| expr '/' expr { code(divide); }
	| expr '^' expr { code(power); }
	| expr '%' expr { code(mod); }
	| '-' expr %prec UNARYMINUS { $$ = $2; code(negate); }
	| '+' expr %prec UNARYPLUS { $$ = $2; }
	| expr GT expr { code(gt); }
	| expr GE expr { code(ge); }
	| expr LT expr { code(lt); }
	| expr LE expr { code(le); }
	| expr EQ expr { code(eq); }
	| expr NE expr { code(ne); }
	| expr AND expr { code(and); }
	| expr OR expr { code(or); }
	| NOT expr { $$ = $2; code(not); }
	;
%%

int main(int argc, char *argv[]) {
	progname = argv[0];
	init();
	setjmp(begin);
	signal(SIGFPE, fpecatch);
	for (initcode(); yyparse(); initcode()) {
		execute(prog);
	}
}

int yylex() {
	int c;

	while ((c = getchar()) == ' ' || c == '\t') {
	}
	if (c == EOF) {
		return 0;
	}
	if (c == '.' || isdigit(c)) {
		double d;
		ungetc(c, stdin);
		scanf("%lf", &d);
		yylval.sym = install("", NUMBER, d);
		return NUMBER;
	}
	if (isalpha(c)) {
		Symbol *s;
		char sbuf[100], *p = sbuf;
		do {
			*p++ = c;
		} while ((c = getchar()) != EOF && isalnum(c));
		ungetc(c, stdin);
		*p = '\0';
		if ((s = lookup(sbuf)) == NULL) {
			s = install(sbuf, UNDEF, 0.0);
		}
		yylval.sym = s;
		return s->type == UNDEF ? VAR : s->type;
	}
	switch (c) {
	case '>': return follow('=', GE, GT);
	case '<': return follow('=', LE, LT);
	case '=': return follow('=', EQ, '=');
	case '!': return follow('=', NE, NOT);
	case '|': return follow('|', OR, '|');
	case '&': return follow('&', AND, '&');
	}
	return c;
}

/* look ahead for >=, etc. */
follow(int expect, int ifyes, int ifno) {
	int c = getchar();
	if (c == expect) {
		return ifyes;
	}
	ungetc(c, stdin);
	return ifno;
}

/* yyerror is called for yacc syntax error */
void yyerror(char *s) {
	warning(s, NULL);
}

void warning(char *s, char *t) {
	fprintf(stderr, "%s: %s", progname, s);
	if (t) {
		fprintf(stderr, " %s", t);
	}
	fprintf(stderr, " near line %d\n", lineno);
}

void execerror(char *s, char *t) {
	warning(s, t);
	longjmp(begin, 0);
}

/* catch floating point exceptions */
void fpecatch(int signum) {
	execerror("floating point exception", NULL);
}
