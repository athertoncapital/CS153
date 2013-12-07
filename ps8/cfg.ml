(* Neal Wu, Tianen Li *)

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

let r2 = Reg(Mips.R2)
let r4 = Reg(Mips.R4)
let r5 = Reg(Mips.R5)
let r6 = Reg(Mips.R6)
let r7 = Reg(Mips.R7)

module VarSet = Set.Make(struct 
    type t = var
    let compare = compare 
  end)

module EdgeSet = Set.Make(struct 
    type t = var * var
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

module InterfereGraph = 
  struct
    type t = {mutable adjacency_list: VarSet.t VarMap.t; 
              mutable adjacency_set: EdgeSet.t; 
              precolored: VarSet.t; 
              mutable select_stack: var list;
              mutable coalescedNodes: VarSet.t;
              mutable aliases: var VarMap.t }

    let init (precolored: VarSet.t) : t = 
      {adjacency_list = VarMap.empty;
       adjacency_set = EdgeSet.empty;
       precolored = precolored;
       select_stack = [];
       coalescedNodes = VarSet.empty;
       aliases = VarMap.empty; }

    let add_edge (u:var) (v:var) (graph: t) : t = 
      if u != v then 
        (graph.adjacency_set <- EdgeSet.add (v, u) (EdgeSet.add (u, v) graph.adjacency_set); 
        (if not (VarSet.mem u graph.precolored) then
          if VarMap.mem u graph.adjacency_list then 
            let es = VarMap.find u graph.adjacency_list in
              graph.adjacency_list <- VarMap.add u (VarSet.add v es) graph.adjacency_list
          else 
            graph.adjacency_list <- VarMap.add u (VarSet.singleton v) graph.adjacency_list);
        (if not (VarSet.mem v graph.precolored) then
          if VarMap.mem v graph.adjacency_list then 
            let es = VarMap.find v graph.adjacency_list in
              graph.adjacency_list <- VarMap.add v (VarSet.add u es) graph.adjacency_list
          else 
            graph.adjacency_list <- VarMap.add v (VarSet.singleton u) graph.adjacency_list);
        graph)
      else graph

    let add_edges (us: VarSet.t) (vs: VarSet.t) (graph: t) : t =
      let add_edges_from_var_to_set (vs: VarSet.t) (u: var) (graph: t) : t =
        VarSet.fold (add_edge u) vs graph in
      VarSet.fold (add_edges_from_var_to_set vs) us graph

    let adjacent (u: var) (graph: t) : VarSet.t =
      if VarMap.mem u graph.adjacency_list then
        let neighbors = VarMap.find u graph.adjacency_list in
        let neighbors_minus_select_stack = List.fold_left (fun n v -> VarSet.remove v n) neighbors graph.select_stack in
        VarSet.diff neighbors_minus_select_stack graph.coalescedNodes
      else
        VarSet.empty

    let get_alias (u: var) (graph: t) : var =
      if VarMap.mem u graph.aliases then VarMap.find u graph.aliases else u

    let coalesce_nodes (u: var) (v: var) (graph: t) : t = 
      graph.coalescedNodes <- VarSet.add v graph.coalescedNodes;
      graph.aliases <- VarMap.add v u graph.aliases;
      graph
  end


type interfere_graph = VarSet.t VarMap.t

let print_set s = 
  VarSet.iter (Printf.printf "%s ") s; print_string "\n"

let vars_of_ops (ops: operand list) : VarSet.t =
  let add_op vset op =
    match op with
    | Var x -> VarSet.add x vset
    | Lab l -> VarSet.add l vset
    | Reg r -> VarSet.add (Mips.reg2string r) vset
    | _ -> vset
  in List.fold_left add_op VarSet.empty ops

let gens (i: inst) : VarSet.t =
  match i with
  | Move (_, op) -> vars_of_ops [op]
  | Arith (_, op1, _, op2) -> vars_of_ops [op1; op2]
  | Load (_, op, _) -> vars_of_ops [op]
  | Store (op1, _, op2) -> vars_of_ops [op1; op2]
  | If (op1, _, op2, _, _) -> vars_of_ops [op1; op2]
  | Return -> vars_of_ops [r2]
  | Call _ ->  vars_of_ops [r4; r5; r6; r7]
  | _ -> VarSet.empty

let kills (i: inst) : VarSet.t =
  match i with
  | Move (op, _) -> vars_of_ops [op]
  | Arith (op, _, _, _) -> vars_of_ops [op]
  | Load (op , _, _) -> vars_of_ops [op]
  | Return -> vars_of_ops [r4; r5; r6; r7]
  | Call _ -> vars_of_ops [r2]
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

let add_block_edges (b: block) (liveout: VarSet.t) (g: interfere_graph) : interfere_graph =
  let rec process_stmts b liveout g =
    match b with
    | i::b ->
      let (g, liveout) = process_stmts b liveout g in
      let genned = gens i in
      let killed = kills i in
      let out_minus_killed = VarSet.diff liveout killed in
      let livein = VarSet.union genned out_minus_killed in    
      if VarSet.equal liveout livein 
        then (g, livein)
      else
        (add_mutual_edges genned livein g, livein)
    | [] -> (add_mutual_edges liveout liveout g, liveout)
  in 
  fst (process_stmts b liveout g)

(* given a function (i.e., list of basic blocks), construct the
 * interference graph for that function.  This will require that
 * you build a dataflow analysis for calculating what set of variables
 * are live-in and live-out for each program point. *)
let build_interfere_graph (f: func) : interfere_graph =
  let _ = init f in
  let _ = build_liveness() in
  List.fold_left (fun g bloc -> add_block_edges bloc (LabelMap.find (label_of bloc) !liveout) g) VarMap.empty f

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
