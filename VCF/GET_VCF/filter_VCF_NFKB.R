system("export PERL5LIB=/home/zeng/Dropbox/kmer/preprocess/vcftools_0.1.11/perl/",intern=T)
maxchr = 22;
for (i in 1:maxchr){
	size = read.table(paste('/mnt/work/zeng/kmer/hg19/chr',i,'.size.txt',sep=''),stringsAsFactors=FALSE,header=FALSE)
	system(paste0('tabix -h ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20110521/ALL.chr',i,'.phase1_release_v3.20101123.snps_indels_svs.genotypes.vcf.gz ',i,':1-',size[1], ' | vcf-subset -c NA10847,NA18505,NA18526,NA18951,NA19099 | bgzip -c > /mnt/work/zeng/kmer/hg19/chr',i,'.nfkb.vcf.gz &'),intern=T)
}
