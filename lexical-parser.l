%{
#include <stdio.h>
#include <stdlib.h>
#include "syntax-parser.tab.h"
%}

%option noyywrap 

%{
    int lineCounter = 1;
%}

%%

"peso"                  { return INT; }
"mostrar"               { return PRINT; }
"lerexercicio"          { return SCAN; }
"supino"                { return SE; }
"crossover"             { return SENAO; }
"serie"                 { return ENQUANTO; }
"obrigado_turing"       { return RETURN; }
"+"                     { return MAIS; }
"-"                     { return MENOS; }
"*"                     { return VEZES; }
"/"                     { return DIVIDIDO; }
"{"                     { return ABRE_CHAVES; }
"}"                     { return FECHA_CHAVES; }
"("                     { return ABRE_PARENTESES; }
")"                     { return FECHA_PARENTESES; }
"="                     { return ATRIBUICAO; }
"<"                     { return MENOR; }
">"                     { return MAIOR; }
"<="                    { return MENOR_IGUAL; }
">="                    { return MAIOR_IGUAL; }
"=="                    { return IGUAL; }
"!="                    { return DIFERENTE; }
"%"                     { return RESTO; }
";"                     { return PEV; }

-{0,1}[0-9]+            {
                        yylval.int_val = atoi(yytext);
                        return NUM;
                        }

[a-zA-Z][a-zA-Z0-9_]*   {
                        yylval.str_val = strdup(yytext);
                        return ID;
                        }

" "                     {}
"\n"                    { lineCounter++; }
"//".*                  { /* Ignorar comentários de linha */ }
.                       { printf("ERRO: lexical error in %d: %s\n", lineCounter, yytext); return 1; }

%%
