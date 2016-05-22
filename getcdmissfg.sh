#!/bin/sh

len=$1
if [ "x$len" == "x" ]
then
    len="60"
fi

./perf record -ere6 -F 99 -a -g -- sleep $len
./perf script | ./stackcollapse-perf.pl > perf.folded
./flamegraph.pl perf.folded > "trans-cd-`date +s`-`uname -v`.svg"
rm perf.folded perf.data

