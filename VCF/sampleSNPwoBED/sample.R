args = commandArgs(T)
VCFdir = args[1]
bedfile = args[2]
samplenum = as.numeric(args[3])
outdir = args[4]

sampleN<- function(vcfdir,num,outdir){

	sampletmp = tempfile()
    alltmp = tempfile()

	files <- list.files(vcfdir,pattern = "\\.vcf$")
	filenum = length(files)

	cmd = 'cat '
	for (i in 1:filenum){
		cmd = paste0(cmd,vcfdir,'/',files[i],' ')
	}
	cmd = paste0(cmd,' > ',alltmp)
	system(cmd)

	system(paste0('shuf ',alltmp,' -n ',num,' | sort -n -k 2 -s | sort -n -k 1 -s > ',sampletmp))

	dir.create(outdir, showWarnings = FALSE)
	system(paste0('awk -F \"\t\" \'{print $0 >> (\"',outdir,'/chr\" $1 \".vcf\")}\' ',sampletmp))
	system(paste0('rm ',sampletmp))
	system(paste0('rm ',alltmp))
}

if (file.exists(bedfile)){
	bedsize = as.numeric(strsplit(system(paste0('wc ',bedfile,' -l'),intern=T),split=' ')[[1]][1])
	s_num = samplenum + bedsize
}else{
	if (bedfile=='NA'){
		print('No bedfile specified')
		s_num = samplenum
	}else{
		print('Can not open bedfile, exit')
		quit("no",1,F)
	}
}

re=dir.create(outdir, showWarnings = FALSE,recursive=T)
if (!re){
	print('Outdir exists! Will empty it')
	system(paste0('rm -r ',outdir))
	dir.create(outdir, showWarnings = FALSE)
}

print(paste0('sample ',s_num,' from ',VCFdir))
a = tempfile()
sample1rd = paste0(tempfile(),'a')
sample2rd = paste0(tempfile(),'a')
excluded = paste0(tempdir(),'a')

sampleN(VCFdir,s_num,sample1rd)

if (bedfile != 'NA'){
	print('Exclude variants in bedfile')
	cmd = paste('Rscript /cluster/zeng/code/research/tools/VCF/excludeSNPbyBED/excludeSNPbyBED.R ',sample1rd,bedfile,0,excluded,sep=' ')
	system(cmd)

	print('Sample again')
	sampleN(excluded,samplenum,sample2rd)
	system(paste('cp -r', paste0(sample2rd,'/*'),outdir,sep=' '))
	system(paste0('rm -r ',excluded))
	system(paste0('rm -r ',sample2rd))
}else{
	system(paste('cp -r ',paste0(sample1rd,'/*'),outdir,sep=' '))
}

system(paste0('rm -r ',sample1rd))


