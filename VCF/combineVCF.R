setwd('/cluster/zeng/research/kmer/hg19/FINAL.ver140827/SNP_data/CTCF')
dir1='MOTIF_rand60_ASB_SNP/';
#dir1='rand60_ASB_SNP_AF001_1KG';
dir2='1KG_sample1000_wo_rand60_ASB_SNP_AF001_1KG/'
outdir ='1KG_sample1000_plus_MOTIF_rand60_ASB_SNP/'
#outdir ='1KG_sample1000_plus_ALL_ASB_SNP_AF001_1KG/'

dir1 = paste0(dir1,'/');
dir2 = paste0(dir2,'/');
outdir = paste0(outdir,'/');
dir.create(file.path(outdir),showWarnings=F)

list2 = list.files(dir2,pattern='\\.vcf$')
for (i in 1:length(list2)){
	if (file.exists(paste0(dir1,list2[i]))){
		d1 <- read.delim(paste0(dir1,list2[i]),stringsAsFactors=F,header=F)
		d2 <- read.delim(paste0(dir2,list2[i]),stringsAsFactors=F,header=F)
		col= min(ncol(d1),ncol(d2));
		d1 = d1[,1:col]
		d2 = d2[,1:col]
		
		if (length(which(d1[,4]==TRUE))>0)
			d1[,4]=rep('T')
		if (length(which(d1[,5]==TRUE))>0)	
	    	d1[,5]=rep('T')
		if (length(which(d2[,4]==TRUE))>0)
        	d1[,4]=rep('T')
		if (length(which(d2[,5]==TRUE))>0)
        	d1[,5]=rep('T')

		
		d = rbind(d1,d2)
		d = d[order(as.numeric(d[,2])),]
		write.table(d,file=paste0(outdir,list2[i]),quote=F,row.names=F,col.names=F,sep="\t")
	}else{
		system(paste0('cp ',paste0(dir2,list2[i]),' ',paste0(outdir,list2[i])))
	}
}

