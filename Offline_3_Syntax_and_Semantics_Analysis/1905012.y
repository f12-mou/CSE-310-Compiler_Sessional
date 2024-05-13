%{
#include <bits/stdc++.h>
#include "1905012_compiler.h"
#define YYSTYPE SymbolInfo*

using namespace std;

int yyparse(void);
int yylex(void);
extern FILE *yyin;
FILE* fp;
FILE* fp2;
FILE* fp3;
FILE* fp4;

SymbolTable table;
SymbolInfo* mainJinish;
stack<SymbolInfo*>stck;


void yyerror(char *s)
{
	//write your code
}


%}

%token ID LPAREN RPAREN SEMICOLON COMMA LCURL RCURL INT FLOAT VOID LTHIRD RTHIRD FOR IF ELSE WHILE PRINTLN RETURN ASSIGNOP LOGICOP RELOP ADDOP MULOP NOT CONST_INT CONST_FLOAT INCOP DECOP

%destructor{cout<<"vallagee nah "<<$$->msg<<endl;free($$);} ID LPAREN RPAREN SEMICOLON COMMA LCURL RCURL INT FLOAT VOID LTHIRD RTHIRD FOR IF ELSE WHILE PRINTLN RETURN ASSIGNOP LOGICOP RELOP ADDOP MULOP NOT CONST_INT CONST_FLOAT INCOP DECOP

%nonassoc LOWER_THAN_ID
%nonassoc ID
%nonassoc LOWER_THAN_LTHIRD
%nonassoc LTHIRD
%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE
%nonassoc LOWER_THAN_LOGICOP
%nonassoc LOGICOP
%nonassoc LOWER_THAN_RELOP
%nonassoc RELOP

%%

start : program
	{
		$$ = new SymbolInfo("", "", 2, $1->line, $1->line2, "start : program",$1);
		mainJinish = $$;
		fprintf(fp4,"%s\n",$$->msg.c_str());	
	}
	;

program : program unit 
	{
		$$ = new SymbolInfo("", "", 2, $1->line, $2->line2, "program : program unit",$1, $2);
		fprintf(fp4,"%s\n",$$->msg.c_str());	
	}
	| unit 
	{
		$$ = new SymbolInfo("", "", 2, $1->line, $1->line2, "program : unit",$1);
		fprintf(fp4,"%s\n",$$->msg.c_str());	
	}
	;
	
unit : var_declaration
		{
			$$ = new SymbolInfo("", "", 2, $1->line, $1->line2, "unit : var_declaration",$1);
			fprintf(fp4,"%s\n",$$->msg.c_str());	
		}
     | func_declaration
		{
			$$ = new SymbolInfo("", "", 2, $1->line, $1->line2, "unit : func_declaration",$1);
			fprintf(fp4,"%s\n",$$->msg.c_str());	
		}
     | func_definition
	 	{
			$$ = new SymbolInfo("", "", 2, $1->line, $1->line2, "unit : func_definition",$1);
			fprintf(fp4,"%s\n",$$->msg.c_str());	
		}
	 |  error
	 {	
			SymbolInfo* prb = new SymbolInfo("","",1,1,1, "unit : error");
			cout<<"in error of unit"<<endl;
			$$ = new SymbolInfo("", "", 1, 1, 1, "unit : error",prb);
			fprintf(fp4,"%s\n",$$->msg.c_str());	
	 } 
     ;
     
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON
				{
					$$ = new SymbolInfo("", "", 2, $1->line, $6->line2, "func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON",$1, $2, $3, $4, $5, $6);
					//cout<<"func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON"<<endl;
					$2->fptypes.insert($2->fptypes.end(),$4->fptypes.begin(), $4->fptypes.end());

					SymbolInfo* got = table.LookUp($2->name);
					if(got == NULL)
					{
						$2->etype = 4; // it is a function
						$2->rtype = $1->name;
						$2->vec.insert($2->vec.end(),$4->vec.begin(), $4->vec.end());
						table.Insert2($2);
					}
					else
					{
						int insertedType = got->etype;
						if(insertedType != 4) // not a function
						{
							fprintf(fp3,"Line# %d: \'%s\' redeclared as different kind of symbol\n",$1->line, got->name.c_str());
						}
						else
						{
							fprintf(fp3,"Line# %d: \'%s\' again and again a function why why\n",$1->line, got->name.c_str());
						}
					}
					
					$$->vec.insert($$->vec.end(),$4->vec.begin(), $4->vec.end());
					int len = $$->vec.size();
					for(int i=0;i<len;i++)
					{
						for(int j=i+1;j<len;j++)
							if($$->vec[i]->name == $$->vec[j]->name)
								fprintf(fp3,"Line# %d: Redefinition of parameter \'%s\'\n",$1->line, $$->vec[j]->name.c_str());
					}
					fprintf(fp4,"%s\n",$$->msg.c_str());	
				
				}
		| type_specifier ID LPAREN RPAREN SEMICOLON
		{
			$$ = new SymbolInfo("", "", 2, $1->line, $5->line2, "func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON",$1, $2, $3, $4, $5);
			fprintf(fp4,"%s\n",$$->msg.c_str());	
		}
		| type_specifier ID LPAREN error RPAREN SEMICOLON
		{		
				SymbolInfo* prb = new SymbolInfo("","",1,$3->line, $3->line2, "parameter_list : error");
				$$ = new SymbolInfo("", "", 2, $1->line, $6->line2, "func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON",$1, $2, $3, prb, $5, $6);
				fprintf(fp4,"%s\n",$$->msg.c_str());	
		}
		;
		 
func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement
				{
					//cout<<"func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement"<<endl;

					$$ = new SymbolInfo("", "", 2, $1->line, $6->line2, "func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement",$1, $2, $3, $4, $5, $6);
					$$->vec.insert($$->vec.end(),$4->vec.begin(), $4->vec.end());
					$2->fptypes.insert($2->fptypes.end(),$4->fptypes.begin(), $4->fptypes.end());
					int len = $$->vec.size();
					for(int i=0;i<len;i++)
					{
						for(int j=i+1;j<len;j++)
							if($$->vec[i]->name == $$->vec[j]->name)
								fprintf(fp3,"Line# %d: Redefinition of parameter \'%s\'\n",$1->line, $$->vec[j]->name.c_str());
					}

					SymbolInfo* got = table.LookUp($2->name);
					if(got == NULL)
					{
						$2->etype = 4; // it is a function
						$2->rtype = $1->name;
						$2->vec.insert($2->vec.end(),$4->vec.begin(), $4->vec.end());
						table.Insert2($2);
					}
					else
					{
						int insertedType = got->etype;
						if(insertedType != 4) // not a function
						{
							fprintf(fp3,"Line# %d: \'%s\' redeclared as different kind of symbol\n",$1->line, got->name.c_str());
						}
						else // agei declaration dea hoise, definition akhon
						{	
							string insertedRet = got->rtype;
							int totalParamsInserted = got->vec.size();
							if(insertedRet != $1->name)
							{
								fprintf(fp3,"Line# %d: Conflicting types for \'%s\'\n",$1->line, got->name.c_str());
							}
							if(totalParamsInserted != $$->vec.size())
							{
								fprintf(fp3,"Line# %d: Conflicting types for \'%s\'\n",$1->line, got->name.c_str());
							}
						}
					}
					fprintf(fp4,"%s\n",$$->msg.c_str());	
				}
		| type_specifier ID LPAREN RPAREN compound_statement
		{
			$$ = new SymbolInfo("", "", 2, $1->line, $5->line2, "func_definition : type_specifier ID LPAREN RPAREN compound_statement",$1, $2, $3, $4, $5);
			fprintf(fp4,"%s\n",$$->msg.c_str());	
		}
		| type_specifier ID LPAREN error RPAREN compound_statement
		{		
				SymbolInfo* prb = new SymbolInfo("","",1,$3->line, $3->line2, "parameter_list : error");
				$$ = new SymbolInfo("", "", 2, $1->line, $6->line2, "func_definition : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON",$1, $2, $3, prb, $5, $6);
				fprintf(fp4,"%s\n",$$->msg.c_str());	
		}
 		;				


parameter_list  : parameter_list COMMA type_specifier ID
				{
					$$ = new SymbolInfo("", "", 2, $1->line, $4->line2, "parameter_list : parameter_list COMMA type_specifier ID",$1, $2, $3, $4);
					$4->etype = 3; // it is a parameter
					$4->rtype = $3->name;
					if($1->vec.empty()==false)
						$$->vec.insert($$->vec.end(),$1->vec.begin(), $1->vec.end());
					if($1->fptypes.empty()==false)
						$$->fptypes.insert($$->fptypes.end(),$1->fptypes.begin(), $1->fptypes.end());
					$$->vec.push_back($4);
					$$->fptypes.push_back($3->name);
					table.Insert2($4);
					fprintf(fp4,"%s\n",$$->msg.c_str());	
				}
		| parameter_list COMMA type_specifier			%prec LOWER_THAN_ID
			{
				$$ = new SymbolInfo("", "", 2, $1->line, $3->line2, "parameter_list : parameter_list COMMA type_specifier",$1, $2, $3);
				if($1->vec.empty()==false)
						$$->vec.insert($$->vec.end(),$1->vec.begin(), $1->vec.end());
				if($1->fptypes.empty()==false)
						$$->fptypes.insert($$->fptypes.end(),$1->fptypes.begin(), $1->fptypes.end());
				$$->fptypes.push_back($3->name);
				fprintf(fp4,"%s\n",$$->msg.c_str());	
			}
 		| type_specifier ID
		    {
				$$ = new SymbolInfo("", "", 2, $1->line, $2->line2, "parameter_list : type_specifier ID",$1, $2);
				$2->etype = 3; // it is a parameter
				$2->rtype = $1->name;
				$$->vec.push_back($2);
				$$->fptypes.push_back($1->name);
				table.Insert2($2);
				fprintf(fp4,"%s\n",$$->msg.c_str());	
			}
		| type_specifier	%prec LOWER_THAN_ID
			{
				$$ = new SymbolInfo("", "", 2, $1->line, $1->line2, "parameter_list : type_specifier",$1);
				$$->fptypes.push_back($1->name);
				fprintf(fp4,"%s\n",$$->msg.c_str());	
			}
 		;

 		
compound_statement : LCURL statements RCURL
					{
						$$ = new SymbolInfo("", "", 2, $1->line, $3->line2, "compound_statement : LCURL statements RCURL",$1, $2, $3);
						if($2->vec.empty()==false)
						{
							for(int i=0;i<$2->vec.size();i++)
							{
								table.Delete2($2->vec[i]->name, $2->vec[i]->scope);
							}
						}
						fprintf(fp4,"%s\n",$$->msg.c_str());	
					}
 		    | LCURL RCURL
			{
				$$ = new SymbolInfo("", "", 2, $1->line, $2->line2, "compound_statement : LCURL RCURL",$1, $2);
				fprintf(fp4,"%s\n",$$->msg.c_str());	
			}
			| LCURL error RCURL
			{
				SymbolInfo* prb = new SymbolInfo("","",1,$1->line, $3->line2, "statements : error");
				$$ = new SymbolInfo("", "", 2, $1->line, $3->line2, "compound_statement : LCURL statements RCURL",$1,prb, $3);
				fprintf(fp4,"%s\n",$$->msg.c_str());	
			}
 		    ;
 		    
var_declaration : type_specifier declaration_list SEMICOLON
				{
					$$ = new SymbolInfo("", "", 2, $1->line, $3->line2, "var_declaration : type_specifier declaration_list SEMICOLON",$1, $2, $3);
					$$->vec.insert($$->vec.end(),$2->vec.begin(), $2->vec.end());
					for(int i=0;i<$2->vec.size();i++)
					{
						SymbolInfo* now = $2->vec[i];
						now->rtype = $1->name; 
					}
					if($1->name == "void")
					{
						 fprintf(fp3,"Line# %d: Variable or field \'%s\' declared void\n",$1->line, $2->vec[0]->name.c_str());

					}
					if($2->vec.empty()==false)
					{
					    for(int i=0;i<$2->vec.size();i++)
						{
							SymbolInfo* got = table.LookUp2($2->vec[i]->name, $2->vec[i]->scope);
							if(got!=NULL)
							{
								if(got->rtype != $1->name)
								{
									fprintf(fp3,"Line# %d: Conflicting types for\'%s\'\n",$1->line, got->name.c_str());
								}
							}
						}
					}
					fprintf(fp4,"%s\n",$$->msg.c_str());	
				}
				| type_specifier error SEMICOLON
				{	
					SymbolInfo* prb = new SymbolInfo("","",1,$3->line, $3->line2, "declaration_list : error");
					$$ = new SymbolInfo("", "", 2, $1->line, $3->line2, "var_declaration : type_specifier declaration_list SEMICOLON",$1, prb, $3);
					fprintf(fp4,"%s\n",$$->msg.c_str());	
				}
 			 ;
 		 
type_specifier	: INT 
					{
						$$ = new SymbolInfo("int", "INT", 2, $1->line, $1->line2, "type_specifier : INT",$1);
						fprintf(fp4,"Line# %d: Token <%s> Lexeme %s found\n",$1->line, $1->type.c_str(),$1->name.c_str());
						fprintf(fp4,"type_specifier	: INT\n");
					}
 		| FLOAT 
			{
				$$ = new SymbolInfo("float", "FLOAT", 2, $1->line, $1->line2, "type_specifier : FLOAT",$1);
				fprintf(fp4,"Line# %d: Token <%s> Lexeme %s found\n",$1->line, $1->type.c_str(),$1->name.c_str());
				fprintf(fp4,"type_specifier	: FLOAT\n");
			}
 		| VOID 
			{
				$$ = new SymbolInfo("void", "VOID", 2, $1->line, $1->line2, "type_specifier : VOID",$1);
				fprintf(fp4,"Line# %d: Token <%s> Lexeme %s found\n",$1->line, $1->type.c_str(),$1->name.c_str());
				fprintf(fp4,"type_specifier	: VOID\n");
			}
 		;
 		
declaration_list : declaration_list COMMA ID %prec LOWER_THAN_LTHIRD
					{
						$$ = new SymbolInfo("", "", 2, $1->line, $3->line2, "declaration_list : declaration_list COMMA ID",$1, $2, $3);
						
						SymbolInfo* got = table.LookUp2($3->name, $3->scope);
						if(got!=NULL)
						{
							if($3->rtype != got->rtype)
							{
							   fprintf(fp3,"Line# %d: Conflicting types for\'%s\'\n",$3->line, got->name.c_str());
							}
						}
						
						$3->etype = 1; // it is a normal variable
						$$->vec.insert($$->vec.end(),$1->vec.begin(), $1->vec.end());
						$$->vec.push_back($3);
						table.Insert2($3);
						fprintf(fp4,"Line# %d: Token <%s> Lexeme %s found\n",$2->line, $2->type.c_str(),$2->name.c_str());
						fprintf(fp4,"Line# %d: Token <%s> Lexeme %s found\n",$3->line, $3->type.c_str(),$3->name.c_str());
						//fprintf(fp4,"Line# %d: Token <%s> Lexeme %s found\n",$4->line, $4->type.c_str(),$4->name.c_str());
						fprintf(fp4,"declaration_list : declaration_list COMMA ID\n");
					}
 		  | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD
		 		 {
					$$ = new SymbolInfo("", "", 2, $1->line, $6->line2, "declaration_list : declaration_list COMMA ID LSQUARE CONST_INT RSQUARE",$1, $2, $3, $4, $5, $6);
					$3->etype = 2; // it is an array
					$$->vec.insert($$->vec.end(),$1->vec.begin(), $1->vec.end());
					$$->vec.push_back($3);
					table.Insert2($3);
					fprintf(fp4,"Line# %d: Token <%s> Lexeme %s found\n",$2->line, $2->type.c_str(),$2->name.c_str());
					fprintf(fp4,"Line# %d: Token <%s> Lexeme %s found\n",$3->line, $3->type.c_str(),$3->name.c_str());
					fprintf(fp4,"Line# %d: Token <%s> Lexeme %s found\n",$4->line, $4->type.c_str(),$4->name.c_str());
					fprintf(fp4,"Line# %d: Token <%s> Lexeme %s found\n",$5->line, $5->type.c_str(),$5->name.c_str());
					fprintf(fp4,"Line# %d: Token <%s> Lexeme %s found\n",$6->line, $6->type.c_str(),$6->name.c_str());
					fprintf(fp4,"declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD\n");
				}
 		  | ID %prec LOWER_THAN_LTHIRD
		  		{
					$$ = new SymbolInfo("", "", 2, $1->line, $1->line2, "declaration_list : ID",$1);
					$1->etype = 1; // it is a normal variable
					$$->vec.push_back($1);
					table.Insert2($1);
					fprintf(fp4,"Line# %d: Token <%s> Lexeme %s found\n",$1->line, $1->type.c_str(),$1->name.c_str());
					fprintf(fp4,"declaration_list : ID\n");
				}
 		  | ID LTHIRD CONST_INT RTHIRD
		  	{
				$$ = new SymbolInfo("", "", 2, $1->line, $4->line2, "declaration_list : ID LSQUARE CONST_INT RSQUARE",$1, $2, $3, $4);
				$1->etype = 2; // it is an array
				$$->vec.push_back($1);
				table.Insert2($1);
				fprintf(fp4,"Line# %d: Token <%s> Lexeme %s found\n",$1->line, $1->type.c_str(),$1->name.c_str());
				fprintf(fp4,"Line# %d: Token <%s> Lexeme %s found\n",$2->line, $2->type.c_str(),$2->name.c_str());
				fprintf(fp4,"Line# %d: Token <%s> Lexeme %s found\n",$3->line, $3->type.c_str(),$3->name.c_str());
				fprintf(fp4,"Line# %d: Token <%s> Lexeme %s found\n",$4->line, $4->type.c_str(),$4->name.c_str());
				fprintf(fp4,"declaration_list : ID LTHIRD CONST_INT RTHIRD\n");
			}
 		  ;
 		  
statements : statement
			{
				$$ = new SymbolInfo("", "", 2, $1->line, $1->line2, "statements : statement",$1);
				$$->vec.insert($$->vec.end(),$1->vec.begin(), $1->vec.end());
				fprintf(fp4,"statements : statement\n");
			}
	   | statements statement
	  		{
				$$ = new SymbolInfo("", "", 2, $1->line, $2->line2, "statements : statements statement",$1, $2);
				$$->vec.insert($$->vec.end(),$1->vec.begin(), $1->vec.end());
				$$->vec.insert($$->vec.end(),$2->vec.begin(), $2->vec.end());
				fprintf(fp4,"statements : statements statement\n");
			}
	   ;
	   
statement : var_declaration
			{
				$$ = new SymbolInfo("", "", 2, $1->line, $1->line2, "statement : var_declaration",$1);
				$$->vec.insert($$->vec.end(),$1->vec.begin(), $1->vec.end());
				fprintf(fp4,"statement : var_declaration\n");
			}
	  | expression_statement
	  	{
			$$ = new SymbolInfo("", "", 2, $1->line, $1->line2, "statement : expression_statement",$1);
			fprintf(fp4,"statement : expression_statement\n");
		}
	  | compound_statement
		{
			$$ = new SymbolInfo("", "", 2, $1->line, $1->line2, "statement : compound_statement",$1);
			fprintf(fp4,"statement : compound_statement\n");
		}
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement
	  	{
			$$ = new SymbolInfo("", "", 2, $1->line, $7->line2, "statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement",$1, $2, $3, $4, $5, $6, $7);
			fprintf(fp4,"Line# %d: Token <%s> Lexeme %s found\n",$1->line, $1->type.c_str(),$1->name.c_str());
			fprintf(fp4,"Line# %d: Token <%s> Lexeme %s found\n",$2->line, $2->type.c_str(),$2->name.c_str());
			fprintf(fp4,"Line# %d: Token <%s> Lexeme %s found\n",$6->line, $6->type.c_str(),$6->name.c_str());
			fprintf(fp4,"statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement\n");		
		}
	  | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE
	  	{
			$$ = new SymbolInfo("", "", 2, $1->line, $5->line2, "statement : IF LPAREN expression RPAREN statement",$1, $2, $3, $4, $5);
			fprintf(fp4,"Line# %d: Token <%s> Lexeme %s found\n",$1->line, $1->type.c_str(),$1->name.c_str());
			fprintf(fp4,"Line# %d: Token <%s> Lexeme %s found\n",$2->line, $2->type.c_str(),$2->name.c_str());
			fprintf(fp4,"Line# %d: Token <%s> Lexeme %s found\n",$4->line, $4->type.c_str(),$4->name.c_str());
			fprintf(fp4,"statement : IF LPAREN expression RPAREN statement\n");
		}
	  | IF LPAREN expression RPAREN statement ELSE statement
	  	{
			$$ = new SymbolInfo("", "", 2, $1->line, $7->line2, "statement : IF LPAREN expression RPAREN statement ELSE statement",$1, $2, $3, $4, $5, $6, $7);
			fprintf(fp4,"Line# %d: Token <%s> Lexeme %s found\n",$1->line, $1->type.c_str(),$1->name.c_str());
			fprintf(fp4,"Line# %d: Token <%s> Lexeme %s found\n",$2->line, $2->type.c_str(),$2->name.c_str());
			fprintf(fp4,"Line# %d: Token <%s> Lexeme %s found\n",$4->line, $4->type.c_str(),$4->name.c_str());
			fprintf(fp4,"Line# %d: Token <%s> Lexeme %s found\n",$6->line, $6->type.c_str(),$6->name.c_str());
			fprintf(fp4,"statement : IF LPAREN expression RPAREN statement ELSE statement\n");
		}
	  | WHILE LPAREN expression RPAREN statement
	  	{
			$$ = new SymbolInfo("", "", 2, $1->line, $5->line2, "statement : WHILE LPAREN expression RPAREN statement",$1, $2, $3, $4, $5);
			fprintf(fp4,"Line# %d: Token <%s> Lexeme %s found\n",$1->line, $1->type.c_str(),$1->name.c_str());
			fprintf(fp4,"Line# %d: Token <%s> Lexeme %s found\n",$2->line, $2->type.c_str(),$2->name.c_str());
			fprintf(fp4,"Line# %d: Token <%s> Lexeme %s found\n",$4->line, $4->type.c_str(),$4->name.c_str());
			fprintf(fp4,"%s\n",$$->msg.c_str());		
		}
	  | PRINTLN LPAREN ID RPAREN SEMICOLON
	  	{
			$$ = new SymbolInfo("", "", 2, $1->line, $5->line2, "statement : PRINTLN LPAREN ID RPAREN SEMICOLON",$1, $2, $3, $4, $5);
			fprintf(fp4,"Line# %d: Token <%s> Lexeme %s found\n",$1->line, $1->type.c_str(),$1->name.c_str());
			fprintf(fp4,"Line# %d: Token <%s> Lexeme %s found\n",$2->line, $2->type.c_str(),$2->name.c_str());
			fprintf(fp4,"Line# %d: Token <%s> Lexeme %s found\n",$3->line, $3->type.c_str(),$3->name.c_str());
			fprintf(fp4,"Line# %d: Token <%s> Lexeme %s found\n",$4->line, $4->type.c_str(),$4->name.c_str());
			fprintf(fp4,"Line# %d: Token <%s> Lexeme %s found\n",$5->line, $5->type.c_str(),$5->name.c_str());
			fprintf(fp4,"%s\n",$$->msg.c_str());	
		}
	  | RETURN expression SEMICOLON
	  	{
			$$ = new SymbolInfo("", "", 2, $1->line, $3->line2, "statement : RETURN expression SEMICOLON",$1, $2, $3);
			fprintf(fp4,"Line# %d: Token <%s> Lexeme %s found\n",$1->line, $1->type.c_str(),$1->name.c_str());
			fprintf(fp4,"Line# %d: Token <%s> Lexeme %s found\n",$3->line, $3->type.c_str(),$3->name.c_str());
			fprintf(fp4,"%s\n",$$->msg.c_str());	
		}
	  ;
	  
expression_statement 	: SEMICOLON	
						{
							$$ = new SymbolInfo("", "", 2, $1->line, $1->line2, "expression_statement : SEMICOLON",$1);
							fprintf(fp4,"Line# %d: Token <%s> Lexeme %s found\n",$1->line, $1->type.c_str(),$1->name.c_str());
							fprintf(fp4,"%s\n",$$->msg.c_str());	
						}		
			| expression SEMICOLON 
						{
							$$ = new SymbolInfo("", "", 2, $1->line, $2->line2, "expression_statement : expression SEMICOLON",$1, $2);
							if($1->argtypes.empty()==false)
								$$->argtypes.insert($$->argtypes.end(),$1->argtypes.begin(), $1->argtypes.end());
							fprintf(fp4,"Line# %d: Token <%s> Lexeme %s found\n",$2->line, $2->type.c_str(),$2->name.c_str());
							fprintf(fp4,"%s\n",$$->msg.c_str());	
						}
			| error SEMICOLON 
						{	
							SymbolInfo* prb = new SymbolInfo("","",1,$2->line, $2->line2, "expression : error");
							$$ = new SymbolInfo("", "", 2, $1->line, $2->line2, "expression_statement : expression SEMICOLON",prb, $2);
							fprintf(fp4,"Line# %d: Token <%s> Lexeme %s found\n",$2->line, $2->type.c_str(),$2->name.c_str());
							fprintf(fp4,"%s\n",$$->msg.c_str());	
						}

						
			;
	  
variable : ID 	%prec LOWER_THAN_LTHIRD
				{
					$$ = new SymbolInfo("", "", 2, $1->line, $1->line2, "variable : ID",$1);
					//cout<<"variable : ID"<<endl;
					SymbolInfo* got = table.LookUp2($1->name, $1->scope);
					if(got == NULL)
					{
						got = table.LookUp2($1->name, $1->scope-1);
					}
					if(got == NULL)
					{
						fprintf(fp3,"Line# %d: Undeclared variable \'%s\'\n",$1->line, $1->name.c_str());
					}
					else
					{
						if(got->rtype == "void")
						{
							fprintf(fp3,"Line# %d: Void cannot be used in expression \n",$1->line);

						}
						// got mane ei jinish age jokhon declare hoise tokhon entry paise
						$$->argtypes.push_back(got->rtype);			
					}
					fprintf(fp4,"Line# %d: Token <%s> Lexeme %s found\n",$1->line, $1->type.c_str(),$1->name.c_str());
					fprintf(fp4,"%s\n",$$->msg.c_str());		
				}	
	 | ID LTHIRD expression RTHIRD 
	 	{	
			$$ = new SymbolInfo("", "", 2, $1->line, $4->line2, "variable : ID LSQUARE expression RSQUARE",$1, $2, $3, $4);
			SymbolInfo* now = table.LookUp2($1->name, $1->scope);
			if(now == NULL)
				now = table.LookUp2($1->name, $1->scope-1);
			if(now == NULL)
				{
					fprintf(fp3,"Line# %d: Undeclared variable \'%s\'\n",$1->line, $1->name.c_str());
				}
			else{
				int type = now->etype;
				if(type != 2)
				{
					fprintf(fp3,"Line# %d: \'%s\' is not an array\n",$1->line, $1->name.c_str());

				}
				$$->argtypes.push_back(now->rtype);
			}
			if($3->argtypes.empty()==false)
			{
				if($3->argtypes[0] != "int")
				{
					fprintf(fp3,"Line# %d: Array subscript is not an integer\n",$1->line);
				}
			}
			fprintf(fp4,"Line# %d: Token <%s> Lexeme %s found\n",$1->line, $1->type.c_str(),$1->name.c_str());
			fprintf(fp4,"Line# %d: Token <%s> Lexeme %s found\n",$2->line, $2->type.c_str(),$2->name.c_str());
			fprintf(fp4,"Line# %d: Token <%s> Lexeme %s found\n",$4->line, $4->type.c_str(),$4->name.c_str());
			fprintf(fp4,"%s\n",$$->msg.c_str());	
		}
		| ID LTHIRD error RTHIRD 
			{	
				SymbolInfo* prb = new SymbolInfo("","",1,$2->line, $2->line2, "expression : error");
				$$ = new SymbolInfo("", "", 2, $1->line, $4->line2, "variable : ID LSQUARE expression RSQUARE",prb, $1,$2,prb,$4);
				fprintf(fp4,"%s\n",$$->msg.c_str());	
			}

	 ;
	 
 expression : logic_expression
			{	$$ = new SymbolInfo("", "", 2, $1->line, $1->line2, "expression : logic_expression",$1);
				if($1->argtypes.empty()==false)
					$$->argtypes.insert($$->argtypes.end(),$1->argtypes.begin(), $1->argtypes.end());
				fprintf(fp4,"%s\n",$$->msg.c_str());	
			}
	   | variable ASSIGNOP logic_expression 
	   {	$$ = new SymbolInfo("", "", 2, $1->line, $3->line2, "expression : variable ASSIGNOP logic_expression",$1, $2, $3);
			if($3->voidFunc.empty()==false)
				{	
					for(int i=0;i<$3->voidFunc.size();i++)
						if($3->voidFunc[i]->rtype == "void")
						{
							fprintf(fp3,"Line# %d: Void cannot be used in expression \n",$2->line);
						}	
				}
				if($1->argtypes.empty()==false && $3->argtypes.empty()==false)
				{
					if($1->argtypes[0] =="int" && $3->argtypes[0] =="float")
					{
						fprintf(fp3,"Line# %d: Warning: possible loss of data in assignment of FLOAT to INT\n",$2->line);
					}
				}
			if($1->argtypes.empty()==false)
					$$->argtypes.insert($$->argtypes.end(),$1->argtypes.begin(), $1->argtypes.end());
			fprintf(fp4,"Line# %d: Token <%s> Lexeme %s found\n",$2->line, $2->type.c_str(),$2->name.c_str());
	  		fprintf(fp4,"%s\n",$$->msg.c_str());	
	   }	
	   ;
			
logic_expression : rel_expression 	%prec LOWER_THAN_LOGICOP
					{	
						$$ = new SymbolInfo("", "", 2, $1->line, $1->line2, "logic_expression : rel_expression",$1);
						if($1->voidFunc.empty()==false) $$->voidFunc.insert($$->voidFunc.end(),$1->voidFunc.begin(), $1->voidFunc.end());
						if($1->argtypes.empty()==false)
							$$->argtypes.insert($$->argtypes.end(),$1->argtypes.begin(), $1->argtypes.end());
						fprintf(fp4,"%s\n",$$->msg.c_str());	
					}
		 | rel_expression LOGICOP rel_expression
		 		{	
					$$ = new SymbolInfo("", "", 2, $1->line, $3->line2, "logic_expression : rel_expression LOGICOP rel_expression",$1, $2, $3);
					if($1->voidFunc.empty()==false) $$->voidFunc.insert($$->voidFunc.end(),$1->voidFunc.begin(), $1->voidFunc.end());
					if($3->voidFunc.empty()==false) $$->voidFunc.insert($$->voidFunc.end(),$3->voidFunc.begin(), $3->voidFunc.end());
					$$->argtypes.push_back("int");
					fprintf(fp4,"Line# %d: Token <%s> Lexeme %s found\n",$2->line, $2->type.c_str(),$2->name.c_str());
					fprintf(fp4,"%s\n",$$->msg.c_str());	
				} 	
		 ;
			
rel_expression	: simple_expression %prec LOWER_THAN_RELOP
				{	
					$$ = new SymbolInfo("", "", 2, $1->line, $1->line2, "rel_expression : simple_expression",$1);
					if($1->voidFunc.empty()==false) $$->voidFunc.insert($$->voidFunc.end(),$1->voidFunc.begin(), $1->voidFunc.end());
					if($1->argtypes.empty()==false)
						$$->argtypes.insert($$->argtypes.end(),$1->argtypes.begin(), $1->argtypes.end());
					fprintf(fp4,"%s\n",$$->msg.c_str());	
				}
		| simple_expression RELOP simple_expression	
			{	
					$$ = new SymbolInfo("", "", 2, $1->line, $3->line2, "rel_expression : simple_expression RELOP simple_expression",$1, $2, $3);
					if($1->voidFunc.empty()==false) $$->voidFunc.insert($$->voidFunc.end(),$1->voidFunc.begin(), $1->voidFunc.end());
					if($3->voidFunc.empty()==false) $$->voidFunc.insert($$->voidFunc.end(),$3->voidFunc.begin(), $3->voidFunc.end());
					$$->argtypes.push_back("int");// 0 or 1 jabe
					fprintf(fp4,"Line# %d: Token <%s> Lexeme %s found\n",$2->line, $2->type.c_str(),$2->name.c_str());
					fprintf(fp4,"%s\n",$$->msg.c_str());	
			}
		;
				
simple_expression : term
					{	
						$$ = new SymbolInfo("", "", 2, $1->line, $1->line2, "simple_expression : term",$1);
						if($1->voidFunc.empty()==false) $$->voidFunc.insert($$->voidFunc.end(),$1->voidFunc.begin(), $1->voidFunc.end());
						if($1->argtypes.empty()==false)
							$$->argtypes.insert($$->argtypes.end(),$1->argtypes.begin(), $1->argtypes.end());
				   		fprintf(fp4,"%s\n",$$->msg.c_str());	
				    }
		  | simple_expression ADDOP term 
		  {	
				$$ = new SymbolInfo("", "", 2, $1->line, $3->line2, "simple_expression : simple_expression ADDOP term",$1, $2, $3);
				
				if($1->voidFunc.empty()==false) $$->voidFunc.insert($$->voidFunc.end(),$1->voidFunc.begin(), $1->voidFunc.end());
				if($3->voidFunc.empty()==false) $$->voidFunc.insert($$->voidFunc.end(),$3->voidFunc.begin(), $3->voidFunc.end());
		  		if($1->argtypes.empty()==false && $3->argtypes.empty()==false)
				{
					if($1->argtypes[0]=="int" && $3->argtypes[0]=="int")
						$$->argtypes.push_back("int");
					else if($1->argtypes[0]=="int" && $3->argtypes[0]=="float")
						$$->argtypes.push_back("float");
					else if($1->argtypes[0]=="float" && $3->argtypes[0]=="int")
						$$->argtypes.push_back("float");
					else if($1->argtypes[0]=="float" && $3->argtypes[0]=="float")
						$$->argtypes.push_back("float");
				}
				fprintf(fp4,"Line# %d: Token <%s> Lexeme %s found\n",$2->line, $2->type.c_str(),$2->name.c_str());
		  	fprintf(fp4,"%s\n",$$->msg.c_str());	
		  }
		  ;
					
term :	unary_expression
	  	{	
			$$ = new SymbolInfo("", "", 2, $1->line, $1->line2, "term : unary_expression",$1);
			if($1->voidFunc.empty()==false)
			{
				$$->voidFunc.insert($$->voidFunc.end(),$1->voidFunc.begin(), $1->voidFunc.end());
			}
			if($1->argtypes.empty()==false)
						$$->argtypes.insert($$->argtypes.end(),$1->argtypes.begin(), $1->argtypes.end());
			fprintf(fp4,"%s\n",$$->msg.c_str());	
		}
     |  term MULOP unary_expression
	    {	
			$$ = new SymbolInfo("", "", 2, $1->line, $3->line2, "term : term MULOP unary_expression",$1, $2, $3);
			if($1->voidFunc.empty()==false)
			{
				$$->voidFunc.insert($$->voidFunc.end(),$1->voidFunc.begin(), $1->voidFunc.end());
			}
			if($3->voidFunc.empty()==false)
			{
				$$->voidFunc.insert($$->voidFunc.end(),$3->voidFunc.begin(), $3->voidFunc.end());
			}
			if(($2->name == "%" || $2->name == "\/") && ($3->name=="0"))
			{
				fprintf(fp3,"Line# %d: Warning: division by zero i=0f=1Const=0\n",$1->line);
			}
			if(($2->name == "%") && ($3->argtypes.empty()==false) && ($3->argtypes[0] == "float"))
			{
				fprintf(fp3,"Line# %d: Operands of modulus must be integers \n",$1->line);
			}

			fprintf(fp4,"Line# %d: Token <%s> Lexeme %s found\n",$2->line, $2->type.c_str(),$2->name.c_str());
			if($1->argtypes.empty()==false && $3->argtypes.empty()==false)
			{
				if($1->argtypes[0]=="int" && $3->argtypes[0]=="int")
					$$->argtypes.push_back("int");
				else if($1->argtypes[0]=="int" && $3->argtypes[0]=="float")
					$$->argtypes.push_back("float");
				else if($1->argtypes[0]=="float" && $3->argtypes[0]=="int")
					$$->argtypes.push_back("float");
				else if($1->argtypes[0]=="float" && $3->argtypes[0]=="float")
					$$->argtypes.push_back("float");
			}

			fprintf(fp4,"%s\n",$$->msg.c_str());	


		}
     ;

unary_expression : ADDOP unary_expression 
				{	
					$$ = new SymbolInfo("", "", 2, $1->line, $2->line2, "unary_expression : ADDOP unary_expression",$1, $2);
					if($2->voidFunc.empty()==false)
					{
						$$->voidFunc.insert($$->voidFunc.end(),$2->voidFunc.begin(), $2->voidFunc.end());
					}
					fprintf(fp4,"Line# %d: Token <%s> Lexeme %s found\n",$1->line, $1->type.c_str(),$1->name.c_str());
					fprintf(fp4,"%s\n",$$->msg.c_str());	
				}
		 | NOT unary_expression 
				 {	
					$$ = new SymbolInfo("", "", 2, $1->line, $2->line2, "unary_expression : LOGICOP unary_expression",$1, $2);
					if($2->voidFunc.empty()==false)
					{
						$$->voidFunc.insert($$->voidFunc.end(),$2->voidFunc.begin(), $2->voidFunc.end());
					}
					fprintf(fp4,"Line# %d: Token <%s> Lexeme %s found\n",$1->line, $1->type.c_str(),$1->name.c_str());
					fprintf(fp4,"%s\n",$$->msg.c_str());	
				}
		 | factor 
				 {	
					$$ = new SymbolInfo($1->name, "", 2, $1->line, $1->line2, "unary_expression : factor",$1);
					if($1->voidFunc.empty()==false)
					{
						$$->voidFunc.insert($$->voidFunc.end(),$1->voidFunc.begin(), $1->voidFunc.end());

					}
					if($1->argtypes.empty()==false)
						$$->argtypes.insert($$->argtypes.end(),$1->argtypes.begin(), $1->argtypes.end());
					fprintf(fp4,"%s\n",$$->msg.c_str());	
				}
		 ;
	
factor	: variable
		{	
			$$ = new SymbolInfo("", "", 2, $1->line, $1->line2, "factor : variable",$1);
			if($1->argtypes.empty()==false)
				$$->argtypes.insert($$->argtypes.end(),$1->argtypes.begin(), $1->argtypes.end());
			fprintf(fp4,"%s\n",$$->msg.c_str());	
		}
	| ID LPAREN argument_list RPAREN
		{	
			$$ = new SymbolInfo("", "", 2, $1->line, $4->line2, "factor : ID LPAREN argument_list RPAREN",$1, $2, $3, $4);
			SymbolInfo* got = table.LookUp($1->name);
			if(got == NULL)
			{
				fprintf(fp3,"Line# %d: Undeclared function \'%s\'\n",$1->line, $1->name.c_str());
			}
			else
			{
				$$->voidFunc.push_back(got);
				$$->argtypes.push_back(got->rtype);
				int check1 = 0;
				int check2 = 0;
				if(got->fptypes.empty()==false) check1 = got->fptypes.size();
				if($3->argtypes.empty()==false) check2 = $3->argtypes.size();
				if(check1>check2)
				{
					fprintf(fp3,"Line# %d: Too few arguments to function \'%s\'\n",$1->line, got->name.c_str());
				}
				else if(check1<check2)
				{
					fprintf(fp3,"Line# %d: Too many arguments to function \'%s\'\n",$1->line, got->name.c_str());
				}
				else
				{
					if(check1 !=0)
					{
						for(int i=0;i<got->fptypes.size();i++)
						{
							if(got->fptypes[i] != $3->argtypes[i])
							{
								fprintf(fp3,"Line# %d: Type mismatch for argument %d of \'%s\'\n",$1->line,i+1, got->name.c_str());
							}
						}
					}
				}
			}
			fprintf(fp4,"Line# %d: Token <%s> Lexeme %s found\n",$1->line, $1->type.c_str(),$1->name.c_str());
			fprintf(fp4,"Line# %d: Token <%s> Lexeme %s found\n",$2->line, $2->type.c_str(),$2->name.c_str());
			fprintf(fp4,"Line# %d: Token <%s> Lexeme %s found\n",$4->line, $4->type.c_str(),$4->name.c_str());
			fprintf(fp4,"%s\n",$$->msg.c_str());	
		}
	| LPAREN expression RPAREN
		{	
			$$ = new SymbolInfo("", "", 2, $1->line, $3->line2, "factor : LPAREN expression RPAREN",$1, $2, $3);
			fprintf(fp4,"Line# %d: Token <%s> Lexeme %s found\n",$1->line, $1->type.c_str(),$1->name.c_str());
			fprintf(fp4,"Line# %d: Token <%s> Lexeme %s found\n",$3->line, $3->type.c_str(),$3->name.c_str());
			fprintf(fp4,"%s\n",$$->msg.c_str());	
		}
	| CONST_INT 
		{	
			$$ = new SymbolInfo($1->name, "", 2, $1->line, $1->line2, "factor : CONST_INT",$1);
			$$->argtypes.push_back("int");
			fprintf(fp4,"Line# %d: Token <%s> Lexeme %s found\n",$1->line, $1->type.c_str(),$1->name.c_str());
			fprintf(fp4,"%s\n",$$->msg.c_str());	
		}
	| CONST_FLOAT
		{	
			$$ = new SymbolInfo($1->name, "", 2, $1->line, $1->line2, "factor : CONST_FLOAT",$1);
			$$->argtypes.push_back("float");
			fprintf(fp4,"Line# %d: Token <%s> Lexeme %s found\n",$1->line, $1->type.c_str(),$1->name.c_str());
			fprintf(fp4,"%s\n",$$->msg.c_str());	
		}
	| variable INCOP 
		{	
			$$ = new SymbolInfo("", "", 2, $1->line, $2->line2, "factor : variable INCOP",$1, $2);
			if($1->argtypes.empty()==false)
				$$->argtypes.insert($$->argtypes.end(),$1->argtypes.begin(), $1->argtypes.end());
			fprintf(fp4,"Line# %d: Token <%s> Lexeme %s found\n",$2->line, $2->type.c_str(),$2->name.c_str());
			fprintf(fp4,"%s\n",$$->msg.c_str());	
		}
	| variable DECOP
		{	
			$$ = new SymbolInfo("", "", 2, $1->line, $2->line2, "factor : variable DECOP",$1, $2);
			if($1->argtypes.empty()==false)
				$$->argtypes.insert($$->argtypes.end(),$1->argtypes.begin(), $1->argtypes.end());
			fprintf(fp4,"Line# %d: Token <%s> Lexeme %s found\n",$2->line, $2->type.c_str(),$2->name.c_str());
			fprintf(fp4,"%s\n",$$->msg.c_str());	
		}
	;
	
argument_list : arguments
				{	
					$$ = new SymbolInfo("", "", 2, $1->line, $1->line2, "argument_list : arguments",$1);
					if($1->argtypes.empty()==false)
						$$->argtypes.insert($$->argtypes.end(),$1->argtypes.begin(), $1->argtypes.end());
					fprintf(fp4,"%s\n",$$->msg.c_str());	
				}
			  |
			  ;
	
arguments : arguments COMMA logic_expression
				{	
					$$ = new SymbolInfo("", "", 2, $1->line, $3->line2, "arguments : arguments COMMA logic_expression",$1, $2, $3);
					if($1->argtypes.empty()==false)
						$$->argtypes.insert($$->argtypes.end(),$1->argtypes.begin(), $1->argtypes.end());
					if($3->argtypes.empty()==false)
						$$->argtypes.insert($$->argtypes.end(),$3->argtypes.begin(), $3->argtypes.end());
					fprintf(fp4,"Line# %d: Token <%s> Lexeme %s found\n",$2->line, $2->type.c_str(),$2->name.c_str());
					fprintf(fp4,"%s\n",$$->msg.c_str());	
				}
	      | logic_expression
		  		{	
					$$ = new SymbolInfo("", "", 2, $1->line, $1->line2, "arguments : logic_expression",$1);
					if($1->argtypes.empty()==false)
						$$->argtypes.insert($$->argtypes.end(),$1->argtypes.begin(), $1->argtypes.end());
					fprintf(fp4,"%s\n",$$->msg.c_str());	
				}
	      ;
 

%%

void func(SymbolInfo* now, int loopNum)
{
	if(now == NULL) return;
	for(int i=1;i<=loopNum;i++) fprintf(fp2," ");
	fprintf(fp2,"%s",now->msg.c_str());
	if(now->nodeType==1)
	{
		fprintf(fp2,"	<Line: %d>\n", now->line);
	}
	else
	{
		fprintf(fp2," 	<Line: %d-%d>\n", now->line, now->line2);
	}

	stck.push(now);

	func(now->ch1, loopNum+1);
	func(now->ch2, loopNum+1);
	func(now->ch3, loopNum+1);
	func(now->ch4, loopNum+1);
	func(now->ch5, loopNum+1);
	func(now->ch6, loopNum+1);
	func(now->ch7, loopNum+1);
}
int main(int argc,char *argv[])
{	
	table.EnterScope(100);

	if((fp=fopen(argv[1],"r"))==NULL)
	{
		printf("Cannot Open Input File.\n");
		exit(1);
	}

	fp2= fopen(argv[2],"w");
	//fclose(fp2);
	fp3= fopen(argv[3],"w");
	//fclose(fp3);
	
	//fp2= fopen(argv[2],"a");
	//fp3= fopen(argv[3],"a");
	
	fp4= fopen(argv[4],"w");

	yyin=fp;
	yyparse();

	//cout<<mainJinish->line<<"	"<<mainJinish->line2<<endl;
	func(mainJinish, 0);

	fclose(fp2);
	fclose(fp3);
	fclose(fp4);
	while(stck.empty()==false)
	{
		SymbolInfo* soFar = stck.top();
		stck.pop();
		delete soFar;
	}
	
	return 0;
}

