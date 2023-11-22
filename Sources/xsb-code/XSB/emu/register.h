/* File:      register.h
** Author(s): Warren, Swift, Xu, Sagonas
** Contact:   xsb-contact@cs.sunysb.edu
** 
** Copyright (C) The Research Foundation of SUNY, 1986, 1993-1998
** 
** XSB is free software; you can redistribute it and/or modify it under the
** terms of the GNU Library General Public License as published by the Free
** Software Foundation; either version 2 of the License, or (at your option)
** any later version.
** 
** XSB is distributed in the hope that it will be useful, but WITHOUT ANY
** WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
** FOR A PARTICULAR PURPOSE.  See the GNU Library General Public License for
** more details.
** 
** You should have received a copy of the GNU Library General Public License
** along with XSB; if not, write to the Free Software Foundation,
** Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
**
** $Id: register.h,v 1.20 2010-08-19 15:03:37 spyrosh Exp $
** 
*/

#ifndef __REGISTER_H__
#define __REGISTER_H__

#include "psc_xsb.h"
#include "varstring_xsb.h"

#ifndef MULTI_THREAD

/* Argument Registers
   ------------------ */
#define MAX_REGS    257

/*---- special registers -----------------------------------------------*/

#ifdef WINDOWS_IMP
__declspec(dllimport) Cell reg[MAX_REGS];
__declspec(dllimport) CPtr ereg;
__declspec(dllimport) CPtr breg;
__declspec(dllimport) CPtr hreg;
__declspec(dllimport) CPtr *trreg;
__declspec(dllimport) CPtr hbreg;
__declspec(dllimport) CPtr sreg;
__declspec(dllimport) byte *cpreg;
#else
DllExport extern Cell reg[MAX_REGS];
DllExport extern CPtr ereg;	/* last activation record       */
DllExport extern CPtr breg;	/* last choice point            */
DllExport extern CPtr hreg;	/* top of heap                  */
DllExport extern CPtr *trreg;	/* top of trail stack           */
DllExport extern CPtr hbreg;	/* heap back track point        */
DllExport extern CPtr sreg;	/* current build or unify field */
DllExport extern byte *cpreg;	/* return point register        */
#endif

extern byte *pcreg;	/* program counter              */

extern byte *biarg;

// #define CP_DEBUG 1

#ifdef CP_DEBUG
extern Psc pscreg;
#endif
/*---- registers added for the SLG-WAM ---------------------------------*/

#ifdef WINDOWS_IMP
__declspec(dllimport) CPtr efreg;
__declspec(dllimport) CPtr bfreg;
__declspec(dllimport) CPtr hfreg;
__declspec(dllimport) CPtr *trfreg;
__declspec(dllimport) CPtr delayreg;
#else
DllExport extern CPtr efreg;
DllExport extern CPtr bfreg;
DllExport extern CPtr hfreg;

DllExport extern CPtr *trfreg;
DllExport extern CPtr delayreg;
#endif


extern CPtr pdlreg;
extern CPtr openreg;

extern CPtr ptcpreg;	/* parent tabled CP (subgoal)	*/
extern CPtr interrupt_reg;

/*---- registers added for demand support ------------------------------*/
#ifdef DEMAND
/* demand-freeze registers */
extern CPtr edfreg;
extern CPtr bdfreg;
extern CPtr hdfreg;
extern CPtr *trdfreg;
#endif

/*---- global thread-specific char buffers for local builtins ----------*/
extern VarString *tsgLBuff1;
extern VarString *tsgLBuff2;
extern VarString *tsgSBuff1;
extern VarString *tsgSBuff2;

/*---- other stuff added for the SLG-WAM -------------------------------*/

extern int  xwammode;
extern int  level_num;
extern CPtr root_address;

/*---- for splitting stack mode ----------------------------------------*/

#ifdef WINDOWS_IMP
__declspec(dllimport) CPtr ebreg;	/* breg into environment stack */
#else
DllExport extern CPtr ebreg;	/* breg into environment stack */
#endif

#endif


#endif /* __REGISTER_H__ */
