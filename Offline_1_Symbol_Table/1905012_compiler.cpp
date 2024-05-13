#include <bits/stdc++.h>
#include<fstream>
using namespace std;
#define ll long long

FILE* fp2;

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
        cout<<"\tScopeTable# "<<unique_number<<endl;
        for(int i=0;i<num_buckets;i++)
        {
            cout<<"\t"<<i+1<<"--> ";
            SymbolInfo* now=p[i];
            while(now!=NULL)
            {
                cout<<"<"<<now->getName()<<","<<now->getType()<<"> ";
                now=now->rc;
            }
            cout<<endl;
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

int main()
{

	FILE* fp1=freopen("compilerInput.txt", "r", stdin);
	fp2=freopen("compilerOutput.txt", "w", stdout);

	string s, I, a, b, t;
	int numOfBuckets, caseNo=1;

	getline(cin,s);


	numOfBuckets=std::stoi(s);
	SymbolTable symbolTable;
	symbolTable.EnterScope(numOfBuckets);

	while(1)
    {
        cout<<"Cmd "<<caseNo++<<": ";

        getline(cin,s);
        int startIdx=0;
        string commands[6];
        int leftIdx=0, rightIdx=0;

        if(s=="Q")
        {
            startIdx=1;
            commands[0]="Q";
        }
        else{

        for(int i=0;i<s.size();i++)
        {
            if(s[i]==10 || s[i]==13)
            {
                    string finalString="";
                    for(int j=leftIdx;j<i;j++)
                    {
                        string z="";
                        z+=s[j];
                        finalString=finalString+z;

                    }
                    commands[startIdx++]=finalString;
                    leftIdx=i+1;
                    rightIdx=i+1;
                    break;

            }
            else if(startIdx>3)
                break;
            else if(s[i]==' ')
            {
                string finalString="";
                for(int j=leftIdx;j<i;j++)
                {
                    string z="";
                    z+=s[j];
                    finalString=finalString+z;

                }
                commands[startIdx++]=finalString;
                leftIdx=i+1;
                rightIdx=i+1;
            }
        }
        }


        I = commands[0];
        if(I=="I")
        {
            if(startIdx!=3)
            {
                cout<<I;
                for(int i=1;i<startIdx;i++)
                    {
                        cout<<" "<<commands[i];

                    }
                cout<<endl;
                cout<<"\tNumber of parameters mismatch for the command I"<<endl; continue;
            }

            a= commands[1]; b=commands[2];
            cout<<I<<" "<<a<<" "<<b<<endl;


            bool result = symbolTable.Insert(a,b);
            if(result)
            {
                int pFirst=symbolTable.getIndexInfoFirst(a,b);
                int pSec=symbolTable.getIndexInfoSecond(a,b);
                cout<<"\t"<<"Inserted in ScopeTable# "<<symbolTable.getCurrSize()<<" at position "<<pFirst+1<<", "<<pSec<<endl;
            }
            else
            {
                cout<<"\t'"<<a<<"' already exists in the current ScopeTable"<<endl;
            }
        }
        else if(I=="L")
        {
           if(startIdx!=2)
           {
               cout<<I;
               for(int i=1;i<startIdx;i++)
                cout<<" "<<commands[i];
               cout<<endl;
               cout<<"\tNumber of parameters mismatch for the command L"<<endl; continue;
           }
           a=commands[1];
            cout<<I<<" "<<a<<endl;
            int where = symbolTable.LookUp(a);
            if(where!=-1)
            {
                cout<<"\t"<<"'"<<a<<"' found in ScopeTable# "<<where<<" at position ";
                int pFirst=symbolTable.getIndexInfoFirst(a,b);
                int pSec=symbolTable.getIndexInfoSecond(a,b);
                cout<<pFirst+1<<", "<<pSec<<endl;
            }
            else
            {
                cout<<"\t'"<<a<<"'" <<" not found in any of the ScopeTables"<<endl;
            }
        }
        else if(I=="P")
        {
            if(startIdx!=2)
            {
                cout<<I;
               for(int i=1;i<startIdx;i++)
                cout<<" "<<commands[i];
               cout<<endl;
                cout<<"\tNumber of parameters mismatch for the command P"<<endl; continue;
            }
            a=commands[1];
            cout<<I<<" "<<a<<endl;
            if(a=="C")
            {
                symbolTable.PrintCurrentScopeTable();
            }
            else if(a=="A")
            {
                symbolTable.PrintAllScopeTable();
            }
            else
            {
                cout<<"\tLetters of parameters mismatch for the command P"<<endl; continue;
            }
        }
        else if(I=="D")
        {
            cout<<I;
               for(int i=1;i<startIdx;i++)
                cout<<" "<<commands[i];
            cout<<endl;
            if(startIdx!=2)
            {
                cout<<"\tNumber of parameters mismatch for the  command D"<<endl; continue;
            }
            a=commands[1];
            int pFirst=symbolTable.getIndexInfoFirst(a,b);
            int pSec=symbolTable.getIndexInfoSecond(a,b);
            bool result = symbolTable.Delete(a);
             if(result)
             {
                 cout<<"\tDeleted '"<<a<<"' from ScopeTable# "<<symbolTable.getCurrSize()<<" at position "<<pFirst+1<<", "<<pSec<<endl;
             }
             else
             {
                 cout<<"\tNot found in the current ScopeTable"<<endl;
             }

        }
        else if(I=="S")
        {
            cout<<I;
            for(int i=1;i<startIdx;i++)
                cout<<" "<<commands[i];
            cout<<endl;
            if(startIdx!=1)
            {
                cout<<"\tNumber of parameters mismatch for the command S"<<endl; continue;
            }
            symbolTable.EnterScope(numOfBuckets);
        }
        else if(I=="E")
        {
            cout<<I;
            for(int i=1;i<startIdx;i++)
                cout<<" "<<commands[i];
            cout<<endl;
            if(startIdx!=1)
            {
                cout<<"\tNumber of parameters mismatch for the command S"<<endl; continue;
            }

            bool result = symbolTable.ExitScope();
            if(result)
            {

            }
            else
            {
                cout<<"\tScopeTable# 1 cannot be removed"<<endl;
            }
        }
        else if(I=="Q")
        {
            cout<<I;
            for(int i=1;i<startIdx;i++)
                cout<<" "<<commands[i];
            cout<<endl;
            if(startIdx!=1)
            {
                cout<<"\tNumber of parameters mismatch for the command S"<<endl; continue;
            }
            else
            {
                symbolTable.clearTable();
                break;
            }
        }
    }
    fclose(fp1);
    fclose(fp2);

    return 0;
}


