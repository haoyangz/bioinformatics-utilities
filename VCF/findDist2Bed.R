source('findHeader.R')
library('IRanges')
args = commandArgs(T)
vcfdir = args[1]
bedfile = args[2]
outdir = args[3]

dir.create(outdir,showWarnings=F,recursive=T)

vcffiles = list.files(path=vcfdir,pattern='\\.vcf$')
bed = read.delim(bedfile,header=F,stringsAsFactors=F)
tmp = tempfile()
for (file in vcffiles){
	print(paste0('processing: ',file))
	t_file = file.path(vcfdir,file)
	header = findHeader(t_file)
	cmd = paste0('tail -n+',1+header,' ',t_file,' | awk \'{print $2}\' > ',tmp)
	system(cmd)
	t_data = read.delim(tmp,header=F)
	
	t_chr = strsplit(file,'.vcf')[[1]][1]
	t_bed = bed[bed[,1]==t_chr,]

	variants = IRanges(start=t_data[,1],width=1)
	beds = IRanges(start = t_bed[,2]+1,end=t_bed[,3])
	
	print('Calculate distance2nearest')
	dist = distanceToNearest(variants,beds)@elementMetadata
	t_outfile = file.path(outdir,paste0(file,'.dist'))
	write.table(dist,file=t_outfile,quote=F,row.names=F,col.names=F,sep="\t")
}
system(paste0('rm ',tmp))
