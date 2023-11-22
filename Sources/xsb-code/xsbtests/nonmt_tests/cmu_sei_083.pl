
% Tests multiple updates/find_visitors with the same subgoal

test:- solve(foo).

:-import incr_assert/1,incr_retract/1 from increval.
:-import maplist/2 from swi.

:-dynamic findint/2 as incremental.
:-dynamic factClassHasNoBase/1 as incremental.
:-dynamic debuggingStoreEnabled.

?- set_prolog_flag(clause_garbage_collection,off).
?- set_prolog_flag(heap_garbage_collection,none).

possibleVFTableEntry(0x40aca4, 0x1b4, 0x406870).
possibleVFTableEntry(0x40aca4, 0x1b8, 0x406876).
possibleVFTableEntry(0x40aca4, 0x1bc, 0x40687c).

debug_store(_X):-debuggingStoreEnabled->e;true.

possibleMethod(Method):-possibleVFTableEntry(_,_,Method).
possibleMethodSet(Set):-setof(Method,possibleMethod(Method),Set).

makeAllObjects:-possibleMethodSet(PS),maplist(make,PS).
methodsNOTOnSameClass(M,Method2):-findint(M,_C),findint(Method2,_C2).

:-table reasonMergeClasses/2 as incremental.
reasonMergeClasses(C,Method):-
    nvwriteln('reasonmerge1'(findint(C,Class))),findint(C,Class),
    nvwriteln('reasonmerge2(C,Class)'),factClassHasNoBase(Class),
    writeln('reasonmerge3'),methodsNOTOnSameClass(C,Method).

guessConstructor:-findint(C,C),tryClassHasNoBase(C).
tryClassHasNoBase(C):-try_assert(factClassHasNoBase(C)).

concludeMergeClasses:-
    writeln('conclude1'),reasonMergeClasses(M,Method2),
    writeln('conclude2'),mergeClasses(M,Method2),writeln('conclude3').

if_(If_0,Then_0,_):-(If_0,Then_0).

make(M):-try_assert(findint(M,M)).
unionhelp(d,_R,M):-try_retract(findint(M,_Rd)).
union(M,M2):-findint(M,_R),myfindall(M2,S2),maplist(unionhelp(d,w),S2),writeln('union').
myfindall(M,S):-findint(M,R),setof(X,findint(X,R),S).

try_assert(X):-X;try_assert_real(X).
try_assert_real(X):-incr_assert(X),nvwriteln(try_assert_real(X)).

try_retract(X):-X,try_retract_real(X).
try_retract_real(X):-nvwriteln('retracting'(X)), incr_retract(X), writeln('done retracting').

mergeClasses(M,M2):-union(M,M2),writeln('pre debug store'),debug_store(d),writeln('post debug store').

reasonForwardAsManyTimesAsPossible:-writeln('reason1'),concludeMergeClasses,
                                    writeln('reason2'),reasonForwardAsManyTimesAsPossible,writeln('reason3').

solve(_X):-makeAllObjects,guessConstructor,reasonForwardAsManyTimesAsPossible.

:- import numbervars/1 from num_vars.
nvwriteln(Term) :-
    numbervars(Term),
    writeln(Term),
    fail.
nvwriteln(_Term).
