#! /bin/bash

python=$1

# Only needed for the Mac due to its crypto-fascist System Integrity Protection
source ../../XSB/packages/xsbpy/px_activate

#if [ -z ${python+x} ];  then 
if [ $# -eq 0 ]
   then
    echo "No Python version specified";
    exit 1 ;
fi

#echo "test LLP: $DYLD_LIBRARY_PATH"

echo "-------------------------------------------------------"
echo "--- Running python_tests/test.sh                    ---"
echo "-------------------------------------------------------"



#if test "$valgrind" = "true"; then
#    echo "valgrind = $valgrind"
#fi

u=`uname`;
#echo "uname for this system is $u";

../pygentest.sh $python px_callbacks.py
../pygentest.sh $python test_cmd_query.py
../pygentest.sh $python test_interrupts.py
echo "Expect slight diffs in test_comps between (...) and (...), due to set creation in Python"
../pygentest.sh $python test_comps.py

#========== the following are non-regression tests ==========

$python test_iterations.py
