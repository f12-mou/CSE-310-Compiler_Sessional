
%x STRINGSTART
%x STRINGSTART2
%x SINGLECOMMENTSTART
%x MULTIPLECOMMENTSTART
%x SINGLECOMMENTSTART2

%{
#include<iostream>
#include<stdlib.h>
#include<string.h>
#include "1905012_compiler.h"
#define YYSTYPE SymbolInfo*

#include "y.tab.h"

using namespace std;

extern YYSTYPE yylval;
extern SymbolTable table;
void yyerror(char *);

int line_count=1;
int err_count=0;
int nowScope=0;


%}



digit [0-9]
letter [A-Za-z]
delim [ \t\r\f\v]
newline \n
ws [delim]+
id (_|{letter})(_|{letter}|{digit})*
integer {digit}+
number {digit}*(\.{digit}+)?(E[+-]?{digit}+)?
ADDOP [+-] 
MULOP [*/%]

%%

{delim}+	{}
{newline} {line_count++;}

"if"    {
			SymbolInfo *s= new  SymbolInfo(yytext, (char *)"IF", 1, line_count, line_count, "IF : if");
			yylval = (YYSTYPE)s;
			return IF;
	    }
"else"  {
			SymbolInfo *s= new  SymbolInfo(yytext, (char *)"ELSE", 1, line_count,line_count, "ELSE : else");
			yylval = (YYSTYPE)s;
			return ELSE;
	    }
"for"   {
			SymbolInfo *s= new  SymbolInfo(yytext, (char *)"FOR", 1, line_count,line_count, "FOR : for");
			yylval = (YYSTYPE)s;
			return FOR;
	    }
"while" {
			SymbolInfo *s= new  SymbolInfo(yytext, (char *)"WHILE", 1, line_count,line_count, "WHILE : while");
			yylval = (YYSTYPE)s;
			return WHILE;
	    }
"int"   {
			SymbolInfo *s= new  SymbolInfo(yytext, (char *)"INT", 1, line_count,line_count, "INT : int");
			yylval = (YYSTYPE)s;
			return INT;
	    }
"float" {
			SymbolInfo *s= new  SymbolInfo(yytext, (char *)"FLOAT", 1, line_count, line_count,  "FLOAT : float");
			yylval = (YYSTYPE)s;
			return FLOAT;
	    }
"return" {
			SymbolInfo *s= new  SymbolInfo(yytext, (char *)"RETURN", 1, line_count,line_count, "RETURN : return");
			yylval = (YYSTYPE)s;
			return RETURN;
	     }
"void" {
			SymbolInfo *s= new  SymbolInfo(yytext, (char *)"VOID", 1, line_count,line_count, "VOID : void");
			yylval = (YYSTYPE)s;
			return VOID;
	   }
"println"	{
			SymbolInfo *s= new  SymbolInfo(yytext, (char *)"PRINTLN", 1, line_count, line_count,"PRINTLN : println");
			yylval = (YYSTYPE)s;
			return PRINTLN;
	     }

{ADDOP} { 	
			string now = "ADDOP : ";
			now=now+(string)(yytext);
			SymbolInfo *s= new  SymbolInfo(yytext, (char *)"ADDOP", 1, line_count,line_count, now);
			yylval = (YYSTYPE)s;
			return ADDOP;
		}



{MULOP}	{
			string now = "MULOP : ";
			now=now+(string)(yytext);
			SymbolInfo *s= new  SymbolInfo(yytext, (char *)"MULOP", 1, line_count, line_count,now);
			yylval = (YYSTYPE)s;
			return MULOP;
		}


"=" 	{
			string now = "ASSIGNOP : =";
			//now=now+(string)(yytext);
			SymbolInfo *s= new  SymbolInfo(yytext, (char *)"ASSIGNOP", 1, line_count,line_count, now);
			yylval = (YYSTYPE)s;
			return ASSIGNOP;
	   }

">" |
"<" |
">=" |
"<=" |
"==" |
"!=" {
			string now = "RELOP : ";
			now=now+(string)(yytext);
			SymbolInfo *s= new  SymbolInfo(yytext, (char *)"RELOP", 1, line_count, line_count,now);
			yylval = (YYSTYPE)s;
			return RELOP;
	}

"&&"	|
"||"	{
			string now = "LOGICOP : ";
			now=now+(string)(yytext);
			SymbolInfo *s= new  SymbolInfo(yytext, (char *)"LOGICOP", 1, line_count,line_count, now);
			yylval = (YYSTYPE)s;
			return LOGICOP;
		}
"!"		{
			string now = "LOGICOP : !";
			//now=now+(string)(yytext);
			SymbolInfo *s= new  SymbolInfo(yytext, (char *)"NOT", 1, line_count, line_count,now);
			yylval = (YYSTYPE)s;
			return NOT;
	   }


";" 	{
			string now = "SEMICOLON : ;";
			//now=now+(string)(yytext);
			SymbolInfo *s= new  SymbolInfo(yytext, (char *)"SEMICOLON", 1, line_count,line_count, now);
			yylval = (YYSTYPE)s;
			return SEMICOLON;
	    }
"," 	{
			string now = "COMMA : ,";
			//now=now+(string)(yytext);
			SymbolInfo *s= new  SymbolInfo(yytext, (char *)"COMMA", 1, line_count, line_count,now);
			yylval = (YYSTYPE)s;
			return COMMA;
	   }
"(" 	{
			string now = "LPAREN : (";
			//now=now+(string)(yytext);
			SymbolInfo *s= new  SymbolInfo(yytext, (char *)"LPAREN", 1, line_count, line_count,now);
			yylval = (YYSTYPE)s;
			return LPAREN;
	    }
")" 	{
			string now = "RPAREN : )";
			//now=now+(string)(yytext);
			SymbolInfo *s= new  SymbolInfo(yytext, (char *)"RPAREN", 1, line_count, line_count,now);
			yylval = (YYSTYPE)s;
			return RPAREN;
	    }
"{" 	{
			string now = "LCURL : {";
			//now=now+(string)(yytext);
			SymbolInfo *s= new  SymbolInfo(yytext, (char *)"LCURL", 1, line_count, line_count,now);
			yylval = (YYSTYPE)s;
			nowScope++;
			return LCURL;
	    }
"}" 	{
			string now = "RCURL : }";
			//now=now+(string)(yytext);
			SymbolInfo *s= new  SymbolInfo(yytext, (char *)"RCURL", 1, line_count,line_count, now);
			yylval = (YYSTYPE)s;
			nowScope--;
			return RCURL;
	    }
"[" 	{
			string now = "LSQUARE : [";
			//now=now+(string)(yytext);
			SymbolInfo *s= new  SymbolInfo(yytext, (char *)"LTHIRD", 1, line_count,line_count, now);
			yylval = (YYSTYPE)s;
			return LTHIRD;
	    }
"]" 	{
			string now = "RSQUARE : ]";
			//now=now+(string)(yytext);
			SymbolInfo *s= new  SymbolInfo(yytext, (char *)"RTHIRD", 1, line_count,line_count, now);
			yylval = (YYSTYPE)s;
			return RTHIRD;
	    }
"++" 	{
			string now = "INCOP : ++";
			//now=now+(string)(yytext);
			SymbolInfo *s= new  SymbolInfo(yytext, (char *)"INCOP", 1, line_count,line_count, now);
			yylval = (YYSTYPE)s;
			return INCOP;
	    }
"--" 	{
			string now = "DECOP : --";
			//now=now+(string)(yytext);
			SymbolInfo *s= new  SymbolInfo(yytext, (char *)"DECOP", 1, line_count, line_count,now);
			yylval = (YYSTYPE)s;
			return DECOP;
	    }



{integer}	{
				string now = "CONST_INT : ";
			now=now+(string)(yytext);
			SymbolInfo *s= new  SymbolInfo(yytext, (char *)"CONST_INT", 1, line_count,line_count, now);
			s->rtype = "int";
			yylval = (YYSTYPE)s;
			return CONST_INT;
			}
{number} 	{	
				string now = "CONST_FLOAT : ";
			now=now+(string)(yytext);
			SymbolInfo *s= new  SymbolInfo(yytext, (char *)"CONST_FLOAT", 1, line_count, line_count,now);
			s->rtype = "float";
			yylval = (YYSTYPE)s;
			return CONST_FLOAT;
			}
{id} 		{	 
				
				SymbolInfo *s;				
				string now = "ID : ";
				now=now+(string)(yytext);	
				s= new SymbolInfo((string)yytext, "ID", 1, line_count,line_count, now);
				s->scope = nowScope;
				yylval = (YYSTYPE)s;
							
				return ID;
			}
\/\*                    { 	BEGIN MULTIPLECOMMENTSTART; 
			}
<MULTIPLECOMMENTSTART>([a-zA-Z\t\b\\\*0-9 ]*\*\/)          {
								
								BEGIN INITIAL;
							   }
<MULTIPLECOMMENTSTART>([a-zA-Z\t\b\\\*0-9 ]*)       {
								
								BEGIN MULTIPLECOMMENTSTART;
				 		     }
<MULTIPLECOMMENTSTART>\n      {
					line_count++;			
			      }
<MULTIPLECOMMENTSTART><<EOF>>      {
						err_count++;BEGIN INITIAL;		
			      	   }

\/\/[^\n]*[^\\]\n	{ 	
			}
\/\/	{ 	
		 BEGIN SINGLECOMMENTSTART;
		}
<SINGLECOMMENTSTART>(\\\n)	{
					line_count++; BEGIN SINGLECOMMENTSTART;
				}
<SINGLECOMMENTSTART>\n		{	
					
					//fprintf(logout," found\n");
					line_count++; BEGIN INITIAL;
				}
<SINGLECOMMENTSTART>([a-zA-Z\t\,\b0-9 ]*)       {
								//fprintf(logout,"%s",yytext);
								BEGIN SINGLECOMMENTSTART;
				 		     }
<SINGLECOMMENTSTART>\\		{
					//fprintf(logout,"%s",yytext);
					BEGIN SINGLECOMMENTSTART2;
				}
<SINGLECOMMENTSTART2>\n		{
					//fprintf(logout,"%s",yytext);
					BEGIN SINGLECOMMENTSTART;line_count++;
				}



%%

int yywrap(void)
{
	return 1;
}






