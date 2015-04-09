system("export PERL5LIB=/cluster/zeng/code/research/kmer/software/vcftools_0.1.12b/perl/",intern=T)
sizedir = '/cluster/zeng/research/kmer/mm10/seq_data/';
outputdir = '/cluster/zeng/research/kmer/mm10/mgp_Hbg3_SNP/';
for (i in 16:19){
	size = read.table(paste(sizedir,'/chr',i,'.size.txt',sep=''),stringsAsFactors=FALSE,header=FALSE)
	system(paste0('tabix -h ftp://ftp-mouse.sanger.ac.uk/current_snps/mgp.v4.snps.dbSNP.vcf.gz ',i,':1-',size[1], ' | vcf-subset -c C57BL_6NJ,CBA_J | bgzip -c > ',outputdir,'/chr',i,'.vcf.gz &'),intern=T)
}
