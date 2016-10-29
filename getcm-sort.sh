#!/bin/bash

KIMG=~/vmlinux

perf record -F 99 $@
perf script | sed -e 's/(//' -e 's/)//' | awk '{ printf("%s\t%s\t%s\t%s\n", $4, $8, $6, $7); }' | sort -nr > a2l.txt

cat a2l.txt | while read p; 
do
    ADDR=`echo $p | awk '{ print $3; }'`
    PROG=`echo $p | awk '{ print $2; }'`
    #echo $p | awk '{ print $3; }'
    #echo "hi $ADDR $PROG"
    if [ $PROG == "[kernel.kallsyms]" ]
    then
	PROG=$KIMG
    fi
    if [ -e $PROG ]
    then
	addr2line -e $PROG $ADDR
    fi
done 

