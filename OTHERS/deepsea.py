import sys,numpy as np
from os.path import join,exists,dirname
from os import system,makedirs,getcwd,chdir,remove
cwd = getcwd()

orifile = sys.argv[1]
outfile_final = sys.argv[2]

fasta_n = 80
deepsea_sourcedir = '/cluster/zeng/code/research/archive/DeepSEA-v0.93/'
fa_batchsize = 100

def convert(infile,outfile):
    with open(infile,'r') as fin, open(outfile,'w') as fout:
        cnt = 0
        batchcnt = 0
        for x in fin:
            if cnt % fa_batchsize == 0:
                if cnt > 0:
                    fout.close()
                fout = open(outfile+'.batch'+str(batchcnt)+'.fasta','w')
                batchcnt += 1
            cnt += 1
            if cnt%2 == 1:
                fout.write(x)
            else:
                x_len = len(x.strip())
                left_size = (1000-x_len)/2
                right_size = 1000-x_len - left_size
                left_padding = ''.join(['N']*left_size)
                right_padding = ''.join(['N']*right_size)
                line = ''.join([left_padding,x.strip(),right_padding])
                outstring = [line[i:i+fasta_n] for i in range(0, len(line), fasta_n)]
                for item in outstring:
                    fout.write('%s\n' % item)
    return batchcnt

ori_topdir = dirname(orifile)
infile = join(ori_topdir,'1000nt.fasta')
batchcnt = convert(orifile,infile)
outfile = join(ori_topdir,'deepsea_919feature_tmp')
for idx in range(batchcnt):
    t_infile = infile+'.batch'+str(idx)+'.fasta'

    chdir(deepsea_sourcedir)
    cmd = ' '.join(['python rundeepsea.py',t_infile,outfile])
    system(cmd)
    chdir(cwd)

    cmd = ' '.join(['cut -d \",\" -f 3- --output-delimiter=\'\t\' ',outfile,'>',outfile_final+'.batch'+str(idx)])
    system(cmd)

    remove(outfile)
    remove(t_infile)

for idx in range(batchcnt):
    tt = '>' if idx==0 else '>>'
    system(' '.join(['tail -n+2',outfile_final+'.batch'+str(idx),tt,outfile_final]))
for idx in range(batchcnt):
    remove(outfile_final+'.batch'+str(idx))
