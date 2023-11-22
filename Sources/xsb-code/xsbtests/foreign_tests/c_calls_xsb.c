
#include <stdio.h>
#include <stdlib.h>

/* The following include is necessary to get the macros and routine
   headers */

#include "cinterf.h"
#include "context.h"

extern char *xsb_executable_full_path(char *);
extern char *strip_names_from_path(char*, int);

int main(int argc, char *argv[])
{ 
  int rcode;
  int myargc = 2;
  char *myargv[2];

  /* xsb_init relies on the calling program to pass the absolute or relative
     path name of the XSB installation directory. We assume that this directory
     is passed as argv[1].
     */
  myargv[0] = argv[1];
  myargv[1] = "-n";  /* now unnecessary, but wont hurt */

  /* Initialize xsb */
  if (xsb_init(myargc,myargv)) {
    fprintf(stderr,"%s initializing XSB: %s\n",xsb_get_init_error_type(),
	    xsb_get_init_error_message());
    exit(XSB_ERROR);
  }

#ifdef MULTI_THREAD
  th_context *th = xsb_get_main_thread();
#endif

  /* Create command to consult a prolog file in argv[2] and send it. */
  c2p_functor(CTXTc "consult",1,reg_term(CTXTc 1));
  c2p_string(CTXTc argv[2],p2p_arg(reg_term(CTXTc 1),1));
  if (xsb_command(CTXT)) printf("Error consulting %s.P.\n", argv[2]);

  if (xsb_command_string(CTXTc "consult(basics).")) 
    printf("Error (string) consulting basics.\n");

  /* Create the query p(300,X,Y) and send it. */
  c2p_functor(CTXTc "p",3,reg_term(CTXTc 1));
  c2p_int(CTXTc 300,p2p_arg(reg_term(CTXTc 1),1));

  rcode = xsb_query(CTXT);

  /* Print out answer and retrieve next one. */
  while (!rcode) {
    if (!(is_string(p2p_arg(reg_term(CTXTc 2),1)) & 
	  is_string(p2p_arg(reg_term(CTXTc 2),2))))
      printf("2nd and 3rd subfields must be atoms\n");
    else
      printf("Answer: %d, %s(%s), %s(%s)\n",
	     p2c_int(p2p_arg(reg_term(CTXTc 1),1)),
	     p2c_string(p2p_arg(reg_term(CTXTc 1),2)),
	     xsb_var_string(1),
	     p2c_string(p2p_arg(reg_term(CTXTc 1),3)),
	     xsb_var_string(2)
	     );
    rcode = xsb_next(CTXT);
  }

  /* Create the string query p(300,X,Y) and send it, use higher-level
     routines. */

  xsb_make_vars(3);
  xsb_set_var_int(300,1);
  rcode = xsb_query_string(CTXTc "p(X,Y,Z).");

  /* Print out answer and retrieve next one. */
  while (!rcode) {
    if (!(is_string(p2p_arg(reg_term(CTXTc 2),2)) & 
	  is_string(p2p_arg(reg_term(CTXTc 2),3))))
       printf("2nd and 3rd subfields must be atoms\n");
    else
      printf("Answer: %d, %s, %s\n",
	     xsb_var_int(1),
	     xsb_var_string(2),
	     xsb_var_string(3)
	     );
    rcode = xsb_next(CTXT);
  }



  /* Close connection */
  xsb_close(CTXT);
  printf("cmain exit\n");
  return(0);
}
