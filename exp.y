%{
#include<stdio.h>
extern int line;
int error_occur=0;


struct tokenList
{
	char *token,type[20],line[100];
	struct tokenList *next;
};
typedef struct tokenList tokenList;
extern char *tablePtr;
tokenList *symbolPtr = NULL;
tokenList *constantPtr = NULL;
void makeList(char *,char,int);
%} 
%token ID NUM TYPE MAIN HEAD WHILE OP COP FOR UN IF ELSE RETURN MUL_AS SUB_AS ADD_AS DIV_AS MOD_AS RIGHT_AS LEFT_AS

%start S

%% 
S : M  ;
M: HEADER ST |  ;
HEADER : HEAD   ;

ST :   TYPE ID LB ARG RB FBL BODY FBR ST  {makeList(tablePtr,'v', line);}  | ; 

ARG : SDEC  | ;
SDEC : TYPE ID {makeList(tablePtr,'v', line);} 
	| TYPE ID C SDEC {makeList(tablePtr,'v', line);}
  ;
RET :  RETURN K   ;
K : ID {makeList(tablePtr,'v', line);} |NUM  ;
BODY : BODY BODY | R SM | DEC SM| WLOOP | FLOOP | IFEL | RET SM | SM  | FUNC SM     ;
SINGLE : R SM|DEC SM|WLOOP|FLOOP|IFEL|RET SM|FUNC SM|SM ;

R : ID AS_OP E {makeList(tablePtr,'v', line);} | E   ;
E : E '+' P {makeList("+",'o', line);} | P |E '-' P {makeList("-",'o', line);}   ; 
P : P '*' SS {makeList("*",'o', line);}| SS   ;
SS : SS '/' Q {makeList("/",'o', line);} | Q    ;
Q :  Q UN | ID {makeList(tablePtr,'v', line);} | NUM | LB E RB 
	 ;

DEC : TYPE VAR  ;
VAR : TT C VAR 
	| TT  ;
TT : ID {makeList(tablePtr,'v', line);} | ID AS_OP E ;

WLOOP : WHILE LB COND RB WDEF {makeList("while",'k', line);}
 ;
WDEF : FBL BODY FBR 
	| SINGLE  ;
COND : EXP COP COND| EXP   ;
EXP : ID {makeList(tablePtr,'v', line);} |ID OP ID {makeList(tablePtr,'v', line);} 
     |ID OP NUM {makeList(tablePtr,'v', line);}|NUM ;

FLOOP : FOR LB ARG1 SM COND SM R RB FDEF {makeList("for",'k', line);}
	 ;
ARG1 : TYPE R | R   ;
FDEF : FBL BODY FBR 
	| SINGLE   ;

IFEL : IF LB COND RB IDEF  IF {makeList("if",'k', line);}
       | IF LB COND RB IDEF ELSE IDEF  {makeList("if",'k', line);makeList("else",'k', line); } 
	  ;
IDEF : FBL BODY FBR 
	| SINGLE  ;

FUNC: TYPE ID AS_OP ID LB XY RB 
	| ID AS_OP ID LB XY RB
	| ID LB XY RB 
	 ;

XY : ID| NUM | E SM XY  |;

AS_OP : '=' { makeList("=",'o', line); }
	| MUL_AS { makeList("*=",'o', line); }
	| DIV_AS { makeList("/=",'o', line); }
	| MOD_AS { makeList("%=",'o', line); }
	| ADD_AS { makeList("+=",'o', line); }
	| SUB_AS { makeList("-=",'o', line); } ;

LB : '(' {makeList("(",'p',line);} ;
RB : ')' {makeList(")",'p',line);} ;

FBL : '{' {makeList("{",'p',line);} ;
FBR : '}' {makeList("}",'p',line);} ;

C : ',' {makeList(",",'p',line);} ;
SM : ';' {makeList(";",'p',line);} ;



%%



void yyerror()
 {
	error_occur=1;
  printf("Invalid expression at %d",line);
 }
 extern FILE *yyin;
int main(int argc,char **argv)
 {
  yyin=fopen(argv[1],"r");
  yyparse();


	if(!error_occur){
		printf("Parsing complete");
	}

	FILE *writeSymbol=fopen("symbolTable.txt","w");
    		fprintf(writeSymbol,"\n\t\t\t\tSymbolTable\n\n\t\tToken\t\t\tType\t\t\t\t\t\t\tLineNumber\n");
      		for(tokenList *ptr=symbolPtr;ptr!=NULL;ptr=ptr->next){
  			fprintf(writeSymbol,"\n%20s%30.30s%60s",ptr->token,ptr->type,ptr->line);
		}
		
		FILE *writeConstant=fopen("constantTable.txt","w");
    		fprintf(writeConstant,"\n   \t\t\t\t\t\t\t\tConstant Table \n\n \t\t\t\t\t\tValue\t\t\t\t\t\t\tLine Number\n");
    		for(tokenList *ptr=constantPtr;ptr!=NULL;ptr=ptr->next)
  		fprintf(writeConstant,"\n%50s%60s",ptr->token,ptr->line);
  	
  	
  		fclose(writeSymbol);
		
		fclose(writeConstant);
 }


void makeList(char *tokenName,char tokenType, int tokenLine)
{
	char line[39],linen[19];
	
  	snprintf(linen, 19, "%d", tokenLine);
	strcpy(line," ");
	strcat(line,linen);
	char type[20];
	switch(tokenType)
	{
			case 'c':
					strcpy(type,"Constant");
					break;
			case 'v':
					strcpy(type,"Identifier");
					break;
			case 'p':
					strcpy(type,"Punctuator");
					break;
			case 'o':
					strcpy(type,"Operator");
					break;
			case 'k':
					strcpy(type,"Keyword");
					break;
			
	
	}
	
	if(tokenType == 'c')
	{
    		
    		for(tokenList *p=constantPtr;p!=NULL;p=p->next)
  	 		if(strcmp(p->token,tokenName)==0){
       				strcat(p->line,line);
       				return;
     			}
		tokenList *temp=(tokenList *)malloc(sizeof(tokenList));
		temp->token=(char *)malloc(strlen(tokenName)+1);
		strcpy(temp->token,tokenName);
		strcpy(temp->type,type);
    		strcpy(temp->line,line);
    		temp->next=NULL;
    		
    		tokenList *p=constantPtr;
    		if(p==NULL){
    			constantPtr=temp;
    		}
    		else{
    			while(p->next!=NULL){
    				p=p->next;
    			}
    			p->next=temp;
    		}	
    		

	}
	else 
	{
    		for(tokenList *p=symbolPtr;p!=NULL;p=p->next)
  	 		if(strcmp(p->token,tokenName)==0){
       				strcat(p->line,line);
       				return;
     			}
		tokenList *temp=(tokenList *)malloc(sizeof(tokenList));
		temp->token=(char *)malloc(strlen(tokenName)+1);
		strcpy(temp->token,tokenName);
		strcpy(temp->type,type);
    		strcpy(temp->line,line);
    		temp->next=NULL;
    		tokenList *p=symbolPtr;
    		if(p==NULL){
    			symbolPtr=temp;
    		}
    		else{
    			while(p->next!=NULL){
    				p=p->next;
    			}
    			p->next=temp;
    		}
	}
}
