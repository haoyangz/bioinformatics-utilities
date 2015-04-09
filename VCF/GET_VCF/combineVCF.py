#!/usr/bin/env python
import sys

def main():
    if len(sys.argv) != 3:
        print 'Usage: python countBase.py  vcf_dir maxchr'
        sys.exit(2)

    dirr = sys.argv[1]
    maxchr = int(sys.argv[2])
    for chr in range(1,maxchr+1):
        file = open(dirr + 'chr' + str(chr)+'.vcf','r')
        line = file.readline()
        while line != '':
            if (line[0]=='#'):
                if (chr>1):
                    line = file.readline()
                    continue
            print(line)
            line = file.readline()

if __name__ == '__main__':
    main()
