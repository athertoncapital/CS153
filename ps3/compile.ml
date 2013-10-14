(* Compile Cish AST to MIPS AST *)
open Mips
open Ast

exception IMPLEMENT_ME
exception FATAL_ERROR

type result = { code : Mips.inst list;
                data : Mips.label list }

(* generate fresh labels *)
let label_counter = ref 0
let new_int() = (label_counter := (!label_counter) + 1; !label_counter)
let new_label() = "L%" ^ (string_of_int (new_int()))

module VarSet = Set.Make(struct
                           type t = var
                           let compare = String.compare
                         end)

module VarMap = Map.Make(struct
                           type t = var
                           let compare = String.compare
                         end)

let arguments : VarSet.t ref = ref (VarSet.empty)
let variables : VarSet.t ref = ref (VarSet.empty)
let var_to_offset : int VarMap.t ref = ref VarMap.empty
let fun_to_frame_size : int VarMap.t ref = ref VarMap.empty
let fun_to_local_var_size : int VarMap.t ref = ref VarMap.empty

let var_offset = ref 0

let reset_offset (c: int) : unit =
	var_offset := c

let new_minus_offset() = (var_offset := !var_offset - 4; !var_offset)

let new_offset() = (let offset = !var_offset in var_offset := offset + 4; offset)

let reset() = (reset_offset(0); arguments := VarSet.empty; variables := VarSet.empty)

(* helper function for collect_vars:
adding in vars to VarSet, if the var is already in the set, do nothing *)

let add_arg v = 
  if (VarSet.mem v !arguments) then () else (arguments := VarSet.add v !arguments)

let add_var v =
  if (VarSet.mem v !arguments or VarSet.mem v !variables) then () else (variables := VarSet.add v !variables)

let add_argument (fn: var) (v: var) : unit =
  var_to_offset := VarMap.add (fn ^ "$" ^ v) (new_offset()) !var_to_offset

let add_variable (fn: var) (v : var) : unit =
  var_to_offset := VarMap.add (fn ^ "$" ^ v) (new_minus_offset ()) !var_to_offset

let lookup_var (fn: var) (v : var) : int =
  VarMap.find (fn ^ "$" ^ v) !var_to_offset

(* copy r2 to r1 *)
let copy_register (r1 : reg) (r2 : reg) : inst =
  Add (r1, r2, Immed (Word32.fromInt 0))

let put_on_stack_int (i : int) : inst list =
  [Add (R29, R29, Immed (Word32.fromInt (-4))); Li (R8, Word32.fromInt i); Sw (R8, R29, Word32.fromInt 0)]

let put_on_stack (r : reg) : inst list =
  [Add (R29, R29, Immed (Word32.fromInt (-4))); Sw (r, R29, Word32.fromInt 0)]

let pop_from_stack (r : reg) : inst list =
  [Lw (r, R29, Word32.fromInt 0); Add (R29, R29, Immed (Word32.fromInt 4))]

let load_variable (fn : var) (v : var) (r : reg) : inst list =
  let offset = lookup_var fn v in
    if offset = 0 then [copy_register r R4]
    else if offset = 4 then [copy_register r R5]
    else if offset = 8 then [copy_register r R6]
    else if offset = 12 then [copy_register r R7]
    else if offset > 0 then [Lw (r, R30, Word32.fromInt offset)]
    else [Lw (r, R16, Word32.fromInt offset)]

let save_variable (fn: var) (v : var) (r : reg) : inst list =
  let offset = lookup_var fn v in 
    if offset = 0 then [copy_register R4 r]
    else if offset = 4 then [copy_register R5 r]
    else if offset = 8 then [copy_register R6 r]
    else if offset = 12 then [copy_register R7 r]
    else if offset > 0 then [Sw (r, R30, Word32.fromInt offset)]
    else [Lw (r, R16, Word32.fromInt offset)]

(* find all of the variables in a program and add them to the set variables *)
let rec body_vars ((p, _) : stmt) : unit = 
  match p with
  | Ast.Seq(x, y) -> body_vars x; body_vars y
  | If(e,x,y) -> body_vars x; body_vars y
  | While(e, x) -> body_vars x
  | For(e1,e2,e3,x) -> body_vars x
  | Let(v, e, x) -> add_var v; body_vars x;
  | _ -> ()

let rec arg_vars (fn: var) (args: var list) : unit =
	match args with
	| v::tl -> add_arg v; add_argument fn v; arg_vars fn tl
	| _ -> ()

let fun_vars (f: Ast.funcsig) : unit =
  reset();
	arg_vars f.name f.args;
  reset_offset(0);
  body_vars f.body;
  VarSet.iter (add_variable f.name) !variables;
  fun_to_local_var_size := VarMap.add f.name (- !var_offset) !fun_to_local_var_size

let collect_vars (fns: Ast.funcsig list) : unit =
	List.iter fun_vars fns

let determine_frame_sizes (fns: Ast.funcsig list) : unit =
  let max_arg_len = List.fold_left (fun max f -> if (max >= List.length f.args) then max else (List.length f.args)) 4 fns in
  let find_frame_size (f: Ast.funcsig) : int =
    (VarMap.find f.name !fun_to_local_var_size) + max_arg_len * 4 + 12 in
  fun_to_frame_size := List.fold_left (fun m f -> VarMap.add f.name (find_frame_size f) m) !fun_to_frame_size fns

let binop_to_inst (b : binop) : inst =
  match b with
  | Plus -> Add (R8, R8, Reg R9)
  | Minus -> Sub (R8, R8, R9)
  | Times -> Mul (R8, R8, R9)
  | Ast.Div -> Mips.Div (R8, R8, R9)
  | Eq -> Mips.Seq (R8, R8, R9)
  | Neq -> Sne (R8, R8, R9)
  | Lt -> Slt (R8, R8, Reg R9)
  | Lte -> Sle (R8, R8, R9)
  | Gt -> Sgt (R8, R8, R9)
  | Gte -> Sge (R8, R8, R9)

(* Evaluates an expression and puts the result onto the stack. *)
let rec compile_exp (fn: var) ((e, _) : exp) : inst list =
  match e with
  | Int i -> put_on_stack_int i

  | Var v -> (load_variable fn v R8) @ (put_on_stack R8)

  | Binop (e1, b, e2) -> (compile_exp fn e1) @ (compile_exp fn e2) @ (pop_from_stack R9) @ (pop_from_stack R8) @ [binop_to_inst b] @ (put_on_stack R8)

  | Not e -> (compile_exp fn e) @ (pop_from_stack R8) @ [Li (R9, Word32.fromInt 0); Mips.Seq (R8, R8, R9)] @ (put_on_stack R8)

  | Ast.And (e1, e2) -> compile_stmt fn (If (e1, (Exp e2, 0), (Exp (Int 0, 0), 0)), 0)

  | Ast.Or (e1, e2) -> compile_stmt fn (If (e1, (Exp (Int 1, 0), 0), (Exp e2, 0)), 0)

  | Assign (v, e) -> (compile_exp fn e) @ (pop_from_stack R8) @ (save_variable fn v R8) @ (put_on_stack R8)

  | Call (c, es) -> (prologue fn c es) @ [Jal c] @ (epilogue fn) @ (put_on_stack R2)

and compile_stmt (fn: var) ((s, _):stmt) : inst list =
  match s with
  | Exp e -> (compile_exp fn e) @ (pop_from_stack R8)

  | Ast.Seq (s1, s2) -> (compile_stmt fn s1) @ (compile_stmt fn s2)

  | If (e, s1, s2) -> let (label1, label2) = (new_label (), new_label ()) in
                        (compile_exp fn e) @ (pop_from_stack R8) @ [Li (R9, Word32.fromInt 0); Beq (R8, R9, label1)] @ (compile_stmt fn s1) @ [J label2; Label label1] @ (compile_stmt fn s2) @ [Label label2]

  | While (e, s) -> let (label1, label2) = (new_label (), new_label ()) in
                      [Label label1] @ (compile_exp fn e) @ (pop_from_stack R8) @ [Li (R9, Word32.fromInt 0); Beq (R8, R9, label2)] @ (compile_stmt fn s) @ [J label1; Label label2]

  | For (e1, e2, e3, s) -> (compile_exp fn e1) @ (pop_from_stack R8) @ (compile_stmt fn (While (e2, (Ast.Seq (s, (Exp e3, 0)), 0)), 0))

  | Return e -> (compile_exp fn e) @ (pop_from_stack R2) @ [copy_register R3 R2; Jr R31]

  | Let (v, e, s) -> (load_variable fn v R8) @ (put_on_stack R8) @ (compile_exp fn e) @ (pop_from_stack R8) @ (save_variable fn v R8) @ (compile_stmt fn s) @ (pop_from_stack R8) @ (save_variable fn v R8)

and prologue (caller : var) (callee: var) (es: exp list) : inst list =
  let rec store_args es position : inst list =
    match es with
    | e::tl -> 
      if position = 0 then (compile_exp caller e) @ (pop_from_stack R4) @ (store_args tl 1)
      else if position = 1 then (compile_exp caller e) @ (pop_from_stack R5) @ (store_args tl 2)
      else if position = 2 then (compile_exp caller e) @ (pop_from_stack R6) @ (store_args tl 3)
      else if position = 3 then (compile_exp caller e) @ (pop_from_stack R7) @ (store_args tl 4)
      else (compile_exp caller e) @ (pop_from_stack R8) @ [Sw (R8, R30, (Word32.fromInt (position * 4)))] @ (store_args tl (position + 1))
    | _ -> [] in

  let save_old_args = [Sw (R4, R30, Word32.fromInt 0)] @ [Sw (R5, R30, Word32.fromInt 4)] @ [Sw (R6, R30, Word32.fromInt 8)] @ [Sw (R7, R30, Word32.fromInt 12)] in
  let save_old_ra = [Sw (R31, R16, Word32.fromInt (-(VarMap.find caller !fun_to_local_var_size) -4))] in
  let save_old_fp = [Sw (R30, R16, Word32.fromInt (-(VarMap.find caller !fun_to_local_var_size) - 8))] in
  let dec_fp = [Add(R30, R30, Immed(Word32.fromInt (-(VarMap.find caller !fun_to_frame_size))))] in
  let save_old_r16 = [Sw (R16, R29, Word32.fromInt (-(VarMap.find caller !fun_to_local_var_size) - 12))] in
  let save_sp = [copy_register R16 R29] in
  let dec_sp = [Add(R29, R29, Immed(Word32.fromInt (-(VarMap.find callee !fun_to_frame_size))))] in
  let store_new_args = store_args es 0 in

  save_old_args @ save_old_ra @ save_old_fp @ dec_fp @ save_old_r16 @ save_sp @ dec_sp @ store_new_args

and epilogue (caller : var) : inst list =
  let restore_sp = [copy_register R29 R16] in
  let restore_r16 = [Lw (R16, R29, Word32.fromInt (-(VarMap.find caller !fun_to_local_var_size) - 12))] in
  let restore_ra = [Lw (R31, R16, Word32.fromInt (-(VarMap.find caller !fun_to_local_var_size) - 4))] in
  let restore_fp = [Lw (R30, R16, Word32.fromInt (-(VarMap.find caller !fun_to_local_var_size) - 8))] in
  let restore_args = [Lw (R4, R30, Word32.fromInt 0)] @ [Lw (R5, R30, Word32.fromInt 4)] @ [Lw (R6, R30, Word32.fromInt 8)] @ [Lw (R7, R30, Word32.fromInt 12)] in

  restore_sp @ restore_r16 @ restore_ra @ restore_fp  @ restore_args

let compile_fun (f:Ast.funcsig) : Mips.inst list =
  let init = 
    if f.name = "main" then 
      [copy_register R30 R29; copy_register R16 R30; Add(R29, R30, Immed(Word32.fromInt(-(VarMap.find "main" !fun_to_frame_size))))]
    else []
  in
  [Label (f.name)] @ init @ (compile_stmt f.name f.body)

let rec compile (p:Ast.program) : result =
  let fns = List.map (function Fn f-> f) p in
  let _ = collect_vars fns in
  let _ = determine_frame_sizes fns in
  let insts = List.fold_left (fun c f -> c @ (compile_fun f)) [] fns in
    {code = insts; data = [] }

let result2string (res:result) : string = 
  let code = res.code in
  let data = res.data in
  let strs = List.map (fun x -> (Mips.inst2string x) ^ "\n") code in
  let vaR8decl x = x ^ ":\t.word 0\n" in
  let readfile f =
    let stream = open_in f in
    let size = in_channel_length stream in
    let text = String.create size in
    let _ = really_input stream text 0 size in
	  let _ = close_in stream in 
    text in
  let debugcode = readfile "print.asm" in
    "\t.text\n" ^
    "\t.align\t2\n" ^
    (String.concat "" strs) ^
    "\n\n" ^
    "\t.data\n" ^
    "\t.align 0\n"^
    (String.concat "" (List.map vaR8decl data)) ^
    "\n" ^
    debugcode
