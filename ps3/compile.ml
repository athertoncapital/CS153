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
let new_label() = "L" ^ (string_of_int (new_int()))

let fun_label (f : var) : var =
  "fun_" ^ f

module VarSet = Set.Make(struct
                           type t = var
                           let compare = String.compare
                         end)

module VarMap = Map.Make(struct
                           type t = var
                           let compare = String.compare
                         end)

let var_to_offset : int VarMap.t ref = ref VarMap.empty

let var_offset = ref 0
let var_minus_offset = ref 0

let reset_offsets() = (var_offset := 0; var_minus_offset := 0)

let new_minus_offset() = (var_minus_offset := !var_minus_offset - 4; !var_minus_offset)

let dec_minus_offset() = (var_minus_offset := !var_minus_offset - 4)

let inc_minus_offset() = (var_minus_offset := !var_minus_offset + 4)

let new_offset() = (let offset = !var_offset in var_offset := offset + 4; offset)

let reset() = (reset_offsets(); var_to_offset := VarMap.empty)

(* helper function for collect_vars:
adding in vars to VarSet, if the var is already in the set, do nothing *)

let add_argument (v : var) : unit =
  var_to_offset := VarMap.add v (new_offset()) !var_to_offset

let add_variable_at_offset (v : var) (offset : int) : unit =
  var_to_offset := VarMap.add v offset !var_to_offset

let remove_variable (v : var) : unit =
  var_to_offset := VarMap.remove v !var_to_offset

let lookup_var (v : var) : int =
  VarMap.find v !var_to_offset

(* copy r2 to r1 *)
let copy_register (r1 : reg) (r2 : reg) : inst =
  Mips.Or (r1, r2, Immed (Word32.fromInt 0))

let put_on_stack_int (i : int) : inst list =
  dec_minus_offset();
  [Add (R29, R29, Immed (Word32.fromInt (-4))); Li (R8, Word32.fromInt i); Sw (R8, R29, Word32.fromInt 0)]

let put_on_stack (r : reg) : inst list =
  dec_minus_offset();
  [Add (R29, R29, Immed (Word32.fromInt (-4))); Sw (r, R29, Word32.fromInt 0)]

let pop_from_stack (r : reg) : inst list =
  inc_minus_offset();
  [Lw (r, R29, Word32.fromInt 0); Add (R29, R29, Immed (Word32.fromInt 4))]

let load_variable (v : var) (r : reg) : inst list =
  let offset = lookup_var v in
    if offset = 0 then [copy_register r R4]
    else if offset = 4 then [copy_register r R5]
    else if offset = 8 then [copy_register r R6]
    else if offset = 12 then [copy_register r R7]
    else [Lw (r, R30, Word32.fromInt offset)]

let save_variable (v : var) (r : reg) : inst list =
  let offset = lookup_var v in 
    if offset = 0 then [copy_register R4 r]
    else if offset = 4 then [copy_register R5 r]
    else if offset = 8 then [copy_register R6 r]
    else if offset = 12 then [copy_register R7 r]
    else [Sw (r, R30, Word32.fromInt offset)]

let collect_vars (f : Ast.funcsig) : unit =
  List.iter add_argument f.args

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
let rec compile_exp ((e, _) : exp) : inst list =
  match e with
  | Int i -> put_on_stack_int i

  | Var v -> (load_variable v R8) @ (put_on_stack R8)

  | Binop (e1, b, e2) -> (compile_exp e1) @ (compile_exp e2) @ (pop_from_stack R9) @ (pop_from_stack R8) @ [binop_to_inst b] @ (put_on_stack R8)

  | Not e -> (compile_exp e) @ (pop_from_stack R8) @ [Li (R9, Word32.fromInt 0); Mips.Seq (R8, R8, R9)] @ (put_on_stack R8)

  | Ast.And (e1, e2) -> (compile_exp e1) @ (compile_exp e2) @ (pop_from_stack R8) @ (pop_from_stack R9) @ [Mips.And (R8, R8, Reg R9)] @ (put_on_stack R8)

  | Ast.Or (e1, e2) -> (compile_exp e1) @ (compile_exp e2) @ (pop_from_stack R8) @ (pop_from_stack R9) @ [Mips.Or (R8, R8, Reg R9)] @ (put_on_stack R8)

  | Assign (v, e) -> (compile_exp e) @ (pop_from_stack R8) @ (save_variable v R8) @ (put_on_stack R8)

  | Call (c, es) ->
    let old_offset = !var_minus_offset in
    let _ = var_minus_offset := 0 in
    let call_inst = (prologue c es) @ [Jal (fun_label c)] @ (epilogue es) in
    let _ = var_minus_offset := old_offset in
    call_inst @ (put_on_stack R2)
(* Compiles a statement and makes sure not to move the stack pointer. *)
and compile_stmt ((s, _) : stmt) : inst list =
  match s with
  | Exp e -> (compile_exp e) @ (pop_from_stack R8)

  | Ast.Seq (s1, s2) -> (compile_stmt s1) @ (compile_stmt s2)

  | If (e, s1, s2) -> let (label1, label2) = (new_label (), new_label ()) in
                        (compile_exp e) @ (pop_from_stack R8) @ [Li (R9, Word32.fromInt 0); Beq (R8, R9, label1)] @ (compile_stmt s1) @ [J label2; Label label1] @ (compile_stmt s2) @ [Label label2]

  | While (e, s) -> let (label1, label2) = (new_label (), new_label ()) in
                      [Label label1] @ (compile_exp e) @ (pop_from_stack R8) @ [Li (R9, Word32.fromInt 0); Beq (R8, R9, label2)] @ (compile_stmt s) @ [J label1; Label label2]

  | For (e1, e2, e3, s) -> (compile_exp e1) @ (pop_from_stack R8) @ (compile_stmt (While (e2, (Ast.Seq (s, (Exp e3, 0)), 0)), 0))

  | Return e -> (compile_exp e) @ (pop_from_stack R2) @ [copy_register R3 R2; Jr R31]

  | Let (v, e, s) -> 
    if VarMap.mem v !var_to_offset then 
      let old_offset = VarMap.find v !var_to_offset in
      let new_value = (compile_exp e) in
      let new_offset = !var_minus_offset in
      let _ = add_variable_at_offset v new_offset in 
      let stmt_inst = (compile_stmt s) in
      let _ = add_variable_at_offset v old_offset in 
      new_value @ stmt_inst @ (pop_from_stack R8)
    else 
      let new_value = (compile_exp e) in
      let new_offset = !var_minus_offset in
      let _ = add_variable_at_offset v new_offset in 
      let stmt_inst = (compile_stmt s) in
      let _ = remove_variable v in
      new_value @ stmt_inst @ (pop_from_stack R8)

and prologue (callee : var) (es : exp list) : inst list =
  let rec store_args es position : inst list =
    match es with
    | e::tl -> 
      if position = 0 then (compile_exp e) @ (pop_from_stack R4) @ (store_args tl 1)
      else if position = 1 then (compile_exp e) @ (pop_from_stack R5) @ (store_args tl 2)
      else if position = 2 then (compile_exp e) @ (pop_from_stack R6) @ (store_args tl 3)
      else if position = 3 then (compile_exp e) @ (pop_from_stack R7) @ (store_args tl 4)
      else (compile_exp e) @ (pop_from_stack R8) @ [Sw (R8, R29, (Word32.fromInt (position * 4)))] @ (store_args tl (position + 1))
    | _ -> [] in

  let save_old_args = [Sw (R4, R30, Word32.fromInt 0); Sw (R5, R30, Word32.fromInt 4); Sw (R6, R30, Word32.fromInt 8); Sw (R7, R30, Word32.fromInt 12)] in
  let save_old_fp = put_on_stack R30 in
  let save_old_ra = put_on_stack R31 in
  let arg_size = if List.length(es) <= 4 then 4 else List.length(es) in
  let move_sp = [Add(R29, R29, Immed(Word32.fromInt(-arg_size * 4)))] in
  let move_fp = [copy_register R30 R29] in
  let store_new_args = store_args es 0 in

  save_old_args @ save_old_fp @ save_old_ra @ move_sp @ store_new_args @ move_fp

and epilogue (es : exp list) : inst list =
  let arg_size = if List.length(es) <= 4 then 4 else List.length(es) in
  let move_sp_to_fp = [copy_register R29 R30] in
  let pop_args = [Add(R29, R29, Immed(Word32.fromInt(arg_size * 4)))] in
  let restore_ra = pop_from_stack R31 in
  let restore_fp = pop_from_stack R30 in
  let restore_args = [Lw (R4, R30, Word32.fromInt 0); Lw (R5, R30, Word32.fromInt 4); Lw (R6, R30, Word32.fromInt 8); Lw (R7, R30, Word32.fromInt 12)] in

  move_sp_to_fp @ pop_args @ restore_ra @ restore_fp @ restore_args

let compile_fun (f : Ast.funcsig) : Mips.inst list =
  let _ = reset() in
  let _ = collect_vars f in
  let init = 
    if f.name = "main" then 
      [Label f.name; copy_register R30 R29]
    else [Label (fun_label f.name)]
  in
  init @ (compile_stmt f.body)

let rec compile (p : Ast.program) : result =
  let fns = List.map (function Fn f-> f) p in
  let insts = List.fold_left (fun c f -> c @ (compile_fun f)) [] fns in
    {code = insts; data = [] }

let result2string (res : result) : string = 
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
