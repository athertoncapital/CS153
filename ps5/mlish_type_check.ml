open Mlish_ast

exception TypeError
let type_error(s:string) = (print_string s; raise TypeError)

type environment = (var * tipe_scheme) list

let guess() = Guess_t(ref None)

let rec lookup ls key =
  match ls with
  | (k, v)::tl -> if k = key then v else lookup tl key
  | _ -> raise TypeError

let extend (env: environment) (v: var) (ts: tipe_scheme) =
  (v, ts)::env

let rec substitute (tvars: (tvar * tipe) list) (t:tipe) : tipe =
  match t with
  | Tvar_t tv -> lookup tvars tv
  | Fn_t (t1, t2) -> Fn_t ((substitute tvars t1), (substitute tvars t2))
  | Pair_t (t1, t2) -> Pair_t ((substitute tvars t1), (substitute tvars t2))
  | List_t t1 -> List_t(substitute tvars t1)
  | Guess_t g -> (match !g with
                  | Some t1 -> (g := Some(substitute tvars t1); t)
                  | None -> t)
  | _ -> t

let instantiate (ts: tipe_scheme) : tipe =
  let Forall(vs, t) = ts in
    let vs_and_ts = List.map (fun a -> (a, guess())) vs in
    substitute vs_and_ts t

let rec tc (env: environment) ((e, _): exp) : tipe =
  match e with
  | Var x -> instantiate (lookup env x)
  | PrimApp (p, es) -> check_prims env p es
  | Fn (v, e) -> 
      let g = guess() in Fn_t(g, tc (extend env v (Forall([], g))) e)
  | App (e1, e2) -> 
      let (t1, t2, t) = (tc env e1, tc env e2, guess())
      in if unify t1 (Fn_t(t2, t)) then t else raise TypeError
  | If (e1, e2, e3) -> 
      let (t1, t2, t3) = (tc env e1, tc env e2, tc env e3)
      in if (unify t1 Bool_t) && (unify t2 t3) then t2 else raise TypeError
  | Let (v, e1, e2) -> 
      let s = generalize env (tc env e1) in
      tc (extend env v s) e2

and check_prims (env: environment) (p: prim) (es: exp list) : tipe =
  match (p, es) with
  | (Int _, []) -> Int_t
  | (Bool _, []) -> Bool_t
  | (Unit, []) -> Unit_t
  | ((Plus|Minus|Times|Div), [e1; e2]) -> check_binop env e1 e2 Int_t Int_t Int_t
  | ((Eq | Lt), [e1; e2]) -> check_binop env e1 e2 Int_t Int_t Bool_t
  | (Pair, [e1;e2]) -> Pair_t(tc env e1, tc env e2)
  | _ -> raise TypeError

and check_binop env e1 e2 expected_t1 expected_t2 tout =
  let (t1, t2) = ((tc env e1), (tc env e2)) in
    if (unify t1 expected_t1) && (unify t2 expected_t2) then tout else raise TypeError

and unify (t1: tipe) (t2: tipe) : bool =
  if (t1 = t2) then true else
  match t1, t2 with
  | (Guess_t r), _ -> (match !r with 
                        | Some t1' -> unify t1' t2
                        | None -> if occurs r t2 then raise TypeError else (r := Some t2; true))
  | _, (Guess_t _) -> unify t2 t1
  | Fn_t (a, b) , Fn_t (c, d) -> (unify a c) && (unify b d)
  | Pair_t (a, b), Pair_t (c, d) -> (unify a c) && (unify b d)
  | List_t a, List_t b -> unify a b
  | _ -> false

and occurs (opt:tipe option ref) (t:tipe) : bool =
  match t with
  | Fn_t (t1, t2) -> occurs opt t1 || occurs opt t2
  | Pair_t (t1, t2) -> occurs opt t1 || occurs opt t2
  | List_t t1 -> occurs opt t1
  | Guess_t opt2 -> 
      if (opt = opt2) then true
      else (match !opt2 with
            | Some t1 -> occurs opt t1
            | None -> false)
  | _ -> false

and generalize (env: environment) (t: tipe) : tipe_scheme =
  raise TypeError

let type_check_exp (e:Mlish_ast.exp) : tipe = 
  tc [] e
