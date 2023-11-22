
XSBDIR=$1

 echo "--------------- dbg test -------------------------"
 
 cd ../XSB/build
 
 rm ../config/*dflt/saved.o/*.o ; 
./configure --with-config-tag=dflt
 ./makexsb --config-tag=dflt ;
 
 cd ../../xsbtests
 
 sh testsuite.sh -tag dflt  $XSBDIR
