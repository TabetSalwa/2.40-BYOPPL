open Byoppl
open Distributions   
open Infer.Rejection_sampling

let coin =
  create_model (uniform 0. 1.) bernoulli

let _ =
  Format.printf "@.-- Coin, Basic Rejection Sampling with n=1000 --@.";
  let dist = infer (fun x -> x) coin [| 0; 1; 1; 0; 0; 0; 0; 0; 0; 0 |] in
  let m, s = Distributions.stats dist in
  Format.printf "Coin bias, mean: %f std:%f@." m s


open Infer.Importance_sampling

let coin =
  create_model (uniform 0. 1.) bernoulli

let _ =
  Format.printf "@.-- Coin, Basic Importance Sampling with n=1000 --@.";
  let dist = infer (fun x -> x) coin [| 0; 1; 1; 0; 0; 0; 0; 0; 0; 0 |] in
  let m, s = Distributions.stats dist in
  Format.printf "Coin bias, mean: %f std:%f@." m s    

    
