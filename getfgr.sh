#!/bin/sh

len=$2
if [ "x$len" == "x" ]
then
    len="60"
fi

./perf record -F 99 -er$1 -a -g -- sleep $len
./perf script | ./stackcollapse-perf.pl > perf.folded
./flamegraph.pl perf.folded > reg-$1-`date -Isec`.svg
rm perf.folded perf.data

