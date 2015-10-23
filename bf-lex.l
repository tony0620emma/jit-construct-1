%{
#include "jit-x64-yacc.tab.h"
extern YYSTYPE yylval;
%}

%%

"[-]"			{return ZERO;}
"+"+			{yylval = yyleng;return ADD;}
"-"+			{yylval = yyleng;return SUB;}
">"+			{yylval = yyleng;return MOV_R;}
"<"+			{yylval = yyleng;return MOV_L;}
","			{return INPUT;}
"."			{return OUTPUT;}
"["			{return BRA_L;}
"]"			{return BRA_R;}
<<EOF>> 		{return END_OF_FILE;}
[ \t\n] 		;
.			;


%%

int yywrap(void)
{
	return 1;
}
