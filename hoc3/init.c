#include <math.h>
#include "hoc.h"
#include "y.tab.h"

double Log(), Log10(), Exp(), Sqrt(), integer();

static struct {
	char *name;
	double cval;
} consts[] = {
	"PI", 3.14159265358979323846,
	"E", 2.71828182845904523536,
	"GAMMA", 0.577215664901532087680,
	"DEG", 57.29577951308232087680,
	"PHI", 1.61803398874989484820,
	0, 0,
};

static struct {
	char *name;
	double (*func)();
} builtins[] = {
	"sin", sin,
	"cos", cos,
	"atan", atan,
	"log", Log,
	"log10", Log10,
	"exp", Exp,
	"sqrt", Sqrt,
	"int", integer,
	"abs", fabs,
	0, 0,
};

/* install constants and built-ins in table */
void init() {
	int i;
	Symbol *s;

	for (i = 0; consts[i].name; i++) {
		install(consts[i].name, VAR, consts[i].cval);
	}
	for (i = 0; builtins[i].name; i++) {
		s = install(builtins[i].name, BLTIN, 0.0);
		s->u.ptr = builtins[i].func;
	}
}
