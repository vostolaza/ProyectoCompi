/* Mini Calculator */
/* calc.y */

%{
#include "heading.h"
int yyerror(char *s);
extern "C" int yylex();

enum var_type {
  int_t, void_t
}

struct type_val{
  var_type type;
  int val;
};

map<string, type_val> tabla;


void insertar_simbolo(string id, type_val val);
bool buscar_simbolo(string id);
void actualizar_simbolo(string, type_val new_val);
%}

%union{
  int		int_val;
  string*	op_val;
  int     digit_val;
  string* id_val;
}

%start	input 

%token EOS
%token OPENPAR
%token CLOSEPAR
%token OPENSQB
%token CLOSESQB
%token OPENBR
%token CLOSEBR
%token EQ 
%token LEQ
%token GEQ
%token LT 
%token GT 
%token NEQ
%token VOID
%token RETURN
%token WHILE
%token IF
%token ELSE
%token COMMA
%token <int_val>	NUM
%token <op_val> ID
%token <int_val> INT
%token <op_val> ASSIGN
//%type	<int_val>	exp
%left	PLUS
%left	MULT
%left DIV

%%
programa:
  lista_declaracion;

lista_declaracion:
  lista_declaracion declaracion
  | declaracion
  ;

declaracion:
  var_declaracion
  | fun_declaracion
  ;

var_declaracion:
  INT ID EOS {
    if(!buscar_simbolo(string(*$2)))
      {
        type_val t;
        t.type=int_t;
        insertar_simbolo(string(*$2), t);
      }
      else
      {
        /* Error */
        yyerror("Simbolo ya definido!");
      }
  }
  | INT ID OPENSQB NUM CLOSESQB EOS
  ;

tipo:
  INT
  | VOID
  ;

fun_declaracion:
  tipo ID OPENPAR params CLOSEPAR sent_compuesta
  ;

params:
  lista_params
  | VOID
  ;

lista_params:
  lista_params COMMA param 
  | param
  ;

param:
  tipo ID
  | tipo ID OPENSQB CLOSESQB
  ;

sent_compuesta:
  OPENBR declaracion_local lista_sentencias CLOSEBR
  ;

declaracion_local:
  declaracion_local var_declaracion
  | 


input:		/* empty */
		| input decl	/*{ cout << "Result: " << $1 << endl; }*/
    | input sent
    | decl
    | sent
		;

decl:
    BOOL ID EOS {
      if(!buscar_simbolo(string(*$2)))
      {
        type_val t;
        t.type=$1;
        insertar_simbolo(string(*$2), t);
      }
      else
      {
        /* Error */
        yyerror("Simbolo ya definido!");
      }
    }
    | INT ID EOS {
      if(!buscar_simbolo(string(*$2)))
      {
        type_val t;
        t.type=$1;
        insertar_simbolo(string(*$2), t);
      }
      else
      {
        /* Error */
        yyerror("Simbolo ya definido!");
      }
    }
    | ID EOS {}

sent:
    ID ASSIGN exp EOS {}

exp:		DIGIT	{ }
    | ID
		| exp PLUS exp	{  }
		| exp MULT exp	{  }
		;

%%

int yyerror(string s)
{
  extern int yylineno;	// defined and maintained in lex.c
  extern char *yytext;	// defined and maintained in lex.c

  cerr << "ERROR: " << s << " at symbol \"" << yytext;
  cerr << "\" on line " << yylineno << endl;
  exit(1);
}

int yyerror(char *s)
{
  return yyerror(string(s));
}

void insertar_simbolo(string id, type_val val){
  tabla[id]=val;
}

bool buscar_simbolo(string id){
  return tabla.find(id)!=tabla.end();
}

void actualizar_simbolo(string, type_val new_val){
  
}