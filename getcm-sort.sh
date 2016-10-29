#!/bin/bash

KIMG=~/vmlinux

perf record -F 99 $@
perf script | sed -e 's/(//' -e 's/)//' | awk '{ printf("%s\t%s\t%s\t%s\n", $4, $8, $6, $7); }' | sort -nr > a2l.txt

declare -i TOTAL=0
#myvar TOTAL=0
#TOTAL=0

while read p;
do
    VAL=`echo $p | awk '{print $1; }'`
    if [ $(($VAL > 0)) ]; then
	TOTAL=$(($TOTAL+$VAL))
    fi
done <a2l.txt

cat a2l.txt | while read p; 
do
    ADDR=`echo $p | awk '{ print $3; }'`
    PROG=`echo $p | awk '{ print $2; }'`
    VAL=`echo $p  | awk '{ print $1; }'`
    PCT="$((($VAL*100)/$TOTAL))"
    #echo $p | awk '{ print $3; }'
    #echo "hi $ADDR $PROG"
    if [ $PROG == "[kernel.kallsyms]" ]
    then
	PROG=$KIMG
    fi
    echo -n "$PCT%: "
    if [ -e $PROG ]
    then
	addr2line -e $PROG $ADDR
    fi
done 

