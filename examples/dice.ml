open Byoppl
open Distributions   
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
  Format.printf "Die bias, mean: %f std:%f@." m s



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

