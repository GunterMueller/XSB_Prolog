
:- import janus_python_version/1 from janus.
:- import shell/2 from shell.
:- import xsb_configuration/2 from xsb_configuration.
   
test:-
    janus_python_version(Version),
    shell(['bash test_janus_py.sh ',Version],_F).
    
