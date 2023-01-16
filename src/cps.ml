open Distributions
open Utils

module Enumeration = struct

  type 'a future = {cont : 'a prob -> 'a prob ; prob : float}
  and 'a prob = {values : 'a list ; probs : float list ; futures : 'a future Queue.t}
  type ('a,'b) model = ('a prob -> 'a prob) -> 'a prob -> 'b -> 'a prob

  exception Continuous_model
  let curr_prob = ref 1.

  let run_next _prob =
    try
      let f = Queue.pop _prob.futures in
      let () = curr_prob := f.prob in
      f.cont _prob
    with Queue.Empty -> _prob

  let sample cont _prob d =
    match d.law with
      |Some l ->
        let () = Array.iter2 (fun value prob -> Queue.push {cont = (fun _prob -> cont _prob value) ; prob = !curr_prob *. prob} _prob.futures) l.support l.probs in
        run_next _prob
      |None -> raise Continuous_model

  let factor cont _prob p =
    let () = curr_prob := !curr_prob *. p in
    cont _prob

  let assume cont _prob c =
    factor cont _prob (if c then 1. else 0.)

  let observe cont _prob d v =
    factor cont _prob (d.pdf v)

  let exit _prob v =
    let values = v::_prob.values in
    let probs = !curr_prob::_prob.probs in
    run_next {values = values ; probs = probs ; futures = _prob.futures}

  let model cont _prob _data =
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

  let infer to_float model data =
    let () = curr_prob := 1. in
    let _prob = {values = [] ; probs = [] ; futures = Queue.create ()} in
    let _prob = model exit _prob data in
    discrete_support to_float (Array.of_list _prob.values) (Array.of_list _prob.probs)
end
