open Mips_ast
open Byte

exception TODO
exception FatalError

(* Register file definitions. A register file is a map from a register 
   number to a 32-bit quantity. *)
module IntMap = Map.Make(struct type t = int let compare = compare end)
type regfile = int32 IntMap.t 
let empty_rf = IntMap.empty
let rf_update (r : int) (v : int32) (rf : regfile) : regfile = 
  IntMap.add r v rf
let rf_lookup (r : int) (rf : regfile) : int32 = 
  try IntMap.find r rf with Not_found -> Int32.zero
let string_of_rf (rf : regfile) : string = 
  IntMap.fold (fun key v s -> 
    s^(string_of_int key)^" -> "^(Int32.to_string v)^"\n") rf ""

(* Memory definitions. A memory is a map from 32-bit addresses to bytes. *)
module Int32Map = Map.Make(struct type t = int32 let compare = Int32.compare end)
type memory = byte Int32Map.t
let empty_mem = Int32Map.empty
let mem_update (a : int32) (v : byte) (m : memory) : memory =
  Int32Map.add a v m
let mem_lookup (a : int32) (m : memory) : byte =
  try (Int32Map.find a m) with Not_found -> mk_byte Int32.zero
let string_of_mem (m : memory) : string =
  Int32Map.fold (fun key v s ->
    s^(Int32.to_string key)^" -> "^(Int32.to_string (b2i32 v))^"\n") m ""

(* State *)
type state = { r : regfile; pc : int32; m : memory }

let to_byte (inst : inst) : byte =
  match inst with
    Add (r1, r2, r3) -> mk_byte(Int32.of_int(((((((0 lsl 5) + reg2ind r1) lsl 5) + reg2ind r2) lsl 5 + reg2ind r3) lsl 11) + 32))
  | Beq (r1, r2, i1) -> mk_byte(Int32.of_int(((((4 lsl 5) + reg2ind r1) lsl 5) + reg2ind r2) lsl 16 + Int32.to_int(i1)))
  | Jr (r1) -> mk_byte(Int32.of_int((((0 lsl 5) + reg2ind r1) lsl 21) + 8))
  | Jal (i1) -> mk_byte(Int32.of_int((3 lsl 26) + Int32.to_int(i1)))
  | Li (r1, i1) -> raise FatalError
  | Lui (r1, i1) -> mk_byte(Int32.of_int(((((15 lsl 10) + reg2ind r1) lsl 16) + Int32.to_int(i1))))
  | Ori (r1, r2, i1) -> mk_byte(Int32.of_int((((((13 lsl 5) + reg2ind r1) lsl 5) + reg2ind r2) lsl 16) + Int32.to_int(i1)))
  | Lw (r1, r2, i1) -> mk_byte(Int32.of_int(((((35 lsl 5) + reg2ind r2) lsl 5) + reg2ind r1) lsl 16 + Int32.to_int(i1)))
  | Sw (r1, r2, i1) -> mk_byte(Int32.of_int(((((43 lsl 5) + reg2ind r2) lsl 5) + reg2ind r1) lsl 16 + Int32.to_int(i1)))

(* Map a program, a list of Mips assembly instructions, down to a starting 
   state. You can start the PC at any address you wish. Just make sure that 
   you put the generated machine code where you started the PC in memory! *)


let rec assem (prog : program) : state =
  let rec assem_helper prog state =
    match prog with 
      inst::ls -> (
        match inst with
          Li (r1, i1) -> assem_helper ls {r = state.r; pc = Int32.add state.pc 64l ; m = mem_update (Int32.add state.pc 32l) (to_byte(Ori(r1, R0, Int32.logand 0x0000000Fl i1 ))) (mem_update state.pc (to_byte(Lui(r1, (Int32.shift_right_logical i1 16)))) state.m)}
        | _ -> assem_helper ls {r = state.r; pc = Int32.add state.pc 32l ; m = mem_update state.pc (to_byte inst) state.m}
        )
    | [] -> {r = rf_update 0 0l state.r; pc = state.pc; m = state.m }

  in assem_helper prog {r = empty_rf; pc = 0l; m = empty_mem}


(* Given a starting state, simulate the Mips machine code to get a final state *)
let rec interp (init_state : state) : state = raise TODO
