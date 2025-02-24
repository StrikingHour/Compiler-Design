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

%token ASSIGN SEMI LP RP MINUS MUL PLUS AS SCAN PRINT DIM
%token<str_val> ID 
%token<int_val> ICONST INT 

%type<int_val> type exp T

%start code

%%
code: {gen_code(START, -1);} statements {gen_code(HALT, -1);};

statements: statements statement | ;

statement: declaration
        | output
        | input
        ;
declaration: DIM ID AS type
        {
            insert($2, $4);
        };
type: INT {$$=INT_TYPE;}

input: ID ASSIGN SCAN LP RP
        {
            int addr = idcheck($1);
            if(addr!=-1){
                gen_code(SCAN_INT_VALUE, addr);
            }
            else yyerror();
        };

output: PRINT LP exp RP 
        {
            gen_code(PRINT_INT_VALUE, $3);
        };

exp: exp MUL T 
    {
        gen_code(MULT, -1);
        char* name = "__TEMP__";
        int addr = idcheck(name);
        if(addr==-1){
            insert(name, INT_TYPE);
            addr = idcheck(name);
        }
        gen_code(STORE, addr);
        $$ = addr;
    }
    | exp PLUS T 
    {
        gen_code(ADD, -1);
        char* name = "__TEMP__";
        int addr = idcheck(name);
        if(addr==-1){
            insert(name, INT_TYPE);
            addr = idcheck(name);
        }
        gen_code(STORE, addr);
        $$ = addr;
    }
    | T {$$=$1;}
    ;
T: ID 
    {
        int addr = idcheck($1);
        if(addr!=-1){
            gen_code(LD_VAR, addr);
            $$ = addr;
        }
        else yyerror();
    }
    | ICONST
    {gen_code(LD_INT, $1); $$=$1;} ;

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




