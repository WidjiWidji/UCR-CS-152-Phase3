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

%union {
  // int int_val;
  int ival;
  char *sval;
}

%error-verbose

%token <ival> NUMBER
%token <sval> FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY INTEGER ARRAY OF IF THEN ENDIF ELSE WHILE DO BEGINLOOP ENDLOOP CONTINUE BREAK READ WRITE NOT RETURN SUB PLUS MULT DIV MOD EQ NEQ LT GT LTE GTE SEMICOLON COLON COMMA L_PAREN R_PAREN L_BRACKET R_BRACKET ASSIGN IDENT TRUE FALSE


%% 

  /* write your rules here */
program: DIGIT {}

%% 

int main(int argc, char **argv) {
   yyparse();
   return 0;
}

void yyerror(const char *msg) {
    /* implement your error handling */
}