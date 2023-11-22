# standard libraries
import argparse
import os
import shutil
import sys
import glob
from subprocess import *
import sysconfig

# 3rd-party packagesf
import requests
#import find_libpython

# python3.8 -m download

if sys.platform == 'linux':
    USERDIR = os.environ['HOME'] + '/.local'
    SYSTEMDIR = '/usr/local'
    SLASH='/'
else: 
    raise NotImplementedError('Downloads on ' + sys.platform + ' are not yet supported')

XSBURL ='https://sourceforge.net/projects/xsb/files/xsb/5.0%20%28Green%20Tea%29/XSB-5.0.tar.gz'
XSBFILE= '~/XSB.tar.gz'

basedir = ''
preferred_python = ''

#------------------------------------------------------

def get_basedir():
    global basedir
    clargs = parser.parse_args()
    if clargs.system:
        if not os.access(SYSTEMDIR,os.W_OK):
            raise PermissionError('Cannot write to '+ SYSTEMDIR + ' use --user or sudo.')
        basedir = SYSTEMDIR
    elif clargs.special is not None:
        basedir = clargs.special
    elif clargs.user:
        basedir = USERDIR
    else:
        if 'VIRTUAL_ENV' in os.environ and os.environ['VIRTUAL_ENV'] != None:
            basedir = os.environ['VIRTUAL_ENV'] + '/lib'
        elif 'CONDA_DEFAULT_ENV' in os.environ and os.environ['CONDA_DEFAULT_ENV'] is not None:
            basedir = os.environ['CONDA_PREFIX']
        else:
            basedir = USERDIR + '/lib/' + preferred_python

#------------------------------------------------------

def get_input_args():
    global preferred_python
    parser = argparse.ArgumentParser(description="XSB Installation Script",
                                     formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    location = parser.add_mutually_exclusive_group()
    location.add_argument("--user", action="store_true", help="store XSB under ~user/.local")
    location.add_argument("--system", action="store_true", help="store XSB under /opt")
    #parser.add_argument("--special", action="store_true",,help="store XSB in a chosen directory")
    location.add_argument("--special",help="store XSB in a chosen directory")
    parser.add_argument("--testing", action="store_true",help="Testing Mode")
    parser.add_argument("--with-preferred-python",dest="preferred_python",
                        help="Choose a version of Python to use.  If provided the configuration will choose one")
    clargs = parser.parse_args()
    if clargs.preferred_python is None:
        preferred_python =  'python' + sysconfig.get_config_var('VERSION')
    else:
        preferred_python = 'python' + clargs.parse_args().preferred_python
    parser.add_argument("--force", action="store_true",
                        help="for debugging: force removal of existing packages px\*")
    return parser

#------------------------------------------------------

def download_file(url):
    clargs = parser.parse_args()
    if clargs.testing:
        os.system("cp " + XSBFILE + " .")
        local_filename = XSBFILE.split('/')[-1]
        print("Testing " + local_filename)
        return local_filename
    else:
        local_filename = url.split('/')[-1]
        with requests.get(url, stream=True) as r:
            with open(local_filename, 'wb') as f:
                shutil.copyfileobj(r.raw, f)
    return local_filename

#------------------------------------------------------

def install_xsb():
#    if not os.path.exists(basedir + SLASH + XSBTARGZ):
#        print("...downloading XSB...")
    XSBTARGZ = download_file(XSBURL)        
    print("...XSB downloaded: " + XSBTARGZ)
    os.system("tar -xzf " + XSBTARGZ)
#        subprocess.pOpen('gunzip ',XSBTARGZ)
    print(os.listdir('.'))
    os.chdir('XSB/build')
    clargs = parser.parse_args()
    configure_cmd = './configure -with-preferred-python=' + preferred_python
    print('configure = ' + configure_cmd)
    os.system(configure_cmd)
    os.system('./makexsb')

#------------------------------------------------------

def check_sys_path_conflicts():
    hits = []
    error_string = ''
    for path in sys.path:
#        print('path: '+path)
        globlist = glob.glob(path+'/px*')
#        print('   glob: '+str(globlist))
        if globlist != []:
            for globfile in globlist:
#                fullpath = path + '/' + globfile
                hits.append(globfile)
    if hits != []:
#        if clargs.force:
#            print("removing")
#        else:
        for elt in hits:
            error_string = error_string + ' ' + elt
#            print(elt,end=' ')
#        print(' ')
        raise(PermissionError('Possibe conflicting px implementations. ' + 
                              'Check/remove manually:\n\n' + error_string))
    return hits
        
#------------------------------------------------------

def check_libpython(): 
    v = sysconfig.get_config_vars()
    maybe_paths = [os.path.join(v[pv], v['LDLIBRARY']) for pv in ('LIBDIR', 'LIBPL')]
    if len(list(filter(os.path.exists, maybe_paths))) == 0:
        raise FileNotFoundError('Cannot find libpython for ' + preferred_python +
                                ' make sure the proper development library is installed')
    
#------------------------------------------------------
# There has to be a better way to do this than introducing such a trivial file.
# Anyway, not yet ysed, but in case I ever want for 1 version of python to download for another.

def get_sys_path(version):
    callstring = 'python' + version + ' print_sys_path.py'
    opencall = Popen([callstring], stdout=PIPE, stderr=PIPE,shell=True)
    return opencall.communicate()

#------------------------------------------------------

if __name__ == '__main__':
    parser = get_input_args()
    clargs = parser.parse_args()
    print(clargs)
    check_libpython()
    conflicts = check_sys_path_conflicts()
    get_basedir()
    print('basedir =' + basedir)
    invoke_dir = os.getcwd()
    os.chdir(basedir)
    print(' in ' + os.getcwd())
    print(os.listdir('.'))
    XSBTARGZ = XSBURL.split(SLASH)[-1]
    install_xsb()
#    os.chdir('../packages/xsbpy')
#    os.system('./configure')
    os.chdir(invoke_dir)

# for user-installation    
#python -m pip install requests
#python3.7 ~/xsb-repo/xsb-code/XSB/admin/downloadXSB.py --testing --with_preferred_python python3.7
#source ~/.local/XSB/packages/xsbpy/px_activate
#python3.7
#import px
#print(px.__file__)

# for venv
#rm -rf ~/mypy3.7
#python3.7 -m venv ~/mypy3.7
#source ~/mypy3.7/bin/activate
#python -m pip install requests
#export PYTHON_BIN=/home/tswift/mypy3.7/bin/python
#python ~/xsb-repo/xsb-code/XSB/admin/downloadXSB.py --testing#
#source ~/mypy3.7/lib/XSB/packages/xsbpy/px_activate
#python3.7
#import px
#print(px.__file__)

# todo
# handle preferred_python = python3.7m

