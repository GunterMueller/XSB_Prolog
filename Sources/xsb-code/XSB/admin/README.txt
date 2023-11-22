
Note: Most of the tar scripts here are obsolete.

CREATION OF EASY-TO-INSTALL RELEASES FOR THE USER

Preparing a Linux/Mac release:

cd to the dir containing XSB
    cd ../../ 
Then run:
    ./XSB/admin/make-XSB-installer.sh

This will create a self-extracting archive XSB_XXXX.run, where XXXX is the
version number.

INSTALLATION OF AN EASY-TO-INSTALL RELEASE

The above self-extracting archive can be copied to a desired directory and
executed as (if the mode is rwx) 

     ./XSB_XXXX.run
or (if ./XSB_XXXX.run is not executable and you do not want to change the
mode manually):

     sh ./XSB_XXXX.run

This will install XSB and a desktop icon to run XSB.

Windows: see windows/NOTES.txt
