open Byoppl
open Distributions

open Infer.Importance_sampling

let gender n data =
  let p = sample (uniform 0. 1.) in
  let d = binomial p n in
  (p,Array.fold_left (fun prob -> observe prob d) 1. data)

let () = Format.printf "@.-- Die, Basic Importance Sampling with n=1000 --@.";
  let dist = infer (fun x -> x) (gender 493472) [|241945|] in
  let m, s = Distributions.stats dist in
  Format.printf "Die bias, mean: %f std:%f@." m s;
  print_discrete dist
