(* Tianen Li and Neal Wu *)

{
  open Parse
}

let digit = ['0'-'9']
let id = ['a'-'z' 'A'-'Z']['a'-'z' 'A'-'Z' '0'-'9' '_']*

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
  | [' ' '\t' '\n'] { lexer lexbuf }
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