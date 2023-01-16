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

  let observe_array =
    let rec observe_array_rec cont _prob d a id =
      let cont' =
        if id+1 >= Array.length a
        then cont
        else fun _prob -> observe_array_rec cont _prob d a (id+1)
      in observe cont' _prob d a.(id)
    in fun cont _prob d a -> observe_array_rec cont _prob d a 0

  let exit _prob v =
    let values = v::_prob.values in
    let probs = !curr_prob::_prob.probs in
    run_next {values = values ; probs = probs ; futures = _prob.futures}

  let infer to_float model data =
    let () = curr_prob := 1. in
    let _prob = {values = [] ; probs = [] ; futures = Queue.create ()} in
    let _prob = model exit _prob data in
    discrete_support to_float (Array.of_list _prob.values) (normalize (Array.of_list _prob.probs))
end


module Rejection_sampling = struct

  type prob = Prob
  type ('a,'b) model = (prob -> 'a option) -> prob -> 'b -> 'a option

  let sample cont _prob d =
    let a = draw d in
    cont _prob a

  let assume cont _prob c =
    if c then cont _prob else None

  let observe cont _prob d v =
    sample
      (fun _prob a ->
        assume
          cont
          _prob
          (a = v))
      _prob
      d

  let exit _prob v =
    Some v

  let observe_array =
    let rec observe_array_rec cont _prob d a id =
      let cont' =
        if id+1 >= Array.length a
        then cont
        else fun _prob -> observe_array_rec cont _prob d a (id+1)
      in observe cont' _prob d a.(id)
    in fun cont _prob d a -> observe_array_rec cont _prob d a 0

  let rec exec model data =
    match model exit Prob data with
    |Some v -> v
    |None -> exec model data

  let infer ?(n=1000) to_float model data =
    let values = Array.init n (fun _ -> exec model data) in
    uniform_support to_float values
end


module Importance_sampling = struct

  type ('a,'b) model = (float -> float) -> float -> 'b -> 'a * float

  let sample cont _prob d =
    let a = draw d in
    cont _prob a

  let factor cont _prob p =
    cont (_prob *. p)

  let assume cont _prob c =
    factor cont _prob (if c then 1. else 0.)

  let observe cont _prob d v =
    factor cont _prob (d.pdf v)

  let observe_array =
    let rec observe_array_rec cont _prob d a id =
      let cont' =
        if id+1 >= Array.length a
        then cont
        else fun _prob -> observe_array_rec cont _prob d a (id+1)
      in observe cont' _prob d a.(id)
    in fun cont _prob d a -> observe_array_rec cont _prob d a 0

  let exit _prob v =
    (v,_prob)

  let infer ?(n=1000) to_float model data =
    let values,probs = Array.split (Array.init n (fun _ -> model exit 1. data)) in
    discrete_support to_float values (normalize probs)
end
