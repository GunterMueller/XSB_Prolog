#! /bin/sh

echo "-------------------------------------------------------"
echo "--- Running prolog_tests/test.sh                    ---"
echo "-------------------------------------------------------"

XEMU=$1
options=$2
valgrind=$3

#if test "$valgrind" = "true"; then
    echo "valgrind = $valgrind"
#fi

u=`uname`;
echo "uname for this system is $u";

#VALGRIND
#if test $u  != "" && test "$valgrind" != "true"; then
#    echo "removing xeddis object files"
#    rm -f xeddis.dylib xeddis.so
#    $XEMU -e "catch(consult(compile_xeddis),Ball,(writeln(userout,Ball),halt))."
#    echo "-------------------------------------------------------"
#    else
#    echo "not removing object files"
#    echo "-------------------------------------------------------"
#fi

#------------------------------------
    # XEMU and options must be together in quotes
../nosorttest.sh "$XEMU $options" test_janus_plg "test"
../nosorttest.sh "$XEMU $options" test_py_pp "test"  # no . needed here
echo "-------------------------------------------------------"

$XEMU << EOF
[test_janus_py].

test.
EOF

echo "-------------------------------------------------------"
$XEMU --quietload -e "[jns_plg_benches],bench,halt."
