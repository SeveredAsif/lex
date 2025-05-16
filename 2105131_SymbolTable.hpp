using namespace std;
#include<sstream>
#include "2105131_ScopeTable.hpp"
int ScopeTable::scopeId = 1;

class SymbolTable
{
    private:
        ScopeTable* currentScope;
        int bucketCount;
    public:

        SymbolTable(int bucketCount=7,unsigned (*hashPointer)(const char *) = SDBMHash){
            // ScopeTable.setScopeId(1);
            currentScope = new ScopeTable(bucketCount,nullptr,hashPointer);
            cout<<"\tScopeTable# "<<getCurrentScope()->getId()<<" created"<<endl;
            this->bucketCount = bucketCount;
        }
        // ~SymbolTable(){
        //     while(currentScope->getParent()!=nullptr){
        //         exitScope();
        //         cout<<"\tScopeTable# "<<currentScope->getId()<<" removed"<<endl;
        //         delete currentScope;
        //     }
        // }
        ~SymbolTable() noexcept {
            while (currentScope) {
                ScopeTable* parent = currentScope->getParent();
                cout<<"\tScopeTable# "<<currentScope->getId()<<" removed"<<endl;
                delete currentScope;       
                currentScope = parent;     
            }
        }
        ScopeTable* getCurrentScope(){
            return currentScope;
        }
        void enterScope(){
            ScopeTable *newScope = new ScopeTable(bucketCount,currentScope);
            this->currentScope = newScope;
            cout<<"\tScopeTable# "<<getCurrentScope()->getId()<<" created"<<endl;
        }

        void exitScope(){
            ScopeTable *toExit = currentScope;
            if(currentScope->getParent()!=nullptr){ //preventing global scope to get deleted
                cout<<"\tScopeTable# "<<currentScope->getId()<<" removed"<<endl;
                this->currentScope = currentScope->getParent();
                delete toExit;
            }
        }

        bool insert(string name,string type,string toprint){
            bool validity = currentScope->insert(name,type,toprint);
            return validity;
        }

        bool remove(string name){
            return currentScope->Delete(name);
        }

        string lookUp(string name){
            ScopeTable* temp = currentScope;
            while(temp!=nullptr){
                string found = temp->LookUp(name);
                if(found!=""){
                    return found;
                }
                temp = temp->getParent();
            }
            cout<<"\t'"<<name<<"' not found in any of the ScopeTables"<<endl;
            return "";
        }

        void printCurrentScope(){
            currentScope->print();
        }

        string printAllScope() {
            string result;
            for (ScopeTable* sc = currentScope; sc; sc = sc->getParent()) {
                // append this scope’s snapshot
                result += sc->print();
            }
            return result;
        }
        
        
};