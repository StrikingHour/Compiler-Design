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

"Sub" {return(SUB_H);}
"Dim" {return(DIM);}
"As" {return(AS);}
"Single" {return(SINGLE);}
"Integer" {return(INT);}
"For" {return(FOR);}
"To" {return(TO);}
"Next" {return(NEXT);}
"If" {return(IF);}
"Then" {return(THEN);}
"End" {return(END);}
"print" {return(PRINT);}
"While" {return(WHILE);}
":" {return(COLON);}
"do" {return(DO);}

{ID} {strcpy(yylval.str_val, yytext); return(ID);}
"(" {return(LP);}
")" {return(RP);}
{digit}+ {yylval.int_val=atoi(yytext); return(ICONST);}
"=" {return(ASSIGN);}
"+" {return(PLUS);}
">" {return(GT);}
"<" {return(LT);}
";" {return(SEMI);}

"\n"        { lineno += 1; }
[ \t\r\f]+  

.       { yyerror("Unrecognized character"); }

