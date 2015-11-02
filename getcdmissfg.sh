#!/bin/sh

./perf record -ere6 -F 99 -a -g -- sleep 60
./perf script | ./stackcollapse-perf.pl > perf.folded
./flamegraph.pl perf.folded > "trans-`date -Isec`-`uname -v`.svg"
rm perf.folded perf.data

