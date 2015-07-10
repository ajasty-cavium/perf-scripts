#!/bin/bash

len=$1
cntval=1
ncores=48
freq=2000000000

if [ "xlen" == "x" ]
then
    len=30
fi

function getcnt {
  cntval=`grep -v Perform /tmp/perf1.out | grep $1 | awk '{ print $1; }' | sed s/,//g `
}

#./getfg.sh

./perf stat -er11 -- sleep 1 2> /tmp/perf1.out
getcnt r11
r11=$cntval
freq=$r11
#msfreq=$(($freq/1000))
msfreq=$freq
echo "freq=$freq, msfreq=$msfreq"

./perf stat -a -er16,r17,r3,r42,r40,re6 -- sleep $len 2> /tmp/perf1.out

getcnt r16
r16=$(($cntval))
getcnt r17
r17=$(($cntval))

getcnt r3
r3=$cntval

getcnt r42
r42=$(($cntval))
getcnt r40
r40=$(($cntval))
getcnt re6
re6=$(($cntval))

echo "r16=$r16 r17=$r17 r3=$r3 r42=$r42 r40=$r40 re6=$re6"

echo "L1 miss rate = $((($r42*100)/$r40))%"
echo "L2 miss rate = $((($r17*100)/$r16))%"
echo "Avg cycles/dmiss = $((($re6*100000)/$r17))"
echo "CDMISS latency = $((($re6 + ($r3*8))/$r3))"
echo "Time spent in CDMISS = $(($re6/(($msfreq)*$ncores)))ms"

./perf stat -a -er1f9,r1fa,r1fb,r193,rdf,r1f2 -- sleep $len 2> /tmp/perf1.out

getcnt r1fb
r1fb=$(($cntval*100000))
getcnt r1fa
r1fa=$(($cntval*1000))

getcnt r1f2
r1f2=$cntval
getcnt rdf
rdf=$cntval

getcnt r193
r193=$cntval

echo "STX fail rate = $(($r1fa/$r1fb))%"

echo "DMB instructions issued = $r1f2"
echo "STR stalls on NOWBUFS = $rdf"
echo "Cycles spent in PTW = $r193 / $(($r193/(($msfreq)*$ncores)))ms"

./perf stat -a -erce,rcc,rc8,r90,r68,r2d -- sleep $len 2> /tmp/perf1.out

getcnt rce
rce=$cntval
getcnt rcc
rcc=$cntval
getcnt rc8
rc8=$cntval
getcnt r90
r90=$cntval
getcnt r68
r68=$cntval
getcnt r2d
r2d=$cntval
echo "rce=$rce rcc=$rcc rc8=$rc8 r90=$r90 r68=$r68 r2d=$r2d"

./perf stat -a -er23,r24,ref,r1a,r10,rd8 -- sleep $len 2> /tmp/perf1.out

getcnt r23
r23=$cntval
getcnt r24
r24=$cntval
getcnt ref
ref=$cntval
getcnt r1a
r1a=$cntval
getcnt r10
r10=$cntval
getcnt rd8
rd8=$cntval
echo "r23=$r23 r24=$r24 ref=$ref r1a=$r1a r10=$r10 rd8=$rd8"

echo "Backend stall time = $(($r24/($msfreq*$ncores)))ms"
echo "icache stall time = $(($rd8/($msfreq*$ncores)))ms"
echo "throttle stall time = $(($ref/($msfreq*$ncores)))ms"
echo "Unaligned replay penalty = $((($rcc*8)/($msfreq*$ncores)))ms"

./perf stat -a -ercf,re7,r187,re8,rc7,r7a -- sleep $len 2> /tmp/perf1.out

getcnt rcf
rcf=$cntval
getcnt re7
re7=$cntval
getcnt r187
r187=$cntval
getcnt re8
re8=$cntval
getcnt rc7
rc7=$cntval
getcnt r7a
r7a=$cntval

echo "rcf=$rcf re7=$re7 r187=$r187 re8=$re8 rc7=$rc7 r7a=$r7a"

./perf stat -a -er1b,rf,r10,r70,rde,r71 -- sleep $len 2> /tmp/perf1.out

getcnt r1b
r1b=$cntval
getcnt rf
rf=$cntval
getcnt r10
r10=$cntval
getcnt r70
r70=$cntval
getcnt rde
rde=$cntval
getcnt r71
r71=$cntval

echo "r1b=$r1b rf=$rf r10=$r10 r70=$r70 rde=$rde r71=$r71"
./perf stat -a -erc2,rc3,rc4,rc1,rc0,r11 -- sleep $len 2> /tmp/perf1.out

getcnt rc2
rc2=$cntval
getcnt rc3
rc3=$cntval
getcnt rc4
rc4=$cntval
getcnt rc1
rc1=$cntval
getcnt rc0
rc0=$cntval
getcnt r11
r11=$cntval

echo "rc2=$rc2 rc3=$rc3 rc4=$rc4 rc5=$rc1 rc0=$rc0 r11=$r11"

iclk=$(($rc0/100))
issp=$(($rc1/100))
echo "Issue clk% = $((($rc0*100)/$r11))"
echo "0 issue cycles = $(($rc2/$iclk))"
echo "1 issue cycles = $(($rc3/$iclk))"
echo "2 issue cycles = $(($rc4/$iclk))"

echo "Single-issued instruction% = $(($rc3/$issp))"
echo "Double-issued instruction% = $((($rc4/$issp)*2))"

./perf stat -a -er5,rde,r8,r6,r7,rc -- sleep $len 2> /tmp/perf1.out

getcnt r5
r5=$cntval
getcnt rde
rde=$cntval
getcnt r8
r8=$cntval
getcnt r6
r6=$cntval
getcnt r7
r7=$cntval
getcnt rc
rc=$cntval

echo "r5=$r5 rde=$rde r3=$r3 re6=$re6 r8=$r8 r6=$r6 r7=$r7 rc=$rc"

./perf stat -a -er1b,rb -- sleep $len 2> /tmp/perf1.out
getcnt r1b
r1b=$cntval
getcnt rb
rb=$cntval

echo "r1b=$r1b rb=$rb ipc=$((($r8*100)/$rc0))    \n\n"

