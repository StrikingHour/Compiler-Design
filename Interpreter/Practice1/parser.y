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
    struct lbs *lbls;
}

%token PRINT SCAN
%token PLUS MINUS MUL DIV EQUOP LT GT INCR
%token LP RP LB RB SEMI ASSIGN ELSE
%token<str_val> ID
%token<int_val> ICONST
%token<int_val> INT
%token<lbls> IF
%token<lbls> WHILE FOR

%left LT GT /*LT GT has lowest precedence*/
%left PLUS MINUS 
%left MULOP /*MULOP has lowest precedence*/
%left INCR


%start program

%%
program: {gen_code(START, -1);} statements {gen_code(HALT, -1);};

statements: statements statement | ;

statement: declaration
        | assignment 
        | loop_while
        | for_loop
        | print
        | inc_dec 
        | conditional
        ;

declaration: INT ID SEMI
        {
            insert($2, $1);
        }
        ;

assignment: ID ASSIGN exp SEMI
        {
            int addr = idcheck($1);
            if(addr!=-1){
                gen_code(STORE, addr);
            }
            else yyerror();
        }
        ;

inc_dec: ID INCR SEMI 
        {
            int addr = idcheck($1);
            if(addr!=-1){
                gen_code(INC, addr);
            }
            else yyerror();
        }
        ;
exp: exp PLUS T 
    {
        gen_code(ADD, -1);
    }
    | exp MINUS T {gen_code(SUB, -1);}
    | exp LT T {gen_code(LT_OP, -1);}
    | T ;

T: ID 
    {
        int addr = idcheck($1);
        if(addr!=-1){
            gen_code(LD_VAR, addr);
        }
        else yyerror();
    }
    | ICONST {gen_code(LD_INT, $1);} ;

print: PRINT LP ID RP SEMI 
        {
            int addr = idcheck($3);
            if(addr!=-1){
                gen_code(PRINT_INT_VALUE, addr);
            }
            else yyerror();
        };

conditional: IF {$1 = (struct lbs *) newlblrec();}
            LP exp RP 
            {
                $1->for_goto = reserve_loc();
            }
            LB statements RB 
            {
                $1->for_jmp_false = reserve_loc();
                back_patch($1->for_goto, JMP_FALSE, gen_label());
            }
            ELSE LB statements RB 
            {
                back_patch($1->for_jmp_false, GOTO, gen_label());
            };

loop_while: WHILE 
            {
                $1 = (struct lbs *) newlblrec();
                $1->for_goto = gen_label();
            }
            LP exp RP {$1->for_jmp_false = reserve_loc();}
            LB statements RB 
            {
                gen_code(GOTO, $1->for_goto);
                back_patch($1->for_jmp_false, JMP_FALSE, gen_label());
            };

for_loop: FOR LP assignment 
            {
                $1 = (struct lbs *) newlblrec();
                $1->for_goto = gen_label();
            }
            exp SEMI 
            {
                $1->for_jmp_false = reserve_loc();
            }
            ID INCR RP LB statements RB 
            {
                
                int addr = idcheck($8);
                if(addr!=-1){
                    gen_code(INC, addr);
                }
                else yyerror();
                gen_code(GOTO, $1->for_goto);
                back_patch($1->for_jmp_false, JMP_FALSE, gen_label());
            }
            
            ;

// for_loop: FOR LP assignment exp SEMI ID ASSIGN exp RP LB statements RB ;

%%

void yyerror ()
{
	printf("Syntax error at line %d\n", lineno);
	exit(1);
}

int main (int argc, char *argv[])
{
	yyparse();
	printf("Parsing finished!\n");

    printf("============= INTERMEDIATE CODE===============\n");
    print_code();

    printf("============= RUN CODE IN VIRTUAL MACHINE ===============\n");
    vm();

	return 0;
}
