
VALGRIND_LOG=$1

# Note, the XSB testsuite can be run on Linux as: 
# nohup bash testall.sh -valgrind 'valgrind --dsymutil=yes --ignore-range-below-sp=1024-1 --track-origins=yes <path-to-xsb-executable>' > ~/valgrind.log &
#

echo "Tests completed:  `grep -c 'ERROR SUMMARY' $VALGRIND_LOG | grep -v '0 errors'`"
echo "Errors: "
grep "ERROR SUMMARY"  $VALGRIND_LOG | grep -v '0 errors'
