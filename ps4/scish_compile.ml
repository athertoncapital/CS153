(* TODO:  your job is to map ScishAst expressions to CishAst functions. 
   The file sample_input.scish shows a sample Scish expression and the
   file sample_output.cish shows the output I get from my compiler.
   You will want to do your own test cases...
 *)

open Cish_ast

exception Unimplemented
exception VariableNotFoundInEnvironment
exception NotALambdaExpression
exception Hell
exception IncorrectNumArgs

module VarMap = Map.Make(struct
                           type t = var
                           let compare = String.compare
                         end)

type environment = var list

let funs = ref []

let temp_counter = ref 0

let new_temp() =
  let n = !temp_counter in
    temp_counter := n + 1; "t" ^ string_of_int(n)

let int_of n = (Int n, 0)
let var_of v = ((Var v), 0)
let exp_of e : Cish_ast.stmt = ((Exp e), 0)

let binop_of_prim p =
  match p with
  | Scish_ast.Plus -> Plus
  | Scish_ast.Minus -> Minus
  | Scish_ast.Times -> Times
  | Scish_ast.Div -> Div
  | Scish_ast.Eq -> Eq
  | Scish_ast.Lt -> Lt
  | _ -> raise Hell

let seq_of_stmts ls : Cish_ast.stmt =
  match ls with
  | hd::[] -> hd
  | hd::tl -> List.fold_left (fun acc stmt -> (Seq (acc, stmt), 0)) hd tl
  | _ -> raise Hell

let seq_of_exprs ls : Cish_ast.stmt =
  seq_of_stmts (List.map exp_of ls)

let initialize_vars stmt =
  List.fold_left (fun acc s -> (Let(s, (int_of 0), acc), 0)) stmt

let lookup (en: environment) (v: var) =
  let rec helper en v acc =
    match en with
    | hd::tl -> if hd = v then acc else helper tl v (acc + 1)
    | _ -> raise VariableNotFoundInEnvironment
  in
  let i = helper en v 0 in
  let rec indexOf i acc =
    if i <= 0 then
      (Assign("result", (Load(acc), 0)), 0)
    else
      indexOf (i - 1) (Load(Binop(acc, Plus, int_of 4), 0), 0)
  in indexOf i (var_of "dynenv")

let m = { name = "a"; args = []; body = (skip, 0); pos = 0}

let rec compile_env_fun (e:Scish_ast.exp) (f: var) (en: environment) : unit =
  let code = compile_env_exp e en in
  let init = (if f = "main" then ["dynenv"; "result"] else ["result"]) in
  let wrapped_code = initialize_vars (Seq(code, (Return(var_of "result"), 0)), 0) init in
  let args = (if f = "main" then [] else ["dynenv"]) in
  let m = { name = f; args = args; body = wrapped_code; pos = 0 } in
  funs := (Fn(m))::!funs

and compile_env_exp (e:Scish_ast.exp) (en:environment) : Cish_ast.stmt =
  match e with
  | Scish_ast.Int i -> exp_of (Assign("result", (Int i, 0)), 0)
  | Scish_ast.Var v -> exp_of (lookup en v)
  | Scish_ast.PrimApp (op, es) -> compile_primapp op es en
  | Scish_ast.Lambda (v, e) -> 
                      let lambda = new_temp() in 
                      let _ = compile_env_fun e lambda (v::en) in
                      let closure = Assign("result", ((Malloc ((Int 8),0)), 0)) in
                      let load_fun = Store(var_of "result", ((Var lambda), 0)) in
                      let load_env = Store((Binop(var_of "result", Plus, int_of 4), 0), var_of "dynenv") in
                      seq_of_exprs [(int_of 0); (closure, 0); (load_fun, 0); (load_env, 0); (int_of 1);]
  | Scish_ast.App (e1, e2) -> 
                      let temp1 = new_temp() in
                      let temp2 = new_temp() in
                      let temp3 = new_temp() in
                      let e1 = compile_env_exp e1 en in
                      let assign_t1 = Assign(temp1, (Load((Var "result"), 0), 0)) in
                      let assign_t2 = Assign(temp2, ((Load((Binop(var_of "result", Plus, int_of 4), 0))), 0)) in
                      let e2 = compile_env_exp e2 en in
                      let assign_t3 = Assign(temp3, var_of "result") in
                      let alloc_env = Assign("result", ((Malloc ((Int  8),0)), 0)) in
                      let store_t3 = Store(var_of "result", var_of temp3) in
                      let store_t2 = Store((Binop(var_of "result", Plus, ((Int 4),0)), 0), var_of temp2) in
                      let store_result = Assign("result", (Call(var_of temp1, [var_of "result"]), 0)) in
                      initialize_vars (seq_of_stmts [exp_of (int_of 2); e1; exp_of (assign_t1, 0); exp_of (assign_t2, 0); e2; exp_of (assign_t3, 0); exp_of (alloc_env, 0); exp_of (store_t3, 0); exp_of (store_t2, 0); exp_of (store_result, 0); exp_of (int_of 3)]) [temp1; temp2; temp3]
  | Scish_ast.If(e1, e2, e3) -> let calc_e1 = compile_env_exp e1 en in
                      let calc_e2 = compile_env_exp e2 en in
                      let calc_e3 = compile_env_exp e3 en in
                      seq_of_stmts [calc_e1; (If (var_of "result", calc_e2, calc_e3), 0)]

and compile_primapp (op: Scish_ast.primop) (es: Scish_ast.exp list) (en: environment) =
  match op with
  | Scish_ast.Fst -> (match es with
            | e::[] -> let code = compile_env_exp e en in 
                        (Seq(code, exp_of (Assign("result", (Load(var_of "result"), 0)), 0)), 0)
            | _ -> raise IncorrectNumArgs)
  | Scish_ast.Snd -> (match es with
            | e::[] -> let code = compile_env_exp e en in
                        (Seq(code, exp_of((Assign("result", (Load((Binop(var_of "result", Plus, int_of 4), 0)), 0)), 0))), 0)
            | _ -> raise IncorrectNumArgs)
  | Scish_ast.Cons -> (match es with
            | e1::e2::[] -> let code1 = compile_env_exp e1 en in
                            let temp1 = new_temp() in
                            let store_temp1 = exp_of (Assign(temp1, var_of "result"), 0) in
                            let code2 = compile_env_exp e2 en in
                            let temp2 = new_temp() in
                            let store_temp2 = exp_of (Assign(temp2, var_of "result"), 0) in
                            let alloc_res = exp_of ((Assign("result", (Malloc(int_of 8), 0))), 0) in
                            let store_result1 = exp_of ((Store(var_of "result", var_of temp1)), 0) in
                            let store_result2 = exp_of ((Store((Binop(var_of "result", Plus, int_of 4), 0), var_of temp2)), 0) in
                            initialize_vars (seq_of_stmts [code1; store_temp1; code2; store_temp2; alloc_res; store_result1; store_result2;]) [temp1; temp2]
            | _ -> raise IncorrectNumArgs)
  | op -> (match es with
            | e1::e2::[] -> let code1 = compile_env_exp e1 en in
                            let temp = new_temp() in
                            let store_temp = exp_of (Assign(temp, var_of "result"), 0) in
                            let code2 = compile_env_exp e2 en in
                            let res = exp_of (Assign("result", (Binop(var_of temp, (binop_of_prim op), var_of "result"), 0)), 0) in
                            initialize_vars (seq_of_stmts [code1; store_temp; code2; res]) [temp]
            | _ -> raise IncorrectNumArgs)

let compile_exp (e:Scish_ast.exp) : Cish_ast.program =
  let _ = compile_env_fun e "main" [] in
  List.rev !funs



