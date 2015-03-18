#!/bin/sh

active_jobs=0

compile_board() {
#args:
#$1 board
#$2 libs
#$3 log_file_basename

let active_jobs=active_jobs+1
echo "==========================" >> $3_$1
echo "Starting with board $1" >> $3_$1
echo "==========================" >> $3_$1

local file
for file in `find $2 | grep "\.ino" | grep -v "inoflag"`
do
	#divide tests into $CPU_COUNT works
	`$HOME_DIR/build/linux/work/arduino --board arduino:avr:$1 --verify $file > /dev/null 2>&1`
	local RESULT=$?
	echo "$file <-> $board in progress"
	FILENAME=`basename $file`
	if (($RESULT == 0)); then
		echo "PASSED: $FILENAME" >> $3_$1
	else
		echo "ERROR $RESULT: $FILENAME" >> $3_$1
	fi
done
let active_jobs=active_jobs-1
}

HOME_DIR=`pwd`
LIB_DIRS="$HOME_DIR/libraries/ $HOME_DIR/build/shared/examples/"
AVR_LIB_DIRS="$LIB_DIRS $HOME_DIR/hardware/arduino/avr/libraries/"
SAM_LIB_DIRS="$LIB_DIRS $HOME_DIR/hardware/arduino/sam/libraries/"

AVR_BOARDS="uno, diecimila, mega, nano, leonardo, yun, megaADK, micro, esplora, mini, ethernet, fio, bt, LilyPadUSB, lilypad, pro, atmegang, robotControl, robotMotor"

SAM_BOARDS="arduino_due_x"

git reset HEAD --hard
#git clean -dxf
git checkout master
#git pull origin master

mkdir "$HOME_DIR/autotest/"

DATE=`date +%s`
RESULT_FILE="$HOME_DIR/autotest/results_$DATE"
echo `date` > $RESULT_FILE
echo `git log | head -1` >> $RESULT_FILE

#EXAMPLES_INO=`find $AVR_LIB_DIRS | grep "\.ino" | grep -v "inoflag"`

CPU_NUM=`nproc`

IFS=', ' read -a avr_board_array <<< "$AVR_BOARDS"

cd "$HOME_DIR/build/"
ant clean
ant

for board in "${avr_board_array[@]}"
do
	echo "active_jobs: $active_jobs"
	if [ $active_jobs -lt $CPU_NUM ]; then
		compile_board $board $AVR_LIB_DIRS $RESULT_FILE &
	else
		sleep 10
	fi
done

