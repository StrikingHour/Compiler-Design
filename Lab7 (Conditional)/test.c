#include<stdio.h>
#include<string.h>


struct Literal
{
    char str[200];
};

int literal_no = 0;
struct Literal literals[100];

int gen_literal(char* lit)
{
    printf("%s----%d\n", lit, literal_no);
    strcpy(literals[literal_no].str, lit);
    return literal_no++;
}

int main()
{
    char str[200] = "Hello World";
    gen_literal(str);
    printf("%s----%d\n", literals[literal_no-1].str, literal_no);
}