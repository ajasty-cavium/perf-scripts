PERFBIN=../sdk.build/linux-aarch64/tools/perf/perf
echo "Gathering CDMISS"
sudo $PERFBIN record -ere6 -c 250000 -g -a -- sleep 2
sudo $PERFBIN script | ./stackcollapse-perf.pl > perf.folded
./flamegraph.pl perf.folded > CDMISS-`date -Isec`.svg
rm perf.folded perf.data

echo "Gathering CIMISS"
sudo $PERFBIN record -erd8 -c 250000 -g -a -- sleep 2
sudo $PERFBIN script | ./stackcollapse-perf.pl > perf.folded
./flamegraph.pl perf.folded > CIMISS-`date -Isec`.svg
rm perf.folded perf.data
