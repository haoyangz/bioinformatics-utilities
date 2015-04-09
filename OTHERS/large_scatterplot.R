args = commandArgs(T);
file1 = args[1]
file2 = args[2]
label1 = args[3]
label2 = args[4]
outfile = args[5]
mode = args[6]

if (identical(mode,'MATLAB')){
	library(R.matlab);
	data1 = readMat(file1)[[1]];
	data2 = readMat(file2)[[1]];
}else{
	data1 = read.table(file1);
	data2 = read.table(file2);
}
data1 = data1[,3]
data2 = data2[,3]
good= !is.na(data1) & !is.na(data2)
data1 = data1[good]
data2 = data2[good]

reg <- lm(data2~data1)

png(outfile,2000,2000,res=300)
plot(data1,data2,pch='.',col=rgb(0,0,0,alpha=0.05),xlim=c(0,0.1),ylim=c(0,0.1),xlab=label1,ylab=label2)
abline(reg,col='red')
dev.off()
