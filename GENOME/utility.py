def ReverseComplement1(seq,concat):
    seq_dict = {'A':'T','T':'A','G':'C','C':'G'}
    X = [seq_dict[base] for base in reversed(seq)]
    if concat:
        return "".join(X)
    else:
        return X

def readGenome(genomefile,regions):
    # regions is 2D array where each element contains the start pos and end pos
    # of a query region. The position should be 1-based
    out = []
    for region in regions:
        region_s,region_e = region[:]
        with open(genomefile,'rb') as f:
            f.seek(region_s-1)
            out.append(map(ord,f.read(region_e - region_s+1)))
    return out
