if [ $# -ne 1 ]
	then
		echo "No arguments supplied"
		exit 1
fi


sed -n 's/chr//gp' $1 | sed 's/^\([0-9]*\t\)[0-9]*\t\([0-9]*\)/\1\2/'
