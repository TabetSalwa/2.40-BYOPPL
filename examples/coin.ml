open Byoppl
open Distributions
   
(*let _ =
  Format.printf "@.Coin : we infer the bias of the coin given the following array of observations [0; 1; 1; 0; 0; 0; 0; 0; 0; 0]@.";*)
   
let _ =
  Format.printf "@.-- Coin, Basic Enumeration --@.";
  Format.printf "This inference method doesn't work because the coin's bias follows a continuous distribution (uniform)@.";

  
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

  

open Cps.Rejection_sampling

let coin cont _prob data =
  sample
    (fun _prob p ->
      let d = bernoulli p in
      observe_array
        (fun _prob -> cont _prob p)
        _prob
        d
        data)
    _prob
    (uniform 0. 1.)

let _ =
  Format.printf "@.-- Coin, Cps Rejection Sampling with n=1000 --@.";
  let dist = infer (fun x -> x) coin [| 0; 1; 1; 0; 0; 0; 0; 0; 0; 0 |] in
  let m, s = Distributions.stats dist in
  Format.printf "Coin bias, mean: %f std:%f@." m s  


  
open Cps.Importance_sampling

let coin cont _prob data =
  sample
    (fun _prob p ->
      let d = bernoulli p in
      observe_array
        (fun _prob -> cont _prob p)
        _prob
        d
        data)
    _prob
    (uniform 0. 1.)

let _ =
  Format.printf "@.-- Coin, Cps Importance Sampling with n=1000 --@.";
  let dist = infer (fun x -> x) coin [| 0; 1; 1; 0; 0; 0; 0; 0; 0; 0 |] in
  let m, s = Distributions.stats dist in
  Format.printf "Coin bias, mean: %f std:%f@." m s  
