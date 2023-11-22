
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
#ifdef MULTI_THREAD
   static th_context *th ;
#endif

#ifdef MULTI_THREAD
  th = malloc( sizeof( th_context ) ) ;  /* don't use mem_alloc */
#endif

  /* xsb_init relies on the calling program to pass the absolute or relative
     path name of the XSB installation directory. We assume that this directory
     is passed as argv[1].
     */
  myargv[0] = argv[1];
  myargv[1] = "-n";

  /* Initialize xsb */
  /* depend on user to put in right options (-n) */
  if ((rcode = xsb_init(CTXTc myargc,myargv)))
    printf("Did not initialize XSB the first time\n");  

  /* Initialize xsb */
  if ((rcode = xsb_init(CTXTc myargc,myargv)))
    printf("Did not initialize XSB the second time\n");  

  /* Close connection */
  xsb_close(CTXT);
  printf("cmain exit\n");
  return(0);
}

