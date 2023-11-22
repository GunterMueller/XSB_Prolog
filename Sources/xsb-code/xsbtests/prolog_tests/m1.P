
:- export exported/2, p1/2, p2/2, p3/2, p3s/2, p4/2, p10/0, p11/0, r2/2, d1/2.

:- import p9/2,a1/0 from m2.
:- import d2/2 from usermod.

exported(a,b).
%local(c,d).

:- dynamic d1/2.
% local dynamic code
p1(X,Y):- assert(d1(X,Y)).
p2(X,Y):- d1(X,Y).

p3(X,Y):- assert(d2(X,Y)).
p4(X,Y):- d2(X,Y).

% importing an exported symbol
p3s(A,B):- p9(A,B).

% importing a non-exported symbol
%p4(A,B):- p8(A,B).

p10:- call(a1).

p11:- atom_chars(A1,[a,'1']),call(A1).

% redefining a symbol
r2(A,B):- m2:r2(A,B).

