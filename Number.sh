#!/bin/bash

for i in $(ls RD_Mappability/KE*/*70_filtered.txt); do
  wc -l $i >> KE_Total_Number.txt
  grep "Dup" $i | wc -l >> KE_Dup_Number.txt
  grep "Del" $i | wc -l >> KE_Del_Number.txt
  cat $i >> KE_CNVs.txt
done

cat KE_CNVs.txt |cut -f 1,2,3,4,7 | sort | uniq > KE_Common_CNVs.txt

