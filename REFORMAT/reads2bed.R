library(plyr)
library(snow)
args = commandArgs(T)
mydir = args[1]
barcode = args[2]
maxchr = as.numeric(args[3])
outdir = args[4]
chr_parser = args[5]

files = list.files(mydir)
files = files[grepl(barcode,files)]

#cl = makeCluster(2);
myfunc <- function(chr){
	data = data.frame()
	for (fidx in 1:length(files)){
		subfiles = list.files(paste0(mydir,'/',files[fidx],'/'))
		subfiles = subfiles[grepl(paste0('chr',chr,chr_parser),subfiles)]
		if (length(subfiles)>1){
			subfiles = subfiles[grepl('tpx',subfiles)]
		}
		myfile =  paste0(mydir,'/',files[fidx],'/',subfiles);
		tmp = read.delim(myfile,header=F,stringsAsFactors=F)
		data = rbind(data,tmp)
	}
	colnames(data) = c('NAME','POS','ANNO')
	stat = count(data,'POS');
	out = data.frame(matrix(nrow=nrow(stat),ncol=6))
	out[,1] = rep(paste0('chr',chr))
	out[,2] = stat[,1]-1
	out[,3] = stat[,1]
	out[,4] = rep('NA')
	out[,5] = stat[,2]
	out[,6] = rep('+')
	outfile = paste0(outdir,'/chr',chr,'.bed')
	write.table(out,file=outfile,sep="\t",quote=F,row.names=F,col.names=F)
}

for ( chr in 1:maxchr)
	myfunc(chr)
#clusterExport(cl,c('mydir','files','outdir','chr_parser'))
#clusterCall(cl,function(){require('plyr')})
#clusterApplyLB(cl,1:maxchr,myfunc)
#stopCluster(cl)
