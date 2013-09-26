open Combparser
open Comblexer
open Explode

let test x = parse (tokenize (explode x))
