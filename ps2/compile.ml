(* Compile Fish AST to MIPS AST *)
open Ast
open Mips

exception IMPLEMENT_ME

type result = { code : Mips.inst list;
                data : Mips.label list }

(* generate fresh labels *)
let label_counter = ref 0
let new_int() = (label_counter := (!label_counter) + 1; !label_counter)
let new_label() = "L" ^ (string_of_int (new_int()))

(* sets of variables -- Ocaml Set and Set.S *)
module VarSet = Set.Make(struct
                           type t = var
                           let compare = String.compare
                         end)

module VarMap = Map.Make(struct
                           type t = var
                           let compare = String.compare
                         end)

(* a table of variables that we need for the code segment *)
let variables : VarSet.t ref = ref (VarSet.empty)
let var_to_offset : int VarMap.t ref = ref VarMap.empty

(* generate a fresh temporary variable and store it in the variables set. *)
let rec new_temp() = 
    let t = "T" ^ (string_of_int (new_int())) in
    (* make sure we don't already have a variable with the same name! *)
    if VarSet.mem t (!variables) then new_temp()
    else (variables := VarSet.add t (!variables); t)

(* reset internal state *)
let reset() = (label_counter := 0; variables := VarSet.empty)

(* helper function for collect_vars:
adding in vars to VarSet, if the var is already in the set, do nothing *)
let add_var v =
  if (VarSet.mem v !variables) then () else (variables := VarSet.add v !variables)
  
(* find variables in expressions *)
let rec exp_vars ((e, _) : exp) : unit =
  match e with
  | Int x -> ()
  | Var x -> add_var x
  | Binop (x,v,y) -> exp_vars x; exp_vars y
  | Not x -> exp_vars x
  | Ast.And (x,y) -> exp_vars x; exp_vars y
  | Ast.Or (x,y) -> exp_vars x; exp_vars y
  | Assign (x,y) -> add_var x; exp_vars y

(* find all of the variables in a program and add them to
 * the set variables *)
let rec collect_vars ((p, _) : program) : unit = 
  match p with
    | Exp e -> exp_vars e
    | Ast.Seq(x, y) -> collect_vars x; collect_vars y
    | If(e,x,y) -> exp_vars e; collect_vars x; collect_vars y
    | While(e, x) -> exp_vars e; collect_vars x
    | For(e1,e2,e3,x) -> exp_vars e1; exp_vars e2; exp_vars e3; collect_vars x
    | Return(e) -> exp_vars e

let var_offset = ref 0
let new_offset() = (var_offset := (!var_offset) - 4; !var_offset)

let lookup_var (v : var) : int =
  VarMap.find v !var_to_offset

let add_variable (v : var) : unit =
  var_to_offset := VarMap.add v (new_offset ()) !var_to_offset

(* copy r2 to r1; total hack *)
let copy_register (r1 : reg) (r2 : reg) : inst =
  Add (r1, r2, Immed (Word32.fromInt 0))

let put_on_stack_int (i : int) : inst list =
  [Add (R29, R29, Immed (Word32.fromInt (-4))); Li (R8, Word32.fromInt i); Sw (R8, R29, Word32.fromInt 0)]

let put_on_stack (r : reg) : inst list =
  [Add (R29, R29, Immed (Word32.fromInt (-4))); Sw (r, R29, Word32.fromInt 0)]

let pop_from_stack (r : reg) : inst list =
  [Lw (r, R29, Word32.fromInt 0); Add (R29, R29, Immed (Word32.fromInt 4))]

let load_variable (v : var) (r : reg) : inst list =
  let offset = lookup_var v in [Lw (r, R30, Word32.fromInt offset)]

let save_variable (v : var) (r : reg) : inst list =
  let offset = lookup_var v in [Sw (r, R30, Word32.fromInt offset)]

let binop_to_inst (b : binop) : inst =
  match b with
    | Plus -> Add (R8, R8, Reg R9)
    | Minus -> Sub (R8, R8, R9)
    | Times -> Mul (R8, R8, R9)
    | Ast.Div -> Mips.Div (R8, R8, R9)
    | Eq -> Seq (R8, R8, R9)
    | Neq -> Sne (R8, R8, R9)
    | Lt -> Slt (R8, R8, R9)
    | Lte -> Sle (R8, R8, R9)
    | Gt -> Sgt (R8, R8, R9)
    | Gte -> Sge (R8, R8, R9)

(* compiles a Fish statement down to a list of MIPS instructions.
 * Note that a "Return" is accomplished by placing the resulting
 * value in R2 and then doing a Jr R31.
 *)
let rec compile_exp ((e, _) : exp) : inst list =
    match e with
      | Int i -> put_on_stack_int i

      | Var v -> (load_variable v R8) @ (put_on_stack R8)

      | Binop (e1, b, e2) -> (compile_exp e1) @ (compile_exp e2) @ (pop_from_stack R9) @ (pop_from_stack R8) @ [binop_to_inst b] @ (put_on_stack R8)

      | Not e -> (compile_exp e) @ (pop_from_stack R8) @ [Li (R9, Word32.fromInt 0); Sne (R8, R8, R9)] @ (put_on_stack R8)

      | Ast.And (e1, e2) ->
(*
compile_stmt (If (e1, (Exp e2, 0), (Exp (Int 0, 0), 0)), 0)
*)

        (compile_exp e1) @ (compile_exp e2) @ (pop_from_stack R8) @ (pop_from_stack R9) @ [And (R8, R8, Reg R9)] @ (put_on_stack R8)

      | Ast.Or (e1, e2) ->
(*
compile_stmt (If (e1, (Exp (Int 1, 0), 0), (Exp e2, 0)), 0)
*)

        (compile_exp e1) @ (compile_exp e2) @ (pop_from_stack R8) @ (pop_from_stack R9) @ [Or (R8, R8, Reg R9)] @ (put_on_stack R8)

      | Assign (v, e) -> (compile_exp e) @ (pop_from_stack R8) @ (save_variable v R8) @ (put_on_stack R8)
and compile_stmt ((s, _):stmt) : inst list = 
  match s with
    | Exp e -> compile_exp e

    | Ast.Seq (s1, s2) -> (compile_stmt s1) @ (compile_stmt s2)

    | If (e, s1, s2) -> let (label1, label2) = (new_label (), new_label ()) in
                        (compile_exp e) @ (pop_from_stack R8) @ [Li (R9, Word32.fromInt 0); Beq (R8, R9, label1)] @ (compile_stmt s1) @ [J label2; Label label1] @ (compile_stmt s2) @ [Label label2]

    | While (e, s) -> let (label1, label2) = (new_label (), new_label ()) in
                      [Label label1] @ (compile_exp e) @ (pop_from_stack R8) @ [Li (R9, Word32.fromInt 0); Beq (R8, R9, label2)] @ (compile_stmt s) @ [J label1; Label label2]

    | For (e1, e2, e3, s) -> (compile_exp e1) @ (compile_stmt (While (e2, (Ast.Seq (s, (Exp e3, 0)), 0)), 0))

    | Return e -> (compile_exp e) @ (pop_from_stack R2) @ [Jr R31]

(* compiles Fish AST down to MIPS instructions and a list of global vars *)
let compile (p : program) : result = 
    let _ = reset() in
    let _ = collect_vars(p) in
    let insts = (Label "main") :: (compile_stmt p) in
    { code = insts; data = VarSet.elements (!variables) }

(* converts the output of the compiler to a big string which can be 
 * dumped into a file, assembled, and run within the SPIM simulator
 * (hopefully). *)
let result2string ({code;data}:result) : string = 
    let strs = List.map (fun x -> (Mips.inst2string x) ^ "\n") code in
    let var2decl x = x ^ ":\t.word 0\n" in
    "\t.text\n" ^
    "\t.align\t2\n" ^
    "\t.globl main\n" ^
    (String.concat "" strs) ^
    "\n\n" ^
    "\t.data\n" ^
    "\t.align 0\n"^
    (String.concat "" (List.map var2decl data)) ^
    "\n"

