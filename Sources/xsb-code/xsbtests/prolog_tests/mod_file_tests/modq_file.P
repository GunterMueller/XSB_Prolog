%%:- export q/2.
:- module(modq,[q/2]).

q(X,Y) :- r(X,Y).
q(1,2).
q(2,3).

r(a,b).
r(b,c).
