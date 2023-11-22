:- export q/2.

:- import p/3 from 'TESTQUOTE'.

q(A,B) :- p(_,A,B).
