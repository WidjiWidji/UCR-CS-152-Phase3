/* cs152-miniL phase3 */

%{
#define YY_NO_UNPUT
#include <stdio.h>
#include <stdlib.h>
#include "lib.h"
#include <string.h>
#include <iostream>
#include <sstream>
#include <stdlib.h>
#include <unordered_set>
#include <vector>

using namespace std;

extern FILE * yyin;
extern int currLine;
extern int currPos;
void yyerror(const char *msg);
extern int yylex();
unordered_set<string> pdFunctions;
string new_label();
string new_temp();

enum Type { Integer, Array };
struct Symbol{
  string code;
  string name;
  Type type;
};

struct Function {
  string name;
  vector<Symbol> declarations;
};

vector <Function> symbol_table;

// char* dec_temp_code(char *s){
//   return ". " + *s + "\n";
// }

// char* dec_label_code(char *s){
//   return ": " + *s + "\n";
// }

Function *get_function() {
  int last = symbol_table.size()-1;
  return &symbol_table[last];
}

bool find(char* &value,string &error) {
  Function *f = get_function();
  if(f){
    for(int i=0; i < f->declarations.size(); i++) {
    Symbol *s = &f->declarations[i];
    if (s->name == value) {
      return true;
    }
  }
  return false;
  }
  error = "get function error";
  return false;
}

void add_function_to_symbol_table(char* &value) {
  Function f; 
  f.name = value; 
  symbol_table.push_back(f);
}

void add_variable_to_symbol_table(char* &value, char* &code) {
  Symbol s;
  s.name = value;
  s.code = code;
  Function *f = get_function();
  f->declarations.push_back(s);
}

void print_symbol_table(void) {
  printf("Symbol table:\n");
  printf("--------------------\n");
  for(int i=0; i<symbol_table.size(); i++) {
    printf("function: %s\n", symbol_table[i].name.c_str());
    for(int j=0; j<symbol_table[i].declarations.size(); j++) {
      printf("  locals: %s\n", symbol_table[i].declarations[j].name.c_str());
    }
  }
  printf("--------------------\n");
} 

%}

%union{
  /* put your types here */

  int ival;
  char *sval;

  struct Symbol{
    char* code;
    char* name;
    char* params;
} nonterminal;
}

%error-verbose
%locations

/* %start program */
%start prog
%token FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY INTEGER ARRAY OF IF THEN ENDIF ELSE WHILE DO BEGINLOOP ENDLOOP CONTINUE BREAK READ WRITE NOT RETURN SUB PLUS MULT DIV MOD EQ NEQ LT GT LTE GTE SEMICOLON COLON COMMA L_PAREN R_PAREN L_BRACKET R_BRACKET ASSIGN TRUE FALSE
%token <ival> NUMBER
%token <sval> IDENT
%left ASSIGN EQ NEQ LT LTE GT GTE ADD SUB MULT DIV MOD
%right NOT

%type <nonterminal> functions function declarations declaration identifiers var number
%type <nonterminal> bool-exp comp multiplicative-expr term
%type <nonterminal> statement statements statements-recur not
%type <nonterminal> params expression expressions

%% 

  /* write your rules here */
  
prog: functions
        { //printf("prog -> functions\n"); 
        }


functions: function functions
             { //printf ("functions -> function functions\n");
             stringstream ss;
             ss << $1.code << $2.code;
             string temp = ss.str();
             char* code = const_cast<char*>(temp.c_str());
             string error;
             if(!find(code, error)){
               yyerror(error.c_str());
             }
              $$.code = code;
              $$.name = (char*)"";

             }
         | 
           { //printf("functions -> epsilon\n"); 
           $$.code = (char*)"";
           $$.name = (char*)"";
           }


function: FUNCTION identifiers SEMICOLON params locals body
            {
              stringstream ss;
              ss << "func ";
              char* func_name = $2.name;
              string error;
              if(find(func_name,error)){
                ss << "\nError: function identifier already in use \n";
              }else{
                add_function_to_symbol_table(func_name);
                ss << func_name << "\n"; 
              }
            }


params: BEGIN_PARAMS declarations END_PARAMS
          { 
            stringstream ss;
            ss << $2.code;
            int count = 0;
            string id;
            if($2.params != NULL){
              string s = $2.params;
              stringstream idents(s);
              while(idents >> id){
                ss << "= " << id << ", $" << count << "\n";
                count++;
              }
            }
            ss << "endfunc" << "\n";
            string temp = ss.str();
            $$.code = strdup(temp.c_str());
            $$.name = (char*)"";
          }


locals: BEGIN_LOCALS declarations END_LOCALS
          { //printf("locals -> BEGIN_LOCALS declarations END_LOCALS\n"); 
          }


body: BEGIN_BODY statements-recur END_BODY
        { 
          //printf("body -> BEGIN_BODY statements END_BODY\n"); 
          }


declarations: declaration SEMICOLON declarations
                { 
                  stringstream ss;
                  ss << $1.code << $3.code;
                  string temp = ss.str();
                  $$.code = strdup(temp.c_str());
                  $$.name = (char*)"";
                }
            |
              { 
                $$.code = (char*)"";
                $$.name = (char*)"";
               }


declaration: identifiers COLON INTEGER
               { 
                 stringstream ss;
                 string ident;
                 string sIdents = $1.name;
                 stringstream idents(sIdents);
                 while(idents >> ident){
                   ss << ". " << ident << "\n";
                   char* value = const_cast<char*>(ident.c_str());
                   char* code = $1.code;
                   add_variable_to_symbol_table(value, code);
                 }
                 string temp = ss.str();
                 $$.code = strdup(temp.c_str());
                 $$.params = $1.name;
                 $$.name = (char*)"";
               }
	   | identifiers COLON ARRAY L_BRACKET number R_BRACKET OF INTEGER
	       { 
           stringstream ss;
           string s;
           string temp = $1.code;
           stringstream idents(temp);
           while(idents >> s){
             ss << ".[]" << s << ", " << $5.name << "\n";
           }
           char* code = const_cast<char*>(ss.str().c_str());
           char* name = (char*)"";
           string error;
           if(find(code, error)){
             ss << "\nError: var identifier already in use \n";
           }else{
             add_variable_to_symbol_table(code,name);
           }
           $$.code = code;
           $$.name = name;
          }

identifiers: IDENT
               { 
                 $$.name = (char*)$1;
                 $$.code = (char*)"";
               }


statements-recur: statements statements-recur
                    { //printf("statements-recur -> statements statements-recur\n"); 
                    }
                |
                  { //printf("statements-recur -> epsilon\n"); 
                  }


statements: statement SEMICOLON
              { //printf("statements -> statement SEMICOLON\n"); 
              }



statement: var ASSIGN expression
             { 
               stringstream ss;
               ss << $1.code;
               ss << $3.code;
               ss << "= " << $1.name << ", " << $3.name << "\n";
             }
         | IF bool-exp THEN statements-recur ENDIF
             { 
               string l0 = new_label();
               string l1 = new_label();
               stringstream ss;
               ss << $2.code;
               ss << "?:= " << l0 << $2.name << "\n";
               ss << ":= " << l1;
               ss << ": " << l0;
               ss << $4.code;
               ss << ": " << l1;
               $$.code = const_cast<char*>(ss.str().c_str());
               $$.name = (char*) "";
               }
         | IF bool-exp THEN statements-recur ELSE statements-recur ENDIF
             { 
               string l0 = new_label();
               string l1 = new_label();
               string l2 = new_label();
               stringstream ss;
               ss << $2.code;
               ss << "?:= " << l0 << ", " << $2.name << "\n";
               ss << ":=  " << l1;
               ss << ": " << l0;
               ss << $4.code;
               ss << ":= " << l2;
               ss << ": " << l1;
               ss << $6.code;
               ss << ": " << l2;
               $$.code = const_cast<char*>(ss.str().c_str());
               }
         | WHILE bool-exp BEGINLOOP statements-recur ENDLOOP
             { //printf("statement -> WHILE bool-exp BEGINLOOP  statements-recur ENDLOOP\n"); 
             }
         | DO BEGINLOOP statements-recur ENDLOOP WHILE bool-exp
             { //printf("statement -> DO BEGINLOOP statements-recur ENDLOOP WHILE bool-exp\n"); 
             }
         | READ var
             { //printf("statement -> READ var\n"); 
             }
         | WRITE var
             { //printf("statement -> WRITE var\n"); 
             }
         | CONTINUE
             { //printf("statement -> CONTINUE\n"); 
             }
         | BREAK
             { //printf("statement -> BREAK\n"); 
             }
         | RETURN expression
             { //printf("statement -> RETURN expression\n");
             } 


bool-exp: not expression comp expression
		{ //printf("bool-exp -> not expression comp expression\n"); 
    }


not: NOT not
	{
    string temp = new_temp();
    stringstream ss;
    ss << "! " << temp  << ", ";
    $$.code = const_cast<char*>(ss.str().c_str());
    $$.name = (char*) "! ";
  }
     |
	{
    $$.code = (char*)"";
    $$.name = (char*)"";
  }

comp:
	 EQ {
     $$.name = (char*) "== ";
     $$.code = (char*)"";
     }
	| NEQ {
    $$.name = (char*) "!= ";
    $$.code = (char*) "";
    }
	| LT {
    $$.name = (char*) "< ";
    $$.code = (char*) "";
    }
	| GT {
    $$.name = (char*) "> ";
    $$.code = (char*) "";
    }
	| LTE {
    $$.name = (char*) "<= ";
    $$.code = (char*) "";
    }
	| GTE {
    $$.name = (char*) ">= ";
    $$.code = (char*)"";
    }


expression: multiplicative-expr {
  $$.code = (char*) $1.code;
  $$.name = (char*) $1.name;
  } 
  | multiplicative-expr PLUS expression {
    string temp = new_temp();
    stringstream ss;
    ss << $1.code << $3.code;
    ss << ". " << temp << "\n";
    ss << "+ " << temp << ", " << $1.name << ", " << $3.name;
    $$.code = const_cast<char*>(ss.str().c_str());
    $$.name = const_cast<char*>(temp.c_str());
  }
  | multiplicative-expr SUB expression {
    string temp = new_temp();
    stringstream ss;
    ss << $1.code << $3.code;
    ss << ". " << temp << "\n";
    ss << "- " << temp << ", " << $1.name << ", " << $3.name;
    $$.code = const_cast<char*>(ss.str().c_str());
    $$.name = const_cast<char*>(temp.c_str());
  }
  | 
  {
    $$.code = (char*) "";
    $$.name = (char*) "";
  }

multiplicative-expr: term{
  $$.code = $1.code;
  $$.name = $1.name;
}
| term MULT term {
  string temp = new_temp();
  stringstream ss;
  ss << $1.code << $3.code;
  ss << ". " << temp << $3.code;
  ss << "* " << temp << ", " << $1.name << ", " << $3.name << "\n";
  $$.code = const_cast<char*>(ss.str().c_str());
  $$.name = const_cast<char*>(temp.c_str());
}
| term DIV term {
  string temp = new_temp();
  stringstream ss;
  ss << $1.code << $3.code;
  ss << ". " << temp << "\n";
  ss << "/ " << temp << ", " << $1.name << ", " << $3.name << "\n";
  $$.code = const_cast<char*>(ss.str().c_str());
  $$.name = const_cast<char*>(temp.c_str());
}
| term MOD term {
  string temp = new_temp();
  stringstream ss;
  ss << $1.code << $3.code;
  ss << ". " << temp << "\n";
  ss << "% " << temp << ", " << $1.name << ", " << $3.name << "\n";
  $$.code = const_cast<char*>(ss.str().c_str());
  $$.name = const_cast<char*>(temp.c_str());
}

term:
	 var { //printf("term -> var\n"); 
   }
	| number {
    stringstream ss;
    ss << $1.name;
    $$.name = const_cast<char*>(ss.str().c_str());
    $$.code =(char*) "";
  }
	| L_PAREN expression R_PAREN {
    }
	| identifiers L_PAREN expressions R_PAREN {
    string temp = new_temp();
    stringstream ss;
    ss << $3.code;
    ss << ". " << temp << "\n";

    }


number: NUMBER {
    $$.name = (char*)$1;
    $$.code = (char*)"";
  }


expressions: expression COMMA expressions {
  stringstream ss;
  ss << $1.code << "param " << $1.name << "\n";
  ss << $3.code;

  $$.code = const_cast<char*>(ss.str().c_str());
  $$.name = (char*)"";
}
| expression {
  stringstream ss;
  ss << $1.code  << "param " << $1.name << "\n";
  $$.code = const_cast<char*>(ss.str().c_str());
  $$.name = (char*)"";
}
// expression-recur: COMMA expression expression-recur {
//   printf("expression-recur -> COMMA expression expression-recur\n");
//   }
// 	| 
// 	  {printf("expression-recur -> epsilon\n");}



var: identifiers
	{
    char* code = (char*)"";
    char* name = $1.name;
    string error;
    if(!find(name, error)){
      add_variable_to_symbol_table(name, code);
    }
    $$.code = code;
    $$.name = name;
  }
	| identifiers L_BRACKET expression R_BRACKET {
    stringstream ss;
    ss << $3.code;
    ss << $1.name;
    }

%% 
string new_temp(){
  static int num = 0;
  return "_temp" + to_string(num++);
}

string new_label(){
  static int num = 0;
  return "_label" + to_string(num++);
}

int main(int argc, char **argv) {
   yyparse();
   print_symbol_table();
   return 0;
}

void yyerror(const char *msg) {
    /* implement your error handling */ 
	printf("Error: On line %d, column %d: %s \n", currLine, currPos, msg); 
}

