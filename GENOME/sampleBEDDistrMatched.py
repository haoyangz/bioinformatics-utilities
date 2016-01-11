import tempfile,sys
from os import system,chdir,makedirs,walk
from math import floor
from os.path import join,exists,realpath,dirname
bedfile1 =sys.argv[1]
bedfile2= sys.argv[2]
column2match = int(sys.argv[3])
precision = float(sys.argv[4])
outfile1 = sys.argv[5]
outfile2 = sys.argv[6]

binned1 = tempfile.NamedTemporaryFile().name
binned2 = tempfile.NamedTemporaryFile().name
distr1 = tempfile.NamedTemporaryFile().name
distr2 = tempfile.NamedTemporaryFile().name
#binned1 = '/cluster/zeng/code/research/recomb/preprocess/bin1'
#binned2 = '/cluster/zeng/code/research/recomb/preprocess/bin2'
#distr1 = '/cluster/zeng/code/research/recomb/preprocess/d1'
#distr2 = '/cluster/zeng/code/research/recomb/preprocess/d2'
makedirs(distr1)
makedirs(distr2)
cwd = dirname(realpath(__file__))

def getFileLen(fname):
	with open(fname) as f:
		for i, l in enumerate(f):
			pass
	return i + 1

### Smooth the value to match
def smooth(bedfile,bin):
    with open(bedfile) as fin, open(bin,'w') as fout:
        for x in fin:
            line = x.strip().split()
            line[column2match-1] = str(floor(float(line[column2match-1])/precision))
            fout.write('%s\n' % '\t'.join(line))

smooth(bedfile1,binned1)
smooth(bedfile2,binned2)

### split the file accoding to the smoothed value
chdir(distr1)
system(' '.join(['awk \'{print $0 >','$'+str(column2match)+'}\'',binned1]))
chdir(distr2)
system(' '.join(['awk \'{print $0 >','$'+str(column2match)+'}\'',binned2]))
chdir(cwd)

### Get the number of sample in each bin
bins1 = [float(x) for x in next(walk(distr1))[2]]
bins2 = [float(x) for x in next(walk(distr2))[2]]

num1 = {}
num2 = {}
for x in bins1:
    num1[x] = getFileLen(join(distr1,str(x)))
for x in bins2:
    num2[x] = getFileLen(join(distr2,str(x)))


### Match the distribution
allbin = list(set(bins1 + bins2))

for b in allbin:
    n1 = num1[b] if b in num1 else 0
    n2 = num2[b] if b in num2 else 0
    if n1<n2:
        num2[b] = n1
    else:
        num1[b] = n2

### Resample the data according to the matched distribution
def resample(topdir,num,outfile):
    flag = False
    for x in num.keys():
        if num[x] == 0:
            continue
        if not flag:
            flag = True
            system(' '.join(['shuf -n',str(num[x]),join(topdir,str(x)),'>',outfile]))
        else:
            system(' '.join(['shuf -n',str(num[x]),join(topdir,str(x)),'>>',outfile]))

resample(distr1,num1,outfile1)
resample(distr2,num2,outfile2)

### Clean up
system('rm -r ' + binned1)
system('rm -r ' + binned2)
system('rm -r ' + distr1)
system('rm -r ' + distr2)
