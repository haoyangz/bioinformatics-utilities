source('/cluster/zeng/code/research/tools/GENOME/utility.R')
require('snow')
args = commandArgs(T)
vcfdir = args[1]
genomefile = args[2]
offsetfile = args[3]
out_dir = args[4]
flank_len = as.numeric(args[5])

dir.create(out_dir,showWarnings=F)
out_fafile = file.path(out_dir,'all.fa')
out_pairfile = file.path(out_dir,'all.pairs.txt')
files = list.files(vcfdir,pattern='\\.vcf$')
pick = c()
for (i in 1:length(files)){
	re = system(paste0('wc ',file.path(vcfdir,files[i]),' -l'),intern=T)
	if (as.numeric(strsplit(re,' ')[[1]][1])!=0){
		pick = c(pick,i)
	}
}
files = files[pick]

cl <- makeCluster(11, type = "SOCK") 
clusterExport(cl, c("files","vcfdir","genomefile","offsetfile","flank_len","out_dir")) 
cc = clusterCall(cl,function(){source('/cluster/zeng/code/research/tools/GENOME/utility.R')})
run <- function(i){
	con = file(file.path(out_dir,paste0('fa',i)),open='w')
	p_con = file(file.path(out_dir,paste0('pair',i)),open='w')
	t_tmp = file.path(out_dir,paste0('tmp',i))
	
	cmd = paste0('awk \'{OFS=\"\t\";print $1, $2, $4, $5}\' ',file.path(vcfdir,files[i]),' > ',t_tmp)
	system(cmd)

	data <- read.delim(t_tmp,header=F,stringsAsFactors=F)
	data[data[,3]==T,3] = rep('T')
	data[data[,4]==T,4] = rep('T')

	chr = as.numeric(data[1,1])
	
	ref = readRef(genomefile,offsetfile,chr)
	for (var in 1:nrow(data)){
		pos = data[var,2]
		s = pos-flank_len
		e = pos+flank_len
		name = paste0('chr',chr,':',data[var,2],'-',data[var,2])
		
		writeLines(paste0('>ref:',name),con)
		seq = translate(ref[s:e])
		if (substr(seq,flank_len+1,flank_len+1) != data[var,3]){
			print(substr(seq,flank_len+1,flank_len+1))
			print(data[var,3])
			print('Ref doesn\'t match!')
		}
		writeLines(seq,con)

		writeLines(paste0('>alt:',name),con)
		substr(seq,flank_len+1,flank_len+1) = data[var,4]
		writeLines(seq,con)

		writeLines(paste0('ref:',name,'\t','alt:',name),p_con)
	}
	close(con)
	close(p_con)	
	system(paste0('rm ',t_tmp))
}

re = clusterApplyLB(cl,1:length(files),run)
stopCluster(cl)

cmd1 = 'cat'
cmd2 = 'cat'
for (i in 1:length(files)){
	cmd1 = paste(cmd1,file.path(out_dir,paste0('fa',i)),sep=' ')
	cmd2 = paste(cmd2,file.path(out_dir,paste0('pair',i)),sep=' ')
}
cmd1 = paste(cmd1,'>',out_fafile)
cmd2 = paste(cmd2,'>',out_pairfile)

system(cmd1)
system(cmd2)

for (i in 1:length(files)){
	system(paste0('rm ',file.path(out_dir,paste0('fa',i))))
	system(paste0('rm ',file.path(out_dir,paste0('pair',i))))
}
