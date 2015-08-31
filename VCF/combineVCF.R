args = commandArgs(T)
dirs = args[1]
outdir = args[2]

re = dir.create(file.path(outdir),showWarnings=F,recursive=T)
if (!re){
	print('outdir exists! will empty!')
	system(paste0('rm -r ',outdir))
	re = dir.create(file.path(outdir),showWarnings=F)
}

dirs = strsplit(dirs,'!')[[1]]

filelists = sapply(1:length(dirs),function(x){
				   list.files(dirs[x],pattern='\\.vcf$')
})

cmd = 'cat'
for (i in 1:length(dirs)){
	for (j in 1:length(filelists[[i]])){
		cmd = paste0(cmd,' ',file.path(dirs[i],filelists[[i]][j]))
	}
}
print(cmd)
system(paste0(cmd,' | sort -n -k 2 -s | sort -n -k 1 -s> all.tmp'))
system(paste0('awk -F \"\t\" \'{print $0 >> (\"',outdir,'/chr\" $1 \".vcf\")}\' all.tmp'))
system('rm all.tmp')
