library("readr")
library(stringr)
#Extraction of data
args=commandArgs(trailingOnly=TRUE)


Data <- read_tsv(args[1],skip=, col_names=FALSE)
NData=Data[Data[["X9"]]<0.5,]

Name <- str_replace(args[1],".cnv","_q0.cnv") 
write_tsv(NData,Name,col_names=FALSE)