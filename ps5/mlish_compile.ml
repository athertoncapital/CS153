module ML = Mlish_ast
module SC = Scish_ast

exception ImplementMe
exception FatalError

open SC

let primop_of (p: ML.prim) : primop =
  match p with
  | ML.Plus -> Plus
  | ML.Minus -> Minus
  | ML.Times -> Times
  | ML.Div -> Div
  | ML.Eq -> Eq
  | ML.Lt -> Lt
  | ML.Pair -> Cons
  | ML.Fst -> Fst
  | ML.Snd -> Snd
  | _ -> raise FatalError

let rec compile_exp ((e, _): ML.exp) : SC.exp = 
  match e with
  | ML.Var v -> Var v
  | ML.PrimApp (p, es) -> compile_prim_exp p es
  | ML.Fn (v, e) -> Lambda (v, compile_exp e)
  | ML.App (e1, e2) -> App (compile_exp e1, compile_exp e2)
  | ML.If (e1, e2, e3) -> If (compile_exp e1, compile_exp e2, compile_exp e3)
  | ML.Let (v, e1, e2) -> sLet v (compile_exp e1) (compile_exp e2)

and compile_prim_exp (p: ML.prim) (es: ML.exp list) : SC.exp =
  let es = List.map compile_exp es in
  match p with
  | ML.Int i -> Int i
  | ML.Bool b -> if b then Int 1 else Int 0
  | ML.Nil -> PrimApp(Cons, [Int 1; Int 0])
  | ML.IsNil -> PrimApp(Fst, es)
  | ML.Cons -> PrimApp(Cons, [Int 0; PrimApp(Cons, es)])
  | ML.Hd -> PrimApp(Fst, [PrimApp(Snd, es)])
  | ML.Tl -> PrimApp(Snd, [PrimApp(Snd, es)])
  | ML.Unit -> Int 0
  | _ -> PrimApp(primop_of p, es)

