%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
    #include "symtab.c"
    #include "codeGen.c"
	void yyerror();
	extern int lineno;
	extern int yylex();
%}

%union
{
    char str_val[100];
    int int_val;
}

%token ASSIGN SEMI LP RP PROC PARAMS PLUS BEGIN_ COMMA PRINT BODY_ END_ MINUS MUL
%token<str_val> ID 
%token<int_val> ICONST INT SINGLE

%type<int_val> dtype

%left PLUS MINUS
%left MUL

%start code

%%
code: {gen_code(START, -1);} function {gen_code(HALT, -1);};

function: PROC ID PARAMS LP RP fbody ;
fbody: BEGIN_ BODY_ statements END_ BODY_ ;

statements: statements statement | ;

statement: declaration
            | assignment
            | print_stmt
            ;

declaration: dtype ID SEMI 
            {
                insert($2, $1);
            };

dtype: INT {$$=INT_TYPE;} | SINGLE {$$=SINGLE_TYPE;}

assignment: ID ASSIGN exp optional_semi 
            {
                int addr = idcheck($1);
                if(addr!=-1){
                    gen_code(STORE, addr);
                }
                else yyerror();
            };

optional_semi: SEMI | ;

exp: exp PLUS T 
    {
        gen_code(ADD, -1);
    }
    | exp MINUS T 
    {
        gen_code(SUB, -1);
    }
    | T ;

T: T MUL F 
    {
        gen_code(MULT, -1);
    }
    | F ;

F: ID 
    {
        int addr = idcheck($1);
        if(addr!=-1){
            gen_code(LD_VAR, addr);
        }
        else yyerror();
    }
 | ICONST 
    {
        gen_code(LD_INT, $1);
    };

print_stmt: PRINT COMMA ID 
            {
                int addr = idcheck($3);
                if(addr!=-1){
                    gen_code(PRINT_INT_VALUE, addr);
                }
                else yyerror();
            } ;

%%





void yyerror ()
{
	printf("Syntax error at line %d\n", lineno);
	exit(1);
}

int main (int argc, char *argv[])
{
    // E: E + T | T;
    // T: ID | const;
	yyparse();
	printf("Parsing finished!!\n");

    printf("============= INTERMEDIATE CODE===============\n");
    print_code();

    printf("============= ASM CODE===============\n");
    print_assembly();

	return 0;
}




