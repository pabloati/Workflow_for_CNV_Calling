#!/bin/bash

C=0
#Trimming with Trimmomatic-0.39
for i in $(ls FastaFiles/*/*_R1_001.fastq.gz); do
  name=$(echo $i | cut -d "_" -f 2,3,4) ; ID=$(echo $i | cut -d "/" -f 2) ; Sample=$(echo $i | cut -d "/" -f 3| cut -d "_" -f1)
  mkdir "Trimmed/""$ID"
  java -jar ~/Programs/Trimmomatic-0.39/trimmomatic-0.39.jar PE -threads 10 -phred33 "FastaFiles/""$ID""/""$Sample""_""$name""_R1_001.fastq.gz" "FastaFiles/""$ID""/""$Sample""_""$name""_R2_001.fastq.gz" "Trimmed/""$ID""/""$ID""_""$name""_paired_R1_001.fastq.gz" "Trimmed/""$ID""/""$ID""_""$name""_unpaired_R1_001.fastq.gz" "Trimmed/""$ID""/""$ID""_""$name""_paired_R2_001.fastq.gz" "Trimmed/""$ID""/""$ID""_""$name""_unpaired_R2_001.fastq.gz" LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36 &
  let C=$C+1 ; let Ctr=$C%5
  if [[ $Ctr -eq 0 ]]; then
    wait
  fi  
done ; wait ; C=0

#Aligning Paried End reads (PE) to reference genome using BWA mem. (The genome must be indexed prior to the aligment)
for i in $(ls Trimmed/*/*_paired_R1_001.fastq.gz); do  
  name=$(echo $i | cut -d "_" -f 1,2,3,4,5) ; ID=$(echo $i | cut -d "/" -f 2); newname=$(echo $i | cut -d "/" -f3 | cut -d "_" -f 1,4)
  mkdir "Alignment/""$ID"
  bwa mem -t 10 -M -R '@RG\tID:NRGENE\tSM:'"$ID"'\tPL:PE\tLB:no\tPU:unit1' ~/Maize_RefGen/NormalDNA/Zea_mays.AGPv4.dna.toplevel.fa "$name""_R1_001.fastq.gz" "$name""_R2_001.fastq.gz" | samtools view -bS - > "Alignment/""$ID""/""$newname""_B7v4_PE.bam" &
  let C=$C+1 ; let Ctr=$C%5
  if [[ $Ctr -eq 0 ]]; then
    wait
  fi    
done ; wait ; C=0
  
#Aligning Single End Reads (SE) to reference genome using BWA mem. (The genome must be indexed prior to the aligment)
for i in $(ls Trimmed/*/*_unpaired_*); do
  name=$(echo $i |  cut -d "_" -f 1,2,3,4,5) ; ID=$(echo $i | cut -d "/" -f2) ; R=$(echo $i | cut -d "/" -f3 |  cut -d "_" -f 6) ; newname=$(echo $i | cut -d "/" -f3 | cut -d "_" -f 1,4)
  bwa mem -t 10 -M -R '@RG\tID:NRGENE\tSM:'"$ID"'\tPL:PE\tLB:no\tPU:unit1' ~/Maize_RefGen/NormalDNA/Zea_mays.AGPv4.dna.toplevel.fa "$name""_""$R""_001.fastq.gz" | samtools view -bS - > "Alignment/""$ID""/""$newname""_""$R""_B73v4_SE.bam" &
  let C=$C+1 ; let Ctr=$C%5
  if [[ $Ctr -eq 0 ]]; then
    wait
  fi  
done ; wait ; C=0
 
#Sort files and convert to bam files PE using Picard Tools
for i in $(ls Alignment/*/*PE.bam); do
  name=$(echo $i | cut -d "/" -f 3 | cut -d "_" -f 1,2,3) ;  ID=$(echo $i | cut -d "/" -f2)
  java -Xmx20g -XX:ParallelGCThreads=10 -jar ~/Programs/PicardTools/picard.jar SortSam MAX_RECORDS_IN_RAM=2000000 INPUT=$i OUTPUT="Alignment/""$ID""/""$name""_PE_sorted.bam" SORT_ORDER=coordinate &
  let C=$C+1 ; let Ctr=$C%5
  if [[ $Ctr -eq 0 ]]; then
    wait
  fi  
done ; wait ; C=0
  
#Sorting sam file and converting to bam with Picard (SE)
for i in $(ls Alignment/*/*SE.bam); do
  name=$(echo $i | cut -d "/" -f 3 | cut -d "_" -f 1,2,3,4) ;  ID=$(echo $i | cut -d "/" -f2)
  java -Xmx20g -XX:ParallelGCThreads=10 -jar ~/Programs/PicardTools/picard.jar SortSam MAX_RECORDS_IN_RAM=2000000 INPUT=$i OUTPUT="Alignment/""$ID""/""$name""_SE_sorted.bam" SORT_ORDER=coordinate &
  let C=$C+1 ; let Ctr=$C%5
  if [[ $Ctr -eq 0 ]]; then
    wait
  fi  
done ; wait ; C=0
  
#Merging data using samtools

for i in $(ls Alignment/*/*_sorted.bam) ; do
  ID=$(echo $i | cut -d "/" -f 2)
  ls $i >> "Alignment/""$ID""/""$ID"".txt" &
  let C=$C+1 ; let Ctr=$C%4
  if [[ $Ctr -eq 0 ]]; then
    wait
  fi  
done ; wait ; C=0

for i in $(ls Alignment/*/*.txt); do
  nombre=$(echo $i | cut -d "/" -f2)
  ~/Programs/samtools-1.9/samtools merge "Alignment/""$nombre""/""$nombre""_merged.bam" -b $i &
  let C=$C+1 ; let Ctr=$C%4
  if [[ $Ctr -eq 0 ]]; then
    wait
  fi    
done ; wait ; C=0
  
#Remove duplicates using picard tools
for i in $(ls Alignment/*/*_merged.bam); do
  name=$(echo $i | cut -d "/" -f2)
  java -Xmx200g -XX:ParallelGCThreads=10 -Djava.io.tmpdir=/scratch/ -jar ~/Programs/PicardTools/picard.jar MarkDuplicates INPUT=$i OUTPUT="Alignment/""$name""/""$name""_dedup.bam" REMOVE_DUPLICATES=true METRICS_FILE="Alignment/""$name""/""$name""_metrics.txt" &
  let C=$C+1 ; let Ctr=$C%4
  if [[ $Ctr -eq 0 ]]; then
    wait
  fi  
done ; wait ; C=0

#Create index using picard tools
for i in $(ls Alignment/*/*_dedup.bam); do
  name=$(echo $i | cut -d"/" -f3 | cut -d "." -f 1); ID=$(echo $i | cut -d "/" -f2)
  java -Xmx200g -XX:ParallelGCThreads=10 -jar -Djava.io.tmpdir=/scratch/ ~/Programs/PicardTools/picard.jar BuildBamIndex INPUT=$i OUTPUT="Alignment/""$ID""/""$name"".bai" &
  let C=$C+1 ; let Ctr=$C%4
  if [[ $Ctr -eq 0 ]]; then
    wait
  fi  
done ; wait ; C=0
  
#Indel realignment using GATK
for i in $(ls Alignment/*/*_dedup.bam); do
  name=$(echo $i | cut -d "/" -f3 |  cut -d "." -f 1); ID=$(echo $i | cut -d "/" -f2)
  java1.8 -Xmx200g -jar ~/Programs/GenomeAnalysisTK.jar -T RealignerTargetCreator -R ~/Maize_RefGen/NormalDNA/Zea_mays.AGPv4.dna.toplevel.fa -I $i -o "Alignment/""$ID""/""$name""-forIndelRealigner.intervals" &
  let Ctr=$C%4
  if [[ $Ctr -eq 0 ]]; then
    wait
  fi    
done ; wait ; C=0
for i in $(ls Alignment/*/*forIndelRealigner.intervals); do
  name=$(echo $i | cut -d "/" -f3 | cut -d "-" -f 1) ; ID=$(echo $i | cut -d "/" -f2)
  mkdir "BAMfiles/""$ID" 
  java1.8 -Xmx200g -jar ~/Programs/GenomeAnalysisTK.jar -T IndelRealigner -R ~/Maize_RefGen/NormalDNA/Zea_mays.AGPv4.dna.toplevel.fa -I "Alignment/""$ID""/""$name"".bam"  -targetIntervals $i -o "BAMfiles/""$ID""/""$name""_indelrealigned.bam" &
  let C=$C+1 ; let Ctr=$C%4
  if [[ $Ctr -eq 0 ]]; then
    wait
  fi  
done ; wait ; C=0
