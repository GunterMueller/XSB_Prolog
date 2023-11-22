import sys
sys.path.insert(0,'../../XSB/packages/janus/janus-py')
from janus import *

# probably good to add more interrupt tests to make sure they don't
# get confused by Python.  Not likely that they will, but...

orig_output = sys.stdout 
sys.stdout = open('./temp', 'w')

jns_cmd('consult','ensure_loaded','px_clpr')

def test_interrupts():
#    add_prolog_path(['../attv_tests'])
#    px_cmd('px_test','tc_rep_max') 
#    px_cmd('consult','consult','attv_test')
#    px_cmd('usermod','test')
    print(jns_cmd('px_clpr','px_entailed','[[X  > 3*Y + 2,Y>0],[X > Y]]'))
        
test_interrupts()

sys.stdout = orig_output
