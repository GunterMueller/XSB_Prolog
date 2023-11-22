import sys
sys.path.insert(0,'../../XSB/packages/janus/janus-py')
import janus as jns

orig_output = sys.stdout 
sys.stdout = open('./temp', 'w')

jns.consult('jns_test')

def test_qs():
    for i in jns.query('jns_test:one_ary_fail(FX)'):
        print('for one_ary_fail: ' + str(i))
    print('--------------------------')
    for i in jns.query('jns_test:anti_member([1,2,3],FX)'):
        print('for anti_member: ' + str(i))
    print('--------------------------')
    for i in jns.query('jns_test:anti_member(X,FX)',inputs = {'X':[1,2,3]}):
        print('for anti_member w input dict: ' + str(i))
    print('--------------------------')
    C1 = jns.query('jns_test:anti_member([1,2,3],X)')
    print('anti_member 1: ' + str(C1.next()))
    print('anti_member 2: ' + str(C1.next()))
    print('anti_member 3: ' + str(C1.next()))
    print('anti_member 4: ' + str(C1.next()))
    print('--------------------------')
    C2 = jns.query('jns_test:am_3(foobar,[1,2,3],X)')
    print('am_3 1: ' + str(C2.next()))
    print('am_3 2: ' + str(C2.next()))
    print('am_3 3: ' + str(C2.next()))
    print('am_3 4: ' + str(C2.next()))
    print('--------------------------')
    for i in jns.query('jns_test:bind_test(A,B,C,D,E,F,G)'):
        print('bind_test ' + str(i))
    print('--------------------------')
    for i in jns.query('jns_test:anti_member(X,Y)',inputs={'X':[1,2,3]}):
        print('anti_member input_dict 1: ' + str(i))
    print('--------------------------')
    for i in jns.query('jns_test:test_comp(X)'):
        print('test_comp' + str(i))
    print('--------------------------')
    for i in jns.query('jns_test:test_comp(X)',inputs={}):
        print('test_comp' + str(i))
    print('--------------------------')
    for i in jns.query('jns_test:test_comp(X)',inputs={}):
        print('test_comp' + str(i))
    print('--------------------------')
    for i in jns.query('jns_test:test_comp(X)',truth_vals=jns.DELAY_LISTS):
        print('test_comp' + str(i))
    print('--------------------------')
    for i in jns.query('jns_test:test_comp(X)',inputs={},truth_vals=jns.DELAY_LISTS):
        print('test_comp' + str(i))
    print('--------------------------')
    for i in jns.query('jns_test:test_comp(X)',truth_vals=jns.NO_TRUTHVALS):
        print('test_comp' + str(i))
    print('--------------------------')
    for i in jns.query('jns_test:test_comp(X)',inputs={},truth_vals=jns.NO_TRUTHVALS):
        print('test_comp' + str(i))
    print('--------------------------')

test_qs()

sys.stdout = orig_output
