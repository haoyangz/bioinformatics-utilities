if [ $# -ne 2]
	then
		echo "No arguments supplied"
		exit 1
fi

paste - - -d'\t' < $1 > $3
