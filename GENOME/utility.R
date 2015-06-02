hashtable <- c('A','T','G','C')
hashtable_rev <- c('T','A','C','G')

translate <- function(seq){
	return(paste0(hashtable[seq+1],collapse=''))
}

translateRev <- function(seq){
	return(paste0(hashtable_rev[rev(seq+1)],collapse=''))
}

untranslate<- function(seq){
	return(sapply(1:length(seq),function(idx){which(hashtable==seq[idx])-1}))
}

readGenome<-function(genomefile,s,len){
	con <- file(genomefile,open='rb')
	seek(con,where = s)
	rbequiv=readBin(con,integer(),size=1,n=len)
	close(con)
	rbequiv
}
readRef<-function(refile,offsetfile,chr){
	offsets = as.double(readLines(offsetfile))
    chrlen=diff(offsets)
	readsize=chrlen[chr]
	con <- file(refile,open='rb')
	seek(con,where = offsets[chr])
	rbequiv=readBin(con,integer(),size=1,n=readsize)
	close(con)
	rbequiv
}
