require('Rcpp');require('inline')
uniconv ='
Rcpp::NumericVector cvadd(vadd);
Rcpp::NumericVector cvret(cvadd.size());
int cksize = as<int>(ksize);
int halfsz = (cksize-1)/2;
double temp=0;
for(int i=0; i < (halfsz);i++){
	 temp+=cvadd[i];
}
for(int i=0; i < cvadd.size();i++){
	 if((i+halfsz)< cvadd.size()){
		   temp+=cvadd[i+halfsz];
 }
 cvret[i]=temp/cksize;
  if((i-halfsz)>=0){
	    temp-=cvadd[i-halfsz];
  }
}
return cvret;
'
uconv <- cxxfunction(signature(vadd="numeric",ksize="integer"),uniconv,plugin="Rcpp",includes="#include <numeric>")

readReal<-function(fname,basedir,rmax,chrheld){
	offsets = as.double(readLines(file.path(basedir,fname,'/input/offsets.txt')))
    chrlen=diff(offsets)
	readsize=chrlen[chrheld]
	readfile = file.path(basedir,fname,'/input/reads.in')
	if (!file.exists(readfile)){
		system(paste0('lzop -d ',readfile,'.lzo'))
	}
	con <- file(readfile,open='rb')
	seek(con,where = offsets[chrheld] * 4)
	rbequiv=readBin(con,double(),size=4,n=readsize)
	rbequiv[rbequiv>rmax]=rmax
	close(con)
	rbequiv
}

readFitted<-function(fname,basedir,rmax,chrheld){
	offsets = as.double(readLines(file.path(basedir,fname,'/input/offsets.txt')))
    chrlen=diff(offsets)
	readsize=chrlen[chrheld]
	rbhat=readBin(file.path(basedir,fname,paste0('/summaries/fitted.',chrheld,'.bin')),double(),size=4,n=readsize)
	rbhat[rbhat>rmax]=rmax
	rbhat
}

readBaseline<-function(fname,basedir,rmax,chrheld){
	offsets = as.double(readLines(file.path(basedir,fname,'/input/offsets.txt')))
    chrlen=diff(offsets)
	readsize=chrlen[chrheld]
	rbhat=readBin(file.path(baselinedir,fname,paste0('/baseline/chr',chrheld,'.',fname,'.baseline.bin')),double(),size=4,n=readsize)
	rbhat[rbhat>rmax]=rmax
	rbhat
}

mysqrt <- function(data){
	data[data<0] = 0;
	return(sqrt(data))
}
