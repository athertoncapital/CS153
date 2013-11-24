open Cfg_ast
module C = Cish_ast
exception Implement_Me
exception FatalError

(*******************************************************************)
(* PS7 TODO:  interference graph construction *)

(* an interference graph maps a variable x to the set of variables
 * y such that x and y are live at the same point in time.  It's up to
 * you how you want to represent the graph.  I've just put in a dummy
 * definition for now.  *)

module VarSet = Set.Make(struct 
    type t = var
    let compare = compare 
  end)

module LabelSet = Set.Make(struct 
    type t = label
    let compare = compare 
  end)

module LabelMap = Map.Make(struct
    type t = label
    let compare = compare
  end)

module VarMap = Map.Make(struct
    type t = var
    let compare = compare
  end)

type interfere_graph = VarSet.t VarMap.t

let vars_of_ops (ops: operand list) : VarSet.t =
  let add_op vset op =
    match op with
    | Var x -> VarSet.add x vset
    | _ -> vset
  in List.fold_left add_op VarSet.empty ops

let gens (i: inst) : VarSet.t =
  match i with
  | Move (_, Var y) -> VarSet.singleton y
  | Arith (_, op1, _, op2) -> vars_of_ops [op1; op2]
  | Load (_, Var y, _) -> VarSet.singleton y
  | Store (op1, _, op2) -> vars_of_ops [op1; op2]
  | If (op1, _, op2, _, _) -> vars_of_ops [op1; op2]
  | _ -> VarSet.empty

let kills (i: inst) : VarSet.t =
  match i with
  | Move (Var x, _) -> VarSet.singleton x
  | Arith (Var x, _, _, _) -> VarSet.singleton x
  | Load (Var x , _, _) -> VarSet.singleton x
  | _ -> VarSet.empty

let rec block_gens (b: block) : VarSet.t =
  match b with
  | s::b -> VarSet.union (VarSet.diff (block_gens b) (kills s)) (gens s)
  | _ -> VarSet.empty

let rec block_kills (b: block) : VarSet.t =
  match b with
  | s::b -> VarSet.union (kills s) (block_kills b)
  | _ -> VarSet.empty

let get_succ_from_inst (i: inst) : label list =
  match i with
  | Call (Lab lbl) -> [lbl]
  | Jump lbl -> [lbl]
  | If (_, _, _, l1, l2) -> if l1 = l2 then [l1] else [l1; l2]
  | _ -> []

let succ_of (b: block) : label list =
  get_succ_from_inst (List.nth b ((List.length b) - 1))

let label_of (b: block) : label =
  match b with
  | (Label lbl)::_ -> lbl
  | _ -> raise FatalError

let succs_of_func (f: func) : (label list) LabelMap.t =
  List.fold_left (fun dict bloc -> LabelMap.add (label_of bloc) (succ_of bloc) dict) LabelMap.empty f

let succ = ref LabelMap.empty
let labels = ref []
let livein = ref LabelMap.empty
let liveout = ref LabelMap.empty
let gens_dict = ref LabelMap.empty
let kills_dict = ref LabelMap.empty
let changed = ref false

let init (f: func) : unit =
  succ := succs_of_func f;
  labels := List.map label_of f;
  let temp = List.fold_left (fun dict bloc -> LabelMap.add (label_of bloc) (block_gens bloc) dict) LabelMap.empty f in
  livein := temp;
  liveout := List.fold_left (fun dict lbl -> LabelMap.add lbl VarSet.empty dict) LabelMap.empty !labels;
  gens_dict := temp;
  kills_dict := List.fold_left (fun dict bloc -> LabelMap.add (label_of bloc) (block_kills bloc) dict) LabelMap.empty f;
  changed := true

let update_liveness_for_block (lbl: label) : unit =
  changed := false;
  let succs = LabelMap.find lbl !succ in
  let old_out = LabelMap.find lbl !liveout in
  let new_out = List.fold_left (fun s lab -> VarSet.union s (LabelMap.find lab !livein)) VarSet.empty succs in
  if VarSet.equal old_out new_out then () else
  let new_in = VarSet.union (LabelMap.find lbl !gens_dict) (VarSet.diff new_out (LabelMap.find lbl !kills_dict)) in
  liveout := LabelMap.add lbl new_out !liveout;
  livein := LabelMap.add lbl new_in !livein;
  changed := true

let rec build_liveness () : unit =
  if not !changed then () else
  changed := false;
  List.iter update_liveness_for_block !labels

let add_edge (v1: var) (v2: var) (g: interfere_graph) : interfere_graph =
  if VarMap.mem v1 g then 
    let es = VarMap.find v1 g in
      VarMap.add v1 (VarSet.add v2 es) g
  else 
    VarMap.add v1 (VarSet.singleton v2) g

let add_edges (v1: var) (vs: VarSet.t) (g: interfere_graph) : interfere_graph =
  if VarMap.mem v1 g then
    let es = VarMap.find v1 g in
      VarMap.add v1 (VarSet.union vs es) g
  else
    VarMap.add v1 vs g

let add_mutual_edges (source: VarSet.t) (sink: VarSet.t) (g: interfere_graph) : interfere_graph =
  let add_one_way group1 group2 g =
    VarSet.fold (fun v g -> add_edges v group2 g) group1 g
  in
  let g = add_one_way source sink g in
  let g = add_one_way sink source g in
  g

let add_block_edges (b: block) (livein: VarSet.t) (g: interfere_graph) : interfere_graph =
  let g = add_mutual_edges livein livein g in
  let rec process_stmts b livein g =
    match b with
    | i::b ->
      let genned = gens i in
      let killed = kills i in
      let genned_minus_killed = VarSet.diff genned killed in
      let livein_plus_genned = VarSet.union livein genned in
      let new_livein = VarSet.diff livein_plus_genned killed in
      if VarSet.equal new_livein livein 
        then process_stmts b livein g
      else
        process_stmts b new_livein (add_mutual_edges genned_minus_killed new_livein g)
    | [] -> g
  in 
  process_stmts b livein g

(* given a function (i.e., list of basic blocks), construct the
 * interference graph for that function.  This will require that
 * you build a dataflow analysis for calculating what set of variables
 * are live-in and live-out for each program point. *)
let build_interfere_graph (f: func) : interfere_graph =
  let _ = init f in
  let _ = build_liveness() in
  let _ = Printf.printf "graph built\n" in
  List.fold_left (fun g bloc -> add_block_edges bloc (LabelMap.find (label_of bloc) !livein) g) VarMap.empty f

(* given an interference graph, generate a string representing it *)
let str_of_interfere_graph (g: interfere_graph) : string =
  let str_of_edges (v: var) (vs: VarSet.t) : string =
    VarSet.fold (fun v2 s -> if v < v2 then s ^ "  " ^ v ^ " -- " ^ v2 ^ ";\n" else s) vs ""
  in
  let header = VarMap.fold (fun v vs s -> s ^ (str_of_edges v vs)) g "graph g {\n" in
  header ^ "}"

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
let reg_alloc (f: func) : func = 
    raise Implement_Me

(* Finally, translate the ouptut of reg_alloc to Mips instructions *)
let cfg_to_mips (f: func) : Mips.inst list = 
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

let print_interference_graph () (f: C.func) : unit =
  let bs = fn2blocks f in
  let _ = Printf.printf "%s\n" (fun2string bs) in
  let graph = build_interfere_graph bs in
  Printf.printf "%s\n%s\n\n" (C.fn2string f) (str_of_interfere_graph graph)

let _ =
  let prog = parse_file() in
  List.fold_left print_interference_graph () prog
