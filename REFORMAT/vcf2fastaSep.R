source('/cluster/zeng/code/research/tools/GENOME/utility.R')
args = commandArgs(T)
vcfdir = args[1]
genomefile = args[2]
offsetfile = args[3]
out_dir = args[4]
flank_len = as.numeric(args[5])

dir.create(out_dir,showWarnings=F)
out_ref = file.path(out_dir,'ref.fa')
out_alt = file.path(out_dir,'alt.fa')
files = list.files(vcfdir,pattern='\\.vcf$')

ref_con = file(out_ref,open='w')
alt_con = file(out_alt,open='w')
for (i in 1:length(files)){
	cmd = paste0('awk \'{OFS=\"\t\";print $1, $2, $4, $5}\' ',file.path(vcfdir,files[i]),' > tmp')
	system(cmd)

	data <- read.delim('tmp',header=F,stringsAsFactors=F)
	data[data[,3]==T,3] = rep('T')
	data[data[,4]==T,4] = rep('T')

	chr = as.numeric(data[1,1])
	
	ref = readRef(genomefile,offsetfile,chr)
	for (var in 1:nrow(data)){
		pos = data[var,2]
		s = pos-flank_len
		e = pos+flank_len
		name = paste0('chr',chr,':',data[var,2],'-',data[var,2])
		
		writeLines(paste0('>',name),ref_con)
		seq = translate(ref[s:e])
		if (substr(seq,flank_len+1,flank_len+1) != data[var,3]){
			print(substr(seq,flank_len+1,flank_len+1))
			print(data[var,3])
			print('Ref doesn\'t match!')
		}
		writeLines(seq,ref_con)

		writeLines(paste0('>',name),alt_con)
		substr(seq,flank_len+1,flank_len+1) = data[var,4]
		writeLines(seq,alt_con)

	}
	
	system('rm tmp')
}
close(ref_con)
close(alt_con)
