#!/bin/bash

for i in $(ls CNVnator_Mappability/PE*/PE*70_filtered.txt); do 
  name=$(echo $i | cut -d "/" -f3| cut -d "." -f1)
  ID=$(echo $i | cut -d "/" -f2)
  cat $i | cut -f1,2,3| grep -v "Start" > "CNVnator_Mappability/""$ID""/""$name"".bed" &
done ; wait

mkdir CNVnator-RD_Overlap

for i in $(ls RD_Mappability/PE*/PE*70_filtered.txt); do
  ID=$(echo $i | cut -d "/" -f3| cut -d "_" -f 1) ;mkdir "CNVnator-RD_Overlap/""$ID"
  Per=$(echo $i | cut -d "/" -f3| cut -d "_" -f 4) 
  more $i | cut -f1,2,3,4,5,6,7 > "RD_Mappability/""$ID""/""$ID""_RD_Mappability_""$Per""_cutted.txt"
  python ~/Programs/TCAG-WGS-CNV-workflow/compare_with_RLCR_definition.py "/home/ge97xak/Files/Pablo_Results/BatchTrials/CNVnator_Mappability/""$ID""/""$ID""_CNVnator_Mappability_""$Per""_filtered.bed" "CNVnator-RD_Overlap/""$ID" "RD_Mappability/""$ID""/""$ID""_RD_Mappability_""$Per""_cutted.txt"  
  mv "CNVnator-RD_Overlap/""$ID""/""$ID""_RD_Mappability_CNVnator-RD_Overlap.RLCR" "CNVnator-RD_Overlap/""$ID""/""$ID""_RD_""$Per""_Mappability_CNVnator-RD_Overlap.RLCR"
  rm "RD_Mappability/""$ID""/""$ID""_RD_Mappability_""$Per""_cutted.txt" &
done ; wait

for i in $(ls CNVnator-RD_Overlap/PE*/PE*.RLCR); do
  Rscript Ovlp_Analysis.R $i &
done ; wait

 
