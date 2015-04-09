#!/usr/bin/env python
import sys
import numpy as np
import random
def unexpected_last_line():
    print >>sys.stderr, "file1 does NOT contain all of file2's lines"
    sys.exit(1)

def readline1(f):
    line = f.readline()
    if line == '': unexpected_last_line()

    while line[0] == '#':
        line = f.readline()
        if line == '': unexpected_last_line()

    return line

def main():
    if len(sys.argv) != 3:
        print 'Usage: %s file1 file2'
        sys.exit(2)
    vcffile = open(sys.argv[1])
    d = np.loadtxt(sys.argv[2],delimiter="\t")

    cnt = 0
    idx = 0
    target = int(d[idx])
    line = vcffile.readline();

    while line != '':
        cnt +=1;
        if cnt == target:
            print line.strip()
            idx+=1
            if idx >= len(d):
                break
            target = int(d[idx])
        line = vcffile.readline();
    if idx < len(d):
        raise NameError('Cant find snp for line ' + str(d[idx:len(d)]) + ' in file ' + sys.argv[1] + ' that matches maf and vt requirement')

if __name__ == '__main__':
    main()
