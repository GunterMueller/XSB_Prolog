:- export p/3.

:- module_parameters(mod1).

:- import append/3 from mod1.

p(A,B,C) :- append(A,B,C).
