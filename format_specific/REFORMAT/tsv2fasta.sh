if [ $# -ne 2]
	then
		echo "No arguments supplied"
		exit 1
fi

tr '\t' '\n' < $1
