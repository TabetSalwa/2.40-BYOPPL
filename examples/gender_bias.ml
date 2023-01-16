open Byoppl
open Distributions

open Infer.Importance_sampling

let gender n =
  let p = uniform 0. 1. in
  let distrib p = binomial p n in
  create_model p distrib

let () = Format.printf "@.-- Gender, Basic Importance Sampling with n=1000 --@.";
         let dist = infer (fun x -> x) (gender 493) [|241|] in
  let m, s = Distributions.stats dist in
  Format.printf "Gender bias, mean: %f std:%f@." m s
