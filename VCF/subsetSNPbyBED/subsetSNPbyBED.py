#!/usr/bin/env python
import sys

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
    if len(sys.argv) != 6:
        print 'Usage: %s file1 file2'
        sys.exit(2)

    file1 = open(sys.argv[1])
    file2 = open(sys.argv[2])
    flank = int(sys.argv[3])
    maf = float(sys.argv[4])
    vt = sys.argv[5]

    line2 = file2.readline()
    line2_cnt = 0;

    line1 = readline1(file1)
    line1_split = line1.split('\t')
    line1_chr = int(line1_split[0].strip())
    line1_pos = int(line1_split[1].strip())
    line1_split2 = line1_split[7].split(';AF=')
    line1_split3 = line1_split2[1].split(';')
    line1_maf = float(line1_split3[0].strip())
    line1_split4 = line1_split[7].split(';VT=')
    line1_split5 = line1_split4[1].split(';')
    line1_vt = line1_split5[0].strip()
    while line2 != '':
        line2_split = line2.split('\t')
        line2_chr = int(line2_split[0].split('chr')[1].strip())
        line2_start = int(line2_split[1].strip())+1
        line2_end = int(line2_split[2].strip())
        line2_cnt = line2_cnt + 1
        while line1_chr <line2_chr or ( line1_chr == line2_chr and line1_pos <= line2_end+flank):
            if line1_pos >= line2_start-flank:
                if line1_maf>=maf and line1_vt == vt:
                    print line1.strip() + '\t' + str(line2_cnt)
            line1 = readline1(file1)
            line1_split = line1.split('\t')
            line1_chr = int(line1_split[0].strip())
            line1_pos = int(line1_split[1].strip())
            line1_split2 = line1_split[7].split(';AF=')
            line1_split3 = line1_split2[1].split(';')
            line1_maf = float(line1_split3[0].strip())
            line1_split4 = line1_split[7].split(';VT=')
            line1_split5 = line1_split4[1].split(';')
            line1_vt = line1_split5[0].strip()
        line2 = file2.readline()

if __name__ == '__main__':
    main()
