args <- commandArgs(TRUE)
srcFile <- args[1]
outfile <- args[2]

mat = read.delim(srcFile,stringsAsFactors=FALSE,header=FALSE)

chr = unique(mat[,1])
chr_num = c();
for ( i in 1:length(chr)){
	split = strsplit(chr[i],'chr')[[1]]
	chr_num = c(chr_num,as.numeric(split[2]));
}

chr_num = sort(chr_num);

out=mat;
cnt=0;
for (i in 1:length(chr_num)){
	thischr = paste0('chr',chr_num[i]);
	print(thischr)
	part= mat[mat[,1]==thischr,]
	pick = order(as.numeric(part[,2]))
	part = part[pick,]
	out[(cnt+1):(cnt+nrow(part)),] = part;
	cnt = cnt + nrow(part)
}
write.table(out,file=outfile,quote=FALSE,row.names=FALSE,col.names=FALSE,sep="\t");
