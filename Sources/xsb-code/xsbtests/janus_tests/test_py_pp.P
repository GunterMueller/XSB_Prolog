
:- ensure_loaded(janus).
:- import py_pp/1,py_pp/3 from py_pp.

test:-
     writeln('------------------------------------ pformat '),
     Term = -( 3,3.14159,100000000,
		   %py_set( [a,b,c] ),
	      [d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v],
	      {one:two,three:four}),
     %     py_func( pprint,pformat(Term) ,String ),writeln(String),
     py_pp(Term),
     fail.
test:-
     writeln('------------------------------------  pformat '),
     py_func(test_janus_plg,prolog_load('json_examp.txt'),Json),
     %     py_func(pprint,pformat(Json),String),writeln(String),
     py_pp(Json),
     fail.
test:-
     writeln('==================================== py_pp.P'),
     Term = -( 3,3.14159,100000000,py_set( [a,b,c] ),
	      [d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v],
	      {one:two,three:four}),
     py_pp(userout,Term,[prolog_pp(true)]),
     fail.
test:-
     writeln('------------------------------------ py_pp.P'),
     py_func(test_janus_plg,prolog_load('json_examp.txt'),Json),
     py_pp(userout,Json,[prolog_pp(true)]),
     fail.
test.     
