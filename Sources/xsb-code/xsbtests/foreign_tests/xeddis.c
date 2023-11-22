#include <stdio.h>
#include <string.h>
#include "xsb_config.h"
#include "cinterf.h"
#include "context.h"

int WinMain(int argc, char *argv[]) {
  printf("Error: WinMain called\n");
  return 4;
}

static int mymin(int a, int b, int c)
{
  if (a < b) {
    if (a < c) return a; else return c;
  }
  else {
    if (b < c) return b; else return c;
  }
}

DllExport int call_conv min_ed_dis(CTXTdecl)
{
  int len1,len2, i, j;
  int ins,del,rep;
  int cost[200][200];
  char *string1, *string2;

  string1 = extern_ptoc_string(1);
  string2 = extern_ptoc_string(2);
  len1 = strlen(string1);
  len2 = strlen(string2);
  for (i = 0; i < 200; i++) cost[i][0]= i;
  for (i = 0; i < 200; i++) cost[0][i]= i;
  for (i=1; i<=len1; i++) {
    for (j=1; j<=len2; j++) {
      del = cost[i-1][j]+1;
      ins = cost[i][j-1]+1;
      if (string1[i-1] == string2[j-1]) 
	rep = cost[i-1][j-1];
      else rep = cost[i-1][j-1] + 1;
      cost[i][j] = mymin(del,ins,rep);
    }
  }   
  extern_ctop_int(3,cost[len1][len2]);
  return 1;
}
