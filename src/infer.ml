open Distributions
open Owl_maths

   
module Enumeration = struct

  type ('a,'b) model = 'b array -> 'a * float

  exception Continuous_model
  
  let sample d = Distributions.draw d

  let factor prob s = prob *. s 

  let assume prob c = factor prob (if c then 1. else 0.)
                    
  let observe prob d v =
    factor prob (d.Distributions.pdf v)

  let create_model parameter distribution =
    match parameter.law with
    |Some l ->
      let i = ref 0 in
      fun data ->
      let p = l.support.(!i) in
      let d = distribution p in
      let prob = Array.fold_left (fun prob -> observe prob d) (l.probs.(!i)) data in
      let () = i := !i+1 in
      (p,prob)
    |None -> raise Continuous_model

  let infer to_float _model data =
    let values = ref [] in
    let probs = ref [] in
    let values,probs =
      try
        while true do
          let (p,prob) = _model data in
          values := p::(!values);
          probs := prob::(!probs)
        done;
        [||],[||]
      with Invalid_argument _ -> Array.of_list (List.rev !values), Array.of_list (List.rev !probs)
    in
    let sum = Array.fold_left (fun s p -> s +. p) 0. probs in
    let probs = Array.map (fun p -> p /. sum) probs in
    discrete_support to_float values probs
end
   
module Rejection_sampling = struct

  type ('a,'b) model = 'b array -> 'a
      
  exception Reject
  let sample d = Distributions.draw d

  let assume c = if not c then raise Reject

  let observe d v  = 
    let y = sample d in
    assume (y = v)

  let create_model parameter distribution data =
    let p = sample parameter in
    let d = distribution p in
    let () = Array.iter (observe d) data in
    p

  let rec exec _model data =
    try
      _model data
    with Reject -> exec _model data
    
  let infer ?(n=1000) to_float _model _data =
    let values = Array.init n (fun _ -> exec _model _data) in
    Distributions.uniform_support to_float values
end

                          

module Importance_sampling = struct
  
  type ('a,'b) model = 'b array -> 'a * float
    
  let sample d = Distributions.draw d
  let factor prob s = prob -. (log s)
  let assume prob c = factor prob (if c then 1. else 0.) 
  let observe prob d v = factor prob (d.Distributions.pdf v)

  let create_model parameter distribution data =
    let p = sample parameter in
    let d = distribution p in
    let prob = Array.fold_left (fun prob -> observe prob d) 1. data in
    p,prob
    
  let infer ?(n=1000) to_float _model data =
    let a = Array.init n (fun _ -> _model data) in
    let support = Array.init n (fun i -> fst (Array.get a i)) in
    let probas = Array.init n (fun i -> snd (Array.get a i)) in
    let sum = Array.fold_left (fun s p -> s +. p) 0. probas in
    for i=0 to n-1 do
      probas.(i) <- probas.(i) /. sum
    done;
    Distributions.discrete_support to_float support probas
end
