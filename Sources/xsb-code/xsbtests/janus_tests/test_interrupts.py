import sys
sys.path.insert(0,'../../XSB/packages/janus/janus-py')
import janus as jns

# probably good to add more interrupt tests to make sure they don't
# get confused by Python.  Not likely that they will, but...

orig_output = sys.stdout 
sys.stdout = open('./temp', 'w')

jns.consult('px_clpr')

def test_interrupts():
#    add_prolog_path(['../attv_tests'])
    print(jns.cmd('px_clpr','px_entailed','[[X  > 3*Y + 2,Y>0],[X > Y]]'))
        
test_interrupts()

sys.stdout = orig_output
