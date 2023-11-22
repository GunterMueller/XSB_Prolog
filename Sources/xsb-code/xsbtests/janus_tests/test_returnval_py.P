:- export returnval/2, preturnval/2, returnval/3.

returnval(X,Y):-
    X = Y.

preturnval(X,Y):-
    writeln(prolog(X)),
    X = Y.

returnval(Tag,X,[Tag,X]).


