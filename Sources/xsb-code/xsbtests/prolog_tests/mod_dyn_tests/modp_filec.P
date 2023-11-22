:-(compiler_options([dynamic([canonical(yes),ordering(a)])])).
:-(export(/(p,2))).

:-(p(X,Y), q(X,Y)).
p(5,6).
p(7,8).

q(a,d).
q(b,e).
