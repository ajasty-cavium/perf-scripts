#!/bin/sh

./perf record -F 99 -a -g -- sleep 120
./perf script | ./stackcollapse-perf.pl > perf.folded
./flamegraph.pl perf.folded > trans-`date -Isec`.svg
rm perf.folded perf.data

