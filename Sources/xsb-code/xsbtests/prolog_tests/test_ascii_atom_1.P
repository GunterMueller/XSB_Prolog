:- encoding(latin_1).
% TLS: took out some tests that either wouldnt compile with previous version, or 
% wrote out symbols that sort couldn't handle (e.g., format).

:- import atom_concat/3 from standard.
:- import term_to_atom/2, term_to_codes/2 from string.
:- import format/2 from format.

?- set_prolog_flag(character_set,latin_1).

test_sub:- read_line_code('utf8.txt',List),
       atom_codes(A,List),
       writeq(atom_codes(A,List)),nl,fail.
%test_sub:- read_line_char('utf8.txt',List),
%       atom_chars(A,List),
%       write(atom_chars(A,List)),nl,fail.
test_sub:- atom_length('1こんaにちは今今的',Len),
       writeln(atom_length('1こんaにちは今今的',Len)),fail.
%test_sub:- atom_concat('1こんaにち','は今今的',Len),
%       writeln(atom_concat('1こんaにち','は今今的',Len)),fail.
%test_sub:- term_to_atom('今'('的'),F),writeln(term_to_atom(F)),fail.
%test_sub:- term_to_codes('今'('的'),F),writeln(term_to_codes(F)),fail.
test_sub:- atom_chars('1こんaにちは今今的',F),sort(F,S),chars_to_codes(S,Scodes),writeln(sort(Scodes)),fail.
%test_sub:- X = "1こんaにちは今今的",writeln(string_read(X)),fail.
%test_sub:- format("~d Hello~4cworld!~n", [1,0'は]),fail.
%test_sub:- format("~d Hello ~4s ~4s!~n",[2,"new","1aこちにはん今的"]),fail.
test_sub:- findall(p(X),p(X),L),writeln(findall(L)),fail.
test_sub:- setof(p(X),p(X),L),writeln(setof(L)),fail.
test_sub:- sub_atom(abracadabra,X,5,0,Y),writeln(sub_atom(abracadabra,X,5,0,Y)),fail.
%test_sub:- sub_atom('1こんaにちは今今的z',X,5,0,Y),writeln(sub_atom('1こんaにちは今今的z',X,5,0)),fail.
%test_sub:- char_code(F,12371),writeln(char_code_1(F)),fail.
%test_sub:- char_code('こ',F),writeln(char_code_2(F)),fail.
test_sub:- catch(char_code('こ',_),error(type_error(T,_),_),writeln(type_error(T))),fail.
test_sub:- atom_chars(aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa,_X), atom_chars(_Y,_X),atom_length(_Y,L),writeln(ascii_atom_length(L)),fail.
%test_sub:- atom_chars('1こんaにちは今今的z1こんaにちは今今的z1こんaにちは今今的z1こんaにちは今今的z1こんaにちは今今的z1こんaにちは今今的z1こんaにちは今今的z1こんaにちは今今的z1こんaにちは今今的z1こんaにちは今今的z1こんaにちは今今的z1こんaにちは今今的z1こんaにちは今今的z1こんaにちは今今的z1こんaにちは今今的z1こんaにちは今今的z1こんaにちは今今的z1こんaにちは今今的z1こんaにちは今今的z1こんaにちは今今的z1こんaにちは今今的z1こんaにちは今今的z1こんaにちは今今的z1こんaにちは今今的z1こんaにちは今今的z1こんaにちは今今的z1こんaにちは今今的z1こんaにちは今今的z1こんaにちは今今的z1こんaにちは今今的z1こんaにちは今今的z1こんaにちは今今的z1こんaにちは今今的z1こんaにちは今今的z1こんaにちは今今的z1こんaにちは今今的z1こんaにちは今今的z1こんaにちは今今的z1こんaにちは今今的z1こんaにちは今今的z1こんaにちは今今的z1こんaにちは今今的z1こんaにちは今今的z1こんaにちは今今的z1こんaにちは今今的z1こんaにちは今今的z1こんaにちは今今的z1こんaにちは今今的z1こんaにちは今今的z1こんaにちは今今的z1こんaにちは今今的z1こんaにちは今今的z1こんaにちは今今的z1こんaにちは今今的z1こんaにちは今今的z1こんaにちは今今的z1こんaにちは今今的z1こんaにちは今今的z1こんaにちは今今的z1こんaにちは今今的z',_X), atom_chars(_Y,_X),atom_length(_Y,L),writeln(utf_atom_length(L)),fail.
test_sub.

read_line_code(File,List):- 
	open(File,read,Str),
	read_line_code_1(Str,List),
	close(Str).

read_line_char(File,List):- 
	open(File,read,Str),
	read_line_char_1(Str,List),
	close(Str).

read_line_code_1(Str,List):- 
	get_code(Str,Char), %writeln(Char),
	(Char = 13-> 
	   List = []
	 ; List = [Char|Rest],
	   read_line_code_1(Str,Rest) ).
      
read_line_char_1(Str,List):- 
	get_char(Str,Char), % writeln(Char),
	(Char = z -> 
	   List = []  %writeln(finished)
	 ; List = [Char|Rest],
	   read_line_char_1(Str,Rest) ).
      
p('1').
p('こ').
p('ん').
p('a').
p('に').
p('ち').
p('は').
p('今').
p('今').
p('的').

chars_to_codes([],[]).
chars_to_codes([H|T],[H1|T1]):- 
	atom_codes(H,[H1]),
	chars_to_codes(T,T1). 
