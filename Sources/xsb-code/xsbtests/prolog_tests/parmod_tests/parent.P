:- module_parameters(modmother,modfather).

:- export out/2.

:- import out/2 from union(modmother,modfather) as parent/2.

out(X,Y) :- parent(X,Y).
