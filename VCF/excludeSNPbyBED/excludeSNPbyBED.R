args = commandArgs(T)
VCFdir = args[1]
bedfile = args[2]
flank = args[3]
outdir = args[4]

dir.create(outdir, showWarnings = FALSE)
mat <- read.delim(bedfile,header=F,stringsAsFactors=F)

files <- list.files(VCFdir,pattern = "\\.vcf$")
for (fileidx in 1:length(files)){
	file = files[fileidx]
	split1 = strsplit(file,split='.vcf')[[1]][1]
	thischr = as.numeric(strsplit(split1,split='chr')[[1]][2])
	print(paste0('subseting ',thischr));
	
	outfile = paste0(outdir,'/',thischr,'.vcf');
	
	pick = which(mat[,1] == thischr)
	if (length(pick)==0){
		system(paste0('cp ',VCFdir,'/',file,' ',outfile))
	}else{
		part = mat[pick,]
		write.table(part,file='tmp',row.names=F,col.names=F,quote=F,sep="\t")
		cmd = paste('python excludeSNPbyBED.py ',snpfile,'tmp',flank,'>>',outfile,sep=' ');
		system(cmd);
		system('rm tmp');
	}
}
