source('/cluster/zeng/code/research/tools/GENOME/utility.R')
require('snow')
args = commandArgs(T)
vcfdir = args[1]
genomefile = args[2]
offsetfile = args[3]
out_dir = args[4]
flank_len = as.numeric(args[5])
combine_allele = args[6]

dir.create(out_dir,showWarnings=F)
if (combine_allele=='T'){
	out_file1 = file.path(out_dir,'all.fa')
	out_file2 = file.path(out_dir,'all.pairs.txt')
}else{
	out_file1 = file.path(out_dir,'ref.fa')
	out_file2 = file.path(out_dir,'alt.fa')
}
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
clusterExport(cl, c("files","vcfdir","genomefile","offsetfile","flank_len","out_dir","combine_allele")) 
cc = clusterCall(cl,function(){source('/cluster/zeng/code/research/tools/GENOME/utility.R')})
run <- function(i){
	if (combine_allele=='T'){
		ref_con = file(file.path(out_dir,paste0('fa',i)),open='w')    		
		alt_con = ref_con
	    p_con = file(file.path(out_dir,paste0('pair',i)),open='w')
	}else{
		ref_con = file(file.path(out_dir,paste0('ref',i)),open='w')
		alt_con = file(file.path(out_dir,paste0('alt',i)),open='w')
	}
	t_tmp = file.path(out_dir,paste0('tmp',i))

	cmd = paste0('awk \'{OFS=\"\t\";print $1, $2, $4, $5}\' ',file.path(vcfdir,files[i]),' > ',t_tmp)
	system(cmd)

	data <- read.delim(t_tmp,header=F,stringsAsFactors=F)
	data[data[,3]==T,3] = rep('T')
	data[data[,4]==T,4] = rep('T')

	chr = as.numeric(data[1,1])
	
	ref = readRef(genomefile,offsetfile,chr)
	var_rel_pos = ceiling(flank_len+1)
	for (var in 1:nrow(data)){
		pos = data[var,2]
		s = floor(pos-flank_len)
		ref_e = floor(pos+flank_len) 
		alt_e = ref_e + max(0,nchar(data[var,3])-nchar(data[var,4]))
		name = paste0('chr',chr,':',data[var,2],':',flank_len)
		
		if (combine_allele=='T'){
			writeLines(paste0('>ref:',name),ref_con)
		}else{
			writeLines(paste0('>',name),ref_con)
		}
		ref_seq = translate(ref[s:ref_e])
		ref_allele = substr(ref_seq,var_rel_pos,var_rel_pos+nchar(data[var,3])-1)
		if (ref_allele != data[var,3]){
			print(ref_allele)
			print(data[var,3])
			print('Ref doesn\'t match!')
		}
		writeLines(ref_seq,ref_con)

		if (combine_allele=='T'){
			writeLines(paste0('>alt:',name),alt_con)
		}else{
			writeLines(paste0('>',name),alt_con)
		}
		if (ref_e<alt_e){
			alt_seq = translate(ref[s:alt_e])
		}else{
			alt_seq = ref_seq
		}
		alt_seq_left = substr(alt_seq,1,var_rel_pos -1)
		alt_seq_right = substr(alt_seq,var_rel_pos + nchar(data[var,3]),nchar(alt_seq))
		alt_seq = paste0(alt_seq_left,data[var,4],alt_seq_right)
		writeLines(substr(alt_seq,1,ref_e - s + 1),alt_con)
		
		if (combine_allele=='T'){
			writeLines(paste0('ref:',name,'\t','alt:',name),p_con)
		}

	}
	close(ref_con)
	if (combine_allele=='T'){
		close(p_con)
	}else{
    	close(alt_con)
	}
	system(paste0('rm ',t_tmp))
}
re = clusterApplyLB(cl,1:length(files),run)
stopCluster(cl)


cmd1 = 'cat'
cmd2 = 'cat'
if (combine_allele=='T'){
	file1_tag = 'fa'
	file2_tag = 'pair'
}else{
	file1_tag = 'ref'
    file2_tag = 'alt'
}
for (i in 1:length(files)){
	cmd1 = paste(cmd1,file.path(out_dir,paste0(file1_tag,i)),sep=' ')
	cmd2 = paste(cmd2,file.path(out_dir,paste0(file2_tag,i)),sep=' ')
}
cmd1 = paste(cmd1,'>',out_file1)
cmd2 = paste(cmd2,'>',out_file2)

system(cmd1)
system(cmd2)

for (i in 1:length(files)){
	system(paste0('rm ',file.path(out_dir,paste0(file1_tag,i))))
	system(paste0('rm ',file.path(out_dir,paste0(file2_tag,i))))
}
