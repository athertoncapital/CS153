open Mlish_ast

let rec print_type (t : tipe) : unit =
    match t with
    | Tvar_t t1 -> Printf.printf "%s" t1
    | Int_t -> Printf.printf "Int"
    | Bool_t -> Printf.printf "Bool"
    | Unit_t -> Printf.printf "Unit"
    | Fn_t (t1, t2) -> Printf.printf "Function from ("; print_type t1; Printf.printf ") to ("; print_type t2; Printf.printf ")"
    | Pair_t (t1, t2) -> Printf.printf "Pair of ("; print_type t1; Printf.printf ") and ("; print_type t2; Printf.printf ")"
    | List_t t1 -> Printf.printf "List of ("; print_type t1; Printf.printf ")"
    | Guess_t t1 -> match !t1 with
                    | Some t -> Printf.printf "Guess of ("; print_type t; Printf.printf ")"
                    | None -> Printf.printf "None"

(* This magic is used to glue the generated lexer and parser together.
 * Expect one command-line argument, a file to parse.
 * You do not need to understand this interaction with the system. *)
let parse_file () =
  let argv = Sys.argv in
  let _ = 
    if Array.length argv != 2
    then (prerr_string ("usage: " ^ argv.(0) ^ " [file-to-parse]\n");
    exit 1) in
  let ch = open_in argv.(1) in
  Ml_parse.program Ml_lex.lexer (Lexing.from_channel ch)

let compile_prog prog = 
  let _ = Mlish_type_check.type_check_exp prog in
  Mlish_compile.compile_exp prog

let run_prog prog = Scish_eval.run prog

let _ = 
  let prog = parse_file() in
  (* let _ = print_type (Mlish_type_check.type_check_exp prog); Printf.printf "\n" in *)
  let prog' = compile_prog prog in
  let ans = run_prog prog' in
  print_string ("answer = "^(Scish_eval.val2string ans)^"\n")
  

(*
let dump p = print_string (Cish_ast.prog2string p)

let _ =
  let prog = parse_file() in
 let ans = run_prog prog in
(*
let _ =  print_string ("answer = "^(string_of_int ans)^"\n") in
*)
  dump (compile_prog prog)
*)
