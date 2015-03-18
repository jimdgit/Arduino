#!/bin/sh

compile_sketch() {
#args:
#$1 board
#$2 file
#$3 log_file
echo test
}

HOME_DIR=`pwd`
LIB_DIRS="$HOME_DIR/libraries/ $HOME_DIR/build/shared/examples/"
AVR_LIB_DIRS="$LIB_DIRS $HOME_DIR/hardware/arduino/avr/libraries/"
SAM_LIB_DIRS="$LIB_DIRS $HOME_DIR/hardware/arduino/sam/libraries/"

AVR_BOARDS="uno, diecimila, mega, nano, leonardo, yun, megaADK, micro, esplora, mini, ethernet, fio, bt, LilyPadUSB, lilypad, pro, atmegang, robotControl, robotMotor"

SAM_BOARDS="arduino_due_x"

git reset HEAD --hard
git clean -dxf
git checkout master
#git pull origin master

mkdir "$HOME_DIR/autotest/"

DATE=`date +%s`
RESULT_FILE="$HOME_DIR/autotest/results_$DATE"
echo `date` > $RESULT_FILE
echo `git log | head -1` >> $RESULT_FILE

#EXAMPLES_INO=`find $AVR_LIB_DIRS | grep "\.ino" | grep -v "inoflag"`

IFS=', ' read -a avr_board_array <<< "$AVR_BOARDS"

cd "$HOME_DIR/build/"
ant clean
ant
ant run

for board in "${avr_board_array[@]}"
do

echo "==========================" >> $RESULT_FILE
echo "Starting with board $board" >> $RESULT_FILE
echo "==========================" >> $RESULT_FILE


for file in `find $AVR_LIB_DIRS | grep "\.ino" | grep -v "inoflag"`
do
	#divide tests into $CPU_COUNT works
	`$HOME_DIR/build/linux/work/arduino --board arduino:avr:$board --verify $file > /dev/null 2>&1`
	RESULT=$?
	echo "$file <-> $board in progress"
	FILENAME=`basename $file`
	if (($RESULT == 0)); then
		echo "PASSED: $FILENAME" >> $RESULT_FILE
	else
		echo "ERROR $RESULT: $FILENAME" >> $RESULT_FILE
	fi
done
done

