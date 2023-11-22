:- encoding(latin_1).  % dsw??
?- set_prolog_flag(character_set,latin_1).

% TLS: in this file, I don't use puts as the character codes break
% sorts in some locales

test_sub:- test_code('utf8.txt'),fail.
test_sub:- test_char('utf8.txt'),fail.
test_sub:- test_peek_code('utf8.txt'),fail.
test_sub:- test_peek_char('utf8.txt'),fail.
test_sub:- test_code_for_atom('1こんaにちは今今的z'),fail.
test_sub:- test_char_for_atom('1こんaにちは今今的z'),fail.
%%%test_sub:- test_byte_for_atom('1こんaにちは今今的z'),fail.
test_sub:- test_peek_code_for_atom('1こんaにちは今今的z'),fail.
test_sub:- test_peek_char_for_atom('1こんaにちは今今的z'),fail.
test_sub.

test_code(File):- 
       open(File,read,Str),
       repeat,
       get_code(Str,Code),
       (Code = -1,close(Str) ; 
       writeln('test_code: '(Code)),fail),!.
%       put_byte(Code),nl,fail),!.

test_char(File):- 
       open(File,read,Str),
       repeat,
       get_char(Str,Char),
       (Char = end_of_file,close(Str) ; atom_codes(Char,[Code]),writeln('test_char: '(Code)),fail),!.
%       (Char = end_of_file,close(Str) ; write('put_char: '),put_char(Char), nl,fail),!.

test_peek_code(File):- 
       open(File,read,Str),
       repeat,
       peek_code(Str,PeekCode),
       get_code(Str,GetCode),
       (GetCode = -1,close(Str) ; write(peek_vs_get_code(PeekCode,GetCode)),nl,fail),!.

% test of 'z' to avoid problem with line break / carriage return.
test_peek_char(File):- 
       open(File,read,Str),
       repeat,
       peek_char(Str,PeekChar),
       get_char(Str,GetChar),
       (   GetChar = z,close(Str) 
         ; atom_codes(PeekChar,[PeekCode]),atom_codes(GetChar,[GetCode]),
	   write(peek_vs_get_char(PeekCode,GetCode)),nl,fail),
       !.

test_code_for_atom(Atom):- 
    open(atom(Atom),read,Str),
    repeat,
    get_code(Str,Char),
%    (Char = -1,close(Str) ; write('put_code_for_atom: '),put_code(Char), nl,fail),!.
    (Char = -1,close(Str) ; writeln('test_code_for_atom: '(Char)),fail),!.

test_char_for_atom(Atom):- 
    open(atom(Atom),read,Str),
    repeat,
    get_char(Str,Char),
    (Char = end_of_file,close(Str) ; atom_codes(Char,[Code]),writeln('test_code_for_atom: '(Code)),fail),!.

test_byte_for_atom(Atom):- 
    open(atom(Atom),read,Str),
    repeat,
    get_byte(Str,Char),
    (Char = -1,close(Str) ; write('put_byte_for_atom: '),put_byte(Char), nl,fail),!.

test_peek_code_for_atom(File):- 
       open(atom(File),read,Str),
       repeat,
       peek_code(Str,PeekCode),
       get_code(Str,GetCode),
       (GetCode = -1,close(Str) ; write(peek_vs_get_code_for_atom(PeekCode,GetCode)),nl,fail),!.

test_peek_char_for_atom(File):- 
       open(atom(File),read,Str),
       repeat,
       peek_char(Str,PeekChar),
       get_char(Str,GetChar),
       (   GetChar = end_of_file,close(Str) 
         ; atom_codes(PeekChar,[PeekCode]),atom_codes(GetChar,[GetCode]),writeln(peek_vs_get_char_for_atom(PeekCode,GetCode)),fail),!.


