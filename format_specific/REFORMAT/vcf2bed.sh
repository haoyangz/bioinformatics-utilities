if [ $# -ne 1 ]
	then
		echo "No arguments supplied"
		exit 1
fi

sed '/^#/d' $1 | awk -F'\t' '{$1="chr"$1;$2=$2-1 FS $2;}1' OFS='\t'
