/* Parser for Fish --- TODO */

%{
open Ast
open Lexing
(* use this to get the line number for the n'th token *)
let rhs n =
  let pos = Parsing.rhs_start_pos n in
  pos.pos_lnum
let parse_error s =
  let pos = Parsing.symbol_end_pos () in
  let l = pos.pos_lnum in
  print_string ("line "^(string_of_int l)^": "^s^"\n") 
%}

/* Tells us which non-terminal to start the grammar with. */
%start program

/* This specifies the non-terminals of the grammar and specifies the
 * types of the values they build. Don't forget to add any new non-
 * terminals here.
 */
%type <Ast.program> program
%type <Ast.stmt> stmt
%type <Ast.stmt> astmt
%type <Ast.stmt> bstmt
%type <Ast.stmt> cstmt
%type <Ast.exp> exp
%type <Ast.exp> aexp
%type <Ast.exp> bexp
%type <Ast.exp> cexp
%type <Ast.exp> dexp
%type <Ast.exp> eexp
%type <Ast.exp> fexp
%type <Ast.exp> gexp

/* The %token directive gives a definition of all of the terminals
 * (i.e., tokens) in the grammar. This will be used to generate the
 * tokens definition used by the lexer. So this is effectively the
 * interface between the lexer and the parser --- the lexer must
 * build values using this datatype constructor to pass to the parser.
 * You will need to augment this with your own tokens...
 */
%token <int> INT 
%token <string> ID
%token EOF
%token LPAREN
%token RPAREN
%token NOT
%token STAR
%token SLASH
%token PLUS
%token MINUS
%token EQ
%token NEQ
%token LT
%token LTE
%token GT
%token GTE
%token AND
%token OR
%token ASSIGN
%token SEMI
%token LBRACE
%token RBRACE
%token IF
%token ELSE
%token FOR
%token WHILE
%token RETURN
%token WHITESPACE
%token COMMENT

%left OR
%left AND
%left EQ NEQ LT LTE GT GTE
%left PLUS MINUS
%left STAR SLASH

/* Here's where the real grammar starts -- you'll need to add 
 * more rules here... Do not remove the 2%'s!! */
%%

program:
  stmt EOF { $1 }

aexp:
  INT { (Int($1), 0) }
| LPAREN exp RPAREN { $2 }
| ID { (Var($1), 0) }

bexp:
  aexp { $1 }
| NOT bexp {(Not($2), 0)}
| MINUS bexp {(Binop((Int(0), 0), Minus, $2), 0)}

cexp:
  bexp { $1 }
| cexp STAR cexp {(Binop($1, Times, $3), 0)}
| cexp SLASH cexp {(Binop($1, Div, $3), 0)}

dexp:
  cexp { $1 }
| dexp PLUS dexp {(Binop($1, Plus, $3), 0)}
| dexp MINUS dexp {(Binop($1, Minus, $3), 0)}

eexp:
  dexp { $1 }
| eexp EQ eexp {(Binop($1, Eq, $3), 0)}
| eexp NEQ eexp {(Binop($1, Eq, $3), 0)}
| eexp LT eexp {(Binop($1, Lt, $3), 0)}
| eexp LTE eexp {(Binop($1, Lte, $3), 0)}
| eexp GT eexp {(Binop($1, Gt, $3), 0)}
| eexp GTE eexp {(Binop($1, Gte, $3), 0)}

fexp:
  eexp { $1 }
| fexp AND fexp {(And($1, $3), 0)}

gexp:
  fexp { $1 }
| gexp OR gexp {(Or($1, $3), 0)}

exp:
  gexp { $1 }
| ID ASSIGN exp {(Assign($1, $3), 0)}

astmt:
| RETURN exp SEMI { (Return($2), 0) }
| exp SEMI { (Exp($1), 0) }
| LBRACE stmt RBRACE { $2 }
| LBRACE RBRACE { (Ast.skip, 0) }
| SEMI { (Ast.skip, 0) }

bstmt:
  astmt { $1 }
| FOR LPAREN exp SEMI exp SEMI exp RPAREN bstmt { (For ($3, $5, $7, $9), 0) }
| WHILE LPAREN exp RPAREN bstmt { (While($3, $5), 0) }
| IF LPAREN exp RPAREN bstmt ELSE bstmt { (If($3, $5, $7), 0) }

cstmt :
  bstmt { $1 }
| IF LPAREN exp RPAREN cstmt { (If($3, $5, (Ast.skip, 0)), 0) }


stmt :
  cstmt { $1 }
| cstmt stmt { (Seq($1, $2), 0) }
