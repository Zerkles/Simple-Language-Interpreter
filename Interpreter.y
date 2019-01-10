%{
	#include "instrukcje.h"
	#include <stdio.h>
	#include <string>
	#include <vector>
	void yyerror(const char*);
	int yylex();
	
	char *string;//shift reduce conflict
	int liczbaZmiennych = 0;
	std::vector<std::string> zmienne;
	std::vector<int> wartosci;
	int indeksZmiennej(std::string* nazwa);

	std::vector<instrukcja> kolejka_instrukcji;
	void wykonaj_instrukcje();	
	
%}




%union {
    int iValue;
	int* ptr;
    std::string *vName;
	instrukcja instruction;
};

%start S
%token <iValue> LICZBA 
%type<ptr> E
%type <vName> ZMIENNA
%token UNK PRINT ZMIENNA
%type <instruction> INSTR
%token IF WHILE

%%
S : S INSTR ';' {printf("----------wykonywanie linii kodu----------\n"); wykonaj_instrukcje(); }
  | INSTR ';' {printf("----------wykonywanie linii kodu----------\n"); wykonaj_instrukcje(); }
  | /*nic*/
  ;

INSTR : PRINT E {instrukcja i; i.typ='P'; i.arg1=$2; kolejka_instrukcji.push_back(i);}
	  | ZMIENNA '=' E { instrukcja i; i.typ='='; i.nazwa=$1; i.arg1=$3; kolejka_instrukcji.push_back(i);}
	  | IF E INSTR {
			instrukcja i; i.typ='I'; i.arg1=$2;
			for(int j=0; j<kolejka_instrukcji.size(); j++){
				if(kolejka_instrukcji[j].typ=='<'||kolejka_instrukcji[j].typ=='>'){
					for(int k=j; k<kolejka_instrukcji.size();k++){
						if(kolejka_instrukcji[k].typ=='+'||kolejka_instrukcji[k].typ=='-')
						{ kolejka_instrukcji.insert(kolejka_instrukcji.begin()+k,i); break;}
					}
				}
				

			}
		}
	  | WHILE E INSTR INSTR {instrukcja i; i.typ='W'; i.arg1=$2; kolejka_instrukcji.insert(kolejka_instrukcji.begin(),i); kolejka_instrukcji.push_back(i);}
      ;

E : LICZBA	{$$ = new int; *$$=$1; }
  | ZMIENNA { 
	  if(kolejka_instrukcji[0].typ=='W'&&indeksZmiennej($1)>=0){
		   $$=&wartosci[indeksZmiennej($1)];
		}
	  else{
		  $$=new int; 
		  *$$=0; 
		  instrukcja i; 
		  i.typ='R'; 
		  i.arg1=$$; 
		  i.nazwa=new std::string; *i.nazwa=$1->c_str(); 
		  kolejka_instrukcji.push_back(i);
	  }
	  //printf("\n index: %d, %s\n",wartosci[indeksZmiennej($1)],$1->c_str());
}
  | E '+' LICZBA {instrukcja i; i.typ='+'; i.arg1=$1; i.arg2=new int; *i.arg2=$3; kolejka_instrukcji.push_back(i);}
  | E '*' LICZBA {instrukcja i; i.typ='*'; i.arg1=$1; i.arg2=new int; *i.arg2=$3; kolejka_instrukcji.push_back(i);}
  | E '-' LICZBA {instrukcja i; i.typ='-'; i.arg1=$1; i.arg2=new int; *i.arg2=$3; kolejka_instrukcji.push_back(i);}
  | E '/' LICZBA {instrukcja i; i.typ='/'; i.arg1=$1; i.arg2=new int; *i.arg2=$3; kolejka_instrukcji.push_back(i);}   
  | E '<' LICZBA {instrukcja i; i.typ='<'; i.arg1=$1; i.arg2=new int; *i.arg2=$3; kolejka_instrukcji.push_back(i);}
  | E '>' LICZBA {instrukcja i; i.typ='>'; i.arg1=$1; i.arg2=new int; *i.arg2=$3; kolejka_instrukcji.push_back(i);} 
  
  | E '+' ZMIENNA {instrukcja i; i.typ='+'; i.arg1=$$; i.arg2=NULL; i.nazwa= new std::string; *i.nazwa=$3->c_str(); kolejka_instrukcji.push_back(i); }
  | E '*' ZMIENNA {instrukcja i; i.typ='*'; i.arg1=$$; i.arg2=NULL; i.nazwa= new std::string; *i.nazwa=$3->c_str(); kolejka_instrukcji.push_back(i); }
  | E '-' ZMIENNA {instrukcja i; i.typ='-'; i.arg1=$$; i.arg2=NULL; i.nazwa= new std::string; *i.nazwa=$3->c_str(); kolejka_instrukcji.push_back(i); }
  | E '/' ZMIENNA {instrukcja i; i.typ='/'; i.arg1=$$; i.arg2=NULL; i.nazwa= new std::string; *i.nazwa=$3->c_str(); kolejka_instrukcji.push_back(i); }
  | E '<' ZMIENNA {instrukcja i; i.typ='<'; i.arg1=$$; i.arg2=NULL; i.nazwa= new std::string; *i.nazwa=$3->c_str(); kolejka_instrukcji.push_back(i); }
  | E '>' ZMIENNA {instrukcja i; i.typ='>'; i.arg1=$$; i.arg2=NULL; i.nazwa= new std::string; *i.nazwa=$3->c_str(); kolejka_instrukcji.push_back(i); }
  ;
%%
int main()
{
	yyparse();
}
void yyerror(const char* str)
{
	printf("%s",str);
}

int indeksZmiennej(std::string* nazwa)
{
	for(int i = 0; i< zmienne.size(); i++)
	{
		if(zmienne[i] == *nazwa)
			return i;
	}
	return -1;
}
void wykonaj_instrukcje(){
	// legenda typow/ P-PRINT I-IF W-WHILE E-ELSE R-RESOLVE(wartość zmiennej)
	// d-dodawanie o-odejmowanie m-mnozenie D-dzielenie p-prawa wieksza l-lewa wieksza
	
	if(!kolejka_instrukcji.empty()){
	for(int j=0;j<kolejka_instrukcji.size();j++){
		instrukcja i=kolejka_instrukcji[j];
		//printf("wykonywana instrukcja: %c\n",i.typ);
		switch(i.typ){
		case '+': {
				if(i.arg2==NULL){i.arg2=&wartosci[indeksZmiennej(i.nazwa)];}
				*i.arg1+=*i.arg2;
				} break;
		case '-': {
				if(i.arg2==NULL){i.arg2=&wartosci[indeksZmiennej(i.nazwa)];}
				*i.arg1-=*i.arg2;
				} break;
		case '*': {
				if(i.arg2==NULL){i.arg2=&wartosci[indeksZmiennej(i.nazwa)];}
				*i.arg1*=*i.arg2;
				} break;
		case '/': {
				if(i.arg2==NULL){i.arg2=&wartosci[indeksZmiennej(i.nazwa)];}
				*i.arg1/=*i.arg2;
				} break;
		case '<': {
				if(i.arg2==NULL){i.arg2=&wartosci[indeksZmiennej(i.nazwa)];}
				if(*i.arg1<*i.arg2){*i.arg1=1;} 
				else{*i.arg1=0;}
				} break;
		case '>': {
				if(i.arg2==NULL){i.arg2=&wartosci[indeksZmiennej(i.nazwa)];}
				if(*i.arg1>*i.arg2) {*i.arg1=1;} 
				else{*i.arg1=0;}
				} break;
		case 'P': {printf("%d\n",*i.arg1);} break;
		case '=': {
				if(indeksZmiennej(i.nazwa)>=0)
				{
					printf("zmienna %s istnieje, przypisano do niej wartosc %d\n",i.nazwa->c_str(),*i.arg1);
					wartosci[indeksZmiennej(i.nazwa)] = *i.arg1;
				}
				else
				{
					printf("zmienna %s nie istnieje, utworzono ja i przypisano do niej wartosc %d\n",i.nazwa->c_str(),*i.arg1);
					zmienne.push_back(*i.nazwa);
					wartosci.push_back(*i.arg1);
					liczbaZmiennych += 1;
				}
			}
		case 'R': {
				*i.arg1 = wartosci[indeksZmiennej(i.nazwa)];
				printf("indeks pobieranej zmiennej to %d\n",indeksZmiennej(i.nazwa));
				} break;
		case 'I': { 
				if(*i.arg1==1){printf("prawda\n");} 
				else{ 
					printf("falsz\n"); 
					j=kolejka_instrukcji.size();} 
				} break;
		case 'W': {
			if(*i.arg1!=0){j=0;} 
			} break;
		}
	}
}
	kolejka_instrukcji.clear();
}