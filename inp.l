%{
#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include <string.h>   
int lines=0;
int max=0;
int c=0;
int comments=0;
int z=0;
%}

LINE \n
letter [a-zA-Z]  
digit[0-9]
op "&&"|"<"|">"|"<="|">="|"="|"+"|"-"|"?"|"*"|"/"|"||"
keyword "if"|"else"|"int"|"char"|"scanf"|"printf"|"switch"|"return"|"struct"|"do"|"while"|"void"|"for"|"float"|"main"|"include"|"auto"|"break"|"case"|"const"|"continue"|"default"|"double"|"enum"|"extern"|"goto"|"long"|"register"|"return"|"short"|"signed"|"sizeof"|"static"|"typedef"|"union"|"unsigned"|"volatile"

Id {letter}({letter}|{digit})*
/*func Id "(" ("int"|"float" Id) ")" */

func {Id}"("("int "|"float "){Id}")"

func_call {Id}"("")"

point "*"{Id}

array {Id}"["{digit}+"]"

preprocessor "#"("include"|"define ")(("<"{Id}".h>")|({Id}" "{digit}))

comment "/*"

endcomment "*/"

scomment "//"

bad "@"|"$"

all ({Id}|{digit}|{op}|{array}|{keyword})*



%% 

{comment} {if(c==1){printf("Error :NESTED COMMENT\n");exit(0);}else{c=1;}}

{endcomment} {c=0;comments++;}

{scomment}  if(c==0)c=2;comments++;

\"[^\"]*\" if(c==0)Insert("String literal",yytext,Search(yytext)); /* comment this line for identify format srecifiers*/

{LINE}  if(c==2)c=0;

({digit})+{letter}+  if(c==0)printf("Error : BAD TOKEN %s\n",yytext);

{all}*{bad}+{all}*  if(c==0)printf("Error : ILLEGAL TOKEN %s\n",yytext);



{preprocessor} if(c==0)Insert("PRE PROCESSOR",yytext,Search(yytext));

{func} if(c==0)Insert("FUNCTION" ,yytext,Search(yytext)); 
{func_call} if(c==0)Insert("FUNCTION CALL",yytext,Search(yytext));
{array} if(c==0)Insert("ARRAY",yytext,Search(yytext));




{digit}+("E"("+"|"-")?{digit}+)? if(c==0)Insert("RE_NUM",yytext,Search(yytext));  

{digit}+"."{digit}+("E"("+"|"-")?{digit}+)? if(c==0)Insert("FLOAT",yytext,Search(yytext));  
{point} if(c==0)Insert("POINTER" , yytext,Search(yytext));
{keyword}   if(c==0)Insert("KEYWORD",yytext,Search(yytext)); 












{Id} if(c==0)Insert("ID",yytext,Search(yytext));

"&&"|"<"|">"|"<="|">="|"="|"+"|"-"|"?"|"*"|"/"|"&"|"||"|"++"|"--" if(c==0)Insert("OPERATOR",yytext,Search(yytext));  

"{"|"}"|"["|"]"|"("|")"|"."|"\""|"\\"|";"|"," if(c==0)Insert("SEPERATOR",yytext,Search(yytext));  


"%d"|"%s"|"%c"|"%f"|"%e" if(c==0)Insert("FORMAT_SPECIFIER",yytext,Search(yytext));  

%%  

int yywrap()  
{  
  return 1;  
}  

int size=0;
void Insert(char[],char[],int);
void Display();
int Search(char[]);

struct SymbTab
{
 char label[100],symbol[100];
 int addr;
struct SymbTab *next;};
struct SymbTab *first,*last;

int main(int argc,char *argv[]){  
  yyin=fopen(argv[1],"r"); 
  ++lines;
  FILE *file=fopen("output.txt","w");
  yyout=file;
  yylex(); 
  fclose(yyin);
  
  Display(); 
fclose(yyout); 
  return 0;  
}  
void Insert(char l[100],char a[100],int op)
{
  int n;
  struct SymbTab *p;
  p=malloc(sizeof(struct SymbTab));
  strcpy(p->label,l);
  strcpy(p->symbol,a);
  p->addr=op;
  p->next=NULL;
  if(size==0){
    first=p;
    last=p;
  }
  else{
    last->next=p;
    last=p;
  }
  size++;
}
int Search(char l[100])
{
	int abc=0;
	struct SymbTab *qw;
	if(size==0)
	{
		return 0;
	}
	qw=first;
	int i;
	for(i=0;i<size;i++)
	{
		if(strcmp(qw->symbol,l)==0)
		{
			abc=qw->addr;
			return abc;
		}
		else
		{
			qw=qw->next;
		}

	}
	max++;
	return max;
}
	
void Display()
{
  int i;
  struct SymbTab *p;
  p=first;
  printf("There are %d comments in the code\n",comments);
  //printf("\n\tSYMBOL\t\t\t\tTOKEN\t\t\t\tAttribute Number\n");
fprintf(yyout,"\n\tSYMBOL\t\t\t\t\t\t\tTOKEN\t\t\t\tAttribute Number\n");
  for(i=0;i<size;i++)
   {
    //printf("\t%s\t\t\t\t%s\t\t\t\t%d\n",p->symbol,p->label,p->addr);
	if(p->addr==z){    /* comment the if condition(not the printf statements within) for reoccurances of symbols to be shown*/
	fprintf(yyout,"\t%s\t\t\t\t\t\t\t%s\t\t\t\t%d\n",p->symbol,p->label,p->addr);
	z++;
	}
    	p=p->next;
   }
}
