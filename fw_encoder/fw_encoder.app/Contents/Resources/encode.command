#!/bin/bash

echo $1


declare -a PARAMS



# kenny only change below


PARAMS[2]="-e x264 --x264-profile baseline -x level=3.0 -w 1280 -l 720 -r 15 -b 800 --two-pass --turbo --decomb -R 24 -B 32" 

PARAMS[1]="-e x264 --x264-profile baseline -x level=3.0 -w 1024 -l 576 -r 15 -b 600 --two-pass --turbo --decomb -R 24 -B 32"

PARAMS[3]="-e x264 --x264-profile baseline -x level=3.0 -w 640 -l 360 -r 15 -b 300 --two-pass --turbo --decomb -R 24 -B 32"


# kenny never change below




	for i in 1 2 3
	do
		file=$1"/"$i".mp4"
		echo "======converting "$0" to "$file" ========="
		echo
		HandBrakeCLI -i "$0" -o "$file" ${PARAMS[$i]}
	done


ALERT="Kenny, All your videos are been converted successfully! Have Fun!"

echo
echo $ALERT
echo
echo Done!
echo
echo
echo "   /--------/"
echo "  /        /"
echo "          /"
echo "         /"
echo "        /"
echo "       /"
echo "      /"
echo "     /"
echo "    /"
echo
echo

say $ALERT