args = commandArgs(T)
dir1 = args[1]
dir2 = args[2]
outdir = args[3]

dir1 = paste0(dir1,'/');
dir2 = paste0(dir2,'/');
outdir = paste0(outdir,'/');

re = dir.create(file.path(outdir),showWarnings=F)
if (!re){
	print('outdir exists! will empty!')
	system(paste0('rm -r ',outdir))
	re = dir.create(file.path(outdir),showWarnings=F)
}

list1 = list.files(dir1,pattern='\\.vcf$')
list2 = list.files(dir2,pattern='\\.vcf$')

cmd = 'cat'
for (i in 1:length(list1)){
	cmd = paste0(cmd,' ',dir1,list1[i])
}

for (i in 1:length(list2)){
	cmd = paste0(cmd,' ',dir2,list2[i])
}

system(paste0(cmd,' | sort -n -k 2 -s | sort -n -k 1 -s> all.tmp'))
system(paste0('awk -F \"\t\" \'{print $0 >> (\"',outdir,'/chr\" $1 \".vcf\")}\' all.tmp'))
#system('rm all.tmp')
