%option noyywrap 
%{
    #include<math.h>
    #include"2105131_SymbolTable.hpp"
    #include <sstream>
    #include <string>
    #include <cstdio>
    using namespace std;
    SymbolTable* st;
    string lexemecurr = "";
    string curr = "";
    FILE* logfile = nullptr;
    int error_count = 0;
%}

DIGIT [0-9]
%x SComment String MComment
%%

#yylineno
\n {
    yylineno++;
    cout << " Line Count: " << yylineno << endl;
    /*fprintf(logfile, "Line no %d: \n", yylineno);*/
}


#lexicalErrors
{DIGIT}*\.{DIGIT}*\..* {
    fprintf(logfile, "Error at line no: %d: Too many decimal points: %s\n\n", yylineno, yytext);
    error_count++;
}

{DIGIT}+[A-Za-z_]+ {
    fprintf(logfile, "Error at line no: %d: Invalid prefix on ID or invalid suffix on Number: %s\n\n", yylineno, yytext);
    error_count++;
}

'(([ -~]{-}['\\])([ -~]{-}['\\])+)' {
    cout<<yytext<<" error char"<<endl;
    fprintf(logfile, "Error at line no: %d: Multi-character constant error: %s\n\n", yylineno, yytext);
    error_count++;
}

<String><<EOF>> {
    fprintf(logfile, "Error at line no: %d: Unterminated string: %s\n\n", yylineno, lexemecurr.c_str());
    error_count++;
    exit(1);
}

<MComment><<EOF>> {
    fprintf(logfile, "Error at line no: %d: Unterminated comment: %s\n\n", yylineno, curr.c_str());
    error_count++;
    exit(1);
}

'' {
    fprintf(logfile, "Error at line no: %d: Empty character constant error: %s\n\n", yylineno, yytext);
    error_count++;
    exit(1);
}

[#@$] {
    fprintf(logfile, "Error at line no: %d: Unrecognized character: %s\n\n", yylineno, yytext);
    error_count++;
}
'\\' {
    fprintf(logfile, "Error at line no: %d: Unterminated character: %s\n\n", yylineno, yytext);
    error_count++;
}


#whitespace
[ \t\r\f\v]+               { /* skip */ }

#Comments
<INITIAL>\/\/              { BEGIN(SComment); curr+=yytext;}
<SComment>\\\n             { yylineno++; curr+=yytext;}
<SComment>\n                {   BEGIN(INITIAL);  
                                cout << " Line Count: " << yylineno << endl; 
                                //curr+='\n';
                                fprintf(logfile, "Line no %d: Token <COMMENT> Lexeme %s found\n\n", yylineno,curr.c_str());
                                curr="";
                                yylineno++;
                            }
<SComment>.                  { curr+=yytext; }

#MultilineComment
<INITIAL>"/*"             { BEGIN(MComment); curr+=yytext;}
<MComment>"*/"             { BEGIN(INITIAL); 
                             curr+=yytext;
                             fprintf(logfile, "Line no %d: Token <COMMENT> Lexeme %s found\n\n", yylineno,curr.c_str());
                             curr="";
                            }
<MComment>\n {
    yylineno++;
    cout << " Line Count: " << yylineno << endl;
    curr += '\n'; 
}
<MComment>.                 { curr+=yytext;}

#Keywords
if                { printf("<IF>");    fprintf(logfile, "Line no %d: Token <IF> Lexeme if found\n\n", yylineno); }
for               { printf("<FOR>");   fprintf(logfile, "Line no %d: Token <FOR> Lexeme for found\n\n", yylineno); }
do                { printf("<DO>");    fprintf(logfile, "Line no %d: Token <DO> Lexeme do found\n\n", yylineno); }
int               { printf("<INT>");   fprintf(logfile, "Line no %d: Token <INT> Lexeme int found\n\n", yylineno); }
float             { printf("<FLOAT>"); fprintf(logfile, "Line no %d: Token <FLOAT> Lexeme float found\n\n", yylineno); }
void              { printf("<VOID>");  fprintf(logfile, "Line no %d: Token <VOID> Lexeme void found\n\n", yylineno); }
switch           { printf("<SWITCH>");fprintf(logfile, "Line no %d: Token <SWITCH> Lexeme switch found\n\n", yylineno); }
default           { printf("<DEFAULT>");fprintf(logfile, "Line no %d: Token <DEFAULT> Lexeme default found\n\n", yylineno); }
else              { printf("<ELSE>");  fprintf(logfile, "Line no %d: Token <ELSE> Lexeme else found\n\n", yylineno); }
while             { printf("<WHILE>"); fprintf(logfile, "Line no %d: Token <WHILE> Lexeme while found\n\n", yylineno); }
break             { printf("<BREAK>");fprintf(logfile, "Line no %d: Token <BREAK> Lexeme break found\n\n", yylineno); }
char              { printf("<CHAR>");  fprintf(logfile, "Line no %d: Token <CHAR> Lexeme char found\n\n", yylineno); }
double            { printf("<DOUBLE>");fprintf(logfile, "Line no %d: Token <DOUBLE> Lexeme double found\n\n", yylineno); }
return           { printf("<RETURN>");fprintf(logfile, "Line no %d: Token <RETURN> Lexeme return found\n\n", yylineno); }
case              { printf("<CASE>");  fprintf(logfile, "Line no %d: Token <CASE> Lexeme case found\n\n", yylineno); }
continue         { printf("<CONTINUE>");fprintf(logfile, "Line no %d: Token <CONTINUE> Lexeme continue found\n\n", yylineno); }
goto              { printf("<GOTO>");  fprintf(logfile, "Line no %d: Token <GOTO> Lexeme goto found\n\n", yylineno); }
long             { printf("<LONG>");  fprintf(logfile, "Line no %d: Token <LONG> Lexeme long found\n\n", yylineno); }
short             { printf("<SHORT>"); fprintf(logfile, "Line no %d: Token <SHORT> Lexeme short found\n\n", yylineno); }
static            { printf("<STATIC>");fprintf(logfile, "Line no %d: Token <STATIC> Lexeme static found\n\n", yylineno); }
unsigned          { printf("<UNSIGNED>");fprintf(logfile, "Line no %d: Token <UNSIGNED> Lexeme unsigned found\n\n", yylineno); }

#Constants
{DIGIT}+                      { if(st->getCurrentScope()->getId()>1){
                                printf("<CONST_INT,%s>", yytext);   
                                fprintf(logfile, "Line no %d: Token <CONST_INT> Lexeme %s found\n\n", yylineno, yytext); 
                                stringstream ss;
                                ss << "<CONST_INT," << yytext << ">";
                                string printStr = ss.str();
                                bool ans = st->insert(yytext, "CONST_INT", printStr);
                                if (ans) fprintf(logfile, "%s\n", st->printAllScope().c_str());
                                if(!ans){
                                    string ans = st->lookUp(yytext);
                                    fprintf(logfile, "< %s : CONST_INT > already exists in %s\n\n", yytext, ans.c_str());

                                }
                                }
                            }

[0-9]*\.?[0-9]+(E[+-]?{DIGIT}+)? { 
    if(st->getCurrentScope()->getId()>1){

    printf("<CONST_FLOAT,%s>", yytext); 
    fprintf(logfile, "Line no %d: Token <CONST_FLOAT> Lexeme %s found\n\n", yylineno, yytext); 
    stringstream ss;
    ss << "<CONST_FLOAT," << yytext << ">";
    string printStr = ss.str();
    bool ans = st->insert(yytext, "CONST_FLOAT", printStr);
    if (ans) fprintf(logfile, "%s\n", st->printAllScope().c_str());
    if(!ans){
        string ans = st->lookUp(yytext);
        fprintf(logfile, "< %s : FLOAT > already exists in %s\n\n", yytext, ans.c_str());

    }
    }
}

[0-9]*\.?[0-9]+(E[+-]?{DIGIT}+.*\..*) {
    fprintf(logfile, "Error at Line no: %d: Ill-formed number: %s\n\n", yylineno, yytext);
    error_count++;
}


#Characters

'\\([tabfrbv0])'            {   
                                if(st->getCurrentScope()->getId()>1)
                                printf("<CONST_CHAR,%c>", yytext[2]); 
                                char value;

                                if (yytext[2] == 'a') value = '\a';
                                else if (yytext[2] == 't') value = '\t';
                                else if (yytext[2] == 'r') value = '\r';
                                else if (yytext[2] == 'b') value = '\b';
                                else if (yytext[2] == 'f') value = '\f';
                                else if (yytext[2] == 'v') value = '\v';
                                else if (yytext[2] == '0') value = '\0';
                                else value = yytext[2]; // not an escape character

                                fprintf(logfile, "Line no %d: Token <CONST_CHAR> Lexeme '\\%c' found --> <CONST_CHAR, %c>\n\n", 
                                yylineno, yytext[2], value);  
                                stringstream ss;
                                ss << "<CONST_CHAR," << yytext << ">";
                                string printStr = ss.str();
                                bool ans = st->insert(yytext, "CONST_CHAR", printStr);
                                if (ans) fprintf(logfile, "%s\n", st->printAllScope().c_str());
                                if(!ans){
                                    string ans = st->lookUp(yytext);
                                    fprintf(logfile, "< %s : CONST_CHAR > already exists in %s\n\n", yytext, ans.c_str());

                                }
                                
                            }
'.'        {   
                                if(st->getCurrentScope()->getId()>1){
                                printf("<CONST_CHAR,%c>", yytext[2]); 
                                fprintf(logfile, "Line no %d: Token <CONST_CHAR> Lexeme '%c' found --> <CONST_CHAR, %c>\n\n", yylineno, yytext[1],yytext[1]); 
                                stringstream ss;
                                ss << "<CONST_CHAR," << yytext << ">";
                                string printStr = ss.str();
                                bool ans = st->insert(yytext, "CONST_CHAR", printStr);
                                if (ans) fprintf(logfile, "%s\n", st->printAllScope().c_str());
                                if(!ans){
                                    string ans = st->lookUp(yytext);
                                    fprintf(logfile, "< %s : CONST_CHAR > already exists in %s\n\n", yytext, ans.c_str());

                                }
                                }
                                
                            }
'\\n'                         { 
                                if(st->getCurrentScope()->getId()>1){
                                printf("<CONST_CHAR,%c>", '\n'); fprintf(logfile, "Line no %d: Token <CONST_CHAR> Lexeme '\\n' found --> <CONST_CHAR, %c>\n\n", yylineno,'\n'); 
                                stringstream ss;
                                ss << "<CONST_CHAR," << "'\n'" << ">";
                                string printStr = ss.str();
                                bool ans = st->insert(yytext, "CONST_CHAR", printStr);
                                if (ans) fprintf(logfile, "%s\n", st->printAllScope().c_str());
                                if(!ans){
                                    string ans = st->lookUp(yytext);
                                    fprintf(logfile, "< %s : CONST_CHAR > already exists in %s\n\n", yytext, ans.c_str());

                                }
                                }

                                }
"'"[^']{2} {
    fprintf(logfile, "Error at line no: %d: Unterminated character: %s\n\n", yylineno, yytext);
    error_count++;
}



#Operators
[+-]                          { printf("<ADDOP,%s>", yytext); fprintf(logfile, "Line no %d: Token <ADDOP> Lexeme %s found\n\n", yylineno, yytext); }
[*%//]                        { printf("<MULOP,%s>", yytext); fprintf(logfile, "Line no %d: Token <MULOP> Lexeme %s found\n\n", yylineno, yytext); }
"++"|"--"                   { printf("<INCOP,%s>", yytext); fprintf(logfile, "Line no %d: Token <INCOP> Lexeme %s found\n\n", yylineno, yytext); }
"<"|"<="|">"|">="|"=="|"!="    { printf("<RELOP,%s>", yytext); fprintf(logfile, "Line no %d: Token <RELOP> Lexeme %s found\n\n", yylineno, yytext); }
=                             { printf("<ASSIGNOP,%s>", yytext); fprintf(logfile, "Line no %d: Token <ASSIGNOP> Lexeme %s found\n\n", yylineno, yytext); }
"&&"|"||"                   { printf("<LOGICOP,%s>", yytext); fprintf(logfile, "Line no %d: Token <LOGICOP> Lexeme %s found\n\n", yylineno, yytext); }
!                             { printf("<NOT,%s>", yytext); fprintf(logfile, "Line no %d: Token <NOT> Lexeme %s found\n\n", yylineno, yytext); }
\(                            { printf("<LPAREN,%s>", yytext); fprintf(logfile, "Line no %d: Token <LPAREN> Lexeme %s found\n\n", yylineno, yytext); }
\)                            { printf("<RPAREN,%s>", yytext); fprintf(logfile, "Line no %d: Token <RPAREN> Lexeme %s found\n\n", yylineno, yytext); }
\{                            { printf("<LCURL,%s>", yytext); fprintf(logfile, "Line no %d: Token <LCURL> Lexeme %s found\n\n", yylineno, yytext); st->enterScope();}
\}                            { printf("<RCURL,%s>", yytext); fprintf(logfile, "Line no %d: Token <RCURL> Lexeme %s found\n\n", yylineno, yytext); st->exitScope();}
\[                            { printf("<LTHIRD,%s>", yytext); fprintf(logfile, "Line no %d: Token <LTHIRD> Lexeme %s found\n\n", yylineno, yytext); }
\]                            { printf("<RTHIRD,%s>", yytext); fprintf(logfile, "Line no %d: Token <RTHIRD> Lexeme %s found\n\n", yylineno, yytext); }
,                             { printf("<COMMA,%s>", yytext); fprintf(logfile, "Line no %d: Token <COMMA> Lexeme %s found\n\n", yylineno, yytext); }
;                             { printf("<SEMICOLON,%s>", yytext); fprintf(logfile, "Line no %d: Token <SEMICOLON> Lexeme %s found\n\n", yylineno, yytext); }



#Identifiers
<INITIAL>[a-zA-Z_][a-zA-Z0-9_]* {
    cout<<yytext<<" valid id"<<endl;
    //if(st->getCurrentScope()->getId()>1)
    printf("<ID,%s>", yytext);
    fprintf(logfile, "Line no %d: Token <ID> Lexeme %s found\n\n", yylineno, yytext);
    stringstream ss;
    ss << "<ID," << yytext << ">";
    string printStr = ss.str();
    bool ans = st->insert(yytext, "ID", printStr);
    if (ans) fprintf(logfile, "%s\n", st->printAllScope().c_str());
    if(!ans){
        string ans = st->lookUp(yytext);
        fprintf(logfile, "< %s : ID > already exists in %s\n\n", yytext, ans.c_str());

    }
}

#String
<INITIAL>\"      { BEGIN(String);curr = "<STRING, "; lexemecurr ="\"" ; }
<String>\\\n      { lexemecurr+="\\";lexemecurr += '\n'; curr+=""; yylineno++;}
<String>\\n       { curr += "\n"; yylineno++;lexemecurr += "\n";}
<String>\n        { fprintf(logfile, "Error at Line no: %d: Unterminated string: %s\n\n", yylineno, yytext); error_count++; BEGIN(INITIAL); }
<String>\"         {lexemecurr+=yytext;curr+="\"";}
<String>.         { if(strcmp(yytext, "\\") != 0){
                    curr += yytext; 
                    //cout<<yytext<<endl;
                    } 
                    lexemecurr+=yytext;
                    
                   }
<String>[^\\]\"        {
    //curr += "\"";
    curr += yytext[0];

    curr += ">"; 
    lexemecurr += yytext[0];
    lexemecurr += "\""; 
    string display_str = curr;
    BEGIN(INITIAL);
    //string lexeme_content = display_str.substr(9, display_str.length()-10);
    //fprintf(logfile, "Line no %d: Token <STRING> Lexeme \"%s\" found --> <STRING, %s>\n\n", yylineno, curr.c_str(),curr.c_str());
        fprintf(logfile, "Line no %d: Token <STRING> Lexeme %s found --> %s\n\n", 
            yylineno, lexemecurr.c_str(), curr.c_str());
    curr = "";
    lexemecurr="";
}


<<EOF>> {
    if (logfile) {
        fprintf(logfile, "%s", st->printAllScope().c_str());
        fprintf(logfile, "\nTotal lines: %d\n", yylineno);
        fprintf(logfile, "Total errors: %d\n", error_count);
    }
    return 0;
}
%%

int main(int argc, char* argv[])
{
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <input_file>\n", argv[0]);
        return 1;
    }

    st = new SymbolTable();
    yyin = fopen(argv[1], "r");
    if (!yyin) {
        perror("Failed to open input file");
        return 1;
    }

    string log_filename = string("My") + argv[1];
    logfile = fopen(log_filename.c_str(), "w");
    if (!logfile) {
        perror("Failed to open log file");
        fclose(yyin);
        delete st;
        return 1;
    }

    yylex();

    // fprintf(logfile, "\nTotal lines: %d\n", yylineno);
    // fprintf(logfile, "Total errors: %d\n", error_count);

    fclose(yyin);
    fclose(logfile);
    delete st;

    return 0;
}
