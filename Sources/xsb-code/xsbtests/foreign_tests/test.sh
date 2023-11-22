#! /bin/sh

echo "-------------------------------------------------------"
echo "--- Running nonmswin_tests/test.sh (foreign)        ---"
echo "-------------------------------------------------------"

XEMU=$1
options=$2
valgrind=$3

if test "$valgrind" = "true"; then
    echo "valgrind = $valgrind"
fi

u=`uname`;
echo "uname for this system is $u";

#VALGRIND
if test $u  != "" && test "$valgrind" != "true"; then
    echo "removing xeddis object files"
    rm -f xeddis.dylib xeddis.so
    $XEMU -e "catch(consult(compile_xeddis),Ball,(writeln(userout,Ball),halt))."
    echo "-------------------------------------------------------"
    else
    echo "not removing object files"
    echo "-------------------------------------------------------"
fi

# Doing this here to support valgrind testing.
rm -f unsafe1.xwam
rm -f unsafe2.xwam
rm -f varcond.xwam

# VALGRIND doesn't seem to work on these tests (its Valgrind and not XSB).
OBJEXT=.xwam
os_type=`uname -s`
echo "config tag is $config_tag"

if test "$os_type" = "HP-UX" || test "$config_tag" = "-mt" || test "$valgrind" = "true"; then
	echo "Foreign language interface tests bypassed"
else
#------------------------------------------------------------------------
	rm -f xeddis.o xeddis.so xeddis$OBJEXT
	../gentest.sh "$XEMU $options" cinter1 "test."
#------------------------------------------------------------------------
	rm -f zero.o zero.so zero$OBJEXT
	../gentest.sh "$XEMU $options" cinter2 "test."
#------------------------------------------------------------------------
	rm -f c_calls_xsb.o c_calls_xsb$OBJEXT c_calls_xsb_make$OBJEXT
	../gentest.sh "$XEMU $options" c_calls_xsb_make "test."
#------------------------------------------------------------------------
	rm -f cfixedstring.o c_fixedstring_make$OBJEXT
	../gentest.sh "$XEMU $options" cfixedstring_make "test."
#------------------------------------------------------------------------
	rm -f cvarstring.o c_varstring_make$OBJEXT
	../gentest.sh "$XEMU $options" cvarstring_make "test."
#------------------------------------------------------------------------
	rm -f cregs.o c_regs_make$OBJEXT
	../gentest.sh "$XEMU $options" cregs_make "test."
fi

if test "$valgrind" = "true"; then
	echo "Skipping foreign compilation"
else
rm -f fibr.dylib fibr.so
../gentest.sh "$XEMU $options" fibp "test."
../gentest.sh "$XEMU $options" test_importas "test."
fi

#if test "$valgrind" = "true"; then
#	echo "Skipping cvarconstr_make in table_tests"
#else
# test of C-calling XSB w. constraints.
#../gentest.sh "$XEMU $opts" cvarconstr_make "test."
#fi

# VALGRIND
if test "$valgrind" = "true"; then
	echo "Skipping cvarconstr_make in table_tests"
else
# test of C-calling XSB w. constraints.
../gentest.sh "$XEMU $opts" cvarconstr_make "test."
fi
