(*open Distributions*)

let mean (a : float array) =
  (Array.fold_left (fun x y -> x +. y) 0. a)/.(float_of_int (Array.length a))
   
let expectancy ?(n = 1000) (d: 'a Distributions.distrib) (g: 'a -> float) =
  let x = Array.init n (fun _ -> Distributions.draw d) in
  let g_x = Array.map g x in
  mean g_x
