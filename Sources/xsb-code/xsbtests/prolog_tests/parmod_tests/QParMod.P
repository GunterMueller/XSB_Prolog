:- module_parameters(parmod).

:- export myapp(A,B,C).

:- import append/3 from parmod.

myapp(A,B,C) :- append(A,B,C).

