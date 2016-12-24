#!/bin/bash

len=$2
if [ "x$len" == "x" ]
then
    len="60"
fi

tag=$3
if [ "x$tag" == "x" ]
then
    tag="base"
fi

./perf record -F 99 -er$1 -g -- ./a.out $len
./perf script | ./stackcollapse-perf.pl > perf.folded
./flamegraph.pl perf.folded > reg-$1-$tag-`date -Isec`.svg
rm perf.folded perf.data

