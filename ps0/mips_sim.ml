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

module I32 = struct
  open Int32
  let (+), ( * ), (lsl), (lsr), (land), (lor), to_int = add, mul, shift_left, shift_right_logical, logand, logor, to_int
end

let reg2ind_i32 (r: reg) : int32 = 
  Int32.of_int (reg2ind r)

let int32_to_int16 (num : int32) : int32 =
  I32.(num land 0x0000FFFFl)

let to_i32 (inst : inst) : int32 =
  let helper op1 reg1 reg2 last16: int32 =
    I32.(int32_to_int16 last16 lor reg2ind_i32 reg2 lsl 16 lor reg2ind_i32 reg1 lsl 21 lor op1 lsl 26) in
  match inst with
    Add (r1, r2, r3) -> helper 0x0l r2 r3 I32.(0x20l lor reg2ind_i32 r1 lsl 11)
  | Beq (r1, r2, i1) -> helper 0x4l r1 r2 i1
  | Jr (r1) -> helper 0x0l r1 R0 0x8l
  | Jal (i1) -> I32.((i1 land 0x3FFFFFFl) lor 0x3l lsl 26)
  | Li (r1, i1) -> raise FatalError
  | Lui (r1, i1) -> helper 0xFl R0 r1 i1
  | Ori (r1, r2, i1) -> helper 0xDl r2 r1 i1
  | Lw (r1, r2, i1) -> helper 0x23l r2 r1 i1
  | Sw (r1, r2, i1) -> helper 0x2Bl r2 r1 i1

let rec store_memory (word : int32) (pc : int32) (mem : memory) : memory =
  if Int32.compare word Int32.zero = 0 then mem else
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
  let load_word (pc : int32) : int32 =
    let d = b2i32 (mem_lookup pc mem) in
    let c = b2i32 (mem_lookup (Int32.add pc 1l) mem) in
    let b = b2i32 (mem_lookup (Int32.add pc 2l) mem) in
    let a = b2i32 (mem_lookup (Int32.add pc 3l) mem) in
    I32.(d lor c lsl 8 lor b lsl 16 lor a lsl 24)
  in
  let word = load_word init_state.pc in
  if word = 0l then init_state else
  let first_six (word : int32) : int =
    Int32.to_int I32.((word lsr 26) land 0x3Fl)
  in
  let last_six (word : int32) : int =
    Int32.to_int I32.(word land 0x3Fl)
  in
  let first_five (word : int32) : int =
    Int32.to_int I32.((word lsr 21) land 0x1Fl)
  in
  let second_five (word : int32) : int =
    Int32.to_int I32.((word lsr 16) land 0x1Fl)
  in
  let third_five (word : int32) : int =
    Int32.to_int I32.((word lsr 11) land 0x1Fl)
  in
  let last_sixteen (word : int32) : int32 =
    I32.(word land 0xFFFFl)
  in
  let reg = init_state.r in
  let next_pc = Int32.add init_state.pc 4l in
  let next_state =
  if first_six word = 0x0 && last_six word = 0x20 then
    (* Add *)
    let r2 = first_five word in
    let r3 = second_five word in
    let r1 = third_five word in
    let sum = Int32.add (rf_lookup r2 reg) (rf_lookup r3 reg) in
    let reg = rf_update r1 sum reg in
    {r = reg; pc = next_pc; m = mem}
  else if first_six word = 0x4 then
    (* Beq *)
    let rs = first_five word in
    let rt = second_five word in
    let offset = last_sixteen word in
    if rf_lookup rs reg = rf_lookup rt reg then
      let new_pc = Int32.add init_state.pc I32.(4l * offset) in
      {r = reg; pc = new_pc; m = mem}
    else
      {r = reg; pc = next_pc; m = mem}
  else if first_six word = 0x0 && last_six word = 0x8 then
    (* Jr *)
    let r1 = first_five word in
    let new_pc = rf_lookup r1 reg in
    {r = reg; pc = new_pc; m = mem}
  else if first_six word = 0x3 then
    (* Jal *)
    let reg = rf_update 31 next_pc reg in
    let offset = last_sixteen word in
    let new_pc = Int32.add init_state.pc I32.(4l * offset) in
    {r = reg; pc = new_pc; m = mem}
  else if first_six word = 0xF then
    (* Lui *)
    let rt = second_five word in
    let imm = last_sixteen word in
    let reg = rf_update rt I32.(imm lsl 16) reg in
    {r = reg; pc = next_pc; m = mem}
  else if first_six word = 0xD then
    (* Ori *)
    let rs = first_five word in
    let rt = second_five word in
    let imm = last_sixteen word in
    let result = I32.((rf_lookup rs reg) lor imm) in
    let reg = rf_update rt result reg in
    {r = reg; pc = next_pc; m = mem}
  else if first_six word = 0x23 then
    (* Lw *)
    let rs = first_five word in
    let rt = second_five word in
    let offset = last_sixteen word in
    let result = load_word I32.((rf_lookup rs reg) + offset) in
    let reg = rf_update rt result reg in
    {r = reg; pc = next_pc; m = mem}
  else if first_six word = 0x2B then
    (* Sw *)
    let rs = first_five word in
    let rt = second_five word in
    let offset = last_sixteen word in
    let result = rf_lookup rt reg in
    let mem = store_memory result (Int32.add (rf_lookup rs reg) offset) mem in
    {r = reg; pc = next_pc; m = mem}
  else raise FatalError
in interp next_state
