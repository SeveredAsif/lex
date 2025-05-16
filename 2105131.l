%option noyywrap 
%{
    #include<math.h>
    #include"2105131_SymbolTable.hpp"
    #include <sstream>
    #include <string>
    #include <cstdio>
    using namespace std;
    SymbolTable* st;
    int linecount = 1;
    string curr = "";
    FILE* logfile = nullptr;
    int error_count = 0;
%}

DIGIT [0-9]
%s MComment
%x SComment String
%%

#linecount
\n {
    linecount++;
    cout << " Line Count: " << linecount << endl;
    /*fprintf(logfile, "Line no %d: \n", linecount);*/
}

#lexicalErrors
{DIGIT}*\.{DIGIT}*\..*       { cout << "Line no: " << linecount << " Error: this " << yytext << endl; error_count++; }

{DIGIT}+[A-Za-z_]+        { cout << "Line no: " << linecount << " Error: that" << yytext << endl; error_count++; }
'[[:alnum:]][[:alnum:]]+'      { cout << "Line no: " << linecount << " Error: wow" << yytext << endl; error_count++; }
<String><<EOF>>             { cout << "STRING Line no: " << linecount << " Error: ajaira" << yytext << endl; error_count++; exit(1); }
<MComment><<EOF>>            { cout << "Line no: " << linecount << " Error: chole" << yytext << endl; error_count++; exit(1); }
''                           { cout << "Line no: " << linecount << " Error: bored" << yytext << endl; exit(1); }

#whitespace
[ \t\r\f\v]+               { /* skip */ }

#Comments
<INITIAL>\/\/              { BEGIN(SComment); }
<SComment>\\\n             { linecount++; }
<SComment>\n                { BEGIN(INITIAL); linecount++; cout << " Line Count: " << linecount << endl; }
<SComment>.                  { /* skip */ }

#MultilineComment
<INITIAL>"/*"             { BEGIN(MComment); }
<MComment>"*/"             { BEGIN(INITIAL); }
<MComment>.                 { /* skip */ }

#Keywords
if                { printf("<IF>");    fprintf(logfile, "Line no %d: Token <IF> Lexeme if found\n\n", linecount); }
for               { printf("<FOR>");   fprintf(logfile, "Line no %d: Token <FOR> Lexeme for found\n\n", linecount); }
do                { printf("<DO>");    fprintf(logfile, "Line no %d: Token <DO> Lexeme do found\n\n", linecount); }
int               { printf("<INT>");   fprintf(logfile, "Line no %d: Token <INT> Lexeme int found\n\n", linecount); }
float             { printf("<FLOAT>"); fprintf(logfile, "Line no %d: Token <FLOAT> Lexeme float found\n\n", linecount); }
void              { printf("<VOID>");  fprintf(logfile, "Line no %d: Token <VOID> Lexeme void found\n\n", linecount); }
switch           { printf("<SWITCH>");fprintf(logfile, "Line no %d: Token <SWITCH> Lexeme switch found\n\n", linecount); }
default           { printf("<DEFAULT>");fprintf(logfile, "Line no %d: Token <DEFAULT> Lexeme default found\n\n", linecount); }
else              { printf("<ELSE>");  fprintf(logfile, "Line no %d: Token <ELSE> Lexeme else found\n\n", linecount); }
while             { printf("<WHILE>"); fprintf(logfile, "Line no %d: Token <WHILE> Lexeme while found\n\n", linecount); }
break             { printf("<BREAK>");fprintf(logfile, "Line no %d: Token <BREAK> Lexeme break found\n\n", linecount); }
char              { printf("<CHAR>");  fprintf(logfile, "Line no %d: Token <CHAR> Lexeme char found\n\n", linecount); }
double            { printf("<DOUBLE>");fprintf(logfile, "Line no %d: Token <DOUBLE> Lexeme double found\n\n", linecount); }
return           { printf("<RETURN>");fprintf(logfile, "Line no %d: Token <RETURN> Lexeme return found\n\n", linecount); }
case              { printf("<CASE>");  fprintf(logfile, "Line no %d: Token <CASE> Lexeme case found\n\n", linecount); }
continue         { printf("<CONTINUE>");fprintf(logfile, "Line no %d: Token <CONTINUE> Lexeme continue found\n\n", linecount); }
goto              { printf("<GOTO>");  fprintf(logfile, "Line no %d: Token <GOTO> Lexeme goto found\n\n", linecount); }
long             { printf("<LONG>");  fprintf(logfile, "Line no %d: Token <LONG> Lexeme long found\n\n", linecount); }
short             { printf("<SHORT>"); fprintf(logfile, "Line no %d: Token <SHORT> Lexeme short found\n\n", linecount); }
static            { printf("<STATIC>");fprintf(logfile, "Line no %d: Token <STATIC> Lexeme static found\n\n", linecount); }
unsigned          { printf("<UNSIGNED>");fprintf(logfile, "Line no %d: Token <UNSIGNED> Lexeme unsigned found\n\n", linecount); }

#Constants
{DIGIT}+                      { printf("<CONST_INT,%s>", yytext);   
                                fprintf(logfile, "Line no %d: Token <CONST_INT> Lexeme %s found\n\n", linecount, yytext); 
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

[0-9]*\.?[0-9]+(E[+-]?{DIGIT}+)? { 
    printf("<CONST_FLOAT,%s>", yytext); 
    fprintf(logfile, "Line no %d: Token <CONST_FLOAT> Lexeme %s found\n\n", linecount, yytext); 
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

[0-9]*\.[0-9]+(E[+-]?{DIGIT}+.*\..*) { 
    cout << "Line no: " << linecount << " Error: " << yytext << endl; 
    error_count++; 
}


#Characters

'\\([tabfrbv0])'            {   
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
                                linecount, yytext[2], value);  
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
'([^nt\\abfrbv0])'        {   
                                printf("<CONST_CHAR,%c>", yytext[2]); 
                                fprintf(logfile, "Line no %d: Token <CONST_CHAR> Lexeme '%c' found --> <CONST_CHAR, %c>\n\n", linecount, yytext[1],yytext[1]); 
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
'\\n'                         { 
                                printf("<CONST_CHAR,%c>", '\n'); fprintf(logfile, "Line no %d: Token <CONST_CHAR> Lexeme '\\n' found --> <CONST_CHAR, %c>\n\n", linecount,'\n'); 
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
"'"[^']{2}                   { cout << "Line no: " << linecount << " unmatched single quote Error: kire" << yytext << endl; error_count++; }
'\\'                        { /* lone backslash */ }

#Operators
[+-]                          { printf("<ADDOP,%s>", yytext); fprintf(logfile, "Line no %d: Token <ADDOP> Lexeme %s found\n\n", linecount, yytext); }
[*%//]                        { printf("<MULOP,%s>", yytext); fprintf(logfile, "Line no %d: Token <MULOP> Lexeme %s found\n\n", linecount, yytext); }
"++"|"--"                   { printf("<INCOP,%s>", yytext); fprintf(logfile, "Line no %d: Token <INCOP> Lexeme %s found\n\n", linecount, yytext); }
"<"|"<="|">"|">="|"=="|"!="    { printf("<RELOP,%s>", yytext); fprintf(logfile, "Line no %d: Token <RELOP> Lexeme %s found\n\n", linecount, yytext); }
=                             { printf("<ASSIGNOP,%s>", yytext); fprintf(logfile, "Line no %d: Token <ASSIGNOP> Lexeme %s found\n\n", linecount, yytext); }
"&&"|"||"                   { printf("<LOGICOP,%s>", yytext); fprintf(logfile, "Line no %d: Token <LOGICOP> Lexeme %s found\n\n", linecount, yytext); }
!                             { printf("<NOT,%s>", yytext); fprintf(logfile, "Line no %d: Token <NOT> Lexeme %s found\n\n", linecount, yytext); }
\(                            { printf("<LPAREN,%s>", yytext); fprintf(logfile, "Line no %d: Token <LPAREN> Lexeme %s found\n\n", linecount, yytext); }
\)                            { printf("<RPAREN,%s>", yytext); fprintf(logfile, "Line no %d: Token <RPAREN> Lexeme %s found\n\n", linecount, yytext); }
\{                            { printf("<LCURL,%s>", yytext); fprintf(logfile, "Line no %d: Token <LCURL> Lexeme %s found\n\n", linecount, yytext); st->enterScope();}
\}                            { printf("<RCURL,%s>", yytext); fprintf(logfile, "Line no %d: Token <RCURL> Lexeme %s found\n\n", linecount, yytext); st->exitScope();}
\[                            { printf("<LTHIRD,%s>", yytext); fprintf(logfile, "Line no %d: Token <LTHIRD> Lexeme %s found\n\n", linecount, yytext); }
\]                            { printf("<RTHIRD,%s>", yytext); fprintf(logfile, "Line no %d: Token <RTHIRD> Lexeme %s found\n\n", linecount, yytext); }
,                             { printf("<COMMA,%s>", yytext); fprintf(logfile, "Line no %d: Token <COMMA> Lexeme %s found\n\n", linecount, yytext); }
;                             { printf("<SEMICOLON,%s>", yytext); fprintf(logfile, "Line no %d: Token <SEMICOLON> Lexeme %s found\n\n", linecount, yytext); }



#Identifiers
<INITIAL>[a-zA-Z_][a-zA-Z0-9_]* {
    printf("<ID,%s>", yytext);
    fprintf(logfile, "Line no %d: Token <ID> Lexeme %s found\n\n", linecount, yytext);
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
<INITIAL>\"      { BEGIN(String); curr = "<STRING,\""; }
<String>\\\n      { curr += "\\n"; }
<String>\\n       { curr += "\n"; }
<String>\n        { cout << "string error" << endl; error_count++; BEGIN(INITIAL); }
<String>\"        {
    curr += "\">\n";
    BEGIN(INITIAL);
    cout << curr;
    fprintf(logfile, "Line no %d: Token %s", linecount, curr.c_str());
    curr = "";
}
<String>.         { curr += yytext; }

<<EOF>> {
    if (logfile) {
        fprintf(logfile, "%s", st->printAllScope().c_str());
        fprintf(logfile, "\nTotal lines: %d\n", linecount);
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

    // fprintf(logfile, "\nTotal lines: %d\n", linecount);
    // fprintf(logfile, "Total errors: %d\n", error_count);

    fclose(yyin);
    fclose(logfile);
    delete st;

    return 0;
}
