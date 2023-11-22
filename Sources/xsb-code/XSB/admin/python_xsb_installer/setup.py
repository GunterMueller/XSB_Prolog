from setuptools import setup

with open("README.md", "r") as fd:
   long_description_string = fd.read()
   
setup (name = 'python_xsb_installer',
       version = '0.3',
       description = 'Installer for XSB and its Python connections',
       long_description = long_description_string,
       project_urls = {"XSB Project Page" : "http://xsb.sourceforge.net"},
       install_requires=['requests','find-libpython'],
       author = 'Theresa Swift',
#       packages = ['python_xsb_installer'],
       python_requires=">=3.6",
       classifiers=[
           "Programming Language :: Python :: 3",
           "License :: OSI Approved :: MIT License",
   ],
       )

       
