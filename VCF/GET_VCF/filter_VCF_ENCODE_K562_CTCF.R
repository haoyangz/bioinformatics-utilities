system("export PERL5LIB=/home/zeng/Dropbox/kmer/preprocess/vcftools_0.1.11/perl/",intern=T)
maxchr = 22;
for (i in 1:maxchr){
	size = read.table(paste('/mnt/work/zeng/kmer/hg19/chr',i,'.size.txt',sep=''),stringsAsFactors=FALSE,header=FALSE)
	system(paste0('tabix -h ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/working/20121009_broad_exome_chip/ALL.wgs.broad_exome_lof_indel_GRCh37_BeadStudio_v3.20130115.snps_and_indels.snpchip.genotypes.vcf.gz ',i,':1-',size[1], ' | vcf-subset -c NA12801,NA12864,NA12865,NA12872,NA12873,NA12874,NA12875,NA12878,NA12891,NA12892 | bgzip -c > /mnt/work/zeng/kmer/hg19/chr',i,'.ctcf.vcf.gz &'),intern=T)
}
