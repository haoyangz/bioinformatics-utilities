setwd('/cluster/zeng/research/kmer/hg19/FINAL.ver140827/SNP_data/NFKB')
dir1='ALL_ASB_SNP_AF001_1KG/';
#dir1='rand60_ASB_SNP_AF001_1KG';
dir2='1KG_sample60_wo_ALL_ASB_SNP_AF001_1KG/'
outdir ='1KG_sample60_plus_ALL_ASB_SNP_AF001_1KG/'
#outdir ='1KG_sample1000_plus_ALL_ASB_SNP_AF001_1KG/'

dir1 = paste0(dir1,'/');
dir2 = paste0(dir2,'/');
outdir = paste0(outdir,'/');
dir.create(file.path(outdir),showWarnings=F)

list1 = list.files(dir1,pattern='\\.vcf$')
list2 = list.files(dir2,pattern='\\.vcf$')
listall = unique(c(list1,list2))
for (i in 1:length(listall)){
	file1 = paste0(dir1,listall[i])
	file2 = paste0(dir2,listall[i])
	line1 = 0
	line2 = 0
	outfile = paste0(outdir,listall[i])

	if (file.exists(file1)){
		line1 =as.numeric(strsplit(system(paste0('wc ',file1,' -l'),intern=T),split=' ')[[1]])
	}
	if (file.exists(file2)){
    	line2 =as.numeric(strsplit(system(paste0('wc ',file2,' -l'),intern=T),split=' ')[[1]])
    }
	if (line1>0 && line2 > 0){
		d1 <- read.delim(paste0(dir1,listall[i]),stringsAsFactors=F,header=F)
		d2 <- read.delim(paste0(dir2,listall[i]),stringsAsFactors=F,header=F)
		col= min(ncol(d1),ncol(d2));
		d1 = d1[,1:col]
		d2 = d2[,1:col]
		
		if (length(which(d1[,4]==TRUE))>0)
			d1[,4]=rep('T')
		if (length(which(d1[,5]==TRUE))>0)	
	    	d1[,5]=rep('T')
		if (length(which(d2[,4]==TRUE))>0)
        	d2[,4]=rep('T')
		if (length(which(d2[,5]==TRUE))>0)
        	d2[,5]=rep('T')
		
		d = rbind(d1,d2)
		d = d[order(as.numeric(d[,2])),]
		write.table(d,file=outfile,quote=F,row.names=F,col.names=F,sep="\t")
	}else{
		if (line1>0 && line2==0){
			system(paste0('cp ',file1,' ',outfile))
		}else{
			if (line1==0 && line2 > 0){
				system(paste0('cp ',file2,' ',outfile))
			}
		}
	}
}

