#!/bin/bash


./perf record -g -- $@
./perf script | ./stackcollapse-perf.pl > perf.folded
./flamegraph.pl perf.folded > "trans-`date +%s`-`uname -v`.svg"
echo "trans-`date +%s`-`uname -v`.svg"
rm perf.folded perf.data

