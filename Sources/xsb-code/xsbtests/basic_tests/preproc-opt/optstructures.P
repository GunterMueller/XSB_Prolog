/* File:      optstructures.P  -- aux structs for compiler preprocessor
**
**
*/

:- compiler_options([xpp_on]).
#mode standard Prolog

#include "flora_terms.flh"
#include "flora_porting.flh"

:- import
        is_flaggregt_struct/1,
        is_flreify_struct/1,
        is_flstring_struct/1,
        is_flnumber_struct/1,
        is_fldatatype_struct/1,
        is_flbuiltin_identifier_struct/2,
        is_flbuiltin_identifier_struct/3,
        is_flatom_struct/2,
        is_flatom_struct/3,
        is_fllist_struct/1
   from flrparser.

:- import
        is_flterm/4,
        is_fltransactionalterm/4,
	is_flbirelate/4,
	is_flobjspec/4,
	is_flobjeql/3,
	is_flneg/3,
	is_flvariable/3,
	is_fltransactionalvariable/3,
        is_flfloralib/3,
        is_flfloralib/2,
	is_fldatatype/4,
	is_fltransactionaldatatype/4,
        is_flatom/2,
        is_flatom/3,
        is_flbuiltin_identifier/2,
        is_flbuiltin_identifier/3,
        is_flnumber/2,
        is_flnumber/3,
	is_flstring/2,
	is_flstring/3,
        is_flcharlist/3,
	is_fltransactionalstring/2,
	is_fltransactionalatom/2,
	is_fltoken/4,
	is_fltoken/3,
	is_fltoken/1,
	is_flobjref/4,
	is_flarith/2,
        is_fllist/4,
	is_flworkspace/3,
	is_reifyop/2,
	is_fltrans_atomnumberstring/1,
	is_flatomnumberstringbuiltin/1,
	is_flconjunct/3,
	is_fldisjunct/3,
	is_flplgnaf/2,
	is_flrulelognaf/2,
	is_default_negation/3,
	is_fllogicquantifier/5,
	is_fldelayquant/5,
	is_flhypothetical/4,
	is_flannotated_construct/3,
	is_fldescriptor/4,
	is_fldirective/3,
	is_flload/2,
	is_fladd/2,
	is_flconstraint/2,
	is_flplib/2,
	is_flplib/3,
	is_flpliball/2,
	is_flpliball/3,
	is_flinsert/4,
	is_flinsert/3,
	is_fldelete/4,
	is_fldelete/3,
	is_fltablerefresh/2,
	is_fltruthvalue/3,
	is_fltag_primitive/3,
	is_flprefixprimitive/4,
	is_fldelayedliteral/3,
	is_fldelayedliteral/4,
	is_flstopdelay/3,
	is_flstopdelay/2,
	is_flruleworkspace/3,
	is_fldynrule/4,
	is_flcatch/4,
	is_flthrow/2,
	is_flp2h/3,
	is_flnewmodule/3,
	is_flerasemodule/3,
	is_flupdaterule/3,
	is_flsimpleprimitive/3,
	is_flaggregate/6,
	is_flcallermodule/3,
	is_flclause/3,
	is_flclause/4,
	is_flannotated_clause_stmt/4,
	is_flannotated_clause_stmt/5,
	is_flcallmetafacts/3,
	is_flifthenelse/4,
	is_flifthen/3,
	is_fluniveqform/3,
	is_flmetauniv/3,
	is_flprologifthen/3,
	is_flcontrolconstruct/4,
	is_flcut/2,
        is_modularized_pratom/3,
	is_flmvdattspec/5,
	is_flsigattspec/5,
	is_flsigconstr/3,
	is_flincattspec/5,
	is_fltolistattspec/5,
	is_flboolsig/4,
	is_fltransig/4,
	is_fltranspec/3,
	is_flmethspec/3,
	is_flpassthru/2,
	is_flrule/3,
	is_flfact/2,
	is_flquery/2,
	is_fllatent_query/2,
	is_fludfunction/4,
	is_fludfunctionfact/3,
        is_florasyslib_struct/5
   from flrcompiler.

:- import
	is_prbuiltin_identifier/2,
	is_prbuiltin_identifier/3,
        is_prdatatype/4,
        is_prconjunct/3,
        is_prdisjunct/3,
        is_prvariable/1,
        is_prtransactionalvariable/3,
        is_pratomnumberstringbuiltin/2,
        is_prtransactionalnumber/3,
	is_prologterm/4,
	is_prologterm/5,
        is_prologterm/3
   from flrcoder.

%% from compile_head_literal/6
preproc_struct(is_flterm(FLTERM(Funct,N,Args),Funct,N,Args)).
preproc_struct(is_fltransactionalterm(FLTRANSACTIONALTERM(Func,N,Args),Func,N,Args)).
preproc_struct(is_flbirelate(FLBIRELATE(Obj1,RelType,Obj2),Obj1,RelType,Obj2)).
preproc_struct(is_flobjspec(FLOBJSPEC(Obj,Spec,Type),Obj,Spec,Type)).
preproc_struct(is_flobjeql(FLOBJEQL(O1,O2),O1,O2)).
preproc_struct(is_flneg(FLNEG(Goal,Idx),Goal,Idx)).
preproc_struct(is_flvariable(FLVAR(Name,Index),Name,Index)).
preproc_struct(is_fltransactionalvariable(FLTRANSACTIONALVAR(Name,Index),Name,Index)).
preproc_struct(is_flfloralib(FLFLORALIB(P,M),P,M)).
preproc_struct(is_flfloralib(FLFLORALIB(Mod),Mod)).
preproc_struct(is_fldatatype(FLDATATYPE(Sort,Literal,Index),Sort,Literal,Index)).
preproc_struct(is_fltransactionaldatatype(FLTRANSACTIONALPREDSPEC(FLDATATYPE(Sort,Literal,Index)),Sort,Literal,Index)).
preproc_struct(is_flatom(FLATOM(Atom,_I),Atom)).
preproc_struct(is_flatom(FLATOM(Atom,Index),Atom,Index)).
preproc_struct(is_fltransactionalatom(FLTRANSACTIONALATOM(Atom,_I),Atom)).
preproc_struct(is_flbuiltin_identifier(FLBUILTIN_IDENTIFIER(Builtin,_I),Builtin)).
preproc_struct(is_flbuiltin_identifier(FLBUILTIN_IDENTIFIER(Builtin,I),Builtin,I)).

%% additional from compile_head_pathexp/7
preproc_struct(is_flnumber(FLNUMBER(Number,_I),Number)).
preproc_struct(is_flnumber(FLNUMBER(Number,I),Number,I)).
preproc_struct(is_flstring(FLSTRING(String,_I),String)).
preproc_struct(is_flstring(FLSTRING(String,I),String,I)).
preproc_struct(is_flcharlist(FLCHARLIST(String,I),String,I)).
preproc_struct(is_fltransactionalstring(FLTRANSACTIONALSTRING(String,_I),String)).
preproc_struct(is_fltoken(FLTOKEN(_Token,_I))).
preproc_struct(is_fltoken(FLTOKEN(Token,I),Token,I)).
preproc_struct(is_fltoken(FLTOKEN(Token,Suffix,I),Token,Suffix,I)).
preproc_struct(is_flobjref(FLOBJREF(Obj,Att,Type),Obj,Att,Type)).
preproc_struct(is_flarith(FLARITH(Expr),Expr)).
preproc_struct(is_fllist(FLLIST(L,T,I),L,T,I)).
preproc_struct(is_flworkspace(FLWORKSPACE(P,WS),P,WS)).
preproc_struct(is_reifyop(FLREIFYOP(Formula),Formula)).

preproc_struct(is_fltrans_atomnumberstring(FLTRANSACTIONALATOM(_,_))).
preproc_struct(is_fltrans_atomnumberstring(FLTRANSACTIONALNUMBER(_,_))).
preproc_struct(is_fltrans_atomnumberstring(FLTRANSACTIONALSTRING(_,_))).

preproc_struct(is_flatomnumberstringbuiltin(FLATOM(_,_))).
preproc_struct(is_flatomnumberstringbuiltin(FLNUMBER(_,_))).
preproc_struct(is_flatomnumberstringbuiltin(FLSTRING(_,_))).
preproc_struct(is_flatomnumberstringbuiltin(FLCHARLIST(_,_))).
preproc_struct(is_flatomnumberstringbuiltin(FLBUILTIN_IDENTIFIER(_,_))).

%% Structures for compile_body/3
preproc_struct(is_flconjunct(FLCONJUNCT(L,R),L,R)).
preproc_struct(is_fldisjunct(FLDISJUNCT(L,R),L,R)).
preproc_struct(is_flplgnaf(FLPLGNAF(Goal),Goal)).
preproc_struct(is_flrulelognaf(FLRULELOGNAF(Goal),Goal)).
preproc_struct(is_default_negation(FLPLGNAF(Goal),Goal,FL_PLGNAF)).
preproc_struct(is_default_negation(FLRULELOGNAF(Goal),Goal,FL_RULELOGNAF)).
preproc_struct(is_fllogicquantifier(FLQUANTIFIER(Quant,VarNames,FormulaCode,Idx),Quant,VarNames,FormulaCode,Idx)).
preproc_struct(is_fldelayquant(FLDELAYQUANTIFIER(Quant,Condition,Goal,Index),Quant,Condition,Goal,Index)).
preproc_struct(is_flhypothetical(FLHYPOTHETICAL(Op,Goal,Index),Op,Goal,Index)).
preproc_struct(is_flannotated_construct(FLANNOTATEDCONSTRUCT(Descriptor,MainPartOfRule),Descriptor,MainPartOfRule)).
preproc_struct(is_fldescriptor(FLDESCRIPTOR(IdConstruct,Type,Index),IdConstruct,Type,Index)).

%% structures for compile_body_literal/6
preproc_struct(is_fldirective(FLDIRECTIVE(DirectList,I),DirectList,I)).
preproc_struct(is_flload(FLLOAD(LoadList),LoadList)).
preproc_struct(is_fladd(FLADD(LoadList),LoadList)).
preproc_struct(is_flconstraint(FLCONSTRAINT(ConstrBody),ConstrBody)).
preproc_struct(is_flplib(FLPLIB(P,M),P,M)).
preproc_struct(is_flplib(FLPLIB(P),P)).
preproc_struct(is_flpliball(FLPLIBALL(P),P)).
preproc_struct(is_flpliball(FLPLIBALL(P,M),P,M)).
preproc_struct(is_flinsert(FLINSERT(Op,List,Cond),Op,List,Cond)).
preproc_struct(is_flinsert(FLINSERT(Op,List),Op,List)).
preproc_struct(is_fldelete(FLDELETE(Op,List,Cond),Op,List,Cond)).
preproc_struct(is_fldelete(FLDELETE(Op,List),Op,List)).
preproc_struct(is_fltablerefresh(FLREFRESH(List),List)).
preproc_struct(is_fltruthvalue(FLTRUTHVALUE(Formula,Op),Formula,Op)).
preproc_struct(is_fltag_primitive(FLTAGPRIMITIVE(Descriptor,HeadList),Descriptor,HeadList)).
preproc_struct(is_flprefixprimitive(FLPREFIXPRIMITIVE(Prefix,Expansion,Module),Prefix,Expansion,Module)).
preproc_struct(is_fldelayedliteral(FLDELAYEDLITERAL(Op,Args),Op,Args)).
preproc_struct(is_fldelayedliteral(FLDELAYEDLITERAL(Op,Args,Mod),Op,Args,Mod)).
preproc_struct(is_flstopdelay(FLSTOPDELAY(Vars,I),Vars,I)).
preproc_struct(is_flstopdelay(FLSTOPDELAY(I),I)).
preproc_struct(is_flruleworkspace(FLRULEWORKSPACE(R,WS),R,WS)).
preproc_struct(is_fldynrule(FLDYNRULE(Head,Body,DescriptorList),Head,Body,DescriptorList)).
preproc_struct(is_flcatch(FLCATCH(Goal,Error,Handler),Goal,Error,Handler)).
preproc_struct(is_flthrow(FLTHROW(Error),Error)).
preproc_struct(is_flp2h(FLP2H(Prolog,Hilog),Prolog,Hilog)).
preproc_struct(is_flnewmodule(FLNEWMODULE(Op,Module),Op,Module)).
preproc_struct(is_flerasemodule(FLERASEMODULE(Op,Module),Op,Module)).
preproc_struct(is_flupdaterule(FLUPDATERULE(Op,RuleList),Op,RuleList)).
preproc_struct(is_flsimpleprimitive(FLSIMPLEPRIMITIVE(PrimName,Args),PrimName,Args)).
preproc_struct(is_flaggregate(FLAGGREGATE(Op,V,GV,Sort,Goal),Op,V,GV,Sort,Goal)).
preproc_struct(is_flcallermodule(FLCALLERMODULE(Op,Var),Op,Var)).
preproc_struct(is_flclause(FLCLAUSE(Head,Body),Head,Body)).
preproc_struct(is_flclause(FLCLAUSE(Mode,Head,Body),Mode,Head,Body)).
preproc_struct(is_flannotated_clause_stmt(FLANNOTATEDCLAUSE(Descriptor,Head,Body),Descriptor,Head,Body)).
preproc_struct(is_flannotated_clause_stmt(FLANNOTATEDCLAUSE(Descriptor,Mode,Head,Body),Descriptor,Mode,Head,Body)).
preproc_struct(is_flcallmetafacts(FLCALLMETAFACTS(MF,Idx),MF,Idx)).
preproc_struct(is_flifthenelse(FLIFTHENELSE(Cond,Then,Else),Cond,Then,Else)).
preproc_struct(is_flifthen(FLIFTHEN(Cond,Then),Cond,Then)).
preproc_struct(is_fluniveqform(FLUNIVEQFORM(Left,Right),Left,Right)).
preproc_struct(is_flmetauniv(FLMETAUNIV(Left,Right),Left,Right)).
preproc_struct(is_flprologifthen(FLPROLOGIFTHEN(Left,Right),Left,Right)).
preproc_struct(is_flcontrolconstruct(FLWHILEDO(Cond,Action),FLLIBWHILEDO,Cond,Action)).
preproc_struct(is_flcontrolconstruct(FLWHILELOOP(Cond,Action),FLLIBWHILELOOP,Cond,Action)).
preproc_struct(is_flcontrolconstruct(FLDOUNTIL(Cond,Action),FLLIBDOUNTIL,Cond,Action)).
preproc_struct(is_flcontrolconstruct(FLLOOPUNTIL(Cond,Action),FLLIBLOOPUNTIL,Cond,Action)).
preproc_struct(is_flcontrolconstruct(FLUNLESSDO(Cond,Action),FLLIBUNLESSDO,Cond,Action)).
preproc_struct(is_flcut(FLCUT(I),I)).

%% structures from compile_body_pathexp/7
%%preproc_struct(is_flsetarg(FLSETARG(Term,Idx),Term,Idx)).

%% structures from compile_pathexp_no_workspace/6
preproc_struct(is_modularized_pratom(PRMODULARIZEDATOM(PRDYNMODATOM(Atom),Idx),Atom,Idx)).
preproc_struct(is_modularized_pratom(PRMODULARIZEDATOM(PRDYNMODATOM(Atom),_Mod,Idx),Atom,Idx)).
preproc_struct(is_modularized_pratom(PRMODULARIZEDATOM(Atom,Idx),Atom,Idx)).
preproc_struct(is_modularized_pratom(PRMODULARIZEDATOM(Atom,_Mod,Idx),Atom,Idx)).

%% compile_head_specbody/7
%% compile_body_specbody/7
preproc_struct(is_flmvdattspec(FLMVDATTSPEC(Att,Arrow,Val,Type),Att,Arrow,Val,Type)).
preproc_struct(is_flsigattspec(FLSIGATTSPEC(Att,Arrow,Val,Type),Att,Arrow,Val,Type)).
preproc_struct(is_flsigattconspec(FLSIGATTCONSPEC(Att,Constr,Arrow,Val,Type),Att,Constr,Arrow,Val,Type)).
preproc_struct(is_flsigconstr(FLSIGCONSTR(Lower,Upper),Lower,Upper)).
preproc_struct(is_flincattspec(FLINCATTSPEC(Att,RefType,Val,Type),Att,RefType,Val,Type)).
preproc_struct(is_fltolistattspec(FLTOLISTATTSPEC(Att,Arrow,Val,Type),Att,Arrow,Val,Type)).
preproc_struct(is_flboolsig(FLBOOLSIG(Att,Arrow,Type),Att,Arrow,Type)).
preproc_struct(is_fltransig(FLTRANSIG(Att,Arrow,Type),Att,Arrow,Type)).
preproc_struct(is_fltranspec(FLTRANSPEC(Tran,Type),Tran,Type)).
preproc_struct(is_flmethspec(FLMETHSPEC(Meth,Type),Meth,Type)).
preproc_struct(is_flpassthru(FLPASSTRU(O),O)).

%% compile_internal/complie_add_internal
preproc_struct(is_flrule(FLRULE(Head,Body),Head,Body)).
preproc_struct(is_flfact(FLFACT(Head),Head)).
preproc_struct(is_flquery(FLQUERY(Body),Body)).
preproc_struct(is_fllatent_query(FLLATENTQUERY(Body),Body)).
preproc_struct(is_fludfunction(FLUDF(Function,Body,ReturnValue),Function,Body,ReturnValue)).
preproc_struct(is_fludfunctionfact(FLUDFFACT(Function,Value),Function,Value)).
preproc_struct(is_florasyslib_struct(FLORASYSLIB(I,F,N,Args), I,F,N,Args)).

%% Coder
%% pr-wrappers
preproc_struct(is_prvariable(PRVARIABLE(_Name,_I))).
preproc_struct(is_prtransactionalvariable(PRTRANSACTIONALVARIABLE(Name,I),Name,I)).
preproc_struct(is_pratomnumberstringbuiltin(PRATOM(Term,_),Term)).
preproc_struct(is_pratomnumberstringbuiltin(PRNUMBER(Term,_),Term)).
preproc_struct(is_pratomnumberstringbuiltin(PRSTRING(Term,_),Term)).
preproc_struct(is_pratomnumberstringbuiltin(PRBUILTIN_IDENTIFIER(Term,_),Term)).
preproc_struct(is_prtransactionalnumber(PRTRANSACTIONALNUMBER(Number,I),Number,I)).

preproc_struct(is_prconjunct(PRAND(L,R),L,R)).
preproc_struct(is_prdisjunct(PROR(L,R),L,R)).

preproc_struct(is_prologterm(PROLOGTERM(F,N,_Args),F,N)).
preproc_struct(is_prologterm(PROLOGTERM(F,N,_Args,_Module),F,N)).
preproc_struct(is_prologterm(PROLOGTERM(F,N,Args),F,N,Args)).
preproc_struct(is_prologterm(PROLOGTERM(F,N,Args,Module),F,N,Args,Module)).

preproc_struct(is_prbuiltin_identifier(PRBUILTIN_IDENTIFIER(Builtin,_I),Builtin)).
preproc_struct(is_prbuiltin_identifier(PRBUILTIN_IDENTIFIER(Builtin,I),Builtin,I)).
preproc_struct(is_prdatatype(PRDATATYPE(Sort,Lit,Idx), Sort,Lit,Idx)).


%% PARSER data
preproc_struct(is_fllist_struct(FLLIST(_Front,_Tail,_Idx))).
preproc_struct(is_flaggregt_struct(FLAGGREGATE(_Op,_Var,_GroupVars,_SortSpec,_Conds))).
preproc_struct(is_flreify_struct(FLREIFYOP(_Formula))).
preproc_struct(is_flnumber_struct(FLNUMBER(_Num,_I))).
preproc_struct(is_flstring_struct(FLSTRING(_Str,_I))).
preproc_struct(is_fldatatype_struct(FLDATATYPE(_Sort,_Lit,_I))).
preproc_struct(is_flbuiltin_identifier_struct(FLBUILTIN_IDENTIFIER(Name,I),Name,I)).
preproc_struct(is_flbuiltin_identifier_struct(FLBUILTIN_IDENTIFIER(Name,_I),Name)).

preproc_struct(is_flatom_struct(FLATOM(Atom,_I),Atom)).
preproc_struct(is_flatom_struct(FLATOM(Atom,I),Atom,I)).
