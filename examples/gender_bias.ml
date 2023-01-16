open Byoppl
open Distributions

let _ =
  Format.printf "@.Gender bias : we infer the gender bias in a population of 493 people, given that there are 241 women in said population.@."   

let _ =
  Format.printf "@.-- Gender, Basic Enumeration --@.";
  Format.printf "This inference method doesn't work because gender bias follows a continuous distribution (uniform)@."


  
let _ =
  Format.printf "@.-- Gender, Basic Rejection Sampling --@.";
  Format.printf "This inference method doesn't work because the gender bias example has a too large support."


open Infer.Importance_sampling

let gender n =
  let p = uniform 0. 1. in
  let distrib p = binomial p n in
  create_model p distrib

let () = Format.printf "@.-- Gender, Basic Importance Sampling with n=1000 --@.";
let dist = infer (fun x -> x) (gender 493) [|241|] in
let m, s = Distributions.stats dist in
Format.printf "Gender bias, mean: %f std:%f@." m s

  
