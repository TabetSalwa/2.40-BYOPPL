open Byoppl
open Distributions
open Montecarlo
let _ =
  Format.printf "@.Disk : we estimate the value of pi/4 thanks to an experiment, consisting in letting fall rice grains on a square surface and counting how many of them are in 1/4 of a disk.@."
   
let disk =
  let d = uniform 0. 1. in
  fun () ->
  let x = sample d in
  let y = sample d in
  if x*.x +. y*.y < 1. then 1. else 0.

let _ =
  Format.printf "@.-- Disk, Monte-Carlo simulation with n=1000 --@.";
  let m = ev disk in
  Format.printf "Coin bias, mean: %f@." m
