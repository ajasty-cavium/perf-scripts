#!/bin/sh

WRITE_FILE="perfstat-`date -Isec`.txt"

./perf-30.sh 1 > $WRITE_FILE

./getfg.sh

git stash

git add $WRITE_FILE *.svg

git commit -a -m "Pushing stats."

git push origin cass

