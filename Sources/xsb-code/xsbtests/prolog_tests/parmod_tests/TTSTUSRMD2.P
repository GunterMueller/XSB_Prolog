:- import p/3 from usermod(usrmd).
:- import r/3 from usermod(usrmd).

v(A,B,C) :- p(A,B,C).
v(A,B,C) :- r(A,B,C).

