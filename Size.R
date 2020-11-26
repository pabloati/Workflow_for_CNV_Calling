library(readr)
library(stringr)
#Extraction of data
args=commandArgs(trailingOnly=TRUE)

df<-read_tsv(args[1],col_names=TRUE)
size<-read_tsv(args[2],col_names=TRUE)

Size<-df[,"End"]-df[,"Start"]+1
size[as.integer(args[3]),"Size"]<-mean(Size[[1]])
write_tsv(size,args[2])