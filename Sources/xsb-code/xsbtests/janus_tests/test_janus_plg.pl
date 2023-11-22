:- compiler_options([xpp_on,spec_off]).
:- ensure_loaded(janus).
#include "../../XSB/packages/janus/janus_defs.h"
:-  set_prolog_flag(character_set, utf_8) . 

:- import py_func/3, py_dot/3, py_func/4,py_func/5,janus_python_version/1 from janus.
:- import concat_atom/2 from string.
:- import length/2 from basics.
:- import xsb_error_get_message/2,xsb_error_get_tag/2 from error_handler.
:- import lazy_writeln/1 from standard.
:- import numbervars/1 from num_vars.

test:-
    func_tests,
    py_object_tests,
    dataConversionTests,
%    callback_test,
    json_tests,
    kwargs_tests,
    error_tests,
    meth_tests,
    variadic_tests,
    pyc_tests,
    py_iter_tests,
    more_iter_tests,  
    py_func(gc,collect(),Collect),
    writeln(collect(Collect)).

%--------------------------------

func_tests :- 
    check_call(py_func(test_janus_plg, sumlist3(5,[1,2,3]),_Res1),[6,7,8]),
    fail.
func_tests :- 
    check_call(py_func(builtins,float('+1E6'),_Res2),1000000.0),
    fail.
func_tests :- 
    catch(py_func(builtins,set({a,b,c,d}),_),_E,
	  (xsb_error_get_message(_E,M),lazy_writeln(['(should error) py_func set: ',M]))),
    fail.
func_tests :- 
    check_call(py_func(test_janus_plg,return_empty_dict(),_F),{}()),
    fail.
func_tests :- 
    check_call(py_func(test_janus_plg,return_empty_set(),_F),py_set([])),
    fail.
func_tests :- 
    check_call(py_func(test_janus_plg,my_generation(5),_,[py_object(true)]),pyObj(_)),
    fail.
func_tests :- 
    check_call(py_func(test_janus_plg,my_generation(5),_,[iter(true)]),[1,2,3,4]),
    fail.
% Tests casting to an iterator 
func_tests :- 
    check_call(py_func(builtins, range(1,5),_F,[iter(true)]),[1,2,3,4]),
    fail.
func_tests:- 
    catch(py_func( test_janus_plg, returnVal(_),_),_E,
	  (xsb_error_get_message(_E,M),numbervars(M),
	   lazy_writeln(['(should error) py_func check_var top level: ',M]))),
    fail.
func_tests:-
    catch(py_func(test_janus_plg, returnVal([a,b,_]),_MinValue),_E,
	  (xsb_error_get_message(_E,M),numbervars(M),
	   lazy_writeln(['(should error) py_func check_var in term: ',M]))),
    fail.
func_tests.

py_object_tests :- 
    check_call(py_func(builtins,float('+1E6'),_Res2,[py_object(true)]),1000000.0),
    fail.
py_object_tests :- 
    check_call(py_func(test_janus_plg, returnVal(1234), _,[py_object(true)]),1234),
    fail.
py_object_tests :- 
    check_call(py_func(test_janus_plg, returnVal(foobar), _,[py_object(true)]),foobar),
    fail.
py_object_tests :- 
    check_call(py_func(test_janus_plg, returnVal(@(true)),_,[py_object(true)]),@(true)),
    fail.
py_object_tests :- 
    check_call(py_func(builtins,float('+1E6'),_Res2,[py_object(true)]),1000000.0),
    fail.
py_object_tests :- 
    check_call(py_func(builtins,set([a,b,c,d]),_F,[py_object(true)]),pyObj(_)),
    fail.
py_object_tests :- 
    check_call(py_func(test_janus_plg, returnVal([1,2,3,4]),_,[py_object(true)]),pyObj(_)),
    fail.
py_object_tests :-
    check_call(py_func(test_janus_plg, returnVal(-(1,2,3,4)),_,[py_object(true)]),pyObj(_)),
    fail.
py_object_tests :- 
    check_call(py_func(test_janus_plg, returnVal({1:2,3:4}),_,[py_object(true)]),pyObj(_)),
    fail.
py_object_tests:- 
    check_call(py_func(test_janus_plg,returnVal([1,2,3,4]),Obj,[py_object(true)]),pyObj(_)),
    py_func(test_janus_plg,returnVal(Obj),F),
    (F = [1,2,3,4] ->
       writeln(succeeded(py_func(test_janus_plg,returnVal(pyobj),[1,2,3,4])))
     ; writeln('!!!failed'(py_func(test_janus_plg,returnVal(pyobj),[1,2,3,4]))) ),
    fail.
py_object_tests :-
    py_dot_py_object_tests.
py_object_tests.

py_dot_py_object_tests:-
    py_func(test_janus_plg,'ReturnVal'(),PyObj),
    check_call(py_dot(PyObj,returnVal([1,2,3,4]),_,[py_object(true)]),pyObj(_)),
    fail.
py_dot_py_object_tests:-
    py_func(test_janus_plg,'ReturnVal'(),PyObj),
    check_call(py_dot(PyObj,returnVal(py_set([1,2,3,4])),_,[py_object(true)]),pyObj(_)),
    fail.
py_dot_py_object_tests:-
    py_func(test_janus_plg,'ReturnVal'(),PyObj),
    check_call(py_dot(PyObj,returnVal(-(1,2,3,4)),_,[py_object(true)]),pyObj(_)),
    fail.
py_dot_py_object_tests:-
    py_func(test_janus_plg,'ReturnVal'(),PyObj),
    check_call(py_dot(PyObj,returnVal({1:2,3:4}),_,[py_object(true)]),pyObj(_)),
    fail.
py_dot_py_object_tests:-
    py_func(test_janus_plg,'ReturnVal'(),PyObj),
    check_call(py_dot(PyObj,returnVal(42),_,[py_object(true)]),42),
    fail.
py_dot_py_object_tests:-
    py_func(test_janus_plg,'ReturnVal'(),PyObj),
    check_call(py_dot(PyObj,returnVal(3.14),_,[py_object(true)]),3.14),
    fail.
py_dot_py_object_tests:-
    py_func(test_janus_plg,'ReturnVal'(),PyObj),
    check_call(py_dot(PyObj,returnVal(mystring),_,[py_object(true)]),mystring),
    fail.
py_dot_py_object_tests:-
    py_func(test_janus_plg,'ReturnVal'(),PyObj),
    check_call(py_dot(PyObj,returnVal_kwargs([1,2,3,4],bar=1,baz=2),_F),[[1,2,3,4],baz - 2,bar - 1]),
    fail.
py_dot_py_object_tests:-
    py_func(test_janus_plg,'ReturnVal'(),PyObj),
    check_call(py_dot(PyObj,returnVal_kwargs7(a,b,c,d,e,f,g,bar=1,baz=2),_H),
	       [[a,b,c,d,e,f,g],-(baz,2),-(bar,1)]),
    fail.
y_dot_py_object_tests.
	       

%-------------------------------

py_iter_tests:-
    check_call(setof(Ret,py_iter(test_janus_plg,makelist(),Ret),_List),[1,2,3,4]),
    fail.
py_iter_tests:-
    check_call(setof(Ret,py_iter(test_janus_plg,squares(1,5),Ret),_List),[1,4,9,16]),
    fail.
py_iter_tests:-
    check_call(setof(Ret,py_iter(builtins,range(1,6),Ret),_List),[1,2,3,4,5]),
    fail.
py_iter_tests:-
    check_call(setof(Ret,py_iter(test_janus_plg,kwargs_append(foo,bar=1,baz=2),Ret),_List),
		     [foo,-(bar,1),-(baz,2)]),
    fail.
py_iter_tests:-
    check_call(setof(Ret,py_iter(test_janus_plg,my_generation(5),Ret),_List),[1,2,3,4]),
    fail.
py_iter_tests.
    
pyObj_GetIterTest :- 
	py_func(test_janus_plg, sumlist3(5,[1,2,3]), R),
	pyObj_GetIter(R, R1), pyObj_Next(R1, 6).

pyObj_NextTest :- 
	py_func(test_janus_plg, sumlist3(5,[1,2,3]), R),
	pyObj_GetIter(R, R1), pyObj_Next(R1, 6), not(pyObj_Next(R, 6)).

%--------------------------------

dataConversionTests :- 
    (intConvTest->
	 write('int conversion tests successful\n')
     ;   write('!!!int conversion tests failed\n')), 
    (floatConvTest->
	 write('float conversion tests successful\n')
     ;   write('!!!float conversion tests failed\n')),
    (stringConvTest->
	 write('string conversion tests successful\n')
     ;   write('!!!string conversion tests failed\n')),
    (listConvTest->
	 write('list conversion tests successful\n')
     ;   write('!!!list conversion tests failed\n')),
    (setConvTest->
	 write('set conversion tests successful\n')
     ;   write('!!!set conversion tests failed\n')),
    fail.
dataConversionTests :- 
    (tupleConvTest->
	 write('tuple conversion tests successful\n')
    ;    write('!!!tuple conversion tests failed\n')),
    fail.
dataConversionTests :- 
    (dictConvTest->
	 write('dict conversion tests successful\n')
    ;    write('!!!dict conversion tests failed\n')),
    fail.
dataConversionTests :-
    check_call(py_func(test_janus_plg,return_None(),_None),@('none')),
    fail.
dataConversionTests :- 
    check_call(py_func(test_janus_plg,return_True(),_True),@('true')),
    fail.
dataConversionTests :- 
    check_call(py_func(test_janus_plg,return_False(),_False),@('false')),
    fail.
dataConversionTests :- 
    (intConvTest_sizecheck->
	 write('int conversion_sizecheck tests successful\n')
     ;   write('!!!int conversion_sizecheck tests failed\n')), 
    (floatConvTest_sizecheck->
	 write('float conversion_sizecheck tests successful\n')
     ;   write('!!!float conversion_sizecheck tests failed\n')),
    (stringConvTest_sizecheck->
	 write('string conversion_sizecheck tests successful\n')
     ;   write('!!!string conversion_sizecheck tests failed\n')),
    (listConvTest_sizecheck->
	 write('list conversion_sizecheck tests successful\n')
     ;   write('!!!list conversion_sizecheck tests failed\n')),
    (setConvTest_sizecheck->
	 write('set conversion_sizecheck tests successful\n')
     ;   write('!!!set conversion_sizecheck tests failed\n')),
    (tupleConvTest_sizecheck->
	 write('tuple conversion_sizecheck tests successful\n')
    ;   write('!!!tuple conversion_sizecheck tests failed\n')),
    fail.
dataConversionTests:- 
    (dictConvTest_sizecheck->
	 write('dict conversion_sizecheck tests successful\n')
    ;    write('!!!dict conversion_sizecheck tests failed\n')),
    fail.
dataConversionTests.

py_func_sc(Mod,Func,Reg):-
    py_func(Mod,Func,Reg,[sizecheck(true)]).

intConvTest :-
    current_prolog_flag(min_integer, MinValue), 
    not(var(MinValue)), 
    current_prolog_flag(max_integer, MaxValue), 
    not(var(MaxValue)),
    py_func(test_janus_plg, returnVal(MinValue), MinValue), 
    py_func(test_janus_plg, returnVal(MaxValue), MaxValue).

intConvTest_sizecheck :-
    current_prolog_flag(min_integer, MinValue), 
    not(var(MinValue)), 
    current_prolog_flag(max_integer, MaxValue), 
    not(var(MaxValue)),
    py_func_sc(test_janus_plg, returnVal(MinValue), MinValue), 
    py_func_sc(test_janus_plg, returnVal(MaxValue), MaxValue).

floatConvTest :- 
    py_func(test_janus_plg, returnVal(3.54), 3.54),
    py_func(test_janus_plg, returnVal(3.5535252352), 3.5535252352).

floatConvTest_sizecheck :- 
    py_func_sc(test_janus_plg, returnVal(3.54), 3.54),
    py_func_sc(test_janus_plg, returnVal(3.5535252352), 3.5535252352).

stringConvTest :-
    py_func(test_janus_plg, returnVal(helloworld), helloworld),
    py_func(test_janus_plg, returnVal('helloworld'), helloworld),
    py_func(test_janus_plg, returnVal('Санкт-Петербург'),R3),R3 == 'Санкт-Петербург'.
				  
stringConvTest_sizecheck :-
    py_func_sc(test_janus_plg, returnVal(helloworld), helloworld),
    py_func_sc(test_janus_plg, returnVal('helloworld'), helloworld),
    py_func_sc(test_janus_plg, returnVal('Санкт-Петербург'),R3),R3 == 'Санкт-Петербург'.
				  
listConvTest:-
    py_func(test_janus_plg, returnVal([a,b,c]), R1),R1 = [a,b,c],
    py_func(test_janus_plg, returnVal([]), R2), R2 == [],
    py_func(test_janus_plg, returnVal([1,[2,3,4],[hello,155]]), R3),
    R3 ==  [1, [2, 3, 4], ['hello', 155]],
    py_func(test_janus_plg, func(), R4), R4 == [1,2,3, PYTUP_PROLOG(5, 6), 'hello', [11,17]],
    !.
listConvTest_sizecheck:-
    py_func_sc(test_janus_plg, returnVal([a,b,c]), R1),R1 = [a,b,c],
    py_func_sc(test_janus_plg, returnVal([]), R2), R2 == [],
    py_func_sc(test_janus_plg, returnVal([1,[2,3,4],[hello,155]]), R3),
    R3 ==  [1, [2, 3, 4], ['hello', 155]],
    py_func_sc(test_janus_plg, func(), R4), R4 == [1,2,3, PYTUP_PROLOG(5, 6), 'hello', [11,17]],
    !.

setConvTest:- 
    check_sort_call(py_func(test_janus_plg,returnSet( ),_Ret1),
		      ['"foo"','''bar''',PYSET_PROLOG([1,-(a,b,7),hello])]).

setConvTest_sizecheck:- 
    py_func_sc(test_janus_plg,returnSet( ) ,F ),
    F = ['"foo"','''bar''',PYSET_PROLOG(S)],
    length(S,3),
    py_func_sc(test_janus_plg, returnVal(PYSET_PROLOG([a,b,c])), R1 ),
    arg(1,R1,A), length(A,3),!.

tupleConvTest:-
    py_func(test_janus_plg, returnVal(PYTUP_PROLOG(a,b,c)), R1),R1 = PYTUP_PROLOG(a,b,c),
    py_func(test_janus_plg,tupletest_func(),R2),
    R2 = PYTUP_PROLOG(5,PYTUP_PROLOG(),hello,PYTUP_PROLOG(5,6,7)),
    !.

tupleConvTest_sizecheck:-
    py_func_sc(test_janus_plg, returnVal(PYTUP_PROLOG(a,b,c)), R1),R1 = PYTUP_PROLOG(a,b,c),
    py_func_sc(test_janus_plg,tupletest_func(),R2), R2 = PYTUP_PROLOG(5,PYTUP_PROLOG(),hello,PYTUP_PROLOG(5,6,7)),
    !.

dictConvTest_sizecheck:-
    py_func(returnVal,return_dictionary(),Ret,[sizecheck(true)]),
    Ret =  {('Name' : 'Geeks',1 : [1,2,3,4])}.

dictConvTest:-
    py_func(returnVal,return_dictionary(),Ret),
    Ret =  {('Name' : 'Geeks',1 : [1,2,3,4])}.

%--------------------------------

% TES: probably the wrong way to do this, but keeping it in for now.
% it *might* be responsible for uninitialized stack frame problem.

callback_test:- 
    py_func('test/testc', tester(),  X),
    X = [['Санкт-Петербург', '2']],
    writeln('callback test successful'),
    !.
callback_test:-
    writeln('!!!callback test failed').

% used in callback
p('Санкт-Петербург').
p(3).
q(2).

%--------------------------------

% numpy
pyc_tests:- 
    py_func(test_janus_plg,go(),X),X == 2,!,
    writeln('pyc_tests successful').
pyc_tests:- 
    writeln('!!!pyc_tests failed').

json_tests:-
    Jstring = '{"name": "Bob", "languages": ["English", "Fench","GERMAN"]}',
     py_func(test_janus_plg,prolog_loads(Jstring),F),
     (F = {(name : 'Bob',languages : ['English','Fench','GERMAN'])} -> 
	  writeln('json_loads_test successful')
        ; writeln('!!!json_loads_test_failed') ),
     fail.
%json_tests:-
%    Jstring = '{"name": "Bob", "languages": ["English", "French","GERMAN"]}',
%      atom_chars(Jgood,Jgch),write(Jgch),nl,
%  py_func('janus_json',prolog_loads(Jstring),Jdict),
%    py_func('janus_json',prolog_dumps(Jdict),[indent=2],Jindent),
%    (Jindent = Jgood -> 
%      writeln('json_dumps_test successful')
%    ; write('!!!json_dumps_test_failed'),nl,
%      writeq(Jgood),nl,writeq(Jindent),nl,
%      atom_chars(Jgood,Jgch),write(Jgch),nl,
%      writeln('----------------'),
%      atom_chars(Jindent,Jich),writeq(Jich),nl ),
%    fail.
json_tests:- 
    py_func(test_janus_plg,prolog_load('sample.json'),Json),
    writeln(json_2(Json)),
    fail.
json_tests.    

kwargs_tests:-
    check_call(py_func(test_janus_plg,kwargs_append(foo,bar=1,baz=2),_),[foo,-(baz,2),-(bar,1)]),
    fail.
kwargs_tests.

error_tests:-
    error_tests_1(no_module,foo(1),
		  [' Python Error;',_,'Type: <class ''ModuleNotFoundError''>',_,
		   'Value: ModuleNotFoundError("No module named ''no_module''")',_]),
    fail.
error_tests:-
    catch(py_func(test_janus_plg,foo(1),_),E,(xsb_error_get_tag(E,T),writeln(T))),
    fail.
error_tests:-
    catch(py_func(test_janus_plg,7,_F),E,xsb_error_get_tag(E,T)),
    (T = type_error(callable_term,7) ->
	 true ; writeln('catch(py_func(test_janus_plg,7)) failed')),
    fail.
% returns obj
%error_tests:-
%    catch(py_func(test_err,raise_err_3(),_X),E,(xsb_error_get_message(E,M),writeln(M))),
%    fail.
error_tests:-
    \+ janus_python_version('python3.11'),
   error_tests_1(test_err,raise_err_1(),
		  [' Python Error;',_,'Type: <class ''Exception''>',_, 
		   'Value: Exception(''spam'', ''eggs'')',_,
		   'Python traceback (most recent call last):',_,
		   'File ',_,', line 3, in raise_err_1',_]),
    fail.
error_tests:-
    janus_python_version('python3.11'),
    error_tests_1(test_err,raise_err_1(),
		  [' Python Error;',_,'Type: <class ''Exception''>',_,
		   'Value: Exception(''spam'', ''eggs'')',_]),
    fail.
error_tests:-
    catch(py_func(test_janus_plg,returnVal(py_set([q,{a:b}])),_F),E,
	  (xsb_error_get_tag(E,Tag),lazy_writeln(['Should error: (unhashable set elt) ',Tag]))),
    fail.
error_tests:-
    catch(py_func(test_janus_plg,returnVal({[1,2,3]:q}),_F),E,
	  (xsb_error_get_tag(E,Tag),lazy_writeln(['Should error: (unhashable dict key) ',Tag]))),
    fail.
error_tests:-
    catch(py_func(test_janus_plg,returnVal({[1,2,3]:q,a:b}),_F),E,
	  (xsb_error_get_tag(E,Tag),lazy_writeln(['Should error: (unhashable dict key) ',Tag]))),
    fail.
error_tests.

error_tests_1(Mod,Goal,Message):-
    catch(py_func(Mod,Goal,_X),E,xsb_error_get_message(E,Mess)),
    (concat_atom(Message,Mess) ->
       writeln(error_test_succeeded((Mod,Goal)))
    ;  writeln('!!!failed'(error_tests_1(Mod,Goal))),
       writeln(bad(Mess)),
       writeln(good(Message))).
    
meth_tests:- 
    check_call(py_func('Person','Person'(john,35),Obj),pyObj(_)),
    check_call(py_dot(Obj,func0(),_Ret1),'Hello my name is john'),
    check_call(py_dot(Obj,func1(doofus),_Ret2),'Hello my name is john and I''m a doofus'),
    check_call(py_dot(Obj,favorite_ice_cream,_Ret3),chocolate),
    check_call(py_dot(Obj,func2(real,doofus),_Ret4),
	       'Hello my name is john and I''m a real doofus'),
    check_call(py_dot(Obj,func3(real,big,doofus),_Ret5),
	       'Hello my name is john and I''m a real big doofus'),
    check_call(py_call(Obj:func3(eager,janus,programmer),_Ret6),
	       'Hello my name is john and I''m a eager janus programmer'),
    fail.
meth_tests:-
    check_call(py_dot(sys,flags,_Res),
	       -(0,0,0,0,0,0,0,0,0,0,0,1,0,@('false'),0,0,@('false'),-1)),
    check_call(py_dot(sys,exc_info(),_Res1),-(@('none'),@('none'),@('none'))),
    fail.
meth_tests:-
    py_func('Person','Person'(mary,34),Obj),
    obj_dict(Obj,Dict),writeln(dict(Dict)),
    obj_dir(Obj,Dir),writeln(dir(Dir)),
    fail.
meth_tests:- 
    catch(py_dot(1,favorite_ice_cream,_Ret4),E2,xsb_error_get_tag(E2,Msg2)),
    writeln('personErr1 (should err)'(Msg2)),
    py_func('Person','Person'(john,35),Obj),
    catch(py_dot(Obj,1,_Ret5),E3,xsb_error_get_tag(E3,Msg3)),
    writeln('personErr2 (should err)'(Msg3)),fail.
meth_tests:-
    catch(py_dot(   sys,'path.append'(_Dir1),_F1),_,true),
    writeln('caught error for path.append(Dir)'),
    catch(py_dot(   sys,'path.append'(_Dir2,_Dor2),_F2),_,true),
    writeln('caught error for path.append(Dir,Dor)'),
    catch(py_dot(   sys,'path.append'(_Dir3,_Dor3,_Dur3),_F3),_,true),
    writeln('caught error for path.append(Dir,Dor,Dur)'),
    fail.
meth_tests.

variadic_tests:-
    testit(py_func(variadic,variadic_print('a','b','c'),A),A,'a|b|c|'),
    testit(py_func(variadic,variadic_print('a','b','c','d'),B),B,'a|b|c|d|'),
    testit(py_func(variadic,opt_print('a'),C),C,'a|1'),
    testit(py_func(variadic,opt_print('b','c'),D),D,'b|c'),
    writeln('variadic tests succeeded'),!.
variadic_tests:-
    writeln('!!!variadic test failed').

testit(Call,Var,Answer):-
    call(Call),
    (Var = Answer -> 
       true
    ; writeln('!!!wrong_answer'(Call,Var,Answer)),
      fail).

py_call_tests :- 
    check_call(py_call(test_janus_plg:sumlist3(5,[1,2,3]),_Res1),[6,7,8]),
    fail.
py_call_tests :- 
    check_call(py_call(sys:flags,_), -(0,0,0,0,0,0,0,0,0,0,0,1,0,@('false'),0,0,@('false'),-1)),
    fail.
py_call_tests :- 
    check_call(py_call(sys:exc_info(),_),-(@('none'),@('none'),@('none'))),
    fail.
%py_call_tests :- 
%    check_call(py_call(Obj,favorite_ice_cream,_Ret3),chocolate),
%    fail.
py_call_tests.

check_call(py_dot(Obj,MA,Res),Atom):-
    py_dot(Obj,MA,Res),
    (Res = Atom ->
      (Res = pyObj(_) -> ResOut = pyObj ; ResOut = Res),
      (Obj = pyObj(_) -> ObjOut = pyObj ; ObjOut = Obj),
      lazy_writeln([py_dot(ObjOut,MA,ResOut),' succeeded.'])
    ; lazy_writeln(['!!! ',py_dot(pyObj,MA,ResOut),' failed.  Did not match ',Atom])).
check_call(py_dot(Obj,MA,Res,Opts),Atom):-
    py_dot(Obj,MA,Res,Opts),
    (Res = Atom ->
      (Res = pyObj(_) -> ResOut = pyObj ; ResOut = Res),
      (Obj = pyObj(_) -> ObjOut = pyObj ; ObjOut = Obj),
      lazy_writeln([py_dot(ObjOut,MA,ResOut,Opts),' succeeded.'])
    ; lazy_writeln(['!!! ',py_dot(pyObj,MA,ResOut,Opts),' failed.  Did not match ',Atom])).
check_call(py_func(Mod,MA,Res),Atom):-
    py_func(Mod,MA,Res),
    (Res = Atom ->
      (Res = pyObj(_) -> ResOut = pyObj ; ResOut = Res),
      lazy_writeln([py_func(Mod,MA,ResOut),' succeeded.'])
    ; lazy_writeln(['!!! ',py_func(Mod,MA,Res),' failed.  Did not match ',Atom])).
check_call(py_func(Mod,Func,Res,Opts),Atom):-
    py_func(Mod,Func,Res,Opts),
    (Res = Atom ->
      (Res = pyObj(_) -> ResOut = pyObj ; ResOut = Res),
      lazy_writeln([py_func(Mod,Func,ResOut,Opts),' succeeded.'])
    ; lazy_writeln(['!!! ',py_func(Mod,Func,Res,Opts),' failed.  Did not match ',Atom])).
check_call(py_call(Mod:Func,Res),Atom):-
    py_call(Mod:Func,Res),
    (Res = Atom ->
      (Mod = pyObj(_) -> ModOut = pyObj ; ModOut = Mod),
      (Res = pyObj(_) -> ResOut = pyObj ; ResOut = Res),
      lazy_writeln([py_call(ModOut,Func,ResOut),' succeeded.'])
    ; lazy_writeln(['!!! ',py_call(ModOut,Func,Res),' failed.  Did not match ',Atom])).
check_call(py_call(Mod:Func,Res,Opts),Atom):-
    py_call(Mod:Func,Res,Opts),
    (Res = Atom ->
      (Res = pyObj(_) -> ResOut = pyObj ; ResOut = Res),
      lazy_writeln([py_call(Mod,Func,ResOut,Opts),' succeeded.'])
    ; lazy_writeln(['!!! ',py_call(Mod,Func,Res,Opts),' failed.  Did not match ',Atom])).
check_call(setof(Res,py_iter(Mod,MA,Res),List),GoodList):- 
    setof(Res,py_iter(Mod,MA,Res),List),
    (List = GoodList ->
      lazy_writeln([py_iter(Mod,MA,List),' succeeded.'])
    ; lazy_writeln(['!!! ',py_iter(Mod,MA,List),' failed.  Did not match ',GoodList])).

check_sort_call(py_func(Mod,MA,Res),Atom):-
    py_func(Mod,MA,Res),
    (Res = ['"foo"','''bar''',py_set(Set)] ->
       true
    ; lazy_writeln(['!!!-1 ',py_func(Mod,MA,Res),' failed. Did not match ',['"foo"','bar',py_set(Set)]])),
    sort(Set,SetSort),
    (SetSort = [1,hello,-(a,b,7)] -> 
      lazy_writeln([py_func(Mod,MA,SetSort),' succeeded.'])
    ; lazy_writeln(['!!! ',py_func(Mod,MA,SetSort),' failed.  Did not match ',Atom])).

more_iter_tests:-
    check_call(py_func(range,demo_yield(),_Res1,[iter(true)]),[0,1,2,3,4,5,6,7,8,9]),
    fail.
more_iter_tests:-
    check_call(py_func(range,demo_comp(),_Res1,[iter(true)]),[0,1,2,3,4,5,6,7,8,9]),
    fail.
more_iter_tests:-
    check_call(py_func(range,demo_set(),_Res1,[iter(true)]),py_set([0,1,2,3,4,5,6,7,8,9])),
    fail.
more_iter_tests:-
    check_call(setof(Ret,py_iter(range,demo_yield(),Ret),_List),[0,1,2,3,4,5,6,7,8,9]),
    fail.
more_iter_tests:-
    check_call(setof(Ret,py_iter(range,demo_comp(),Ret),_List),[0,1,2,3,4,5,6,7,8,9]),
    fail.
more_iter_tests:-
    check_call(setof(Ret,py_iter(range,demo_set(),Ret),_List),[0,1,2,3,4,5,6,7,8,9]),
    fail.
more_iter_tests:-
    setof(Ret,(py_func( range,demo_yield( ) ,F ,[py_object(true)]),py_iter(F,Ret)),List),
    (List = [0,1,2,3,4,5,6,7,8,9] ->
	 lazy_writeln([setof(var,(py_func(range,demo_yield(),pyObj),py_iter(pyObj,var)),List),
		       ' succeeded'])
    ;   lazy_writeln(['!!!',setof(var,(py_func(range,demo_yield( ),pyObj),py_iter(pyObj,var)),List),
		      ' failed'])),
    fail.
%more_iter_tests:-
%    setof(Ret,(py_func( range,demo_yield( ) ,F ),py_next(F,Ret)),List),
%    (List = [0,1,2,3,4,5,6,7,8,9] ->
%	 lazy_writeln([setof(var,(py_func(range,demo_yield(),pyObj),py_next(pyObj,var)),List),
%		       ' succeeded'])
%    ;   lazy_writeln(['!!!',setof(var,(py_func(range,demo_yield( ),pyObj),py_next(pyObj,var)),List),
%		      ' failed'])),
%    fail.
more_iter_tests:-
    py_iter(range,demo_num(),Ret),
    (Ret = 1234 -> 
	 lazy_writeln([py_iter(range,demo_num(),ret),' succeeded'])
    ; 	 lazy_writeln(['!!!',py_iter(range,demo_num(),ret),' failed'])),
    fail.
%more_iter_tests:-
%    catch((py_func(range,demo_comp( ) ,F , [py_object(true)]),py_next(F,_G)),E,
%	  (xsb_error_get_message(E,M),write(M),writeln(' (should error)'))),
%    fail.
more_iter_tests:-
    catch((py_func(range,demo_comp( ) ,F , [py_object(true)]),py_iter(F,_G)),E,
	  (xsb_error_get_message(E,M),write('demo comp '),write(M),writeln(' (should error)'))),
    fail.
more_iter_tests:-
    catch( (py_func( range,demo_set( ) ,F ),py_obj_py_iter(F,_G)),_E,
	  (xsb_error_get_tag(_E,M),lazy_writeln(['demo set ',M,' (should error)']))),
    fail.
more_iter_tests:-
    catch( (py_func( range,demo_comp( ) ,F ),py_obj_py_iter(F,_G)),_E,
	  (xsb_error_get_tag(_E,M),lazy_writeln([M,' (should error)']))),
    fail.
more_iter_tests:-
    findall(H,(py_func(test_janus_plg,returnVal([1,2,3,4]),F,[py_object(true)]),py_iter(F,H)),AnsL),
    (AnsL = [1,2,3,4] ->
	 writeln('py_func(retVal([1,2,3,4]),F,[py_object(true)]),py_iter(F,H) succeeded')
       ; writeln('py_func(retVal([1,2,3,4]),F,[py_object(true)]),py_iter(G,H) failed')),
    fail.
more_iter_tests:-
    findall(H,(py_func(test_janus_plg,returnVal(-(1,2,3,4)),F,[py_object(true)]),py_iter(F,H)),AnsL),
    (AnsL = [1,2,3,4] ->
	 writeln('py_func(retVal(-(1,2,3,4)),F,[py_object(true)]),py_iter(F,H) succeeded')
       ; writeln('py_func(retVal(-(1,2,3,4)),F,[py_object(true)]),py_iter(G,H) failed')),
    fail.
more_iter_tests:-
    findall(H,(py_func(test_janus_plg,returnVal(py_set([1,2,3,4])),F,[py_object(true)]),
	       py_iter(F,H)),AnsL),
    (AnsL = [1,2,3,4] ->
	 writeln('py_func(retVal(py_set(1,2,3,4)),F,[py_object(true)]),py_iter(F,H) succeeded')
       ; writeln('py_func(retVal(py_set(1,2,3,4)),F,[py_object(true)]),py_iter(G,H) failed')),
    fail.
more_iter_tests:-
    findall(H,(py_func(builtins,range(1,4),F,[py_object(true)]),
	       py_iter(F,H)),AnsL),
    (AnsL = [1,2,3] ->
	 writeln('py_func(range(1,4)),F,[py_object(true)]),py_iter(F,H) succeeded')
       ; writeln('py_func(range(1,4)),F,[py_object(true)]),py_iter(F,H) failed')),
    fail.
more_iter_tests:- 
    findall(H,(py_func(builtins,range(1,4),F,[py_object(true)]),py_iter(F,H)),AnsL),
    (AnsL = [1,2,3] ->
	 writeln('py_func(range(1,4)),F),py_iter(F,H) succeeded')
    ; writeln('py_func(range(1,4)),F),py_iter(F,H) failed')),
    fail.
more_iter_tests:- 
    check_call(py_func(builtins,range( 1,4 ),_F,[iter(true)]),[1,2,3]),
    fail.
more_iter_tests.

end_of_file.

%pytXSB :- py_func('test/testc', tester(),  X), pyList2prList(X, []).
%pythonXSBTests :- (pytXSB->write('python to XSB tests successful\n'); write('python to XSB tests %failed\n')).


%object_tests:- 
%    meth_tests,
%    fail.
%Object_Tests.

%meth_tests:-
%    Ret2 = 'Hello my name is john and I''m a doofus',
%    Ret3 = chocolate,
%    Ret4 = 'Hello my name is john and I''m a real doofus',
%    Ret5 = 'Hello my name is john and I''m a real big doofus',
%    M1 = ' ++Error[janus]: arg 1 of py_dot/4 is not a Python Object: 1',
%    M2 = ' ++Error[janus]: arg 2 of py_dot/4 is not a Python function or attribute: 1',
%    writeln('Person test succeeded'),!.
%meth_tests:- 
%    writeln('!!!Person test failed').

<
