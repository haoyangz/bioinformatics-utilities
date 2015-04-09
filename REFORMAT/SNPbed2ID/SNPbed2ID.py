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
    if len(sys.argv) != 3:
        print 'Usage: %s file1 file2'
        sys.exit(2)

    file1 = open(sys.argv[1])
    file2 = open(sys.argv[2])

    line2 = file2.readline()

    line1 = readline1(file1)
    line1_split = line1.split('\t')
    line1_pos = int(line1_split[1].strip())
    while line2 != '':
        line2_split = line2.split('\t')
        line2_chr = line2_split[0].split('chr')[1].strip()
        line2_pos = int(line2_split[2].strip())
        while line1_split[0].strip() != line2_chr or line1_pos < line2_pos:
            line1 = readline1(file1)
            line1_split = line1.split('\t')
            line1_pos = int(line1_split[1].strip())

        if  line1_pos== line2_pos:
            print line2.strip() + '\t' + line1_split[2].strip()
        line2 = file2.readline()

if __name__ == '__main__':
    main()
