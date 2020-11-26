#!/bin/bash

#Initial setup
source ~/Programs/ROOT/root/bin/thisroot.sh
mkdir FilteredBAM ; mkdir GenesMean ; mkdir CNVs ; mkdir RD_Mappability ; mkdir CNVnator ;mkdir CNVnator_Mappability
C=0

#Filtering bam file accoding to MQ < 30
for i in $(ls BAMfiles/*/*.bam); do
  name=$(echo $i |cut -d "/" -f3 | cut -d "." -f1) ; ID=$(echo $name | cut -d "_" -f1)
  mkdir "FilteredBAM/""$ID"
  samtools view -bq 30 $i > "FilteredBAM/""$ID""/""$name""_30MQ.bam" &
  let C=$C+1; let Ctr=$C%5
  if [[ $Ctr -eq 0 ]]; then
    wait
  fi
done ; wait ; C=0

#Creation of BAM index
for i in $(ls FilteredBAM/*/*.bam); do
  samtools index -b $i &
  let C=$C+1 ; let Ctr=$C%10
  if [[ $Ctr -eq 0 ]]; then
    wait
  fi
done ; wait ; C=0

#Calculating genes mean with bedtools
for i in $(ls FilteredBAM/*/*.bam); do
  name=$(echo $i |cut -d "/" -f3 | cut -d "." -f1 | cut -d "_" -f1)
  mkdir "GenesMean/""$name" ; print $i
  bedtools coverage -a ~/Files/Pablo_Results/Bedfiles/PABLO_Genes/39kGenes_Simple.bed -b $i -mean > "GenesMean/""$name""/""$name""_GenesRD.txt" &   
  let C=$C+1 ; let Ctr=$C%2
  if [[ $Ctr -eq 0 ]]; then
    wait
  fi
done ; wait ; C=0

#Comparison of read depth means and determination of CNVs (Dup=2*GenesMean ; Del= <0.1)
for i in $(ls GenesMean/*/*.txt); do
  name=$(echo $i |cut -d "/" -f2 )
  mkdir "CNVs/""$name"
  Rscript Comparison.R $i 
  grep -v "Normal" $i > "CNVs/""$name""/""$name""_CNVs.txt" &
  let C=$C+1 ; let Ctr=$C%5
  if [[ $Ctr -eq 0 ]]; then
    wait
  fi
done ; wait ; C=0

#Filtering CNVs against low mappability regions
for i in $(ls CNVs/*/*.txt); do
  ID=$(echo $i |cut -d "/" -f2) ; mkdir "RD_Mappability/""$ID"
  python ~/Programs/TCAG-WGS-CNV-workflow/compare_with_RLCR_definition.py ~/Files/Pablo_Results/Bedfiles/Mappability_bedfile.txt "RD_Mappability/""$ID" $i &
  let C=$C+1 ; let Ctr=$C%5
  if [[ $Ctr -eq 0 ]]; then
    wait
  fi  
done ; wait ; C=0

for i in $(ls RD_Mappability/*/*.RLCR) ; do
  Rscript Analysis.R $i &
  let C=$C+1 ; let Ctr=$C%5
  if [[ $Ctr -eq 0 ]]; then
    wait
  fi
done ; wait ; C=0

#CNVnator CNVcalling
# Step1: extracting read mapping from bam/sam files
for i in $(ls BAMfiles/*/*.bam); do
  name=$(echo $i | cut -d "/" -f3 | cut -d "." -f1 | cut -d "_" -f1) ;  ID=$(echo $i | cut -d "/" -f2)
  mkdir "CNVnator/""$ID"
  ~/Programs/CNVnator/cnvnator -root "CNVnator/""$ID""/""$name"".root" -tree $i &
  let C=$C+1 ; let Ctr=$C%5
  if [[ $Ctr -eq 0 ]]; then
    wait
  fi
done ; wait ; C=0

# Step2: generate a histogram
for i in $(ls CNVnator/*/*root); do
  ~/Programs/CNVnator/cnvnator -root $i -his 1000 -d /data/home/ge97xak/Maize_RefGen/EricDNA/PABLO/Splitted/ &
  let C=$C+1 ; let Ctr=$C%5
  if [[ $Ctr -eq 0 ]]; then
    wait
  fi
done ; wait ; C=0 
# Step3: calculating statistics
for i in $(ls CNVnator/*/*root); do   
  ~/Programs/CNVnator/cnvnator -root $i -stat 1000 &
  let C=$C+1 ; let Ctr=$C%5
  if [[ $Ctr -eq 0 ]]; then
    wait
  fi
done ; wait ; C=0
# Step4: ReadDepth signal partitioning
for i in $(ls CNVnator/*/*root); do   
  ~/Programs/CNVnator/cnvnator -root $i -partition 1000 &
  let C=$C+1 ; let Ctr=$C%5
  if [[ $Ctr -eq 0 ]]; then
    wait
  fi
done ; wait ; C=0
# Step5: CNV calling
for i in $(ls CNVnator/*/*root); do 
  name=$(echo $i | cut -d "/" -f 3 | cut -d "." -f 1); ID=$(echo $i | cut -d "/" -f2)
  ~/Programs/CNVnator/cnvnator -root $i -call 1000 > "CNVnator/""$ID""/""$name""_CNVnator.cnv" &
  let C=$C+1 ; let Ctr=$C%5
  if [[ $Ctr -eq 0 ]]; then
    wait
  fi
done ; wait ; C=0

#Step6: Filtering CNVs with q0<0.5
for i in $(ls CNVnator/*/*_CNVnator.cnv); do
  name=$(echo $i | cut -d "/" -f 3 | cut -d '_' -f 1,3)
  Rscript q0Filter.R $i
  let C=$C+1 ; let Ctr=$C%5
  if [[ $Ctr -eq 0 ]]; then
    wait
  fi
done

#Conversion of .cnvfile to common format 
for i in $(ls CNVnator/*/*_q0.cnv); do 
  name=$(echo $i | cut -d "/" -f 3 | cut -d '_' -f 1,3) ; ID=$(echo $i | cut -d "/" -f2)
  python ~/Programs/TCAG-WGS-CNV-workflow/convert_CNV_calls_to_common_format.py $i CNVnator > "CNVnator/""$ID""/""$name""_CNVnator.txt" &
  let C=$C+1 ; let Ctr=$C%5
  if [[ $Ctr -eq 0 ]]; then
    wait
  fi
done ; wait ; C=0

#Filtering CNVs against low mappability regions
for i in $(ls CNVnator/*/*.txt); do
  ID=$(echo $i |cut -d "/" -f2); mkdir "CNVnator_Mappability/""$ID"
  python ~/Programs/TCAG-WGS-CNV-workflow/compare_with_RLCR_definition.py ~/Files/Pablo_Results/Bedfiles/Mappability_bedfile.txt "CNVnator_Mappability/""$ID" $i &
  let C=$C+1 ; let Ctr=$C%5
  if [[ $Ctr -eq 0 ]]; then
    wait
  fi
done ; wait ; C=0

for i in $(ls CNVnator_Mappability/*/*.RLCR); do 
  Rscript Analysis.R $i &
  let C=$C+1 ; let Ctr=$C%5
  if [[ $Ctr -eq 0 ]]; then
    wait
  fi
done ; wait ; C=0