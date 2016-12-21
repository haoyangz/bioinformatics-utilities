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
    if len(sys.argv) != 6:
        print 'Usage: %s inDir outDir keyword maf'
        sys.exit(2)

    inDir = sys.argv[1]
    outDir = sys.argv[2]
    keyword = sys.argv[3].split(';')
    value = sys.argv[4].split(';')
    relation = sys.argv[5].split(';')

    for i in range(len(relation)):
        if relation[i]!='e' and relation[i] != 'ne':
            value[i] = float(value[i])

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
            line1_split = line1.split('\t')
            info_split = line1_split[7].split(';')
            info_key = [x.split('=')[0] if '=' in x else x for x in info_split]
            info_value = [x.split('=')[1] if '=' in x else 'NA' for x in info_split]
            flag = True
            for query in range(len(value)):
                if relation[query] == 'e':
                    if info_value[info_key.index(keyword[query])] != value[query]:
                        flag = False
                else:
                    if relation[query] == 'g':
                        if float(info_value[info_key.index(keyword[query])]) < value[query]:
                            flag = False
                    else:
                        if relation[query] == 'l':
                            if float(info_value[info_key.index(keyword[query])]) >value[query]:
                                flag = False
                        else:
                            if relation[query] == 'ne':
                                if info_value[info_key.index(keyword[query])] == value[query]:
                                    flag = False
                            else:
                                print 'Unrecognized relation : ' + relation[query]
                                sys.exit(2)

            if flag:
                outfile.write(line1)
            line1 = infile.readline()
        infile.close()
        outfile.close()

if __name__ == '__main__':
    main()
