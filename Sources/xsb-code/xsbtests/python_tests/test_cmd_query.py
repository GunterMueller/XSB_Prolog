import sys
sys.path.insert(0,'../../XSB/packages/janus/janus-py')
from janus import *

orig_output = sys.stdout 
sys.stdout = open('./temp', 'w')

jns_cmd('consult','ensure_loaded','jns_test')

def test_cmd_query():
    print('------------ command: arity 1 -------------')
    pp_jns_cmd('jns_test','win',0)
    pp_jns_cmd('jns_test','one_ary_fail','p')
    pp_jns_cmd('jns_test','instan','b')
    print('----------- command arity 0 --------------')
    pp_jns_cmd('jns_test','zero_ary_true')
    pp_jns_cmd('jns_test','zero_ary_fail')
    pp_jns_cmd('jns_test','zero_ary_undef')
    print('----------- query: arity 1 --------------')
    pp_jns_qdet('jns_test','one_ary_undef')
    pp_jns_qdet('jns_test','instan')
    pp_jns_qdet('jns_test','one_ary_fail')
    pp_jns_qdet('jns_test','return_tuple')
    pp_jns_qdet('jns_test','return_term')
    print('------------ query: arity 2 -------------')
    pp_jns_qdet('basics','reverse',[1,2,3,{'a':{'b':'c'}}])
    pp_jns_qdet('string','concat_atom',['a','b','c','d','e','f','g'])
    print('------------ query: arity 3 -------------')
    pp_jns_qdet('basics','append',[1,2],[3,4])
#    print('----------- testing interrupts --------------')
#    test_interrupts()
    print('----------- done with test_cmd_query --------------')

test_cmd_query()

sys.stdout = orig_output
