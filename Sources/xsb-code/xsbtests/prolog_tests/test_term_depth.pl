:- import for/3 from basics.

test:- 
    makelist(100,L),term_depth(L,LN),writeln(list_depth(LN)),
    makef(100,F),term_depth(F,FN),writeln(functor_depth(FN)).

makelist(0,[]):-!.
makelist(N,[N|T]):- 
    N1 is N - 1,
    makelist(N1,T).

makef(0,a):-!.
makef(N,f(T)):- 
    N1 is N - 1,
    makef(N1,T).

test_td(Nin,Nout):-
    makelist(Nin,L),
    term_depth(L,Nout).

time(Len,Its,Time):-
    cputime(B),
    makelist(Len,L),
    cputime(A),T is A - B,writeln(maketime(T)),
    cputime(Before),
    time_1(Its,L),
    cputime(After),
    Time is After - Before.

timef(Len,Its,Time):-
    makef(Len,L),
    cputime(Before),
    time_1(Its,L),
    cputime(After),
    Time is After - Before.


time_1(Its,L):- 
    for(_I,1,Its),
    term_depth(L,_),
    fail.
time_1(_Its,_L).
