:- compiler_options([dynamic([])]).
:- export p/2.

p(X,Y) :- q(X,Y).
p(1,2).
p(2,3).

q(a,b).
q(b,c).
