library("readr")
library(stringr)
#Extraction of data
args=commandArgs(trailingOnly=TRUE)

df<-as.data.frame(read_tsv(args[1],col_names=TRUE))
df[44:46,1]<-0 ; df[is.na(df)]<-0
print("Starting")

for (i in colnames(df)){
  df[42,i]<-sum(abs(df[[i]]))
  df[43,i]<-sum(abs(df[1:14,i]))
  df[44,i]<-sum(abs(df[15:43,i]))
}

write_tsv(df,"./Final_table.txt",col_names=TRUE)

