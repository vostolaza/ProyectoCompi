/* Mini Calculator */
/* calc.y */

%{
#include "heading.h"
#include "globals.h"
int yyerror(char *s);
extern "C" int yylex();

#define YYSTYPE TreeNode *
static TreeNode * savedTree;
static char * savedName;
static int savedLineNo;
#define MAXTOKENLEN 40
char tokenString[MAXTOKENLEN+1];


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
%token <op_val> EQ 
%token <op_val> LEQ
%token <op_val> GEQ
%token <op_val> LT 
%token <op_val> GT 
%token <op_val> NEQ
%token VOID
%token RETURN
%token WHILE
%token IF
%token ELSE
%token COMMA
%token VACIO
%token <int_val>	NUM
%token <op_val> ID
%token <int_val> INT
%token <op_val> ASSIGN
//%type	<int_val>	exp
%left	PLUS
%left MINUS
%left	MULT
%left DIV

%type<op_val> mulop addop relop
%type<id_val> lista_arg args var param lista_params fun_declaracion var_declaracion declaracion lista_declaracion programa
%type<int_val> call factor term expresion_aditiva expresion_simple expresion sentencia_retorno sentencia_iteracion sentencia_seleccion sentencia_expresion sentencia lista_sentencias declaracion_local sent_compuesta

%%
programa:
  lista_declaracion {savedTree = $1;};

lista_declaracion:
  lista_declaracion declaracion{ 
    YYSTYPE t = $1;
    if (t != NULL)
    { while (t->sibling != NULL)
        t = t->sibling;
      t->sibling = $2;
      $$ = $1; }
      else $$ = $2;
  }
  | declaracion { $$ = $1; }
  ;

declaracion:
  var_declaracion { $$ = $1; }
  | fun_declaracion { $$ = $1; }
  ;

var_declaracion:
  INT ID {
    $$ = newStmtNode(AssignK);
    $$->attr.name = copyString(tokenString);
    $$->lineno = lineno;
  } EOS
  | INT ID {
    $$ = newStmtNode(AssignK);
    $$->attr.name = copyString(tokenString);
    $$->lineno = lineno;
  } OPENSQB NUM CLOSESQB EOS 
  ;

tipo:
  INT { $$ = $1; }
  | VOID { $$ = $1; }
  ;

fun_declaracion:
  tipo ID { savedName = copyString(tokenString);
            savedLineNo = lineno; }
  OPENPAR params CLOSEPAR sent_compuesta {
    $$ = newStmtNode(AssignK);
    $$->child[0] = $1;
    $$->child[1] = $4;
    $$->child[2] = $6;
    $$->attr.name = savedName;
    $$->lineno = savedLineNo;
  }
  ;

params:
  lista_params { $$ = $1; }
  | VOID { $$ = $1; }
  ;

lista_params:
  lista_params COMMA param { 
    $$ = newStmtNode(AssingK);
    $$->child[0] = $1;
    $$->child[1] = $3; 
  }
  | param { $$ = $1; }
  ;

param:
  tipo ID {
    $$ = newStmtNode(AssingK);
    $$->child[0] = $2;
    $$->attr.name = copyString(tokenString);
  }
  | tipo ID {
    $$ = newStmtNode(AssingK);
    $$->child[0] = $2;
    $$->attr.name = copyString(tokenString);
  } OPENSQB CLOSESQB 
  ;

sent_compuesta:
  OPENBR declaracion_local lista_sentencias CLOSEBR { 
    $$ = newStmtNode(AssingK);
    $$->child[0] = $2;
    $$->child[1] = $3; 
  }
  ;

declaracion_local:
  declaracion_local var_declaracion { 
    $$ = newStmtNode(AssingK);
    $$->child[0] = $1;
    $$->child[1] = $2; 
  }
  | VACIO { $$ = $1; }
  ;

lista_sentencias:
  lista_sentencias sentencia { 
    $$ = newStmtNode(AssingK);
    $$->child[0] = $1;
    $$->child[1] = $2; 
  }
  | VACIO { $$ = $1; }
  ;

sentencia:
  sentencia_expresion { $$ = $1; }
  | sentencia_seleccion { $$ = $1; }
  | sentencia_iteracion { $$ = $1; }
  | sentencia_retorno { $$ = $1; }
  ;

sentencia_expresion:
  expresion EOS { 
    $$ = newStmtNode(AssingK);
    $$->child[0] = $1;
  }
  | EOS { $$ = $1; }
  ;

sentencia_seleccion:
  IF OPENPAR expresion CLOSEPAR sentencia { 
    $$ = newStmtNode(Ifk);
    $$->child[0] = $3;
    $$->child[1] = $5;
  }
  | IF OPENPAR expresion CLOSEPAR sentencia ELSE sentencia { 
    $$ = newStmtNode(Ifk);
    $$->child[0] = $3;
    $$->child[1] = $5;
    $$->child[2] = $7;
  }
  ;

sentencia_iteracion:
  WHILE OPENPAR expresion CLOSEPAR OPENBR lista_sentencias CLOSEBR { 
    $$ = newStmtNode(RepeatK);
    $$->child[0] = $3;
    $$->child[1] = $6;
  }
  ;

sentencia_retorno:
  RETURN EOS { $$ = $1 }
  | RETURN expresion EOS{ 
    $$ = newStmtNode(AssingK);
    $$->child[0] = $2;
  }
  ;

expresion:
  var ASSIGN expresion { 
    $$ = newExpNode(Idk);
    $$->child[0] = $1;
    $$->child[1] = $3;
  }
  | expresion_simple { $$ = $1; }
  ;
  
var:
  ID { $$ = copyString(tokenString); }
  | ID { savedName = copyString(tokenString); }
    OPENSQB expresion CLOSESQB {  
        $$ = newExpNode(Opk);
        $$->child[0] = savedName;
        $$->child[1] = $3;
      }
  ;
  
expresion_simple:
  expresion_aditiva relop expresion_aditiva {  
        $$ = newExpNode(Opk);
        $$->child[0] = $1;
        $$->child[1] = $2;
        $$->child[2] = $3;
  }
  | expresion_aditiva { $$ = $1; }
  ;
  
relop:
  LT { $$ = $1; }
  | LEQ { $$ = $1; }
  | GT { $$ = $1; }
  | GEQ { $$ = $1; }
  | EQ { $$ = $1; }
  | NEQ { $$ = $1; }
  ;

expresion_aditiva:
  expresion_aditiva addop term {  
    $$ = newExpNode(Opk);
    $$->child[0] = $1;
    $$->child[1] = $2;
    $$->child[2] = $3;
  }
  | term { $$ = $1; }
  ;

addop:
  PLUS { $$ = $1; }
  | MINUS { $$ = $1; }
  ;

term:
  term mulop factor {  
    $$ = newExpNode(Opk);
    $$->child[0] = $1;
    $$->child[1] = $2;
    $$->child[2] = $3;
  }
  | factor { $$ = $1; }
  ;

mulop:
  MULT { $$ = $1; }
  | DIV { $$ = $1; }
  ;

factor:
  OPENPAR expresion CLOSEPAR {
    $$ = $2;
  }
  | var { $$ = $1; }
  | call { $$ = $1; }
  | NUM { 
    $$ = newExpNode(ConstK);
    $$->attr.val = atoi(tokenString);
  }
;

call:
  ID OPENPAR args CLOSEPAR {  
    $$ = newStmtNode(AssignK);
    $$->child[0] = $1;
    $$->child[1] = $2;
    $$->child[2] = $3;
  }
  ;

args:
  lista_arg { $$ = $1; }
  | VACIO { $$ = $1; }
  ;

lista_arg:
  lista_arg COMMA expresion {  
    $$ = newStmtNode(AssignK);
    $$->child[0] = $1;
    $$->child[1] = $3;
  }
  | expresion { $$ = $1; }
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