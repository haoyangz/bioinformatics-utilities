import sys
from struct import *
from os.path import join,dirname,exists
from os import makedirs

fastadir = sys.argv[1] # a folder containing all the fasta files, named as "chrnum.fa" for instance "1.fa"
numchr = int(sys.argv[2])
binfile = sys.argv[3]

mydict = {'A':0,'T':1,'G':2,'C':3,'N':4}

split_fa_dir = join(dirname(fastafile),'split_fa')
if not exists(split_fa_dir):
    makedirs(split_fa_dir)

with open(binfile,'wb') as fout:
    for i in range(numchr):
        t_fa = join(split_fa_dir,'chr'+str(i+1)+'.fa')
        print t_fa
        with open(t_fa) as f:
            f.readline()
            for line in f:
                for x in list(line.strip()):
                    fout.write(pack('b',mydict[x]))

