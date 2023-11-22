
:- compiler_options([xpp_on(gpp,optcompile)]).

:- import is_flvariable/3 from usermod.


collect_flvars(ParserTerm,[ParserTerm|Vars],Vars,ProtVars,ProtVars) :-
	is_flvariable(ParserTerm,_Name,_Index),
	!.

compile_body_literal(ParserTerm,_WS,NULL,BodyLitCode,[],Status) :-
	is_fladd(ParserTerm,LoadList),
	!,
	compile_load(LoadList,FL_ADD,BodyLitCode,Status).

compile_body_literal(ParserTerm,_WS,NULL,BodyLitCode,[],Status) :-
	is_flconstraint(ParserTerm,ConstrBody),
	!,
	push_context(CONTEXT_COMPILER_ARITHMETICS),
	set_context(CONTEXT_COMPILER_CONSTRAINT),
	compile_body(ConstrBody,ConstrBodyCode,Status),
	clear_context(CONTEXT_COMPILER_CONSTRAINT),
	pop_context(CONTEXT_COMPILER_ARITHMETICS),
	constraint_struct(ConstrBodyCode,BodyLitCode).

