from os import system
from os.path import join
import multiprocessing as mp,argparse

def parse_args():
    parser = argparse.ArgumentParser(description="Launch a list of commands on EC2.")
    parser.add_argument("topdir",  type=str)
    parser.add_argument("suffix",  type=str)
    # Optional arguments:
    parser.add_argument("-g", "--genome", dest="genomesize", default="/cluster/zeng/research/hg19_data/seq_data/genome")
    parser.add_argument("-b", "--bigwig2Bed", dest="bigwig2Bed", default="/cluster/zeng/code/research/tools/REFORMAT/bigWigToBedGraph")
    parser.add_argument("-w", "--wig2bigwig", dest="wig2bigwig", default="/cluster/zeng/code/research/tools/REFORMAT/wigToBigWig")
    return parser.parse_args()

def slave(args):
    i,topdir,suffix,wig2bigwig,bigwig2Bed,genomesize = args[:]
    system(' '.join([wig2bigwig,join(topdir,'chr'+str(i+1)+suffix),genomesize,join(topdir,'chr'+str(i+1)+'.bigWig')]))
    system(' '.join([bigwig2Bed,join(topdir,'chr'+str(i+1)+'.bigWig'),join(topdir,'chr'+str(i+1)+'.bedGraph')]))


if __name__ == "__main__":
    args = parse_args()
    myargs = [ [i,args.topdir,args.suffix,args.wig2bigwig,args.bigwig2Bed,args.genomesize] for i in range(22)]

    pool = mp.Pool(processes=8)
    pool.map(slave,myargs)
    pool.close()
    pool.join()
