using namespace std;
#include "2105131_SymbolInfo.hpp"
#include<sstream>



unsigned int SDBMHash(const char *p) {
    unsigned int hash = 0;
    auto *str = (unsigned char *) p;
    int c{};
    while ((c = *str++)) {
    hash = (c + (hash << 6) + (hash << 16) - hash);
    }
    return hash%7;
    }
// src: https://stackoverflow.com/questions/64699597/how-to-write-djb2-hashing-function-in-c
unsigned djb2_hash(string str, unsigned num_buckets) {
    unsigned long long hash = 5381;
    for (char c : str)
        hash = ((hash << 5) + hash) + c; // hash * 33 + c
    return hash % num_buckets;
}


//src : https://algocademy.com/blog/rolling-hash-a-powerful-technique-for-string-manipulation-in-programming/

unsigned polynomial_hash(string str, unsigned num_buckets) {
    const int p = 31;
    const int m = 1e9 + 9;
    unsigned long long hash = 0, p_pow = 1;
    for (char c : str) {
        hash = (hash + (c - 'a' + 1) * p_pow) % m;
        p_pow = (p_pow * p) % m;
    }
    return hash % num_buckets;
}

class ScopeTable{
    private:
        unsigned (*hashFunc)(const char *p); 
        static int scopeId;
        SymbolInfo **array;
        int num_buckets;
        ScopeTable* parentSCope;
        int collisionCount;
        int id;
    public:
        ScopeTable(int size,ScopeTable* parent=nullptr,unsigned (*hashF)(const char *p)=SDBMHash){
            this->id = scopeId++;
            this->hashFunc = hashF;
            this->collisionCount = 0;
            array = new SymbolInfo*[size];
            for(int i=0;i<size;i++){
                array[i] = nullptr;
            }
            this->num_buckets = 7;
            this->parentSCope = parent;
        }
        ~ScopeTable(){
            for (int i=0;i<num_buckets;i++){
                SymbolInfo* temp = array[i];
                while(temp!=nullptr){
                    SymbolInfo* toDelete = temp;
                    temp = temp->getNext();
                    delete toDelete;
                }
            }
            delete [] array;
        }
        ScopeTable* getParent(){
            return this->parentSCope;
        }
        int getId(){
            return this->id;
        }
        int getCollision(){
            return this->collisionCount;
        }
        bool insert(string name, string type, string toPrint=""){
            int chainPosition = 1;
            SymbolInfo* newSymbol = new SymbolInfo(name,type,toPrint);
            unsigned int bucketNumber = hashFunc(name.c_str());
            //int bucketNumber = hashNumber % num_buckets;
            //cout<<"yoo "<<bucketNumber<<endl;
            if(array[bucketNumber]==nullptr){
                array[bucketNumber] = newSymbol;
                cout<<"\tInserted in ScopeTable# "<<this->id<<" at position "<<bucketNumber<<", "<<chainPosition<<endl;
                return true;

            }
            else{
                this->collisionCount++;
                SymbolInfo* temp = array[bucketNumber];
                if(temp->getName()==name){
                    delete newSymbol;
                    cout<<"\t'"<<name<<"'"<<" already exists in the current ScopeTable"<<endl;
                    return false;
                }
                while(temp->getNext()!=nullptr){
                    temp = temp->getNext();
                    chainPosition++;
                    if(temp->getName()==name){
                        delete newSymbol;
                        cout<<"\t'"<<name<<"'"<<" already exists in the current ScopeTable"<<endl;
                        return false;
                    }
                }
                temp->setNext(newSymbol);
                chainPosition++;
                cout<<"\tInserted in ScopeTable# "<<this->id<<" at position "<<bucketNumber<<", "<<chainPosition<<endl;
                return true;
            }
        }
        string LookUp(string name) {
            int bucket = hashFunc(name.c_str());
            SymbolInfo* temp = array[bucket];
            int chainPosition = 0;
        
            if (array[bucket] == nullptr) {
                return "";
            }
        
            while (temp != nullptr) {
                string symbolName = temp->getName();
                if (symbolName == name) {
                    // Convert id (e.g., 3) to 1.1.1 format
                    stringstream idFormat;
                    idFormat << "1";
                    for (int i = 1; i < id; ++i) {
                        idFormat << ".1";
                    }
                    string formattedID = idFormat.str();
        
                    stringstream ss;
                    ss << "ScopeTable# " << formattedID << " at position " << bucket << ", " << chainPosition;
                    return ss.str();
                }
                temp = temp->getNext();
                chainPosition++;
            }
        
            return "";
        }
        
        bool Delete(string name){
            int chainPosition = 1;
            int bucket = hashFunc(name.c_str());
            if(array[bucket]==nullptr){
                return false;
            }
            SymbolInfo* temp = array[bucket];
            string symbolName = temp->getName();
            if(symbolName==name){
                SymbolInfo* toDelete = temp;
                array[bucket] = toDelete->getNext();
                toDelete->setNext(nullptr);
                delete toDelete;
                cout<<"\tDeleted '"<<name<<"' from ScopeTable# "<<this->id<<" at position "<<bucket+1<<", "<<chainPosition<<endl;
                return true;
            }
            else{
                while(temp->getNext()!=nullptr)
                {
                    string symbolName = temp->getNext()->getName();
                    if(symbolName == name){
                        SymbolInfo* toDelete = temp->getNext();
                        temp->setNext(temp->getNext()->getNext());
                        delete toDelete;
                        cout<<"\tDeleted '"<<name<<"' from ScopeTable# "<<this->id<<" at position"<<bucket+1<<", "<<chainPosition<<endl;
                        return true;
                    }
                    temp = temp->getNext();
                    chainPosition++;
                } 
            }
            return false;
        }

        string print() const {
            ostringstream out;
            // Header
            // Construct hierarchical ID
            out << "ScopeTable # 1";
            for (int i = 1; i < id; ++i) {
                out << ".1";
            }
            out << '\n';
        
            // Only non‑empty buckets
            for (int b = 0; b < num_buckets; ++b) {
                if (array[b] == nullptr) 
                    continue;
        
                out << (b ) << " --> ";
                for (SymbolInfo* cur = array[b]; cur != nullptr; cur = cur->getNext()) {
                    out << "< " 
                        << cur->getName() 
                        << " : " 
                        << cur->getType() 
                        << " >";
                }
                out << '\n';
            }
        
            return out.str();
        }
        
    };
