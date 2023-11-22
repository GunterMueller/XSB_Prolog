#! /bin/sh

XEMU=$1
NUM=$2
options=$3

echo "------------------------------------------------------"
echo "--- Running shared_tests/test.sh w. $NUM threads   ---"
echo "------------------------------------------------------"

#------------------------------------
# tests involving definite tabling
#------------------------------------
# XEMU and options must be together in quotes
# convention is that to use test_single, leave the last argument of test
# goal uninstantiated to unify with the stream.

../gentest.sh "$XEMU $options" sharedcomp1 "sc(1000,_)" $NUM
../gentest.sh "$XEMU $options" sharedcomp2 "sc(1000,_)" $NUM
../gentest.sh "$XEMU $options" sharedpriv1 "spfail(_)" $NUM
../gentest.sh "$XEMU $options" sharedpriv2 "spfail(_)" $NUM
../gentest.sh "$XEMU $options" sharedpriv3 "spone(_)" $NUM
../gentest.sh "$XEMU $options" sharedpriv4 "spone(_)" $NUM
../gentest.sh "$XEMU $options" sharedpriv5 "spone(_)" $NUM
../gentest.sh "$XEMU $options" sharedpriv6 "spmany(_)" $NUM
../gentest.sh "$XEMU $options" sharedpriv7 "spmany(_)" $NUM


