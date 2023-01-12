(*open Random*)
(*open Owl
open Owl_stats*)
open Utils

exception Invalid_prob of float
exception Invalid_value of float

type 'a prob_law = {  
    support : 'a array;
    probs : float array;
  }

type 'a distrib = {
    sample : unit -> 'a;
    pdf : 'a -> float;
    mean : float;
    var : float;
    law : 'a prob_law option;
  }
             
let draw distrib = distrib.sample ()

let stats distrib = distrib.mean,Float.sqrt (distrib.var)


let print_discrete distrib =
  match distrib.law with
  |Some l ->
    let n = Array.length l.support in
    for i=0 to n-1 do
      Printf.printf "Value : %f - Probability : %f\n" l.support.(i) l.probs.(i)
    done
  |None -> raise (Invalid_argument "Continuous distribution")
                  
let bernoulli (p: float) : int distrib =
  if not (p <= 1. && 0. <= p) then raise (Invalid_prob p)
  else let sample ()  = 
         let x = Random.float 1.0 in
         if x < p then 1 else 0 in
       let pdf x = match x with
         |0 -> 1. -. p
         |1 -> p
         |_ -> 0. in
       let mean = p in
       let var = p *. (1. -. p) in
       let law =
         Some {
             support = [| 0; 1 |];
             probs = [| 1. -. p ; p |];
           } in
       {
         sample = sample;
         pdf = pdf;
         mean = mean;
         var = var;
         law = law;
       }
      
let binomial (p: float) (n: int) : int distrib =
  if not (p <= 1. && 0. <= p) then raise (Invalid_prob p)
  else
    let sample () =
      let k = ref 0 in
      for _ = 1 to n do
        let x = Random.float 1.0 in
        if x < p then k := !k + 1
      done;
      !k in
    let pdf k =
      float_of_int (Owl_maths.combination n k) *. (( p ** (float_of_int k)) *. ((1. -. p) ** (float_of_int (n - k)))) in
    
    let mean = (float_of_int n) *. p in
    let var = (float_of_int n) *. p *. (1. -. p) in
    let law = None in
    {
      sample = sample;
      pdf = pdf;
      mean = mean;
      var = var;
      law = law;
    }

let uniform (a: float) (b: float) : float distrib =
  if b<=a then raise (Invalid_value b)
  else
    let sample () =
      (Random.float (b -. a)) +. a in
    let pdf x =
      if (x<=b && a<=x) then (1. /. (b -. a)) else 0. in
    let mean = (a +. b /. 2.) in
    let var = ((b -. a) ** 2.) /. 12. in
    let law = None in
    {
      sample = sample;
      pdf = pdf;
      mean = mean;
      var = var;
      law = law;
    }

let uniform_discr (a: int) (b: int) : int distrib =
  if b<a then raise (Invalid_value (float_of_int b))
  else
    let sample () =
      (Random.int (b-a+1)) + a in
    let pdf x =
      if x<=b && a<=x then 1./.(float_of_int (b-a+1)) else 0. in
    let mean = (float_of_int (a+b)) /. 2. in
    let var = (float_of_int ((b-a)*(b-a+2))) /. 12. in
    let law = Some
                {support = Array.init (b-a+1) (fun i -> a+i);
                 probs = Array.make (b-a+1) (1. /. (float_of_int (b-a+1)));}
    in
    {
      sample = sample;
      pdf = pdf;
      mean = mean;
      var = var;
      law = law;
    }

let discrete_support to_float (values : 'a array) (probs : float array) : 'a distrib =
  let values,probs = Utils.agglomerate values probs in
  let n = Array.length values in
  let cumul_probs = Array.make n probs.(0) in
  for i=1 to n-1 do
    cumul_probs.(i) <- cumul_probs.(i-1) +. probs.(i)
  done;
  let sample () =
    let x = Random.float 1. in
    let i = ref 0 in
    while !i<n-1 && cumul_probs.(!i) < x do
      i := !i + 1
    done;
    values.(!i) in
  let pdf x =
    let s = ref 0. in
    for i=0 to n-1 do
      if values.(i) = x then s := !s +. probs.(i)
    done;
    !s in
  let mean =
    let s = ref 0. in
    for i=0 to n-1 do
      s := !s +. (to_float (values.(i))) *. probs.(i)
    done;
    !s in
  let var =
    let s = ref 0. in
    for i=0 to n-1 do
      s := !s +. (to_float (values.(i))) *. (to_float (values.(i))) *. probs.(i)
    done;
    !s -. (mean *. mean) in
  let law = Some
              {
                support = values;
                probs = probs
              }
  in
  {
    sample = sample;
    pdf = pdf;
    mean = mean;
    var = var;
    law = law;
  }

let uniform_support to_float (values : 'a array) : 'a distrib =
  let n = Array.length values in
  let probs = Array.make n (1./.(float_of_int n)) in
  discrete_support to_float values probs
  
let exponential (lambda: float) : float distrib =
  let sample () =
    let p = Random.float 1. in
    (-1. /. lambda) *. (Float.log (1. -. p)) in
  let pdf x = lambda *. Float.exp (-. lambda *. x) in
  let mean = 1. /. lambda in
  let var = 1. /. (lambda *. lambda) in
  let law = None in
  {
    sample = sample;
    pdf = pdf;
    mean = mean;
    var = var;
    law = law;
  }
  

  
let normal (m: float) (s: float) : 'a distrib =
  if s < 0. then raise (Invalid_value s)
  else
    let sample () = Owl_stats.gaussian_rvs ~mu:m ~sigma:s in
    let const = 1. /. (s *. Float.sqrt (2. *. Float.pi)) in
    let pdf x = const *. Float.exp (- 0.5 *. (((x -. m) /. s) ** 2.)) in
    let mean = m in
    let var = s ** 2. in
    let law = None in
    {
      sample = sample;
      pdf = pdf;
      mean = mean;
      var = var;
      law = law;
    }


 



    
  
(*let () = Random.init 15;
  let d = normal 0. 1. in
         for i = 1 to 10 do
           print_int (draw d);
           print_newline ()
         done;
           print_float (d.pdf 2)*)
