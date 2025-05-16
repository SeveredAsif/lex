#include <iostream>
#include <string>

using namespace std;

class SymbolInfo{
    private:
        string name;
        string type;
        SymbolInfo* next;
        string printingLine;
    public:
        SymbolInfo(string name, string type,string print = ""){
            this->name = name;
            this->type = type;
            this->next = nullptr;
            this->printingLine= print;
            //cout<<printingLine<<endl;
        }

        string getName(){
            return this->name;
        }
        void setName(string name){
            this->name = name;
        }
        string getPrintingLine(){
            return this->printingLine;
        }
        void setPrintingLine(string s){
            this->printingLine = s;
        }
        string getType(){
            return this->type;
        }
        void setType(string type){
            this->type = type;            
        }
        SymbolInfo* getNext(){
            return this->next;
        }
        void setNext(SymbolInfo* next){
            this->next = next;
        }
        // void print(){
        //     cout<<"<"<<name<<","<<type<<
        // }
};