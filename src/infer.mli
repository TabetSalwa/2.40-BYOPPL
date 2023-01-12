(** {0 Library for inference algorithms }

This library contains three modules for basic discrete models: 
enumeration, rejection sampling and importance sampling.

@author Salwa Tabet Gonzalez (X)
 *)

(** {1 Enumeration} *)
module Enumeration : sig
  type ('a,'b) model = 'b array -> 'a * float
  (** Type of a model which takes a parameter of type 'a and 
models a distribution with output type 'b *)

  val create_model : 'a Distributions.distrib -> ('a -> 'b Distributions.distrib) -> ('a,'b) model
  
  exception Continuous_model
          
  val sample : 'a Distributions.distrib -> 'a
  (** draws a sample following the distribution*)
    
  val factor : float -> float -> float
  (** updates the probability by multiplying a probability by 
a score*)

  val assume : float -> bool -> float
    
  val observe : float -> 'a Distributions.distrib -> 'a -> float
  (** takes the probability of our scenario (the parameter is 
equal to the given value and the model corresponds to the observations)
, the distribution using the given parameter and a new observation (for
 example, heads or tails for a coin). It computes the new probability 
of getting the observations.*)
    
  (** takes a model, an array of observations and a value for the parameter of the model to be inferred. It outputs the probability of the parameter being the given value and of the model corresponding to the observations. It corresponds to P(A ∩ B) with :
\n- A being the event "the parameter is equal to the given value"
\n- B being the event "the model corresponds to the observations"
and using the definition of conditional probability *)
    
  val infer : ('a -> float) -> ('a,'b) model -> 'b array -> 'a Distributions.distrib
  (** computes the probability of each scenario ( P(B|A) * P(A)), then sums these to obtain P(B) and uses the Bayes formula to deduce the law of the parameter conditioned by our observations P(A|B).*)
    
end


     
(** {2 Rejection sampling} *)
module Rejection_sampling : sig
  type ('a,'b) model = 'b array -> 'a
  (** Type of a model which takes a parameter of type 'a and models a distribution with output type 'b *)

  val create_model : 'a Distributions.distrib -> ('a -> 'b Distributions.distrib) -> ('a,'b) model
    
  exception Reject
          
  val sample : 'a Distributions.distrib -> 'a
  (** draws a sample following the distribution*)
    
  val assume : bool -> unit
  (** takes as argument a condition and rejects the scenario if the condition is not met*)
    
  val observe : 'a Distributions.distrib -> 'a -> unit
  (** takes a distribution and a single observed value, if the observation is not equal to the sample it rejects the sample.*)
    
  val exec : ('a,'b) model -> 'b array -> 'a
  (** takes a model and an array of observations. It creates scenarios until the model matches the observations. *)
    
  val infer : ?n:int -> ('a -> float) -> ('a,'b) model -> 'b array -> 'a Distributions.distrib
  (** samples n values of the parameter using the exec function and outputs the distribution of said parameter.*)
    
end


     
(** {3 Importance sampling} *)
module Importance_sampling : sig
  type ('a,'b) model = 'b array -> 'a * float
  (** Type of a model which takes a parameter of type 'a and 
models a distribution with output type 'b *)
     
  val create_model : 'a Distributions.distrib -> ('a -> 'b Distributions.distrib) -> ('a,'b) model
    
  val sample : 'a Distributions.distrib -> 'a
  (** draws a sample following the distribution*)
    
  val factor : float -> float -> float
  (** updates the probability by multiplying a probability by 
a score*)

  val assume : float -> bool -> float
    
  val observe : float -> 'a Distributions.distrib -> 'a -> float
  (** takes the probability of our scenario (the parameter is 
equal to the given value and the model corresponds to the observations)
, the distribution using the given parameter and a new observation (for
 example, heads or tails for a coin). It computes the new probability 
of getting the observations.*)
    
  (** takes a model and an array of observations. It draws a random value for the parameter, which is to be inferred. It outputs the probability of the parameter being the given value and of the model corresponding to the observations. It corresponds to P(A ∩ B) with :
\n- A being the event "the parameter is equal to the given value"
\n- B being the event "the model corresponds to the observations"
and using the definition of conditional probability *)
    
  val infer : ?n:int -> ('a -> float) -> ('a,'b) model -> 'b array -> 'a Distributions.distrib
  (** computes the probability of each scenario ( P(B|A) * P(A)), then sums these to obtain P(B) and uses the Bayes formula to deduce the law of the parameter conditioned by our observations P(A|B).*)
    
end
