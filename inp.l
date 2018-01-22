%{
#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include <string.h>   

int next_value=0;
int flag=0;
int comments=0;
int z=0;
%}

LINE \n
letter [a-zA-Z]  
digit[0-9]

keyword "if"|"else"|"int"|"char"|"scanf"|"printf"|"switch"|"return"|"struct"|"do"|"while"|"void"|"for"|"float"|"main"|"include"|"auto"|"break"|"case"|"const"|"continue"|"default"|"double"|"enum"|"extern"|"goto"|"long"|"register"|"return"|"short"|"signed"|"sizeof"|"static"|"typedef"|"union"|"unsigned"|"volatile"

operator "&&"|"<"|">"|"<="|">="|"="|"+"|"-"|"?"|"*"|"/"|"||"

Id {letter}({letter}|{digit})*


func {Id}"("("int "|"float "){Id}")"

func_call {Id}"("")"

pointer "*"{Id}

array {Id}"["{digit}+"]"

preprocessor "#"("include"|"define ")(("<"{Id}".h>")|({Id}" "{digit}))

comment_begin "/*"

comment_end "*/"

single_comment "//"


%% 

{comment_begin} {if(flag==1){printf("Error Found :NESTED COMMENT\n");exit(0);}else{flag=1;}}

{comment_end} {flag=0;comments++;}

{single_comment}  if(flag==0)flag=2;comments++;

\"[^\"]*\" if(flag==0)Insert("String literal",yytext,find_Attribute_Value(yytext));

{LINE}  if(flag==2)flag=0;

({digit}|"$"|"@")+{letter}+("$"|"@")*  if(flag==0)printf("Error Found : ILLEGAL IDENTIFIER %s\n",yytext);

{preprocessor} if(flag==0)Insert("PRE PROCESSOR",yytext,find_Attribute_Value(yytext));

{func} if(flag==0)Insert("FUNCTION" ,yytext,find_Attribute_Value(yytext)); 
{func_call} if(flag==0)Insert("FUNCTION CALL",yytext,find_Attribute_Value(yytext));
{array} if(flag==0)Insert("ARRAY",yytext,find_Attribute_Value(yytext));

{digit}+("E"("+"|"-")?{digit}+)? if(flag==0)Insert("REAL_NUMBER",yytext,find_Attribute_Value(yytext));  

{digit}+"."{digit}+("E"("+"|"-")?{digit}+)? if(flag==0)Insert("FLOAT",yytext,find_Attribute_Value(yytext));  
{pointer} if(flag==0)Insert("POINTER" , yytext,find_Attribute_Value(yytext));
{keyword}   if(flag==0)Insert("KEYWORD",yytext,find_Attribute_Value(yytext)); 

{Id} if(flag==0)Insert("ID",yytext,find_Attribute_Value(yytext));

"&&"|"<"|">"|"<="|">="|"="|"+"|"-"|"?"|"*"|"/"|"&"|"||"|"++"|"--" if(flag==0)Insert("OPERATOR",yytext,find_Attribute_Value(yytext));  

"{"|"}"|"["|"]"|"("|")"|"."|"\""|"\\"|";"|"," if(flag==0)Insert("SEPERATOR",yytext,find_Attribute_Value(yytext));  


"%d"|"%s"|"%c"|"%f"|"%e" if(flag==0)Insert("FORMAT_SPECIFIER",yytext,find_Attribute_Value(yytext));  

%%  

int yywrap()  
{  
  return 1;  
}  

int size=0;
void Insert(char[],char[],int);
void Display();
int find_Attribute_Value(char[]);

struct Table
{
 char token[100],symbol[100];
 int value;
struct Table *next;};

struct Table *first,*last;

int main(int argc,char *argv[]){  
  yyin=fopen(argv[1],"r"); 
  
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
  struct Table *p;
  p=malloc(sizeof(struct Table));
  strcpy(p->token,l);
  strcpy(p->symbol,a);
  p->value=op;
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
int find_Attribute_Value(char l[100])
{
	int found=0;
	struct Table *tab;
	if(size==0)
	{
		return 0;
	}
	tab=first;
	int i;
	for(i=0;i<size;i++)
	{
		if(strcmp(tab->symbol,l)==0)
		{
			found=tab->value;
			return found;
		}
		else
		{
			tab=tab->next;
		}

	}
	next_value++;
	return next_value;
}
	
void Display()
{
  int i;
  struct Table *p;
  p=first;
  printf("There are %d comments in the code\n",comments);
  

fprintf(yyout,"\n\tSYMBOL\t\t\t\t\t\t\tTOKEN\t\t\t\tAttribute Number\n");
  for(i=0;i<size;i++)
   {
   
	if(p->value==z){  
  
	fprintf(yyout,"\t%s\t\t\t\t\t\t\t%s\t\t\t\t%d\n",p->symbol,p->token,p->value);
	z++;

	}
    	p=p->next;
   }
}
