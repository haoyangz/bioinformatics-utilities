#!/usr/bin/env python
import sys
import numpy as np
import random
def unexpected_last_line():
    print >>sys.stderr, "file1 does NOT contain all of file2's lines"
    sys.exit(1)

def readline1(f):
    line = f.readline()
    if line == '': return line

    while line[0] == '#':
        line = f.readline()
        if line == '': unexpected_last_line()

    return line

def main():
    if len(sys.argv) != 4:
        print 'Usage: %s file1 file2'
        sys.exit(2)
    vcffile = open(sys.argv[1])
    maf = float(sys.argv[2])
    vt = sys.argv[3]

    line = readline1(vcffile);

    while line != '':
        line_split = line.split('\t')
	line_split2 = line_split[7].split(';AF=')
	line_split3 = line_split2[1].split(';')
	line_maf = float(line_split3[0].strip())
	line_split4 = line_split[7].split(';VT=')
	line_split5 = line_split4[1].split(';')
	line_vt = line_split5[0].strip()
	if line_maf >= maf and line_vt==vt:
            print line.strip()
        line = readline1(vcffile);

if __name__ == '__main__':
    main()
