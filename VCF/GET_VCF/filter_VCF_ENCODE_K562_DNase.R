system("export PERL5LIB=/home/zeng/Dropbox/kmer/preprocess/vcftools_0.1.11/perl/",intern=T)
maxchr = 22;
for (i in 1:maxchr){
	size = read.table(paste('/mnt/work/zeng/kmer/hg19/chr',i,'.size.txt',sep=''),stringsAsFactors=FALSE,header=FALSE)
	system(paste0('tabix -h ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20110521/ALL.chr',i,'.phase1_release_v3.20101123.snps_indels_svs.genotypes.vcf.gz ',i,':1-',size[1], ' | vcf-subset -c NA18486,NA18498,NA18499,NA18501,  NA18502,NA18504,NA18505,NA18507,NA18508,NA18510,NA18511,NA18516,NA18517,NA18519,NA18520,NA18522,NA18853,NA18856,NA18858,NA18861,NA18870,NA18907,NA18909,NA18912,NA18916,NA19093,NA19098,NA19099,NA19114,NA19116,NA19119,NA19131,NA19137,NA19138,NA19147,NA19152,NA19160,NA19171,NA19190,NA19200,NA19204,NA19207,NA19209,NA19225,NA19257 | bgzip -c > /mnt/work/zeng/kmer/hg19/chr',i,'.vcf.gz &'),intern=T)
}
