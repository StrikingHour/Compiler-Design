input = input.txt
output = output.txt

main: 
	bison -d parser.y 
	flex lexer.l 
	gcc parser.tab.c lex.yy.c
	a <$(input)> $(output)

assembler:
	E:\masm32\bin\ml /c /coff /Cp prog.asm
	E:\masm32\bin\link -entry:main /subsystem:console prog.obj
	prog