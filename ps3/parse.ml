type token =
  | SEMI
  | LPAREN
  | RPAREN
  | LBRACE
  | RBRACE
  | EQEQ
  | NEQ
  | LTE
  | GTE
  | LT
  | GT
  | EQ
  | BANG
  | PLUS
  | MINUS
  | TIMES
  | DIV
  | AND
  | OR
  | RETURN
  | IF
  | ELSE
  | WHILE
  | FOR
  | LET
  | COMMA
  | INT of (int)
  | ID of (string)
  | EOF

open Parsing;;
# 2 "parse.mly"
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
# 45 "parse.ml"
let yytransl_const = [|
  257 (* SEMI *);
  258 (* LPAREN *);
  259 (* RPAREN *);
  260 (* LBRACE *);
  261 (* RBRACE *);
  262 (* EQEQ *);
  263 (* NEQ *);
  264 (* LTE *);
  265 (* GTE *);
  266 (* LT *);
  267 (* GT *);
  268 (* EQ *);
  269 (* BANG *);
  270 (* PLUS *);
  271 (* MINUS *);
  272 (* TIMES *);
  273 (* DIV *);
  274 (* AND *);
  275 (* OR *);
  276 (* RETURN *);
  277 (* IF *);
  278 (* ELSE *);
  279 (* WHILE *);
  280 (* FOR *);
  281 (* LET *);
  282 (* COMMA *);
    0 (* EOF *);
    0|]

let yytransl_block = [|
  283 (* INT *);
  284 (* ID *);
    0|]

let yylhs = "\255\255\
\001\000\001\000\002\000\004\000\004\000\003\000\003\000\005\000\
\005\000\005\000\005\000\005\000\005\000\005\000\005\000\005\000\
\006\000\006\000\017\000\017\000\007\000\007\000\008\000\008\000\
\009\000\009\000\010\000\010\000\011\000\011\000\011\000\012\000\
\012\000\012\000\012\000\012\000\013\000\013\000\013\000\014\000\
\014\000\014\000\015\000\015\000\015\000\015\000\016\000\016\000\
\016\000\016\000\016\000\000\000"

let yylen = "\002\000\
\001\000\002\000\005\000\002\000\003\000\001\000\003\000\001\000\
\002\000\003\000\003\000\007\000\005\000\005\000\009\000\006\000\
\001\000\002\000\000\000\001\000\001\000\003\000\001\000\003\000\
\001\000\003\000\001\000\003\000\001\000\003\000\003\000\001\000\
\003\000\003\000\003\000\003\000\001\000\003\000\003\000\001\000\
\003\000\003\000\001\000\002\000\002\000\002\000\001\000\001\000\
\003\000\004\000\003\000\002\000"

let yydefred = "\000\000\
\000\000\000\000\000\000\052\000\000\000\000\000\000\000\002\000\
\004\000\000\000\000\000\000\000\000\000\005\000\008\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\047\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\040\000\043\000\007\000\000\000\
\000\000\000\000\046\000\044\000\045\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\018\000\003\000\009\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\051\000\011\000\010\000\000\000\000\000\
\020\000\000\000\000\000\049\000\000\000\000\000\022\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\041\000\042\000\000\000\000\000\000\000\000\000\000\000\
\050\000\000\000\014\000\000\000\000\000\024\000\000\000\000\000\
\016\000\012\000\000\000\000\000\015\000"

let yydgoto = "\002\000\
\004\000\005\000\011\000\007\000\028\000\029\000\030\000\078\000\
\031\000\032\000\033\000\034\000\035\000\036\000\037\000\038\000\
\074\000"

let yysindex = "\007\000\
\247\254\000\000\020\255\000\000\247\254\011\255\024\255\000\000\
\000\000\014\255\045\255\069\255\030\255\000\000\000\000\002\255\
\069\255\072\255\072\255\072\255\002\255\060\255\064\255\067\255\
\053\255\000\000\044\255\069\255\086\255\071\255\079\255\102\255\
\000\255\231\255\037\255\059\255\000\000\000\000\000\000\118\255\
\120\255\131\255\000\000\000\000\000\000\122\255\002\255\002\255\
\002\255\125\255\010\255\002\255\000\000\000\000\000\000\072\255\
\072\255\072\255\072\255\072\255\072\255\072\255\072\255\072\255\
\072\255\072\255\072\255\000\000\000\000\000\000\135\255\138\255\
\000\000\133\255\002\255\000\000\116\255\141\255\000\000\102\255\
\000\255\231\255\231\255\037\255\037\255\037\255\037\255\059\255\
\059\255\000\000\000\000\069\255\069\255\002\255\145\255\002\255\
\000\000\132\255\000\000\154\255\069\255\000\000\069\255\002\255\
\000\000\000\000\155\255\069\255\000\000"

let yyrindex = "\000\000\
\000\000\000\000\000\000\000\000\159\000\000\000\000\000\000\000\
\000\000\159\255\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\100\255\158\255\000\000\000\000\017\255\076\255\
\008\255\005\000\184\255\121\255\000\000\000\000\000\000\000\000\
\000\000\100\255\000\000\000\000\000\000\000\000\000\000\000\000\
\164\255\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\172\255\000\000\000\000\025\000\
\024\000\015\000\029\000\198\255\212\255\226\255\247\255\142\255\
\163\255\000\000\000\000\000\000\000\000\164\255\000\000\000\000\
\000\000\040\255\000\000\000\000\000\000\000\000\000\000\173\255\
\000\000\000\000\000\000\000\000\000\000"

let yygindex = "\000\000\
\162\000\000\000\166\000\000\000\168\000\249\255\240\255\084\000\
\000\000\127\000\129\000\046\000\233\000\048\000\239\255\000\000\
\209\255"

let yytablesize = 311
let yytable = "\040\000\
\043\000\044\000\045\000\016\000\046\000\058\000\059\000\001\000\
\027\000\041\000\027\000\016\000\076\000\009\000\018\000\019\000\
\020\000\021\000\003\000\021\000\053\000\006\000\018\000\019\000\
\020\000\027\000\027\000\012\000\026\000\027\000\071\000\072\000\
\073\000\027\000\077\000\079\000\026\000\027\000\010\000\013\000\
\013\000\013\000\021\000\013\000\013\000\051\000\100\000\014\000\
\090\000\091\000\064\000\065\000\013\000\013\000\013\000\052\000\
\107\000\010\000\095\000\013\000\013\000\047\000\013\000\013\000\
\013\000\048\000\013\000\013\000\049\000\015\000\016\000\055\000\
\017\000\016\000\066\000\067\000\025\000\073\000\025\000\077\000\
\050\000\018\000\019\000\020\000\018\000\019\000\020\000\073\000\
\021\000\022\000\054\000\023\000\024\000\025\000\025\000\026\000\
\027\000\056\000\026\000\042\000\048\000\025\000\048\000\082\000\
\083\000\048\000\048\000\048\000\048\000\048\000\048\000\088\000\
\089\000\048\000\048\000\048\000\048\000\048\000\048\000\057\000\
\068\000\037\000\070\000\037\000\069\000\048\000\037\000\037\000\
\037\000\037\000\037\000\037\000\051\000\094\000\037\000\037\000\
\075\000\092\000\037\000\037\000\093\000\096\000\038\000\097\000\
\038\000\101\000\037\000\038\000\038\000\038\000\038\000\038\000\
\038\000\103\000\104\000\038\000\038\000\108\000\001\000\038\000\
\038\000\006\000\017\000\039\000\019\000\039\000\008\000\038\000\
\039\000\039\000\039\000\039\000\039\000\039\000\023\000\019\000\
\039\000\039\000\039\000\102\000\039\000\039\000\080\000\000\000\
\032\000\081\000\032\000\000\000\039\000\032\000\032\000\032\000\
\032\000\032\000\032\000\000\000\000\000\000\000\035\000\000\000\
\035\000\032\000\032\000\035\000\035\000\035\000\035\000\035\000\
\035\000\032\000\000\000\000\000\036\000\000\000\036\000\035\000\
\035\000\036\000\036\000\036\000\036\000\036\000\036\000\035\000\
\000\000\000\000\033\000\000\000\033\000\036\000\036\000\033\000\
\033\000\033\000\033\000\033\000\033\000\036\000\060\000\061\000\
\062\000\063\000\000\000\033\000\033\000\000\000\000\000\034\000\
\000\000\034\000\000\000\033\000\034\000\034\000\034\000\034\000\
\034\000\034\000\000\000\098\000\099\000\029\000\000\000\029\000\
\034\000\034\000\029\000\029\000\105\000\000\000\106\000\030\000\
\034\000\030\000\000\000\109\000\030\000\030\000\029\000\029\000\
\028\000\026\000\028\000\026\000\000\000\031\000\029\000\031\000\
\030\000\030\000\031\000\031\000\084\000\085\000\086\000\087\000\
\030\000\028\000\028\000\026\000\000\000\000\000\031\000\031\000\
\000\000\028\000\026\000\000\000\000\000\000\000\031\000"

let yycheck = "\016\000\
\018\000\019\000\020\000\002\001\021\000\006\001\007\001\001\000\
\001\001\017\000\003\001\002\001\003\001\003\001\013\001\014\001\
\015\001\001\001\028\001\003\001\028\000\002\001\013\001\014\001\
\015\001\018\001\019\001\004\001\027\001\028\001\047\000\048\000\
\049\000\026\001\051\000\052\000\027\001\028\001\028\001\026\001\
\001\001\002\001\026\001\004\001\005\001\002\001\094\000\003\001\
\066\000\067\000\014\001\015\001\013\001\014\001\015\001\012\001\
\104\000\028\001\075\000\020\001\021\001\002\001\023\001\024\001\
\025\001\002\001\027\001\028\001\002\001\001\001\002\001\001\001\
\004\001\002\001\016\001\017\001\001\001\094\000\003\001\096\000\
\028\001\013\001\014\001\015\001\013\001\014\001\015\001\104\000\
\020\001\021\001\005\001\023\001\024\001\025\001\019\001\027\001\
\028\001\019\001\027\001\028\001\001\001\026\001\003\001\058\000\
\059\000\006\001\007\001\008\001\009\001\010\001\011\001\064\000\
\065\000\014\001\015\001\016\001\017\001\018\001\019\001\018\001\
\003\001\001\001\001\001\003\001\005\001\026\001\006\001\007\001\
\008\001\009\001\010\001\011\001\002\001\001\001\014\001\015\001\
\012\001\003\001\018\001\019\001\003\001\026\001\001\001\003\001\
\003\001\001\001\026\001\006\001\007\001\008\001\009\001\010\001\
\011\001\022\001\001\001\014\001\015\001\003\001\000\000\018\001\
\019\001\003\001\005\001\001\001\001\001\003\001\005\000\026\001\
\006\001\007\001\008\001\009\001\010\001\011\001\003\001\003\001\
\014\001\015\001\013\000\096\000\018\001\019\001\056\000\255\255\
\001\001\057\000\003\001\255\255\026\001\006\001\007\001\008\001\
\009\001\010\001\011\001\255\255\255\255\255\255\001\001\255\255\
\003\001\018\001\019\001\006\001\007\001\008\001\009\001\010\001\
\011\001\026\001\255\255\255\255\001\001\255\255\003\001\018\001\
\019\001\006\001\007\001\008\001\009\001\010\001\011\001\026\001\
\255\255\255\255\001\001\255\255\003\001\018\001\019\001\006\001\
\007\001\008\001\009\001\010\001\011\001\026\001\008\001\009\001\
\010\001\011\001\255\255\018\001\019\001\255\255\255\255\001\001\
\255\255\003\001\255\255\026\001\006\001\007\001\008\001\009\001\
\010\001\011\001\255\255\092\000\093\000\001\001\255\255\003\001\
\018\001\019\001\006\001\007\001\101\000\255\255\103\000\001\001\
\026\001\003\001\255\255\108\000\006\001\007\001\018\001\019\001\
\001\001\001\001\003\001\003\001\255\255\001\001\026\001\003\001\
\018\001\019\001\006\001\007\001\060\000\061\000\062\000\063\000\
\026\001\018\001\019\001\019\001\255\255\255\255\018\001\019\001\
\255\255\026\001\026\001\255\255\255\255\255\255\026\001"

let yynames_const = "\
  SEMI\000\
  LPAREN\000\
  RPAREN\000\
  LBRACE\000\
  RBRACE\000\
  EQEQ\000\
  NEQ\000\
  LTE\000\
  GTE\000\
  LT\000\
  GT\000\
  EQ\000\
  BANG\000\
  PLUS\000\
  MINUS\000\
  TIMES\000\
  DIV\000\
  AND\000\
  OR\000\
  RETURN\000\
  IF\000\
  ELSE\000\
  WHILE\000\
  FOR\000\
  LET\000\
  COMMA\000\
  EOF\000\
  "

let yynames_block = "\
  INT\000\
  ID\000\
  "

let yyact = [|
  (fun _ -> failwith "parser")
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : Ast.func) in
    Obj.repr(
# 52 "parse.mly"
       ( [_1] )
# 282 "parse.ml"
               : Ast.program))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : Ast.func) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : Ast.program) in
    Obj.repr(
# 53 "parse.mly"
               ( _1::_2 )
# 290 "parse.ml"
               : Ast.program))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 4 : string) in
    let _2 = (Parsing.peek_val __caml_parser_env 3 : Ast.var list) in
    let _4 = (Parsing.peek_val __caml_parser_env 1 : Ast.stmt) in
    Obj.repr(
# 56 "parse.mly"
                                    ( Fn{name=_1;args=_2;body=_4;pos=rhs 1} )
# 299 "parse.ml"
               : Ast.func))
; (fun __caml_parser_env ->
    Obj.repr(
# 59 "parse.mly"
                ( [] )
# 305 "parse.ml"
               : Ast.var list))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : Ast.var list) in
    Obj.repr(
# 60 "parse.mly"
                       ( _2 )
# 312 "parse.ml"
               : Ast.var list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 63 "parse.mly"
     ( [_1] )
# 319 "parse.ml"
               : Ast.var list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : string) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : Ast.var list) in
    Obj.repr(
# 64 "parse.mly"
                  ( _1::_3 )
# 327 "parse.ml"
               : Ast.var list))
; (fun __caml_parser_env ->
    Obj.repr(
# 67 "parse.mly"
       ( (skip, rhs 1) )
# 333 "parse.ml"
               : Ast.stmt))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : Ast.exp) in
    Obj.repr(
# 68 "parse.mly"
            ( (Exp _1, rhs 1) )
# 340 "parse.ml"
               : Ast.stmt))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : Ast.exp) in
    Obj.repr(
# 69 "parse.mly"
                   ( (Return _2, rhs 1) )
# 347 "parse.ml"
               : Ast.stmt))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : Ast.stmt) in
    Obj.repr(
# 70 "parse.mly"
                         ( _2 )
# 354 "parse.ml"
               : Ast.stmt))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 4 : Ast.exp) in
    let _5 = (Parsing.peek_val __caml_parser_env 2 : Ast.stmt) in
    let _7 = (Parsing.peek_val __caml_parser_env 0 : Ast.stmt) in
    Obj.repr(
# 71 "parse.mly"
                                       ( (If(_3,_5,_7), rhs 1) )
# 363 "parse.ml"
               : Ast.stmt))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 2 : Ast.exp) in
    let _5 = (Parsing.peek_val __caml_parser_env 0 : Ast.stmt) in
    Obj.repr(
# 72 "parse.mly"
                                                   ( (If(_3,_5,(skip, rhs 5)), rhs 1) )
# 371 "parse.ml"
               : Ast.stmt))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 2 : Ast.exp) in
    let _5 = (Parsing.peek_val __caml_parser_env 0 : Ast.stmt) in
    Obj.repr(
# 73 "parse.mly"
                                ( (While(_3,_5), rhs 1) )
# 379 "parse.ml"
               : Ast.stmt))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 6 : Ast.exp option) in
    let _5 = (Parsing.peek_val __caml_parser_env 4 : Ast.exp option) in
    let _7 = (Parsing.peek_val __caml_parser_env 2 : Ast.exp option) in
    let _9 = (Parsing.peek_val __caml_parser_env 0 : Ast.stmt) in
    Obj.repr(
# 74 "parse.mly"
                                                        (
      let e1 = match _3 with None -> (Int(0), rhs 3) | Some e -> e in
      let e2 = match _5 with None -> (Int(1), rhs 5) | Some e -> e in
      let e3 = match _7 with None -> (Int(0), rhs 7) | Some e -> e in
      (For(e1,e2,e3,_9), rhs 1)
    )
# 394 "parse.ml"
               : Ast.stmt))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 4 : string) in
    let _4 = (Parsing.peek_val __caml_parser_env 2 : Ast.exp) in
    let _6 = (Parsing.peek_val __caml_parser_env 0 : Ast.stmt) in
    Obj.repr(
# 80 "parse.mly"
                           ( (Let(_2,_4,_6), rhs 1) )
# 403 "parse.ml"
               : Ast.stmt))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : Ast.stmt) in
    Obj.repr(
# 83 "parse.mly"
       ( _1 )
# 410 "parse.ml"
               : Ast.stmt))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : Ast.stmt) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : Ast.stmt) in
    Obj.repr(
# 84 "parse.mly"
                ( (Seq(_1,_2), rhs 1) )
# 418 "parse.ml"
               : Ast.stmt))
; (fun __caml_parser_env ->
    Obj.repr(
# 87 "parse.mly"
  ( None )
# 424 "parse.ml"
               : Ast.exp option))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : Ast.exp) in
    Obj.repr(
# 88 "parse.mly"
         ( Some _1 )
# 431 "parse.ml"
               : Ast.exp option))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : Ast.exp) in
    Obj.repr(
# 91 "parse.mly"
        ( _1 )
# 438 "parse.ml"
               : Ast.exp))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : string) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : Ast.exp) in
    Obj.repr(
# 92 "parse.mly"
             ( (Assign(_1,_3), rhs 1) )
# 446 "parse.ml"
               : Ast.exp))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : Ast.exp) in
    Obj.repr(
# 95 "parse.mly"
       ( [_1] )
# 453 "parse.ml"
               : Ast.exp list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : Ast.exp) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : Ast.exp list) in
    Obj.repr(
# 96 "parse.mly"
                     ( _1::_3 )
# 461 "parse.ml"
               : Ast.exp list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : Ast.exp) in
    Obj.repr(
# 99 "parse.mly"
         ( _1 )
# 468 "parse.ml"
               : Ast.exp))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : Ast.exp) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : Ast.exp) in
    Obj.repr(
# 100 "parse.mly"
                  ( (Or(_1,_3), rhs 1) )
# 476 "parse.ml"
               : Ast.exp))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : Ast.exp) in
    Obj.repr(
# 103 "parse.mly"
           ( _1 )
# 483 "parse.ml"
               : Ast.exp))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : Ast.exp) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : Ast.exp) in
    Obj.repr(
# 104 "parse.mly"
                      ( (And(_1,_3), rhs 1) )
# 491 "parse.ml"
               : Ast.exp))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : Ast.exp) in
    Obj.repr(
# 107 "parse.mly"
          ( _1 )
# 498 "parse.ml"
               : Ast.exp))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : Ast.exp) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : Ast.exp) in
    Obj.repr(
# 108 "parse.mly"
                        ( (Binop(_1,Eq,_3), rhs 1) )
# 506 "parse.ml"
               : Ast.exp))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : Ast.exp) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : Ast.exp) in
    Obj.repr(
# 109 "parse.mly"
                       ( (Binop(_1,Neq,_3), rhs 1) )
# 514 "parse.ml"
               : Ast.exp))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : Ast.exp) in
    Obj.repr(
# 112 "parse.mly"
         ( _1 )
# 521 "parse.ml"
               : Ast.exp))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : Ast.exp) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : Ast.exp) in
    Obj.repr(
# 113 "parse.mly"
                    ( (Binop(_1,Lt,_3), rhs 1) )
# 529 "parse.ml"
               : Ast.exp))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : Ast.exp) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : Ast.exp) in
    Obj.repr(
# 114 "parse.mly"
                    ( (Binop(_1,Gt,_3), rhs 1) )
# 537 "parse.ml"
               : Ast.exp))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : Ast.exp) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : Ast.exp) in
    Obj.repr(
# 115 "parse.mly"
                     ( (Binop(_1,Lte,_3), rhs 1) )
# 545 "parse.ml"
               : Ast.exp))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : Ast.exp) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : Ast.exp) in
    Obj.repr(
# 116 "parse.mly"
                     ( (Binop(_1,Gte,_3), rhs 1) )
# 553 "parse.ml"
               : Ast.exp))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : Ast.exp) in
    Obj.repr(
# 119 "parse.mly"
         ( _1 )
# 560 "parse.ml"
               : Ast.exp))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : Ast.exp) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : Ast.exp) in
    Obj.repr(
# 120 "parse.mly"
                     ( (Binop(_1,Plus,_3), rhs 1) )
# 568 "parse.ml"
               : Ast.exp))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : Ast.exp) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : Ast.exp) in
    Obj.repr(
# 121 "parse.mly"
                      ( (Binop(_1,Minus,_3), rhs 1) )
# 576 "parse.ml"
               : Ast.exp))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : Ast.exp) in
    Obj.repr(
# 124 "parse.mly"
           ( _1 )
# 583 "parse.ml"
               : Ast.exp))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : Ast.exp) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : Ast.exp) in
    Obj.repr(
# 125 "parse.mly"
                        ( (Binop(_1,Times,_3), rhs 1) )
# 591 "parse.ml"
               : Ast.exp))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : Ast.exp) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : Ast.exp) in
    Obj.repr(
# 126 "parse.mly"
                      ( (Binop(_1,Div,_3), rhs 1) )
# 599 "parse.ml"
               : Ast.exp))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : Ast.exp) in
    Obj.repr(
# 129 "parse.mly"
            ( _1 )
# 606 "parse.ml"
               : Ast.exp))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : Ast.exp) in
    Obj.repr(
# 130 "parse.mly"
                ( _2 )
# 613 "parse.ml"
               : Ast.exp))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : Ast.exp) in
    Obj.repr(
# 131 "parse.mly"
                 ( (Binop((Int 0,rhs 1),Minus,_2), rhs 1) )
# 620 "parse.ml"
               : Ast.exp))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : Ast.exp) in
    Obj.repr(
# 132 "parse.mly"
                ( (Not _2, rhs 1) )
# 627 "parse.ml"
               : Ast.exp))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : int) in
    Obj.repr(
# 135 "parse.mly"
      ( (Int _1, rhs 1) )
# 634 "parse.ml"
               : Ast.exp))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 136 "parse.mly"
     ( (Var _1, rhs 1) )
# 641 "parse.ml"
               : Ast.exp))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : string) in
    Obj.repr(
# 137 "parse.mly"
                   ( (Call(_1,[]), rhs 1) )
# 648 "parse.ml"
               : Ast.exp))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 3 : string) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : Ast.exp list) in
    Obj.repr(
# 138 "parse.mly"
                           ( (Call(_1,_3), rhs 1) )
# 656 "parse.ml"
               : Ast.exp))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : Ast.exp) in
    Obj.repr(
# 139 "parse.mly"
                     ( _2 )
# 663 "parse.ml"
               : Ast.exp))
(* Entry program *)
; (fun __caml_parser_env -> raise (Parsing.YYexit (Parsing.peek_val __caml_parser_env 0)))
|]
let yytables =
  { Parsing.actions=yyact;
    Parsing.transl_const=yytransl_const;
    Parsing.transl_block=yytransl_block;
    Parsing.lhs=yylhs;
    Parsing.len=yylen;
    Parsing.defred=yydefred;
    Parsing.dgoto=yydgoto;
    Parsing.sindex=yysindex;
    Parsing.rindex=yyrindex;
    Parsing.gindex=yygindex;
    Parsing.tablesize=yytablesize;
    Parsing.table=yytable;
    Parsing.check=yycheck;
    Parsing.error_function=parse_error;
    Parsing.names_const=yynames_const;
    Parsing.names_block=yynames_block }
let program (lexfun : Lexing.lexbuf -> token) (lexbuf : Lexing.lexbuf) =
   (Parsing.yyparse yytables 1 lexfun lexbuf : Ast.program)
