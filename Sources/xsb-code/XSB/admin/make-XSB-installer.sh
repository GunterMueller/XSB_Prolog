#!/bin/sh 

# Create an XSB installer 

# Run this script as
#  XSB/admin/make-XSB-installer.sh [-v Version]
# in a folder that has ./XSB & ./XSB/emu

# Arguments: none or two
# If arg1/2 are -v version: build that version.


XSB_base="./XSB/"
XSB_base2="XSB"


. XSB/build/version.sh

if test -n "$xsb_beta_version" ; then
    xsb_version=$xsb_major_version.${xsb_minor_version}-b${xsb_beta_version}
else
    xsb_version=$xsb_major_version.${xsb_minor_version}.${xsb_patch_version}
fi

if [ "$1" = "-v" ] ; then
    shift
    VERSION="$1"
    shift
else
    VERSION=$xsb_version
fi

# XSB will be installed in XSBHomeland/$OUTDIR
OUTDIR=XSB_$VERSION
outfile_suffix=_$VERSION
# $OUTFILE is the name of the file xxxx.run
OUTFILE=XSB$outfile_suffix
echo creating $OUTFILE.run

files="./XSB/LICENSE ./XSB/INSTALL \
        ./XSB/README  \
        ./XSB/FAQ ./XSB/Makefile \
        ./XSB/XSB-post-makeself-config.sh \
        ./XSB/admin/MacOS \
        ./XSB/admin/uninstall_XSB.sh ./XSB/admin/XSB-linux-desktop \
        ./XSB/build/ac* ./XSB/build/*.in ./XSB/build/config.guess \
        ./XSB/build/config.sub ./XSB/build/*sh ./XSB/build/*.msg \
        ./XSB/build/configure ./XSB/build/README \
        ./XSB/build/windows* \
        ./XSB/emu ./XSB/syslib ./XSB/cmplib  ./XSB/lib \
	./XSB/gpp \
	./XSB/bin \
	./XSB/prolog_includes \
        ./XSB/etc/ \
        ./XSB/packages \
        ./XSB/pthreads \
	./XSB/prolog-commons \
        ./XSB/docs/userman \
        ./XSB/docs/JupyterNotebooks \
        ./XSB/installer \
        ./XSB/InstallXSB.jar \
        ./XSB/examples"

## excluded doc files
#        ./XSB/docs/userman/manual?.pdf \
#        $XSB_base/docs/*.pdf \

if [ -d ./XSB/emu -a -d ./XSB ]; then
    xsbdir=$currdir/XSB
else
    echo "This script must be run as ./XSB/admin/make-XSB-installer.sh"
    echo "The folders ./XSB and ./XSB/emu must reside in the current folder"
    exit 1
fi


EXCLUDEFILE=XSB/admin/.excludedFiles

cat > $EXCLUDEFILE <<EOF
CVS
*.conf
*.log
.#*
.cvsignore
.svn
.excludedFiles
*.zip
*.tar
*.bz2
*.gz
*.Z
*~
*.bak
*-sv
*-old
.*.tmp
*.tmp
bundle_config.sh
flrcompiler.[PH]
flrparser.[PH]
flrcomposer.[PH]
flrshell.[PH]
flrlibman.[PH]
flora2.[PH]
EOF

if [ "`uname`" = "Darwin" ]; then
    tar -X $EXCLUDEFILE -s ,^\.,XSBHomeland/$OUTDIR, -cf XSB.tar $files || failure=yes
else
    tar cf XSB.tar --exclude-from=$EXCLUDEFILE $files --transform "s,^\\.,XSBHomeland/$OUTDIR," || failure=yes
fi

if [ "$failure" = "yes" ]; then
    echo ""
    echo "*** Failed to create XSB.tar"
    echo ""
    exit 1
fi

gzip -f XSB.tar

echo ""
echo "*************************************************************"
echo "**  The XSB archive is now in ./XSB.tar.gz"
echo "**"
echo "**  Remaining steps (performed automatically):"
echo "**"
echo "**     1.  mv ./XSB.tar.gz /tmp"
echo "**         cd /tmp"
echo "**     2.  tar xpzf ./XSB.tar.gz"
echo "**     3.  XSB/admin/makeself/makeself.sh --notemp XSBHomeland $OUTFILE.run 'Installing XSB' 'cd $OUTDIR; ./XSB/XSB-post-makeself-config.sh'"
echo "**          mv $OUTFILE.run ."
echo "*************************************************************"

TEMPDIR=/tmp
mv ./XSB.tar.gz $TEMPDIR
xsb_parent_dir=`pwd`
cd $TEMPDIR
# this clears out XSBHomeland in /tmp
/bin/rm -rf XSBHomeland
tar xpzf ./XSB.tar.gz

"$xsb_parent_dir/XSB/admin/makeself/makeself.sh" --notemp XSBHomeland $OUTFILE.run "Installing XSB" "cd $OUTDIR; ./XSB/XSB-post-makeself-config.sh" -v $VERSION
mv $OUTFILE.run $xsb_parent_dir
/bin/rm -rf ./XSB.tar.gz
/bin/rm -rf XSBHomeland
cd $xsb_parent_dir

echo ""
echo "*************************************************************"
echo "**"
echo "**  Installing from self-extracting archive:"
echo "**"
echo "**         ./$OUTFILE.run"
echo "**"
echo "**  Running XSB on command line:"
echo "**"
echo "**         ./XSBHomeland/$OUTDIR/XSB/bin/xsb"
echo "**"
echo "*************************************************************"
echo ""
