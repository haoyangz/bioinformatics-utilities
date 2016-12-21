if [ $# -ne 2]
	then
		echo "No arguments supplied"
		exit 1
fi

TMP_file1=/tmp/tmp1.$$

/cluster/zeng/code/research/tools/REFORMAT/vcf2bed.sh $2 > $TMP_file1
bedtools intersect -wa -a $1 -b $TMP_file1

rm -f $TMP_file1
