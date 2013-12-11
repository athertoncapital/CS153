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
let r31 = Reg(Mips.R31)

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

module IntSet = Set.Make(struct
    type t = int
    let compare = compare
  end)

let rec find f ls =
  match ls with
  | hd::tl -> if f hd then Some hd else find f tl
  | _ -> None

module InterfereGraph = 
  struct
    type t = {adjacency_set: EdgeSet.t; 
              move_set: EdgeSet.t;
              nodes : VarSet.t;
             }

    let init () : t = 
      {
        adjacency_set = EdgeSet.empty;
        move_set = EdgeSet.empty;
        nodes = VarSet.empty;
      }

    let edge_set_to_string (set: EdgeSet.t) : string =
      "graph g {\n" ^
      (EdgeSet.fold (fun (x, y) str -> if x < y then str ^ " " ^ x ^ " -- " ^ y ^ ";\n" else str) set "") ^
      "}\n"

    (* given an interference graph, generate a string representing it *)
    let to_string (graph: t) : string =
      "Nodes:\n" ^
      (VarSet.fold (fun node str -> str ^ node ^ " ") graph.nodes "") ^ "\n" ^
      "Adjacency set:\n" ^
      edge_set_to_string graph.adjacency_set ^
      "Move set:\n" ^
      edge_set_to_string graph.move_set

    let verify_bidirectionality (graph: t) : bool =
      EdgeSet.for_all (fun (u, v) -> EdgeSet.mem (v, u) graph.adjacency_set) graph.adjacency_set &&
      EdgeSet.for_all (fun (u, v) -> EdgeSet.mem (v, u) graph.move_set) graph.move_set

    let add_nodes (ns: VarSet.t) (graph: t) : t = 
      {graph with nodes = VarSet.union ns graph.nodes}

    let add_edge (u: var) (v: var) (graph: t) : t =
      if u = v then graph else
        let new_adjacency_set = EdgeSet.add (v, u) (EdgeSet.add (u, v) graph.adjacency_set) in
        let new_nodes = VarSet.add v (VarSet.add u graph.nodes) in
          {graph with adjacency_set = new_adjacency_set; nodes = new_nodes}

    let add_move (u: var) (v: var) (graph: t) : t =
      if u = v then graph else
        let new_move_set = EdgeSet.add (v, u) (EdgeSet.add (u, v) graph.move_set) in
        let new_nodes = VarSet.add v (VarSet.add u graph.nodes) in
          {graph with move_set = new_move_set; nodes = new_nodes}

    let add_edges (v1: var) (vs: VarSet.t) (graph: t) : t =
      VarSet.fold (fun v new_graph -> add_edge v1 v new_graph) vs graph

    let add_mutual_edges (source: VarSet.t) (sink: VarSet.t) (graph: t) : t =
      let add_one_way group1 group2 graph =
        VarSet.fold (fun v g -> add_edges v group2 g) group1 graph
      in
      let graph = add_one_way source sink graph in
      let graph = add_one_way sink source graph in
      graph

    let neighbors (u: var) (graph: t) : VarSet.t =
      EdgeSet.fold (fun edge set -> if fst edge = u then VarSet.add (snd edge) set else set) graph.adjacency_set VarSet.empty

    let degree (u: var) (graph: t) : int =
      VarSet.cardinal (neighbors u graph)

    let is_edge (u: var) (v: var) (graph: t) : bool =
      EdgeSet.mem (u, v) graph.adjacency_set

    let is_move (u: var) (v: var) (graph: t) : bool = 
      EdgeSet.mem (u, v) graph.move_set

    let combine (u: var) (v: var) (graph: t) : t =
      let combine_helper (edges: EdgeSet.t) : EdgeSet.t = 
        let new_edges = EdgeSet.remove (v, u) (EdgeSet.remove (u, v) edges) in
        let (change, save) = EdgeSet.partition (function (x, y) -> x = v || y = v) new_edges in
        EdgeSet.fold (fun edge set -> if (fst edge) = v then EdgeSet.add (u, (snd edge)) set else EdgeSet.add((fst edge), u) set) change save
      in

      {adjacency_set = combine_helper graph.adjacency_set;
       move_set = combine_helper graph.move_set;
       nodes = VarSet.remove v graph.nodes}

    let remove (u: var) (graph: t) : t =
      let remove_helper (edges: EdgeSet.t) : EdgeSet.t =
        EdgeSet.filter (function (x, y) -> x != u && y != u) edges
      in

      {adjacency_set = remove_helper graph.adjacency_set;
       move_set = remove_helper graph.move_set;
       nodes = VarSet.remove u graph.nodes}

    let freeze (u: var) (graph: t) : t =
      let remove_helper (edges: EdgeSet.t) : EdgeSet.t =
        EdgeSet.filter (function (x, y) -> x != u && y != u) edges
      in
      {graph with move_set = remove_helper graph.move_set;}

    let move_related (u: var) (graph: t) : bool =
      EdgeSet.exists (function (x, y) -> x = u || y = u) graph.move_set

    let is_precolored (graph: t) (u: var): bool =
      false

    let can_simplify (k: int) (graph: t) (u: var) : bool =
      not (move_related u graph) && degree u graph < k && not (is_precolored graph u)

    let get_simplify (k: int) (graph: t) : var option =
      find (can_simplify k graph) (VarSet.elements graph.nodes)

    let georges (k: int) (graph: t) (edge: var * var) : bool =
      let (x, y) = edge in
      if is_precolored graph x && is_precolored graph y then false else
      let ts = neighbors x graph in
      not (VarSet.exists (fun t -> not (is_edge y t graph || degree t graph < k)) ts)

    let get_coalesce (k: int) (graph: t) : (var * var) option =
      let o = find (georges k graph) (EdgeSet.elements (EdgeSet.diff graph.move_set graph.adjacency_set)) in
      match o with
      | Some (x, y) -> if is_precolored graph y then Some (y, x) else Some (x, y)
      | None -> None

    let can_freeze (k: int) (graph: t) (u: var) : bool =
      move_related u graph && degree u graph < k

    let get_freeze (k: int) (graph: t) : var option =
      find (can_freeze k graph) (VarSet.elements graph.nodes)

    let can_spill (k: int) (graph: t) (u: var) : bool =
      if degree u graph < k then
        (Printf.printf "Error in can_spill\n"; raise FatalError)
      else
        is_precolored graph u

    let get_spill (k: int) (graph: t) : var option =
      let o = find (can_spill k graph) (VarSet.elements (VarSet.filter (fun v -> v.[0] != '?') graph.nodes)) in
      if o = None then
        let o = find (can_spill k graph) (VarSet.elements graph.nodes) in 
          match o with
          | None -> o
          | _ ->
              let _ = Printf.printf "%s\n" "Warning: potentially spilling a temporary variable generated from a spill" in o
      else o

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
  | Return -> vars_of_ops [r2; r31]
  | Call _ ->  vars_of_ops [r4; r5; r6; r7]
  | _ -> VarSet.empty

let kills (i: inst) : VarSet.t =
  match i with
  | Move (op, _) -> vars_of_ops [op]
  | Arith (op, _, _, _) -> vars_of_ops [op]
  | Load (op , _, _) -> vars_of_ops [op]
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
  | _ -> Printf.printf "Error in label_of\n"; raise FatalError

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

let add_block_edges (b: block) (liveout: VarSet.t) (g: InterfereGraph.t) : InterfereGraph.t =
  let rec process_stmts b liveout g =
    match b with
    | i::b ->
      let (g, liveout) = process_stmts b liveout g in
      let genned = gens i in
      let killed = kills i in
      let g = (match i with
        | Move (x, y) -> InterfereGraph.add_move (op2string x) (op2string y) g
        | _ -> g) in
      let out_minus_killed = VarSet.diff liveout killed in
      let livein = VarSet.union genned out_minus_killed in
      if VarSet.equal liveout livein
        then (g, livein)
      else
        (InterfereGraph.add_mutual_edges genned livein g, livein)
    | [] -> (InterfereGraph.add_mutual_edges liveout liveout g, liveout)
  in
  fst (process_stmts b liveout g)

(* given a function (i.e., list of basic blocks), construct the
 * interference graph for that function.  This will require that
 * you build a dataflow analysis for calculating what set of variables
 * are live-in and live-out for each program point. *)
let build_interfere_graph (f: func) : InterfereGraph.t =
  let _ = init f in
  let _ = build_liveness() in
  List.fold_left (fun g bloc -> add_block_edges bloc (LabelMap.find (label_of bloc) !liveout) g) (InterfereGraph.init ()) f

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

let gen_selected_and_aliases (k: int) (graph: InterfereGraph.t): (var list * var VarMap.t) =
  let rec helper (select_stack: var list) (aliases: var VarMap.t) (graph: InterfereGraph.t): (var list * var VarMap.t) =
    let o = InterfereGraph.get_simplify k graph in
    match o with
    | Some v -> Printf.printf "simplifying %s\n" v; helper (v::select_stack) aliases (InterfereGraph.remove v graph)
    | None ->
        let o = InterfereGraph.get_coalesce k graph in
        match o with
        | Some (x, y) -> Printf.printf "coalescing %s into %s\n" y x; helper (y::select_stack) (VarMap.add y x aliases) (InterfereGraph.combine x y graph)
        | None ->
            let o = InterfereGraph.get_freeze k graph in
            match o with
            | Some v -> Printf.printf "freezing %s \n" v; helper select_stack aliases (InterfereGraph.freeze v graph)
            | None -> 
                let o = InterfereGraph.get_spill k graph in
                match o with
                | Some v -> Printf.printf "%s\n" ("potential spill: " ^ v);
                    helper (v::select_stack) aliases(InterfereGraph.remove v graph)
                | None -> (select_stack, aliases)
  in helper [] VarMap.empty graph

let attempt_color (k: int) (graph: InterfereGraph.t) : int VarMap.t * var list =
  let rec range x y = 
    if x >= y then IntSet.empty else IntSet.add x (range (x + 1) y) 
  in
  let all_colors = range 0 k in
  let select_stack, aliases = gen_selected_and_aliases k graph in
  let select_color (c: int VarMap.t * var list) (node: var): int VarMap.t * var list =
    let (coloring, spilled) = c in
      if VarMap.mem node aliases then
        ((VarMap.add node (VarMap.find (VarMap.find node aliases) coloring) coloring), spilled)
      else
        let neighbors = InterfereGraph.neighbors node graph in
        let unavailable = VarSet.fold (fun v colors -> if VarMap.mem v coloring then IntSet.add (VarMap.find v coloring) colors else colors) neighbors IntSet.empty in
        let available = IntSet.diff all_colors unavailable in
        if IntSet.is_empty available then (coloring, node::spilled) else
          let chosen = IntSet.choose (IntSet.diff all_colors unavailable) in
            (VarMap.add node chosen coloring, spilled)
      in
      List.fold_left select_color (VarMap.empty, []) select_stack

let rewrite_program (f: func) (spilled_nodes: var list) =
  raise Implement_Me

let rec color (k: int) (f: func) : int VarMap.t =
  let graph = build_interfere_graph f in
  let coloring, spilled_nodes = attempt_color k graph in
  if spilled_nodes = [] then coloring else
    let _ = Printf.printf "%s" "Now spilling: " in
    let _ = List.iter (Printf.printf "%s ") spilled_nodes in
    let _ = Printf.printf "%s" "\n" in
    let new_f = rewrite_program f spilled_nodes in
    color k new_f

let reg_alloc (f: func) : func = 
  let coloring = color 1000 f in
  f

let op_to_mips (op: operand) : Mips.operand =
  match op with
  | Int i -> Mips.Immed (Word32.fromInt i)
  | Reg r -> Mips.Reg r
  | _ -> Printf.printf "Error in op_to_mips\n"; raise FatalError

let op_to_reg (op: operand) : Mips.reg =
  match op with
  | Reg r -> r
  | _ -> Printf.printf "Error in op_to_reg\n"; raise FatalError

let op_to_label (op: operand) : label =
  match op with
  | Lab lbl -> lbl
  | _ -> Printf.printf "Error in op_to_label\n"; raise FatalError

let rec inst_list_to_mips (insts: inst list) : Mips.inst list =
  match insts with
  | head::tail -> 
    (match head with
    | Label lbl -> [Mips.Label lbl]
    | Move (op1, op2) -> [Mips.Or (op_to_reg op1, op_to_reg op2, Mips.Immed (Word32.fromInt 0))]
    | Arith (op, a, arith, b) ->
      let reg = op_to_reg op in
      let a_reg = op_to_reg a in
      (match arith with
      | Plus -> [Mips.Add (reg, a_reg, op_to_mips b)]
      | Minus -> [Mips.Sub (reg, a_reg, op_to_reg b)]
      | Times -> [Mips.Mul (reg, a_reg, op_to_reg b)]
      | Div -> [Mips.Div (reg, a_reg, op_to_reg b)]
      )
    | Load (op1, op2, i) -> [Mips.Lw (op_to_reg op1, op_to_reg op2, Word32.fromInt i)]
    | Store (op1, i, op2) -> [Mips.Sw (op_to_reg op2, op_to_reg op1, Word32.fromInt i)]
    | Call op -> [Mips.Jal (op_to_label op)]
    | Jump lbl -> [Mips.J lbl]
    | If (op1, comp, op2, lbl1, lbl2) ->
      let reg1 = op_to_reg op1 in
      let reg2 = op_to_reg op2 in
      (match comp with
      | Eq -> [Mips.Beq (reg1, reg2, lbl1); Mips.B lbl2]
      | Neq -> [Mips.Bne (reg1, reg2, lbl1); Mips.B lbl2]
      | Lt -> [Mips.Blt (reg1, reg2, lbl1); Mips.B lbl2]
      | Lte -> [Mips.Ble (reg1, reg2, lbl1); Mips.B lbl2]
      | Gt -> [Mips.Bgt (reg1, reg2, lbl1); Mips.B lbl2]
      | Gte -> [Mips.Bge (reg1, reg2, lbl1); Mips.B lbl2]
      )
    | Return -> [Mips.Jr Mips.R31]
    ) @ (inst_list_to_mips tail)
  | _ -> []

(* Finally, translate the ouptut of reg_alloc to Mips instructions *)
let cfg_to_mips (f: func) : Mips.inst list = 
  inst_list_to_mips (List.fold_left (@) [] f)

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
  Printf.printf "%s\n%s\n\n" (C.fn2string f) (InterfereGraph.to_string graph);
  let _ = reg_alloc bs in ()

let _ =
  let prog = parse_file() in
  List.fold_left print_interference_graph () prog;
  let bs = cfg_to_mips (List.fold_left (fun a b -> a @ (fn2blocks b)) [] prog) in
  List.iter (fun i -> Printf.printf "%s\n" (Mips.inst2string i)) bs