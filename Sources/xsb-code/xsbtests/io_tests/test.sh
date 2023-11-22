#! /bin/sh

echo "-------------------------------------------------------"
echo "--- Running io_tests/test.sh                        ---"
echo "-------------------------------------------------------"

XEMU=$1
options=$2

# XEMU and options must be together in quotes
../gentest.sh "$XEMU $options" io_basics "test."
../gentest.sh "$XEMU $options" fmt_io "test."
../gentest.sh "$XEMU $options" test_proc_files "test."
#../gentest.sh "$XEMU $options" io_timeout "test."
