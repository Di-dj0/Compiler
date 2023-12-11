%{
    
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// yyout defines the file used as an output for the programm
extern FILE *yyout;

// this is needed to define what a simbol is
typedef struct {
    char* id;
    int address;
} _symbol;

// this defines what an action is
typedef struct {
    int id;
    int start;
    int end;
} _action;

// finally, this defines the stack of actions
typedef struct {
    int tabaction[1000];
    int iterator;
} _labelStack;

void push(_labelStack *stack, int id);
int pop(_labelStack *stack);

// here we have the push action, that receives a stack and an id, to do a stack.push_back(id)
void push(_labelStack *stack, int id) {
        stack->tabaction[stack->iterator] = id;
        stack->iterator++;
}

// and here we hava the pop action, that receives a stack and returns the action id, as the stack.pop()
int pop(_labelStack *stack) {
        stack->iterator--;
        return stack->tabaction[stack->iterator];
}

// these are the variables and vectors 
_symbol tabsymb[1000];
_action tabaction[1000];
int _nsymbs = 0, _naction = 0, _nactionaux = 0;
_labelStack stack;

// we need to check if the ID is already in the programm everytime a new ID is identified
int getAddress(char *id) {
    for (int i=0;i<_nsymbs;i++)
        if (!strcmp(tabsymb[i].id, id))
            return tabsymb[i].address;

    return -1;
}

// this function verifies if the action exists and returns its start label
int getActionStart(int id) {
    for (int i=0;i<=_naction;i++)
        if (tabaction[i].id == id)
            return tabaction[i].start;

    return -1;
}

// this function verifies if the action exists and returns its end label
int getActionEnding(int id) {
    for (int i=0;i<=_naction;i++)
        if (tabaction[i].id == id)
            return tabaction[i].end;

    return -1;
}

%}

%union {
    char *str_val;
    int int_val;
}

%token <str_val>INT ID PRINT SCAN SE SENAO RETURN MAIS MENOS VEZES DIVIDIDO RESTO ATRIBUICAO MENOR MAIOR MENOR_IGUAL MAIOR_IGUAL IGUAL DIFERENTE PEV <int_val>NUM ABRE_CHAVES FECHA_CHAVES ABRE_PARENTESES FECHA_PARENTESES ENQUANTO

%%

S : declaracao S_linha
    | atrib S_linha 
    | leitura S_linha
    | escrita S_linha
    | condicao S_linha
    | laco S_linha
    | end ;

S_linha : PEV S
    | PEV ;

end : RETURN NUM PEV                        {fprintf(yyout,"     SAIR\n");} 
    | RETURN PEV                            {fprintf(yyout,"     SAIR\n");} ;

bloco : declaracao bloco_linha
    | condicao bloco_linha
    | atrib bloco_linha 
    | leitura bloco_linha
    | escrita bloco_linha
    | laco bloco_linha ;

bloco_linha : PEV bloco
    | PEV ;

laco :  ENQUANTO                            {
                                            tabaction[_naction].id = _naction;
                                            tabaction[_naction].start = (_naction*2);
                                            tabaction[_naction].end = ((_naction*2)+1);

                                            if(getActionStart(_naction) < 10)
                                                fprintf(yyout, "R0%d: NADA\n", getActionStart(_naction)); 
                                            else
                                                fprintf(yyout, "R%d: NADA\n", getActionStart(_naction)) ;
                                            }

        ABRE_PARENTESES 
        comparacao
        FECHA_PARENTESES
        ABRE_CHAVES                         {
                                            if(getActionEnding(_naction) < 10)
                                                fprintf(yyout, "     GFALSE R0%d\n", getActionEnding(_naction)); 
                                            else
                                                fprintf(yyout, "     GFALSE R%d\n", getActionEnding(_naction));
                                            push(&stack, _naction);
                                            _naction++;
                                            }
        bloco      
        FECHA_CHAVES                        {
                                            _nactionaux = pop(&stack);
                                            if(getActionStart(_nactionaux) < 10)
                                                fprintf(yyout, "     GOTO R0%d\n", getActionStart(_nactionaux) ); 
                                            else
                                                fprintf(yyout, "     GOTO R%d\n", getActionStart(_nactionaux) ); 
                                              
                                            if(getActionEnding(_nactionaux) < 10)
                                                fprintf(yyout, "R0%d: NADA\n", getActionEnding(_nactionaux)  ); 
                                            else
                                                fprintf(yyout, "R%d: NADA\n", getActionEnding(_nactionaux)  ); 
                                            } ;

declaracao : INT ID ATRIBUICAO exprecao     {
                                            if(getAddress($2)==-1) {
                                                tabsymb[_nsymbs].id = $2;
                                                tabsymb[_nsymbs].address = _nsymbs;
                                                _nsymbs++;
                                                fprintf(yyout, "     ATR %%%d\n", getAddress($2));
                                            }
                                            else {
                                                printf("ERRO: semantic error\n");
                                                exit(1);
                                            }
                                            } 

    | INT ID ATRIBUICAO SCAN ABRE_PARENTESES FECHA_PARENTESES 
                                            {
                                            if(getAddress($3)==-1) {
                                                tabsymb[_nsymbs].id = $2;
                                                tabsymb[_nsymbs].address = _nsymbs;
                                                _nsymbs++;
                                                fprintf(yyout, "LEIA\nATR %%%d\n", getAddress($2));
                                            }
                                            else {
                                                printf("ERRO: semantic error\n");
                                                exit(1);
                                            }
                                            } ;

atrib : ID ATRIBUICAO exprecao              {
                                            if(getAddress($1)==-1) {
                                                printf("ERRO: semantic error\n");
                                                exit(1);
                                            }
                                            fprintf(yyout, "     ATR %%%d\n", getAddress($1));
                                            } 

    | ID ATRIBUICAO SCAN ABRE_PARENTESES FECHA_PARENTESES 
                                            {
                                            if(getAddress($3)==-1) {
                                                fprintf(yyout, "ERRO: semantic error\n");
                                                exit(1);
                                            }
                                            fprintf(yyout, "LEIA\nATR %%%d\n", getAddress($3));
                                            } ;

condicao :  SE                              {
                                            tabaction[_naction].id = _naction;
                                            tabaction[_naction].start = (_naction*2);
                                            tabaction[_naction].end = ((_naction*2)+1);
                                            }
            ABRE_PARENTESES 
            comparacao 
            FECHA_PARENTESES 
            ABRE_CHAVES                     {
                                            if(getActionStart(_naction) < 10)
                                                fprintf(yyout, "     GFALSE R0%d\n", getActionStart(_naction)); 
                                            else
                                                fprintf(yyout, "     GFALSE R%d\n", getActionStart(_naction));
                                            push(&stack, _naction);
                                            _naction++;
                                            }
            bloco
            FECHA_CHAVES                    {
                                            _nactionaux = pop(&stack);
                                            if(getActionEnding(_nactionaux) < 10)
                                                fprintf(yyout, "     GOTO R0%d\n", getActionEnding(_nactionaux) ); 
                                            else
                                                fprintf(yyout, "     GOTO R%d\n", getActionEnding(_nactionaux) );
                                            } 
            SENAO
            ABRE_CHAVES                     {
                                            if(getActionStart(_nactionaux) < 10)
                                                fprintf(yyout, "R0%d: NADA\n", getActionStart(_nactionaux)  ); 
                                            else
                                                fprintf(yyout, "R%d: NADA\n", getActionStart(_nactionaux)  );
                                            }
            bloco
            FECHA_CHAVES                    {
                                            if(getActionEnding(_nactionaux) < 10)
                                                fprintf(yyout, "R0%d: NADA\n", getActionEnding(_nactionaux)  ); 
                                            else
                                                fprintf(yyout, "R%d: NADA\n", getActionEnding(_nactionaux)  ); 
                                            } ;

comparacao : exprecao IGUAL exprecao              {fprintf(yyout, "     IGUAL\n");} 
        | exprecao DIFERENTE exprecao             {fprintf(yyout, "     DIFER\n");} 
        | exprecao MAIOR exprecao                 {fprintf(yyout, "     MAIOR\n");} 
        | exprecao MENOR exprecao                 {fprintf(yyout, "     MENOR\n");} 
        | exprecao MAIOR_IGUAL exprecao           {fprintf(yyout, "     MAIOREQ\n");} 
        | exprecao MENOR_IGUAL exprecao           {fprintf(yyout, "     MENOREQ\n");} ;

leitura : SCAN ABRE_PARENTESES ID FECHA_PARENTESES 
                                            {
                                            if(getAddress($3)==-1) {
                                                printf("ERRO: semantic error\n");
                                                exit(1);
                                            }
                                            fprintf(yyout, "     LEIA\n     ATR %%%d\n", getAddress($3));
                                            } ;

escrita : PRINT ABRE_PARENTESES exprecao FECHA_PARENTESES
                                            {fprintf(yyout, "     IMPR\n"); } ;

exprecao : exprecao MAIS termo              {fprintf(yyout, "     SOMA\n");}
        | exprecao MENOS termo              {fprintf(yyout, "     SUB\n");}
        | termo ;

termo : termo VEZES fator                   {fprintf(yyout, "     MULT\n");}
        | termo DIVIDIDO fator              {fprintf(yyout, "     DIV\n");}
        | termo RESTO fator                 {fprintf(yyout, "     MOD\n");}
        | fator ;

fator : ID                                  {
                                            if(getAddress($1)==-1) {
                                                printf("ERRO: semantic error\n");
                                                exit(1);
                                            }
                                            fprintf(yyout, "     PUSH %%%d\n", getAddress($1));
                                            }
                                            
        | NUM                               {fprintf(yyout, "     PUSH %d\n", $1); }
 
        | ABRE_PARENTESES exprecao FECHA_PARENTESES ;

%%

extern FILE *yyin;

int main(int argc, char *argv[]) {

    yyin = fopen(argv[1], "r"); 
    yyout = fopen("input.pil", "w");

    yyparse();

    fclose(yyin);
    fclose(yyout);

    return 0;
}

void yyerror(char *s) { fprintf(stderr,"ERRO: %s\n", s); }
