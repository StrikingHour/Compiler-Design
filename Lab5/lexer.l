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

%%

"Proc" {return(PROC);}
"params" {return(PARAMS);}
"begin" {return(BEGIN_);}
"Disp: *value:*" {return(PRINT);}
"," {return(COMMA);}
"intvar" {return(INT);}
"single" {return(SINGLE);}
"body" {return(BODY_);}
"end" {return(END_);}

{ID} { strcpy(yylval.str_val, yytext); return(ID);}
"(" {return(LP);}
")" {return(RP);}
{digit}+ {yylval.int_val=atoi(yytext); return(ICONST);}
"=" {return(ASSIGN);}
"+" {return(PLUS);}
"-" {return(MINUS);}
"*" {return(MUL);}
";" {return(SEMI);}

"\n"        { lineno += 1; }
[ \t\r\f]+  

.       { yyerror("Unrecognized character"); }

