(* This file should be extended to implement the Fish parser using the 
 * parsing combinator library, and the combinator-based lexer. *)
open Lcombinators.GenericParsing
open Comblexer
open Ast

let dummy_pos : pos = 0

let binop_map = map (fun (e1, (op, e2)) -> (Binop (e1, op, e2), dummy_pos))

let make_next_binop_parser parser op = 
  let rec next_parser () =
    let op_parser = satisfy_opt op in
    let op_exp_parser = binop_map (lazy_seq (lazy (parser()), lazy (seq(op_parser, next_parser())))) in
      alt (parser(), op_exp_parser)
  in next_parser ()

let rec make_aexp_parser() =
  let int_parser = satisfy_opt (function INT i -> Some (Int i, dummy_pos) | _ -> None) in
  let sub_parser = seq (satisfy (fun t -> t == LPAREN), 
    lazy_seq (lazy (make_exp_parser ()), lazy (satisfy (fun t -> t == RPAREN)))) in 
  let sub_exp_parser = map (fun (_, (e, _)) -> e) sub_parser in
  alt (int_parser, sub_exp_parser)

and make_bexp_parser () = 
  make_next_binop_parser (make_aexp_parser) (function STAR -> Some Times | SLASH -> Some Div | _ -> None)

and make_cexp_parser () = 
  make_next_binop_parser (make_bexp_parser) (function PLUS -> Some Plus | MINUS -> Some Minus | _ -> None)

and make_dexp_parser () = 
  make_next_binop_parser (make_cexp_parser) (function
    EQ -> Some Eq | NEQ -> Some Neq | LT -> Some Lt | LTE -> Some Lte | GT -> Some Gt | GTE -> Some Gte | _ -> None)

and make_exp_parser () = 
  make_dexp_parser()

let rec make_stmt_parser (():unit) : (token, stmt) parser =
  let token_p tk = satisfy (fun t -> t == tk) in
  let semi_p = token_p SEMI in
  let lparen_p = token_p LPAREN in
  let rparen_p = token_p RPAREN in
  let exp_p = lazy (make_exp_parser ()) in
  let stmt_p = lazy (make_stmt_parser ()) in 
  let singleton_parser = lazy_seq (lazy (opt (make_exp_parser())), lazy semi_p) in
  let singleton_stmt_parser = map (fun (o, _) -> match o with
        Some e -> ((Exp e) , dummy_pos)
      | None -> (skip, dummy_pos))
    singleton_parser in
  let seq_parser = lazy_seq (lazy singleton_stmt_parser, stmt_p) in
  let seq_stmt_parser = map (fun (s1, s2) -> ((Seq (s1, s2)), dummy_pos)) seq_parser in
  let block_parser = seq (token_p LBRACE, lazy_seq (stmt_p, lazy (token_p RBRACE))) in
  let block_stmt_parser = map (fun (_, (s, _)) -> s) block_parser in
  let return_parser = seq (token_p RETURN, lazy_seq (exp_p, lazy semi_p)) in
  let return_stmt_parser = map (fun (_, (e, _)) -> ((Return e), dummy_pos)) return_parser in
  let for_parser = seq (token_p FOR, seq (lparen_p , lazy_seq (exp_p, lazy (seq (semi_p, lazy_seq (exp_p, lazy (seq (semi_p, lazy_seq (exp_p, lazy (lazy_seq(lazy rparen_p, stmt_p))))))))))) in
  let for_stmt_parser = map (fun (_, (_, (e1, (_, (e2, (_, (e3, (_, s)))))))) -> (For (e1, e2, e3, s), dummy_pos)) for_parser in
  let while_parser = seq (token_p WHILE, seq(lparen_p, lazy_seq(exp_p, lazy (lazy_seq(lazy rparen_p, stmt_p))))) in
  let while_stmt_parser = map (fun (_, (_, (e, (_, s)))) -> (While (e, s), dummy_pos)) while_parser in
  let if_parser = seq (token_p IF, seq (lparen_p, lazy_seq (exp_p, lazy (seq (rparen_p, lazy_seq (stmt_p, lazy(opt(lazy_seq(lazy(token_p ELSE), lazy (opt(make_stmt_parser()))))))))))) in
  let if_stmt_parser = map (fun (_, (_, (e, (_, (s1, o))))) -> match o with 
        Some (_, Some(s2)) -> (If (e, s1, s2), dummy_pos)
      | None -> (If (e, s1, (skip, dummy_pos)), dummy_pos)
      | _ -> failwith "parse error") 
    if_parser in
  let exp_stmt_parser = map (fun e -> (Exp e, dummy_pos)) (make_exp_parser ()) in
  alts [return_stmt_parser; for_stmt_parser; while_stmt_parser; if_stmt_parser; exp_stmt_parser; block_stmt_parser; seq_stmt_parser; singleton_stmt_parser]

let parse(ts:token list) : program = 
  let program_parser = make_stmt_parser () in
  match run (program_parser ts) with
   | Some stmt -> stmt
   | None -> failwith "parse error"
