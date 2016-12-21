import sys,numpy as np

seqfile = sys.argv[1]
pwmfile = sys.argv[2]




mydict = {'A':[1,0,0,0],'C':[0,1,0,0],'G':[0,0,1,0],'T':[0,0,0,1],'N':[0,0,0,0]}
def seq2matrix(seq):
    return [mydict[x]for x in seq]

mymatrix = {}
newgroup = True
cur_group = ''
with open(seqfile) as f:
    for x in f:
        seq = x.strip().split()
        if not seq[1] in mymatrix.keys():
            mymatrix[seq[1]] = np.zeros((len(seq[0]),4))
            print seq[1]
        mymatrix[seq[1]] += seq2matrix(list(seq[0]))

with open(pwmfile,'w') as f:
    for k in mymatrix.keys():
        f.write('>PWM'+k+'\n')
        for x in mymatrix[k]:
            f.write('%s\n' % '\t'.join(map(str,np.asarray(x,dtype=int))))


