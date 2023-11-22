:- compiler_options([xpp_on]).
#include "socket_defs_xsb.h"
#include "timer_defs_xsb.h"
#include "char_defs.h"

:- ['auxiliary/auxdefs'].
:- import tryN/5 from auxdefs.

:- import 
     socket/2, socket_connect/4, socket_set_option/3,
     socket_close/2, socket_recv/3, socket_send/3  from socket.


%% machine where server is running
machine(localhost).
%% Try something else:
%%machine(compserv1).

%% Port on which the server is listening
%% Server must bind to this port
xsb_port(6022).

client :-
	writeln('starting client...'),
	socket(Sockfd0, ErrCode),
	(ErrCode =\= SOCK_OK
	-> writeln('Cannot open write socket to the server.'), fail
	; true),
	socket_set_option(Sockfd0,linger,SOCK_NOLINGER),
	machine(IPAddrOrHostname),
	xsb_port(XSB_port),
	tryN(4,
	     socket_connect(Sockfd0 ,XSB_port, IPAddrOrHostname, Ecode2),
	     (writeln(sock_connect1(sockfd0,XSB_port,IPAddrOrHostname,Ecode2)),
		 writeln('connected to server...')),
	     (writeln('Cannot connect to server'), socket_close(Sockfd0,_)),
	     Ecode2
	    ),
	%% Socket for reading replies
	socket(Sockfd1, Error2),
	(Error2 =\= SOCK_OK
	-> writeln('Cannot open read socket to the server'),
	    socket_close(Sockfd0,_), fail
	; true),
	socket_set_option(Sockfd1,linger,SOCK_NOLINGER),
	tryN(4,
	     socket_connect(Sockfd1, XSB_port, IPAddrOrHostname, Ecode3),
	     writeln(socket_connect(sockfd1,XSB_port,IPAddrOrHostname,Ecode3)),
	     (writeln('Cannot connect to server'),
		 socket_close(Sockfd0,_), socket_close(Sockfd1,_)),
	     Ecode3
	    ),
	client_loop(Sockfd0, Sockfd1).
client :- writeln('Client error: exiting...').


client_loop(Sockfd0, Sockfd1) :-  
  nl, writeln('Please enter goal: g(X). or h(X).  Type e. to finish. Goal: '), 
  read_canonical(Goal),
  ((Goal == 'e' ; Goal == end_of_file) ->
      !,
      socket_close(Sockfd0, _ErrClose), socket_close(Sockfd1, _ErrClose1),
      nl, writeln('Exiting.'), true
  ;   
      nl,
      fmt_write_string(GoalStr, '%S.', arg(Goal)),
      socket_send(Sockfd0, GoalStr, _Er), 
      nl, writeln('Answers: '),
      repeat,
      socket_recv(Sockfd1, AnswerStr,_),
      open(atom(AnswerStr),read,IOport),
      read(IOport,Answer),
      close(IOport),
      (Answer==end_of_file 
      -> !, true
      ;  (   Answer == 'end' 
	 ->  client_loop(Sockfd0, Sockfd1)
	 ;   
	      write('    '),
	      write(Answer), nl, 
	      fail
	  )
      )
   ).
 
