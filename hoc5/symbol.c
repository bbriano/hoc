#include <stdlib.h>
#include <string.h>
#include "hoc.h"
#include "y.tab.h"

void *emalloc(unsigned);

static Symbol *symlist = NULL; /* symbol table: linked list */

Symbol *lookup(char *s) {
	Symbol *sp;

	for (sp = symlist; sp != NULL; sp = sp->next) {
		if (strcmp(sp->name, s) == 0) {
			return sp;
		}
	}
	return NULL;
}

Symbol *install(char *s, int t, double d) {
	Symbol *sp;

	sp = emalloc(sizeof(Symbol));
	sp->name = emalloc(strlen(s)+1);
	strcpy(sp->name, s);
	sp->type = t;
	sp->u.val = d;
	sp->next = symlist; /* put at front of list */
	symlist = sp;
	return sp;
}

/* Check return from malloc */
void *emalloc(unsigned n) {
	void *p;

	p = malloc(n);
	if (p == NULL) {
		execerror("out of memory", NULL);
	}
	return p;
}
