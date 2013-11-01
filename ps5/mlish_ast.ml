type var = string   (* program variables *)
type tvar = string  (* type variables *)
type pos = int

type tipe = 
  Tvar_t of tvar
| Int_t
| Bool_t
| Unit_t
| Fn_t of tipe * tipe
| Pair_t of tipe * tipe
| List_t of tipe
| Guess_t of tipe option ref

type tipe_scheme = Forall of (tvar list) * tipe

type prim = 
  Int of int
| Bool of bool
| Unit   (* unit value -- () *)
| Plus   (* add two ints *)
| Minus  (* subtract two ints *)
| Times  (* multiply two ints *)
| Div    (* divide two ints *)
| Eq     (* compare two ints for equality *)
| Lt     (* compare two ints for inequality *)
| Pair   (* create a pair from two values *)
| Fst    (* fetch the 1st component of a pair *)
| Snd    (* fetch the 2nd component of a pair *)
| Nil    (* the empty list *)
| Cons   (* create a list from two values *)
| IsNil  (* determine whether a list is Nil *)
| Hd     (* fetch the head of a list *)
| Tl     (* fetch the tail of a list *)

type rexp = 
  Var of var
| PrimApp of prim * exp list
| Fn of var * exp
| App of exp * exp
| If of exp * exp * exp
| Let of var * exp * exp
and exp = rexp * pos

let rec print_type (t : tipe) : unit =
    match t with
    | Tvar_t t1 -> Printf.printf "%s" t1
    | Int_t -> Printf.printf "Int"
    | Bool_t -> Printf.printf "Bool"
    | Unit_t -> Printf.printf "Unit"
    | Fn_t (t1, t2) -> Printf.printf "Function from ("; print_type t1; Printf.printf ") to ("; print_type t2; Printf.printf ")"
    | Pair_t (t1, t2) -> Printf.printf "Pair of ("; print_type t1; Printf.printf ") and ("; print_type t2; Printf.printf ")"
    | List_t t1 -> Printf.printf "List of ("; print_type t1; Printf.printf ")"
    | Guess_t t1 -> match !t1 with
                    | Some t -> Printf.printf "Guess of ("; print_type t; Printf.printf ")"
                    | None -> Printf.printf "None"

let rec print_exp (e, _) : unit =
  match e with
  | Var v -> print_string v
  | PrimApp (Int i, _) -> Printf.printf "%d" i
  | PrimApp (Hd, [e]) -> Printf.printf "(hd "; print_exp e; Printf.printf ")"
  | PrimApp (Tl, [e]) -> Printf.printf "(tl "; print_exp e; Printf.printf ")"
  | PrimApp (Cons, [e1; e2]) -> print_string "("; print_exp e1; print_string "::"; print_exp e2; print_string ")"
  | PrimApp (Nil, _) -> print_string "[]"
  | Fn (v, e) -> print_string ("(fun " ^ v ^ "->"); print_exp e; print_string ")"
  | App (e1, e2) -> print_string "("; print_exp e1; print_string " "; print_exp e2; print_string ")"
  | Let (v, e1, e2) -> print_string ("(let " ^ v ^ "="); print_exp e1; print_string " in "; print_exp e2; print_string ")"
  | PrimApp( Pair, [e1; e2]) -> print_string ("("); print_exp e1; print_string ", "; print_exp e2; print_string ")"
  | PrimApp (Fst, [e]) -> Printf.printf "(fst "; print_exp e; Printf.printf ")"
  | PrimApp (Snd, [e]) -> Printf.printf "(snd "; print_exp e; Printf.printf ")"
  | _ -> print_string "unimp"
