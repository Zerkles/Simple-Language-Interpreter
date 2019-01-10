%option noyywrap

%{
#include "instrukcje.h"
#include <string>
#include "y.tab.h"
int yyparse();
%}

%%
"PRINT" { return PRINT; }
"IF" {return IF;}
"WHILE" {return WHILE;}
[a-z]+ {
	yylval.vName = new std::string(yytext);
	
	return ZMIENNA;
}
[0-9]+ {
	yylval.iValue = atoi(yytext);
	return LICZBA;
	}
[+\-*^/=;<>] {
	return yytext[0];
	}
[ \t\n] ;
.	{
	return UNK;
	}
%%