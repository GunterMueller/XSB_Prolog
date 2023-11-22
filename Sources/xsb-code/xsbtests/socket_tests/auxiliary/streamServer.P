:- compiler_options([xpp_on]).
#include "socket_defs_xsb.h"
#include "timer_defs_xsb.h"
#include "char_defs.h"

:- ['auxiliary/auxdefs'].
%%:- ['auxiliary/auxdefs'].
:- import tryN/5 from auxdefs.

#define Q_LENGTH  10

:- import 
     socket/2, socket_bind/3, socket_listen/3, socket_accept/3, 
     socket_set_option/3, socket_close/2 from socket.

:- import fmt_write/3, fd2iostream/3, file_flush/2 from file_io.


%% Port on which the server is listening
xsb_port(6028).

server :-
	socket(Sockfd0, ErrCode),
	(ErrCode =\= SOCK_OK
	-> writeln('Cannot open socket'), fail
	; true),
	writeln(socket(sockfd0, ErrCode)),
	socket_set_option(Sockfd0,linger,SOCK_NOLINGER),
	xsb_port(XSBPort),
	tryN(4,
	     socket_bind(Sockfd0, XSBPort, ErrBind),
	     writeln(socket_bind(sockfd0, XSBPort, ErrBind)),
	     (writeln('Cannot bind...'), socket_close(Sockfd0,_)),
	     ErrBind
	    ),
	
	socket_listen(Sockfd0,Q_LENGTH, ErrListen),
	writeln(socket_listen(sockfd0,Q_LENGTH, ErrListen)),
	
	tryN(4,
	     (
	       %%set_timer(10),
	       socket_accept(Sockfd0, Sockfd0_out1, ErrorCode)),
	     (
	       writeln(socket_accept1(sockfd0, sockfd0_out1, ErrorCode)),
	       fd2iostream(Sockfd0_out1,'r',Sockptr0)
	     ),
	     (
	       writeln('Cannot accept connection1'),
	       socket_close(Sockfd0,_)),
	     ErrorCode),
	tryN(4,
	     (
	       %%set_timer(10),
	       socket_accept(Sockfd0, Sockfd0_out2, ErrorCode2)),
	     (
	       writeln(socket_accept2(sockfd0, sockfd0_out2, ErrorCode2)),
	       fd2iostream(Sockfd0_out2,'w',Sockptr1)
	     ),
	     (
	       writeln('Cannot accept connection2'),
	       socket_close(Sockfd0,_)
	     ),
	     ErrorCode2),
	server_loop(Sockptr0, Sockptr1, Sockfd0, Sockfd0_out1, Sockfd0_out2).



server_loop(Sockptr0, Sockptr1, Sockfd0,Sockfd0_out1,Sockfd0_out2) :-
    read_canonical(Sockptr0, Goal),
    Goal =.. [F|_Rest],
    (F=end_of_file -> 
	writeln('Client quits...'),
	socket_close(Sockfd0,_),
	socket_close(Sockfd0_out1,_),
	socket_close(Sockfd0_out2,_),
	close(Sockptr1), close(Sockptr0),
	true
    ;	((F=h; F=g) ->
	    call(Goal), 
	    write(Sockptr1, Goal),
	    write(Sockptr1, '. ')
	;   write('Invalid goal: '), writeln(Goal),
	    fmt_write(Sockptr1, '''+++Invalid goal: %S''', arg(Goal)),
	    write(Sockptr1, '. ')
	),
	file_flush(Sockptr1,_),
	fail
    ).

  
server_loop(Sockptr0, Sockptr1, Sockfd0, Sockfd0_out1, Sockfd0_out2) :-
  write_canonical(Sockptr1, end),
  write(Sockptr1, '. '),
  file_flush(Sockptr1,_),
  server_loop(Sockptr0,Sockptr1, Sockfd0, Sockfd0_out1, Sockfd0_out2).



g(1).
g(2).
g(3).
g(4).
g(5). 



h(a).
h(b).
h(c).
h(d).
h(e).
