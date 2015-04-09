args = commandArgs(T)
vcfdir = args[1]
beddir = args[2]
chr = as.numeric(args[3])
flank = as.numeric(args[4])
outdir = args[5]
readmax = as.numeric(args[6])

	vcffile = paste0(vcfdir,'/chr',chr,'.vcf.pos')
	vcf_pos = read.table(vcffile,stringsAsFactor=FALSE)
	vcf_size = nrow(vcf_pos)

	bedfile = paste0(beddir,'/chr',chr,'.bed')
	bed = read.table(bedfile,stringsAsFactors=FALSE)
	bed_pos = bed[,3]
	bed_cnt = bed[,5]
	bed_size = nrow(bed)

	bed_cnt[bed_cnt>readmax] = readmax;

	bed_left = 1;
	
	output = matrix(nrow=vcf_size,ncol=2)
	colnames(output) = c('POS','COUNT')
	output[,1] = vcf_pos[,1]

	flag = F
	for ( i in 1:vcf_size){
		pos = vcf_pos[i,1]
		if (flag){
			output[i,2] = 0;
			next
		}

		range = c(pos-flank,pos+flank);
		while (bed_pos[bed_left]<range[1]){
			bed_left = bed_left + 1
			if (bed_left>bed_size){
				flag = T
				output[i,2] = 0;
				break;
			}
		}
		if (flag)
			next

		if (bed_pos[bed_left]>range[2]){
			output[i,2] = 0;
			next;
		}
		bed_right = bed_left
		while (bed_pos[bed_right] <=range[2]){
			bed_right = bed_right + 1
			if (bed_right>bed_size){
				break;
			}
		}
		bed_right = bed_right -1
		output[i,2]  = sum(bed_cnt[bed_left:bed_right])
	} 

	outputFile = paste0(outdir,'/chr',chr,'.pheno')
	write.table(output,file=outputFile,quote=F,row.names=F,col.names=T,sep="\t")
