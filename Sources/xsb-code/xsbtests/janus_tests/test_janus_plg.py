 
def sumlist3(X:str,Y:list):
#	print('First element to combine with is '+str(X))
	Z = []
	for element in Y:
		Z.append(X+element)
	return Z

#--------------
#from json import *
import json

#def prolog_loads(String):
#    jdict = json.loads(String)
#    jlist = list(jdict.items())
#    return(jlist)

def prolog_loads(String):
    jdict = json.loads(String)
#    jlist = list(jdict.items())
    return(jdict)

#def prolog_load(File):
#    with open(File) as fileptr:
#        data = json.load(fileptr)
#        jlist = dict_to_list(data)
#        print(jlist)
#        return(jlist)

def prolog_load(File):
    with open(File) as fileptr:
        data = json.load(fileptr)
        return(data)

#should not be needed -- transformation now done in C.    
def dict_to_list(indict):
    originally_dict = False
    orig_struct = indict
    if type(indict) not in [dict,list,tuple]:
        return indict
    elif type(indict) is dict:
        indict = list(indict.items())
        originally_dict = True
    retstruct = []
    print("  ",end = " ")
    print(indict)
    for elt in indict:
#        print("    ",end = " ")
#        print(elt)
        if type(elt) in [dict,list,tuple]: 
            newelt = dict_to_list(elt)
        else:
            newelt = elt
        retstruct.append(newelt)
    if type(indict) is tuple:
        retstruct = tuple(retstruct)
    elif originally_dict == True:
        retstruct = ("__dict",retstruct)
    return(retstruct)

            
# Output: {'name': 'Bob', 'languages': ['English', 'Fench']}

def prolog_dumps(list):
    jdict = json.loads(String)
    jlist = list(jdict.items())
    return(jlist)

#--------------

def makelist():
    return([1,2,3,4])

def squares(start, stop):
     for i in range(start, stop):
         yield i * i

#--------------

def returnVal(X):
#        print(X)
        return(X)

def return_None():
        return(None)

def return_True():
        return(True)

def return_False():
        return(False)

def return_empty_dict():
        return({})

def return_empty_set():
        return(set())

def returnSet():
        empty = set()
        X = ['"foo"',"'bar'",{1,"hello",('a','b',7)}]
        return(X)

#--------------

def kwargs_append(X,**Features):
    List = [X]
    for (key,value) in Features.items():
#        print((key,value))
        List.append((key,value))
    return(List)
    
import numpy as np

#--------------

mat = np.arange(15).reshape(3, 5)

def go():
    dim = np.ndim(mat)
    return(dim)

#--------------

def func():
	lis = [1,2,3, (5, 6), 'hello', [11,17]]
	return lis

def func1():
        obj = (5,6,(7,8),[9,10])
        return obj

def return_error():
        X = 1/0
        return X

#--------------

def tupletest_func():
	l = (5, (), 'hello', (5, 6, 7))
	return l

#--------------

def my_generation(N):
        for i in range(1,N):
                yield i

#--------------

import inspect

def inspect_function1(module,func):
        print(type(func))
        mbrlist = inspect.getmembers(module)
        mbrdict = dict(mbrlist)
#        print(mbrdict)
        callable_func = mbrdict[func]
        return inspect.signature(callable_func)
        
def inspect_function2(module,function):
        func = locals()[function]
        print(func)
        return inspect.signature(module.func)

def prolog_load(File,**Features):
    with open(File) as fileptr:
        data = json.load(fileptr,**Features)
        return(data)

#----------------------------------

class ReturnVal:
        
        def __init__(self):
                pass

        def returnVal(self,X):
                return(X)

        def returnVal_kwargs(self,X,**Features):
                ret = kwargs_append(X,**Features)
                return(ret)

        def returnVal_kwargs7(self,A,B,C,D,E,F,G,**Features):
                ret = kwargs_append([A,B,C,D,E,F,G],**Features)
                return(ret)

#----------------------------------

from collections import namedtuple

Author = namedtuple('author','journal volume year')

John =  Author('TPLP',3,2021)

def return_complex():
        return(complex(3,2))
