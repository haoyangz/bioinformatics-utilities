source('/cluster/zeng/code/research/tools//GENOME/readRef.R')
source('/cluster/zeng/code/research/tools/GENOME/utility.R')
pullSeq <- function(loci,geomefile,offsetfile){
	uni_chr = unique(loci[,1])
	seq = matrix(nrow=nrow(loci),ncol=1)
	for (chridx in 1:length(uni_chr)){
		chr = uni_chr[chridx]
		ref <- readRef(genomefile,offsetfile,chr)
		pick = which(loci[,1]==chr)
		part = loci[pick,]
		for (row in 1:nrow(part)){
			left = part[row,2]
			right = part[row,3]
			seq[pick[row],1] = translate(ref[left:right])
		}
	}
	return(seq)
}


args = commandArgs(T)
bedfile = args[1]
outfile = args[2]
genomefile = args[3]
offsetfile = args[4]

bed <- read.delim(bedfile,header=F,stringsAsFactors=F)

loci = bed[,1:3]
loci[,1] = as.numeric(sapply(1:nrow(loci),function(i){strsplit(loci[i,1],split='chr')[[1]][2]}))
loci[,2] = loci[,2]+1
loci = loci[!is.na(loci[,1]),]

seq = pullSeq(loci,genomefile,offsetfile)

con <- file(outfile,open='w')
for (i in 1:nrow(seq)){
	writeLines(paste0('>chr',loci[i,1],':',loci[i,2],'-',loci[i,3]),con)
	writeLines(seq[i,1],con)
}
close(con)
