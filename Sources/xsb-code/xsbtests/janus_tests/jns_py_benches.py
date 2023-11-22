import sys
sys.path.insert(0,'../../XSB/packages/janus/janus-py')
import janus as jns
import time

jns.consult('jns_test')

def test_iterations():
    pp_iteration(test_iteration_cmd,200000)
    pp_iteration(test_iteration_apply_once,200000)
    pp_iteration(test_iteration_apply_once_nd,200000)
    pp_iteration(test_iteration_query_once_cmd,20000)
    pp_iteration(test_iteration_query_once,20000)
    pp_iteration(test_iteration_query_once_dict,20000)
    pp_iteration(test_comp_no_tvs,50000)
    pp_iteration(test_comp_default_tvs,50000)
    pp_iteration(test_comp_delay_lists,50000)
    bench_apply_list(500000)
    bench_Query_list(500000)
    py_to_xsb_list_xfer(1500000)        
    xsb_to_py_list_xfer(1500000)        
    pp_iteration(test_iteration_native,4000000)

# ============= Iteration Code  =============

def test_iteration_native(N):
    for i in range(1,N):
        my_incr(N)

def my_incr(N):
    return(N+1)

def test_iteration_cmd(N):
    for i in range(1,N):
        jns.cmd('jns_test','simple_cmd',N)

# deterministic query        
def test_iteration_apply_once(N):
    for i in range(1,N):
        jns.apply_once('jns_test','simple_call',N)
    
def test_iteration_query_once_cmd(N):
    for i in range(1,N):
        jns.query_once('jns_test:simple_call(1,2)')
    
def test_iteration_query_once(N):
    for i in range(1,N):
        jns.query_once('jns_test:simple_call(1,Num1)')
    
def test_iteration_query_once_dict(N):
    for i in range(1,N):
        jns.query_once('jns_test:simple_call(Num,Num1)',inputs={'Num':i})
    
def test_iteration_apply_once_nd(N):
    for i in range(1,N):
        jns.apply_once('jns_test','nondet_query')

# Passes back 6 solutions of 2 vars w. default tv        
def test_comp_default_tvs(N):
    for i in range(1,N):
        jns.comp('jns_test','table_comp',vars=2)

# Passes back 6 solutions of 2 vars w. no tvs        
def test_comp_no_tvs(N):
    for i in range(1,N):
        jns.comp('jns_test','table_comp',vars=2,truth_vals=jns.NO_TRUTHVALS)

# Passes back 6 solutions of 2 vars w. delay_lists
def test_comp_delay_lists(N):
    for i in range(1,N):
        jns.comp('jns_test','table_comp',vars=2,truth_vals=jns.DELAY_LISTS)

def pp_iteration(test_func,argument):
    Start = time.time()
    test_func(argument)
    End = time.time()
    print(test_func.__name__+'('+str(argument)+') succeeded')
    PerSec = argument/(End-Start)
    print('# Time: {:.3f} secs; {:_.0f} per sec.'.format(End-Start,PerSec))
    print('')    

def py_to_xsb_list_xfer(N):
    mylist = makelist(N)
#    print('getting the length of List = makelist(100000)')
    start = time.time()
    jns.apply_once('basics','length',mylist)
    end = time.time()
    PerSec = N/(end-start)
    print('py_to_xsb_list_xfer succeded: '+str(N))
    print('# Time: {:.3f} secs; {:_.0f} per sec.'.format(end-start,PerSec))
    print('')

def xsb_to_py_list_xfer(N):
#    print('calling prolog_makelist(1000000)')
    start = time.time()
    jns.apply_once('jns_test','prolog_makelist',N)    
    end = time.time()
    PerSec = N/(end-start)
    print('xsb_to_py_list_xfer succeded: '+str(N))
    print('# Time: {:.3f} secs; {:_.0f} per sec.'.format(end-start,PerSec))
    print('')
    
def makelist(N):
    list = []
    for i in range(1,N):
        list.append(i)
    return list

def bench_apply_list(N):
    start = time.time()
    for i in jns.apply('jns_test','backtrack_through_list',N):
        pass
    end = time.time()
    PerSec = N/(end-start)
    print('bench_apply_list succeded: '+str(N))
    print('# Time: {:.3f} secs; {:_.0f} per sec.'.format(end-start,PerSec))
    print('')
    
def bench_Query_list(N):
    start = time.time()
#    QSC = jns.QueryString('jns_test:backtrack_through_list(' + str(N) + ',Elt)')
    for i in jns.query('jns_test:backtrack_through_list(' + str(N) + ',Elt)'):
        pass
    end = time.time()
    PerSec = N/(end-start)
    print('bench_querystring_list succeded: '+str(N))
    print('# Time: {:.3f} secs; {:_.0f} per sec.'.format(end-start,PerSec))
    print('')
    

test_iterations()
