open Byoppl
open Distributions
let _ =
  Format.printf "@.Die : we infer the die's bias given an array of observations [| 1; 2; 3; 4; 5; 6|]@."
   
let _ =
  Format.printf "@.-- Die, Basic Enumeration --@.";
  Format.printf "This inference method doesn't work because the die's bias follows a continuous distribution (uniform)@."


   
open Infer.Rejection_sampling

let die =
  let p = uniform 0. 1. in
  let distrib p =
    let p_other = (1. -. p) /. 5. in
    discrete_support float_of_int [| 1; 2; 3; 4; 5; 6|] [| p_other; p_other; p_other; p_other; p_other; p|] in
  create_model p distrib

let () =
  Format.printf "@.-- Die, Basic Rejection Sampling with n=1000 --@.";
  let dist = infer (fun x -> x) die [| 1; 2; 3; 4; 5; 6 |] in
  let m, s = Distributions.stats dist in
  Format.printf "Die bias, mean: %f std:%f@." m s;
  Format.printf "@.This method is very slow because of the unlikelihood of having the same array of observations@."



open Infer.Importance_sampling

let die =
  let p = uniform 0. 1. in
  let distrib p =
    let p_other = (1. -. p) /. 5. in
    discrete_support float_of_int [| 1; 2; 3; 4; 5; 6|] [| p_other; p_other; p_other; p_other; p_other; p|] in
  create_model p distrib

let () =
  Format.printf "@.-- Die, Basic Importance Sampling with n=1000 --@.";
  let dist = infer (fun x -> x) die [| 1; 2; 3; 4; 5; 6 |] in
  let m, s = Distributions.stats dist in
  Format.printf "Die bias, mean: %f std:%f@." m s

