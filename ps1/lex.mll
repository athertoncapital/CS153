{
    open Printf

    type token = 
      | INT of int
      | ID of string 
      | PLUS | MINUS | STAR | SLASH
      | AND | OR | NOT
      | LPAREN | RPAREN
      | LBRACE | RBRACE
      | ASSIGN
      | EQ | LT | GT | GTE | LTE | NEQ
      | WHITESPACE | COMMENT 
      | SEMI
      | IF | ELSE | FOR | WHILE
      | RETURN
      | EOF

    let print_token (tok : token) =
      match tok with
        | INT x -> printf "int %d\n" x
        | ID x -> printf "ident %s\n" x
        | PLUS -> printf "plus\n"
        | MINUS -> printf "minus\n"
        | STAR -> printf "star\n"
        | SLASH -> printf "slash\n"
        | AND -> printf "and\n"
        | OR -> printf "or\n"
        | NOT -> printf "not\n"
        | LPAREN -> printf "lparen\n"
        | RPAREN -> printf "rparen\n"
        | LBRACE -> printf "lbrace\n"
        | RBRACE -> printf "rbrace\n"
        | ASSIGN -> printf "assign\n"
        | EQ -> printf "eq\n"
        | LT -> printf "lt\n"
        | GT -> printf "gt\n"
        | GTE -> printf "gte\n"
        | LTE -> printf "lte\n"
        | NEQ -> printf "neq\n"
        | WHITESPACE -> printf "whitespace\n"
        | COMMENT -> printf "comment\n"
        | SEMI -> printf "semi\n"
        | IF -> printf "if\n"
        | ELSE -> printf "else\n"
        | FOR -> printf "for\n"
        | WHILE -> printf "while\n"
        | RETURN -> printf "return\n"
        | EOF -> printf "eof\n"
}

let digit = ['0'-'9']
let id = ['a'-'z' 'A'-'Z']['a'-'z' 'A'-'Z' '0'-'9' '_']*

(* TODO: comments and EOF *)

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
  | [' ' '\t' '\n'] { WHITESPACE }
  | ';' { SEMI }
  | "if" { IF }
  | "else" { ELSE }
  | "for" { FOR }
  | "while" { WHILE }
  | "return" { RETURN }
  | "/*" { comment lexbuf; COMMENT }
  | digit+ as inum
    { let num = int_of_string inum in
      INT num
    }
  | id as word
    { ID word
    }
  | eof { EOF }
and comment = parse
  | "*/" { lexer lexbuf }
  | _ { comment lexbuf }

{
  let main () =
    let cin =
      if Array.length Sys.argv > 1
      then open_in Sys.argv.(1)
      else stdin
    in
    let lexbuf = Lexing.from_channel cin in
    let tokens = lexer lexbuf in
    let rec print_list = function [] -> () | e::l -> print_token e ; print_list l in
    print_token tokens

  let _ = Printexc.print main ()
}

(*

(* Lexer for Fish --- TODO *)

(* You need to add new definition to build the
 * appropriate terminals to feed to parse.mly.
 *)

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

(* definition section *)
let cr='\013'
let nl='\010'
let eol=(cr nl|nl|cr)
let ws=('\012'|'\t'|' ')*
let digit=['0'-'9'] 

(* rules section *)
rule lexer = parse
| eol { incr_lineno lexbuf; lexer lexbuf } 
| ws+ { lexer lexbuf }
| digit+ { INT(int_of_string(Lexing.lexeme lexbuf)) } 

*)