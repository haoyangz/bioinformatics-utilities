
br <- read.table('/cluster/zeng/research/kmer/hg19/FINAL.ver140827/NFKB/NFKBQTL/NFKB_quantile_normalized_matrix_of_replicates_between_individuals.txt.hg19.bed',stringsAsFactors=F)
snp = read.table('/cluster/zeng/research/kmer/hg19/FINAL.ver140827/AlleleSeqData/NFKB/MOTIF_ASB_from_rsnp_strap_haplo_from_ALL_ASB_AF001_1KG_JASPAR_TRANSFAC.bed',stringsAsFactors=FALSE)
#snp = read.table('/cluster/zeng/research/kmer/hg19/FINAL.ver140827/AlleleSeqData/NFKB/all_ASB_hg19.rsid_1KG20110521_MAF001.bed',stringsAsFactors=FALSE)
pick = c()
for (i in 1:nrow(br)){
	for (j in 1:nrow(snp)){
		if (snp[j,3]>br[i,2] && snp[j,3]<=br[i,3] && snp[j,1]==br[i,1]){
			pick = c(pick,i);
			break
		}
	}
}
out = br[pick,]

num_chr = c()
for (i in 1:nrow(out)){
	split = strsplit(out[i,1],'chr')[[1]]
	num_chr = c(num_chr,as.numeric(split[2]))
}

out = out[order(num_chr),]

uni_chr = unique(num_chr);

for (i in 1:length(uni_chr)){
	pick = out[,1] == paste0('chr',uni_chr[i])
	part = out[pick,]
	out[pick,] = part[order(as.numeric(part[,2])),]
}

#write.table(out,file='/cluster/zeng/research/kmer/hg19/FINAL.ver140827/NFKB/NFKBQTL/NFKB_quantile_normalized_matrix_of_replicates_between_individuals.txt.hg19.ALL_ASB_AF001_1KG_IN.bed',quote=F,row.names=F,col.names=F,sep='\t')
write.table(out,file='/cluster/zeng/research/kmer/hg19/FINAL.ver140827/NFKB/NFKBQTL/NFKB_quantile_normalized_matrix_of_replicates_between_individuals.txt.hg19.MOTIF_ASB_IN.bed',quote=F,row.names=F,col.names=F,sep='\t')
