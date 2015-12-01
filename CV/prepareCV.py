### Split the dataset for cross-validation
### Input:
### outdir: the outdir of output folder.This directory will be cleared if it exists already!!!
### CV: the fold of CV
### filedir: The directory of all the files to split
### fileprefix: The prefix of all the files to split.
### filesuffix: The suffix of all the files to split, delimited with '_'. For example, '.txt_.pdf_.ref_.alt'. All the files fileprefix+filesuffix will be row-shuffled and row-split in the same way.
### model: Whether generate valid set. Either 'train_valid_test' or 'train_test'
### outputCVnum: The num of cv to output. For example, CV=5, outputCVnum=1 means split the set into 4:1 but output only one of the five possible splits.
### toshuf: whether to shuff the input files in the same way (Y/N)
import os,sys
from sklearn.cross_validation import KFold

outdir = sys.argv[1]
CV = int(sys.argv[2])
filedir = sys.argv[3]
fileprefix = sys.argv[4]
filesuffix = sys.argv[5]
mode = sys.argv[6]
outputCVnum = int(sys.argv[7])
toshuf = sys.argv[8]

def file_len(fname):
    with open(fname) as f:
        for i, l in enumerate(f):
            pass
        return i + 1

def splitFile(test,train_len,shuffled,data_train,data_valid,data_test):
    os.system(' '.join(['sed ',str(test[0]+1)+','+str(test[-1]+1)+'d',shuffled,'> temp']))
    os.system(' '.join(['head temp -n',str(train_len),'>',data_train]))
    os.system(' '.join(['tail temp -n+'+str(1+train_len),'>',data_valid]))
    os.system('rm temp')
    os.system(' '.join(['sed -n ',str(test[0]+1)+','+str(test[-1]+1)+'p',shuffled,'>',data_test]))

def splitFile_novalid(train,test,shuffled,data_train,data_test):
    os.system(' '.join(['sed ',str(test[0]+1)+','+str(test[-1]+1)+'d',shuffled,'>',data_train]))
    os.system(' '.join(['sed -n ',str(test[0]+1)+','+str(test[-1]+1)+'p',shuffled,'>',data_test]))

if os.path.exists(outdir):
    print('Output folder ' + outdir + ' exists! Will be removed!')
    os.system('rm -r ' + outdir)
os.makedirs(outdir)

if filesuffix == 'NA':
    filesuffix = ''
fileprefix_base = os.path.basename(fileprefix)
suffixes = filesuffix.split('_')
files = [os.path.join(filedir,fileprefix+x) for x in suffixes]
files_shuffled = [x+'.shuffled' for x in files]

### Shuffle the files in the same way
shufseq = ' | shuf ' if toshuf=='Y' else ""
cmd = ' '.join(['paste -d \'!\' '] + files + [shufseq + ' | awk -v FS=\"!\" \'{ '])
cmd = ' '.join([cmd,'print $1 > ','\"'+files_shuffled[0]+'\"'])
for i in range(1,len(files)):
    cmd = ' '.join([cmd,'; print $'+str(i+1),'>','\"'+files_shuffled[i]+'\"'])
cmd = ' '.join([cmd,' }\'' ])
print cmd
os.system(cmd)

### Split into train,valid and test set
kf = KFold(file_len(files[0]), n_folds=CV)
cvcnt = 0
for train,test in kf:
    cvdir = os.path.join(outdir,'CV'+str(cvcnt))
    if not os.path.exists(cvdir):
        os.makedirs(cvdir)

    if mode == 'train_valid_test':
        index_train =  os.path.join(cvdir,'index_train.txt')
        index_valid =  os.path.join(cvdir,'index_valid.txt')
        index_test =  os.path.join(cvdir,'index_test.txt')

        train_len  = int(len(train) *(CV-1)/CV)

        with open(index_train,'w') as f:
            for i in range(train_len):
                f.write(str(train[i]+1)+'\n')

        with open(index_valid,'w') as f:
            for i in range(train_len,len(train)):
                f.write(str(train[i]+1)+'\n')

        with open(index_test,'w') as f:
            for i in xrange(len(test)):
                f.write(str(test[i]+1)+'\n')

        for t_file in files_shuffled:
            fileprefix_base = os.path.basename(t_file)
    	    splitFile(test,train_len,t_file,os.path.join(cvdir,fileprefix_base+'.train'),os.path.join(cvdir,fileprefix_base+'.valid'),os.path.join(cvdir,fileprefix_base+'.test'))
    else:
        for t_file in files_shuffled:
            fileprefix_base = os.path.basename(t_file)
            splitFile_novalid(train,test,t_file,os.path.join(cvdir,fileprefix_base+'.train'),os.path.join(cvdir,fileprefix_base+'.test'))

    cvcnt += 1
    if cvcnt>=outputCVnum:
        break

