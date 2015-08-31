#!/usr/bin/env python
import sys
from os import listdir,path,makedirs
def unexpected_last_line():
    print >>sys.stderr, "file1 does NOT contain all of file2's lines"
    sys.exit(1)

def readline1(f):
    line = f.readline()
    if line == '': unexpected_last_line()

    while line[0] == '#':
        line = f.readline()

    return line

def main():
    if len(sys.argv) != 5:
        print 'Usage: %s inDir outDir geno geno_col'
        sys.exit(2)

    inDir = sys.argv[1]
    outDir = sys.argv[2]
    geno = int(sys.argv[3]) ### 0 for 0|0, 1 for 1|0 or 0|1, 2 for 1|1
    geno_col = int(sys.argv[4])

    infiles = [ f for f in listdir(inDir) if path.isfile(path.join(inDir,f)) ]

    if not path.exists(outDir):
        makedirs(outDir)

    for tfile in infiles:
        if tfile.find('.vcf') == -1:
            continue
        print 'filter '+tfile
        infile = open(path.join(inDir,tfile),'r')
        outfile = open(path.join(outDir,tfile),'w')

        line1 = readline1(infile)
        while line1 != '':
            if line1.split('\t')[geno_col-1].count('1') == geno:
                outfile.write(line1)
            line1 = infile.readline()
        infile.close()
        outfile.close()

if __name__ == '__main__':
    main()
