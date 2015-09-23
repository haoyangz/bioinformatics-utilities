args <- commandArgs(T)

infile = args[1]
outfile = args[2]
flank = as.numeric(args[3])

mat <- read.delim(infile,header=F,stringsAsFactors=F)
mid = floor((mat[,3] + mat[,2] + 1)/2)
out = mat
out[,3] = floor(mid + flank)
out[,2] = floor(mid - flank)-1

write.table(out,file=outfile,quote=F,row.names=F,col.names=F,sep="\t")
