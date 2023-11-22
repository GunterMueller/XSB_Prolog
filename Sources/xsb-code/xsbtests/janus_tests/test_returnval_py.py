import sys
sys.path.insert(0,'../../XSB/packages/janus/janus-py')
#from janus import *
import janus as jns

#orig_output = sys.stdout 
#sys.stdout = open('./temp', 'w')

jns.consult('test_returnval_py')

def test_returnval():
    print('--------------------------')
    print(jns_qdet('test_returnval_py','preturnval',3.14159))
    print('-----')
    print(jns_qdet('test_returnval_py','preturnval',42))
    print('-----')
    print(jns_qdet('test_returnval_py','preturnval',None))
    print('-----')
    print(jns_qdet('test_returnval_py','preturnval',True))
    print('-----')
    print(jns_qdet('test_returnval_py','preturnval',False))
    print('-----')
    print(jns_qdet('test_returnval_py','preturnval',(1,2,3)))
    print('-----')
    print(jns_qdet('test_returnval_py','preturnval',[{'Name':'Geeks',1:[1,2,3,4]}]))
    

test_returnval()

