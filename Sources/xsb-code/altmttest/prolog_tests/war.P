test :-
	( X = [5], _ == [X]
	 ->	writeln('flattened yes!')
	 ; 	writeln('flattened no!')
	), fail.
test :- 
	( _ == [[5]]
	 ->	writeln('nested yes!')
	 ;	writeln('nested no!')
	), fail.
test :- 
	( [[5,mother],[5,father]] == [[5,mother],[5,father]]
	 ->	writeln('two nested yes!')
	 ;	writeln('two nested no!')
	).
