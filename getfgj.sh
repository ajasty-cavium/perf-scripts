#!/bin/sh


./perf script -f | ./stackcollapse-perf.pl > perf.folded
./flamegraph.pl perf.folded > "trans-`date +%s`-`uname -v`.svg"
rm perf.folded 

