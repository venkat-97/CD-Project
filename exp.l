
%{
 #include"y.tab.h"
 int line=1;
char *tablePtr;
void addToken(char*);
%}
datatype "int"|"float"|"char"|"long"
alpha [a-zA-Z]
digit [0-9]
header "#include<"
had  ".h>"
noperators ">="|"<="|"=="|">"|"<"|"!=" 
coperators "&&"|"||"
unary     "++"|"--"
us        "_"
%%
[\t ]
[\n]              {line++;} 
{noperators}      {return OP;}
{coperators}       {return COP;}
{unary}            {return UN;}
{header}(.)*{had} {return HEAD;}
while             {return WHILE;}
for               {return FOR;} 
if		  {return IF;}
else              {return ELSE;} 
return           {return RETURN;}
{datatype}         {return TYPE;}
main        {return ID;}
{digit}+    {return NUM;}
({alpha}|{us})({alpha}|{digit}|{us})* { addToken(yytext); return ID;}
">>="			{  return(RIGHT_AS); }
"<<="			{  return(LEFT_AS); }
"+="			{  return(ADD_AS); }
"-="			{  return(SUB_AS); }
"*="			{  return(MUL_AS); }
"/="			{  return(DIV_AS); }
.                return yytext[0];
%%


yywrap()
{
	return(1);
}

void addToken(char *yytext)
{
  int len = strlen(yytext);
  tablePtr = (char*)malloc((len+1)*sizeof(char));
  strcpy(tablePtr, yytext);
}
