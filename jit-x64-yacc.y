%{
#include <stdlib.h>
#include <stdio.h>
#include "util.h"

#ifndef YYSTYPE
#define YYSTYPE int
#endif
extern YYSTYPE yylval;

int num_brackets = 0;
int matching_bracket = 0;
struct stack stack = { .size = 0, .items = { 0 } };
const char * const prologue = 
	    ".text\n"
	    ".global main\n"
	    "main:\n"
	    "    pushq %rbp\n"
	    "    movq %rsp, %rbp\n"
	    "    pushq %r12\n"        // store callee saved register
	    "    subq $30008, %rsp\n" // allocate 30,008 B on stack, and realign
	    "    leaq (%rsp), %rdi\n" // address of beginning of tape
	    "    movl $0, %esi\n"     // fill with 0's
	    "    movq $30000, %rdx\n" // length 30,000 B
	    "    call memset\n"       // memset
	    "    movq %rsp, %r12";

const char *const epilogue =
	    "    addq $30008, %rsp\n" // clean up tape from stack.
	    "    popq %r12\n" // restore callee saved register
	    "    popq %rbp\n"
	    "    ret\n";

void yyerror(const char *str)
{
	extern int yylineno;
	extern char yytext[];
	fprintf(stderr, "error : %s\nAt line: %d\nprocess: %s\n", str, yylineno, yytext);
}
%}

%token ADD SUB MOV_R MOV_L BRA_L BRA_R INPUT OUTPUT ZERO END_OF_FILE

%%

commands:
	| commands command
	;

command:
       	/*ZERO 	{puts("  movq $0, %r12");}
	|*/
	ADD 	{printf("    addq $%d, (%%r12)\n", $1);}
	|
	SUB 	{printf("    addq $%d, (%%r12)\n", -($1));}
	|
	MOV_R 	{printf("    addq $%d, %%r12\n", $1);}
	|
	MOV_L 	{printf("    addq $%d, %%r12\n", -($1));}
	|
	OUTPUT 	{// move byte to double word and zero upper bits
		 // since putchar takes an int.
		 puts("    movzbl (%r12), %edi");
		 puts("    call putchar");}
	|
	INPUT 	{puts("    call getchar");
		 puts("    movb %al, (%r12)");}
	|
	BRA_L 	{if (stack_push(&stack, num_brackets) == 0) {
		 	puts  ("    cmpb $0, (%r12)");
			printf("    je bracket_%d_end\n", num_brackets);
			printf("bracket_%d_start:\n", num_brackets++);
		 } else {
			err("out of stack space, too much nesting");
		 }}
	|
	BRA_R 	{if (stack_pop(&stack, &matching_bracket) == 0) {
			puts("    cmpb $0, (%r12)");
			printf("    jne bracket_%d_start\n", matching_bracket);
			printf("bracket_%d_end:\n", matching_bracket);
		} else {
			err("stack underflow, unmatched brackets");
		}}
	|
	END_OF_FILE{ return 0;}
	;

%%

int main(int argc, char *argv[])
{
	if (argc != 2) err("Usage: compiler-x64 <inputfile>");
	extern FILE *yyin;
	yyin = fopen(argv[1], "r");

	puts(prologue);
	yyparse();
	puts(epilogue);
	return 0;
}

