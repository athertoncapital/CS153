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

let int32_to_int16 (num : int32) : int =
  (Int32.to_int num) land 0x0000FFFF

let to_i32 (inst : inst) : int32 =
  match inst with
    Add (r1, r2, r3) -> Int32.of_int ((((0x0 lsl 5 + reg2ind r2) lsl 5 + reg2ind r3) lsl 5 + reg2ind r1) lsl 11 + 0x20)
  | Beq (r1, r2, i1) -> Int32.of_int (((0x4 lsl 5 + reg2ind r1) lsl 5 + reg2ind r2) lsl 16 + int32_to_int16 i1)
  | Jr (r1) -> Int32.of_int ((0x0 lsl 5 + reg2ind r1) lsl 21 + 0x8)
  | Jal (i1) -> Int32.of_int (0x3 lsl 26 + Int32.to_int i1)
  | Li (r1, i1) -> raise FatalError
  | Lui (r1, i1) -> Int32.of_int ((0xF lsl 10 + reg2ind r1) lsl 16 + int32_to_int16 i1)
  | Ori (r1, r2, i1) -> Int32.of_int (((0xD lsl 5 + reg2ind r2) lsl 5 + reg2ind r1) lsl 16 + int32_to_int16 i1)
  | Lw (r1, r2, i1) -> Int32.of_int (((0x23 lsl 5 + reg2ind r2) lsl 5 + reg2ind r1) lsl 16 + int32_to_int16 i1)
  | Sw (r1, r2, i1) -> Int32.of_int (((0x2B lsl 5 + reg2ind r2) lsl 5 + reg2ind r1) lsl 16 + int32_to_int16 i1)

let rec store_memory (word : int32) (pc : int32) (mem : memory) : memory =
  if Int32.compare word Int32.zero == 0 then mem else
    let new_mem = mem_update pc (mk_byte word) mem in
      store_memory (Int32.shift_right_logical word 8) (Int32.succ pc) new_mem

(* Map a program, a list of Mips assembly instructions, down to a starting 
   state. You can start the PC at any address you wish. Just make sure that 
   you put the generated machine code where you started the PC in memory! *)

let rec assem (prog : program) : state =
  let rec assem_helper prog mem_loc mem =
    match prog with
      | inst::ls -> (
          match inst with
            | Li (r1, i1) ->
              let mem = store_memory (to_i32 (Lui (r1, (Int32.shift_right_logical i1 16)))) mem_loc mem in
                let mem = store_memory (to_i32 (Ori (r1, r1, Int32.logand 0x0000FFFFl i1))) (Int32.add mem_loc 4l) mem in
                  assem_helper ls (Int32.add mem_loc 8l) mem
            | _ -> assem_helper ls (Int32.add mem_loc 4l) (store_memory (to_i32 inst) mem_loc mem)
          )
      | [] -> mem
  in let loaded_mem = assem_helper prog Int32.zero empty_mem in
    {r = empty_rf; pc = Int32.zero; m = loaded_mem}

(* Given a starting state, simulate the Mips machine code to get a final state *)
let rec interp (init_state : state) : state =
  let mem = init_state.m in
  let load_word (pc : int32) : int =
    let d = Int32.to_int (b2i32 (mem_lookup pc mem)) in
    let c = Int32.to_int (b2i32 (mem_lookup (Int32.add pc 1l) mem)) in
    let b = Int32.to_int (b2i32 (mem_lookup (Int32.add pc 2l) mem)) in
    let a = Int32.to_int (b2i32 (mem_lookup (Int32.add pc 3l) mem))in
    a lsl 24 + b lsl 16 + c lsl 8 + d
  in
  let word = load_word init_state.pc in
  if word == 0 then init_state else
  let first_six (word : int) : int =
    (word lsr 26) land 0x3F
  in
  let last_six (word : int) : int =
    word land 0x3F
  in
  let first_five (word : int) : int =
    (word lsr 21) land 0x1F
  in
  let second_five (word : int) : int =
    (word lsr 16) land 0x1F
  in
  let third_five (word : int) : int =
    (word lsr 11) land 0x1F
  in
  let last_sixteen (word : int) : int =
    word land 0xFFFF
  in
  let reg = init_state.r in
  let next_pc = Int32.add init_state.pc 4l in
  if first_six word == 0x0 && last_six word == 0x20 then
    (* Add *)
    let r2 = first_five word in
    let r3 = second_five word in
    let r1 = third_five word in
    let sum = Int32.add (rf_lookup r2 reg) (rf_lookup r3 reg) in
    let reg = rf_update r1 sum reg in
    {r = reg; pc = next_pc; m = mem}
  else if first_six word == 0x4 then
    (* Beq *)
    let rs = first_five word in
    let rt = second_five word in
    let offset = last_sixteen word in
    if rf_lookup rs reg == rf_lookup rt reg then
      let new_pc = Int32.add init_state.pc (Int32.of_int (4 * offset)) in
      {r = reg; pc = new_pc; m = mem}
    else
      {r = reg; pc = next_pc; m = mem}
  else if first_six word == 0x0 && last_six word == 0x8 then
    (* Jr *)
    let r1 = first_five word in
    let new_pc = rf_lookup r1 reg in
    {r = reg; pc = new_pc; m = mem}
  else if first_six word == 0x3 then
    (* Jal *)
    let reg = rf_update 31 next_pc reg in
    let offset = last_sixteen word in
    let next_pc = Int32.add init_state.pc (Int32.of_int (4 * offset)) in
    {r = reg; pc = next_pc; m = mem}
  else if first_six word == 0xF then
    (* Lui *)
    let rt = second_five word in
    let imm = last_sixteen word in
    let reg = rf_update rt (Int32.of_int (imm lsl 16)) reg in
    {r = reg; pc = next_pc; m = mem}
  else if first_six word == 0xD then
    (* Ori *)
    let rs = first_five word in
    let rt = second_five word in
    let imm = last_sixteen word in
    let result = (Int32.to_int (rf_lookup rs reg)) lor imm in
    let reg = rf_update rt (Int32.of_int result) reg in
    {r = reg; pc = next_pc; m = mem}
  else if first_six word == 0x23 then
    (* Lw *)
    let rs = first_five word in
    let rt = second_five word in
    let offset = last_sixteen word in
    let result = load_word (Int32.of_int (rs + offset)) in
    let reg = rf_update rt (Int32.of_int result) reg in
    {r = reg; pc = next_pc; m = mem}
  else if first_six word == 0x2B then
    (* Sw *)
    let rs = first_five word in
    let rt = second_five word in
    let offset = last_sixteen word in
    let result = rf_lookup rt reg in
    let mem = store_memory result (Int32.add (rf_lookup rs reg) (Int32.of_int offset)) mem in
    {r = reg; pc = next_pc; m = mem}
  else raise FatalError
