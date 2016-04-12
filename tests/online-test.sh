#!/bin/bash
cd ../
N_ITERS=100
for i in $(seq 1 $N_ITERS)
do
  echo "Iteración $i"
  octave --silent online.m
done
