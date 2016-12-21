if [ $# -ne 3 ]
	then
		echo "No arguments supplied"
		exit 1
fi

paste - - -d'\t' < $1 | shuf -n $2 | tr '\t' '\n' > $3
