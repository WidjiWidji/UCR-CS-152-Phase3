/* cs152-miniL phase3 */


%{
#include <stdio.h>
#include <stdlib.h>
#include "lib.h"
#include <string>

using namespace std;

extern FILE * yyin;
extern int currLine;
extern int currPos;
void yyerror(const char *msg);
extern int yylex();

char *ident_token;
int number_token;
int count = 0;

enum Type {Integer, Array};
struct Symbol{
  string name;
  Type type;
}
struct Function{
  string name;
  vector<Symbol> declarations;
}

vector <Function> symbol_table;


Function *get_function() {
  int last = symbol_table.size()-1;
  return &symbol_table[last];
}

bool find(string &value) {
  Function *f = get_function();
  for(int i=0; i < f->declarations.size(); i++) {
    Symbol *s = &f->declarations[i];
    if (s->name == value) {
      return true;
    }
  }
  return false;
}

void add_function_to_symbol_table(string &value) {
  Function f; 
  f.name = value; 
  symbol_table.push_back(f);
}

void add_variable_to_symbol_table(string &value, Type t) {
  Symbol s;
  s.name = value;
  s.type = t;
  Function *f = get_function();
  f->declarations.push_back(s);
}

void print_symbol_table(void) {
  printf("symbol table:\n");
  printf("--------------------\n");
  for(int i=0; i<symbol_table.size(); i++) {
    printf("function: %s\n", symbol_table[i].name.c_str());
    for(int j=0; j<symbol_table[i].declarations.size(); j++) {
      printf("  locals: %s\n", symbol_table[i].declarations[j].name.c_str());
    }
  }
  printf("--------------------\n");
}

int temp_count = 0;
int begin_count = 0;
int end_count = 0;
int body_count = 0;

string new_temp(){
  temp_count++;
  return "_temp" + to_string(temp_count);
}

string new_begin(){
  begin_count++;
  return "beginloop" + to_string(begin_count);
}

string new_end(){
  end_count++;
  return "endloop" + to_string(end_count);
}

string new_body(){
  body_count++;
  return "loopbody" + to_string(body_count);
}

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
        { printf("prog -> functions\n"); }


functions: function functions
             { printf ("functions -> function functions\n"); }
         | 
           { printf("functions -> epsilon\n"); }


function: FUNCTION identifiers SEMICOLON params locals body
            { printf("function -> FUNCTION identifiers SEMICOLON params locals body\n"); }


params: BEGIN_PARAMS declarations END_PARAMS
          { printf("params -> BEGIN_PARAMS declarations END_PARAMS\n"); }


locals: BEGIN_LOCALS declarations END_LOCALS
          { printf("locals -> BEGIN_LOCALS declarations END_LOCALS\n"); }


body: BEGIN_BODY statements-recur END_BODY
        { printf("body -> BEGIN_BODY statements END_BODY\n"); }


declarations: declaration SEMICOLON declarations
                { printf("declarations -> declaration SEMICOLON declarations\n"); }
            |
              { printf("declarations -> epsilon\n"); }


declaration: identifiers COLON INTEGER
               { 
                 printf("declaration -> identifiers COLON INTEGER\n"); 
                 string value = $1;
                 Type t = Integer;
                 add_variable_to_symbol_table(value, t);
                 out
               }
	   | identifiers COLON ARRAY L_BRACKET number R_BRACKET OF INTEGER
	       { printf("declaration -> identifiers COLON ARRAY L_BRACKET number R_BRACKET OF INTEGER\n"); }

identifiers: IDENT
               { 
                 printf("identifiers -> IDENT %s\n", $1); 
                 $$ = $1;
               }


statements-recur: statements statements-recur
                    { printf("statements-recur -> statements statements-recur\n"); }
                |
                  { printf("statements-recur -> epsilon\n"); }


statements: statement SEMICOLON
              { printf("statements -> statement SEMICOLON\n"); }



statement: var ASSIGN expression
             { printf("statement -> var ASSIGN expression\n"); }
         | IF bool-exp THEN statements-recur ENDIF
             { printf("statement -> IF bool-exp THEN statements-recur ENDIF\n"); }
         | IF bool-exp THEN statements-recur ELSE statements-recur ENDIF
             { printf("statement -> IF bool-exp THEN statements-recur ELSE statements-recur ENDIF\n"); }
         | WHILE bool-exp BEGINLOOP statements-recur ENDLOOP
             { printf("statement -> WHILE bool-exp BEGINLOOP  statements-recur ENDLOOP\n"); }
         | DO BEGINLOOP statements-recur ENDLOOP WHILE bool-exp
             { printf("statement -> DO BEGINLOOP statements-recur ENDLOOP WHILE bool-exp\n"); }
         | READ var
             { printf("statement -> READ var\n"); }
         | WRITE var
             { printf("statement -> WRITE var\n"); }
         | CONTINUE
             { printf("statement -> CONTINUE\n"); }
         | BREAK
             { printf("statement -> BREAK\n"); }
         | RETURN expression
             { printf("statement -> RETURN expression\n");} 


bool-exp: not expression comp expression
		{printf("bool-exp -> not expression comp expression\n");}


not: NOT not
	{printf("not -> NOT not\n");}
     |
	{printf("not -> epsilon\n");}

comp:
	 EQ {printf("comp -> EQ\n");}
	| NEQ {printf("comp -> NEQ\n");}
	| LT {printf("comp -> LT\n");}
	| GT {printf("comp -> GT\n");}
	| LTE {printf("comp -> LTE\n");}
	| GTE {printf("comp -> GTE\n");}


expression: multiplicative-expr multiplicative-expr-recur {printf("expression -> multiplicative-expr multiplicative-expr-recur\n");} 
 

multiplicative-expr-recur: PLUS multiplicative-expr multiplicative-expr-recur {printf("multiplicative-expr-recur -> PLUS multiplicative-expr multiplicative-expr-recur\n");}
	| SUB multiplicative-expr multiplicative-expr-recur {printf("multiplicative-expr-recur -> SUB  multiplicative-expr multiplicative-expr-recur\n");}
	|
	  {printf("multiplicative-expr-recur -> epsilon\n");}


multiplicative-expr: term term-recur {printf("multiplicative-expr -> term term-recur\n");}

term-recur:
	MULT term term-recur {printf("term-recur -> MULT term term-recur\n");}
	| DIV term term-recur {printf("term-recur -> DIV term term-recur\n");}
	| MOD term term-recur {printf("term-recur -> MOD term term-recur\n");}
	|
	  {printf("term-recur -> epsilon\n");}
	

term:
	 var {printf("term -> var\n");}
	| number {printf("term -> number\n");}
	| L_PAREN expression R_PAREN {printf("term -> L_PAREN expression R_PAREN\n");}
	| identifiers L_PAREN parameters R_PAREN {printf("term-> identifiers L_PAREN expression expression-recur R_PAREN\n");}


parameters: expression expression-recur {printf("parameters -> expression expression-recur\n");}
	| 
          {printf("parameters -> epsilon\n");}



number: NUMBER {
  printf("number -> NUMBER %d\n", $1);
  $$ = $1;
  }


expression-recur: COMMA expression expression-recur {printf("expression-recur -> COMMA expression expression-recur\n");}
	| 
	  {printf("expression-recur -> epsilon\n");}



var: identifiers
	{printf("var ->  identifiers\n");}
	| identifiers L_BRACKET expression R_BRACKET {printf("var -> identifiers L_BRACKET expression R_BRACKET\n");}

%% 

int main(int argc, char **argv) {
   yyparse();
   print_symbol_table();
   return 0;
}

void yyerror(const char *msg) {
    /* implement your error handling */ 
	printf("Error: On line %d, column %d: %s \n", currLine, currPos, msg); 
}

