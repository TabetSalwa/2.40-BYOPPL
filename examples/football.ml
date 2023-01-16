open Byoppl
open Distributions


let () = Format.printf  "Simple football is a two-team game in which each team scores a number of goals following a Poisson distribution, and the team that scores the most goals wins. The parameter of the Poisson law is the form of the team, and itself follows a normal distribution, of mean the strength of the team, and with standard deviation 1. Knowing the strengths of the two teams, we want to infer the form of the first team, given that they won the match.@."


open Cps.Rejection_sampling

let football cont _prob (str1,str2) =
  sample
    (fun _prob form1 ->
      sample
        (fun _prob form2 ->
          sample
            (fun _prob goals1 ->
              sample
                (fun _prob goals2 ->
                  assume
                    (fun _prob -> cont _prob form1)
                    _prob
                    (goals1 > goals2)
                )
                _prob
                (poisson (Float.max form2 0.))
            )
            _prob
            (poisson (Float.max form1 0.))
        )
        _prob
        (normal str2 1.)
     )
     _prob
     (normal str1 1.)

let () =
  Format.printf "@.-- Simple football, CPS Rejection Sampling --@.";
  let dist = infer (fun x -> x) football (2.,2.) in
  let m, s = Distributions.stats dist in
  Format.printf "Form, mean: %f std:%f@." m s


open Cps.Importance_sampling

let football cont _prob (str1,str2) =
  sample
    (fun _prob form1 ->
      sample
        (fun _prob form2 ->
          sample
            (fun _prob goals1 ->
              sample
                (fun _prob goals2 ->
                  assume
                    (fun _prob -> cont _prob form1)
                    _prob
                    (goals1 > goals2)
                )
                _prob
                (poisson (Float.max form2 0.))
            )
            _prob
            (poisson (Float.max form1 0.))
        )
        _prob
        (normal str2 1.)
     )
     _prob
     (normal str1 1.)

let () =
  Format.printf "@.-- Simple football, CPS Importance Sampling --@.";
  let dist = infer (fun x -> x) football (2.,2.) in
  let m, s = Distributions.stats dist in
  Format.printf "Form, mean: %f std:%f@." m s
