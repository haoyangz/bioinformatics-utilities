import sys,os,multiprocessing

maxchr = 22;
topdir = 'ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/'
prefix = 'ALL.chr'
suffix = '.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz'
outdir = '/cluster/zeng/research/kmer/hg19/FINAL.ver140827/SNP_data/1KG_20130502/'
individual = ['NA12878']

tmpdir = 'tmpdir'
if not os.path.exists(tmpdir):
    os.makedirs(tmpdir)

def worker(chridx,tmpdir,prefix,suffix,topdir,outdir,individual):
    filefrom = os.path.join(topdir,prefix+str(chridx)+suffix)
    fileto = os.path.join(tmpdir,'chr'+str(chridx)+'.vcf.gz')
    #os.system(' '.join(['wget',filefrom,'-O',fileto]))
    #print 'gunzip'
    #os.system(' '.join(['gunzip',fileto]))

    print 'get header'
    headfile = 'temp'+str(chridx)
    os.system(' '.join(['head -n 1000 ',os.path.join(tmpdir,'chr'+str(chridx)+'.vcf'), '>',headfile]))
    cnt =0
    with open(headfile) as f:
        for line in f:
            if line[0]!='#':
                break;
            else:
                cnt += 1
    print 'header row:'+str(cnt)

    colfile = 'col' + str(chridx)
    os.system(' '.join(['head',headfile, '-n',str(cnt),' | tail -n 1 > ',colfile]))

    with open(colfile) as f:
        colname = f.readline().strip().split()

    indiv_col = []
    for indiv in individual:
        indiv_col.append(colname.index(indiv))

    print 'awk desired colums'
    orifile = os.path.join(tmpdir,'chr'+str(chridx)+'.vcf')
    outfile = os.path.join(outdir,'chr'+str(chridx)+'.vcf')
    cmd  = ' '.join(['tail -n+'+str(cnt),orifile,'| awk \'{print'])
    cmd  = cmd + ' $' + str(1)
    for j in range(1,9):
        cmd  = cmd + ' \"\\t\"' + ' $' + str(j+1)
    for j in range(len(indiv_col)):
        cmd = cmd + ' \"\\t\"' + ' $' + str(indiv_col[j]+1)
    cmd = cmd + '}\' > ' + outfile
    print cmd
    os.system(cmd)

    os.system('rm ' + headfile)
    os.system('rm ' + colfile)

#worker(22,tmpdir,prefix,suffix)
jobs = []
for i in range(maxchr):
    p = multiprocessing.Process(target=worker, args=(i+1,tmpdir,prefix,suffix,topdir,outdir,individual))
    jobs.append(p)
    p.start()

#os.system('rm -r tmpdir')


