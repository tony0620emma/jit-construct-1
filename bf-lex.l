%{
#include "bf-lex.h"
%}

%%

"[-]"			{return ZERO;}
"+"+			{return ADD;}
"-"+			{return SUB;}
">"+			{return MOV_R;}
"<"+			{return MOV_L;}
","			{return INPUT;}
"."			{return OUTPUT;}
"["			{return BRACE_L;}
"]"			{return BRACE_R;}
<<EOF>> 		{return END_OF_FILE;}
[ \t\n] 		;
.			;


%%

int yywrap(void)
{
	return 1;
}
