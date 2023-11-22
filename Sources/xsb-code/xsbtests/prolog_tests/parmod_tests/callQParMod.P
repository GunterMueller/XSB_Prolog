:- import myapp/3 from 'QParMod'(basics).

:- export still_my_app/3.

still_my_app(A,B,C) :- myapp(A,B,C).
