:- encoding(latin_1).
:- set_prolog_flag(character_set,latin_1).

test_sub:- 
       compile(unicode_facts_c),
       ['unicode_facts_c'],
       a(X,Y),writeln(a(X,Y)),fail.
test_sub:- a(X,Y),writeq(a(X,Y)),nl,fail.
test_sub:- write(uncode_escape('u306f','\u306f')),nl,fail.
test_sub:- test_canonical,fail.
test_sub.

test_canonical:- 
       open('unicode_facts.P',read,S),
       test_canonical_1(S),
       close(S),
       !.

test_canonical_1(S):- 
       repeat,
       read_canonical(S,F),
       (F = end_of_file -> 
          true
        ; 
          write_canonical(rc_c(F)),nl,fail ).

test_fmt:- 
       open('unicode_facts.P',read,S),
       fmt_read(S,"%s",A,_),
       fmt_write("formatted read: %s !\n",A).