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


  
open Infer.Importance_sampling

let sum _ =
  let d = uniform_discr 1 6 in
  let n1 = sample d in
  let n2 = sample d in
  let p = assume 1. (n1 mod 2 = 0 || n2 mod 2 = 0) in
  n1+n2,p

let () =
  Format.printf "@.-- Sum of two dice given one is even, Basic Importance Sampling --@.";
  let dist = infer float_of_int sum [| |] in
  let m, s = Distributions.stats dist in
  Format.printf "Sum, mean: %f std:%f@." m s


  
open Cps.Enumeration

let sum cont _prob _data =
    sample
      (fun _prob a ->
        sample
          (fun _prob b ->
            assume
              (fun _prob -> cont _prob (a+b))
              _prob
              (a mod 2 = 0 || b mod 2 = 0))
          _prob
          (uniform_discr 1 6))
      _prob
      (uniform_discr 1 6)

let () =
  Format.printf "@.-- Sum of two dice given one is even, CPS Enumeration --@.";
  let dist = infer float_of_int sum () in
  let m, s = Distributions.stats dist in
  Format.printf "Sum of two dice given one is even, mean: %f std:%f@." m s;
  print_discrete_int dist


  
open Cps.Rejection_sampling

let sum cont _prob _data =
    sample
      (fun _prob a ->
        sample
          (fun _prob b ->
            assume
              (fun _prob -> cont _prob (a+b))
              _prob
              (a mod 2 = 0 || b mod 2 = 0))
          _prob
          (uniform_discr 1 6))
      _prob
      (uniform_discr 1 6)

let () =
  Format.printf "@.-- Sum of two dice given one is even, CPS Rejection sampling --@.";
  let dist = infer float_of_int sum () in
  let m, s = Distributions.stats dist in
  Format.printf "Sum of two dice given one is even, mean: %f std:%f@." m s;
  print_discrete_int dist


  
open Cps.Importance_sampling

let sum cont _prob _data =
    sample
      (fun _prob a ->
        sample
          (fun _prob b ->
            assume
              (fun _prob -> cont _prob (a+b))
              _prob
              (a mod 2 = 0 || b mod 2 = 0))
          _prob
          (uniform_discr 1 6))
      _prob
      (uniform_discr 1 6)

let () =
  Format.printf "@.-- Sum of two dice given one is even, CPS Importance sampling --@.";
  let dist = infer float_of_int sum () in
  let m, s = Distributions.stats dist in
  Format.printf "Sum of two dice given one is even, mean: %f std:%f@." m s;
  print_discrete_int dist
