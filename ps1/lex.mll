(* Tianen Li and Neal Wu *)

{
  open Parse
  open Lexing

  let incr_lineno lexbuf =
  let pos = lexbuf.lex_curr_p in
  lexbuf.lex_curr_p <- { pos with
    pos_lnum = pos.pos_lnum + 1;
    pos_bol = pos.pos_cnum;
  }
}

let digit = ['0'-'9']
let id = ['a'-'z' 'A'-'Z']['a'-'z' 'A'-'Z' '0'-'9' '_']*
let cr = '\013'
let nl = '\010'
let eol = (cr nl|nl|cr)
let ws = ('\012'|'\t'|' ')*

rule lexer = parse
  | '+' { PLUS }
  | '-' { MINUS }
  | '*' { STAR }
  | '/' { SLASH }
  | "&&" { AND }
  | "||" { OR }
  | '!' { NOT }
  | '(' { LPAREN }
  | ')' { RPAREN }
  | '{' { LBRACE }
  | '}' { RBRACE }
  | '=' { ASSIGN }
  | "==" { EQ }
  | '<' { LT }
  | '>' { GT }
  | ">=" { GTE }
  | "<=" { LTE }
  | "!=" { NEQ }
  | ws { lexer lexbuf }
  | eol { incr_lineno lexbuf; lexer lexbuf }
  | ';' { SEMI }
  | "if" { IF }
  | "else" { ELSE }
  | "for" { FOR }
  | "while" { WHILE }
  | "return" { RETURN }
  | "/*" { comment lexbuf }
  | digit+ as inum
    { let num = int_of_string inum in
      INT num
    }
  | id as word { ID word }
  | eof { EOF }
and comment = parse
  | "*/" { lexer lexbuf }
  | _ { comment lexbuf }