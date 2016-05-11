def ReverseComplement1(seq,concat):
    seq_dict = {'A':'T','T':'A','G':'C','C':'G'}
    X = [seq_dict[base] for base in reversed(seq)]
    if concat:
        return "".join(X)
    else:
        return X

def readGenome(genomefile,regions,mapper=''):
    # regions is 2D array where each element contains the start pos and end pos
    # of a query region. The position should be 1-based
    with open(genomefile,'rb') as f:
        out = []
        for region in regions:
            region_s,region_e = region[:]
            f.seek(region_s-1)
            seq = map(ord,f.read(region_e - region_s+1))
            if mapper != '':
                seq = [mapper[x] for x in seq]
            out.append(seq)
    return out

def oneHot(keys):
    mapper = {}
    keys_num = len(keys)
    for idx in range(len(keys)):
        mapper[keys[idx]] = [0 if x!=idx else 1 for x in range(keys_num)]
    return mapper
