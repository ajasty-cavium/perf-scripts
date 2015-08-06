#!/bin/bash

DEVID=$1
NSEC=$2
BS=$3

if [ "x$DEVID" == "x" ]
then
	DEVID="sdb"
fi

if [ "x$NSEC" == "x" ]
then
	NSEC="600"
fi

if [ "x$BS" == "x" ]
then
	BS="4k"
fi

DEVN="$DEVID"
LOGN=fio-`hostname`-FILE
NSEC2=$(($NSEC*2))
FILESZ=$4

fio --name=ssd --numjobs=4 --filename=$DEVN --bs=$BS --iodepth=64 --rw=randwrite --ioengine=libaio --direct=1 --sync=0 --norandommap --group_reporting --runtime=$NSEC2 --time_based --size=$FILESZ| tee $LOGN-readwrite-4.txt

fio --name=ssd --numjobs=4 --filename=$DEVN --bs=$BS --iodepth=64 --rw=randread --ioengine=libaio --direct=1 --sync=0 --norandommap --group_reporting --runtime=$NSEC2 --time_based --size=$FILESZ| tee $LOGN-randread-4.txt

fio --name=ssd --numjobs=1 --filename=$DEVN --bs=$BS --iodepth=1 --rw=randwrite --ioengine=libaio --direct=1 --sync=0 --norandommap --group_reporting --runtime=$NSEC --time_based --size=$FILESZ| tee $LOGN-randwrite-1.txt

fio --name=ssd --numjobs=1 --filename=$DEVN --bs=$BS --iodepth=1 --rw=randread --ioengine=libaio --direct=1 --sync=0 --norandommap --group_reporting --runtime=$NSEC --time_based  --size=$FILESZ| tee $LOGN-randread-1.txt

fio --name=ssd --numjobs=4 --filename=$DEVN --bs=$BS --iodepth=64 --rw=randrw --rwmixwrite=30 --ioengine=libaio --direct=1 --sync=0 --norandommap --group_reporting --runtime=$NSEC2 --time_based  --size=$FILESZ| tee $LOGN-randrw-4.txt
