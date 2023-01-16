type model = unit -> float

let sample = Distributions.draw
           
let mean (a : float array) =
  (Array.fold_left (fun x y -> x +. y) 0. a)/.(float_of_int (Array.length a))
   
let ev ?(n = 1000) (m : model) =
  let x = Array.init n (fun _ -> m ()) in
  mean x
