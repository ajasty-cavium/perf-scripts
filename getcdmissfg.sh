#!/bin/sh

./perf record -ere6 -F 99 -a -g -- sleep $1
./perf script | ./stackcollapse-perf.pl > perf.folded
./flamegraph.pl perf.folded > "trans-cd-`date +s`-`uname -v`.svg"
rm perf.folded perf.data

