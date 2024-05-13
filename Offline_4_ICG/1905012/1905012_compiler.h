#include <bits/stdc++.h>
#include<fstream>
using namespace std;
#define ll long long

class SymbolInfo
{
public:
    string name;
    string type;
    string msg;
    string label;
    int labelNo=0;

    int offset=0;
    int line=0;
    int line2=0;
    int nodeType=0;
    int scope=0;

    int isParam=0;
    int paramOffset=0;

    int etype=0;
    int esize=0;
    string rtype;

    vector<SymbolInfo*>vec;
    vector<SymbolInfo*>voidFunc;
    vector<string>fptypes;
    vector<string>argtypes;

    vector<int>trueList;
    vector<int>falseList;
    vector<int>nextList;

    SymbolInfo* ch1;
    SymbolInfo* ch2;
    SymbolInfo* ch3;
    SymbolInfo* ch4;
    SymbolInfo* ch5;
    SymbolInfo* ch6;
    SymbolInfo* ch7;

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
    SymbolInfo(string key, string val, int ndType, int lineNo,int lineNo2, string ms, SymbolInfo* ch11=NULL, SymbolInfo* ch22=NULL, SymbolInfo* ch33=NULL, SymbolInfo* ch44=NULL, SymbolInfo* ch55=NULL,SymbolInfo* ch66=NULL,SymbolInfo* ch77=NULL)
    {
        lc = NULL;
        rc = NULL;

        name = key;
        type = val;
        msg = ms;

        line = lineNo;
        line2 = lineNo2;
        nodeType = ndType;

        ch1=ch11; ch2=ch22; ch3=ch33; ch4=ch44; ch5=ch55; ch6=ch66; ch7=ch77;

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
        /*for(int i=0;i<num_buckets;i++)
        {
            SymbolInfo* now=p[i];
            while(now!=NULL)
            {
                SymbolInfo* temp=now;
                now=now->rc;
                delete temp;
            }
        }*/
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
    SymbolInfo* searchHelp2(string k, int found_scope)
    {
        ll index = SDBMHash(k);
        index = index % num_buckets;
        SymbolInfo* temp = p[index];
        while(temp!=NULL)
        {
            if(temp->getName()==k && temp->scope==found_scope)
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

           // delete found;
        }
    }

    void deleteHash2(string k, int a)
    {
        if(a==4) return;
        ll index = SDBMHash(k);
        index = index % num_buckets;
        SymbolInfo* found = searchHelp2(k,a);
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

            //delete found;
        }
    }


    SymbolInfo* searchHash(string k)
    {
        SymbolInfo* found=searchHelp(k);
        return found;
    }

    SymbolInfo* searchHash2(string k,int a)
    {
        SymbolInfo* found=searchHelp2(k,a);
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
    bool insertHash2(SymbolInfo* node)
    {
        string k = node->name;
        string value = node->type;
        ll index = SDBMHash(k);
        index = index % num_buckets;

        SymbolInfo* obj=node;

        /*SymbolInfo* found=searchHelp(k);
        if(found!=NULL)
        {
            return false;
        }*/

        if(p[index]==NULL) // first position to insert
        {
            obj=node;
            p[index]=obj;
        }
        else
        {
            SymbolInfo* now = p[index];
            while(now->rc!=NULL)
            {
                now=now->rc;
            }
            obj=node;
            now->rc=obj;
            obj->lc=now;
        }
        cout<<"In insert Symbol Table "<<node->name<<endl;
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
        cout<<"now je delete hobe "<<curr_scope_table->unique_number<<" je parent akhon "<<temp->unique_number<<endl;
        delete curr_scope_table;
        curr_scope_table = temp;
        return true;
    }
    bool Insert(string key, string val="")
    {
        bool result = curr_scope_table->insertHash(key, val);
        return result;
    }
    bool Insert2(SymbolInfo* node)
    {
        bool result = curr_scope_table->insertHash2(node);
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
     bool Delete2(string key, int a)
    {
        SymbolInfo* found=curr_scope_table->searchHelp2(key,a);
        if(found==NULL)
        {
            return false;// nothing to delete
        }
        curr_scope_table->deleteHash2(key,a);
        return true;
    }
    SymbolInfo* LookUp(string key)
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
        return result;
    }
    SymbolInfo* LookUp2(string key, int a)
    {
        ScopeTable* now = curr_scope_table;
        SymbolInfo* result=NULL;
        while(now!=NULL)
        {
            result = now->searchHash2(key,a);
            if(result!=NULL)
            {
                break; // we got here
            }
            now = now->parent_scope;
        }
        return result;
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

