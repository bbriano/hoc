%{
#include <stdio.h>
#include <ctype.h>
#include <signal.h>
#include <setjmp.h>

int yylex(void);
void yyerror(char *);
void warning(char *, char *);
void execerror(char *, char *);
void fpecatch();

char *progname;
int lineno = 1;
double mem[26];
jmp_buf begin;
%}

%union {
	double val;
	int index;
}
%token <val> NUMBER
%token <index> VAR
%type <val> expr
%right '='
%left '+' '-'
%left '*' '/' '%'
%left UNARYMINUS
%left UNARYPLUS

%%
list
	: /* nothing */
	| list '\n' { printf("[%d] ", lineno); }
	| list expr ';' { printf("\t%.8g\n", $2); }
	| list expr '\n' { printf("\t%.8g\n[%d] ", $2, ++lineno); }
	| list error '\n' { yyerrok; }
	;

expr
	: NUMBER { $$ = $1; }
	| VAR { $$ = mem[$1]; }
	| VAR '=' expr { $$ = mem[$1] = $3; }
	| expr '+' expr { $$ = $1 + $3; }
	| expr '-' expr { $$ = $1 - $3; }
	| expr '*' expr { $$ = $1 * $3; }
	| expr '/' expr {
		if ($3 == 0.0) {
			execerror("division by zero", "");
		}
		$$ = $1 / $3;
	}
	| expr '%' expr { $$ = (int) $1 % (int) $3; }
	| '(' expr ')' { $$ = $2; }
	| '-' expr %prec UNARYMINUS { $$ = -$2; }
	| '+' expr %prec UNARYPLUS { $$ = $2; }
	;
%%

int main(int argc, char *argv[]) {
	progname = argv[0];
	printf("[1] ");
	setjmp(begin);
	signal(SIGFPE, fpecatch);
	yyparse();
}

int yylex() {
	int c;

	while ((c = getchar()) == ' ' || c == '\t') {
	}
	if (c == EOF) {
		return 0;
	}
	if (c == '.' || isdigit(c)) {
		ungetc(c, stdin);
		scanf("%lf", &yylval.val);
		return NUMBER;
	}
	if (islower(c)) {
		yylval.index = c - 'a';
		return VAR;
	}
	return c;
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
void fpecatch() {
	execerror("floating point exception", NULL);
}
