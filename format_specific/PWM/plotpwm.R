require('seqLogo')
args = commandArgs(T)
pwmfile = args[1]
outdir = args[2]
sep = args[3]

dir.create(outdir,showWarnings=F)

data = read.delim(pwmfile,stringsAsFactors=F,header=F)

con <- file(pwmfile) 
open(con);
results.list <- list();
current.line <- 1
data = c()
while (length(line <- readLines(con, n = 1, warn = FALSE)) > 0) {
	data = c(data,line)
} 
close(con)

print(data)
filesize = length(data)
data = sapply(1:filesize,function(x){strsplit(data[x],split=sep)[[1]]})

header = which(sapply(1:length(data),function(x){length(data[[x]])!=4}))
for (idx in 1:length(header)){
	t_header = header[idx]
	if (idx == length(header)){
		next_header = length(data)+1
	}else{
		next_header = header[idx+1]
	}
	if (next_header==t_header+1) next
	filesplit = strsplit(data[[t_header]],split='>')[[1]]
	print(filesplit[2])
	rowmat= matrix(unlist(data[(t_header+1):(next_header-1)]),nrow=4)
	mat = matrix(as.numeric(rowmat),nrow=nrow(rowmat))
	
	pdf(file.path(outdir,paste0(filesplit[2],'.pdf')))
	nm=apply(mat[1:4,]+0.0001,2,function(j){j/sum(j)})
	seqLogo(nm)

	nm_rv = nm[c(4,3,2,1),ncol(nm):1]
    seqLogo(nm_rv)
    dev.off()

}




