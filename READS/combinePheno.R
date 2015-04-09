args = commandArgs(T)
phenodir = args[1]
indivfile = args[2]
chr = as.numeric(args[3])
outdir = args[4]

indiv = read.table(indivfile,stringsAsFactors=F)
indiv = indiv[,1]

	for ( idx in 1:length(indiv)){
		file = paste0(phenodir,'/',indiv[idx],'/chr',chr,'.pheno')
		tmp = read.delim(file,stringsAsFactors=F)
		if (idx==1){
			data = tmp
		}else{
			data = cbind(data,tmp[,2])
		}
	}
	colnames(data) = c('POS',indiv);
	outfile = paste0(outdir,'/chr',chr,'.combPheno')
	write.table(data,file=outfile,sep="\t",quote=F,row.names=F,col.names=T)
