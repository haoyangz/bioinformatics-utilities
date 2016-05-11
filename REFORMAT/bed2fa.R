source('/cluster/zeng/code/research/tools/GENOME/utility.R')
options(scipen = 999)

args = commandArgs(T)
bedfile = args[1]
outfile = args[2]
genomefile = args[3]
offsetfile = args[4]
flank = as.numeric(args[5])
twodirect = args[6]

bed <- read.delim(bedfile,header=F,stringsAsFactors=F)

loci = bed[,1:6]
loci[,1] = as.numeric(sapply(1:nrow(loci),function(i){strsplit(loci[i,1],split='chr')[[1]][2]}))
loci[,2] = loci[,2]+1
loci = loci[!is.na(loci[,1]),]

loci[,2] = floor(loci[,2] - flank)
loci[,3] = floor(loci[,3] + flank)


if (twodirect == '1'){
	fw_pick = rep(T,nrow(loci))
	rv_pick = rep(T,nrow(loci))
}else{
	fw_pick = loci[,6]=='+'
	rv_pick = loci[,6] == '-'
}

loci_fw = loci[fw_pick,]
loci_rv = loci[rv_pick,]
seq = pullSeq(loci_fw,genomefile,offsetfile)
seq_rev = pullSeqRev(loci_rv,genomefile,offsetfile)

con <- file(outfile,open='w')
fw_cnt = 0
rv_cnt = 0
for (i in 1:nrow(loci)){
	if (fw_pick[i]){
		fw_cnt = fw_cnt + 1
   		writeLines(paste0('>chr',loci_fw[fw_cnt,1],':',loci_fw[fw_cnt,2],'-',loci_fw[fw_cnt,3]),con)
		writeLines(seq[fw_cnt,1],con)
	}
	if (rv_pick[i]){
		rv_cnt = rv_cnt + 1
		writeLines(paste0('>Rev:chr',loci_rv[rv_cnt,1],':',loci_rv[rv_cnt,2],'-',loci_rv[rv_cnt,3]),con)
		writeLines(seq_rev[rv_cnt,1],con)
	}
}
close(con)
