# 2.40-BYOPPL

Build Your Own Probabilistic Programming Language project for MPRI course 2.40 - Probabilistic Programming Languages).

## Install

After cloning the repo, you can then test your installation with a simple:
```
git clone
cd byo-ppl
dune build
```

## Organization

The `Byoppl` library contains the following modules

- `Distributions`: Library of probability distributions and basic statistical functions.
- `Infer`: Basic inference with enumeration, rejection sampling and importance sampling on discrete and continuous models.
- `CPS` (TODO): Inference on Continuation Passing Style (CPS) models.
- `Cps_operators`: Syntactic sugar to write CPS style probabilistic models.
- `Utils`: Missing utilities functions used in other modules.

Examples can be found in the `examples` directory. To try them, you can use the following syntax :

```
dune exec ./examples/coin.exe
```
