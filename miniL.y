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


struct CodeNode{
  string code;
  string name;
};

int temp_count = 0;
string new_temp(){
  string ret = "_temp" + to_string(temp_count);
  install(ret);
  temp_count++;
  return ret;
}

struct symtable {
  struct CodeNode *code;
  struct symtable *next;
};

/* add symbol to table function*/
symtable* add_symbol(string sym_name){
  symtable *p;
  p = (symtable *) malloc (sizeof(symtable));
  p->name = (string) malloc (strlen(sym_name) + 1);
  strcpy(p->name, sym_name);
  p->next = (struct symtable *)symbol_table;
  symbol_table = p;
  return p;
}

/*lookup symbol table function*/
symtable* lookup(string sym_name){
  symtable *p;
  p = (symtable *) malloc (sizeof(symtable));
  p->name = (string) malloc (strlen(sym_name)+1);
  strcpy(p->name, sym_name);
  p->next = (struct symtable *) symbol_table;
  symbol_table = p;
  return p;
}

/* install symbol into table*/
void install(string sym_name){
  symtable *s;
  s = lookup(sym_name);
  if(s==0){
    s = add_symbol(sym_name);
  }else{
    printf("Error line %d: symbol %s multiply-defined\n", currLine, sym_name);
  }
}

void context_check(string syn_name){
  if(lookup(sym_name) == 0){
    printf("Error line %d: %s is an undeclared identifier \n", currLine, sym_name);
  }
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
               {
                 CodeNode *node = new CodeNode;
                 node->code = "";
                 node->name = $1;
                 string error;
                 if(!find(node->name, NUMBER, error)){
                   yyerror(error.c_str());
                 }
                 $$ = node;
               }


statements-recur: statements statements-recur
                    { }
                |
                  {}


statements: statement SEMICOLON
              {}



statement: var ASSIGN expression
             { 
               string var_name = $1;
               string error;
               if(!find(var_name, NUMBER, error)){
                 yyerror(error.c_str());
               }
               CodeNode *node = new CodeNode;
               node->code = $3->code;
               node->code += string("= ") + var_name + string(", ") + $3->name + string("\n");;
               $$ = node;
             }
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


expression: multiplicative-expr multiplicative-expr-recur {
} 
 

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
	{
    CodeNode *node = new CodeNode;
    node->code = "";
    node->name = $1;
    string error;
    if(!find(node->name, NUMBER, error)){
      yyerror(error.c_str());
    }
    $$ = node;
  }
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

