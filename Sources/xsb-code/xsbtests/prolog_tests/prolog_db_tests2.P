:- import size_db/2 from prolog_db.

/* these tests need to be here where all the (other) prolog_db calls,
used under call_i_db, are in usermod.  In other they are imported from
prolog_db, and since load_in_db loads everything to usermod, these
wouldn't be found.  Must fix....  */

testdbu :- testdbu1,fail.

testdbu1 :-
    (do_all
     nl,writeln(start_test4),
     xsb_configuration(libdir,LibDir),
     string:concat_atom([LibDir,'/prolog_db.P'],Prolog_db_file),
     prolog_db:new_db(EmptyDB),
     prolog_db:assert_in_db(:-(comment(_,_)),EmptyDB,ExcDB), % ignore comment/2 directives.
     prolog_db:load_in_db(Prolog_db_file,ExcDB,EmptyDB,_DB),
%%     prolog_db:dump_db(_DB,userout),
%%     term_size(_DB,DBSize), writeln(userout,size=DBSize),
%%     size_db(_DB,DBCnt), writeln(userout,cnt=DBCnt),
     prolog_db:in_db((new_db(_DB0),
		 assert_in_db(app([],_L,_L),_DB0,_DB1),
		 assert_in_db((app([_X|_L1],_L2,[_X|_L3]):-app(_L1,_L2,_L3)),_DB1,_DB2),
		 assert_in_db(nrev([],[]),_DB2,_DB3),
		 assert_in_db((nrev([_X|_LL],_RR) :- nrev(_LL,_RR1),app(_RR1,[_X],_RR)),_DB3,_DB4),
			   pure_in_db((cputime(_T0),
				  (nrev([a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z],REV),writeln(test4(REV)),fail ; true),
				  cputime(_T1),_Time is _T1-_T0 %% ,writeln(time(_Time))
				 ),_DB4)
		),_DB)
    ),
    fail.

