
sampleSNP <- function(snpdir,outdir,num,maf,vt,filter){

outdir = paste0(outdir,'/')
snpdir = paste0(snpdir,'/')
filterdir = paste0(outdir,'filtered/');
dir.create(file.path(outdir),showWarnings=F)
dir.create(file.path(filterdir),showWarnings=F)

if (snpdir==outdir){
	error('Cant output to the same input dir')
}

files <- list.files(snpdir,pattern = "\\.vcf$")
filenum = length(files) 

#### Filter the file on MAF and VT
if (filter){
for (i in 1:filenum){
	print(paste0('Filtering ',files[i]))
	outfile = paste0(filterdir,files[i])
	
	if (file.exists(outfile)){
		system(paste0('rm ',outfile))
	}
	cmd = paste0('python filterSNP.py ',paste0(snpdir,files[i]),' ',maf,' ',vt,' >> ',outfile)
	system(cmd)
	#system(paste0('rm ',tmpfile))
}
}else{
	system(paste0('rm -r ',filterdir))
	filterdir = snpdir
}

#### Determine the size of each of the vcf file

header <- rep(0,filenum)
fsize  <- rep(0,filenum)
agg <- rep(0,filenum+1)

for (i in 1:filenum){
	con  <- file(paste0(filterdir,files[i]), open = "r")
	while (length(oneLine <- readLines(con, n = 1, warn = FALSE)) > 0) {
		if (substring(oneLine,1,1)=='#'){
			header[i] = header[i] + 1
		}else{
			break
		}
	}
	close(con)
	wc = system(paste0('wc -l ',filterdir,files[i]),intern=T)
	split = strsplit(wc,' ')[[1]]
	fsize[i] = as.numeric(split[1])

	if (header[i]>0){
		print(paste0(files[i],' has header ',header[i],' lines'))
	}
}

datasize <- fsize - header
for (i in 1:filenum){
	agg[i+1] = agg[i]+datasize[i]
}

#### Permutation
perm = sample.int(sum(datasize),size=num)

permmat = matrix(perm,nrow=num,ncol=filenum)
aggmat = t(matrix(agg[1:filenum],ncol=num,nrow=filenum))

offset = permmat - aggmat


#### Get the samples
for (i in 1:filenum){
	print(paste0('Sampling from ',files[i]))
	if (i==filenum){
		pick = offset[,i]>0
	}else{
		pick = offset[,i]*offset[,i+1] <=0 & offset[,i]!=0
	}
	samples = sort(offset[pick,i] + header[i])
	tmpfile = paste0('tmp',i)
	write.table(samples,file=tmpfile,sep="\t",quote=F,row.names=F,col.names=F)
	
	outfile = paste0(outdir,files[i])
	if (file.exists(outfile)){
		system(paste0('rm ',outfile))
	}

	cmd = paste0('python sampleSNP.py ',paste0(filterdir,files[i]),' ',tmpfile,' >> ',outfile)
	system(cmd)
	system(paste0('rm ',tmpfile))
}

}
















