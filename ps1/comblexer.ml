open Lcombinators.GenericParsing
open Lcombinators.CharParsing
open Explode

(* the datatype for tokens -- you will need to augment these *)
type token = 
    INT of int
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

(* removes WHITESPACE and COMMENT tokens from a token list *)
let remove_whitespace (ts: token list) : token list =
  let p = fun a t -> match t with (WHITESPACE | COMMENT) -> a | _ -> t::a in
  List.rev (List.fold_left p [] ts)

(* the tokenize function -- should convert a list of characters to a list of 
 * Fish tokens using the combinators. *)
let rec tokenize(cs:char list) : token list = 
  let ws_parser = const_map WHITESPACE white in
  let comment_parser = const_map COMMENT comment in
  let int_parser = map (fun i -> INT i) integer in
  let plus_parser = const_map PLUS (c '+') in
  let minus_parser = const_map MINUS (c '-')  in
  let star_parser = const_map STAR (c '*')  in
  let slash_parser = const_map SLASH (c '/')  in
  let lparen_parser = const_map LPAREN (c '(') in
  let rparen_parser = const_map RPAREN (c ')') in
  let lbrace_parser = const_map LBRACE (c '{') in
  let rbrace_parser = const_map RBRACE (c '}') in
  let eq_parser = const_map EQ (str "==") in
  let neq_parser = const_map NEQ (str "!=") in
  let lte_parser = const_map LTE (str "<=") in
  let gte_parser = const_map GTE (str ">=") in
  let lt_parser = const_map LT (c '<') in
  let gt_parser = const_map GT (c '>') in
  let assign_parser = const_map ASSIGN (c '=') in
  let and_parser = const_map AND (str "&&") in
  let or_parser = const_map OR (str "||") in
  let not_parser = const_map NOT (c '!') in
  let if_parser = const_map IF (str "if") in
  let else_parser = const_map ELSE (str "else") in
  let for_parser = const_map FOR (str "for") in
  let while_parser = const_map WHILE (str "while") in
  let return_parser = const_map RETURN (str "return") in
  let keyword_parser = alts [if_parser; else_parser; for_parser; while_parser; return_parser] in
  let id_parser = map (fun s -> match run (keyword_parser s) with
                                | Some (tk) -> tk
                                | None -> ID (implode s)
                      )
      (cons (alpha, (star (alts [alpha; dig ; c '_'])))) in 
  let semi_parser = const_map SEMI (c ';') in
  let all_tokens = [ws_parser; comment_parser; id_parser; int_parser;
    plus_parser; minus_parser; star_parser; slash_parser;
    lparen_parser; rparen_parser; lbrace_parser; rbrace_parser;
    eq_parser; neq_parser; lte_parser; gte_parser; lt_parser;
    gt_parser; assign_parser; and_parser; or_parser; not_parser;
    semi_parser] in
  let eof_parser = map (fun _ -> EOF) eof in
  let p = seq (star (alts all_tokens), eof_parser) in
  match run (p cs) with
   | Some (tokens, EOF) -> remove_whitespace tokens
   | _ -> failwith "lex error"
