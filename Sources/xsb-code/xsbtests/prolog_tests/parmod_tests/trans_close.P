:- module_parameters(edge).

:- export out/2.

:- import out/2 from edge as edge/2.

out(X,Y) :- edge(X,Y).
out(X,Y) :- edge(X,Z),out(Z,Y).
