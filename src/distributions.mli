(** {0 Module for distribution data structures }

This library contains data structures for basic discrete and continuous distributions.
 *)

(** {1 Types} *)

type 'a prob_law = {support : 'a array; probs : float array}
    (** Type of a discrete law, with a support being an array of type 'a and their linked probabilities in another array of floats *)

type 'a distrib = {
    sample : unit -> 'a;
    pdf : 'a -> float;
    logpdf : 'a -> float;
    mean : float;
    var : float;
    law : 'a prob_law option;
  }
    (** Type of a distribution data structure. Each distribution has :

- a sampling function
- a probability mass or density function
- its corresponding logarithmic probability mass or density function
- an analytical mean value
- an analytical variance value
- a law if the distribution is discrete*)

(** {1 General functions}*)

val draw : 'a distrib -> 'a 
(** yields a sample following the distribution given as argument*)

val stats : 'a distrib -> (float * float)
(** gives the mean and the standard deviation of the distribution given as argument*)

(** {1 Printing functions} *)

val print_discrete : float distrib -> unit
(** prints on the screen the probability for each value of a discrete distribution*)
                            
(** {1 Distributions} *)

(** {2 Discrete distributions}*)
  
val bernoulli : float -> int distrib
(** {b Bernoulli} distribution, taking as argument a certain probability {m p} and yielding
- a sampling function
- its probability mass function with {m \mathbb{P}(0) = 1 - p}  and  {m \mathbb{P}(1) = p}
- its logarithmic probability mass function 
- the mean {m \mathbb{E}(X) = p}
- the variance {m Var(X) = p(1 - p) }
- the law of support {m \{0;1\}} and of probabilities {m \{1-p;p\}} **)

val binomial : float -> int -> int distrib
(** {b Binomial} distribution, taking as arguments a certain probability {m p}, a number of experiments {m n} and yielding
- a sampling function
- its probability mass function with {m \mathbb{P}(X=k) = \binom{n}{k} p^{k} (1-p)^{n-k} }
- its logarithmic probability mass function using the [Owl_stats] dedicated function 
- the mean {m \mathbb{E}(X=k) = np}
- the variance {m Var(X=k) = np \times (1-p)}
- and no law even if discrete because of the possibility of having a very large array *)

val uniform_discr : int -> int -> int distrib
(** {b Uniform} distribution on a discrete support, taking as arguments the bounds {m a} and {m b} and yielding
- a sampling function
- its probability mass function with {m \mathbb{P}(X=x) = \frac{1}{b-a+1}}
- its logaritmic probability mass function
- the mean {m \mathbb{E}(X) = \frac{a+b}{2}}
- the variance {m Var(X)=\frac{(b-a)(b-a+2)}{12}}
- the law of support {m \{a;a+1;...;b-1;b\}} *)

val discrete_support : ('a -> float) -> 'a array -> float array -> 'a distrib

val uniform_support : ('a -> float) -> 'a array -> 'a distrib
  
(** {2 Continuous distributions}*)
  
val uniform : float -> float -> float distrib
(** {b Uniform} distribution, taking as arguments the bounds {m a} and {m b} and yielding
- a sampling function
- its probability density function with {m \mathbb{P}(X=x) = \frac{1}{b-a}}
- its logaritmic probability density function
- the mean {m \mathbb{E}(X) = \frac{a+b}{2}}
- the variance {m Var(X)=\frac{(b-a)^{2}}{12}} *)

val exponential : float -> float distrib
(** The {b Exponential} distribution is the probability distribution of the time between events in a process in which events occur continuously and independently at a constant average rate. This function takes as argument the parameter {m \lambda} and yields
- a sampling function
- its probability density function with {m \mathbb{P}(X=x) = \lambda e^{-\lambda x}} 
- its logarithmic probability density function
- the mean {m \mathbb{E}(X) = \frac{1}{\lambda}}
- the variance {m Var(X) = \frac{1}{\lambda^{2}}}*)  
  
val normal : float -> float -> float distrib
                                     (** {b Normal} distribution, taking as arguments the mean {m \mu} and the standard deviation {m \sigma}, and yielding
- a sampling function using the [Owl_stats] dedicated function
- its probability density function with {m \mathbb{P}(X=x) = \frac{1}{\sigma \sqrt{2 \pi}} e^{- \frac{1}{2} \left(\frac{x-\mu}{\sigma}  \right)^{2} }}
- the mean {m \mathbb{E}(X) = \mu}
- the variance {m Var(X) = \sigma^{2}} *)
