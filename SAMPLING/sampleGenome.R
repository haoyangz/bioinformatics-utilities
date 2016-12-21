require('IRanges')
source('/cluster/zeng/code/research/tools/GENOME/utility.R')
sampleGenome <- function(num,minchr,maxchr,flank,offsetfile,genomefile){
	offsets_ori = as.double(readLines(offsetfile))
	offsets = offsets_ori[minchr:(maxchr+1)] - offsets_ori[minchr]

	chrlen=diff(offsets)
	samples = sample(offsets[length(offsets)],num)
	s_info = splitArray(samples,offsets)	
	
	loci = matrix(nrow=num,ncol=3)
	loci_cnt =0;
	uni_chr = sort(unique(s_info[['class']]))
	win = list()
	for (chridx in 1:length(uni_chr)){
		print(paste0('sampling chr',minchr-1+uni_chr[chridx]))
		chr = uni_chr[chridx]
		chrsize = chrlen[chr]
		ref <- readRef(genomefile,offsetfile,chr+minchr-1)
		this_s = sort(s_info[['pos']][s_info[['class']]==chr])
		chr_sample_range = chrsize - (2*flank-1)
		for (i in 1:length(this_s)){
			flag = F
			target = this_s[i]
			while(!flag){
				if (target>flank && target <= chrsize - flank+1){
					region = ref[(target-flank):(target+flank-1)]
					if (sum(region>3) + sum(region<0)==0){
						flag = T
					}
				}
				if (!flag){
					target = sample(chr_sample_range,1) + flank
					while (sum(this_s==target)>0){
						target = sample(chr_sample_range,1) + flank
					}
				}
			}
			this_s[i] = target
		}
		
		win[[chridx]] = flank(IRanges(this_s,width=1),both=T,width=flank)
		loci_range = (loci_cnt+1):(loci_cnt+length(this_s))
		loci[loci_range,1] = rep(chr+minchr-1)
		loci[loci_range,2] = floor(this_s - flank)
		loci[loci_range,3] = floor(this_s + flank)
		loci_cnt = loci_cnt + length(this_s)
	}
	loci = loci[order(loci[,2]),]
	loci = loci[order(loci[,1]),]
	return(list(uni_chr+minchr-1,win,loci))
}

splitArray <- function(vec,cut){
	a = matrix(1,nrow=length(cut),ncol=1) %*% matrix(vec,nrow=1)
	b = matrix(cut,ncol=1) %*% matrix(1,nrow=1,ncol=length(vec))
	s = a-b
	out = list()
	out[['class']] = sapply(1:length(vec),function(x){sum(s[,x]>0)})
	out[['pos']] = sapply(1:length(vec),function(x){vec[x] - cut[out[['class']][x]]})
	return(out)
}
