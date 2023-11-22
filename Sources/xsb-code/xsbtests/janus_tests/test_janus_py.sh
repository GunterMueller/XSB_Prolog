#! /bin/bash

python=$1

# Only needed for the Mac due to its crypto-fascist System Integrity Protection
source ../../XSB/packages/janus/janus_activate

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

../pygentest.sh $python jns_callbacks.py
../pygentest.sh $python test_cmd_apply_once.py
../pygentest.sh $python test_interrupts.py
../pygentest.sh $python test_comps.py
../pygentest.sh $python test_query_once.py
../pygentest.sh $python test_Apply.py
../pygentest.sh $python test_Query.py
#../pygentest.sh $python test_returnval_py.py

#========== the following are non-regression tests ==========
echo '--------------------------------------------------------------------'
$python jns_py_benches.py
