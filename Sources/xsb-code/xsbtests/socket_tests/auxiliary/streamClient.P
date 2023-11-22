:- compiler_options([xpp_on]).
#include "socket_defs_xsb.h"
#include "timer_defs_xsb.h"
#include "char_defs.h"

:- ['auxiliary/auxdefs'].
%%:- ['auxiliary/auxdefs'].
:- import tryN/5 from auxdefs.

:- import 
     socket/2, socket_connect/4, socket_set_option/3,
     socket_close/2  from socket.
:- import fd2iostream/3, file_flush/2 from file_io.


%% machine where server is running
machine(localhost).
%% Try something else:
%%machine(compserv1).

%% Port on which the server is listening
%% Server must bind to this port
xsb_port(6028).

client :-
	writeln('started client...'),
	socket(Sockfd0, ErrCode),
	(ErrCode =\= SOCK_OK
	-> writeln('Cannot connect to the server.'), fail
	; true),
	socket_set_option(Sockfd0,linger,SOCK_NOLINGER),
	machine(IPAddrOrHostname),
	xsb_port(XSB_port),
	%%set_timer(10),
	tryN(4,
	     socket_connect(Sockfd0 ,XSB_port, IPAddrOrHostname, Ecode2),
	     (
	       fd2iostream(Sockfd0,'w',Sockptr0), 
	       writeln('connected to server...')
	     ),
	     (writeln('Cannot connect to server'), socket_close(Sockfd0,_)),
	     Ecode2
	    ),
	%% Socket for reading replies
	socket(Sockfd1, Error2),
	(Error2 =\= SOCK_OK
	-> writeln('Cannot read from the server'),
	    socket_close(Sockfd0,_), fail
	; true),
	socket_set_option(Sockfd1,linger,SOCK_NOLINGER),
	tryN(4,
	     socket_connect(Sockfd1, XSB_port, IPAddrOrHostname, Ecode3),
	     (
	       writeln(sock_connect2(sockfd1,XSB_port,IPAddrOrHostname,Ecode3)),
	       fd2iostream(Sockfd1,'r',Sockptr1)
	     ),
	     (
	       writeln('Cannot connect to server'),
	       socket_close(Sockfd0,_), socket_close(Sockfd1,_)
	     ),
	     Ecode3
	    ),
	client_loop(Sockptr0, Sockptr1, Sockfd0, Sockfd1).
client :- writeln('Client error: exiting...').
      


client_loop(Sockptr0, Sockptr1, Sockfd0, Sockfd1) :-  
  nl, writeln('Please enter goal: g(X). or h(X).  Type e. to finish. Goal: '), 
  read(0,Goal),
  ((Goal == 'e' ; Goal == end_of_file) ->
      !,
      socket_close(Sockfd0, _ErrClose), socket_close(Sockfd1, _ErrClose1),
      close(Sockptr1), close(Sockptr0),
      nl, writeln('Exiting.'), true
  ;   
      write_canonical(Sockptr0, Goal), 
      write(Sockptr0, '. '),
      file_flush(Sockptr0,_),
      nl, writeln('Answers: '),
      repeat,
      read(Sockptr1, Answer),
      (Answer==end_of_file ->  true
      ;
	  (   Answer == 'end' 
	  ->  client_loop(Sockptr0, Sockptr1, Sockfd0, Sockfd1)
	  ;   
	      write('    '),
	      write(Answer), nl, 
	      fail
	  )
      )
   ).
 
