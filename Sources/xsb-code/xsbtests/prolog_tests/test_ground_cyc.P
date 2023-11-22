test_gc(P) :- (ground_cyc(P)-> write(ground_cycle_safe(P)); write(not_ground_cycle_safe(P))),nl.
tgc :- test_ground_cyc.
test_ground_cyc :- tgc(P),test_gc(P),fail.
test_ground_cyc :- X=f(X),test_gc(X).
test_ground_cyc :- X=f(X,Y),test_gc(X).

tgc(a).
tgc(_X).
tgc(f(a)).
tgc(f(_X)).
tgc(f(a,a)).
tgc(f(a,_X)).
tgc(f(f(f(a)))).
tgc(f(f(f(_X)))).

:- tgc.
end_of_file.

| ?- [test_ground_cyc loaded]
ground_cycle_safe(a)
not_ground_cycle_safe(_h191)
ground_cycle_safe(f(a))
not_ground_cycle_safe(f(_h191))
ground_cycle_safe(f(a,a))
not_ground_cycle_safe(f(a,_h192))
ground_cycle_safe(f(f(f(a))))
not_ground_cycle_safe(f(f(f(_h195))))
not_ground_cycle_safe(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(...))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))

yes


