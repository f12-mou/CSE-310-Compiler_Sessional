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
FILE* fp5;
FILE* fp6;
FILE* fp7;
FILE* fp8;


SymbolTable table;
SymbolInfo* mainJinish;
stack<SymbolInfo*>stck;

vector<int>ReplaceCandidate;
map<int,int>labelMap;



int isForLoop=0;
int scopeGlobal=1;
int isCodePrinted=0;
int minusTotal=0;
int labelCnt=1; 
int currOffset=0;
int lineNoTempFile=0;
int returnLabel=-1;
int currIdx=0;
string currGlobalVarName="";
vector<string>globalVariables;
vector<string>globalVariablesArray;


void yyerror(char *s)
{
	//write your code
}


%}

%token ID LPAREN RPAREN SEMICOLON COMMA LCURL RCURL INT FLOAT VOID LTHIRD RTHIRD FOR IF ELSE WHILE PRINTLN RETURN ASSIGNOP LOGICOP RELOP ADDOP MULOP NOT CONST_INT CONST_FLOAT INCOP DECOP

%destructor{free($$);} ID LPAREN RPAREN SEMICOLON COMMA LCURL RCURL INT FLOAT VOID LTHIRD RTHIRD FOR IF ELSE WHILE PRINTLN RETURN ASSIGNOP LOGICOP RELOP ADDOP MULOP NOT CONST_INT CONST_FLOAT INCOP DECOP

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
	}
	;

program : program unit 
	{
		$$ = new SymbolInfo("", "", 2, $1->line, $2->line2, "program : program unit",$1, $2);
	}
	| unit 
	{
		$$ = new SymbolInfo("", "", 2, $1->line, $1->line2, "program : unit",$1);
	}
	;
	
unit : var_declaration
		{
			$$ = new SymbolInfo("", "", 2, $1->line, $1->line2, "unit : var_declaration",$1);
		}
     | func_declaration
		{
			$$ = new SymbolInfo("", "", 2, $1->line, $1->line2, "unit : func_declaration",$1);
		}
     | func_definition
	 	{
			$$ = new SymbolInfo("", "", 2, $1->line, $1->line2, "unit : func_definition",$1);
		}
     ;
     
func_declaration : type_specifier ID LPAREN  parameter_list RPAREN SEMICOLON 
					{
					$$ = new SymbolInfo("", "", 2, $1->line, $6->line2, "func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON",$1, $2, $3, $4, $5, $6);
					$2->fptypes.insert($2->fptypes.end(),$4->fptypes.begin(), $4->fptypes.end());

					SymbolInfo* got = table.LookUp($2->name);
					if(got == NULL)
					{
						$2->etype = 4; // entry type 4 so it is a function
						$2->rtype = $1->name;
						$2->vec.insert($2->vec.end(),$4->vec.begin(), $4->vec.end());
						table.Insert2($2);
					}
					else
					{
						int insertedType = got->etype;
					}
					
					$$->vec.insert($$->vec.end(),$4->vec.begin(), $4->vec.end());
					int len = $$->vec.size();
				}
		| type_specifier ID LPAREN RPAREN SEMICOLON
		{
			$$ = new SymbolInfo("", "", 2, $1->line, $5->line2, "func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON",$1, $2, $3, $4, $5);
		}
		| type_specifier ID LPAREN error RPAREN SEMICOLON
		{		
				SymbolInfo* prb = new SymbolInfo("","",1,$3->line, $3->line2, "parameter_list : error");
				$$ = new SymbolInfo("", "", 2, $1->line, $6->line2, "func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON",$1, $2, $3, prb, $5, $6);
		}
		;

func_definition :type_specifier ID  LPAREN parameter_list RPAREN
				{	
					scopeGlobal=0;
					table.EnterScope(100);
					if(isCodePrinted==0)
					{
						isCodePrinted=1;
						lineNoTempFile++;fprintf(fp5,".CODE\n");
					}
					lineNoTempFile++;fprintf(fp5,"%s PROC\n",$2->name.c_str());
					lineNoTempFile++;fprintf(fp5,"\tPUSH BP\n");
					lineNoTempFile++;fprintf(fp5,"\tMOV BP, SP\n");
					int start=4;// for setting parameter offset of [BP+offset]
					for(int i=$4->vec.size()-1;i>=0;i--)
					{
						table.Insert($4->vec[i]->name);
						SymbolInfo* gotVariable=table.LookUp($4->vec[i]->name);
						if(gotVariable!=NULL)
						{
							gotVariable->isParam=1;
							gotVariable->paramOffset=start;
							start+=2;
						}
					}
					minusTotal=0;
				}
				compound_statement
				{

					$$ = new SymbolInfo("", "", 2, $1->line, $7->line2, "func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement",$1, $2, $3, $4, $5, $7);
					$$->vec.insert($$->vec.end(),$4->vec.begin(), $4->vec.end());
					$2->fptypes.insert($2->fptypes.end(),$4->fptypes.begin(), $4->fptypes.end());
					int len = $$->vec.size();

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
					}
					if(returnLabel!=-1)
					{
						lineNoTempFile++;	fprintf(fp5,"L%d:\n",returnLabel);
					}
					if(minusTotal!=0)
						lineNoTempFile++;	fprintf(fp5,"\tADD SP, %d\n",minusTotal);
					lineNoTempFile++;	fprintf(fp5,"\tPOP BP\n");
					lineNoTempFile++;	fprintf(fp5,"\tRET %d\n",$4->vec.size()*2);
					lineNoTempFile++;	fprintf(fp5,"%s ENDP\n",$2->name.c_str());
					scopeGlobal=1;
					returnLabel=-1;
					table.ExitScope();
				}
		| type_specifier ID LPAREN RPAREN 
		{
			scopeGlobal=0;
			table.EnterScope(100);
			if($2->name=="main")
			{
				lineNoTempFile++;fprintf(fp5,"%s PROC\n",$2->name.c_str());
				lineNoTempFile++;fprintf(fp5,"\tMOV AX, @DATA\n");
				lineNoTempFile++;fprintf(fp5,"\tMOV DS, AX\n");
				lineNoTempFile++;fprintf(fp5,"\tPUSH BP\n");
				lineNoTempFile++;fprintf(fp5,"\tMOV BP, SP\n");
			}
			else
			{	
				lineNoTempFile++;fprintf(fp5,"%s PROC\n",$2->name.c_str());
				lineNoTempFile++;fprintf(fp5,"\tPUSH BP\n");
				lineNoTempFile++;fprintf(fp5,"\tMOV BP, SP\n");
			}
			minusTotal=0;
		} compound_statement
		{
			$$ = new SymbolInfo("", "", 2, $1->line, $6->line2, "func_definition : type_specifier ID LPAREN RPAREN compound_statement",$1, $2, $3, $4, $6);
		}
		{
			if($2->name=="main")
			{	
				if(returnLabel!=-1)
				{
					lineNoTempFile++;	fprintf(fp5,"L%d:\n",returnLabel);
				}
				lineNoTempFile++;	fprintf(fp5,"\tADD SP, %d\n",minusTotal);
				lineNoTempFile++;	fprintf(fp5,"\tPOP BP\n");
				lineNoTempFile++;	fprintf(fp5,"\tMOV AX,4CH\n");
				lineNoTempFile++;	fprintf(fp5,"\tINT 21H\n");
				lineNoTempFile++;	fprintf(fp5,"%s ENDP\n",$2->name.c_str());
				
			}
			else
			{	
				if(returnLabel!=-1)
				{
					lineNoTempFile++;	fprintf(fp5,"L%d:\n",returnLabel);
				}
				lineNoTempFile++;	fprintf(fp5,"\tADD SP, %d\n",minusTotal);
				lineNoTempFile++;	fprintf(fp5,"\tPOP BP\n");
				lineNoTempFile++;	fprintf(fp5,"\tRET\n");
				lineNoTempFile++;	fprintf(fp5,"%s ENDP\n",$2->name.c_str());
			}
			table.ExitScope();
			scopeGlobal=1;
			returnLabel=-1;
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
					if(scopeGlobal==0)
						table.Insert2($4);// parameter pore offset shoho insert korbo, apatoto baad
				}
		| parameter_list COMMA type_specifier			%prec LOWER_THAN_ID
			{
				$$ = new SymbolInfo("", "", 2, $1->line, $3->line2, "parameter_list : parameter_list COMMA type_specifier",$1, $2, $3);
				if($1->vec.empty()==false)
						$$->vec.insert($$->vec.end(),$1->vec.begin(), $1->vec.end());
				if($1->fptypes.empty()==false)
						$$->fptypes.insert($$->fptypes.end(),$1->fptypes.begin(), $1->fptypes.end());
				$$->fptypes.push_back($3->name);
			}
 		| type_specifier ID
		    {
				$$ = new SymbolInfo("", "", 2, $1->line, $2->line2, "parameter_list : type_specifier ID",$1, $2);
				$2->etype = 3; // it is a parameter
				$2->rtype = $1->name;
				$$->vec.push_back($2);
				$$->fptypes.push_back($1->name);
				if(scopeGlobal==0)
					table.Insert2($2);// parameter pore offset shoho insert korbo, apatoto baad
			}
		| type_specifier	%prec LOWER_THAN_ID
			{
				$$ = new SymbolInfo("", "", 2, $1->line, $1->line2, "parameter_list : type_specifier",$1);
				$$->fptypes.push_back($1->name);
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
						if($2->nextList.empty()==false)
							$$->nextList.insert($$->nextList.end(),$2->nextList.begin(), $2->nextList.end());
					}
 		    | LCURL RCURL
			{
				$$ = new SymbolInfo("", "", 2, $1->line, $2->line2, "compound_statement : LCURL RCURL",$1, $2);
			}
			| LCURL error RCURL
			{
				SymbolInfo* prb = new SymbolInfo("","",1,$1->line, $3->line2, "statements : error");
				$$ = new SymbolInfo("", "", 2, $1->line, $3->line2, "compound_statement : LCURL statements RCURL",$1,prb, $3);
			}
 		    ;
 		    
var_declaration : type_specifier declaration_list SEMICOLON
				{
					$$ = new SymbolInfo("", "", 2, $1->line, $3->line2, "var_declaration : type_specifier declaration_list SEMICOLON",$1, $2, $3);
					$$->vec.insert($$->vec.end(),$2->vec.begin(), $2->vec.end());
					for(int i=0;i<$2->vec.size();i++)
					{
						SymbolInfo* now = $2->vec[i];
						now->rtype = $1->name; //int
						if(scopeGlobal==1)
						{	
							if(now->etype==1)
							{
								lineNoTempFile++;fprintf(fp5,"\t%s DW 1 DUP (0000H)\n",now->name.c_str());
								globalVariables.push_back(now->name);// global variable
							}
							else
							{
								lineNoTempFile++;fprintf(fp5,"\t%s DW %d DUP (0000H)\n",now->name.c_str(),now->esize);
								globalVariablesArray.push_back(now->name);//global array
							}
							
						}
						else
						{
							// local variables
							if($2->vec[i]->etype==1)
							{
							lineNoTempFile++;	fprintf(fp5,"\tSUB SP, 2\n");
							 minusTotal+=2;
							now->offset=minusTotal;
							//cout<<"now offset is set for "<<now->name<<" "<<minusTotal<<endl;
							}
							else
							{
								int arraySize=now->esize;
								int nowMinus=arraySize*2;
								now->offset=minusTotal+2;
								minusTotal+=nowMinus;
								//cout<<"here "<<now->name<<" "<<now->esize<<endl;
								lineNoTempFile++;	fprintf(fp5,"\tSUB SP, %d\n",nowMinus);

							}
						}
						
					}	
				}
 			 ;
 		 
type_specifier	: INT 
					{
						$$ = new SymbolInfo("int", "INT", 2, $1->line, $1->line2, "type_specifier : INT",$1);
					}
 		| FLOAT 
			{
				$$ = new SymbolInfo("float", "FLOAT", 2, $1->line, $1->line2, "type_specifier : FLOAT",$1);
			}
 		| VOID 
			{
				$$ = new SymbolInfo("void", "VOID", 2, $1->line, $1->line2, "type_specifier : VOID",$1);
			}
 		;
 		
declaration_list : declaration_list COMMA ID %prec LOWER_THAN_LTHIRD
					{
						$$ = new SymbolInfo("", "", 2, $1->line, $3->line2, "declaration_list : declaration_list COMMA ID",$1, $2, $3);
						
						SymbolInfo* got = table.LookUp2($3->name, $3->scope);
						
						$3->etype = 1; // it is a normal variable
						
						$$->vec.insert($$->vec.end(),$1->vec.begin(), $1->vec.end());
						$$->vec.push_back($3);// name gula push kortesi
						if(scopeGlobal==0)
							table.Insert2($3);
					}
 		  | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD
		 		 {
					$$ = new SymbolInfo("", "", 2, $1->line, $6->line2, "declaration_list : declaration_list COMMA ID LSQUARE CONST_INT RSQUARE",$1, $2, $3, $4, $5, $6);
					$3->etype = 2; // it is an array
					$3->esize=stoi($5->name);
					$$->vec.insert($$->vec.end(),$1->vec.begin(), $1->vec.end());
					$$->vec.push_back($3);
					if(scopeGlobal==0)
						table.Insert2($3);
				}
 		  | ID %prec LOWER_THAN_LTHIRD
		  		{
					$$ = new SymbolInfo("", "", 2, $1->line, $1->line2, "declaration_list : ID",$1);
					$1->etype = 1; // it is a normal variable
					$$->vec.push_back($1);
					if(scopeGlobal==0)
					table.Insert2($1);
				}
 		  | ID LTHIRD CONST_INT RTHIRD
		  	{
				$$ = new SymbolInfo("", "", 2, $1->line, $4->line2, "declaration_list : ID LSQUARE CONST_INT RSQUARE",$1, $2, $3, $4);
				$1->etype = 2; // it is an array
				$1->esize=stoi($3->name);
				$$->vec.push_back($1);
				if(scopeGlobal==0)
					table.Insert2($1);
			}
 		  ;
 		  
statements : statement
			{
				$$ = new SymbolInfo("", "", 2, $1->line, $1->line2, "statements : statement",$1);
				$$->vec.insert($$->vec.end(),$1->vec.begin(), $1->vec.end());
				if($1->nextList.empty()==false)
					$$->nextList.insert($$->nextList.end(),$1->nextList.begin(), $1->nextList.end());
			}
	   | statements statement
	  		{
				$$ = new SymbolInfo("", "", 2, $1->line, $2->line2, "statements : statements statement",$1, $2);
				$$->vec.insert($$->vec.end(),$1->vec.begin(), $1->vec.end());
				$$->vec.insert($$->vec.end(),$2->vec.begin(), $2->vec.end());
				if($2->nextList.empty()==false)
				$$->nextList.insert($$->nextList.end(),$2->nextList.begin(), $2->nextList.end());
			}
	   ;
	   
statement : var_declaration
			{
				$$ = new SymbolInfo("", "", 2, $1->line, $1->line2, "statement : var_declaration",$1);
				$$->vec.insert($$->vec.end(),$1->vec.begin(), $1->vec.end());
			}
	  | expression_statement
	  	{
			$$ = new SymbolInfo("", "", 2, $1->line, $1->line2, "statement : expression_statement",$1);
			if($1->nextList.empty()==false)
				$$->nextList.insert($$->nextList.end(),$1->nextList.begin(), $1->nextList.end());
							
		}
	  | compound_statement
		{
			$$ = new SymbolInfo("", "", 2, $1->line, $1->line2, "statement : compound_statement",$1);
			if($1->nextList.empty()==false)
				$$->nextList.insert($$->nextList.end(),$1->nextList.begin(), $1->nextList.end());
		}
	  | FOR {isForLoop=1;} LPAREN expression_statement M expression_statement M expression 
	  {
		lineNoTempFile++; fprintf(fp5,"\tJMP %s\n",$5->label.c_str());
	  }
	  RPAREN M statement
	  	{
			$$ = new SymbolInfo("", "", 2, $1->line, $12->line2, "statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement",$1, $3, $4, $6, $8, $10, $12);
			
			lineNoTempFile++; fprintf(fp5,"\tJMP %s\n",$7->label.c_str());
			labelCnt++;
			lineNoTempFile++; fprintf(fp5,"L%d:\n",labelCnt);
			for(int i=0;i<$6->trueList.size();i++)
			{
				//cout<<"ADD KORTE HOBE IN FOR LOOP TRUELIST "<<$6->trueList[i]<<" line e "<<$11->label<<endl;
				//ReplaceCandidate.push_back($6->trueList[i]);
				labelMap[$6->trueList[i]]=$11->labelNo;
			}
			for(int i=0;i<$6->falseList.size();i++)
			{
				//cout<<"ADD KORTE HOBE IN FOR LOOP false LIST "<<$6->falseList[i]<<" line e L"<<labelCnt<<endl;
				//ReplaceCandidate.push_back($6->falseList[i]);
				labelMap[$6->falseList[i]]=labelCnt;
			}
			isForLoop=0;

		}
	  | IF LPAREN expression  RPAREN M statement %prec LOWER_THAN_ELSE
	  	{
			$$ = new SymbolInfo("", "", 2, $1->line, $6->line2, "statement : IF LPAREN expression RPAREN statement",$1, $2, $3, $4, $6);
			if($3->trueList.empty()==false)
				$$->trueList.insert($$->trueList.end(),$3->trueList.begin(), $3->trueList.end());
			if($3->falseList.empty()==false)
				$$->nextList.insert($$->nextList.end(),$3->falseList.begin(), $3->falseList.end());
			if($6->nextList.empty()==false){
				$$->nextList.insert($$->nextList.end(),$6->nextList.begin(), $6->nextList.end());
			}
			for(int i=0;i<$3->trueList.size();i++)
			{
				//cout<<"ok            "<<$3->trueList[i]<<" line e add hobe for true  "<<$5->label<<endl;
				labelMap[$3->trueList[i]]=$5->labelNo;
			}
			lineNoTempFile++;
			fprintf(fp5,"L%d:\n",++labelCnt);

			for(int i=0;i<$$->nextList.size();i++)
			{	
				//cout<<"ok            "<<$$->nextList[i]<<" line e add hobe L"<<labelCnt<<endl;
				labelMap[$$->nextList[i]]=labelCnt;
			}

							
		}
		| IF LPAREN expression RPAREN M statement  ELSE N M statement	// 1 2 3 4 6 7 10
	  	{
			$$ = new SymbolInfo("", "", 2, $1->line, $10->line2, "statement : IF LPAREN expression RPAREN statement ELSE statement",$1, $2, $3, $4, $6, $7, $10);
			for(int i=0;i<$3->trueList.size();i++)
			{
				//cout<<"ok            "<<$3->trueList[i]<<" line e add hobe for true  "<<$5->label<<endl;
				labelMap[$3->trueList[i]]=$5->labelNo;
			}
			for(int i=0;i<$3->falseList.size();i++)
			{
				//cout<<"ok            "<<$3->falseList[i]<<" line e add hobe for false  "<<$9->label<<endl;
				labelMap[$3->falseList[i]]=$9->labelNo;
			}
			lineNoTempFile++;
			fprintf(fp5,"L%d:\n",++labelCnt);
			labelMap[$8->nextList[0]]=labelCnt;

		}
	  
	  | WHILE M LPAREN  expression RPAREN M statement // 1 3 4 5 7
	  	{
			$$ = new SymbolInfo("", "", 2, $1->line, $7->line2, "statement : WHILE LPAREN expression RPAREN statement",$1, $3, $4, $5, $7);
			lineNoTempFile++;
			fprintf(fp5,"\tJMP %s\n",$2->label.c_str());
			lineNoTempFile++;
			fprintf(fp5,"L%d:\n",++labelCnt);
			for(int i=0;i<$4->trueList.size();i++)
			{
				//cout<<"ADD KORTE HOBE IN TRUELIST "<<$4->trueList[i]<<" TE "<<$6->label<<endl;
				labelMap[$4->trueList[i]]=$6->labelNo;
			}
			for(int i=0;i<$4->falseList.size();i++)
			{
				//cout<<"ADD KORTE HOBE IN FALSELIST "<<$4->falseList[i]<<" TE L"<<labelCnt<<endl;
				labelMap[$4->falseList[i]]=labelCnt;
			}


		}
	  | PRINTLN LPAREN ID RPAREN SEMICOLON // 1 2 3 4 5
	  	{
			$$ = new SymbolInfo("", "", 2, $1->line, $5->line2, "statement : PRINTLN LPAREN ID RPAREN SEMICOLON",$1, $2, $3, $4, $5);
			
			bool isGlobal=0;
			if(globalVariables.empty()==false)
			{
				for(int i=0;i<globalVariables.size();i++)
					if(globalVariables[i]==($3->name))
						{
							isGlobal=1; break;
						}
			}

			if(isGlobal==1)	
				{lineNoTempFile++;	fprintf(fp5,"\tMOV AX, %s\n",$3->name.c_str());}
			else
			{
				SymbolInfo* gotVariable=table.LookUp($3->name);
				if(gotVariable!=NULL)
				{
					int now = gotVariable->offset;

					string nowS="\tMOV AX, [BP-"+to_string(now)+"]\n";
					lineNoTempFile++;	fprintf(fp5,"%s",nowS.c_str());


					//lineNoTempFile++;
					//fprintf(fp5,"\tMOV AX, [BP-%d]\n",now);
				}
			}
			lineNoTempFile++;	fprintf(fp5,"\tCALL print_output\n");
			lineNoTempFile++;	fprintf(fp5,"\tCALL new_line\n");
			


		}
	  | RETURN expression SEMICOLON // 1 2 3 
	  	{
			$$ = new SymbolInfo("", "", 2, $1->line, $3->line2, "statement : RETURN expression SEMICOLON",$1, $2, $3);
			

			lineNoTempFile++;	 fprintf(fp5,"\tPOP AX\n");// AX e akhon return value
			++labelCnt;
			returnLabel=labelCnt;
			lineNoTempFile++;	 fprintf(fp5,"\tJMP L%d\n",returnLabel);// return paile porer shob baad
		}
	  ;

M 		:{
			string labelNow="L"+to_string(++labelCnt);
			$$=new SymbolInfo();
			$$->label=labelNow;
			$$->labelNo=labelCnt;
			lineNoTempFile++;	 fprintf(fp5,"%s:\n",labelNow.c_str());
		};
N      :{
				lineNoTempFile++;
				fprintf(fp5,"\tJMP L\n");
				$$=new SymbolInfo();
				$$->nextList.push_back(lineNoTempFile);
				ReplaceCandidate.push_back(lineNoTempFile);
		};
	  
expression_statement 	: SEMICOLON	
						{
							$$ = new SymbolInfo("", "", 2, $1->line, $1->line2, "expression_statement : SEMICOLON",$1);	
						}		
			| expression SEMICOLON 
						{
							$$ = new SymbolInfo("", "", 2, $1->line, $2->line2, "expression_statement : expression SEMICOLON",$1, $2);
							if($1->argtypes.empty()==false)
								$$->argtypes.insert($$->argtypes.end(),$1->argtypes.begin(), $1->argtypes.end());
								
							if($1->nextList.empty()==false)
								$$->nextList.insert($$->nextList.end(),$1->nextList.begin(), $1->nextList.end());
							 
							if(isForLoop==1){
							if($1->trueList.empty()==false)
								$$->trueList.insert($$->trueList.end(),$1->trueList.begin(), $1->trueList.end());
							
							if($1->falseList.empty()==false)
								$$->falseList.insert($$->falseList.end(),$1->falseList.begin(), $1->falseList.end());
							}
							else
							{
								++labelCnt;
								lineNoTempFile++; fprintf(fp5,"L%d:\n",labelCnt);
								for(int i=0;i<$1->trueList.size();i++)
								{
									//cout<<"ADD korte hobe "<<$1->trueList[i]<<" "<<labelCnt<<endl;
									labelMap[$1->trueList[i]]=labelCnt;
								}
								++labelCnt;
								lineNoTempFile++; fprintf(fp5,"L%d:\n",labelCnt);
								for(int i=0;i<$1->falseList.size();i++)
								{
									//cout<<"ADD korte hobe "<<$1->falseList[i]<<" "<<labelCnt<<endl;
									labelMap[$1->falseList[i]]=labelCnt;
								}
							}

						}		
			;
	  
variable : ID 	%prec LOWER_THAN_LTHIRD
				{
					$$ = new SymbolInfo("", "", 2, $1->line, $1->line2, "variable : ID",$1);
					$$->argtypes.push_back($1->name);
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
						$$->argtypes.push_back(got->rtype);			
					}

					bool isGlobal=0;
					if(globalVariables.empty()==false)
					{
							for(int i=0;i<globalVariables.size();i++)
							{	
								//cout<<"here "<<globalVariables[i]<<" "<<$1->argtypes[0]<<endl;
								if(globalVariables[i]==($1->name))
								{
									isGlobal=1; break;
								}
							}
					}

					if(isGlobal==1)
					{	
						currOffset=0;
						currGlobalVarName=$1->name;
					}
				else
				{
					SymbolInfo* gotVariable=table.LookUp($1->name);
					if(gotVariable!=NULL)
					{
						currOffset=gotVariable->offset;
					}
				}	

				}	
	 | ID LTHIRD expression RTHIRD 
	 	{	
			$$ = new SymbolInfo("", "", 2, $1->line, $4->line2, "variable : ID LSQUARE expression RSQUARE",$1, $2, $3, $4);
			SymbolInfo* now = table.LookUp2($1->name, $1->scope);
			$$->argtypes.push_back($1->name);
			if(now == NULL)
				now = table.LookUp2($1->name, $1->scope-1);
			if(now == NULL)
				{
					fprintf(fp3,"Line# %d: Undeclared variable \'%s\'\n",$1->line, $1->name.c_str());
				}
			else{
				int type = now->etype;
				$$->argtypes.push_back(now->rtype);
			}	
		}

	 ;
	 
 expression : logic_expression
			{	$$ = new SymbolInfo("", "", 2, $1->line, $1->line2, "expression : logic_expression",$1);
				if($1->argtypes.empty()==false)
					$$->argtypes.insert($$->argtypes.end(),$1->argtypes.begin(), $1->argtypes.end());
				//fprintf(fp4,"%s\n",$$->msg.c_str());	
				if($1->trueList.empty()==false)
					$$->trueList.insert($$->trueList.end(),$1->trueList.begin(), $1->trueList.end());
				if($1->falseList.empty()==false)
					$$->falseList.insert($$->falseList.end(),$1->falseList.begin(), $1->falseList.end());
						
			}
	   | variable ASSIGNOP logic_expression 
	   {	$$ = new SymbolInfo("", "", 2, $1->line, $3->line2, "expression : variable ASSIGNOP logic_expression",$1, $2, $3);
			if($1->argtypes.empty()==false)
					$$->argtypes.insert($$->argtypes.end(),$1->argtypes.begin(), $1->argtypes.end());

			bool isGlobal=0;
			bool isGlobalArray=0;
			if(globalVariables.empty()==false && $1->argtypes.empty()==false)
			{
				for(int i=0;i<globalVariables.size();i++)
				{	
					//cout<<"here "<<globalVariables[i]<<" "<<$1->argtypes[0]<<endl;
					if(globalVariables[i]==($1->argtypes[0]))
					{
						isGlobal=1; break;
					}
				}
			}
			if(globalVariablesArray.empty()==false && $1->argtypes.empty()==false){
				for(int i=0;i<globalVariablesArray.size();i++)
				{	
					//cout<<"here "<<globalVariables[i]<<" "<<$1->argtypes[0]<<endl;
					if(globalVariablesArray[i]==($1->argtypes[0]))
					{
						isGlobalArray=1; break;
					}
				}
				}

			if($3->trueList.empty()==true || $3->falseList.empty()==true){
			SymbolInfo* gotVariable=table.LookUp($1->argtypes[0]);// current scope e find korlam
			if(gotVariable!=NULL)
			{
					if(gotVariable->isParam==0)
					{	
						if(gotVariable->etype==1) // entry type=1, means a local normal variable
						{
							int now = gotVariable->offset;
							lineNoTempFile++;	fprintf(fp5,"\tPOP AX\n");
							string nowS="\tMOV [BP-"+to_string(now)+"], AX\n";
							lineNoTempFile++;	fprintf(fp5,"%s",nowS.c_str());
							//lineNoTempFile++;	fprintf(fp5,"\tMOV [BP-%d], AX\n",now);
						}
						else //id[5]=10, 5 tarpor 10 push hoye ase
						{	
							int now = gotVariable->offset;
							lineNoTempFile++;	fprintf(fp5,"\tPOP BX\n");// ekhane 10 ashlo, data
							lineNoTempFile++;	fprintf(fp5,"\tPOP AX\n");// ekhane 5 ashlo, index
							lineNoTempFile++;	fprintf(fp5,"\tMOV CX,AX\n");// CX e index
							lineNoTempFile++;	fprintf(fp5,"\tMOV AX,2\n");// index er sathe 2 multiply
							lineNoTempFile++;	fprintf(fp5,"\tCWD\n");// 
							lineNoTempFile++;	fprintf(fp5,"\tMUL CX\n");// result akhon ax e
							lineNoTempFile++;	fprintf(fp5,"\tMOV DX,%d\n",now);// base address anlam
							lineNoTempFile++;	fprintf(fp5,"\tADD AX,DX\n");// eta final address

							lineNoTempFile++;	fprintf(fp5,"\tMOV SI,BP\n");
							lineNoTempFile++;	fprintf(fp5,"\tSUB SI,AX\n");
							lineNoTempFile++;	fprintf(fp5,"\tMOV [SI],BX\n");
							lineNoTempFile++;	fprintf(fp5,"\tADD SI,AX\n");

						}
						
					}
					else{
							int now = gotVariable->paramOffset;
							lineNoTempFile++;	fprintf(fp5,"\tPOP AX\n");
							string nowS="\tMOV [BP+"+to_string(now)+"], AX\n";
						    lineNoTempFile++;	fprintf(fp5,"%s",nowS.c_str());
							//lineNoTempFile++;	fprintf(fp5,"\tMOV [BP+%d], AX\n",now);
					}
			}
			else 
			{
				if(isGlobal==1)
				{	
					lineNoTempFile++;	fprintf(fp5,"\tPOP AX\n");
					lineNoTempFile++;	fprintf(fp5,"\tMOV %s, AX\n", $1->argtypes[0].c_str());
				}
				else if(isGlobalArray==1)
				{
					lineNoTempFile++;	fprintf(fp5,"\tPOP BX\n");// ekhane 10 ashlo, data
					lineNoTempFile++;	fprintf(fp5,"\tPOP AX\n");// ekhane 5 ashlo, index
					lineNoTempFile++;	fprintf(fp5,"\tMOV CX,AX\n");// CX e index
					lineNoTempFile++;	fprintf(fp5,"\tMOV AX,2\n");// index er sathe 2 multiply
					lineNoTempFile++;	fprintf(fp5,"\tCWD\n");// 
					lineNoTempFile++;	fprintf(fp5,"\tMUL CX\n");// result akhon ax e

					lineNoTempFile++;	fprintf(fp5,"\tLEA SI,%s\n",$1->argtypes[0].c_str());
					lineNoTempFile++;	fprintf(fp5,"\tADD SI,AX\n");
					lineNoTempFile++;	fprintf(fp5,"\tMOV [SI],BX\n");
					//lineNoTempFile++;	fprintf(fp5,"\tADD SI,AX\n");
				}
			}
			}
			else
			{
				SymbolInfo* gotVariable=table.LookUp($1->argtypes[0]);// current scope e find korlam
				if(gotVariable!=NULL)
				{
						if(gotVariable->isParam==0)
						{
							int now = gotVariable->offset;
							++labelCnt;
							for(int i=0;i<$3->trueList.size();i++)
							{
									//cout<<"ADD KORTE HOBE IN ASNOP FOR TRUELIST "<<$3->trueList[i]<<"line e L"<<labelCnt<<endl;
								labelMap[$3->trueList[i]]=labelCnt;
							}
							lineNoTempFile++;	fprintf(fp5,"L%d:\n",labelCnt);
							lineNoTempFile++;	fprintf(fp5,"\tMOV AX, 1\n");
							string nowS="\tMOV [BP-"+to_string(now)+"], AX\n";
							lineNoTempFile++;	fprintf(fp5,"%s",nowS.c_str());
							//lineNoTempFile++;	fprintf(fp5,"\tMOV [BP-%d], AX\n",now);
							lineNoTempFile++;	fprintf(fp5,"\tJMP L%d\n",labelCnt+2);// na hoile 0 assign hoye jabe
							++labelCnt;
							for(int i=0;i<$3->falseList.size();i++)
							{
								//cout<<"ADD KORTE HOBE IN ASNOP FOR falseLIST "<<$3->falseList[i]<<"line e L"<<labelCnt<<endl;
								labelMap[$3->falseList[i]]=labelCnt;
							}
							lineNoTempFile++;	fprintf(fp5,"L%d:\n",labelCnt);
							lineNoTempFile++;	fprintf(fp5,"\tMOV AX, 0\n");
							 nowS="\tMOV [BP-"+to_string(now)+"], AX\n";
							lineNoTempFile++;	fprintf(fp5,"%s",nowS.c_str());
							//lineNoTempFile++;	fprintf(fp5,"\tMOV [BP-%d], AX\n",now);
							++labelCnt;
							lineNoTempFile++;	fprintf(fp5,"L%d:\n",labelCnt);
						}
						else{
							int now = gotVariable->paramOffset;
							++labelCnt;
							for(int i=0;i<$3->trueList.size();i++)
							{
								//cout<<"ADD KORTE HOBE IN ASNOP FOR TRUELIST "<<$3->trueList[i]<<"line e L"<<labelCnt<<endl;
								labelMap[$3->trueList[i]]=labelCnt;
							}
							lineNoTempFile++;	fprintf(fp5,"L%d:\n",labelCnt);
							lineNoTempFile++;	fprintf(fp5,"\tMOV AX, 1\n");
							string nowS="\tMOV [BP+"+to_string(now)+"], AX\n";
							lineNoTempFile++;	fprintf(fp5,"%s",nowS.c_str());
							//lineNoTempFile++;	fprintf(fp5,"\tMOV [BP+%d], AX\n",now);
							lineNoTempFile++;	fprintf(fp5,"\tJMP L%d\n",labelCnt+2);// na hoile 0 assign hoye jabe
							++labelCnt;
							for(int i=0;i<$3->falseList.size();i++)
							{
								//cout<<"ADD KORTE HOBE IN ASNOP FOR falseLIST "<<$3->falseList[i]<<"line e L"<<labelCnt<<endl;
								labelMap[$3->falseList[i]]=labelCnt;
							}
							lineNoTempFile++;	fprintf(fp5,"L%d:\n",labelCnt);
							lineNoTempFile++;	fprintf(fp5,"\tMOV AX, 0\n");
							 nowS="\tMOV [BP+"+to_string(now)+"], AX\n";
							lineNoTempFile++;	fprintf(fp5,"%s",nowS.c_str());
							//lineNoTempFile++;	fprintf(fp5,"\tMOV [BP+%d], AX\n",now);
							++labelCnt;
							lineNoTempFile++;	fprintf(fp5,"L%d:\n",labelCnt);


						}
				}
				else 
				{
					if(isGlobal==1)
				{	
					lineNoTempFile++;	fprintf(fp5,"\tPOP AX\n");
					lineNoTempFile++;	fprintf(fp5,"\tMOV %s, AX\n", $1->argtypes[0].c_str());
				}
				}
			}


	   }	
	   ;
			
logic_expression : rel_expression 	%prec LOWER_THAN_LOGICOP
					{	
						$$ = new SymbolInfo("", "", 2, $1->line, $1->line2, "logic_expression : rel_expression",$1);
						if($1->voidFunc.empty()==false) $$->voidFunc.insert($$->voidFunc.end(),$1->voidFunc.begin(), $1->voidFunc.end());
						if($1->argtypes.empty()==false)
							$$->argtypes.insert($$->argtypes.end(),$1->argtypes.begin(), $1->argtypes.end());
						//fprintf(fp4,"%s\n",$$->msg.c_str());
						if($1->trueList.empty()==false)
							$$->trueList.insert($$->trueList.end(),$1->trueList.begin(), $1->trueList.end());
						if($1->falseList.empty()==false)
							$$->falseList.insert($$->falseList.end(),$1->falseList.begin(), $1->falseList.end());
						
						
						
					}
		 | rel_expression LOGICOP rel_expression
		 		{	
					$$ = new SymbolInfo("", "", 2, $1->line, $3->line2, "logic_expression : rel_expression LOGICOP rel_expression",$1, $2, $3);
					if($1->voidFunc.empty()==false) $$->voidFunc.insert($$->voidFunc.end(),$1->voidFunc.begin(), $1->voidFunc.end());
					if($3->voidFunc.empty()==false) $$->voidFunc.insert($$->voidFunc.end(),$3->voidFunc.begin(), $3->voidFunc.end());
					$$->argtypes.push_back("int");
					

					int firstLabel=labelCnt+1;
					int secLabel=firstLabel+1;
					int thirdLabel=secLabel+1;
					int fourthLabel=thirdLabel+1;
					if($2->name=="||")
					{	
						lineNoTempFile++;	 fprintf(fp5,"\tPOP AX\n");
						lineNoTempFile++;	fprintf(fp5,"\tMOV DX,AX\n");// SECOND VAL IN DX
						lineNoTempFile++;	fprintf(fp5,"\tPOP AX\n");
						lineNoTempFile++;	fprintf(fp5,"\tMOV CX,AX\n");// FIRST VAL IN CX
						lineNoTempFile++;	fprintf(fp5,"\tMOV AX,CX\n");// FIRST VAL IN AX
						lineNoTempFile++;	fprintf(fp5,"\tCMP AX,0\n");	

						lineNoTempFile++;	fprintf(fp5,"\tJNE L%d\n",secLabel);
						lineNoTempFile++;	fprintf(fp5,"\tJMP L%d\n",firstLabel);
						lineNoTempFile++;	fprintf(fp5,"L%d:\n",firstLabel);
						lineNoTempFile++;	fprintf(fp5,"\tMOV AX,DX\n"); // SEC VAL IN AX
						lineNoTempFile++;	fprintf(fp5,"\tCMP AX,0\n");
						lineNoTempFile++;	fprintf(fp5,"\tJNE L%d\n",secLabel);
						lineNoTempFile++;	fprintf(fp5,"\tJMP L%d\n",fourthLabel);
						lineNoTempFile++;	fprintf(fp5,"L%d:\n",secLabel);
						lineNoTempFile++;	fprintf(fp5,"\tMOV AX,1\n");
						lineNoTempFile++;	fprintf(fp5,"\tJMP L%d\n",thirdLabel);
						lineNoTempFile++;	fprintf(fp5,"L%d:\n",fourthLabel);
						lineNoTempFile++;	fprintf(fp5,"\tMOV AX,0\n");
						lineNoTempFile++;	fprintf(fp5,"L%d:\n",thirdLabel);
						lineNoTempFile++;	fprintf(fp5,"\tPUSH AX\n");
						
					}	
					else
					{
						lineNoTempFile++;	fprintf(fp5,"\tPOP AX\n");
						lineNoTempFile++;	fprintf(fp5,"\tMOV DX,AX\n");// SECOND VAL IN DX
						lineNoTempFile++;	fprintf(fp5,"\tPOP AX\n");
						lineNoTempFile++;	fprintf(fp5,"\tMOV CX,AX\n");// FIRST VAL IN CX
						lineNoTempFile++;	fprintf(fp5,"\tMOV AX,CX\n");// FIRST VAL IN AX
						lineNoTempFile++;	fprintf(fp5,"\tCMP AX,0\n");	
						lineNoTempFile++;	fprintf(fp5,"\tJNE L%d\n",firstLabel);
						lineNoTempFile++;	fprintf(fp5,"\tJMP L%d\n",fourthLabel);
						lineNoTempFile++;	fprintf(fp5,"L%d:\n",firstLabel);
						lineNoTempFile++;	fprintf(fp5,"\tMOV AX,DX\n"); // SEC VAL IN AX
						lineNoTempFile++;	fprintf(fp5,"\tCMP AX,0\n");
						lineNoTempFile++;	fprintf(fp5,"\tJNE L%d\n",secLabel);
						lineNoTempFile++;	fprintf(fp5,"\tJMP L%d\n",fourthLabel);
						lineNoTempFile++;	fprintf(fp5,"L%d:\n",secLabel);
						lineNoTempFile++;	fprintf(fp5,"\tMOV AX,1\n");
						lineNoTempFile++;	fprintf(fp5,"\tJMP L%d\n",thirdLabel);
						lineNoTempFile++;	fprintf(fp5,"L%d:\n",fourthLabel);
						lineNoTempFile++;	fprintf(fp5,"\tMOV AX,0\n");
						lineNoTempFile++;	fprintf(fp5,"L%d:\n",thirdLabel);
						lineNoTempFile++;	fprintf(fp5,"\tPUSH AX\n");

					}
					labelCnt+=5;

				} 	
		 ;
			
rel_expression	: simple_expression %prec LOWER_THAN_RELOP
				{	
					$$ = new SymbolInfo("", "", 2, $1->line, $1->line2, "rel_expression : simple_expression",$1);
					if($1->voidFunc.empty()==false) $$->voidFunc.insert($$->voidFunc.end(),$1->voidFunc.begin(), $1->voidFunc.end());
					if($1->argtypes.empty()==false)
						$$->argtypes.insert($$->argtypes.end(),$1->argtypes.begin(), $1->argtypes.end());
					if($1->trueList.empty()==false)
						$$->trueList.insert($$->trueList.end(),$1->trueList.begin(), $1->trueList.end());
					if($1->falseList.empty()==false)
						$$->falseList.insert($$->falseList.end(),$1->falseList.begin(), $1->falseList.end());
						
				}
		| simple_expression RELOP simple_expression	
			{	
					$$ = new SymbolInfo("", "", 2, $1->line, $3->line2, "rel_expression : simple_expression RELOP simple_expression",$1, $2, $3);
					if($1->voidFunc.empty()==false) $$->voidFunc.insert($$->voidFunc.end(),$1->voidFunc.begin(), $1->voidFunc.end());
					if($3->voidFunc.empty()==false) $$->voidFunc.insert($$->voidFunc.end(),$3->voidFunc.begin(), $3->voidFunc.end());
					$$->argtypes.push_back("int");// 0 or 1 jabe

					lineNoTempFile++;	fprintf(fp5,"\tPOP AX\n");
					lineNoTempFile++;	fprintf(fp5,"\tMOV DX, AX\n");
					lineNoTempFile++;	fprintf(fp5,"\tPOP AX\n");
					lineNoTempFile++;	fprintf(fp5,"\tCMP AX, DX\n");

					if($2->name=="<="){
						lineNoTempFile++;	//fprintf(fp5,"\tJLE L%d\n",firstLabel); eta mane <= true
						fprintf(fp5,"\tJLE L\n");
						$$->trueList.push_back(lineNoTempFile);
						ReplaceCandidate.push_back(lineNoTempFile);
						//cout<<"				"<<lineNoTempFile<<" is in truelist"<<endl;
					}
					else if($2->name=="!=")
					{	
						lineNoTempFile++;
						//fprintf(fp5,"\tJNE L%d\n",firstLabel);
						fprintf(fp5,"\tJNE L\n");
						$$->trueList.push_back(lineNoTempFile);
						ReplaceCandidate.push_back(lineNoTempFile);
						//cout<<"				"<<lineNoTempFile<<" is in truelist"<<endl;
					}
					else if($2->name=="==")
					{	
						lineNoTempFile++;
						fprintf(fp5,"\tJE L\n");
						$$->trueList.push_back(lineNoTempFile);
						ReplaceCandidate.push_back(lineNoTempFile);
						//cout<<"				"<<lineNoTempFile<<" is in truelist for =="<<endl;
					}
					else if($2->name=="<")
					{	
						lineNoTempFile++;
						fprintf(fp5,"\tJL L\n");
						$$->trueList.push_back(lineNoTempFile);
						ReplaceCandidate.push_back(lineNoTempFile);
						//cout<<"				"<<lineNoTempFile<<" is in truelist for <"<<endl;
					}
					else if($2->name==">")
					{	
						lineNoTempFile++;
						fprintf(fp5,"\tJG L\n");
						$$->trueList.push_back(lineNoTempFile);
						ReplaceCandidate.push_back(lineNoTempFile);
						//cout<<"				"<<lineNoTempFile<<" is in truelist for <"<<endl;
					}
					else if($2->name==">=")
					{	
						lineNoTempFile++;
						fprintf(fp5,"\tJGE L\n");
						$$->trueList.push_back(lineNoTempFile);
						ReplaceCandidate.push_back(lineNoTempFile);
						//cout<<"				"<<lineNoTempFile<<" is in truelist for <"<<endl;
					}
					lineNoTempFile++;	fprintf(fp5,"\tJMP L\n"); $$->falseList.push_back(lineNoTempFile);
					ReplaceCandidate.push_back(lineNoTempFile);

			}
		;
				
simple_expression : term
					{	
						$$ = new SymbolInfo("", "", 2, $1->line, $1->line2, "simple_expression : term",$1);
						if($1->voidFunc.empty()==false) $$->voidFunc.insert($$->voidFunc.end(),$1->voidFunc.begin(), $1->voidFunc.end());
						if($1->argtypes.empty()==false)
							$$->argtypes.insert($$->argtypes.end(),$1->argtypes.begin(), $1->argtypes.end());
				   		//fprintf(fp4,"%s\n",$$->msg.c_str());
						if($1->trueList.empty()==false)
							$$->trueList.insert($$->trueList.end(),$1->trueList.begin(), $1->trueList.end());
						if($1->falseList.empty()==false)
							$$->falseList.insert($$->falseList.end(),$1->falseList.begin(), $1->falseList.end());
						
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
				//fprintf(fp4,"Line# %d: Token <%s> Lexeme %s found\n",$2->line, $2->type.c_str(),$2->name.c_str());
		  		//fprintf(fp4,"%s\n",$$->msg.c_str());

				if($2->name=="+"){
				lineNoTempFile++;	fprintf(fp5,"\tPOP AX\n");
				lineNoTempFile++;	fprintf(fp5,"\tPOP DX\n");
				lineNoTempFile++;	fprintf(fp5,"\tADD AX,DX ; adding two operands in source file line no %d\n",$2->line);
				lineNoTempFile++;	fprintf(fp5,"\tPUSH AX\n");
				}
				else if($2->name=="-")
				{
					lineNoTempFile++;	fprintf(fp5,"\tPOP DX\n");
					lineNoTempFile++;	fprintf(fp5,"\tPOP AX\n");
					lineNoTempFile++;	fprintf(fp5,"\tSUB AX,DX ;subtracting two operands in source file line no %d\n",$2->line);
					lineNoTempFile++;	fprintf(fp5,"\tPUSH AX\n");
				}



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
			
			if($1->trueList.empty()==false)
				$$->trueList.insert($$->trueList.end(),$1->trueList.begin(), $1->trueList.end());
			if($1->falseList.empty()==false)
				$$->falseList.insert($$->falseList.end(),$1->falseList.begin(), $1->falseList.end());	
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

			lineNoTempFile++;	 fprintf(fp5,"\tPOP AX\n");	
			lineNoTempFile++;	fprintf(fp5,"\tMOV CX, AX\n");	
			lineNoTempFile++;	fprintf(fp5,"\tPOP AX\n");	
			lineNoTempFile++;	fprintf(fp5,"\tCWD\n");	
			if($2->name=="*"){
				lineNoTempFile++;	fprintf(fp5,"\tMUL CX ; multiplying from line no %d\n",$2->line);
				lineNoTempFile++;	fprintf(fp5,"\tPUSH AX\n");	
			}else{
				lineNoTempFile++;	fprintf(fp5,"\tDIV CX ; dividing from source file line no %d\n",$2->line);
				lineNoTempFile++;	fprintf(fp5,"\tPUSH DX\n");
			}



		}
     ;

unary_expression : ADDOP unary_expression 
				{	
					$$ = new SymbolInfo("", "", 2, $1->line, $2->line2, "unary_expression : ADDOP unary_expression",$1, $2);
					if($2->voidFunc.empty()==false)
					{
						$$->voidFunc.insert($$->voidFunc.end(),$2->voidFunc.begin(), $2->voidFunc.end());
					}	
				}
		 | NOT unary_expression 
				 {	
					$$ = new SymbolInfo("", "", 2, $1->line, $2->line2, "unary_expression : LOGICOP unary_expression",$1, $2);
					if($2->voidFunc.empty()==false)
					{
						$$->voidFunc.insert($$->voidFunc.end(),$2->voidFunc.begin(), $2->voidFunc.end());
					}
					
					if(currOffset==0)
					{
						lineNoTempFile++;	fprintf(fp5,"\tMOV AX, %s\n",currGlobalVarName);
						lineNoTempFile++;	fprintf(fp5,"\tNEG AX\n");
						lineNoTempFile++;	fprintf(fp5,"\tPUSH AX\n");
					}
					else
					{	
						string nowS="\tMOV AX, [BP-"+to_string(currOffset)+"]\n";
						lineNoTempFile++;	fprintf(fp5,"%s",nowS.c_str());
						lineNoTempFile++;	fprintf(fp5,"\tNEG AX\n");
						lineNoTempFile++;	fprintf(fp5,"\tPUSH AX\n");
					}	
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
					if($1->trueList.empty()==false)
						$$->trueList.insert($$->trueList.end(),$1->trueList.begin(), $1->trueList.end());
					if($1->falseList.empty()==false)
						$$->falseList.insert($$->falseList.end(),$1->falseList.begin(), $1->falseList.end());
				}
		 ;
	
factor	: variable
		{	
			$$ = new SymbolInfo("", "", 2, $1->line, $1->line2, "factor : variable",$1);
			if($1->argtypes.empty()==false)
				$$->argtypes.insert($$->argtypes.end(),$1->argtypes.begin(), $1->argtypes.end());
			bool isGlobal=0;
			bool isGlobalArray=0;
			if(globalVariables.empty()==false && $1->argtypes.empty()==false)
			{
				for(int i=0;i<globalVariables.size();i++)
					if(globalVariables[i]==($1->argtypes[0])) {isGlobal=1; break;}
				
			}

			if(globalVariablesArray.empty()==false && $1->argtypes.empty()==false)
				{
					for(int i=0;i<globalVariablesArray.size();i++)
					if(globalVariablesArray[i]==($1->argtypes[0])) {isGlobalArray=1; break;}
				}
			

			SymbolInfo* gotVariable=table.LookUp($1->argtypes[0]);
				if(gotVariable!=NULL)
				{	
					if(gotVariable->isParam==0)
					{	
						if(gotVariable->etype==1)
						{
							int now = gotVariable->offset;
							string nowS="\tMOV AX, [BP-"+to_string(now)+"]\n";
							lineNoTempFile++;	fprintf(fp5,"%s",nowS.c_str());
			    			lineNoTempFile++;	fprintf(fp5,"\tPUSH AX\n");
						}
						else // we got id[5]
						{
							int now = gotVariable->offset;
							//lineNoTempFile++;	fprintf(fp5,"\tPOP BX\n");// ekhane 10 ashlo, data
							lineNoTempFile++;	fprintf(fp5,"\tPOP AX\n");// ekhane 5 ashlo, index
							lineNoTempFile++;	fprintf(fp5,"\tMOV CX,AX\n");// CX e index
							lineNoTempFile++;	fprintf(fp5,"\tMOV AX,2\n");// index er sathe 2 multiply
							lineNoTempFile++;	fprintf(fp5,"\tCWD\n");// 
							lineNoTempFile++;	fprintf(fp5,"\tMUL CX\n");// result akhon ax e
							lineNoTempFile++;	fprintf(fp5,"\tMOV DX,%d\n",now);// base address anlam
							lineNoTempFile++;	fprintf(fp5,"\tADD AX,DX\n");// eta final address

							lineNoTempFile++;	fprintf(fp5,"\tMOV SI,BP\n");
							lineNoTempFile++;	fprintf(fp5,"\tSUB SI,AX\n");
							lineNoTempFile++;	fprintf(fp5,"\tMOV BX,[SI]\n");
							lineNoTempFile++;	fprintf(fp5,"\tPUSH BX\n");
							lineNoTempFile++;	fprintf(fp5,"\tADD SI,AX\n");

						}
					}
					else{
							int now = gotVariable->paramOffset;
							string nowS="\tMOV AX, [BP+"+to_string(now)+"]\n";
							lineNoTempFile++;	fprintf(fp5,"%s",nowS.c_str());
							//lineNoTempFile++;	fprintf(fp5,"\tMOV AX, [BP+%d] %s\n",now);
			    			lineNoTempFile++;	fprintf(fp5,"\tPUSH AX\n");
					}
				}
				else
				{
					if(isGlobal==1)
					{	
						lineNoTempFile++;	fprintf(fp5,"\tMOV AX, %s\n",$1->argtypes[0].c_str());
			    		lineNoTempFile++;	fprintf(fp5,"\tPUSH AX\n");
					}
					else if(isGlobalArray==1) // id[10]
					{
						lineNoTempFile++;	fprintf(fp5,"\tPOP AX\n");// ekhane 10 ashlo, index
						lineNoTempFile++;	fprintf(fp5,"\tMOV CX,AX\n");// CX e index
						lineNoTempFile++;	fprintf(fp5,"\tMOV AX,2\n");// index er sathe 2 multiply
						lineNoTempFile++;	fprintf(fp5,"\tCWD\n");// 
						lineNoTempFile++;	fprintf(fp5,"\tMUL CX\n");// result akhon ax e

						lineNoTempFile++;	fprintf(fp5,"\tLEA SI,%s\n",$1->argtypes[0].c_str());
						lineNoTempFile++;	fprintf(fp5,"\tADD SI,AX\n");
						lineNoTempFile++;	fprintf(fp5,"\tMOV BX,[SI]\n");
						lineNoTempFile++;	fprintf(fp5,"\tPUSH BX\n");// READY TO UPLOAD
					}
				
				}


		}
	| ID LPAREN argument_list RPAREN
		{	
			$$ = new SymbolInfo("", "", 2, $1->line, $4->line2, "factor : ID LPAREN argument_list RPAREN",$1, $2, $3, $4);
			SymbolInfo* got = table.LookUp($1->name);
			if(got == NULL)
			{
				//fprintf(fp3,"Line# %d: Undeclared function \'%s\'\n",$1->line, $1->name.c_str());
			}
			else
			{
				$$->voidFunc.push_back(got);
				$$->argtypes.push_back(got->rtype);
				int check1 = 0;
				int check2 = 0;
				if(got->fptypes.empty()==false) check1 = got->fptypes.size();
				if($3->argtypes.empty()==false) check2 = $3->argtypes.size();
			}	
			lineNoTempFile++;	fprintf(fp5,"\tCALL %s\n", $1->name.c_str());
			lineNoTempFile++;	fprintf(fp5,"\tPUSH AX\n");

		}
	| LPAREN expression RPAREN
		{	
			$$ = new SymbolInfo("", "", 2, $1->line, $3->line2, "factor : LPAREN expression RPAREN",$1, $2, $3);	
		}
	| CONST_INT 
		{	
			$$ = new SymbolInfo($1->name, "", 2, $1->line, $1->line2, "factor : CONST_INT",$1);
			$$->argtypes.push_back("int");

			lineNoTempFile++;	fprintf(fp5,"\tMOV AX, %s ;constant from source file line no %d\n",$1->name.c_str(), $1->line);
			lineNoTempFile++;	fprintf(fp5,"\tPUSH AX\n");
		}
	| CONST_FLOAT
		{	
			$$ = new SymbolInfo($1->name, "", 2, $1->line, $1->line2, "factor : CONST_FLOAT",$1);
			$$->argtypes.push_back("float");	
		}
	| variable INCOP 
		{	
			
			$$ = new SymbolInfo("", "", 2, $1->line, $2->line2, "factor : variable INCOP",$1, $2);
			if($1->argtypes.empty()==false)
				$$->argtypes.insert($$->argtypes.end(),$1->argtypes.begin(), $1->argtypes.end());
			SymbolInfo* gotVariable=table.LookUp($1->argtypes[0]);
			if(gotVariable!=NULL)
				{	
					if(gotVariable->isParam==0){
					int now = gotVariable->offset;
					string nowS="\tMOV AX, [BP-"+to_string(now)+"]\n";
					lineNoTempFile++;	fprintf(fp5,"%s",nowS.c_str());
					//lineNoTempFile++;	fprintf(fp5,"\tMOV AX, [BP-%d]\n",now);
					lineNoTempFile++;	fprintf(fp5,"\tPUSH AX\n");
					lineNoTempFile++;	fprintf(fp5,"\tPOP AX\n");
					 nowS="\tMOV AX, [BP-"+to_string(now)+"]\n";
					lineNoTempFile++;	fprintf(fp5,"%s",nowS.c_str());
					//lineNoTempFile++;	fprintf(fp5,"\tMOV AX, [BP-%d]\n",now);
					lineNoTempFile++;	fprintf(fp5,"\tMOV DX,AX\n");// dx e old val
					lineNoTempFile++;	fprintf(fp5,"\tINC AX\n");
					 nowS="\tMOV [BP-"+to_string(now)+"],AX\n";
					lineNoTempFile++;	fprintf(fp5,"%s",nowS.c_str());
					//lineNoTempFile++;	fprintf(fp5,"\tMOV [BP-%d],AX\n",now); // val update korlam

					lineNoTempFile++;	fprintf(fp5,"\tCMP DX,0\n");
					lineNoTempFile++;	fprintf(fp5,"\tJNE L\n");//ETA TRUELIST
					$$->trueList.push_back(lineNoTempFile);
					ReplaceCandidate.push_back(lineNoTempFile);
					lineNoTempFile++;	fprintf(fp5,"\tJMP L\n");//ETA falseLIST
					$$->falseList.push_back(lineNoTempFile);
					ReplaceCandidate.push_back(lineNoTempFile);
					}
					else{
							int now = gotVariable->paramOffset;
							string nowS="\tMOV AX, [BP+"+to_string(now)+"]\n";
					        lineNoTempFile++;	fprintf(fp5,"%s",nowS.c_str());
							//lineNoTempFile++;	fprintf(fp5,"\tMOV AX, [BP+%d]\n",now);
							lineNoTempFile++;	fprintf(fp5,"\tPUSH AX\n");
							lineNoTempFile++;	fprintf(fp5,"\tPOP AX\n");
							 nowS="\tMOV AX, [BP+"+to_string(now)+"]\n";
					        lineNoTempFile++;	fprintf(fp5,"%s",nowS.c_str());
							//lineNoTempFile++;	fprintf(fp5,"\tMOV AX, [BP+%d]\n",now);
							lineNoTempFile++;	fprintf(fp5,"\tMOV DX,AX\n");// dx e old val
							lineNoTempFile++;	fprintf(fp5,"\tINC AX\n");

							 nowS="\tMOV [BP+"+to_string(now)+"],AX\n";
					        lineNoTempFile++;	fprintf(fp5,"%s",nowS.c_str());							
							//lineNoTempFile++;	fprintf(fp5,"\tMOV [BP+%d],AX\n",now); // val update korlam

							lineNoTempFile++;	fprintf(fp5,"\tCMP DX,0\n");
							lineNoTempFile++;	fprintf(fp5,"\tJNE L\n");//ETA TRUELIST
							$$->trueList.push_back(lineNoTempFile);
							ReplaceCandidate.push_back(lineNoTempFile);
							lineNoTempFile++;	fprintf(fp5,"\tJMP L\n");//ETA falseLIST
							$$->falseList.push_back(lineNoTempFile);
							ReplaceCandidate.push_back(lineNoTempFile);
							
					}
				}
			else
				{	
						lineNoTempFile++;	fprintf(fp5,"\tMOV AX, %s\n",$1->argtypes[0].c_str());
			    		lineNoTempFile++;	fprintf(fp5,"\tPUSH AX\n");
						lineNoTempFile++;	fprintf(fp5,"\tPOP AX\n");
						lineNoTempFile++;	fprintf(fp5,"\tMOV AX, %s\n",$1->argtypes[0].c_str());
						lineNoTempFile++;	fprintf(fp5,"\tMOV DX,AX\n");// dx e old val
						lineNoTempFile++;	fprintf(fp5,"\tINC AX\n");
						lineNoTempFile++;	fprintf(fp5,"\tMOV %s,AX\n",$1->argtypes[0].c_str()); // val update korlam

						lineNoTempFile++;	fprintf(fp5,"\tCMP DX,0\n");
						lineNoTempFile++;	fprintf(fp5,"\tJNE L\n");//ETA TRUELIST
						$$->trueList.push_back(lineNoTempFile);
						ReplaceCandidate.push_back(lineNoTempFile);
						lineNoTempFile++;	fprintf(fp5,"\tJMP L\n");//ETA falseLIST
						$$->falseList.push_back(lineNoTempFile);
						ReplaceCandidate.push_back(lineNoTempFile);
					
				}	
		}
	| variable DECOP
		{	
			$$ = new SymbolInfo("", "", 2, $1->line, $2->line2, "factor : variable DECOP",$1, $2);
			if($1->argtypes.empty()==false)
				$$->argtypes.insert($$->argtypes.end(),$1->argtypes.begin(), $1->argtypes.end());
			if(currOffset==0)
			{
				lineNoTempFile++;	fprintf(fp5,"\tMOV AX, %s\n",currGlobalVarName);
				lineNoTempFile++;	fprintf(fp5,"\tPUSH AX\n");
				lineNoTempFile++;	fprintf(fp5,"\tDEC AX\n");
				lineNoTempFile++;	fprintf(fp5,"\tMOV %s,AX\n",currGlobalVarName);
				
			}
			else
			{
				string nowS="\tMOV AX, [BP-"+to_string(currOffset)+"]\n";
		        lineNoTempFile++;	fprintf(fp5,"%s",nowS.c_str());
				lineNoTempFile++;	fprintf(fp5,"\tPUSH AX\n");
				lineNoTempFile++;	fprintf(fp5,"\tPOP AX\n");
				 nowS="\tMOV AX, [BP-"+to_string(currOffset)+"]\n";
		        lineNoTempFile++;	fprintf(fp5,"%s",nowS.c_str());
				lineNoTempFile++;	fprintf(fp5,"\tMOV DX,AX\n");// dx e old val
				lineNoTempFile++;	fprintf(fp5,"\tDEC AX\n");
				 nowS="\tMOV [BP-"+to_string(currOffset)+"],AX\n";
		        lineNoTempFile++;	fprintf(fp5,"%s",nowS.c_str());
				//lineNoTempFile++;	fprintf(fp5,"\tMOV [BP-%d],AX\n",currOffset); // val update korlam

				lineNoTempFile++;	fprintf(fp5,"\tCMP DX,0\n");
				lineNoTempFile++;	fprintf(fp5,"\tJNE L\n");//ETA TRUELIST
				$$->trueList.push_back(lineNoTempFile);
				ReplaceCandidate.push_back(lineNoTempFile);
				lineNoTempFile++;	fprintf(fp5,"\tJMP L\n");//ETA falseLIST
				$$->falseList.push_back(lineNoTempFile);
				ReplaceCandidate.push_back(lineNoTempFile);

			}		
		}
	;
	
argument_list : arguments
				{	
					$$ = new SymbolInfo("", "", 2, $1->line, $1->line2, "argument_list : arguments",$1);
					if($1->argtypes.empty()==false)
						$$->argtypes.insert($$->argtypes.end(),$1->argtypes.begin(), $1->argtypes.end());
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
				}
	      | logic_expression
		  		{	
					$$ = new SymbolInfo("", "", 2, $1->line, $1->line2, "arguments : logic_expression",$1);
					if($1->argtypes.empty()==false)
						$$->argtypes.insert($$->argtypes.end(),$1->argtypes.begin(), $1->argtypes.end());
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

	fp2= fopen("parsetree.txt","w");
	fp3= fopen("error.txt","w");
	fp4= fopen("log.txt","w");

	fp5= fopen("tempCode.txt","w");
	yyin=fp;
	string lineFromAsm,lineFromAsm2;
	int lineNowCnt=0;
	fstream codeNow;






	lineNoTempFile++;	fprintf(fp5,".MODEL SMALL\n");
	lineNoTempFile++;	fprintf(fp5,".STACK 1000H\n");
	lineNoTempFile++;	fprintf(fp5,".Data\n");
	lineNoTempFile++;	fprintf(fp5,"\tCR EQU 0DH\n");
	lineNoTempFile++;	fprintf(fp5,"\tLF EQU 0AH\n");
	lineNoTempFile++;	fprintf(fp5,"\tnumber DB \"00000$\"\n");
	
	
	yyparse();
	func(mainJinish, 0);





	fclose(fp2);
	fclose(fp3);
	fclose(fp4);



	fclose(fp5);
	table.clearTable();
	while(stck.empty()==false)
	{
		SymbolInfo* soFar = stck.top();
		stck.pop();
		if(soFar!=NULL)
			delete soFar;//deleting the parse tree
	}
	
	fp6= fopen("code.txt","w");
	fp7= fopen("optimized_code.txt","w");
	
	codeNow.open("tempCode.txt", ios::in); 


	
	while(getline(codeNow,lineFromAsm))
	{	
		lineNowCnt++;
		if((labelMap[lineNowCnt]!=0))
		{
			//cout<<lineFromAsm<<labelMap[lineNowCnt]<<endl;
			string to_be_printed = lineFromAsm+to_string(labelMap[lineNowCnt]);
			fprintf(fp6,"%s\n",to_be_printed.c_str());
		}
		else if(std::count(ReplaceCandidate.begin(), ReplaceCandidate.end(), lineNowCnt)!=0)
		{
			//ignore these lines, no mapping 
		}
		else
		{	
			string to_be_printed = lineFromAsm;
			fprintf(fp6,"%s\n",to_be_printed.c_str());
			//cout<<lineFromAsm<<endl;
		}

	}
	codeNow.close();
	codeNow.open("printFunc.txt", ios::in); // to copy the print functions
	while(getline(codeNow,lineFromAsm))
	{	
			fprintf(fp6,"%s\n",lineFromAsm.c_str());
	}



	codeNow.close();

	//fclose(fp5);
	fclose(fp6);

	codeNow.open("code.txt", ios::in); 
	lineNowCnt=0;
	while(getline(codeNow,lineFromAsm))
	{
		lineNowCnt++;
		string opcode=lineFromAsm.substr(1,3);
		if(lineFromAsm=="\tPUSH AX")
		{
			getline(codeNow, lineFromAsm2);
			lineNowCnt++;
			if(lineFromAsm2=="\tPOP AX")
			{

			}
			else
			{
				fprintf(fp7,"%s\n",lineFromAsm.c_str());
				fprintf(fp7,"%s\n",lineFromAsm2.c_str());
			}
		}
		else if(opcode=="JMP")
		{
			string matchLabel1=lineFromAsm.substr(5,lineFromAsm.size()-5);
			getline(codeNow, lineFromAsm2);
			lineNowCnt++;
			string matchLabel2=lineFromAsm2.substr(0,lineFromAsm2.size()-1);
			//cout<<"IN JUMP "<<matchLabel1<<" "<<matchLabel2<<endl;
			if(matchLabel1==matchLabel2)
			{
				//ignore
			}
			else
			{
				fprintf(fp7,"%s\n",lineFromAsm.c_str());
				fprintf(fp7,"%s\n",lineFromAsm2.c_str());
			}

		}
		else if(opcode=="MOV")
		{
			getline(codeNow, lineFromAsm2);
			lineNowCnt++;
			string opcode2=lineFromAsm2.substr(1,3);
			if(opcode==opcode2) // both are MOV instructions
			{
				int idx=0,idx2=0;
				for(int i=0;i<lineFromAsm.size();i++)
				{
					if(lineFromAsm[i]==',')
					{
						idx=i;break;
					}
				}
				for(int i=0;i<lineFromAsm2.size();i++)
				{
					if(lineFromAsm2[i]==',')
					{
						idx2=i;break;
					}
				}

				string operand1=lineFromAsm.substr(5,idx-1-4);
				string operand2=lineFromAsm2.substr(5,idx2-1-4);
				string operand3=lineFromAsm.substr(idx+1,lineFromAsm.size()-1-idx);
				string operand4=lineFromAsm2.substr(idx2+1,lineFromAsm2.size()-1-idx2);
				if(operand1==operand4 && operand2==operand3)
				{
					// mov ax,a 
					// mov a,ax ignored here
				}
				else
				{
					fprintf(fp7,"%s\n",lineFromAsm.c_str());
					fprintf(fp7,"%s\n",lineFromAsm2.c_str());
				}
				


			}
			else
			{
				fprintf(fp7,"%s\n",lineFromAsm.c_str());
				fprintf(fp7,"%s\n",lineFromAsm2.c_str());
			}

		}
		else
		{
			fprintf(fp7,"%s\n",lineFromAsm.c_str());
		}
	}
	codeNow.close();
	codeNow.open("printFunc.txt", ios::in); // to copy the print functions
	while(getline(codeNow,lineFromAsm))
	{	
			fprintf(fp7,"%s\n",lineFromAsm.c_str());
	}



	codeNow.close();
	fclose(fp7);
	return 0;
	//test file 1 ok
	//test file 2 ok
	//test file 3 ok
	//test file 5 ok
	//yacc -d 1905012.y
	//g++ -w -c -o y.o y.tab.c
	//flex -o start.c 1905012.l
	//g++ -w -c -o l.o start.c
	//g++ y.o l.o -lfl -o simple
}


