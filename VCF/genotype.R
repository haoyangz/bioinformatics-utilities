args = commandArgs(T)
vcfdir = args[1]
chr = as.numeric(args[2])
coloffset = as.numeric(args[3]) # The starting column of genotype in VCF file
outputdir = args[4]

vcffile = paste0(vcfdir,'/chr',chr,'.vcf')
outputFile = paste0(outputdir,'/chr',chr,'.geno')

input  <- file(vcffile, open = "r")
output  <- file(outputFile, open = "w")
flag = F
while (length(oneLine <- readLines(input, n = 1, warn = FALSE)) > 0) {
	if (substr(oneLine,1,1)=='#'){
		last = oneLine
		next
    }
	if (!flag){
		flag = T
		myVector <- (strsplit(last, "\t"))[[1]]
		write(paste(c('POS',myVector[coloffset:length(myVector)]),collapse="\t"),file=output)
	}
	myVector <- (strsplit(oneLine, "\t"))[[1]]
	pos = myVector[2]

	data = substr(myVector[coloffset:length(myVector)],1,3)
	genotype = sapply(data,function (x) sum(attr(gregexpr('1',x)[[1]],"match.length")))
	genotype[genotype==-1] = 0;

	write(paste(c(pos,genotype),collapse="\t"),file=output,append=T)	

}
close(output)
close(input)
