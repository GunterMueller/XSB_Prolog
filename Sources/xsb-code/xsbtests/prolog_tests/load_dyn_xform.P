
a --> b.

b --> [dcg_executed].

end_of_file.

end_of_file.

%:- table smtC_1/10 as index([6+8+9,6+9,6+8,8+9,6,8,9,0]) .
:- table smtC_1/10 as variant,index([6+8+9,6+9,6+8,8+9,6,8,9,0]) .

smtC_1(M,X,S,P,O,SC,SC0,PC,OC,OC0) :-
	ta1R:smtR(_M,X,S,P,O),
	M = ta1C,
	P \== 'aida:hasName',
	P \== 'aida:textValue',
	logEvery(1,[f,smtC_1a,smtR(M,X,S,P,O)]),
	%set subject and predicate clusters
	getCluster(S,SC,SC0,false,LevelS,ConfS),
	logEvery(1,[f,smtC_1b,LevelS,SC,S]), 
	%force the predicate abstraction level to agree with the subject
	%update - abandon this restriction as it eliminates too many answers
	getCluster(P,PC,PC0,true,LevelP,ConfP),
	logEvery(1,[f,smtC_1c,PC]),
	getCluster(O,OC,OC0,false,LevelO,ConfO),
	logEvery(1,[f,smtC_1d,OC]),
	Conf is (ConfS + ConfP + ConfO) / 3,
	logEvery(10000,[t,smtC_1d,ConfS,ConfP,ConfO,Conf,M,X,SC,PC,OC,S,P,O]) .

