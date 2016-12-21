require('IRanges')
require('snow')
source('/cluster/zeng/code/research/tools/GENOME/utility.R')

args = commandArgs(T)

vcfdir = args[1]
klen = as.numeric(args[2])
genomefile = args[3]
offsetfile = args[4]
outfile = args[5]
flank_range = as.numeric(args[6])
twodirec = as.numeric(args[7])

ref_outfile = paste0(outfile,'.ref')
alt_outfile = paste0(outfile,'.alt')
vcf_outfile = paste0(outfile,'.info')
outdir = dirname(outfile)
dir.create(outdir,showWarnings=F,recursive=T)

### Main 
print('Reading and parsing vcf file')
tempvcf = tempfile()
print(vcfdir)
cmd = paste0('cat ',vcfdir,'/*.vcf | awk \'{print $1 \"\\t\" $2 \"\\t\" $2 \"\\t\" $4 \"\\t\" $5 \"\\t\" $2}\' > ',tempvcf)
system(cmd)

peak = read.delim(tempvcf,stringsAsFactors=F,header=F)
system(paste0('rm ',tempvcf))

peak[,1] = as.numeric(peak[,1])
peak = peak[!is.na(peak[,1]),]
peak = peak[order(peak[,1]),]

peak[,2] = floor(peak[,2] - flank_range)
peak[,3] = floor(peak[,3] + flank_range)

write.table(peak,file=vcf_outfile,row.names=F,col.names=F,quote=F,sep="\t")

###
chrs = unique(peak[,1])
win = list()
alt = list()
for (chridx in 1:length(chrs)){
	chr = chrs[chridx]
	pick = peak[,1]==chr
	part = peak[pick,]
	part = part[order(part[,2]),]
	peak[pick,] = part
	win[[chridx]] = IRanges(part[,2],part[,3])
	alt[[chridx]] = part[,5]
}

print('Parallelization initiating')
cl <- makeCluster(10,type='SOCK')
clusterExport(cl, c("chrs","win","alt","genomefile","offsetfile","readRef","translate","klen","hashtable","translateRev","hashtable_rev","untranslate") )
clusterCall(cl,function(){require('IRanges')})

print('Pulling k-mer')
if (twodirec==1){
	out_ref = clusterApplyLB(cl,1:length(chrs),pullKmerTwoDirec)
    out_alt = clusterApplyLB(cl,1:length(chrs),pullKmerVCFtwodirec)
}else{
	out_ref = clusterApplyLB(cl,1:length(chrs),pullKmer)
	out_alt = clusterApplyLB(cl,1:length(chrs),pullKmerVCF)
}
stopCluster(cl)

print('Outputing')
con <- file(ref_outfile,open='w')
for (i in 1:length(out_ref)){
	for (j in 1:length(out_ref[[i]])){
		if (twodirec==1){
			len = length(out_ref[[i]][[j]])
            midpoint = len/2
            writeLines(paste0(out_ref[[i]][[j]][1:midpoint],collapse=' '),con)
            writeLines(paste0(out_ref[[i]][[j]][(midpoint+1):len],collapse=' '),con)
		}else{
			writeLines(paste0(out_ref[[i]][[j]],collapse=' '),con)
		}
	}
}
close(con)

con <- file(alt_outfile,open='w')
for (i in 1:length(out_alt)){
	for (j in 1:length(out_alt[[i]])){
		if (twodirec==1){
			len = length(out_alt[[i]][[j]])
            midpoint = len/2
            writeLines(paste0(out_alt[[i]][[j]][1:midpoint],collapse=' '),con)
            writeLines(paste0(out_alt[[i]][[j]][(midpoint+1):len],collapse=' '),con)
		}else{
			writeLines(paste0(out_alt[[i]][[j]],collapse=' '),con)
		}
	}
}
close(con)
