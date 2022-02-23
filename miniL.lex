   /* cs152-miniL */

%{
   /* write your C code here for defination of variables and including headers */
#include "miniL-parser.hpp"

//for miniL.y error handling
int currLine = 1;
int currPos = 0;

%}

   /* some common rules, for example DIGIT */
DIGIT    [0-9]
LETTER [a-zA-Z]
ALPHANUM	{DIGIT}|{LETTER}
UNDERSCORE	[_]

IDENTIFIER	{LETTER}(({ALPHANUM}|{UNDERSCORE})*{ALPHANUM})? 

WHITESPACE	[ \t\r]+
COMMENT		[#]{2}[^\n]*

INVALID_IDENT1	({DIGIT}|{UNDERSCORE})({ALPHANUM}|{UNDERSCORE})*{ALPHANUM}
INVALID_IDENT2	{LETTER}({ALPHANUM}|{UNDERSCORE})*{UNDERSCORE}	


%%
   /* specific lexer rules in regex */

"function" 	{currPos += yyleng; return FUNCTION; }
"beginparams"	{currPos += yyleng; return BEGIN_PARAMS; }
"endparams"	{currPos += yyleng; return END_PARAMS; }
"beginlocals"	{currPos += yyleng; return BEGIN_LOCALS; }
"endlocals"	{currPos += yyleng; return END_LOCALS; }
"beginbody"	{currPos += yyleng; return BEGIN_BODY; }
"endbody"	{currPos += yyleng; return END_BODY; }
"integer"	{currPos += yyleng; return INTEGER; }
"array"		{currPos += yyleng; return ARRAY; }
"of"		{currPos += yyleng; return OF; }
"if"		{currPos += yyleng; return IF; }
"then"		{currPos += yyleng; return THEN; }
"endif"		{currPos += yyleng; return ENDIF; }
"else"		{currPos += yyleng; return ELSE; }
"while"		{currPos += yyleng; return WHILE; }
"do"		{currPos += yyleng; return DO; }
"beginloop"	{currPos += yyleng; return BEGINLOOP; }
"endloop"	{currPos += yyleng; return ENDLOOP; }
"continue"	{currPos += yyleng; return CONTINUE; }
"break"		{currPos += yyleng; return BREAK; }
"read"		{currPos += yyleng; return READ; }
"write"		{currPos += yyleng; return WRITE; }
"not"		{currPos += yyleng; return NOT; }
"true"		{currPos += yyleng; return TRUE; }
"false"		{currPos += yyleng; return FALSE; }
"return"	{currPos += yyleng; return RETURN; }

"-"	{currPos += yyleng; return SUB; }
"+"	{currPos += yyleng; return PLUS; }
"*"	{currPos += yyleng; return MULT; }
"/"	{currPos += yyleng; return DIV; }
"%"	{currPos += yyleng; return MOD; }

"=="	{currPos += yyleng; return EQ; }
"<>"	{currPos += yyleng; return NEQ; }
"<"	{currPos += yyleng; return LT; }
">"	{currPos += yyleng; return GT; }
"<="	{currPos += yyleng; return LTE;  }
">="	{currPos += yyleng; return GTE; }

";"	{currPos += yyleng; return SEMICOLON; }
":"	{currPos += yyleng; return COLON; }
","	{currPos += yyleng; return COMMA; }
"("	{currPos += yyleng; return L_PAREN; }
")"	{currPos += yyleng; return R_PAREN; }
"["	{currPos += yyleng; return L_BRACKET; }
"]"	{currPos += yyleng; return R_BRACKET; }
":="	{currPos += yyleng; return ASSIGN; }

"\n"	{currLine++; currPos = 0;}
{WHITESPACE}	{currPos += yyleng;}

{COMMENT}	{currPos += yyleng;}

{DIGIT}+	{currPos += yyleng; yylval.ival = atoi(yytext); return NUMBER; }
{IDENTIFIER}	{currPos += yyleng; yylval.sval = yytext; return IDENT; }

{INVALID_IDENT1}	{printf("Error at line %d, column %d: identifier \"%s\" must begin with a letter\n", currLine, currPos, yytext); exit(1);}
{INVALID_IDENT2}	{printf("Error at line %d, column %d: identifier \"%s\" cannot end with an underscore\n", currLine, currPos, yytext); exit(1);}
  
. {printf("Error at line %d, col %d : unrecognized symbol  %s \n", currLine, currPos, yytext); exit(1);}
%%
	/* C functions used in lexer */
   /* remove your original main function */