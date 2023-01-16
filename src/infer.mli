(** {0 Library for inference algorithms }

This library contains three modules for basic discrete models: 
enumeration, rejection sampling and importance sampling.

@author Salwa Tabet Gonzalez (X)
 *)

(** {1 Enumeration}
In this module, we use the logarithms of the probabilities instead of the probabilities, and we call that a score. *)
module Enumeration : sig
  type ('a,'b) model = 'b array -> 'a * float
  (** Type of a model which takes a parameter of type 'a and 
models a distribution with output type 'b, i.e. the goal is to infer the value of the parameter given an array of observations of type 'b *)

  val create_model : 'a Distributions.distrib -> ('a -> 'b Distributions.distrib) -> ('a,'b) model
  (** takes a distribution for the parameter, and a function which associates a distribution to each value of the parameter, outputs the corresponding model *)
    
  exception Continuous_model
  (** raised when trying to create a model from a continuously supported distribution *)

  val sample : 'a Distributions.distrib -> 'a
  (** draws a sample following the distribution*)
    
  val factor : float -> float -> float
  (** updates the score by adding a given value*)

  val assume : float -> bool -> float
  (** updates the score by adding infinity if the given condition is not met*)
    
  val observe : float -> 'a Distributions.distrib -> 'a -> float
  (** takes the score of our scenario (the parameter is 
equal to the given value and the model corresponds to the observations)
, the distribution using the given parameter and a new observation (for
 example, heads or tails for a coin). It computes the new score 
of getting the observations.*)
    
  val infer : ('a -> float) -> ('a,'b) model -> 'b array -> 'a Distributions.distrib
  (** takes a model and an array of observations, and computes, for each possible value of the parameter, the  probability of the parameter being the given value and of the model corresponding to the observations. It corresponds to P(A ∩ B) with :

- A being the event "the parameter is equal to the given value"

- B being the event "the model corresponds to the observations"

and using the definition of conditional probability.
  Then, computes the probability of each scenario ( P(B|A) * P(A)), then sums these to obtain P(B) and uses the Bayes formula to deduce the law of the parameter conditioned by our observations P(A|B).
   The additional argument to_float takes a function that converts elements of type 'a to floats, it is used to create a new distribution with support in 'a and compute its mean and variance.*)
end


     
(** {2 Rejection sampling} *)
module Rejection_sampling : sig
  type ('a,'b) model = 'b array -> 'a
  (** Type of a model which takes a parameter of type 'a and models a distribution with output type 'b *)

  val create_model : 'a Distributions.distrib -> ('a -> 'b Distributions.distrib) -> ('a,'b) model
  (** takes a distribution for the parameter, and a function which associates a distribution to each value of the parameter, outputs the corresponding model *)
    
  exception Reject
  (** raised when a scenario does not satisfy the conditions required by the model*)
          
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


     
(** {3 Importance sampling}
In this module, we use the logarithms of the probabilities instead of the probabilities, and we call that a score.*)
module Importance_sampling : sig
  type ('a,'b) model = 'b array -> 'a * float
  (** Type of a model which takes a parameter of type 'a and 
models a distribution with output type 'b *)
     
  val create_model : 'a Distributions.distrib -> ('a -> 'b Distributions.distrib) -> ('a,'b) model
  (** takes a distribution for the parameter, and a function which associates a distribution to each value of the parameter, outputs the corresponding model *)
    
  val sample : 'a Distributions.distrib -> 'a
  (** draws a sample following the distribution*)
    
  val factor : float -> float -> float
  (** updates the score by adding a given value *)

  val assume : float -> bool -> float
  (** updates the score by adding infinity if the given condition is not met*)
    
  val observe : float -> 'a Distributions.distrib -> 'a -> float
  (** takes the score of our scenario (the parameter is 
equal to the given value and the model corresponds to the observations)
, the distribution using the given parameter and a new observation (for
 example, heads or tails for a coin). It computes the new score 
of getting the observations.*)
    
  val infer : ?n:int -> ('a -> float) -> ('a,'b) model -> 'b array -> 'a Distributions.distrib
  (** takes a model and an array of observations. It draws a random value for the parameter, which is to be inferred. It outputs the probability of the model corresponding to the observations. It corresponds to P(B | A) with :

 - A being the event "the parameter is equal to the given value"

 - B being the event "the model corresponds to the observations"

   Then, computes the probability of each scenario ( P(B|A) * P(A)), then sums these to obtain P(B) and uses the Bayes formula to deduce the law of the parameter conditioned by our observations P(A|B).
   The additional argument to_float takes a function that converts elements of type 'a to floats, it is used to create a new distribution with support in 'a and compute its mean and variance.*)
    
end
