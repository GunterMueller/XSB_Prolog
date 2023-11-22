#! /bin/sh

echo "-------------------------------------------------------"
echo "--- Running JSON tests json_tests/test.sh         ---"
echo "-------------------------------------------------------"


XEMU=$1
options=$2


../gentest.sh "$XEMU $options" jsontest "test."
