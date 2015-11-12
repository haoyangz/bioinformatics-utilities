import argparse,pwd,os,numpy as np,h5py
from os.path import splitext

def outputHDF5(data,label,filename):
    print 'data shape: ',data.shape
    comp_kwargs = {'compression': 'gzip', 'compression_opts': 1}
    label = [[x.astype(np.float32)] for x in label]
    with h5py.File(filename, 'w') as f:
    	f.create_dataset('pair_data', data=data, **comp_kwargs)
    	f.create_dataset('label', data=label, **comp_kwargs)


def embed(seq,mapper,worddim):
    mat = np.asarray([mapper[element] if element in mapper else np.random.rand(worddim)*2-1 for element in seq])
    return mat

def seq2feature(data1,data2,mapper,label,out_filename,batchsize,worddim):
    out = []
    lastprint = 0;
    cnt = 0
    batchnum = 0;
    datalen = len(data1)
    for dataidx in range(datalen):
        mat = np.asarray([embed(data1[dataidx],mapper,worddim),embed(data2[dataidx],mapper,worddim)])
        result = mat.transpose((2,0,1))
        out.append(result)
        cnt = cnt + 1
        if cnt % batchsize ==0:
            batchnum = batchnum + 1
            t_filename = out_filename + '.batch' + str(batchnum)
            outputHDF5(np.asarray(out),label[lastprint:cnt],t_filename)
            lastprint = cnt;
            out = []
    if len(out)>0:
        batchnum = batchnum + 1
        t_filename = out_filename + '.batch' + str(batchnum)
        outputHDF5(np.asarray(out),label[lastprint:cnt],t_filename)
    return batchnum

def parse_args():
    parser = argparse.ArgumentParser(description="Convert sequence and target for Caffe")
    user = pwd.getpwuid(os.getuid())[0]

    # Positional (unnamed) arguments:
    parser.add_argument("infile1",  type=str, help="Sequence in FASTA/TSV format (with .fa/.fasta or .tsv extension)")
    parser.add_argument("infile2",  type=str, help="Sequence in FASTA/TSV format (with .fa/.fasta or .tsv extension)")
    parser.add_argument("labelfile",  type=str,help="Label of the sequence. One number per line")
    parser.add_argument("outfile",  type=str, help="Output file (example: $MODEL_TOPDIR$/data/train.h5). ")

    # Optional arguments:
    parser.add_argument("-m", "--mapper", dest="mapper", default="", help="A TSV file mapping each nucleotide to a vector. The first column should be the nucleotide, and the rest denote the vectors. (Default mapping: A:[1,0,0,0],C:[0,1,0,0],G:[0,0,1,0],T:[0,0,0,1])")
    parser.add_argument("-b", "--batch", dest="batch", type=int,default=5000, help="Batch size for data storage (Defalt:5000)")
    parser.add_argument("-p", "--prefix", dest="maniprefix",default='/data', help="The model_dir (Default: /data . This only works for mri-wrapper)")

    return parser.parse_args()


def output(region1,region2,mapper,label,out_filename,batchsize,worddim,manifestprefix):
    batch_num = seq2feature(region1,region2,mapper,label,out_filename,batchsize,worddim)
    locfile = out_filename.split('.')[0] + '.txt'
    with open(locfile,'w') as f:
        for i in range(batch_num):
            f.write('.'.join(['/'.join([manifestprefix]+out_filename.split('/')[-2:]),'batch'+str(i+1)])+'\n')


def readFasta(fafile):
    with open(fafile,'r') as f:
        cnt = 0
        seqdata = []
        for x in f:
            cnt = (cnt+1)%2
            if cnt == 0:
                seqdata.append(x.strip().split())
    return seqdata

def readTSV(infile):
    with open(infile) as f:
        seqdata = [x.strip().split()[1] for x in f]
    return seqdata

def readData(infile):
    filename, file_extension = splitext(infile)
    assert(file_extension == '.fasta' or file_extension == '.fa' or file_extension  == '.tsv')

    if file_extension == '.fasta' or file_extension == '.fa':
        seqdata = readFasta(infile)
    else:
        seqdata = readTSV(infile)
    return seqdata

if __name__ == "__main__":

    args = parse_args()

    seqdata1 = readData(args.infile1)
    seqdata2 = readData(args.infile2)
    assert len(seqdata1) == len(seqdata2)

    seqdata1 = np.asarray([list(x) for x in seqdata1])
    seqdata2 = np.asarray([list(x) for x in seqdata2])

    with open(args.labelfile,'r') as f:
        label = [int(x.strip()) for x in f]
    label = np.asarray(label)

    if args.mapper == "":
        args.mapper = {'A':[1,0,0,0],'C':[0,1,0,0],'G':[0,0,1,0],'T':[0,0,0,1]}
    else:
        args.mapper = {}
        with open(args.mapper,'r') as f:
            for x in f:
                line = x.strip().split()
                word = line[0]
                vec = [float(item) for item in line[1:]]
                args.mapper[word] = vec

    output(seqdata1,seqdata2,args.mapper,label,args.outfile,args.batch,len(args.mapper['A']),args.maniprefix)
