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

%token ASSIGN SEMI LP RP LT DIM AS SUB_H DO COLON END PLUS TO WHILE NEXT THEN GT PRINT
%token<str_val> ID 
%token<int_val> ICONST INT SINGLE IF FOR WHILE DO

%type<int_val> dtype assignment 

%start code

%%
code: {gen_code(START, -1);} function {gen_code(HALT, -1);};
function: SUB_H ID LP RP statements END SUB_H ;
statements: statements statement | ;
statement: declaration
            | assignment
            | conditional 
            | printf
            | while_loop
            | do_while
            | for_loop
            ;

declaration: DIM ID AS dtype 
            {
                insert($2, $4);
            } ;
dtype: INT {$$=INT_TYPE;} | SINGLE {$$=SINGLE_TYPE;} ;

assignment: ID ASSIGN exp optional_semi
            {
                int addr = idcheck($1);
                if(addr!=-1){
                    gen_code(STORE, addr);
                    $$=addr;
                }
            };

optional_semi: SEMI | ;


exp: exp PLUS T
    {
        gen_code(ADD, -1);
    }
    | exp GT T
    {
        gen_code(GT_OP, gen_label());
    }
    | exp LT T 
    {
        gen_code(LT_OP, gen_label());
    }
    | T 
    ;
T: ID
    {
        int addr = idcheck($1);
        if(addr!=-1){
            gen_code(LD_VAR, addr);
        }
    }
    | ICONST {gen_code(LD_INT, $1);};


// loop: FOR {$1=gen_label();}  assignment TO ICONST {printf("%d\n", $3);} statements NEXT ID ;

conditional: IF {$1=gen_label();} exp THEN {gen_code(IF_START, $1);} statements END IF {gen_code(ELSE_START, $1); gen_code(ELSE_END, $1);} ;


printf: PRINT LP ID RP
    {
        int addr = idcheck($3);
        if(addr!=-1){
            gen_code(PRINT_INT_VALUE, addr);
        }
    } ;

while_loop: WHILE {$1 = gen_label(); gen_code(WHILE_LABEL, $1);} 
        exp COLON {gen_code(WHILE_START, $1);} 
        statements END WHILE {gen_code(WHILE_END, $1);} ;

do_while: DO {$1=gen_label(); gen_code(WHILE_LABEL, $1);} 
    COLON statements WHILE exp {gen_code(WHILE_START, $1);} 
    SEMI {gen_code(WHILE_END, $1);};

for_loop: FOR {$1=gen_label();} 
        ID ASSIGN ICONST 
        {
            int addr = idcheck($3);
            if(addr!=-1){
                gen_code(LD_INT, $5);
                gen_code(STORE, addr);
            }
            gen_code(WHILE_LABEL, $1);
        }
        TO ICONST 
        {
            int addr = idcheck($3);
            gen_code(LD_VAR, addr);
            gen_code(LD_INT, $8);
            gen_code(LTE_OP, gen_label());
            gen_code(WHILE_START, $1);
        }
        statements NEXT ID 
        {
            int addr = idcheck($12);
            gen_code(LD_VAR, addr);
            gen_code(LD_INT, 1);
            gen_code(ADD, -1);
            gen_code(STORE, addr); 
            gen_code(WHILE_END, $1);
        }
        ;

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




