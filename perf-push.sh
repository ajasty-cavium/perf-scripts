#!/bin/sh

WRITE_FILE="perfstat-`date -Isec`.txt"

sudo ./perf-30.sh 30 > $WRITE_FILE

./upload.sh $WRITE_FILE

#./getfg.sh

#git stash

#git add $WRITE_FILE *.svg

#git commit -a -m "Pushing stats."

#git push origin cass

