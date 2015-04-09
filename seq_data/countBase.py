#!/usr/bin/env python
import sys

def main():
    if len(sys.argv) != 3:
        print 'Usage: python countBase.py  fa_dir maxchr'
        sys.exit(2)

    dirr = sys.argv[1]
    maxchr = int(sys.argv[2])
    allsizefile = open(dirr + 'all.size.txt','w')
    allsizefile.write('0\n');
    agg_cnt = 0;
    for chr in range(1,maxchr+1):
        file = open(dirr + 'chr' + str(chr)+'.fa','r')
        file.readline()
        base_per_line = -1
        line =file.readline();
        cnt= 0;
        line_base = 0;
        while line != '':
            cnt += 1
            line_base = len(line.strip());
            if (cnt==1):
                base_per_line = line_base
            line =file.readline();
        outfile = open(dirr + 'chr' + str(chr) + '.size.txt','w')
        basenum =  (cnt-1)*base_per_line + line_base
        print basenum
        outfile.write(str(basenum)+ '\n')
        agg_cnt += basenum
        allsizefile.write(str(agg_cnt)+'\n')



if __name__ == '__main__':
    main()
