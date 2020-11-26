#!/bin/bash

Rscript Table_creator.R ~/Files/Pablo_Results/Bedfiles/PABLO_Genes/39kGenes_IDs.txt
n=0
for i in $(ls RD_Mappability/*/*70_filtered.txt); do
  n=$n+1
  Rscript Table_modifier.R Genes_data.txt $i $n 
done

Rscript Final_row.R Genes_data.txt