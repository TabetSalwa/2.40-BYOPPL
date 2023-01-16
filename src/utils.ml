module Array = struct
  include Array

  let fold_left2 f x a1 a2 =
    let u = ref x in
    let n = Array.length a1 in
    for i=0 to n-1 do
      u := f !u a1.(i) a2.(i)
    done;
    !u
end                  

let rec add_value v p values probs =
  match values,probs with
  |v'::t,p'::u ->
    if v'=v then values,(p+.p')::u else
      let values',probs' = add_value v p t u in
      v'::values',p'::probs'
  |[],[] -> [v],[p]
  |_ -> raise (Invalid_argument "Index out of bounds")
  
      
let agglomerate values probs =
  let values,probs = Array.fold_left2 (fun (l1,l2) v p -> add_value v p l1 l2) ([],[]) values probs in
  Array.of_list values,Array.of_list probs

let normalize probs =
  let sum = Array.fold_left (fun s p -> s +. p) 0. probs in
  Array.map (fun p -> p /. sum) probs

let normalize_log logprobs =
  let n = Array.length logprobs in
  let logmean = ref 0. in
  let nb_cool = ref 0 in
  for i=0 to n-1 do
    if logprobs.(i) <> infinity then
      (nb_cool := !nb_cool + 1;
       logmean := !logmean +. logprobs.(i))
  done;
  logmean := !logmean /. (float_of_int !nb_cool);
  let probs = Array.map (fun x -> Owl_maths.exp (!logmean -. x)) logprobs in
  let sum = Array.fold_left (fun s p -> s +. p) 0. probs in
  Array.map (fun p -> p /. sum) probs
