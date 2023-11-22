
python_xsb_installer is a very inital version of a pip package.  It
currently only works for linux.

I am totally open to better ways of Python packaging, so please let me
know if you have any!

------------------------------------------------
To make and upload a new version do the following.

* After you've made changes, make sure setup.py has the appropriate
  version number.

* Make sure you have a working account on testpypi (or eventually
  pypi).

* Decide which version of Python you want to use to make the package
  -- usually the latest stable version.  Then if you are unsure whether
  this Python has the build package:

  python3.X -m pip install build

* Now, cd to python_xsb_installer and build the distribution:

  python.X -m build

  After this command executes, dist should have a .whl file and a
  .tar.gz file.

* python3.X -m pip install twine, if you are unsure whether the twine
  package has been installed.

* Now, upload:

  python3.X -m twine upload --repository testpypi dist/*

  This loads into testpypi rather than pypi.  Whenever we've tested it
  out a bit more, we'll upload directly to pypi.