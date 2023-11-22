
#include <stdio.h>

/* The following include is necessary to get the macros and routine
   headers */

#include "cinterf.h"
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
  myargv[1] = "-n";

  /* Initialize xsb */
  xsb_init(myargc,myargv);  /* depend on user to put in right options (-n) */

  /* Create command to consult a prolog file in argv[2] and send it. */
  c2p_functor("consult",1,reg_term(1));
  c2p_string(argv[2],p2p_arg(reg_term(1),1));
  if (xsb_command()) printf("Error consulting %s.P.\n", argv[2]);

  if (xsb_command_string("consult(basics).")) 
    printf("Error (string) consulting basics.\n");

  /* Create the query p(300,X,Y) and send it. */
  c2p_functor("p",3,reg_term(1));
  c2p_int(300,p2p_arg(reg_term(1),1));

  rcode = xsb_query();

  /* Print out answer and retrieve next one. */
  while (!rcode) {
    if (!(is_string(p2p_arg(reg_term(2),1)) & 
	  is_string(p2p_arg(reg_term(2),2))))
      printf("2nd and 3rd subfields must be atoms\n");
    else
      printf("Answer: %d, %s(%s), %s(%s)\n",
	     p2c_int(p2p_arg(reg_term(1),1)),
	     p2c_string(p2p_arg(reg_term(1),2)),
	     xsb_var_string(1),
	     p2c_string(p2p_arg(reg_term(1),3)),
	     xsb_var_string(2)
	     );
    rcode = xsb_next();
  }

  /* Create the string query p(300,X,Y) and send it, use higher-level
     routines. */

  xsb_make_vars(3);
  xsb_set_var_int(300,1);
  rcode = xsb_query_string("p(X,Y,Z).");

  /* Print out answer and retrieve next one. */
  while (!rcode) {
    if (!(is_string(p2p_arg(reg_term(2),2)) & 
	  is_string(p2p_arg(reg_term(2),3))))
       printf("2nd and 3rd subfields must be atoms\n");
    else
      printf("Answer: %d, %s, %s\n",
	     xsb_var_int(1),
	     xsb_var_string(2),
	     xsb_var_string(3)
	     );
    rcode = xsb_next();
  }



  /* Close connection */
  xsb_close();
  printf("cmain exit\n");
  return(0);
}
