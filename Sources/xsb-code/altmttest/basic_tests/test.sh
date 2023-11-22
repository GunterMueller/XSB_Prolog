#! /bin/sh

echo "-------------------------------------------------------"
echo "--- Running basic_tests/test.sh                     ---"
echo "-------------------------------------------------------"

XEMU=$1
NUM=$2
options=$3

#TLS: should factor out gctest,altindex and longname, as these require just 1 thread.

    # XEMU and options must be together in quotes
../gentest.sh "$XEMU $options" tsstr13 "test(_)" $NUM
../gentest.sh "$XEMU $options" tsstr23 "test(_)" $NUM
../gentest.sh "$XEMU $options" tsstr33 "test(_)" $NUM
#------------------------------------
# simplest series
#------------------------------------
../gentest.sh "$XEMU $options" tstr11 "test(_)" $NUM
../gentest.sh "$XEMU $options" tstr21 "test(_)" $NUM
../gentest.sh "$XEMU $options" tstr31 "test(_)" $NUM
../gentest.sh "$XEMU $options" tstr51 "test(_)" $NUM
../gentest.sh "$XEMU $options" tstr61 "test(_)" $NUM
#------------------------------------
# simple series
#------------------------------------
../gentest.sh "$XEMU $options" tstr12 "test(_)" $NUM
../gentest.sh "$XEMU $options" tstr22 "test(_)" $NUM
../gentest.sh "$XEMU $options" tstr32 "test(_)" $NUM
../gentest.sh "$XEMU $options" tstr52 "test(_)" $NUM
../gentest.sh "$XEMU $options" tstr62 "test(_)" $NUM
#------------------------------------
# transitive closure series
#------------------------------------
../gentest.sh "$XEMU $options" tstr13 "test(_)" $NUM
../gentest.sh "$XEMU $options" tstr23 "test(_)" $NUM
../gentest.sh "$XEMU $options" tstr33 "test(_)" $NUM
../gentest.sh "$XEMU $options" tstr53 "test(_)" $NUM
../gentest.sh "$XEMU $options" tstr63 "test(_)" $NUM
#------------------------------------
# loader/compiler series
#------------------------------------
../gentest.sh "$XEMU $options" thstr13 "test(_)"  $NUM
../gentest.sh "$XEMU $options" thstr43 "test(_)"  $NUM
#------------------------------------
# simple levels series
#------------------------------------
../gentest.sh "$XEMU $options" thstr23 "test(_)"  $NUM
#------------------------------------
# cylinder series
#------------------------------------
../gentest.sh "$XEMU $options" tcyl11 "test(_)"  $NUM
../gentest.sh "$XEMU $options" tcyl12 "test(_)"  $NUM
../gentest.sh "$XEMU $options" testsg "test(_)"  $NUM
#------------------------------------
# interpreter series.
#------------------------------------
../gentest.sh "$XEMU $options" interp "test(_)"  $NUM
#------------------------------------
# tabletrysingle tests.
#------------------------------------
../gentest.sh "$XEMU $options" tsing1 "test(_)"  $NUM
#--------------------------------
# h series is hilog/tabling tests
#------------------------------------
../gentest.sh "$XEMU $options" hirc "test(_)"  $NUM
#------------------------------------
../gentest.sh "$XEMU $options" findall "test(Str)"  $NUM
#------------------------------------
#../gentest.sh "$XEMU $options" altindex "test(Str)"  $NUM
#------------------------------------
#../gentest.sh "$XEMU $options" longname "test(Str)"  $NUM
#------------------------------------
#../gentest.sh "$XEMU $options" gctest "test(Str)"  $NUM
