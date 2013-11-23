open Cfg_ast
module C = Cish_ast
exception Implement_Me
exception FatalError

(*******************************************************************)
(* PS7 TODO:  interference graph construction *)

(* an interference graph maps a variable x to the set of variables that
 * y such that x and y are live at the same point in time.  It's up to
 * you how you want to represent the graph.  I've just put in a dummy
 * definition for now.  *)

module VarSet = Set.Make(struct 
    type t = var
    let compare = compare 
  end)

type interfere_graph = unit

(* given a function (i.e., list of basic blocks), construct the
 * interference graph for that function.  This will require that
 * you build a dataflow analysis for calculating what set of variables
 * are live-in and live-out for each program point. *)
let build_interfere_graph (f : func) : interfere_graph =
    raise Implement_Me

(* given an interference graph, generate a string representing it *)
let str_of_interfere_graph (g : interfere_graph) : string =
    raise Implement_Me

let vars_of_ops (ops: operand list) : VarSet.t =
  let helper a b =
    match b with
    | Var v -> VarSet.add v a
    | _ -> a
  in List.fold_left helper VarSet.empty ops

let gens (i: inst) : VarSet.t =
  match i with
  | Move (_, Var v) -> VarSet.singleton v
  | Arith (_, op1, _, op2) -> vars_of_ops [op1; op2]
  | Load (_, Var v, _) -> VarSet.singleton v
  | Store (_, _, Var v) -> VarSet.singleton v
  | _ -> VarSet.empty

let kills (i: inst) : VarSet.t =
  match i with
  | Move (Var v, _) -> VarSet.singleton v
  | Arith (Var v, _, _, _) -> VarSet.singleton v
  | Load (Var v , _, _) -> VarSet.singleton v
  | _ -> VarSet.empty

let rec block_gens (b: block) : VarSet.t =
  match b with
  | [If (op1, _, op2, _, _)] -> vars_of_ops [op1; op2]
  | s::b -> VarSet.union (VarSet.diff (block_gens b) (kills s)) (gens s)
  | _ -> VarSet.empty

let rec block_kills (b: block) : VarSet.t =
  match b with
  | s::b -> VarSet.union (kills s) (block_kills b)
  | _ -> VarSet.empty

(*******************************************************************)
(* PS8 TODO:  graph-coloring, coalescing register assignment *)
(* You will need to build a mapping from variables to MIPS registers
   using the ideas behind the graph-coloring register allocation
   heuristics described in class.  This may involve spilling some
   of the variables into memory, so be sure to adjust the prelude
   of the function so that you allocate enough space on the stack
   to store any spilled variables.  The output should be a CFG
   function that doesn't use any variables (except for function
   names.)
*)
let reg_alloc (f : func) : func = 
    raise Implement_Me

(* Finally, translate the ouptut of reg_alloc to Mips instructions *)
let cfg_to_mips (f : func ) : Mips.inst list = 
    raise Implement_Me



(*******************************************************************)
(* Command-Line Interface for printing CFG. You probably will not 
    need to modify this for PS7, but will definitely need to for 
    PS8. Feel free to add additional command-line options as you
    see fit (e.g. -printmips, -evalmips, -printcfg, etc...). 
    Please make sure to document any changes you make.
*)
let parse_file() =
  let argv = Sys.argv in
  let _ = 
    if Array.length argv != 2
    then (prerr_string ("usage: " ^ argv.(0) ^ " [file-to-parse]\n");
    exit 1) in
  let ch = open_in argv.(1) in
  Cish_parse.program Cish_lex.lexer (Lexing.from_channel ch)

let parse_stdin() = 
  Cish_parse.program Cish_lex.lexer (Lexing.from_channel stdin)

let print_interference_graph (():unit) (f : C.func) : unit =
  let graph = build_interfere_graph (fn2blocks f) in
  Printf.printf "%s\n%s\n\n" (C.fn2string f) (str_of_interfere_graph graph)

let _ =
  let prog = parse_file() in
  List.fold_left print_interference_graph () prog

