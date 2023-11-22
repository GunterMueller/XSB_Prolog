/* File:      optcompile.P  -- compiler preprocessor
**
*/

%% This preprocessor is invoked using compiler_options([xpp_on(gpp,optcompile)])

:- import register_xsb_preprocessor/2 from parse.
:- import xsb_configuration/2 from xsb_configuration.
:- import slash/1 from machine.
:- import str_repl/4 from string.

?- register_xsb_preprocessor(optcompile,flr_preprocess_cmd(_,_,_,_)).
?- load_structures.

flr_preprocess_cmd(_InputFile,_PreprocName,_Options,Cmd) :-
	xsb_configuration(config_bindir,ConfigBindir),
	opt_installdir(FlrInstallDir),
	slash(Slash),
        fmt_write_string(Cmd,
                         '"%s%sxsb" --noprompt --nobanner -e "asserta(library_directory(''%s'')),see(userin),[optcompile],flr_cmpopt,halt."',
                         f(ConfigBindir,Slash,FlrInstallDir)).
	
%% postprocess the output from gpp
flr_cmpopt :-
	repeat,
        writeln(3,'%%Reading next clause'),
	read(Term),
	(Term == end_of_file -> writeln(3,'  %%End of file')
	;
	    opttransform(Term,OptTermList),
	    optwrite_rules(OptTermList),
	    fail
	).


opttransform((H:-Guard,Rest),OptTermList) :-
        writeln(3,'  %%Trying to query preproc_struct/1'),
        (preproc_struct(Guard) -> write(3,'  %%'), writeln(3,guard=Guard)
        ; writeln(3,'  %%Nothing in preproc_struct/1?????')
        ),
        findall((H :- Rest),preproc_struct(Guard),OptTermList),
	OptTermList \= [],
	!.
opttransform(R,[R]).

optwrite_rules([]) :- !.
optwrite_rules([Rule|OptTermList]) :- 
	write_canonical(Rule),
	writeln('.'),
	optwrite_rules(OptTermList).

%% utilities

opt_installdir('.').

load_structures :-
	opt_installdir(FlrInstallDir),
	slash(Slash),
        fmt_write_string(CompStructures, '%s%soptstructures', arg(FlrInstallDir,Slash)),
        banner:set_banner_control(quietload,1),
        banner:set_banner_control(nofeedback,1),
        banner:set_banner_control(nobanner,1),
        load_dyn(CompStructures),
	str_repl(CompStructures,['\\'],['/'],FCompStructures), % if windows
        write(3,'\n%%File '), write(3,FCompStructures), writeln(3,' is loaded').
