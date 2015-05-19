#!/usr/bin/env bash

# sparkのインストールが必要です
# >brew install spark
#

#Parameters
NBINS=20
INTERVAL=1
PROCESSES=("firefox")

#Set process
if [ $# -gt 0 ];then
  PROCESSES=("$@")
fi

#Prepare initial bins
for i in $(seq 0 $((${#PROCESSES[@]}-1)));do
  eval bins_${i}=\(\)
  for j in $(seq 1 $NBINS);do
    eval bins_${i}=\(\${bins_${i}[@]} 0\)
  done
done
bins=()

#FInalization
finalize(){
  #Show cursor
  tput cnorm > /dev/tty 2> /dev/null || tput vs > /dev/tty 2> /dev/null
  #Show input
  stty echo
  #Go to the clean line
  echo
}

#Set trap
trap "finalize;echo;exit" HUP INT QUIT ABRT SEGV TERM

#Hide cursor/input
tput civis > /dev/tty 2> /dev/null || tput vi > /dev/tty 2> /dev/null
stty -echo

#Main loop
while [ 1 ];do
  for i in $(seq 0 $((${#PROCESSES[@]}-1)));do
    cpu=$(ps ax -o %cpu -o comm|grep "${PROCESSES[$i]}\$"|head -1|awk '{print $1}')
    eval bins_${i}=\(\${bins_${i}[@]:1} \$cpu\)
    printf "%${NBINS}s %4s%% ${PROCESSES[$i]}\n" "$(spark $(eval echo \${bins_${i}[@]}) 100)$(tput cub 1)" $cpu
    tput cub $((NBINS+6))
  done
  tput cuu ${#PROCESSES[@]}
  sleep $INTERVAL
done


