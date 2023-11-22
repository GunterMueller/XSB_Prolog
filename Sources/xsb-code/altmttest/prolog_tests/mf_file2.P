:- multifile p/2.
:- export pp/2.

p(2,1).
p(2,2).
p(2,3).
p(X,Y) :- qqq(X,Y,_).

qqq(5,5,5).  % local

pp(X,Y) :- qqq(X,Y,_).

