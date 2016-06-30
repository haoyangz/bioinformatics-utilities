require('seqLogo')
require('Biostrings')
args <- commandArgs(T)
seqfile = args[1]
logofile = args[2]
pwmfile = args[3]


rc = function(x){
	    reverseComplement(DNAStringSet(x))
}

buildMat <- function(seq){
	incluster=seq
	targ=paste0('NNNN',incluster[1],'NNNN')
	pa1=pairwiseAlignment(DNAStringSet(incluster),targ)
	s1=score(pa1)
	pa2=pairwiseAlignment(DNAStringSet(rc(incluster)),targ)
	s2=score(pa2)
	x1=0
	if(sum(s1>s2)>0)
		x1 = consensusMatrix(pa1[s1>s2])
	x2=0
	if(sum(s2>=s1)>0)
		x2 = consensusMatrix(pa2[s2>=s1])
	return(x1+x2)
}


printPWM <- function(pwmfile,pwm,pwmname,app){
	if (app){
		fileConn<-file(pwmfile,'a')
	}else{
		fileConn<-file(pwmfile,'w')
	}
	write(paste0(">",pwmname), file=fileConn,append=app)
	mat = t(pwm[1:4,]);
	for ( j in 1:nrow(mat)){
		if (sum(mat[j,])==0)
			next
		content = mat[j,1];
		for (k in 2:4){
			content = paste0(content,' ',mat[j,k])
		}
		write(content, file=fileConn,append=T)
	}
	close(fileConn)
}


seq = read.delim(seqfile,header=F,stringsAsFactors=F,sep=' ')
groups = seq[,2]
uni_group = unique(groups)

pdf(logofile)
for (gidx in 1:length(uni_group)){
	thisseq = seq[groups==uni_group[gidx],1]
	mat = buildMat(thisseq)
	if (gidx>1){
		app=T
	}else{
		app=F
	}
	printPWM(pwmfile,mat,paste0('PWM',uni_group[gidx]),app)
	nm=apply(mat[1:4,]+0.1,2,function(j){j/sum(j)})
	print(gidx)
	print(nm)
	seqLogo(nm)
}
dev.off()

