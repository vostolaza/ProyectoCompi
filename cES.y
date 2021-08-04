/* Mini Calculator */
/* calc.y */

%{
#include "heading.h"
int yyerror(char *s);
extern "C" int yylex();

enum var_type {
  int_t, void_t
};

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

%start	programa 

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
%token <id_val> ID
%token <int_val> INT
%token <op_val> ASSIGN
//%type	<int_val>	exp
%left	PLUS
%left MINUS
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
  | INT ID OPENSQB NUM CLOSESQB EOS { 
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
  | %empty
  ;

lista_sentencias:
  lista_sentencias sentencia
  | %empty
  ;

sentencia:
  sentencia_expresion 
  | sentencia_seleccion 
  | sentencia_iteracion 
  | sentencia_retorno 
  ;

sentencia_expresion:
  expresion EOS 
  | EOS 
  ;

sentencia_seleccion:
  IF OPENPAR expresion CLOSEPAR sentencia 
  | IF OPENPAR expresion CLOSEPAR sentencia ELSE sentencia 
  ;

sentencia_iteracion:
  WHILE OPENPAR expresion CLOSEPAR OPENBR lista_sentencias CLOSEBR 
  ;

sentencia_retorno:
  RETURN EOS
  | RETURN expresion EOS
  ;

expresion:
  var ASSIGN expresion 
  | expresion_simple 
  ;
  
var:
  ID 
  | ID OPENSQB expresion CLOSESQB 
  ;
  
expresion_simple:
  expresion_aditiva relop expresion_aditiva
  | expresion_aditiva
  ;
  
relop:
  LT 
  | LEQ 
  | GT 
  | GEQ 
  | EQ 
  | NEQ 
  ;

expresion_aditiva:
  expresion_aditiva addop term  
  | term 
  ;

addop:
  PLUS 
  | MINUS 
  ;

term:
  term mulop factor 
  | factor 
  ;

mulop:
  MULT 
  | DIV
  ;

factor:
  OPENPAR expresion CLOSEPAR  
  | var 
  | call 
  | NUM 
;

call:
  ID OPENPAR args CLOSEPAR
  ;

args:
  lista_arg
  | %empty
  ;

lista_arg:
  lista_arg COMMA expresion 
  | expresion
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