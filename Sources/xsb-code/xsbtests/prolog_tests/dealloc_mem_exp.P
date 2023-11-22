:- import length/2 from basics.

test(N) :-
	(p(N,X),length(X,C)
	 ->	writeln(succeed:len=C)
	 ;	writeln('ERROR!')
	).

p(N,X) :-
	(N > 0
	 ->	N1 is N-1,
		p(N1,Y),
		X = [f(a,a,a,a)|Y]
	 ;	X=[]
	).
