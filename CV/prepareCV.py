### Split the dataset for cross-validation
### Input:
### topdir: the topdir of output folder
### CV: the fold of CV
### fileprefix: The prefix of all the files to split. This should contain both directory and the file prefix
### filesuffix: The suffix of all the files to split, delimited with '_'. For example, '.txt_.pdf_.ref_.alt'

import os,sys
from sklearn.cross_validation import KFold

topdir = sys.argv[1]
CV = int(sys.argv[2])
fileprefix = sys.argv[3]
filesuffix = sys.argv[4]

def file_len(fname):
    with open(fname) as f:
        for i, l in enumerate(f):
            pass
        return i + 1

def splitFile(test,train_len,shuffed,data_train,data_valid,data_test):
    os.system(' '.join(['sed ',str(test[0]+1)+','+str(test[-1]+1)+'d',shuffed,'> temp']))
    os.system(' '.join(['head temp -n',str(train_len),'>',data_train]))
    os.system(' '.join(['tail temp -n+'+str(1+train_len),'>',data_valid]))
    os.system('rm temp')
    os.system(' '.join(['sed -n ',str(test[0]+1)+','+str(test[-1]+1)+'p',shuffed,'>',data_test]))

if not os.path.exists(topdir):
        os.makedirs(topdir)

fileprefix_base = os.path.basename(fileprefix)
suffixes = filesuffix.split('_')
files = [fileprefix+x for x in suffixes]
files_shuffed = [x+'.shuffed' for x in files]

### Shuffle the files in the same way
cmd = ' '.join(['paste -d \'!\' '] + files + [' |  shuf | awk -v FS=\"!\" \'{ '])
cmd = ' '.join([cmd,'print $1 > ','\"'+files_shuffed[0]+'\"'])
for i in range(1,len(files)):
    cmd = ' '.join([cmd,'; print $'+str(i+1),'>','\"'+files_shuffed[i]+'\"'])
cmd = ' '.join([cmd,' }\'' ])
print cmd
os.system(cmd)

### Split into train,valid and test set
kf = KFold(file_len(files[0]), n_folds=CV)
cvcnt = 0
for train,test in kf:
    cvdir = os.path.join(topdir,'CV'+str(cvcnt))
    if not os.path.exists(cvdir):
        os.makedirs(cvdir)

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

    for t_file in files_shuffed:
        fileprefix_base = os.path.basename(t_file)
	splitFile(test,train_len,t_file,os.path.join(cvdir,fileprefix_base+'.train'),os.path.join(cvdir,fileprefix_base+'.valid'),os.path.join(cvdir,fileprefix_base+'.test'))

    cvcnt += 1
