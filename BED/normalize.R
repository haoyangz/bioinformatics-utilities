args <- commandArgs(T)
options("scipen"=100)
infile = args[1]
outfile = args[2]
flank = as.numeric(args[3])
offsetfile = args[4]

chrsize = read.delim(offsetfile,header=F)
chrsize = chrsize[2:nrow(chrsize),1] - chrsize[1:(nrow(chrsize)-1),1]
print(chrsize)

mat <- read.delim(infile,header=F,stringsAsFactors=F)
mid = floor((mat[,3] + mat[,2] + 1)/2)
out = mat
out[,3] = floor(mid + flank)
out[,2] = floor(mid - flank)-1
unique_chr = unique(out[,1])
for (i in 1:length(unique_chr)){
	t_chr = unique_chr[i]
	t_chr_num = as.numeric(strsplit(t_chr,'chr')[[1]][2])
	if (is.na(t_chr_num)){
		next
	}
	pick = which(out[,1] == t_chr)
	part = out[pick,]
	limit = chrsize[t_chr_num]
	badpick = pick[which(part[,3] > limit)]
	exceed = out[badpick,3]-limit
	if (length(which(sign(exceed)>0))>0){
		print('Errrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr!')
	}
	out[badpick,2:3] =out[badpick,2:3] - exceed
}

write.table(out,file=outfile,quote=F,row.names=F,col.names=F,sep="\t")
