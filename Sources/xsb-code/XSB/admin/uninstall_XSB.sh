#! /bin/sh

# perform an uninstall on the version of XSB in which this file lives.

echo
if [ -f ".uninstall_info.data" ]; then
    . .uninstall_info.data
else
    echo "This doesn't look like an XSB release: missing uninstall data"
    echo "This copy is not uninstallable\n" 
    exit 1
fi

# if git repo: caution, do not break. cannot be a valid release
(git log --pretty=format:%h 2>&1) > /dev/null && must_exit=1

if [ "$must_exit" = "1" ]; then
    echo "This is a git-cloned copy of XSB, not an XSB release"
    echo "This copy is not uninstallable\n" 
    exit 1
fi

release=`basename "$base_install_dir"`
echo "***** Starting uninstallation of $release"

echo
echo "Are you sure you want to remove $release from your system?"
echo "This will remove the icon '$xsb_desktop_shortcut_name' "
echo "and then the entire folder '$base_install_dir'"
/bin/echo -n "Continue with uninstallation? (yes/NO): "
read response
echo
if [ "$response" != "Yes" -a "$response" != "yes" -a "$response" != "YES" ]; then
    echo Uninstallation canceled
    echo Exiting ...
    exit 1
fi
echo "Proceeding with uninstallation..."

if [ "`uname`" = "Linux" -a -d $HOME/Desktop ]; then
    echo "... removing \"$xsb_desktop_shortcut\""
    /bin/rm -f "$xsb_desktop_shortcut"
    echo "... removing \"$base_install_dir\""
    /bin/rm -rf "$base_install_dir"
fi

if [ "`uname`" = "Darwin" ]; then
    echo "... removing \"$xsb_desktop_shortcut_name\""
    ./del-mac-alias "$xsb_desktop_shortcut_name"
    echo "... removing \"$base_install_dir\""
    /bin/rm -rf "$base_install_dir"
fi

echo "***** `basename "$base_install_dir"` has been completely uninstalled"
echo
