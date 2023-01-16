open Byoppl
open Distributions
let () =
  Format.printf "@.Sum of two dice: we infer the number obtained with the first die given the sum of the two dice @.";

   
open Infer.Enumeration

let sum =
  let die_1 = uniform_discr 1 6 in
  let distrib n1 =
    uniform_discr (n1+1) (n1+6) in
  create_model die_1 distrib

let () =
  Format.printf "@.-- Sum of two dice, Basic Enumeration --@.";
  let dist = infer float_of_int sum [| 5; 9; 8; 9; 10; 6 |] in
  let m, s = Distributions.stats dist in
  Format.printf "First die number, mean: %f std:%f@." m s
  


open Infer.Rejection_sampling

let sum =
  let die_1 = uniform_discr 1 6 in
  let distrib n1 =
    uniform_discr (n1+1) (n1+6) in
  create_model die_1 distrib

let () =
  Format.printf "@.-- Sum of two dice, Basic Rejection Sampling --@.";
  let dist = infer float_of_int sum [| 5; 9; 8; 9; 10; 6 |] in
  let m, s = Distributions.stats dist in
  Format.printf "First die number, mean: %f std:%f@." m s;
  Format.printf "@.This method is very slow because of the unlikelihood of having the same array of observations@."
 



open Infer.Importance_sampling

let sum =
  let die_1 = uniform_discr 1 6 in
  let distrib n1 =
    uniform_discr (n1+1) (n1+6) in
  create_model die_1 distrib

let () =
  Format.printf "@.-- Sum of two dice, Basic Importance Sampling --@.";
  let dist = infer float_of_int sum [| 5; 9; 8; 9; 10; 6 |] in
  let m, s = Distributions.stats dist in
  Format.printf "First die number, mean: %f std:%f@." m s
