import sys,tempfile
from os import system
from os.path import join

bedfile = sys.argv[1]
r_size = sys.argv[2]
r_num = sys.argv[3]
outfile = sys.argv[4]
genomefile = sys.argv[5]

#genomefile ='/cluster/zeng/code/research/tools/GENOME/hg19.genome'

temp = tempfile.NamedTemporaryFile(dir='/tmp').name
system(' '.join(['bedtools random','-l',r_size,'-n',r_num,'-g',genomefile,'>',temp]))
system(' '.join(['bedtools','shuffle','-excl',bedfile,'-i',temp,'-g',genomefile,'>',outfile]))
#system(' '.join(['bedtools','shuffle','-excl',bedfile,'-i',temp,'-g',genomefile,'-noOverlapping','>',outfile]))

system('rm ' + temp)


