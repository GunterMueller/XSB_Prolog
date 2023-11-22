
:- export base_test/1, get_globals/1, test_float/1,test_uni/2, test_json/1,
   test_class/2, test_float0/0.

:- import py_func/3,py_func/4 from janus.

% make sure we can find the module.
base_test(_A):- writeln(here).
      
test_float(_A):-
     py_func(testcb,myfloat('1e-4'),F),
     writeln(floatis(F)).

test_float0():-
     py_func(testcb,myfloat('1e-4'),F),
     writeln(floatis(F)).

test_uni(A,B):-
    py_func(xp_unicode,unicode_lower(A),B).

test_json(Ret):- 
    py_func(xp_json,prolog_loads('{"name":"Bob","languages": ["English","Fench","GERMAN"]}'),
	   Ret).

test_class(Name,Obj):-
    py_func('Person','Person'(Name,35),Obj,[py_object(true)]).

get_globals(X):-
    py_func(builtins,globals(),X).

