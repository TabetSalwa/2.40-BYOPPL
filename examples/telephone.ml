open Byoppl
open Distributions
let () =
  Format.printf "@.Telephone: we infer the life expectancy (parameter lambda) of an exponential distribution of my telephones in years@.";
   
open Infer.Importance_sampling

let telephone =
  create_model (uniform 1. 3.) (fun life -> exponential (1./.life))

let _ =
  Format.printf "@.-- Life expectancy of my phones , Basic Importance Sampling with n=1000 --@.";
  let dist = infer (fun x -> x) telephone [| 0.5; 0.2; 2.; 2.5; 1.5|] in
  let m, s = Distributions.stats dist in
  Format.printf "Life expectancy, mean: %f std:%f@." m s   
