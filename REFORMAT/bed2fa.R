source('/cluster/zeng/code/research/tools/GENOME/utility.R')

args = commandArgs(T)
bedfile = args[1]
outfile = args[2]
genomefile = args[3]
offsetfile = args[4]
flank = as.numeric(args[5])
twodirec = args[6]

bed <- read.delim(bedfile,header=F,stringsAsFactors=F)

loci = bed[,1:3]
loci[,1] = as.numeric(sapply(1:nrow(loci),function(i){strsplit(loci[i,1],split='chr')[[1]][2]}))
loci[,2] = loci[,2]+1
loci = loci[!is.na(loci[,1]),]

loci[,2] = floor(loci[,2] - flank)
loci[,3] = floor(loci[,3] + flank)

seq = pullSeq(loci,genomefile,offsetfile)
if (twodirec == '1'){
	seq_rev = pullSeqRev(loci,genomefile,offsetfile)
}

con <- file(outfile,open='w')
for (i in 1:nrow(seq)){
	writeLines(paste0('>chr',loci[i,1],':',loci[i,2],'-',loci[i,3]),con)
	writeLines(seq[i,1],con)
	if (twodirec == '1'){
		writeLines(paste0('>Rev:chr',loci[i,1],':',loci[i,2],'-',loci[i,3]),con)
		writeLines(seq_rev[i,1],con)
	}
}
close(con)
