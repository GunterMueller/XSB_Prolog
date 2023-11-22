
# Note that the Apply class was formerly named Query

import sys
sys.path.insert(0,'../../XSB/packages/janus/janus-py')
import janus as jns

orig_output = sys.stdout 
sys.stdout = open('./temp', 'w')

jns.consult('jns_test')

def test_q():
    for i in jns.apply('jns_test','bt2'):
        print('bt2: ' + str(i))
    print('--------------------------')
    for i in jns.apply('jns_test','bt1'):
        print('bt1: ' + str(i))
    print('--------------------------')
    for i in jns.apply('jns_test','one_ary_fail'):
        print('one_ary_fail: ' + str(i))
    for i in jns.apply('jns_test','anti_member',[1,2,3]):
        print('for anti_member: ' + str(i))
    print('--------------------------')
    C1 = jns.apply('jns_test','anti_member',[1,2,3])
    print('anti_member: 1 ' + str(C1.next()))
    print('anti_member: 2 ' + str(C1.next()))
    print('anti_member: 3 ' + str(C1.next()))
    print('anti_member: 4 ' + str(C1.next()))
    print('--------------------------')
    for i in jns.apply('jns_test','am_3','foobar',[1,2,3]):
        print('am_3: ' + str(i))
    print('--------------------------')

test_q()      

sys.stdout = orig_output
