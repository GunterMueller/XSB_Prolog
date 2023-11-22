:- table lanc/2.

lanc(X,Y):- edge(X,Y).
lanc(X,Y):- lanc(X,Z),edge(Z,Y).

edge(a,b).
edge(b,a).

end_of_file.
