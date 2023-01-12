open Byoppl
open Distributions

open Infer.Rejection_sampling

let sum _ =
  let d = uniform_discr 1 6 in
  let n1 = sample d in
  let n2 = sample d in
  let () = assume (n1 mod 2 = 0 || n2 mod 2 = 0) in
  n1+n2

let () =
  Format.printf "@.-- Sum of two dice given one is even, Basic Rejection Sampling --@.";
  let dist = infer float_of_int sum [| |] in
  let m, s = Distributions.stats dist in
  Format.printf "Sum, mean: %f std:%f@." m s
  
