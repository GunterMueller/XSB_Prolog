:- export qqq/3.
:- multifile p/2.

p(1,1).
p(1,2).
p(1,3).

qqq(1,2,3).
qqq(X,Y,Z) :- p(X,Y), Z=3.

