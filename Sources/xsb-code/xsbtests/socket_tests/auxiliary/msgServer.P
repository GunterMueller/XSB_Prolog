:- compiler_options([xpp_on]).
#include "socket_defs_xsb.h"
#include "timer_defs_xsb.h"
#include "char_defs.h"

#define Q_LENGTH  10

:- ['auxiliary/auxdefs'].
:- import tryN/5 from auxdefs.


:- import 
     socket/2, socket_bind/3, socket_listen/3, socket_accept/3, 
     socket_set_option/3,
     socket_close/2, socket_recv/3, socket_send/3 from socket.

:- import fmt_write/3 from file_io.


%% Port on which the server is listening
xsb_port(6022).

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
	     (set_timer(10),
		 socket_accept(Sockfd0, Sockfd0_out1, ErrorCode)),
	     writeln(socket_accept1(sockfd0, sockfd0_out1, ErrorCode)),
	     (writeln('Cannot accept connection1'),
		 socket_close(Sockfd0,_)),
	     ErrorCode
	    ),
	tryN(4,
	     (set_timer(10),
		 socket_accept(Sockfd0, Sockfd0_out2, ErrorCode2)),
	     writeln(socket_accept(sockfd0, sockfd0_out2, ErrorCode2)),
	     (writeln('Cannot accept connection2'),
		 socket_close(Sockfd0,_)),
	     ErrorCode2
	    ),
	server_loop(Sockfd0_out1, Sockfd0_out2, Sockfd0).



server_loop(Sockfd0_out1, Sockfd0_out2, Sockfd0) :-
    writeln(serverloop1),
    socket_recv(Sockfd0_out1, GoalStr,_),
    open(atom(GoalStr),read,IOport),
    read(IOport,Goal),
    close(IOport),
    %% This tests the timer
    set_timer(2),
    socket_recv(Sockfd0_out1, _Tmsg, Etimeout),
    writeln(recv(sockfd0,tmsg,Etimeout)),
    (Etimeout < 0 -> fmt_write("Timeout or EOF: %d\n", Etimeout) ; true),
    Goal =.. [F|_Rest],
    (F=end_of_file -> 
	writeln('Client quits...'),
	socket_close(Sockfd0_out1,_),
	socket_close(Sockfd0_out2,_),
	socket_close(Sockfd0,_),
	true
    ;	((F=h; F=g) ->
	    call(Goal), 
	    fmt_write_string(OutGoalStr, "%S.\n", arg(Goal)),
	    socket_send(Sockfd0_out2, OutGoalStr, _)
	;   write('Invalid goal: '), writeln(Goal),
	    fmt_write_string(GoalStr1, '''+++Invalid goal: %S''.', arg(Goal)),
	    socket_send(Sockfd0_out2, GoalStr1,_)
	),
	fail
    ).

  
server_loop(Sockfd0_out1, Sockfd0_out2, Sockfd0) :-
  writeln(serverloop2),
  socket_send(Sockfd0_out2, 'end.', _),
  server_loop(Sockfd0_out1,Sockfd0_out2, Sockfd0).




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

