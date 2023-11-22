#!/bin/sh 

# This is the post-extraction script run by makeself.
# It configures the extracted XSB files.

# This assumes that XSB is sitting in ./XSB

echo
echo "+++++ Installing XSB -- will take a few minutes"
echo

currdir="`pwd`"
echo "----- Current directory = $currdir"
echo

if [ "$1" = "-v" ] ; then
    VERSION=$2
    version_icon_mark="-$VERSION"
    shift
    shift
fi

if [ -d ./XSB/emu -a -d ./XSB ]; then
    xsbdir="$currdir/XSB"
    tmpxsbdir=/tmp/XSB-`date +"%y-%m-%d-%H_%M_%S"`
    rm -rf $tmpxsbdir || \
	(echo "***** You have no write permission for the /tmp folder: your system is misconfigured"; echo "***** Installation has failed";  exit 1)
else
    echo "***** This script is to be run in a folder that contains ./XSB & ./XSB/emu"
    exit 1
fi


echo "+++++ Removing old files"
/bin/rm -rf ./XSB/config/*
/bin/rm -rf ./*.app

# start recording uninstall info
rm -f "$currdir/.uninstall_info.data"
echo "base_install_dir=\"$currdir\"" > "$currdir/.uninstall_info.data"

cp "$xsbdir/admin/MacOS/mk-mac-alias" "$currdir"
cp "$xsbdir/admin/MacOS/del-mac-alias" "$currdir"
cp "$xsbdir/admin/uninstall_XSB.sh" "$currdir"
chmod 700 "$currdir/mk-mac-alias" "$currdir/del-mac-alias" "$currdir/uninstall_XSB.sh"

# Move XSB to /tmp to sidestep the problems with configuring it
# in dirs that have spaces
mv -f "$xsbdir" $tmpxsbdir
cd $tmpxsbdir/build
rm -f "$currdir/xsb-install.log"

echo "+++++ Configuring XSB"
echo
echo "+++++ Configuring XSB" > "$currdir/xsb-install.log"
echo "----- Current directory = $currdir" >> "$currdir/xsb-install.log"
echo "" >> "$currdir/xsb-install.log"

./configure --with-dbdrivers >> "$currdir/xsb-install.log" 2>&1 || \
    (echo :ERRORS:FOUND: >> "$currdir/xsb-install.log"; echo "***** Configuration of XSB failed: see $currdir/xsb-install.log"; exit 1)

grep "configure: error" "$currdir/xsb-install.log" > "$currdir/xsb-misc.log"
grep "Python integration" "$currdir/xsb-install.log" >> "$currdir/xsb-misc.log"

misc_errors=`cat "$currdir/xsb-misc.log"`
if [ -n "$misc_errors" ]; then
    echo
    cat "$currdir/xsb-misc.log"
    echo
fi

echo "+++++ Compiling XSB"
./makexsb >> "$currdir/xsb-install.log" 2>&1 || \
    (echo :ERRORS:FOUND: >> "$currdir/xsb-install.log"; echo "***** Compilation of XSB failed: see $currdir/xsb-install.log"; exit 1)

# Move compiled XSB from /tmp to its intended place
# Splitting mv into cp+rm because of what seems to be a bug in Ubuntu over W10
cp -rf $tmpxsbdir "$xsbdir"
rm -rf $tmpxsbdir

# setting up the icons
# LINUX
echo "+++++ Setting up icons"
echo "+++++ Setting up icons" >> "$currdir/xsb-install.log"

# important: otherwise cwd will be the deleted /tmp/XSB-23-04-21-02_01_28/build
# and there wil be an error getcwd() failed
cd "$currdir"


# key uninstall vars
xsb_desktop_shortcut="$HOME/Desktop/runXSB$version_icon_mark.desktop"
xsb_desktop_shortcut_name="XSB $VERSION"

if [ "`uname`" = "Linux" -a -d $HOME/Desktop ]; then
    cat "$xsbdir/admin/XSB-linux-desktop" | sed "s|XSB_BASE_FOLDER|$xsbdir|" | sed "s|XSB_VERSION|$VERSION|" > $xsb_desktop_shortcut
    chmod u+x $xsb_desktop_shortcut
fi

# continue recording uninstall info
echo "xsb_desktop_shortcut=\"$xsb_desktop_shortcut\"" >> "$currdir/.uninstall_info.data"

# MAC
if [ "`uname`" = "Darwin" -a -d $HOME/Desktop ]; then
    xsb_app_dir="$currdir/runXSB.app"

    if [ "`which Rez`" = "" ]; then
        echo
        echo
        echo "!!! Mac Developer Tools (XCode) do not seem to be installed."
        echo "!!! As a result, desktop icons might not get installed"
        echo "!!! and some XSB packages might be unavailable."
        echo "!!! Make sure you install XCode."
        echo
        /bin/echo -n I understand...
        read response
        echo
    fi

    /bin/rm -f "$HOME/Desktop/runXSB.desktop"

    # Step 1: set up the Reasoner app and its desktop shortcut
    cp -r "$xsbdir/admin/MacOS/runXSB.app" "$currdir"
    cat "$xsb_app_dir/Contents/MacOS/runXSB.template" | sed "s|XSB_BASE_FOLDER|$xsbdir|" > "$xsb_app_dir/Contents/MacOS/runXSB"
    cat "$xsb_app_dir/Contents/Info.plist.template" | sed "s|XSB_VERSION|$VERSION|" > "$xsb_app_dir/Contents/Info.plist"
    chmod u+x "$xsb_app_dir/Contents/MacOS/runXSB"

    # make desktop alias for the Reasoner
    echo "Running del-mac-alias \"$xsb_desktop_shortcut_name\"" >> "$currdir/xsb-install.log"
    "$currdir/del-mac-alias" "$xsb_desktop_shortcut_name" >> "$currdir/xsb-install.log" 2>&1
    echo "Copying the XSB icon \"$xsbdir/etc/images/xsb-logo.icns\" to the Mac app Resources folder \"$xsb_app_dir/Contents/Resources/\"" >> "$currdir/xsb-install.log"
    cp "$xsbdir/etc/images/xsb-logo.icns" "$xsb_app_dir/Contents/Resources/"
    echo "Running mk-mac-alias $ergoAI_reasoner_app_dir \"$xsb_desktop_shortcut_name\"" >> "$currdir/xsb-install.log"
    "$currdir/mk-mac-alias" "$xsb_app_dir" "$xsb_desktop_shortcut_name" >> "$currdir/xsb-install.log" 2>&1
fi

# continue recording uninstall info
echo "xsb_desktop_shortcut_name=\"$xsb_desktop_shortcut_name\"" >> "$currdir/.uninstall_info.data"

install_err_found=`cat "$currdir/xsb-install.log" | grep :ERRORS:FOUND: `

if [ -z "$install_err_found" ]; then
    echo "+++++ Running XSB for the first time"
    echo "+++++ Running XSB for the first time" >> "$currdir/xsb-install.log"
    "$xsbdir/bin/xsb" > "$currdir/xsb-initrun.log" 2>&1 <<EOF
halt.
EOF
fi

cat "$currdir/xsb-initrun.log"
cat "$currdir/xsb-initrun.log" >> "$currdir/xsb-install.log"

echo
echo "..... The build log is in \"$currdir/xsb-install.log\""
echo "..... Attach it if filing an installation problem report"
echo

initrun_err_found=`cat "$currdir/xsb-initrun.log" | grep Error`
initrun_abort_found=`cat "$currdir/xsb-initrun.log" | grep Abort `
install_err_found=`cat "$currdir/xsb-install.log" | grep :ERRORS:FOUND: `

if [ -z "$initrun_err_found" -a -z "$initrun_abort_found" -a -z "$install_err_found" ]; then
    echo "+++++ All is well: you can run XSB in a terminal via the script"
    echo "+++++    \"$xsbdir/bin/xsb\""
    echo "+++++ XSB Manual:"
    echo "+++++    vol 1: \"$xsbdir/docs/userman/manual1.pdf\""
    echo "+++++    vol 2: \"$xsbdir/docs/userman/manual2.pdf\""
else
    echo "***** ERRORS occurred during installation of XSB"
    echo "***** ERRORS occurred during installation of XSB" >> "$currdir/xsb-install.log"
    echo
fi

echo
#echo "+++++ If the desktop icon 'XSB' was installed"
#echo "+++++ successfully, one can conveniently use it to run XSB."
#if [ "`uname`" = "Darwin" -a -d $HOME/Desktop ]; then
#   echo "+++++ On the Mac, one might need to:"
#   echo "+++++   sudo /bin/rm -rf /Library/Cashes/com.apple.iconservices.store"
#   echo "+++++ and then reboot to ensure that the XSB icon is displayed."
#fi
#echo

