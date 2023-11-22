#! /bin/sh

echo "-------------------------------------------------------"
echo "--- Running symbol_tests/test.sh                    ---"
echo "-------------------------------------------------------"

XEMU=$1
NUM=$2
options=$3

#------------------------------------
# tests involving WAM execution
#------------------------------------
# XEMU and options must be together in quotes
# convention is that to use test_single, leave the last argument of test
# goal uninstantiated to unify with the stream.

../gentest.sh "$XEMU $options" f1 "write_f(_)" $NUM
../gentest.sh "$XEMU $options" symtabtest "test(_)" $NUM
