if [ $# -ne 1]
	then
		echo "No arguments supplied"
		exit 1
fi

paste - - -d'\t' < $1
