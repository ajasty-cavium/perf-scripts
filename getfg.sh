#!/bin/sh

./perf42 record -F 99 -a -g -- sleep 30
./perf42 script | ./stackcollapse-perf.pl > perf.folded
./flamegraph.pl perf.folded > "trans-`date +%s`-`uname -v`.svg"
rm perf.folded perf.data

