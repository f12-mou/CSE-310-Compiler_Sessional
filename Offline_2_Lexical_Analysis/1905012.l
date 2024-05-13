%option noyywrap

%x STRINGSTART
%x SINGLECOMMENTSTART
%x MULTIPLECOMMENTSTART
%x SINGLECOMMENTSTART2

%{
#include <bits/stdc++.h>
#include<fstream>
using namespace std;
#define ll long long

int line_count=1;
int err_count = 0;

FILE *logout;
FILE *tokenout;
class SymbolInfo
{
    string name;
    string type;
public:

    SymbolInfo* lc;
    SymbolInfo* rc;

    SymbolInfo()
    {
        lc = NULL;
        rc = NULL;
    }
    SymbolInfo(string key, string val)
    {
        lc = NULL;
        rc = NULL;
        name = key;
        type = val;
    }
    ~SymbolInfo()
    {

    }
    string getName()
    {
        return name;
    }
    string getType()
    {
        return type;
    }
    void setName(string s)
    {
        name = s;
    }
    void setType(string s)
    {
        type = s;
    }
};


class ScopeTable
{
public:

    SymbolInfo** p;
    ScopeTable* parent_scope;
    int num_buckets;
    int unique_number;

    ScopeTable(int total, int number, ScopeTable* parent_pointer = NULL)
    {
        cout<<"\tScopeTable# "<<number<<" created"<<endl;
        num_buckets = total;
        unique_number = number;
        p = new SymbolInfo*[num_buckets];
        for(int i=0;i<num_buckets;i++)
        {
            p[i]=NULL;
        }
        parent_scope = parent_pointer;
    }
    ~ScopeTable()
    {
        cout<<"\t"<<"ScopeTable# "<<unique_number<<" removed"<<endl;
        for(int i=0;i<num_buckets;i++)
        {
            SymbolInfo* now=p[i];
            while(now!=NULL)
            {
                SymbolInfo* temp=now;
                now=now->rc;
                delete temp;
            }
        }
        delete p;
    }
    ll SDBMHash(string str)
    {
        ll hashval = 0;
        ll i = 0;
        ll len = str.length();

        for (i = 0; i < len; i++)
        {
            hashval = (str[i]) + (hashval << 6) + (hashval << 16) - hashval;
            hashval =hashval % num_buckets;
        }

        return hashval;
    }
    SymbolInfo* searchHelp(string k)
    {
        ll index = SDBMHash(k);
        index = index % num_buckets;
        SymbolInfo* temp = p[index];
        while(temp!=NULL)
        {
            if(temp->getName()==k)
                break;
            temp=temp->rc;
        }
        return temp;
    }
    void deleteHash(string k)
    {
        ll index = SDBMHash(k);
        index = index % num_buckets;
        SymbolInfo* found = searchHelp(k);
        if(found==NULL)
        {
            return;
        }
        else

        {
            if(found->lc!=NULL)
            {
                found->lc->rc=found->rc;
            }
            if(found->rc!=NULL)
            {
                found->rc->lc=found->lc;
            }
            if(found->lc==NULL)
            {
                p[index]=found->rc;
            }

            delete found;
        }
    }

    SymbolInfo* searchHash(string k)
    {
        SymbolInfo* found=searchHelp(k);
        return found;
    }

    bool insertHash(string k, string value)
    {
        ll index = SDBMHash(k);
        index = index % num_buckets;

        SymbolInfo* obj;

        SymbolInfo* found=searchHelp(k);
        if(found!=NULL)
        {
            return false;
        }

        if(p[index]==NULL) // first position to insert
        {
            obj=new SymbolInfo(k,value);
            p[index]=obj;
        }
        else
        {
            SymbolInfo* now = p[index];
            while(now->rc!=NULL)
            {
                now=now->rc;
            }
            obj=new SymbolInfo(k,value);
            now->rc=obj;
            obj->lc=now;
        }
        return true;
    }

    int getIndexInfoFirst(string key, string val="")
    {
        ll index = SDBMHash(key);
        index = index % num_buckets;

        SymbolInfo* now = p[index];
        bool ok=false;

        while(now!=NULL)
        {
            if(now->getName()==key)
            {
                ok=true; break;
            }
            now=now->rc;
        }
        if(ok){
            return index;
        }
        else
        {
            return -1;
        }
    }


    int getIndexInfoSecond(string key, string val="")
    {
        ll index = SDBMHash(key);
        index = index % num_buckets;

        SymbolInfo* now = p[index];
        int where=1;
        bool ok=false;

        while(now!=NULL)
        {
            if(now->getName()==key)
            {
                ok=true; break;
            }
            now=now->rc;
            where++;
        }
        if(ok){
            return where;
        }
        else
        {
            return -1;
        }
    }




    void print()
    {	
	fprintf(logout,"\tScopeTable# %d\n",unique_number);	
        for(int i=0;i<num_buckets;i++)
        {
            SymbolInfo* now=p[i];
	   if(now==NULL) continue; int i2=i+1;
	  fprintf(logout,"\t%d--> ",i2);
            while(now!=NULL)
            {	
		string nowName = now->getName();
		string nowType = "ID";
		char nowName2[500], nowType2[500];
		int i;
		for(i=0;i<nowName.size();i++)
		{ 
			nowName2[i]=nowName[i];
		}
		nowName2[i]='\0';
		for(i=0;i<nowType.size();i++)
		{ 
			nowType2[i]=nowType[i];
		}
		nowType2[i]='\0';
		
		fprintf(logout,"<%s,%s> ",nowName2,nowType2);
		cout<<nowName<<" "<<nowType<<endl;
                now=now->rc;
            }
		fprintf(logout,"\n");
            
        }
    }
};
class SymbolTable
{
    ScopeTable* curr_scope_table;
    int curr_size;
public:
    int getCurrSize()
    {
        return curr_scope_table->unique_number;
    }
    SymbolTable()
    {
        curr_scope_table = NULL;
        curr_size = 0;
    }
    void clearTable()
    {
        ScopeTable* now = curr_scope_table;
        while(now!=NULL)
        {
            ScopeTable* nextPointer = now->parent_scope;
            delete now;
            now = nextPointer;
        }
        curr_scope_table=NULL;
    }
    ~SymbolTable()
    {
        clearTable();
    }
    void EnterScope(int total)
    {
        curr_size++;
        ScopeTable* temp = new ScopeTable(total, curr_size, curr_scope_table);
        curr_scope_table = temp;
    }
    bool ExitScope()
    {
        if(curr_scope_table->unique_number == 1)
        {
            return false;
        }
        ScopeTable* temp = curr_scope_table->parent_scope;
        delete curr_scope_table;
        curr_scope_table = temp;
        return true;
    }
    bool Insert(string key, string val)
    {
        bool result = curr_scope_table->insertHash(key, val);
        return result;
    }
    bool Delete(string key)
    {
        SymbolInfo* found=curr_scope_table->searchHelp(key);
        if(found==NULL)
        {
            return false;// nothing to delete
        }
        curr_scope_table->deleteHash(key);
        return true;
    }
    int LookUp(string key)
    {
        ScopeTable* now = curr_scope_table;
        SymbolInfo* result=NULL;
        while(now!=NULL)
        {
            result = now->searchHash(key);
            if(result!=NULL)
            {
                break; // we got here
            }
            now = now->parent_scope;
        }
        if(result!=NULL)
        {
            return now->unique_number;
        }
        else
        {
            return -1;
        }
    }
    void PrintCurrentScopeTable()
    {
        curr_scope_table->print();
    }
    void PrintAllScopeTable()
    {
        ScopeTable* now = curr_scope_table;
        while(now!=NULL)
        {
            now->print();
            now=now->parent_scope;
        }
    }
    int getIndexInfoFirst(string key, string val="")
    {
        ScopeTable* now = curr_scope_table;
        int p=-1;
        while(now!=NULL)
        {
            p=now->getIndexInfoFirst(key);
            if(p!=-1)
            {
                break;
            }
            now=now->parent_scope;
        }
        return p;
    }
    int getIndexInfoSecond(string key, string val="")
    {
        int p=-1;
        ScopeTable* now = curr_scope_table;
        while(now!=NULL)
        {
            p=now->getIndexInfoSecond(key);
            if(p!=-1)
            {
                break;
            }
            now=now->parent_scope;
        }
        return p;
    }
};

SymbolTable symbolTable;
%}

WHITESPACE [ \t\f\r\v]+
LETTER [a-zA-Z]
DIGIT [0-9]
NEWLINE \n
UCN [a-zA-Z/*/(/)/%/#/@/!]

%%

{NEWLINE} 	{	line_count++;}

"if"		{
			fprintf(tokenout,"<IF, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <IF> Lexeme %s found\n",line_count,yytext);
		}
"else"		{
			fprintf(tokenout,"<ELSE, %s>\n", yytext);
			fprintf(logout,"Line# %d: Token <ELSE> Lexeme %s found\n",line_count,yytext);
		}
"for"		{
			fprintf(tokenout,"<FOR, %s>\n", yytext);
			fprintf(logout,"Line# %d: Token <FOR> Lexeme %s found\n",line_count,yytext);
		}
"while"		{
			fprintf(tokenout,"<WHILE, %s>\n", yytext);
			fprintf(logout,"Line# %d: Token <WHILE> Lexeme %s found\n",line_count,yytext);
		}
"do"		{
			fprintf(tokenout,"<DO, %s>\n", yytext);
			fprintf(logout,"Line# %d: Token <DO> Lexeme %s found\n",line_count,yytext);
		}
"break"		{
			fprintf(tokenout,"<BREAK, %s>\n", yytext);
			fprintf(logout,"Line# %d: Token <BREAK> Lexeme %s found\n",line_count,yytext);
		}
"int"		{
			fprintf(tokenout,"<INT, %s>\n", yytext);
			fprintf(logout,"Line# %d: Token <INT> Lexeme %s found\n",line_count,yytext);
		}
"char"		{
			fprintf(tokenout,"<CHAR, %s>\n", yytext);
			fprintf(logout,"Line# %d: Token <CHAR> Lexeme %s found\n",line_count,yytext);
		}
"float"		{
			fprintf(tokenout,"<FLOAT, %s>\n", yytext);
			fprintf(logout,"Line# %d: Token <FLOAT> Lexeme %s found\n",line_count,yytext);
		}
"double"	{
			fprintf(tokenout,"<DOUBLE, %s>\n", yytext);
			fprintf(logout,"Line# %d: Token <DOUBLE> Lexeme %s found\n",line_count,yytext);
		}
"void"		{
			fprintf(tokenout,"<VOID, %s>\n", yytext);
			fprintf(logout,"Line# %d: Token <VOID> Lexeme %s found\n",line_count,yytext);
		}
"return"	{
			fprintf(tokenout,"<RETURN, %s>\n", yytext);
			fprintf(logout,"Line# %d: Token <RETURN> Lexeme %s found\n",line_count,yytext);
		}
"switch"		{
			fprintf(tokenout,"<SWITCH, %s>\n", yytext);
			fprintf(logout,"Line# %d: Token <SWITCH> Lexeme %s found\n",line_count,yytext);
		}
"case"		{
			fprintf(tokenout,"<CASE, %s>\n", yytext);
			fprintf(logout,"Line# %d: Token <CASE> Lexeme %s found\n",line_count,yytext);
		}
"default"	{
			fprintf(tokenout,"<DEFAULT, %s>\n", yytext);
			fprintf(logout,"Line# %d: Token <DEFAULT> Lexeme %s found\n",line_count,yytext);
		}
"continue"	{
			fprintf(tokenout,"<CONTINUE, %s>\n", yytext);
			fprintf(logout,"Line# %d: Token <CONTINUE> Lexeme %s found\n",line_count,yytext);
		}
"+"		|

"-"		{
			fprintf(tokenout,"<ADDOP, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <ADDOP> Lexeme %s found\n",line_count,yytext);
			//insert in symbol table and print symbol table content(only non empty buckets)
			// There is a '|' in "+"'s rule, this means match execute the action for following rule
		}
"*"		|
"/"		|

"%"		{
			fprintf(tokenout,"<MULOP, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <MULOP> Lexeme %s found\n",line_count,yytext);
		}
"++"		|

"--"		{
			fprintf(tokenout,"<INCOP, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <INCOP> Lexeme %s found\n",line_count,yytext);
		}
"<"		|
"<="		|
">"		|
">="		|
"=="		|
"!="		{
			fprintf(tokenout,"<RELOP, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <RELOP> Lexeme %s found\n",line_count,yytext);
		}
"="		{
			fprintf(tokenout,"<ASSIGNOP, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <ASSIGNOP> Lexeme %s found\n",line_count,yytext);
		}
"&&"		|
"||"		{
			fprintf(tokenout,"<LOGICLOP, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <LOGICLOP> Lexeme %s found\n",line_count,yytext);
		}
"&"		|
"|"		|
"^"		|
"<<"		|
">>"		{
			fprintf(tokenout,"<BITOP, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <BITOP> Lexeme %s found\n",line_count,yytext);
		}
"!"		{
			fprintf(tokenout,"<NOT, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <NOT> Lexeme %s found\n",line_count,yytext);
		}
"("		{
			fprintf(tokenout,"<LPAREN, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <LPAREN> Lexeme %s found\n",line_count,yytext);
		}
")"		{
			fprintf(tokenout,"<RPAREN, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <RPAREN> Lexeme %s found\n",line_count,yytext);
		}
"{"		{
			fprintf(tokenout,"<LCURL, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <LCURL> Lexeme %s found\n",line_count,yytext);symbolTable.EnterScope(10);
		}
"}"		{
			fprintf(tokenout,"<RCURL, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <RCURL> Lexeme %s found\n",line_count,yytext);symbolTable.ExitScope();
		}
"["		{
			fprintf(tokenout,"<LSQUARE, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <LSQUARE> Lexeme %s found\n",line_count,yytext);
		}
"]"		{
			fprintf(tokenout,"<RSQUARE, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <RSQUARE> Lexeme %s found\n",line_count,yytext);
		}
","		{
			fprintf(tokenout,"<COMMA, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <COMMA> Lexeme %s found\n",line_count,yytext);
		}
";"		{
			fprintf(tokenout,"<SEMICOLON, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <SEMICOLON> Lexeme %s found\n",line_count,yytext);
		}
[0-9]+		{
			fprintf(tokenout,"<CONST_INT, %s>\n", yytext);
			fprintf(logout,"Line# %d: Token <CONST_INT> Lexeme %s found\n",line_count,yytext);
		}
[0-9]*\.[0-9]+(E[-+]?[0-9]+)?	 {
					fprintf(tokenout,"<CONST_FLOAT, %s>\n", yytext);
					fprintf(logout,"Line# %d: Token <CONST_FLOAT> Lexeme %s found\n",line_count,yytext);
				}
\'\n		{
				fprintf(logout,"Error at line# %d: UNFINISHED_CONST_CHAR %c\n",line_count,yytext[0]); err_count++;
		}
\'[^\'\n]*\n	{
				fprintf(logout,"Error at line# %d: UNFINISHED_CONST_CHAR ",line_count); line_count++; err_count++;
				for(int i=0;i<yyleng;i++) 
				{
					if(yytext[i]==10 || yytext[i]==13) break;
					fprintf(logout, "%c",yytext[i]);
				}
				fprintf(logout, "\n");
				
		}
\'\'		{	
			fprintf(logout,"Error at line# %d: EMPTY_CONST_CHAR %s\n",line_count,yytext); err_count++;
		}
\'\\\'		{	
			fprintf(logout,"Error at line# %d: UNFINISHED_CONST_CHAR %s\n",line_count,yytext); err_count++;
		}
\'[^\\][^\'\n]+\'	{	
			fprintf(logout,"Error at line# %d: MULTICHAR_CONST_CHAR %s\n",line_count,yytext); err_count++;
		}
\'\\[^tranbvf\'\"\\\n]\'	{	
				fprintf(logout,"Error at line# %d:MULTICHAR_CONST_CHAR %s\n",line_count,yytext); err_count++;
			}
\'\\..+\'		{	
				fprintf(logout,"Error at line# %d:MULTICHAR_CONST_CHAR %s\n",line_count,yytext); err_count++;
			}

\'[^\\\n\t\r\a\n\b\v\f]\'|\'\\[tranbvf\'\"\\]\'				{	
									   string s=string(yytext); fprintf(tokenout,"<CONST_CHAR, ");
									   if(yyleng==4){
									   if(s[1] == '\\' && s[2]=='t') {fprintf(tokenout,"\t>\n");}
									   else if(s[1] == '\\' && s[2]=='r') {fprintf(tokenout,"\r>\n");}
									   else if(s[1] == '\\' && s[2]=='a') {fprintf(tokenout,"\a>\n");}  
								           else if(s[1] == '\\' && s[2]=='n') {fprintf(tokenout,"\n>\n");}
									   else if(s[1] == '\\' && s[2]=='b') {fprintf(tokenout,"\b>\n");}
								           else if(s[1] == '\\' && s[2]=='v') {fprintf(tokenout,"\v>\n");}
									   else if(s[1] == '\\' && s[2]=='f') {fprintf(tokenout,"\f>\n");}
									   else if(s[1] == '\\' && s[2]=='\'') {fprintf(tokenout,"\'>\n");}
									   else if(s[1] == '\\' && s[2]=='\"') {fprintf(tokenout,"\">\n");}
									   else if(s[1] == '\\' && s[2]=='\\') {fprintf(tokenout,"\\>\n");}}
								           else {fprintf(tokenout,"%c>\n",s[1]);}
									   fprintf(logout,"Line# %d: Token <CONST_CHAR> Lexeme ",line_count);
									   if(s[1] == '\\' && s[2]=='t') {fprintf(logout,"\t");}
									   else if(s[1] == '\\' && s[2]=='r') {fprintf(logout,"\r");}
									   else if(s[1] == '\\' && s[2]=='a') {fprintf(logout,"\a");}  
								           else if(s[1] == '\\' && s[2]=='n') {fprintf(logout,"\n");}
									   else if(s[1] == '\\' && s[2]=='b') {fprintf(logout,"\b");}
								           else if(s[1] == '\\' && s[2]=='v') {fprintf(logout,"\v");}
									   else if(s[1] == '\\' && s[2]=='f') {fprintf(logout,"\f");}
									   else {fprintf(logout,"%c",s[1]);}
								           fprintf(logout, " found\n");

									}
\" 			{
				BEGIN STRINGSTART; 
			}
<STRINGSTART><<EOF>>      {
					fprintf(logout,"Error at line# %d: UNFINISHED_COMMENT %s\n",line_count,yytext);	err_count++;BEGIN INITIAL;		
			      	   }
<STRINGSTART>([a-z]*(\\\n))*[a-z]*[^\\]\n	{fprintf(logout,"Error at line# %d: UNFINISHED_STRING %s\n",line_count,yytext);err_count++;BEGIN INITIAL;}
<STRINGSTART>([^\"]*\") {

			 	string s=(string)yytext; int sz=0;
				//cout<<yytext<<" "<<yyleng<<endl;
        		for(int i=0;i<yyleng-1;i++)
        		{	
				int aaa=yytext[i];
            			//if(yytext[i]=='\\' && yytext[i+1]=='n')
                			//sz++;
				if(aaa==10 || aaa==13)
                			sz++;
        		}
        		stack<char>stck; int i=yyleng-2;
			if(sz==0) {	fprintf(tokenout,"<SINGLE LINE STRING, ");
					fprintf(logout,"Line# %d: Token <SINGLE LINE STRING> Lexeme \"%s found\n",line_count,yytext);}
			else {fprintf(tokenout,"<MULTI LINE STRING, ");
					fprintf(logout,"Line# %d: Token <MULTI LINE STRING> Lexeme \"%s found\n",line_count,yytext);}
        		for( i=yyleng-2;i>0;i--)
       			 {	
				int aaa=(int)yytext[i];
				//cout<<aaa<<endl;
				if(yytext[i]==10 || yytext[i]==13) { if(aaa==10) line_count++; continue;}
				if(aaa==9){stck.push('\t');continue;}
            			if(yytext[i]=='t' && yytext[i-1]=='\\') {stck.push('\t');i--;}
            			else if(yytext[i]=='r' && yytext[i-1]=='\\') {stck.push('\r');i--;}
            			else if(yytext[i]=='a' && yytext[i-1]=='\\') {stck.push('\a');i--;}
           			 else if(yytext[i]=='b' && yytext[i-1]=='\\') {stck.push('\b');i--;}
            			else if(yytext[i]=='v' && yytext[i-1]=='\\') {stck.push('\v');i--;}
            			else if(yytext[i]=='f' && yytext[i-1]=='\\') {stck.push('\f');i--;}
            			else if(yytext[i]=='\'' && yytext[i-1]=='\\') {stck.push('\'');i--;}
				else if(yytext[i]=='\"' && yytext[i-1]=='\\') {stck.push('\"');i--;}
            			else if(yytext[i]=='\\') {}
            			else stck.push(yytext[i]);
       			 }
        		if(i==0) stck.push(yytext[i]);

        		while(stck.empty()==false)
        		{
            			char c=stck.top();
				int aaa=(int)c;
            			if(aaa==9) {fprintf(tokenout,"\t");stck.pop();continue;}
				fprintf(tokenout,"%c",c);
            			stck.pop();
        		}
       			fprintf(tokenout,">\n");
		         BEGIN INITIAL;
			}

\/\*                    { 	BEGIN MULTIPLECOMMENTSTART; fprintf(logout,"Line# %d: Token <MULTI LINE COMMENT> Lexeme %s",line_count,"\/\*");
			}
<MULTIPLECOMMENTSTART>([a-zA-Z\t\b\\\*0-9 ]*\*\/)          {
								fprintf(logout,"%s found\n",yytext);
								BEGIN INITIAL;
							   }
<MULTIPLECOMMENTSTART>([a-zA-Z\t\b\\\*0-9 ]*)       {
								fprintf(logout,"%s",yytext);
								BEGIN MULTIPLECOMMENTSTART;
				 		     }
<MULTIPLECOMMENTSTART>\n      {
					fprintf(logout,"\n");line_count++;			
			      }
<MULTIPLECOMMENTSTART><<EOF>>      {
					fprintf(logout,"Error at line# %d: UNFINISHED_COMMENT %s\n",line_count,yytext);	err_count++;BEGIN INITIAL;		
			      	   }

\/\/	{ 	fprintf(logout,"Line# %d: Token <SINGLE LINE COMMENT> Lexeme %s",line_count,yytext); BEGIN SINGLECOMMENTSTART;
	}
<SINGLECOMMENTSTART>(\\\n)	{
					fprintf(logout,"%s",yytext);line_count++; BEGIN SINGLECOMMENTSTART;
				}
<SINGLECOMMENTSTART>\n		{	
					for(int i=0;i<yyleng;i++){
					if(yytext[i]==10 || yytext[i]==13)break;
					fprintf(logout,"%c",yytext[i]);
					}
					
					fprintf(logout," found\n");line_count++; BEGIN INITIAL;
				}
<SINGLECOMMENTSTART>([a-zA-Z\t\,\b0-9 ]*)       {
								fprintf(logout,"%s",yytext);
								BEGIN SINGLECOMMENTSTART;
				 		     }
<SINGLECOMMENTSTART>\\		{
					fprintf(logout,"%s",yytext);BEGIN SINGLECOMMENTSTART2;
				}
<SINGLECOMMENTSTART2>\n		{
					fprintf(logout,"%s",yytext);BEGIN SINGLECOMMENTSTART;line_count++;
				}



				



([a-zA-Z_][a-zA-Z0-9_]*)  {
				fprintf(tokenout,"<ID, %s>\n", yytext);
				fprintf(logout,"Line# %d: Token <ID> Lexeme %s found\n",line_count,yytext); string s = (string)yytext;
				bool result = symbolTable.Insert((string)yytext,(string)yytext);
            			if(result)
            			{	
                			symbolTable.PrintAllScopeTable();
            			}
           			 else
          			  {	
					fprintf(logout,"\t%s already exists in the current ScopeTable\n",yytext);
                			
          			  }	
			  }
[0-9]+\.[0-9]*([\.]+[0-9]*)+	{
					fprintf(logout,"Error at line# %d: TOO_MANY_DECIMAL_POINTS %s\n",line_count,yytext); err_count++;
				}
[0-9]+\.[0-9]+(E[-+]?[0-9]+)?([\.]+[0-9]*)+	{
							fprintf(logout,"Error at line# %d: ILLFORMED_NUMBER %s\n",line_count,yytext);err_count++;
						}
[0-9]+\.[^0-9]*(E[-+]?[0-9]+)?([\.]+[0-9]*)+    {
							fprintf(logout,"Error at line# %d: ILLFORMED_NUMBER %s\n",line_count,yytext);err_count++;
						}
[0-9]+(\.[^0-9]*)*(E[-+]?[0-9]+)?([\.]+[0-9]*)+ {
							fprintf(logout,"Error at line# %d: ILLFORMED_NUMBER %s\n",line_count,yytext);err_count++;
						}
[0-9]+(\.[^0-9]*)*(E[-+]?[0-9]+)?([\.]*[0-9]*)+ {
							fprintf(logout,"Error at line# %d: ILLFORMED_NUMBER %s\n",line_count,yytext);err_count++;
						}
[0-9]+[^;\n\t\b\f\r ]*	{
				fprintf(logout,"Error at line# %d: INVALID_ID_SUFFIX_NUM_PREFIX %s\n",line_count,yytext);err_count++;
			}
[~`\.!@#$\^]	{
			fprintf(logout,"Error at line# %d: UNRECOGNIZED_CHAR %s\n",line_count,yytext);err_count++;
		}

%%

int main(int argc, char** argv) {
	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}

	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	symbolTable.EnterScope(10);
	logout= fopen("log.txt","w");
	tokenout= fopen("token.txt","w");

	yyin= fin;
	yylex();
	symbolTable.PrintCurrentScopeTable();
	fprintf(logout, "Total lines: %d\n", line_count);
	fprintf(logout, "Total errors: %d\n", err_count);
	fclose(yyin);
	fclose(tokenout);
	fclose(logout);
	return 0;
}
