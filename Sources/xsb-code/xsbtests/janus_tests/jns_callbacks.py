import sys
sys.path.insert(0,'../../XSB/packages/janus/janus-py')
import janus as jns

orig_output = sys.stdout 
sys.stdout = open('./temp', 'w')

jns.consult('jns_unicode')
jns.consult('jns_callbacks')
print('xp_unicode:unicode_upper: '
      + str(jns.apply_once('jns_unicode','unicode_upper','Η Google μου το μετέφρασε')))
print('jns_callbacks:test_json: ' + str(jns.apply_once('jns_callbacks','test_json')))
#NewClass,TV = jns.qdet('jns_callbacks','test_class','joe')
Dict = jns.apply_once('jns_callbacks','test_class','joe')
print('jns_callbacks','test_class: ' + str(Dict['return'].name))
#globs = jns.apply_once('jns_callbacks','get_globals')
#print('get_globals ' + 'got globals')

sys.stdout = orig_output
