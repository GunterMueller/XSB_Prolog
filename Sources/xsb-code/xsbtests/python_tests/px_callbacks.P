
:- export base_test/1, test_float/1,test_uni/2, test_json/1,
   test_class/2, test_float0/0.

:- import pyfunc/3 from xsbpy.

% make sure we can find the module.
base_test(_A):- writeln(here).
      
test_float(_A):-
     pyfunc(testcb,myfloat('1e-4'),F),
     writeln(floatis(F)).

test_float0():-
     pyfunc(testcb,myfloat('1e-4'),F),
     writeln(floatis(F)).

test_uni(A,B):-
    pyfunc(xp_unicode,unicode_lower(A),B).

test_json(Ret):- 
    pyfunc(xp_json,prolog_loads('{"name":"Bob","languages": ["English","Fench","GERMAN"]}'),
	   Ret).

test_class(Name,Obj):-
    pyfunc('Person','Person'(Name,35),Obj).
