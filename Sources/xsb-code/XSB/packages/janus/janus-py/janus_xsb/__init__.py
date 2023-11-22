from xsbext import *
#import xsbext as jns
import sys
import time
import atexit
import gc

# ================ Setup  ================

# TES: the gc.disable() is kludgy, but it avoids core dumps.
# when the code settles down, I'll handle xsbpy references better.
# Having said that, why gc before an exit of the main process?

def _myexit():
    close()
    gc.disable()
    print("XSB has been closed")

atexit.register(_myexit)

init ( )

DELAY_LISTS = 1
NO_TRUTHVALS = 2
PLAIN_TRUTHVALS = 4

cmd('curr_sym','set_prolog_flag','heap_garbage_collection','none')

cmd('consult','consult','janus')    # was xsbpy
cmd('consult','consult','janus_py') # was px
cmd('consult','consult','jns_test')

################################################################
# Modified from SWI

UNDEFINED = 2
        
def query_once(TermString,inputs={},truth_vals=PLAIN_TRUTHVALS):
    return(jns_query_once(TermString,inputs,truth_vals))

class apply:

    first_time = True
    query_args = None

    def __init__(self, *args):
        """Create from query and inputs as with janus.once()"""
        self.query_args = args
        self.first_time = True
#        print(self.query_args)
    def __iter__(self):
        """Implement iter protocol"""
        return self
    def __next__(self):
        """Implement iter protocol. Returns a dict as with janus.once()"""
        if (self.first_time):
            self.first_time = False
            return jns_first(*self.query_args)
        else:
            rc = jns_next()
            if rc == None:
                raise StopIteration()
            else:
                return rc      
    def __del__(self):
        """Close the Prolog query"""
    def next(self):
        if (self.first_time):
            self.first_time = False
            return jns_first(*self.query_args)
        else:
            return jns_next()
    def close(self):
        """Explicitly close the query."""
#        swipl.close_query(self.state)

# ================ Query  ================
class query:
    
    first_time = True
    query_args = None
    truthvals = None
    
    def __init__(self, *args,inputs={},truth_vals=PLAIN_TRUTHVALS):
        """Create from query and inputs as with janus.once()"""
        self.query_args = args
        self.keyword_args = inputs
        self.truthvals = truth_vals
        self.first_time = True
    def __iter__(self):
        """Implement iter protocol"""
        return self
    def __next__(self):
        """Implement iter protocol. Returns a dict as with janus.once()"""
        if (self.first_time):
            self.first_time = False
            #            return jns_string_first(*self.query_args)
            return jns_string_first(*self.query_args,self.keyword_args,self.truthvals)
        else:
            rc = jns_string_next(*self.query_args,self.keyword_args,self.truthvals)
#            rc = jns_string_next(*self)
            if rc == None:
                raise StopIteration()
            else:
                return rc      
    def __del__(self):
        """Close the Prolog query"""
    def next(self):
        if (self.first_time):
            self.first_time = False
            return jns_string_first(*self.query_args,self.keyword_args)
        else:
            return jns_string_next()
    def close(self):
        """Explicitly close the query."""
#        swipl.close_query(self.state)

# Notice the blank line above. Code should continue on this line.
# ================ Utils  ================

def ensure_loaded(File):
    """Convenience function for loading and/or compiling a Prolog 'file' as necessary.

    Defined as cmd('consult','ensure_loaded',File)
    """
    
    cmd('consult','ensure_loaded',File)

def consult(File):
    """Convenience function for compiling a Prolog 'file' as necessary, and loading it.

    Defined as cmd('consult','consult',File)
    """
    
    cmd('consult','consult',File)

def prolog_paths():
    """Convenience function to return a list of all current XSB library paths (XSB's equivalent of Python's sys.path).
    """

    return apply_once('jns_test','prolog_paths')
    
def add_prolog_path(List):
    """Convenience function to add one or more XSB library paths designated as a list of strings.  

    This function calls XSB's equivalent of Python's sys.path.append()} and is defined as: 
    jns_cmd('consult','add_lib\dir',Paths).
    """
    
    jns_cmd('consult','add_lib_dir',List)
    
# ================ Pretty Printing  ================
# Gives a Prolog-like echo to calls and writes answers in a Prolog-like manner

def pp_jns_apply_once(Module,Pred,*args):
    """Pretty print apply_once() and its return
    """

    try: 
        if len(args) == 0:
            print('?- '+Module+':'+Pred+'(Answer).')
        else: 
            print('?- '+Module+':'+Pred+'('+str(args)+',Answer).')
        print('')
        Dict = apply_once(Module,Pred,*args)

        print('   TV = ' + _printable_tv(Dict['truth']))
        if (Dict['truth'] != 0):
            print('   Answer  = ' + str(Dict['return']))
        print('')
    except Exception as err:
        _display_xsb_error(err)
        print('')

def pp_jns_comp(Module,Pred,*args,**kwargs):
    """Pretty print jns_comp() and its return
    """

    if 'vars' in kwargs:
        varnum = kwargs.get('vars')
    else:
        varnum = 1
    try:
        if kwargs != {}:
            print(kwargs)
        _print_comp_goal(Module,Pred,varnum,*args)
        Ret = jns_comp(Module,Pred,*args,**kwargs)
        _print_comp_answer(Ret)
    except Exception as err:
        _display_xsb_error(err)
        print('')

def _print_comp_goal(Module,Pred,varnum,*args):
    print('?- jns_comp('+Module+':'+Pred+'(',end="")
    argnum = len(args)
    for i in range(0,argnum-1):
        print(str(args[i])+',',end = "")
    if argnum > 0 and varnum==0:
        print(str(args[argnum-1])+'),Answer).',end = "")
        return
    elif argnum>0:
        print(str(args[argnum-1])+',',end = "")
    if varnum > 0:
        for i in range(0,varnum-1):
            print('_,',end = "")
        print('_',end = "")
    print('),Answer).')
        
def _print_comp_answer(Ret):
    _print_term(Ret,5)

def _tab(N):
    print(N*' ',end='')
    
def _print_term(Term,Offset):
    if type(Term) is tuple:
        _print_tuple(Term,Offset)
    elif type(Term) is list:
        _tab(Offset)
        print('[')
        for i in range(0,len(Term)):
            _print_term_tup(Term[i],(Offset+1))
            if i < len(Term)-1:
                print(',')
            else:
                print(' ')
                _tab(Offset)
                print(']')
    elif type(Term) is set:
        _tab(Offset)
        print('{')
        i=0
        for setelt in Term:
            _print_term_tup(setelt,(Offset+1))
            if i < len(Term)-1:
                print(',')
                i = i+1
            else:
                print(' ')
                _tab(Offset)
                print('}')
    else:
        _tab(Offset)
        print(Term)

def _print_term_tup(Term,Offset):
    if type(Term) is tuple:
        _print_tuple(Term,Offset)
    elif type(Term) is list:
        print('[',end="")
        for elt in Term:
            _print_term_tup(elt,0)
        print(']',end="")
    else:
        print(Term,end="")

def _print_tuple(Tup,Offset):
    if Tup[0] == 'plgTerm':
        print(Tup[1],end="")
        _print_tuple(Tup[2:],0)
    else:
        _tab(Offset)
        print('(',end="")
        for i in range(0,len(Tup)):
            _print_term_tup(Tup[i],0)
            if i != len(Tup)-1:
                print(',',end='')
        print(')',end="")          

        
def pp_jns_cmd(Module,Pred,*args):
    """Pretty print jns_cmd() and its return
    """
    
    try:
        Ret = cmd(Module,Pred,*args)
        print('?- '+Module+':'+Pred+'('+str(*args)+')')
        print('')
        print('   TV = ' + _printable_tv(Ret))
        print('')
    except Exception as err:
        _display_xsb_error(err)
    
def _display_xsb_error(err):    
        print('Exception Caught from XSB: ')
#        print('   ' + str(err))
        print('      ' + get_error_message())

def _printable_tv(TV):
    if TV == 1:
        return('True')
    elif TV == 0:
        return('False')
    else:
        return('Undefined')

# Copied from SWI    
class Undefined:
    """
    Class `Undefined` represents undefined answers according to the
    Well Founded Semantics.  Generic undefined answers are represented
    by a unique instance of this class that is available as the property
    `janus.undefined`.

    Instances of this class are created by once() and Query() and should
    never be created by the user.

    Parameters
    ----------
    term: Term
        Term representing the delay list or residual program.  Defaults
        to `None` for the generic undefined truth.

x    """
    def __init__(self, term=None):
        "Create from a Prolog term or `None` for _generic_ undefined"
        self.term = term
    def __str__(self):
        """Either "Undefined" (generic) or __str__() of the `.term`"""
        if self.term == None:
            return "Undefined"
        else:
            return self.term.__str__()
    def __repr__(self):
        """Either "Undefined" (generic) or __repr__() of the `.term`"""
        if self.term == None:
            return "Undefined"
        else:
            return self.term.__repr__()

# Truth value constants

false = False
true = True
undefined = Undefined()
