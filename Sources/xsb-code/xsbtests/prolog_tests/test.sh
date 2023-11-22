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

# Doing this here to support valgrind testing.
rm -f unsafe1.xwam
rm -f unsafe2.xwam
rm -f varcond.xwam

#------------------------------------
# tests involving standard predicates
#------------------------------------
    # XEMU and options must be together in quotes
../gentest.sh "$XEMU $options" test_modules "test."
../gentest.sh "$XEMU $options" arith_op "test."
../gentest.sh "$XEMU $options" test_precision "test."
../gentest.sh "$XEMU $options" std1 "test."
../gentest.sh "$XEMU $options" std2 "test."
#------------------------------------
# Test reading from strings
#------------------------------------
../gentest.sh "$XEMU $options" readstrtest "test."
#------------------------------------
# Test number_chars
#------------------------------------
../gentest.sh "$XEMU $options" n2c "test."
#------------------------------------
# keep the compiler honest
#------------------------------------
../gentest.sh "$XEMU $options" first "test."
../gentest.sh "$XEMU $options" newfirst "test."
#-----------------------------------------------------------------------
# the following make sure that the compiler will produce the right code
#-----------------------------------------------------------------------
../gentest.sh "$XEMU $options" inline "go."
../gentest.sh "$XEMU $options" unsafe1 "test."
../gentest.sh "$XEMU $options" unsafe2 "test."
../gentest.sh "$XEMU $options" varcond "test."
#-----------------------------------------------------------------------
# the following two tests are used to test multifile directive
#-----------------------------------------------------------------------
#------------------------------------
# Just to create some OBJ files that
# will be used later in multifile test
#------------------------------------
../gentest.sh "$XEMU $options" mf_obj "do."
#------------------------------------
# Test multifile directive
#------------------------------------
../gentest.sh "$XEMU $options" mf_test1 "test."
#------------------------------------
# Test reading constant characters
#------------------------------------
../gentest.sh "$XEMU $options" con_char "test."
#------------------------------------
# Test evaluable functions
#------------------------------------
../gentest.sh "$XEMU $options" conv_fun "test."
#------------------------------------
# Test format library
#------------------------------------
../gentest.sh "$XEMU $options" format_test "test."
#------------------------------------
# Test listing/0
#------------------------------------
../gentest.sh "$XEMU $options" listing_test "test."

#------------------------------------
# Test write_term library
#------------------------------------
../gentest.sh "$XEMU $options" wttest "test."

#------------------------------------
# Test writeq, write_canonical, and read library
#------------------------------------
../gentest.sh "$XEMU $options" test_write_read "test."

#------------------------------------
# Rare specialization bug test
#------------------------------------
../gentest.sh "$XEMU $options" spec_tbl_fold_bug "test."

#------------------------------------
# unify_with_occurs_check test
#------------------------------------
../gentest.sh "$XEMU $options" uwoc "test."

#------------------------------------
# term_to_atom test
#------------------------------------
../gentest.sh "$XEMU $options" test_termtoatom "test."

#------------------------------------
# include/1 test
#------------------------------------
../gentest.sh "$XEMU $options" include_test "test."

#------------------------------------------------------------------------
../gentest.sh "$XEMU $options" test_cleanup "test."

#------------------------------------------------------------------------
../gentest.sh "$XEMU $options" test_forall "test."

#------------------------------------------------------------------------
../gentest.sh "$XEMU $options" test_aggregates "test."
#------------------------------------------------------------------------
../gentest.sh "$XEMU $options" test_term_depth "test."
#------------------------------------------------------------------------
../gentest.sh "$XEMU $options" test_cycle "test."
#------------------------------------------------------------------------
../gentest.sh "$XEMU $options" test_term_size "test."
#------------------------------------------------------------------------
../gentest.sh "$XEMU $options" test_sprint_term "test."
#------------------------------------------------------------------------
#../gentest.sh "$XEMU $options" test_memory_ovrflw_1 "first_test."
#------------------------------------------------------------------------
#../gentest.sh "$XEMU $options" test_memory_ovrflw_2 "second_test."

#------------------------------------
# test call/n
#------------------------------------
#------------------------------------------------------------------------
../gentest.sh "$XEMU $options" call_tests "test."
#------------------------------------------------------------------------
../gentest.sh "$XEMU $options" test_read_integer "test."
#------------------------------------------------------------------------
../gentest.sh "$XEMU $options" test_utf8_getput "test."
#------------------------------------------------------------------------
../gentest.sh "$XEMU $options" test_utf8_readwrite "test."
#------------------------------------------------------------------------
../gentest.sh "$XEMU $options" test_utf8_atom "test."
#------------------------------------------------------------------------
../gentest.sh "$XEMU $options" test_ascii_getput "test."
#------------------------------------------------------------------------
../gentest.sh "$XEMU $options" test_ascii_readwrite "test."
#------------------------------------------------------------------------
../gentest.sh "$XEMU $options" test_ascii_atom "test."
#------------------------------------------------------------------------
../gentest.sh "$XEMU $options" test_charset "test."
#------------------------------------------------------------------------
../gentest.sh "$XEMU $options" test_arith_errors "test."
#------------------------------------------------------------------------
../gentest.sh "$XEMU $options" test_dphc "test."
#------------------------------------------------------------------------
../gentest.sh "$XEMU $options" large_arity_prolog "test."
#------------------------------------------------------------------------
../gentest.sh "$XEMU $options" functor4_tests "test."
#------------------------------------------------------------------------
../gentest.sh "$XEMU $options" range_tree_tests "test."
#------------------------------------------------------------------------
../gentest.sh "$XEMU $options" test_large_atom_codes "test."
#------------------------------------------------------------------------
../gentest.sh "$XEMU $options" test_iso8601 "test."
#------------------------------------------------------------------------
if test "$valgrind" = "true"; then
    echo "Valgrind is too slow on prolog_db_tests; skipping"
else
    ../gentest.sh "$XEMU $options" prolog_db_tests "test."
fi
#------------------------------------------------------------------------
../gentest.sh "$XEMU $options" test_float_io_precision "test."
#------------------------------------
../gentest.sh "$XEMU $options" findall "test."
#------------------------------------
../gentest.sh "$XEMU $options" altindex "test."
#------------------------------------
../gentest.sh "$XEMU $options" longname "test."
#------------------------------------
../gentest.sh "$XEMU $options" gctest "test."
#------------------------------------
../gentest.sh "$XEMU $options" test_load_dyn_et_al "test."
#------------------------------------------------------------------------
../gentest.sh "$XEMU $options" test_immutable "test."
../gentest.sh "$XEMU $options" test_immutable2 "test."
#------------------------------------------------------------------------
cd parmod_tests
../../gentest.sh "$XEMU $options" test_parmod "test."
../../gentest.sh "$XEMU $options" test_parmod_im "test."
cd ..
#------------------------------------------------------------------------
cd mod_file_tests
../../gentest.sh "$XEMU $options" test_mod_file "test."
../../gentest.sh "$XEMU $options" test_mod_file_im "test."
cd ..
#------------------------------------------------------------------------
cd mod_dyn_tests
../../gentest.sh "$XEMU $options" test_dynmod "test."
../../gentest.sh "$XEMU $options" test_dynmod_im "test."
cd ..

#------------------------------------------------------------------------
# Test Prolog calling C: the .so or .o file needs to be created each time
# (actually, mac / others do not create .so)
#------------------------------------------------------------------------

# VALGRIND doesn't seem to work on these tests (its Valgrind and not XSB).
OBJEXT=.xwam
os_type=`uname -s`
echo "config tag is $config_tag"
#if test "$os_type" = "HP-UX" || test "$config_tag" = "-mt" || test "$valgrind" = "true"; then
#	echo "Foreign language interface tests bypassed"
#else
#------------------------------------------------------------------------
#	rm -f xeddis.o xeddis.so xeddis$OBJEXT
#	../gentest.sh "$XEMU $options" cinter1 "test."
#------------------------------------------------------------------------
#	rm -f zero.o zero.so zero$OBJEXT
#	../gentest.sh "$XEMU $options" cinter2 "test."
#------------------------------------------------------------------------
#	rm -f c_calls_xsb.o c_calls_xsb$OBJEXT c_calls_xsb_make$OBJEXT
#	../gentest.sh "$XEMU $options" c_calls_xsb_make "test."
#------------------------------------------------------------------------
#	rm -f cfixedstring.o c_fixedstring_make$OBJEXT
#	../gentest.sh "$XEMU $options" cfixedstring_make "test."
#------------------------------------------------------------------------
#	rm -f cvarstring.o c_varstring_make$OBJEXT
#	../gentest.sh "$XEMU $options" cvarstring_make "test."
#------------------------------------------------------------------------
#	rm -f cregs.o c_regs_make$OBJEXT
#	../gentest.sh "$XEMU $options" cregs_make "test."
#fi

#------------------------------------------------------------------------
rm -f test_cond_comp.xwam
	../gentest.sh "$XEMU $options" test_cond_comp "test."


#if test "$valgrind" = "true"; then
#	echo "Skipping foreign compilation"
#else
#------------------------------------------------------------------------
# TLS: need to remove dylib/so due to 64/32 bit confusion

#rm -f second_foreign.dylib second_foreign.so

#../gentest.sh "$XEMU $options" cinter3 "test."

#rm -f fibr.dylib fibr.so

#../gentest.sh "$XEMU $options" fibp "test."

#------------------------------------------------------------------------
#../gentest.sh "$XEMU $options" test_importas "test."
#fi

