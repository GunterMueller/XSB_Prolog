
% test of compiler throwing the right error when the second argument of table_index is not a list.

:- table p/2 as subsumptive.
:- table_index(p/2,0).

p(X,Y):- r(X,Y),writeln(p1(X,Y)).

%:- table d/2 as subsumptive,dyn.
%:- table_index(d/2,0).
%:- table_index(d/2,[0]).

