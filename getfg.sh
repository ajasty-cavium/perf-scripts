#!/bin/sh

len=$1
if [ "x$len" == "x" ]
then
    len="60"
fi

./perf record -F 99 -a -g -- sleep $1
./perf script | ./stackcollapse-perf.pl > perf.folded
./flamegraph.pl perf.folded > "trans-`date +%s`-`uname -v`.svg"
rm perf.folded perf.data

