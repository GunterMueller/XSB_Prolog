:- module_parameters(modin1,modin2).

:- export out/2.

:- import out/2 from modin1 as rel1/2.
:- import out/2 from modin2 as rel2/2.

out(X,Y) :- rel1(X,Y).
out(X,Y) :- rel2(X,Y).
