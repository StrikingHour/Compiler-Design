%option noyywrap

%{
	#define INT_TYPE 1
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include "parser.tab.h"
	
	int lineno = 1; // initialize to 1
	void yyerror();
%}

letter [a-zA-Z]
digit [0-9]
ID (_|{letter})(_|{letter}|{digit})*

ws [ ]
quo ["]
literal ({quo})({letter}|{digit}|{ws})*({quo})

%%
"dim" {return DIM;}
"as" {return AS;}
"integer" {return INT;}
"output" {return PRINT;}
"if" {return IF;}
"else" {return ELSE;}

{ID} {strcpy(yylval.str_val, yytext); return ID;}
{digit}+ {yylval.int_val = atoi(yytext); return ICONST;}

"<" {return LT;}
"-" {return MINUS;}
"*" {return MUL;}
"=" {return ASSIGN;}
";" {return SEMI;}
"(" {return LP;}
")" {return RP;}
"{" {return LB;}
"}" {return RB;}

{literal} {strcpy(yylval.str_val, yytext); return(STRING);}

"\n"        { lineno += 1; }
[ \t\r\f]+  

.       { yyerror("Unrecognized character"); }

