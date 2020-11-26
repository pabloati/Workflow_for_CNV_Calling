library("readr")
library(stringr)
#Extraction of data
args=commandArgs(trailingOnly=TRUE)


IDs <- as.data.frame(read_tsv(args[1],skip=0,col_names=TRUE))

Indv <- as.data.frame(read_tsv(args[2],skip=0,col_names=TRUE))
Name <- unlist(strsplit(args[2],"/"))[2] 
IDs[args[3],as.character(Indv[1,"Gene"])]<-0 
#rownames(IDs)[as.integer(args[3])]<- Name 

rownames(Indv) <- Indv[["Gene"]]
for (i in Indv[["Gene"]]){
	if (Indv[i,"Type"] == "Dup"){
		IDs[args[3],i]=1
        }else if (Indv[i,"Type"] == "Del"){
		IDs[args[3],i]=-1
	}
}
IDs[is.na(IDs)]<-0
write_tsv(IDs,args[1],col_names=TRUE)
