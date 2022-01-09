%{
#include <stdio.h>
#include <ctype.h>

#define YYSTYPE double /* data type of yacc stack */

int yylex(void);
void yyerror(char *);
void warning(char *, char *);
%}

%token NUMBER
%left '+' '-'
%left '*' '/' '%'
%left UNARYMINUS
%left UNARYPLUS

%%
list
	: /* nothing */
	| list '\n'
	| list expr '\n' { printf("\t%.8g\n", $2); }
	;

expr
	: NUMBER { $$ = $1; }
	| '-' expr %prec UNARYMINUS { $$ = -$2; }
	| '+' expr %prec UNARYPLUS { $$ = $2; }
	| expr '+' expr { $$ = $1 + $3; }
	| expr '-' expr { $$ = $1 - $3; }
	| expr '*' expr { $$ = $1 * $3; }
	| expr '/' expr { $$ = $1 / $3; }
	| expr '%' expr { $$ = (int) $1 % (int) $3; }
	| '(' expr ')' { $$ = $2; }
	;
%%

char *progname;
int lineno = 1;

int main(int argc, char *argv[]) {
	progname = argv[0];
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
		scanf("%lf", &yylval);
		return NUMBER;
	}
	if (c == '\n') {
		lineno++;
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
