(* Tianen Li and Neal Wu *)

(* This file should be extended to implement the Fish parser using the 
 * parsing combinator library, and the combinator-based lexer. *)
open Lcombinators.GenericParsing
open Comblexer
open Ast

let dummy_pos : pos = 0

let binop_map = map (fun (e1, (op, e2)) -> (Binop (e1, op, e2), dummy_pos))

let make_next_parser mapping parser op = 
  let rec next_parser () =
    let op_parser = satisfy_opt op in
    let op_exp_parser = mapping (lazy_seq (lazy (parser()), lazy (seq(op_parser, next_parser())))) in
      alt (parser(), op_exp_parser)
  in next_parser ()

let make_next_binop_parser = make_next_parser binop_map

let rec make_aexp_parser () =
  let int_parser = satisfy_opt (function INT i -> Some (Int i, dummy_pos) | _ -> None) in
  let sub_parser = seq (satisfy (fun t -> t = LPAREN), 
    lazy_seq (lazy (make_exp_parser ()), lazy (satisfy (fun t -> t = RPAREN)))) in 
  let sub_exp_parser = map (fun (_, (e, _)) -> e) sub_parser in
  let var_parser = satisfy_opt (function ID v -> Some (Var v, dummy_pos) | _ -> None) in
  alts [int_parser; var_parser; sub_exp_parser]

and make_bexp_parser () = 
  let neg_parser = satisfy_opt (function MINUS -> Some Minus | _ -> None) in
  let neg_exp_parser = lazy_seq (lazy neg_parser, lazy (make_bexp_parser())) in
  let signed_exp_parser = map (fun (_, e) -> (Binop ((Int 0, dummy_pos), Minus, e), dummy_pos)) neg_exp_parser in
  let not_parser = satisfy_opt (function NOT -> Some 1 | _ -> None) in
  let not_mapping = fun (_, e) -> (Not e, dummy_pos) in
  let not_exp_parser = map (not_mapping) (lazy_seq(lazy not_parser, lazy (make_bexp_parser()))) in
  alts [make_aexp_parser(); signed_exp_parser; not_exp_parser]

and make_cexp_parser () = 
  make_next_binop_parser (make_bexp_parser) (function STAR -> Some Times | SLASH -> Some Div | _ -> None)

and make_dexp_parser () = 
  make_next_binop_parser (make_cexp_parser) (function PLUS -> Some Plus | MINUS -> Some Minus | _ -> None)

and make_eexp_parser () = 
  make_next_binop_parser (make_dexp_parser) (function
    EQ -> Some Eq | NEQ -> Some Neq | LT -> Some Lt | LTE -> Some Lte | GT -> Some Gt | GTE -> Some Gte | _ -> None)

and make_fexp_parser () =
  let and_mapping = map (fun (e1, (_, e2)) -> (And (e1, e2), dummy_pos)) in
  make_next_parser (and_mapping) (make_eexp_parser) (function AND -> Some 1 | _ -> None)

and make_gexp_parser () =
  let or_mapping = map (fun (e1, (_, e2)) -> (Or (e1, e2), dummy_pos)) in
  make_next_parser (or_mapping) (make_fexp_parser) (function OR -> Some 1 | _ -> None)

and make_exp_parser () = 
  let var_parser = satisfy_opt (function ID v -> Some v | _ -> None) in
  let eq_parser = satisfy_opt (function ASSIGN -> Some 1 | _ -> None) in
  let assign_parser = seq(var_parser, lazy_seq(lazy eq_parser, lazy (make_exp_parser()))) in
  let assign_exp_parser = map (fun (v, (_, e)) -> (Assign (v, e), dummy_pos)) assign_parser in
  alt (make_gexp_parser(), assign_exp_parser)

let token_p tk = satisfy (fun t -> t = tk)
let semi_p = token_p SEMI
let lparen_p = token_p LPAREN
let rparen_p = token_p RPAREN

let rec make_astmt_parser () = 
  let lbrace_p = token_p LBRACE in
  let rbrace_p = token_p RBRACE in
  let exp_p = lazy (make_exp_parser ()) in
  let return_parser = seq (token_p RETURN, lazy_seq (exp_p, lazy semi_p)) in
  let return_stmt_parser = map (fun (_, (e, _)) -> ((Return e), dummy_pos)) return_parser in
  let singleton_parser = lazy_seq (lazy (opt (make_exp_parser())), lazy semi_p) in
  let singleton_stmt_parser = map (fun (o, _) -> match o with
        Some e -> ((Exp e) , dummy_pos)
      | None -> (skip, dummy_pos))
    singleton_parser in
  let empty_parser = seq (lbrace_p, rbrace_p) in
  let empty_stmt_parser = map (fun _ -> (skip, dummy_pos)) empty_parser in
  let block_parser = seq (lbrace_p, lazy_seq (lazy (make_stmt_parser()), lazy rbrace_p)) in
  let block_stmt_parser = map (fun (_, (s, _)) -> s) block_parser in
  alts [return_stmt_parser; singleton_stmt_parser; block_stmt_parser; empty_stmt_parser]

and make_bstmt_parser (():unit) : (token, stmt) parser =
  let exp_p = lazy (make_exp_parser ()) in
  let bstmt_p = lazy (make_bstmt_parser ()) in
  let for_parser = seq (token_p FOR, seq (lparen_p , lazy_seq (exp_p, lazy (seq (semi_p, lazy_seq (exp_p, lazy (seq (semi_p, lazy_seq (exp_p, lazy (lazy_seq(lazy rparen_p, bstmt_p))))))))))) in
  let for_stmt_parser = map (fun (_, (_, (e1, (_, (e2, (_, (e3, (_, s)))))))) -> (For (e1, e2, e3, s), dummy_pos)) for_parser in
  let while_parser = seq (token_p WHILE, seq(lparen_p, lazy_seq(exp_p, lazy (lazy_seq(lazy rparen_p, bstmt_p))))) in
  let while_stmt_parser = map (fun (_, (_, (e, (_, s)))) -> (While (e, s), dummy_pos)) while_parser in
  let if_else_parser = seq (token_p IF, seq (lparen_p, lazy_seq (exp_p, lazy (seq (rparen_p, lazy_seq (bstmt_p, lazy(lazy_seq( lazy(token_p ELSE), bstmt_p)))))))) in
  let if_else_stmt_parser = map (fun (_, (_, (e, (_, (s1, (_, s2)))))) -> (If (e, s1, s2), dummy_pos)) if_else_parser in
  alts [make_astmt_parser(); for_stmt_parser; while_stmt_parser; if_else_stmt_parser]

and make_cstmt_parser () =
  let exp_p = lazy (make_exp_parser ()) in
  let cstmt_p = lazy (make_cstmt_parser ()) in
  let if_parser = seq (token_p IF, seq (lparen_p, lazy_seq (exp_p, lazy (lazy_seq (lazy rparen_p, cstmt_p))))) in
  let if_stmt_parser = map (fun (_, (_, (e, (_, s)))) -> (If (e, s, (skip, dummy_pos)), dummy_pos)) if_parser in
  alt (make_bstmt_parser(), if_stmt_parser) 

and make_stmt_parser () =
  let seq_parser = lazy_seq (lazy (make_cstmt_parser()), lazy(make_stmt_parser())) in
  let seq_stmt_parser = map (fun (s1, s2) -> ((Seq (s1, s2)), dummy_pos)) seq_parser in
  alt (make_cstmt_parser(), seq_stmt_parser)

let parse(ts:token list) : program = 
  let program_parser = make_stmt_parser () in
  match run (program_parser ts) with
   | Some stmt -> stmt
   | None -> failwith "parse error"
