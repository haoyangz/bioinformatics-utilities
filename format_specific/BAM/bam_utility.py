from os import remove,system
import tempfile
def bam2count(bamfile,r_chr,r_s,r_e):
    _,temp = tempfile.mkstemp()
    _,temp1 = tempfile.mkstemp()
    _,temp2 = tempfile.mkstemp()
    system(' '.join(['samtools view -F 788',bamfile,r_chr+':'+r_s+'-'+r_e,' | awk \'{print $3 "\t" $4-'+r_s+' "\t" $4+1-'+r_s+'}\' > ',temp]))
    with open(temp2,'w') as f:
        f.write(r_chr+'\t'+str(int(r_e)-int(r_s)+1))
    system(' '.join(['bedtools genomecov -d -g',temp2,' -i',temp,' >',temp1]))
    with open(temp1) as f:
        out = [x.strip().split()[-1] for x in f]
    remove(temp)
    remove(temp1)
    remove(temp2)
    return map(int,out)
