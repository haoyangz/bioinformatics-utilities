source('sampleSNP.R')
bedfile <- '/cluster/zeng/research/kmer/hg19/FINAL.ver140827/BCRANK/USF1_curated_sorted_hg19.bed';
#bedfile <- '/cluster/zeng/research/kmer/hg19/FINAL.ver140827/AlleleSeqData/NFKB/all_ASB_hg19.rsid_1KG20110521_MAF001.bed';
#bedfile <- '/cluster/zeng/research/kmer/hg19/FINAL.ver140827/AlleleSeqData/NFKB/MOTIF_ASB_from_rsnp_strap_haplo_from_ALL_ASB_AF001_1KG_JASPAR_TRANSFAC.bed';
snpdir <- '/cluster/zeng/research/kmer/hg19/FINAL.ver140827/SNP_data/NFKB/NFKB_MODULE_SNP/'
outdir <- '/cluster/zeng/research/kmer/hg19/FINAL.ver140827/SNP_data/USF1/1KG_sample1000_wo_BRANK_AF001_1KG/'
#outdir <- '/cluster/zeng/research/kmer/hg19/FINAL.ver140827/SNP_data/NFKB/1KG_sample400_wo_MOTIF_ASB_SNP/'
num = 1000
maf = 0.01
vt = 'SNP'
flank = 0;

samplingdir = paste0(outdir,'/tmp/');
cleaningdir = paste0(outdir,'/tmp2/');
dir.create(file.path(outdir),showWarnings=F,recursive = TRUE)
dir.create(file.path(samplingdir),showWarnings=F,recursive = TRUE)
dir.create(file.path(cleaningdir),showWarnings=F,recursive = TRUE)

#### Readin Bed file
if (nchar(bedfile)==0){
	bedsize= 0 ;
}else{
	bed <- read.delim(bedfile,header=F,stringsAsFactors=F)
	bedsize = nrow(bed)
}
num = num + bedsize


### Filter the SNPs on MAF and VT, and sample from it
sampleSNP(snpdir,samplingdir,num,maf,vt,T)

#### Get rid of the SNPs specified in the BED file
if (bedsize>0){
	files <-  list.files(samplingdir,pattern = "\\.vcf$")

	for (i in 1:length(files)){
		split = strsplit(files[i],'.vcf')[[1]]
		print(paste0('Filtering out SNPs specified in BED file for ',files[i]))
		
		pick = which(bed[,1]==split[1])
		if (length(pick)>0){
			part = bed[pick,]
			part = part[order(as.numeric(part[,2])),]
		}else{
			part = c()
		}
		tmpfile = paste0('tmp')
		write.table(part,file=tmpfile,sep="\t",quote=F,row.names=F,col.names=F)
		
		snpfile = paste0(samplingdir,files[i])
		outfile = paste0(cleaningdir,files[i])
		if (file.exists(outfile)){
			system(paste0('rm ',outfile))
		}
		cmd = paste0('python subsetSNPwoBED.py ',snpfile,' ',tmpfile,' ',flank,' >> ',outfile)
		system(cmd)
		system(paste0('rm ',tmpfile))
	}


	sampleSNP(cleaningdir,outdir,num-bedsize,maf,vt,F)
}

system(paste0('rm -r ',samplingdir))
system(paste0('rm -r ',cleaningdir))


