require('IRanges')
require('snow')
source('/cluster/zeng/code/research/tools/GENOME/utility.R')

args = commandArgs(T)

peakfile = args[1]
klen = as.numeric(args[2])
genomefile = args[3]
offsetfile = args[4]
outfile = args[5]
flank_range = as.numeric(args[6])
kmer_nonoverlap = as.numeric(args[7])
twodirec = as.numeric(args[8])
centerflank = args[9]

### Main 
print('Reading and parsing peak file')
peak = read.delim(peakfile,stringsAsFactors=F,header=F)

peak[,1] = as.numeric(sapply(1:nrow(peak),function(x){strsplit(peak[x,1],'chr')[[1]][2]}))
peak = peak[!is.na(peak[,1]),]
peak = peak[order(peak[,1]),]

#flank_range = floor(mean(peak[,3]-peak[,2])/2)
if (centerflank=='1'){
if (flank_range >0){
	mid = floor((peak[,2] + 1 + peak[,3])/2)
	peak[,2] = floor(mid - flank_range)
	peak[,3] = floor(mid + flank_range)
}
}else{
	peak[,2] = floor(peak[,2] + 1 - flank_range)  ## Because bedfile are 0-based
	peak[,3] = floor(peak[,3] + flank_range)
}

chrs = unique(peak[,1])
win = list()
for (chridx in 1:length(chrs)){
	chr = chrs[chridx]
	pick = peak[,1]==chr
	part = peak[pick,]
	part = part[order(part[,2]),]
	peak[pick,] = part
	win[[chridx]] = IRanges(part[,2],part[,3])
}

print('Parallelization initiating')
cl <- makeCluster(10,type='SOCK')
clusterExport(cl, c("chrs","win","genomefile","offsetfile","readRef","translate","klen","hashtable","translateRev","hashtable_rev") )
clusterCall(cl,function(){require('IRanges')})

print('Pulling k-mer')
if (kmer_nonoverlap==1){
	if (twodirec == 1){
		out = clusterApplyLB(cl,1:length(chrs),pullKmerNonOverlapTwoDirec)
	}else{
		out = clusterApplyLB(cl,1:length(chrs),pullKmerNonOverlap)
	}
}else{
	if (twodirec==1){
		out = clusterApplyLB(cl,1:length(chrs),pullKmerTwoDirec)
	}else{
		out = clusterApplyLB(cl,1:length(chrs),pullKmer)
	}
}
stopCluster(cl)

print('Outputing')
con <- file(outfile,open='w')
for (i in 1:length(out)){
	for (j in 1:length(out[[i]])){
		if (twodirec==1){
			len = length(out[[i]][[j]])
			midpoint = len/2
			writeLines(paste0(out[[i]][[j]][1:midpoint],collapse=' '),con)
			writeLines(paste0(out[[i]][[j]][(midpoint+1):len],collapse=' '),con)
		}else{
		writeLines(paste0(out[[i]][[j]],collapse=' '),con)
		}
	}
	
}
close(con)

