#!/bin/sh

HOME_DIR=`pwd`
LIB_DIRS="$HOME_DIR/libraries/ $HOME_DIR/build/shared/examples/"
AVR_LIB_DIRS="$LIB_DIRS $HOME_DIR/hardware/arduino/avr/libraries/"
SAM_LIB_DIRS="$LIB_DIRS $HOME_DIR/hardware/arduino/sam/libraries/"

active_jobs=0

compile_board() {
#args:
#$1 board
#$2 log_file_basename

echo "==========================" >> $2_$1
echo "Starting with board $1" >> $2_$1
echo "==========================" >> $2_$1

local file
for file in `find $AVR_LIB_DIRS | grep "\.ino" | grep -v "inoflag"`
do
	FILENAME=`basename $file`
	echo $FILENAME >> $2_$1
	#divide tests into $CPU_COUNT works
	`$HOME_DIR/build/linux/work/arduino --board arduino:avr:$1 --verify $file 2> /dev/null 1> /tmp/$FILENAME$board.tmp`
	local RESULT=$?
	echo "$file <-> $board in progress"
	FLASH=`cat /tmp/$FILENAME$board.tmp | grep program | cut -f3 -d" "`
	RAM=`cat /tmp/$FILENAME$board.tmp | grep dynamic | cut -f4 -d" "`
	if (($RESULT == 0)); then
		echo "PASSED $FLASH $RAM" >> $2_$1
	else
		echo "FAILED $RESULT" >> $2_$1
	fi
done
}

AVR_BOARDS="uno, diecimila, mega, nano, leonardo, yun, megaADK, micro, esplora, mini, ethernet, fio, bt, LilyPadUSB, lilypad, pro, atmegang, robotControl, robotMotor"

SAM_BOARDS="arduino_due_x"

#git reset HEAD --hard
#git clean -dxf
#git checkout master
#git pull origin master

mkdir "$HOME_DIR/autotest/"

DATE=`date +%s`
RESULT_FILE="$HOME_DIR/autotest/results_$DATE"
echo `date` > $RESULT_FILE
echo `git log | head -1` >> $RESULT_FILE

#EXAMPLES_INO=`find $AVR_LIB_DIRS | grep "\.ino" | grep -v "inoflag"`

CPU_NUM=`nproc`
HEADLESS=0

while getopts ":v:b:" opt; do
	case $opt in
		b)
			AVR_BOARDS=$OPTARG
			echo "Compiling only for board $AVR_BOARDS"
			;;
		v)
			if [ $OPTARG == "headless" ]; then
				HEADLESS=1
			fi
			;;
	esac
done

IFS=', ' read -a avr_board_array <<< "$AVR_BOARDS"

cd "$HOME_DIR/build/"
ant clean
ant

#need an X11 display
if [ $HEADLESS -eq 1 ]; then
	VNC_SERVER=`which vncserver`
	if [ x$VNC_SERVER == "x" ]; then
		echo "Please install vnc4server"
		echo "sudo apt-get install vnc4server"
	else
		vncserver :1001
		export DISPLAY=localhost:1001
	fi
fi

for board in "${avr_board_array[@]}"
do
	echo "active_jobs: $active_jobs"
	if [ $active_jobs -lt $CPU_NUM ]; then
		let active_jobs=active_jobs+1
		compile_board $board $RESULT_FILE &
	else
		wait
		compile_board $board $RESULT_FILE &
		active_jobs=1
	fi
done

#wait for all commands to complete
wait

#merge files!
cat $RESULT_FILE_* >> $RESULT_FILE

#analysis
PASSED_T=`cat $RESULT_FILE | grep PASSED | wc -l`
FAILED_T=`cat $RESULT_FILE | grep FAILED | wc -l`
PASS_PERC=`echo "$PASSED_T * 100 / ($PASSED_T + $FAILED_T) " | bc`
echo "TOTAL PASSED: $PASSED_T  TOTAL FAILED: $FAILED_T  ($PASS_PERC %)"
