if [ $# -ne 2 ]
	then
		echo "No arguments supplied"
		exit 1
fi

TMP_file1=/tmp/tmp1.$$
TMP_file2=/tmp/tmp2.$$
TMP_file3=/tmp/tmp3.$$
reformat_dir=/cluster/zeng/code/research/tools/format_specific/REFORMAT
$reformat_dir/vcf2bed.sh $1 > $TMP_file1
$reformat_dir/vcf2bed.sh $2 > $TMP_file2
bedtools intersect -wa -a $TMP_file1 -b $TMP_file2 > $TMP_file3
$reformat_dir/bed2vcf.sh $TMP_file3

rm -f $TMP_file1 $TMP_file2 $TMP_file3
