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
    char str_val[200];
    int int_val;
}

%token DIM AS PRINT IF ELSE LP RP LB RB SEMI LT ASSIGN MINUS MUL
%token <str_val> ID STRING
%token <int_val> INT ICONST IF

%type <int_val> dtype
 

%start code

%%
code: {gen_code(START, -1);} statements {gen_code(HALT, -1);};

statements: statements statement | ;

statement: declaration
            | assignment;
            | conditional
            | output
            ;

declaration: DIM ID AS dtype
            {
                insert($2, $4);
            };
dtype: INT {$$=INT_TYPE;}

assignment: ID ASSIGN exp
            {
                int addr = idcheck($1);
                if(addr!=-1){
                    gen_code(STORE, addr);
                }
                else yyerror();
            };

output: PRINT LP STRING RP SEMI
        {
            gen_code(PRINT_STRING, gen_literal($3));
        }
        | PRINT LP ID RP SEMI 
        {
            int addr = idcheck($3);
            if(addr!=-1){
                gen_code(PRINT_INT_VALUE, addr);
            }
        }
        ;
// conditional: IF {$1=gen_label();} LP exp RP {gen_code(IF_START, $1);} 
//             LB statements RB 
//             {gen_code(ELSE_START, $1)} ELSE LB statements RB 
//                                     {gen_code(ELSE_END, $1);}; 

conditional: IF {$1=gen_label();} LP exp RP {gen_code(IF_START, $1);}
            LB statements RB {gen_code(ELSE_START, $1); gen_code(ELSE_END, $1);} ;


exp: exp LT T 
    {
        gen_code(LT_OP, gen_label());
    }
    | exp MINUS T {gen_code(SUB, -1);}
    | T ;

T: T MUL F {gen_code(MULT, -1);}
    | F;

F: ID 
    {
        int addr = idcheck($1);
        if(addr!=-1){
            gen_code(LD_VAR, addr);
        }
    }
    | ICONST {gen_code(LD_INT, $1);}
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




