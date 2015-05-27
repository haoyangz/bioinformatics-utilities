extractRef<-function(refile,offsetfile,chr,outfile){
	offsets = as.double(readLines(offsetfile))
    chrlen=diff(offsets)
	readsize=chrlen[chr]
	con <- file(refile,open='rb')
	seek(con,where = offsets[chr]*4)
	rbequiv=readBin(con,numeric(),size=4,n=readsize)
	close(con)
	
	con <- file(outfile,open='wb')
	writeBin(rbequiv,con,size=4)
	close(con)
}

args = commandArgs(T)
ref_file = args[1]
offsetfile = args[2]
outfolder = args[3]
outsuffix = args[4]

cmd = paste0('lzop -d ',ref_file,'.lzo')
system(cmd)

for (i in 1:22){
	outfile = file.path(outfolder,paste0('chr',i,outsuffix))
	extractRef(ref_file,offsetfile,i,outfile)
}
