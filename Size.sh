#!/bin/bash

n=1
for i in $(ls RD_Mappability/*/*70_filtered.txt); do
  Rscript Size.R $i Sizes.txt $n
  let n=$n+1
done 