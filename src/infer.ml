open Distributions

   
module Enumeration = struct

  type ('a,'b) model = 'b array -> 'a * float

  exception Continuous_model
  
  let sample d = Distributions.draw d
  let factor score s = score +. s 
  let assume score c = factor score (if c then 0. else infinity)
  let observe prob d v =
    factor prob (-. (d.Distributions.logpdf v))

  let create_model parameter distribution =
    match parameter.law with
    |Some l ->
      let i = ref 0 in
      fun data ->
      let p = l.support.(!i) in
      let d = distribution p in
      let score = Array.fold_left (fun score -> observe score d) (l.probs.(!i)) data in
      let () = i := !i+1 in
      (p,score)
    |None -> raise Continuous_model

  let infer to_float _model data =
    let values = ref [] in
    let logprobs = ref [] in
    let values,logprobs =
      try
        while true do
          let (p,score) = _model data in
          values := p::(!values);
          logprobs := score::(!logprobs)
        done;
        [||],[||]
      with Invalid_argument _ -> Array.of_list (List.rev !values), Array.of_list (List.rev !logprobs)
    in
    discrete_support to_float values (Utils.normalize_log logprobs)
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
  let factor score s = score +. s
  let assume score c = factor score (if c then 0. else infinity) 
  let observe score d v = factor score (-. (d.Distributions.logpdf v))

  let create_model parameter distribution data =
    let p = sample parameter in
    let d = distribution p in
    let score = Array.fold_left (fun score -> observe score d) 0. data in
    p,score
    
  let infer ?(n=1000) to_float _model data =
    let a = Array.init n (fun _ -> _model data) in
    let support = Array.init n (fun i -> fst (Array.get a i)) in
    let logprobs = Array.init n (fun i -> snd (Array.get a i)) in
    Distributions.discrete_support to_float support (Utils.normalize_log logprobs)
end
