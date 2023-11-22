:- multifile tc/2, q/3.
:- table tc/2.  %%, r/4.

tc(A,B) :- tc(A,C), edge(C,B).
tc(A,B) :- edge(A,B).
 
edge(a,b).
edge(b,a).
