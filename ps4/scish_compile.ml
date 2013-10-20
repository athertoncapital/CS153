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

module VarMap = Map.Make(struct
                           type t = var
                           let compare = String.compare
                         end)

type environment = var list

let funs = ref []

let temp_counter = ref 0

let new_temp() =
  temp_counter := !temp_counter + 1; "t" ^ string_of_int(!temp_counter)

let int_of n = (Int n, 0)
let var_of v = ((Var v), 0)
let exp_of e : Cish_ast.stmt = ((Exp e), 0)

let seq_of_stmts ls : Cish_ast.stmt =
  match List.map exp_of ls with
  | hd::[] -> hd
  | hd::tl -> List.fold_right (fun acc stmt -> (Seq (acc, stmt), 0)) tl hd
  | _ -> raise Hell

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
    else if i = 1 then
      (Assign("result", (Load(Binop(acc, Plus, int_of 4), 0), 0)), 0)
    else
      indexOf (i - 1) (Load(Binop(acc, Plus, int_of 4), 0), 0)
  in indexOf i (var_of "dynenv")

let m = { name = "a"; args = []; body = (skip, 0); pos = 0}

let rec compile_env_fun (e:Scish_ast.exp) (f: var) (en: environment) : unit =
  let code = match e with
  | Scish_ast.Int i -> exp_of (Assign("result", (Int i, 0)), 0)
  | Scish_ast.Var v -> exp_of (lookup en v)
  | Scish_ast.PrimApp (op, es) -> (skip, 0)
  | Scish_ast.Lambda (v, e) -> let lambda = new_temp() in 
                     let _ = compile_env_fun e lambda (v::en) in
                     let closure = Assign("result", ((Malloc ((Int 8),0)), 0)) in
                     let load_fun = Store(((Var "result"), 0), ((Var lambda), 0)) in
                     let load_env = Store((Binop(((Var "result"), 0), Plus, ((Int 4),0)), 0), ((Var "dynenv"), 0)) in
                     seq_of_stmts [(closure, 0); (load_fun, 0); (load_env, 0)]
  | Scish_ast.App (e1, e2) -> let temp1 = new_temp() in
                    let temp2 = new_temp() in
                    let temp3 = new_temp() in
                    let env = new_temp() in
                    let _ = compile_env_fun e1 f en in
                    let assign_t1 = Assign(temp1, (Load((Var "result"), 0), 0)) in
                    let assign_t2 = Assign(temp1, ((Load((Binop(((Var "result"), 0), Plus, ((Int 4),0)), 0))), 0)) in
                    let _ = compile_env_fun e2 f en in
                    let assign_t3 = Assign(temp3, ((Var "result"), 0)) in
                    let alloc_env = Assign(env, ((Malloc ((Int  8),0)), 0)) in
                    let store_t3 = Store(((Var env), 0), ((Var temp3), 0)) in
                    let store_t2 = Store((Binop(((Var env), 0), Plus, ((Int 4),0)), 0), ((Var temp2), 0)) in
                    let store_result = Assign("result", (Call(((Var temp1), 0), [((Var env), 0)]), 0)) in
                    initialize_vars (seq_of_stmts [(assign_t1, 0); (assign_t2, 0); (assign_t3, 0); (alloc_env, 0); (store_t3, 0); (store_t2, 0); (store_result, 0)]) [temp1; temp2; temp3; env]
  | _ -> (skip, 0)
  in 
  let wrapped_code = initialize_vars code ["return"] in
  let args = (if f = "main" then [] else ["dynenv"]) in
  let m = { name = f; args = args; body = wrapped_code; pos = 0 } in
  funs := (Fn(m))::!funs

let compile_exp (e:Scish_ast.exp) : Cish_ast.program =
  let _ = compile_env_fun e "main" [] in
  List.rev !funs



