library(biomaRt)
#source('/cluster/zeng/code/research/tools/REFORMAT/SNPID2bed/mapSNPID2coord_params.R');

#snpidfile = '/cluster/zeng/research/kmer/hg19/FINAL.ver140827/NFKB-BSNP/B-SNP_numid';
#headers_bool=FALSE;
#outfile = '/cluster/zeng/research/kmer/hg19/FINAL.ver140827/NFKB-BSNP/B-SNP_rsid';
#append_rs = TRUE;

args = commandArgs(T)
snpidfile = args[1]
outfile = args[2]
headers_bool = args[3]==T
append_rs = args[4]==T


snp_ids = read.delim(snpidfile,stringsAsFactors=FALSE,header=headers_bool)
if (append_rs){
for( i in 1:nrow(snp_ids)){
	snp_ids[i,1] = paste0('rs',snp_ids[i,1]);
}
}
snp_ids = snp_ids[,1]

snp_mart = useMart("ENSEMBL_MART_SNP", dataset="hsapiens_snp",host='feb2014.archive.ensembl.org')
attributes = listAttributes(snp_mart)
snp_attributes = c("refsnp_id", "chr_name", "chrom_start","allele","allele_1","minor_allele")
snp_locations = getBM(attributes=snp_attributes, filters="snp_filter", values=snp_ids, mart=snp_mart)

output = data.frame(matrix(nrow=nrow(snp_locations),ncol=6));
output[,1] = snp_locations[,2]
output[,2] = snp_locations[,3]-1
output[,3] = snp_locations[,3]
output[,4] = snp_locations[,1]
output[,5] = snp_locations[,4];
output[,6] = '+';

pick = !is.na(as.numeric(output[,1]))
output = output[pick,]
chrs = unique(output[,1])
num_chrs = as.numeric(chrs)
num_chrs_sort = sort(num_chrs);

output_s = output;
cnt = 0;
for( i in 1:length(num_chrs)){
	thisnumchr = num_chrs_sort[i]
	thischr = chrs[num_chrs==thisnumchr]
	pick = output[,1]==thischr
	part = output[pick,]
	orders = order(as.numeric(part[,2]));
	output_s[(cnt+1):(cnt+sum(pick)),1] = rep(paste0('chr',thischr));
	output_s[(cnt+1):(cnt+sum(pick)),2:6] = part[orders,2:6]
	cnt = cnt + sum(pick)
}
	
write.table(output_s,file=outfile,col.names=FALSE,row.names=FALSE,quote=FALSE,sep='\t')
