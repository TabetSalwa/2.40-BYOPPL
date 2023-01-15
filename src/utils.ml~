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
