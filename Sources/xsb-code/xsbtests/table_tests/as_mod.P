:- export mp/3.

mp(A,B,C):- min_path(A,B,C).
 
:- table min_path(_,_,lattice(min(_,_,_))).                                                   
min_path(From,To,1):- edge(From,To).                                                          
min_path(From,To,N):-                                                                         
    min_path(From,Neighbor,N1),                                                               
    edge(Neighbor,To),                                                                        
    N is N1 + 1.                                                                              
                                                                                              
min(X,Y,Z):- X > Y -> Z = Y ; Z = X.                                                          
                                                                                              
edge(a,b).
edge(b,d).                                                                                    
edge(b,e).                                                                                    
edge(d,e).       
