import sys
sys.path.insert(0,'../../XSB/packages/janus/janus-py')
from janus import *

jns_cmd('consult','ensure_loaded','jns_test')

def test_iterations():
    pp_iteration(test_iteration_cmd,200000)
    pp_iteration(test_iteration_nondet,200000)
    pp_iteration(test_iteration_query,200000)
    py_to_xsb_list_xfer(1000000)        
    xsb_to_py_list_xfer(1000000)        

# ============= Iteration Code  =============
def test_iteration_cmd(N):
    for i in range(1,N):
        jns_cmd('jns_test','simple_cmd',N)

# deterministic query        
def test_iteration_query(N):
    for i in range(1,N):
        jns_qdet('jns_test','simple_call',N)
    
def test_iteration_nondet(N):
    for i in range(1,N):
        jns_qdet('jns_test','nondet_query')


def pp_iteration(test_func,argument):
    Start = time.time()
    test_func(argument)
    End = time.time()
    print(test_func.__name__+'('+str(argument)+') succeeded')
    print('# Time: '+str(End-Start))
    print('')    

def py_to_xsb_list_xfer(N):
    mylist = makelist(N)
#    print('getting the length of List = makelist(100000)')
    start = time.time()
    jns_qdet('basics','length',mylist)
    end = time.time()
    print('py_to_xsb_list_xfer succeded: '+str(N))
    print('# Time: '+str(end-start))
    print('')

def xsb_to_py_list_xfer(N):
#    print('calling prolog_makelist(1000000)')
    start = time.time()
    jns_qdet('jns_test','prolog_makelist',N)    
    end = time.time()
    print('xsb_to_py_list_xfer succeded: '+str(N))
    print('# Time: '+str(end-start))
    print('')
    
def makelist(N):
    list = []
    for i in range(1,N):
        list.append(i)
    return list

test_iterations()
