#! /bin/sh

echo "-------------------------------------------------------"
echo "--- Running MiniZinc tests minizinc/test.sh         ---"
echo "-------------------------------------------------------"


XEMU=$1
options=$2


../gentest.sh "$XEMU $options" mzn_examples "test."
