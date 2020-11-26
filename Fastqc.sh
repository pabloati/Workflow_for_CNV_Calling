#!/bin/bash


for i in $(ls FastaFiles/KE01*/*.fastq.gz); do
ID=$( echo $i | cut -d "/" -f2); mkdir "fastqc/""$ID"
fastqc -o "fastqc/""$ID" $i &
done ; wait

for i in $(ls FastaFiles/KE0[26]*/*.fastq.gz); do
ID=$( echo $i | cut -d "/" -f2); mkdir "fastqc/""$ID"
fastqc -o "fastqc/""$ID" $i &
done ; wait

for i in $(ls FastaFiles/KE04*/*.fastq.gz); do
ID=$( echo $i | cut -d "/" -f2); mkdir "fastqc/""$ID"
fastqc -o "fastqc/""$ID" $i &
done ; wait

for i in $(ls FastaFiles/PE01*/*.fastq.gz); do
ID=$( echo $i | cut -d "/" -f2); mkdir "fastqc/""$ID"
fastqc -o "fastqc/""$ID" $i &
done ; wait

for i in $(ls FastaFiles/PE02*/*.fastq.gz); do
ID=$( echo $i | cut -d "/" -f2); mkdir "fastqc/""$ID"
fastqc -o "fastqc/""$ID" $i &
done ; wait

for i in $(ls FastaFiles/PE03*/*.fastq.gz); do
ID=$( echo $i | cut -d "/" -f2); mkdir "fastqc/""$ID"
fastqc -o "fastqc/""$ID" $i &
done ; wait

for i in $(ls FastaFiles/PE04*/*.fastq.gz); do
ID=$( echo $i | cut -d "/" -f2); mkdir "fastqc/""$ID"
fastqc -o "fastqc/""$ID" $i &
done ; wait

for i in $(ls FastaFiles/PE06*/*.fastq.gz); do
ID=$( echo $i | cut -d "/" -f2); mkdir "fastqc/""$ID"
fastqc -o "fastqc/""$ID" $i &
done ; wait

for i in $(ls FastaFiles/PE00*/*.fastq.gz); do
ID=$( echo $i | cut -d "/" -f2); mkdir "fastqc/""$ID"
fastqc -o "fastqc/""$ID" $i 
done
