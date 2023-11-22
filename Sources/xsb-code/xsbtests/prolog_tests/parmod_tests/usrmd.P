:- import s/3 from tstusrmd.

p(1,2,3).
p(2,3,4).
p(3,4,5).

r(a,b,c).
r(b,c,d).
r(c,d,e).

t(A,B,C) :- s(A,B,C).
