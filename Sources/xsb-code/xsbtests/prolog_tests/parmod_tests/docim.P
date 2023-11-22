:- export c/3.

:- import p1/3 from usermod('pm_subdir/umod_p').

c(A,B,C) :- p1(A,B,C).
