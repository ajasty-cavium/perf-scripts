#!/bin/sh

./perf record -F 99 -er$1 -a -g -- sleep 20
./perf script | ./stackcollapse-perf.pl > perf.folded
./flamegraph.pl perf.folded > reg-$1-`date -Isec`.svg
rm perf.folded perf.data

