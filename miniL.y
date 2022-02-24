/* cs152-miniL phase3 */


%{
#include <stdio.h>
#include <stdlib.h>
#include "lib.h"

extern FILE * yyin;
extern int currLine;
extern int currPos;
void yyerror(const char *msg);
extern int yylex();



%}

%union{
  /* put your types here */

  int ival;
  char *sval;
}

%error-verbose
%locations

/* %start program */
%start prog

%token <ival> NUMBER
%token <sval> FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY INTEGER ARRAY OF IF THEN ENDIF ELSE WHILE DO BEGINLOOP ENDLOOP CONTINUE BREAK READ WRITE NOT RETURN SUB PLUS MULT DIV MOD EQ NEQ LT GT LTE GTE SEMICOLON COLON COMMA L_PAREN R_PAREN L_BRACKET R_BRACKET ASSIGN IDENT TRUE FALSE

%% 

  /* write your rules here */
  
prog: functions
        {}


functions: function functions
             {}
         | 
           {}


function: FUNCTION identifiers SEMICOLON params locals body
            {}


params: BEGIN_PARAMS declarations END_PARAMS
          {}


locals: BEGIN_LOCALS declarations END_LOCALS
          {}


body: BEGIN_BODY statements-recur END_BODY
        {}


declarations: declaration SEMICOLON declarations
                {}
            |
              {}


declaration: identifiers COLON INTEGER
               {}
	   | identifiers COLON ARRAY L_BRACKET number R_BRACKET OF INTEGER
	       {}

identifiers: IDENT
               {}


statements-recur: statements statements-recur
                    { }
                |
                  {}


statements: statement SEMICOLON
              {}



statement: var ASSIGN expression
             { }
         | IF bool-exp THEN statements-recur ENDIF
             {}
         | IF bool-exp THEN statements-recur ELSE statements-recur ENDIF
             { }
         | WHILE bool-exp BEGINLOOP statements-recur ENDLOOP
             {}
         | DO BEGINLOOP statements-recur ENDLOOP WHILE bool-exp
             {}
         | READ var
             {}
         | WRITE var
             {}
         | CONTINUE
             {}
         | BREAK
             {}
         | RETURN expression
             {} 


bool-exp: not expression comp expression
		{}


not: NOT not
	{}
     |
	{}

comp:
	 EQ {}
	| NEQ {}
	| LT {}
	| GT {}
	| LTE {}
	| GTE {}


expression: multiplicative-expr multiplicative-expr-recur {} 
 

multiplicative-expr-recur: PLUS multiplicative-expr multiplicative-expr-recur {}
	| SUB multiplicative-expr multiplicative-expr-recur {}
	|
	  {}


multiplicative-expr: term term-recur {}

term-recur:
	MULT term term-recur {}
	| DIV term term-recur {}
	| MOD term term-recur {}
	|
	  {}
	

term:
	 var {}
	| number {}
	| L_PAREN expression R_PAREN {}
	| identifiers L_PAREN expression expression-recur R_PAREN {}


number: NUMBER {}


expression-recur: COMMA expression expression-recur {}
	| 
	  {}



var: identifiers
	{}
	| identifiers L_BRACKET expression R_BRACKET {}

%% 

int main(int argc, char **argv) {
   yyparse();
   return 0;
}

void yyerror(const char *msg) {
    /* implement your error handling */ 
	printf("Error: On line %d, column %d: %s \n", currLine, currPos, msg); 
}
