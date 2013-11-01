open Mlish_ast

exception TypeError
exception NotFound
exception FatalError

let type_error(s:string) = (print_string s; raise TypeError)

let type_equals t1 t2 =
  match t1, t2 with
  | Guess_t r1, Guess_t r2 -> r1 == r2
  | _, _ -> t1 = t2

let rec contains l1 e =
  match l1 with
  | hd::tl -> if type_equals hd e then true else contains tl e
  | _ -> false

let union l1 l2 =
  List.fold_left (fun acc e -> if contains acc e then acc else e::acc) l1 l2

let minus l1 l2 =
  List.fold_left (fun acc e -> if contains l2 e then acc else e::acc) [] l1

type environment = (var * tipe_scheme) list

let guess() = Guess_t(ref None)

let var_counter = ref 0

let fresh_var() = let x = !var_counter in
  var_counter := x + 1; "t" ^ string_of_int(x)

let rec lookup ls key =
  match ls with
  | (k, v)::tl -> if k = key then v else lookup tl key
  | _ -> raise NotFound

let rec lookup_guess (ls: (tipe * tvar) list) (key: tipe) : tvar =
  match ls with
  | (k, v)::tl -> if type_equals k key then v else lookup_guess tl key
  | _ -> raise NotFound

let extend (env: environment) (v: var) (ts: tipe_scheme) : environment =
  (v, ts)::env

let rec guesses_of_tipe (t: tipe) : tipe list =
  match t with
  | Fn_t (t1, t2) -> union (guesses_of_tipe t1) (guesses_of_tipe t2)
  | Pair_t (t1, t2) -> union (guesses_of_tipe t1) (guesses_of_tipe t2)
  | List_t t1 -> guesses_of_tipe t1
  | Guess_t _ -> [t]
  | _ -> []

let rec substitute (tvars: (tvar * tipe) list) (t: tipe) : tipe =
  match t with
  | Tvar_t tv -> lookup tvars tv
  | Fn_t (t1, t2) -> Fn_t (substitute tvars t1, substitute tvars t2)
  | Pair_t (t1, t2) -> Pair_t (substitute tvars t1, substitute tvars t2)
  | List_t t1 -> List_t(substitute tvars t1)
  | Guess_t g -> (match !g with
                  | Some t1 -> (g := Some(substitute tvars t1); t)
                  | None -> t)
  | _ -> t

let rec substitute_guesses (gs: (tipe * tvar) list) (t: tipe) =
  match t with
  | Fn_t (t1, t2) -> Fn_t (substitute_guesses gs t1, substitute_guesses gs t2)
  | Pair_t (t1, t2) -> Pair_t (substitute_guesses gs t1, substitute_guesses gs t2)
  | List_t t1 -> List_t (substitute_guesses gs t1)
  | Guess_t _ -> (try Tvar_t (lookup_guess gs t) with NotFound -> t)
  | _ -> t

let rec occurs (opt: tipe option ref) (t: tipe) : bool =
  match t with
  | Fn_t (t1, t2) -> occurs opt t1 || occurs opt t2
  | Pair_t (t1, t2) -> occurs opt t1 || occurs opt t2
  | List_t t1 -> occurs opt t1
  | Guess_t opt2 -> 
      if opt == opt2 then true
      else (match !opt2 with
            | Some t1 -> occurs opt t1
            | None -> false)
  | _ -> false

let rec strip_guess_some (t: tipe) : tipe =
  match t with
  | Fn_t (t1, t2) -> Fn_t (strip_guess_some t1, strip_guess_some t2)
  | Pair_t (t1, t2) -> Pair_t (strip_guess_some t1, strip_guess_some t2)
  | List_t t1 -> List_t (strip_guess_some t1)
  | Guess_t r -> (match !r with
                  | Some s -> strip_guess_some s
                  | None -> t) 
  | _ -> t  

let instantiate (ts: tipe_scheme) : tipe =
  let Forall(vs, t) = ts in
    let vs_and_ts = List.map (fun a -> (a, guess())) vs in
    substitute vs_and_ts t

let rec unify (t1: tipe) (t2: tipe) : bool =
  let _ = print_string "unifying: ";  print_type t1; print_string ", "; print_type t2; print_string "\n" in
  let out = (
  if type_equals t1 t2 then true else
  match t1, t2 with
  | Guess_t r, _ -> (match !r with 
                        | Some t1' -> unify t1' t2
                        | None -> if occurs r t2 then type_error "unify on guess failed\n" else (r := Some t2; true))
  | _, Guess_t _ -> unify t2 t1
  | Fn_t (a, b) , Fn_t (c, d) -> (unify a c) && (unify b d)
  | Pair_t (a, b), Pair_t (c, d) -> (unify a c) && (unify b d)
  | List_t a, List_t b -> unify a b
  | _ -> false) in
  let _ = print_string "done unifying: "; print_type t1; print_string ", "; print_type t2; Printf.printf " %b" out; print_string "\n" in
  out

let generalize (env: environment) (t: tipe) : tipe_scheme =
  let _ = print_string "generalize: ";  print_type t; print_string ": " in
  let t = strip_guess_some t in
  let t_gs = guesses_of_tipe t in
  let env_list_gs = List.map (function (x, Forall (vs, t)) -> guesses_of_tipe t) env in
  let env_gs = List.fold_left union [] env_list_gs in
  let diff = minus t_gs env_gs in
  let gs_vs = List.map (fun g -> (g, fresh_var())) diff in
  let ts = substitute_guesses gs_vs t in
  let _ = print_type ts; print_string "\n" in
  Forall (List.map snd gs_vs, ts)

let rec tc (env: environment) ((e, _): exp) : tipe =
  let _ = print_string "tc: ";  print_exp (e, 0); print_string "\n" in
  let _ = (print_string "env: "; List.iter (function (a, Forall(b, t)) -> print_string (a^": "); print_type t; print_string ", ") env )in
  let _ = print_string "\n" in
  let out = (
  match e with
  | Var x -> instantiate (lookup env x)
  | PrimApp (p, es) -> check_prims env p es
  | Fn (v, e) -> 
      let g = guess() in Fn_t (g, tc (extend env v (Forall ([], g))) e)
  | App (e1, e2) -> 
      let (t1, t2, t) = (tc env e1, tc env e2, guess())
      in if unify t1 (Fn_t (t2, t)) then t else type_error "tc on App failed\n"
  | If (e1, e2, e3) -> 
      let (t1, t2, t3) = (tc env e1, tc env e2, tc env e3)
      in if (unify t1 Bool_t) && (unify t2 t3) then t2 else type_error "tc on If failed\n"
  | Let (v, e1, e2) ->
      let s = generalize env (tc env e1) in
      tc (extend env v s) e2 ) in
  let Forall (vs, gout) = generalize env out in 
  let _ = print_string "tc complete: ";  print_exp (e, 0); print_string ": "; print_type out; print_string "\n" in
  out

and check_prims (env: environment) (p: prim) (es: exp list) : tipe =
  match p, es with
  | Int _, [] -> Int_t
  | Bool _, [] -> Bool_t
  | Unit, [] -> Unit_t
  | (Plus|Minus|Times|Div), [e1; e2] -> check_binop env e1 e2 Int_t Int_t Int_t
  | (Eq | Lt), [e1; e2] -> check_binop env e1 e2 Int_t Int_t Bool_t
  | Pair, [e1; e2] -> Pair_t (tc env e1, tc env e2)
  | Fst, [e] -> 
      let (t, g1, g2) = (tc env e, guess(), guess())
      in if unify t (Pair_t (g1, g2)) then g1 else type_error "check_prims on Fst failed\n"
  | Snd, [e] ->
      let (t, g1, g2) = (tc env e, guess(), guess())
      in if unify t (Pair_t (g1, g2)) then g2 else type_error "check_prims on Snd failed\n"
  | Nil, [] -> List_t (guess())
  | Cons, [e1; e2] ->
      let (t1, t2) = (tc env e1, tc env e2)
      in if unify t2 (List_t t1) then List_t t1 else type_error "check_prims on Cons failed\n"
  | IsNil, [e] -> 
      let (t, l) = (tc env e, List_t(guess()))
      in if unify t l then Bool_t else type_error "check_prims on IsNil failed\n"
  | Hd, [e] ->
      let (t, g) = (tc env e, guess())
      in if unify t (List_t g) then g else type_error "check_prims on Hd failed\n"
  | Tl, [e] ->
      let (t, g) = (tc env e, guess())
      in if unify t (List_t g) then (List_t g) else type_error "check_prims on Tl failed\n"
  | _ -> type_error "check_prims missed match\n"

and check_binop env e1 e2 expected_t1 expected_t2 tout =
  let (t1, t2) = (tc env e1, tc env e2) in
    if (unify t1 expected_t1) && (unify t2 expected_t2) then tout else type_error "check_binop failed\n"

let type_check_exp (e: Mlish_ast.exp) : tipe = 
  tc [] e
