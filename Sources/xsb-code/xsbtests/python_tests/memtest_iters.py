import sys
sys.path.insert(0,'../../XSB/packages/xsbpy/px')
from px import *

px_cmd('consult','ensure_loaded','px_test')

def test_iterations():
    pp_iteration(test_iteration_cmd,200000)
    pp_iteration(test_iteration_nondet,200000)
    pp_iteration(test_iteration_query,200000)
    py_to_xsb_list_xfer(1000000)        
    xsb_to_py_list_xfer(1000000)        

# ============= Iteration Code  =============
# simple_cmd(N):- _N1 is N + 1.
def test_iteration_cmd(N):
    for i in range(1,N):
        px_cmd('px_test','simple_cmd',N)

# simple_call(N,N1):- N1 is N + 1.
def test_iteration_qdet_int(N):
    for i in range(1,N):
        px_qdet('px_test','simple_call',N)

def test_iteration_qdet_tuple(N):
    for i in range(1,N):
        px_qdet('px_test','simple_call',N)
        
def test_iteration_nondet(N):
    for i in range(1,N):
        px_qdet('px_test','nondet_query')

def test_iteration_qdet_tuple(N):
    for i in range(1,N):
        px_qdet('px_test','return_tuple')

def test_iteration_qdet_dict(N):
    for i in range(1,N):
        px_qdet('px_test','return_dict')

def test_iteration_comp(N):
    for i in range(1,N):
        px_comp('px_test','nondet_query')
        
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
    px_qdet('basics','length',mylist)
    end = time.time()
    print('py_to_xsb_list_xfer succeded: '+str(N))
    print('# Time: '+str(end-start))
    print('')

def xsb_to_py_list_xfer(N):
#    print('calling prolog_makelist(1000000)')
    start = time.time()
    px_qdet('px_test','prolog_makelist',N)    
    end = time.time()
    print('xsb_to_py_list_xfer succeded: '+str(N))
    print('# Time: '+str(end-start))
    print('')
    
def makelist(N):
    list = []
    for i in range(1,N):
        list.append(i)
    return list

#test_iterations()
