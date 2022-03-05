/* cs152-miniL phase3 */

%{
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



%}

%union{
  /* put your types here */

  int ival;
  char *sval;

  struct {
    char* code;
    char* ret_name;
    char* var_name;
    char* paramVal;
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
          cout << $1.code;
        }


functions: function functions
             { //printf ("functions -> function functions\n"); 
                stringstream ss;
                ss << $1.code << $2.code;
                string temp = ss.str();
                $$.code = strdup(temp.c_str());
                $$.ret_name = (char*)"";
             }
         | 
           { //printf("functions -> epsilon\n"); 
              $$.code = (char*)"";
              $$.ret_name = (char*)"";
           }


function: FUNCTION identifiers SEMICOLON params locals body
            { //printf("function -> FUNCTION identifiers SEMICOLON params locals body\n");
              stringstream ss;
              ss << "func ";
              if(pdFunctions.find($2.ret_name) != pdFunctions.end()){
                ss << "\nError: function identifier already in use\n";
              }else{
                pdFunctions.insert($2.ret_name);
                ss << $2.ret_name << "\n";
              }
            }


params: BEGIN_PARAMS declarations END_PARAMS
          { 
            //printf("params -> BEGIN_PARAMS declarations END_PARAMS\n"); 
            stringstream ss;
            ss << $2.code;
            int count = 0;
            string id;
            if($2.paramVal != NULL){
              string s = $2.paramVal;
              stringstream idents(s);
              while(idents >> id){
                ss << "= " << id << ", $" << count << "\n";
                count++;
              }
            }
            ss << "endfunc" << "\n";
            string temp = ss.str();
            $$.code = strdup(temp.c_str());
            $$.ret_name = (char*)"";
          }


locals: BEGIN_LOCALS declarations END_LOCALS
          { //printf("locals -> BEGIN_LOCALS declarations END_LOCALS\n"); }


body: BEGIN_BODY statements-recur END_BODY
        { 
          //printf("body -> BEGIN_BODY statements END_BODY\n"); 
          }


declarations: declaration SEMICOLON declarations
                { 
                  //printf("declarations -> declaration SEMICOLON declarations\n"); 
                  stringstream ss;
                  ss << $1.code << $3.code;
                  string temp = ss.str();
                  $$.code = strdup(temp.c_str());
                  $$.ret_name = (char*)"";
                }
            |
              { 
                //printf("declarations -> epsilon\n");
                $$.code = (char*)"";
                $$.ret_name = (char*)"";
               }


declaration: identifiers COLON INTEGER
               { 
                 //printf("declaration -> identifiers COLON INTEGER\n"); 
                 stringstream ss;
                 string ident;
                 string sIdents = $1.ret_name;
                 stringstream idents(sIdents);
                 while(idents >> ident){
                   ss << ". " << ident << "\n";
                 }
                 string temp = ss.str();
                 $$.code = strdup(temp.c_str());
                 $$.paramVal = $1.ret_name;
                 $$.ret_name = (char*)"";
               }
	   | identifiers COLON ARRAY L_BRACKET number R_BRACKET OF INTEGER
	       { 
           //printf("declaration -> identifiers COLON ARRAY L_BRACKET number R_BRACKET OF INTEGER\n"); 
           stringstream ss;
           string s;
           string temp = $1.code;
           stringstream idents(temp);
           while(idents >> s){
             ss << ".[]" << s << ", " << $5.ret_name << "\n";
           }
           $$.code = const_cast<char*>(ss.str().c_str());
           $$.ret_name = (char*)"";
          }

identifiers: IDENT
               { 
                 //printf("identifiers -> IDENT %s\n", $1); 
                 $$.code = (char*)"";
                 $$.ret_name = $1;
               }


statements-recur: statements statements-recur
                    { //printf("statements-recur -> statements statements-recur\n"); }
                |
                  { //printf("statements-recur -> epsilon\n"); }


statements: statement SEMICOLON
              { //printf("statements -> statement SEMICOLON\n"); }



statement: var ASSIGN expression
             { 
               //printf("statement -> var ASSIGN expression\n"); 
               stringstream ss;
               ss << $1.code;
               ss << $3.code;
               ss << "= " << $1.ret_name << ", " << $3.ret_name << "\n";
             }
         | IF bool-exp THEN statements-recur ENDIF
             { 
               //printf("statement -> IF bool-exp THEN statements-recur ENDIF\n"); 
               string l0 = new_label();
               string l1 = new_label();
               stringstream ss;
               ss << $2.code;
               ss << "?:= " << l0 << $2.ret_name << "\n";
               ss << ":= " << l1;
               ss << ": " << l0;
               ss << $4.code;
               ss << ": " << l1;
               $$.code = const_cast<char*>(ss.str().c_str());
               $$.ret_name = (char*) "";
               }
         | IF bool-exp THEN statements-recur ELSE statements-recur ENDIF
             { 
               //printf("statement -> IF bool-exp THEN statements-recur ELSE statements-recur ENDIF\n"); 
               string l0 = new_label();
               string l1 = new_label();
               string l2 = new_label();
               stringstream ss;
               ss << $2.code;
               ss << "?:= " << l0 << ", " << $2.ret_name << "\n";
               ss << ":= " << l1;
               ss << ": " << l0;
               ss << $4.code;
               ss << ":= " << l2;
               ss << ": " << l1;
               ss << $6.code;
               ss << ": " << l2;
               $$.code = const_cast<char*>(ss.str().c_str());
               }
         | WHILE bool-exp BEGINLOOP statements-recur ENDLOOP
             { //printf("statement -> WHILE bool-exp BEGINLOOP  statements-recur ENDLOOP\n"); }
         | DO BEGINLOOP statements-recur ENDLOOP WHILE bool-exp
             { //printf("statement -> DO BEGINLOOP statements-recur ENDLOOP WHILE bool-exp\n"); }
         | READ var
             { //printf("statement -> READ var\n"); }
         | WRITE var
             { //printf("statement -> WRITE var\n"); }
         | CONTINUE
             { //printf("statement -> CONTINUE\n"); }
         | BREAK
             { //printf("statement -> BREAK\n"); }
         | RETURN expression
             { //printf("statement -> RETURN expression\n");} 


bool-exp: not expression comp expression
		{ //printf("bool-exp -> not expression comp expression\n"); }


not: NOT not
	{
    //printf("not -> NOT not\n");
    string temp = new_temp();
    stringstream ss;
    ss << "! " << temp << ", ";
    $$.code = const_cast<char*>(ss.str().c_str());
    $$.ret_name = (char*) "! ";
  }
     |
	{
    //printf("not -> epsilon\n");
    $$.code = (char*)"";
    $$.ret_name = (char*)"";
  }

comp:
	 EQ {
     //printf("comp -> EQ\n");
     $$.ret_name = (char*)"== ";
     $$.code = (char*)"";
     }
	| NEQ {
    //printf("comp -> NEQ\n");
    $$.ret_name = (char*)"!= ";
    $$.code = (char*)"";
    }
	| LT {
    //printf("comp -> LT\n");
    $$.ret_name = (char*) "< ";
    $$.code = (char*) "";
    }
	| GT {
    //printf("comp -> GT\n");
    $$.ret_name = (char*) "> ";
    $$.code = (char*) "";
    }
	| LTE {
    //printf("comp -> LTE\n");
    $$.ret_name = (char*) "<= ";
    $$.code = (char*)"";
    }
	| GTE {
    //printf("comp -> GTE\n");
    $$.ret_name = (char*) ">= ";
    $$.code = (char*)"";
    }


expression: multiplicative-expr {
  //printf("expression -> multiplicative-expr multiplicative-expr-recur\n");
  $$.code = (char*) $1.code;
  $$.ret_name = (char*) $1.ret_name;
  } 
  | multiplicative-expr PLUS expression {
    string temp = new_temp();
    stringstream ss;
    ss << $1.code << $3.code;
    ss << ". " << temp << "\n";
    ss << "+ " << temp << ", " << $1.ret_name << ", " << $3.ret_name;
    $$.code = const_cast<char*>(ss.str().c_str());
    $$.ret_name = const_cast<char*>(temp.c_str());
  }
  | multiplicative-expr SUB expression {
    string temp = new_temp();
    stringstream ss;
    ss << $1.code << $3.code;
    ss << ". " << temp << "\n";
    ss << "- " << temp << ", " << $1.ret_name << ", " << $3.ret_name;
    $$.code = const_cast<char*>(ss.str().c_str());
    $$.ret_name = const_cast<char*>(temp.c_str());
  }
  | 
  {
    $$.code = (char*) "";
    $$.ret_name = (char*) "";
  }
 
/*
// multiplicative-expr-recur: PLUS multiplicative-expr multiplicative-expr-recur {
//   printf("multiplicative-expr-recur -> PLUS multiplicative-expr multiplicative-expr-recur\n");
//   string temp = new_temp();
//   stringstream ss;
//   ss << $2.code << $3.code;
//   ss << ". " << temp << "\n";
//   ss << "+ " << temp << ", " << $2.ret_name << ", " << $3.ret_name << 

//   $$.code = const_cast<char*>(ss.str().c_str());
//   $$.ret_name = temp;
//   }
// 	| SUB multiplicative-expr multiplicative-expr-recur {
//     printf("multiplicative-expr-recur -> SUB  multiplicative-expr multiplicative-expr-recur\n");

//     }
// 	|
// 	  {printf("multiplicative-expr-recur -> epsilon\n");}
*/

multiplicative-expr: term{
  $$.code = $1.code;
  $$.ret_name = $1.ret_name;
}
| term MULT term {
  string temp = new_temp();
  stringstream ss;
  ss << $1.code << $3.code;
  ss << ". " << temp << "\n";
  ss << "* " << temp << ", " << $1.ret_name << ", " << $3.ret_name << "\n";
  $$.code = const_cast<char*>(ss.str().c_str());
  $$.ret_name = const_cast<char*>(temp.c_str());
}
| term DIV term {
  string temp = new_temp();
  stringstream ss;
  ss << $1.code << $3.code;
  ss << ". " << temp << "\n";
  ss << "/ " << temp << ", " << $1.ret_name << ", " << $3.ret_name << "\n";
  $$.code = const_cast<char*>(ss.str().c_str());
  $$.ret_name = const_cast<char*>(temp.c_str());
}
| term MOD term {
  string temp = new_temp();
  stringstream ss;
  ss << $1.code << $3.code;
  ss << ". " << temp << "\n";
  ss << "% " << temp << ", " << $1.ret_name << ", " << $3.ret_name << "\n";
  $$.code = const_cast<char*>(ss.str().c_str());
  $$.ret_name = const_cast<char*>(temp.c_str());
}

/*
// multiplicative-expr: term term-recur {
//   printf("multiplicative-expr -> term term-recur\n");
//   }

// term-recur:
// 	MULT term term-recur { //printf("term-recur -> MULT term term-recur\n"); }
// 	| DIV term term-recur { //printf("term-recur -> DIV term term-recur\n"); }
// 	| MOD term term-recur { //printf("term-recur -> MOD term term-recur\n"); }
// 	|
// 	  { //printf("term-recur -> epsilon\n"); }
*/

term:
	 var { //printf("term -> var\n"); }
	| number {
    //printf("term -> number\n");
    stringstream ss;
    ss << $1.ret_name;
    $$.ret_name = const_cast<char*>(ss.str().c_str());
    $$.code = (char*) "";
    }
	| L_PAREN expression R_PAREN {
    //printf("term -> L_PAREN expression R_PAREN\n");
    }
	| identifiers L_PAREN expressions R_PAREN {
    //printf("term-> identifiers L_PAREN expression expression-recur R_PAREN\n");
    string temp = new_temp();
    stringstream ss;
    ss << $3.code;
    ss << ". " << temp << "\n";
    }


parameters: expression expressions { //printf("parameters -> expression expression-recur\n"); }
	| 
          { //printf("parameters -> epsilon\n"); }



number: NUMBER {
  //printf("number -> NUMBER %d\n", $1);
  $$.ret_name = const_cast<char*>(to_string($1).c_str());
  $$.code = (char*)"";
  }


expressions: expression COMMA expressions {
  stringstream ss;
  ss << $1.code << "param " << $1.ret_name << "\n";
  ss << $3.code;
  
  $$.code = const_cast<char*>(ss.str().c_str());
  $$.ret_name = (char*)"";
}
| expression {
  stringstream ss;
  ss << $1.code << "param " << $1.ret_name << "\n";
  $$.code = const_cast<char*>(ss.str().c_str());
  $$.ret_name = (char*)"";
}
// expression-recur: COMMA expression expression-recur {
//   printf("expression-recur -> COMMA expression expression-recur\n");
//   }
// 	| 
// 	  {printf("expression-recur -> epsilon\n");}



var: identifiers
	{
    //printf("var ->  identifiers\n");
    $$.code = (char*)"";
    $$.ret_name = $1.ret_name;
  }
	| identifiers L_BRACKET expression R_BRACKET {
    //printf("var -> identifiers L_BRACKET expression R_BRACKET\n");
    stringstream ss;
    ss << $3.code;
    ss << $1.ret_name;
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
   return 0;
}

void yyerror(const char *msg) {
    /* implement your error handling */ 
	printf("Error: On line %d, column %d: %s \n", currLine, currPos, msg); 
}

