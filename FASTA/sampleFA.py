import sys,os

infile = sys.argv[1]
num = sys.argv[2]
outfile = sys.argv[3]

cmd = ' '.join(['paste - - -d\'\\t\'','<',infile,'|','shuf -n',str(num),'|','tr \'\\t\' \'\\n\'','>',outfile])
print cmd
os.system(cmd)
