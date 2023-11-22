#define PY_SSIZE_T_CLEAN

#ifdef WIN64
//this allows varstring_xsb to compile
#define WINDOWS_IMP
#endif

#include <stdio.h>
#include <stdlib.h>
#include <Python.h>
#include <cinterf.h>
#include "janus_defs.h"
#include "janus_connect_defs.h"
#include <error_xsb.h>
#include <cell_xsb.h>
#include <emuloop.h>
#include <register.h>
//#include <emudef.h>
#include <heap_xsb.h>
#include <memory_xsb.h>
#include <flags_xsb.h>
#include <xsb_config.h>

extern int convert_pyObj_prObj(PyObject *, prolog_term *);
extern int convert_prObj_pyObj(prolog_term , PyObject **);

void printPlgTerm(prolog_term term2);
void pPO(PyObject *obj1);

static int query_arity = 0;
static PyObject *px_init();
static PyObject *px_close();
static PyObject *px_cmd(PyObject *self,PyObject *args);
static PyObject *px_qdet(PyObject *self,PyObject *args);
static PyObject *px_comp(PyObject *self,PyObject *args,PyObject *kwargs);
static PyObject *px_first(PyObject *self,PyObject *args);
static PyObject *px_next(PyObject *self);
static PyObject *px_once(PyObject *self,PyObject *args);
//static PyObject *px_string_first(PyObject *self,PyObject *args,PyObject *kwargs);
static PyObject *px_string_first(PyObject *self,PyObject *args);
static PyObject *px_string_next(PyObject *self);
static PyObject *px_get_error_message();
static PyObject *px_close_query();


PyObject *printPyObj(PyObject *self,PyObject *obj1);

/* The reason for the following hack variable is as follows.  For XSB
   to be called from C, which is what this module is doing, XSB's
   stacks are initialized once.  To make a call, the call is built in
   XSB's stacks and registers and executed by invoking the emuloop()
   function.  At the end of execution of the goal XSB executes a halt
   instruction which causes emuloop() to exit.  All this should be
   fine because the needed variables and data structures are global,
   which allows the call to be setup and the return of the call to be
   accessed and used.  

   HOWEVER, on the Mac the delayreg, which is defined as a global
   variable is always set to 0 when the halt is executed and emuloop()
   exits.  This may sound strange, but I verified it at least with
   GCC.  The reason I need this, is to set the truth value for the
   return to Python.  For some reason, when I copy from delayreg to
   darwinDelayHack before exiting emuloop() the copied delayreg value
   remains and is not set to 0.

   I don't know why this happens.  It could be a bug with the
   compiler, or it could be that somehow we have some non-standard C
   around delayreg. (I didn't see anything unusual, but there is a lot
   of non-standard C in XSB.

   Fortunately, its just an extra variable and copy, so it will have
   no perceptible effect, but it's frustrating.  If anyone understands
   why this happens on the Mac, please let me (TES) know.
*/

extern CPtr darwinDelayregHack;

//-------------------------------------------------
// Initting
//-------------------------------------------------

static PyMethodDef XsbMethods[] = {
  //    {"printPyObj", printPyObj, METH_VARARGS, "Print Python Obj from C"},
    {"init", px_init, METH_VARARGS, "Init XSB"},
    {"close", px_close, METH_VARARGS, "Close XSB"},
    {"cmd", px_cmd, METH_VARARGS, "XSB command execution using data structures"},
    {"apply_once",px_qdet, METH_VARARGS, "Determiate XSB query execution using data structures"},
    {"comp", px_comp, METH_VARARGS | METH_KEYWORDS, "Set or list comprehehsion using XSB"},
    {"jns_query_once", px_once, METH_VARARGS, "Determinate XSB execution via query/cmd string."},
    {"get_error_message", px_get_error_message, METH_VARARGS, "Find the XSB error message"},
    {"jns_first", px_first, METH_VARARGS, "XSB query execution via structures and iterator"},
    {"jns_next", px_next, METH_VARARGS, "XSB query execution via structures and terator"},
    //    {"jns_string_first", px_string_first, METH_VARARGS | METH_KEYWORDS, "XSB execution via string and iterator"},
    {"jns_string_first", px_string_first, METH_VARARGS, "XSB execution via string and iterator"},
    {"jns_string_next", px_string_next, METH_VARARGS, "XSB execution via string and iterator"},
    {"close_query", px_close_query, METH_VARARGS, "Close Query"},
    {NULL, NULL, 0, NULL}        /* Sentinel */
};


static PyObject * mod_janus(void) {
  static PyObject *janus = NULL;

  if ( !janus )
  { PyObject *janus_name = NULL;

    if ( (janus_name=PyUnicode_FromString("janus")) )
      janus = PyImport_Import(janus_name);

    Py_CLEAR(janus_name);
  }

  return janus;
}

//const PyObject *jns_undef = PyObject_GetAttrString(mod_janus(), "undefined");
const PyObject *jns_undef = NULL;

  
PyObject *px_get_error_message() {
  return PyUnicode_FromString(xsb_get_error_message(CTXT));
}

static struct PyModuleDef moduledef = {					\
            PyModuleDef_HEAD_INIT, "xsbext", "xsbCextenstion", -1, XsbMethods, \
            NULL,NULL,NULL,NULL };


// To init the Python module
PyMODINIT_FUNC 
PyInit_xsbext(void)
{
    PyObject *module = PyModule_Create(&moduledef);
    if (module == NULL)
      return NULL;
    PyRun_SimpleString(
   "import sys\n"
   "sys.path.append('.')\n");
    return module;
}

// TES: need to get from env var
// To init xsb once the Python module has been initted
//static PyObject *pyxsb_init() {
//  char *mychar = "/home/tswift/xsb-repo/xsb-code/XSB";
//  PyObject* ret = PyLong_FromLong((long) xsb_init(1,&mychar)); 
//  return ret;
//}

  //  const char xsb_root[10]  = "XSB_ROOT";
  //  printf("envvar %s\n",getenv(xsb_root));
static PyObject *px_init() {
  char *argarray[1];
  argarray[0] = XSB_ROOTDIR_2QUOTED;
  PyObject* ret = PyLong_FromLong((long) xsb_init(1,argarray)); 
  return ret;
}

static PyObject *px_close() {
  xsb_close();
  return PyLong_FromLong(0);
		
}

PyObject *get_jns_undef() {
  if (jns_undef == NULL)
    jns_undef = PyObject_GetAttrString(mod_janus(), "undefined");
  Py_INCREF(jns_undef);
  return jns_undef;
}

PyObject *get_tv() {
if (darwinDelayregHack) {
  return get_jns_undef();
  //    return PyLong_FromLong(PYUNDEF);
 }
 else {
   Py_INCREF(Py_True);
   Py_RETURN_TRUE;
 }
}

void ensurePyXSBStackSpace(CTXTdeclc PyObject *pyObj) {
  PyObject * thirdArg;
  if (PyTuple_Check(pyObj) && PyTuple_Size(pyObj) > 2) {
    thirdArg = PyTuple_GetItem(pyObj,2);
    if (PyList_Check(thirdArg) || PySet_Check(thirdArg)) {
      //      printf("list size %ld\n",PyList_Size(thirdArg));
      check_glstack_overflow(5,pcreg,2*PyList_Size(thirdArg)*sizeof(Cell));
    }
    else if (PyDict_Check(thirdArg)) {
      //      printf("dict size %ld\n",PyDict_Size(thirdArg));
      check_glstack_overflow(5,pcreg,24*PyDict_Size(pyObj)*sizeof(Cell));
    }
    else if (PyTuple_Check(thirdArg)) {
      //      printf("tuple size %ld\n",PyTuple_Size(thirdArg));
      check_glstack_overflow(5,pcreg,4*PyTuple_Size(pyObj)*sizeof(Cell));
    }
  }
}

PyObject* newPyObj;
//extern CPtr heap_bot;

#define reset_local_heap_ptrs						\
  heap_offset = (CPtr)new_call-(CPtr)gl_bot;				\
  new_call = (prolog_term) ((CPtr)glstack.low + heap_offset) ;		\
  gl_bot = (CPtr)glstack.low;

/* TES: maybe complstack */

#define print_starting_registers			\
  printf("srting hreg %p\n",hreg);			\
  printf("srting hbreg %p\n",hbreg);			\
  printf("srting breg %p\n",breg);			\
  printf("srting ereg %p\n",ereg);			\
  printf("srting ebreg %p\n",ebreg);			\
  printf("srting trreg %p\n",trreg);			\
  printf("srting cpreg %p\n",cpreg);			

#define print_ending_registers			\
  printf("ending hreg %p\n",hreg);		\
  printf("ending hbreg %p\n",hbreg);		\
  printf("ending breg %p\n",breg);		\
  printf("ending ereg %p\n",ereg);		\
  printf("ending ebreg %p\n",ebreg);		\
  printf("ending trreg %p\n",trreg);			\
  printf("ending cpreg %p\n",cpreg);			

#define get_reg_offsets					\
  size_t hreg_offset = hreg - gl_bot;			\
  size_t hbreg_offset = hbreg - gl_bot;			\
  size_t ereg_offset = (CPtr)glstack.high - ereg;	\
  size_t ebreg_offset = (CPtr)glstack.high - ebreg;	\
  size_t trreg_offset = (CPtr) trreg - (CPtr)tcpstack.low;	\
  size_t breg_offset = (CPtr) tcpstack.high - breg;	\
  //  print_starting_registers;

#define reset_regs					\
  hreg = (CPtr)glstack.low + hreg_offset;		\
  hbreg = (CPtr)glstack.low +  hbreg_offset;		\
  ereg = (CPtr)glstack.high - ereg_offset;		\
  ebreg = (CPtr)glstack.high - ebreg_offset;		\
  trreg = (CPtr *)((CPtr)tcpstack.low + trreg_offset);	\
  breg = (CPtr)tcpstack.high - breg_offset;		\
  //     print_ending_registers;  

static PyObject *px_qdet(PyObject *self,PyObject *args) {
  size_t tuplesize = PyTuple_Size(args);
  size_t heap_offset;
  reset_ccall_error(CTXT);
  ensurePyXSBStackSpace(CTXTc args);
  prolog_term return_pr = p2p_new();
  convert_pyObj_prObj(args, &return_pr);
  CPtr gl_bot = (CPtr)glstack.low;
  get_reg_offsets;

  prolog_term new_call = p2p_new();
  c2p_functor_in_mod(p2c_string(p2p_arg(return_pr, 1)),p2c_string(p2p_arg(return_pr, 2)),
		     tuplesize-1,new_call);
  //  if (gl_bot != (CPtr)glstack.low) printf("2 heap bot old %p new %p\n",gl_bot, glstack.low);
  for (int i = 1; i < (int) tuplesize-1; i++) {
    prolog_term call_arg = p2p_arg(new_call,i); 
    p2p_unify(call_arg,p2p_arg(return_pr,i+2));
  }
  //  if (gl_bot != (CPtr)glstack.low) printf("3 heap bot old %p new %p\n",gl_bot, glstack.low);
  xsb_query_save(tuplesize-1);
  if (gl_bot != (CPtr)glstack.low) {
    //    printf("q4 heap bot old %p new %p\n",gl_bot, glstack.low);
    reset_local_heap_ptrs;
  }
  p2p_unify(reg_term(CTXTc 1),new_call);
  c2p_int(CTXTc 0,reg_term(CTXTc 3));  /* set command for calling a goal */
  xsb(CTXTc XSB_EXECUTE,0,0);
  if (ccall_error_thrown(CTXT))  {
    PyErr_SetString(PyExc_Exception,xsb_get_error_message(CTXT));
    return Py_None;
  }
  else {
    if (is_var(reg_term(CTXTc 1))) {
      PyObject *pydict = PyDict_New();
      Py_INCREF(Py_False);
      PyDict_SetItem(pydict,PyUnicode_FromString("truth"),Py_False);
      return pydict;
    }
    else {
      if (gl_bot != (CPtr)glstack.low) {
	//	printf("#6 heap bot old %p new %p\n",gl_bot, glstack.low);
	reset_local_heap_ptrs;
      }
      //      printPlgTerm(p2p_arg(new_call,tuplesize-1));
      //      printf("abt to convet\n");
      convert_prObj_pyObj(p2p_arg(new_call,tuplesize-1),&newPyObj);
      //      printf("conveted\n");
      //      printPyObj(self,newPyObj);
      PyObject *pydict = PyDict_New();
      PyDict_SetItem(pydict,PyUnicode_FromString("truth"),get_tv());
      PyDict_SetItem(pydict,PyUnicode_FromString("return"),newPyObj);
      reset_regs;
      return pydict;
    }
  }
}
//}

static PyObject *var_bindings_to_dict(prolog_term pBind) {
  prolog_term temp = pBind;
  PyObject *pydict, *pykey, *pyval;
  pydict = PyDict_New();
  while(!(is_nil(temp))) {
    //    printPlgTerm(p2p_car(temp));
    convert_prObj_pyObj(p2p_arg(p2p_car(temp),1),&pykey);
    convert_prObj_pyObj(p2p_arg(p2p_car(temp),2),&pyval);
    PyDict_SetItem(pydict,pykey,pyval);
    temp = p2p_cdr(temp);
  }
  return pydict;
}

//static PyObject *px_string_first(PyObject *self,PyObject *args,PyObject *kwargs) {
static PyObject *px_string_first(PyObject *self,PyObject *args) {
  size_t tuplesize = PyTuple_Size(args);
  size_t heap_offset;
  reset_ccall_error(CTXT);
  ensurePyXSBStackSpace(CTXTc args);
  prolog_term return_pr = p2p_new();
  //  printPyObj(self,args);
  convert_pyObj_prObj(args, &return_pr);
  prolog_term term_string = p2p_arg(return_pr,1);
  prolog_term bind_dict = p2p_arg(return_pr,2);
  int tv_type = p2c_int(p2p_arg(return_pr,3));
  CPtr gl_bot = (CPtr)glstack.low;
  get_reg_offsets;

  prolog_term new_call = p2p_new();
  c2p_functor_in_mod("janus_py","eval_atom",4,new_call);
  p2p_unify(p2p_arg(new_call,1),term_string);
  p2p_unify(p2p_arg(new_call,2),bind_dict);
  p2p_unify(p2p_arg(new_call,3),p2p_arg(return_pr,3));
  //  printPlgTerm(bind_dict);
  xsb_query_save(4);
  p2p_unify(reg_term(CTXTc 1),new_call);
  int rcode = xsb_query(CTXT);
  if (ccall_error_thrown(CTXT))  {
    PyErr_SetString(PyExc_Exception,xsb_get_error_message(CTXT));
    return Py_None;
  } else {
    if (is_var(reg_term(CTXTc 1))) {
	PyObject *pydict = PyDict_New();
	//	PyDict_SetItem(pydict,PyUnicode_FromString("truth"),PyLong_FromLong(PYFALSE));
	Py_INCREF(Py_False);
	PyDict_SetItem(pydict,PyUnicode_FromString("truth"),Py_False);
	return pydict;
    }
    else {
      if (gl_bot != (CPtr)glstack.low) {
	reset_local_heap_ptrs;
      }
      PyObject *bindDict = var_bindings_to_dict(p2p_arg(new_call,4));
      //      printPyObj(self,bindDict);
      if (tv_type == PLAIN_TRUTHVALS)
	PyDict_SetItem(bindDict,PyUnicode_FromString("truth"),get_tv());
      return bindDict;
    }
  }
}

  static PyObject *px_string_next(PyObject *self) {
  size_t heap_offset;
  int rcode;
  reset_ccall_error(CTXT);
  //  ensurePyXSBStackSpace(CTXTc args);
  //  prolog_term return_pr = p2p_new();
  CPtr gl_bot = (CPtr)glstack.low;
  get_reg_offsets;
  rcode = xsb_next(CTXT);
  //  printf("rcode %d\n",rcode);
  if (!rcode) {
    if (ccall_error_thrown(CTXT))  {
      PyErr_SetString(PyExc_Exception,xsb_get_error_message(CTXT));
      return Py_None;
    } else {
      if (is_var(reg_term(CTXTc 1))) {
	query_arity = 0;
	PyObject *pydict = PyDict_New();
	Py_INCREF(Py_False);
	PyDict_SetItem(pydict,PyUnicode_FromString("truth"),Py_False);
	//	PyDict_SetItem(pydict,PyUnicode_FromString("truth"),PyLong_FromLong(PYFALSE));
	reset_regs;
	return pydict;
      }
      else {
	PyObject *bindDict = var_bindings_to_dict(p2p_arg(reg_term(1),4));
	if (p2c_int(p2p_arg(reg_term(1),3)) == PLAIN_TRUTHVALS)
	  PyDict_SetItem(bindDict,PyUnicode_FromString("truth"),get_tv());
	//	if (tv_type == PLAIN_TRUTHVALS)
	//      if (gl_bot != (CPtr)glstack.low) {
	//	reset_local_heap_ptrs;
	return bindDict;
      }
    }
  }
  else
    Py_INCREF(Py_None);
    return Py_None;
}

static PyObject *px_once(PyObject *self,PyObject *args) {
  // args is a python string + keywords
  size_t heap_offset;
  reset_ccall_error(CTXT);
  ensurePyXSBStackSpace(CTXTc args);
  prolog_term return_pr = p2p_new();
  //  printPyObj(self,args);
  convert_pyObj_prObj(args, &return_pr);
  prolog_term term_string = p2p_arg(return_pr,1);
  prolog_term bind_dict = p2p_arg(return_pr,2);
  int tv_type = p2c_int(p2p_arg(return_pr,3));
  CPtr gl_bot = (CPtr)glstack.low;
  get_reg_offsets;
  prolog_term new_call = p2p_new();
  c2p_functor_in_mod("janus_py","eval_atom",4,new_call);
  p2p_unify(p2p_arg(new_call,1),term_string);
  p2p_unify(p2p_arg(new_call,2),bind_dict);
  p2p_unify(p2p_arg(new_call,3),p2p_arg(return_pr,3));
  //  p2p_unify(p2p_arg(new_call,3),tv_type);
  xsb_query_save(4);
  p2p_unify(reg_term(CTXTc 1),new_call);
  int rcode = xsb_query(CTXT);
  if (ccall_error_thrown(CTXT))  {
    PyErr_SetString(PyExc_Exception,xsb_get_error_message(CTXT));
    return Py_None;
  } else {
    if (is_var(reg_term(CTXTc 1))) {
      PyObject *pydict = PyDict_New();
      if (tv_type == NO_TRUTHVALS)
	return Py_None;
      else {
	Py_INCREF(Py_False);
	PyDict_SetItem(pydict,PyUnicode_FromString("truth"),Py_False);
	//	PyDict_SetItem(pydict,PyUnicode_FromString("truth"),PyLong_FromLong(PYFALSE));
      }
      return pydict;
    }
    else {
      if (gl_bot != (CPtr)glstack.low) {
	reset_local_heap_ptrs;
      }
      PyObject *bindDict = var_bindings_to_dict(p2p_arg(new_call,4));
      //      printPyObj(self,bindDict);
      if (tv_type == PLAIN_TRUTHVALS)
	PyDict_SetItem(bindDict,PyUnicode_FromString("truth"),get_tv());
      xsb_close_query();
      return bindDict;
    }
  }
}

static PyObject *px_first(PyObject *self,PyObject *args) {
  size_t tuplesize = PyTuple_Size(args);
  size_t heap_offset;
  int rcode;
  reset_ccall_error(CTXT);
  ensurePyXSBStackSpace(CTXTc args);
  prolog_term return_pr = p2p_new();
  convert_pyObj_prObj(args, &return_pr);
  CPtr gl_bot = (CPtr)glstack.low;
  get_reg_offsets;

  prolog_term new_call = p2p_new();
  c2p_functor_in_mod(p2c_string(p2p_arg(return_pr, 1)),p2c_string(p2p_arg(return_pr, 2)),
		     tuplesize-1,new_call);
  //  if (gl_bot != (CPtr)glstack.low) printf("2 heap bot old %p new %p\n",gl_bot, glstack.low);
  for (int i = 1; i < (int) tuplesize-1; i++) {
    prolog_term call_arg = p2p_arg(new_call,i); 
    p2p_unify(call_arg,p2p_arg(return_pr,i+2));
  }
  //  if (gl_bot != (CPtr)glstack.low) printf("3 heap bot old %p new %p\n",gl_bot, glstack.low);

  //  xsb_query_save(tuplesize-1);
if (gl_bot != (CPtr)glstack.low) {
  //    printf("q4 heap bot old %p new %p\n",gl_bot, glstack.low);
    reset_local_heap_ptrs;
  }
 xsb_query_save(tuplesize-1);
 // printf("rt 1-1 %p %p\n",reg_term(1),&new_call);
 p2p_unify(reg_term(CTXTc 1),new_call);
 rcode = xsb_query(CTXT);
 //  printf("rcode %d\n",rcode);
  //  c2p_int(CTXTc 0,reg_term(CTXTc 3));  /* set command for calling a goal */
  //  xsb(CTXTc XSB_EXECUTE,0,0);
  if (ccall_error_thrown(CTXT))  {
    PyErr_SetString(PyExc_Exception,xsb_get_error_message(CTXT));
    return Py_None;
  } else {
    if (is_var(reg_term(CTXTc 1))) {
      PyObject *pydict = PyDict_New();
	Py_INCREF(Py_False);
	PyDict_SetItem(pydict,PyUnicode_FromString("truth"),Py_False);
	//      PyDict_SetItem(pydict,PyUnicode_FromString("truth"),PyLong_FromLong(PYFALSE));
      return pydict;
    }
    else {
      query_arity = tuplesize-1;
      if (gl_bot != (CPtr)glstack.low) {
	reset_local_heap_ptrs;
      }
      convert_prObj_pyObj(p2p_arg(new_call,tuplesize-1),&newPyObj);
      PyObject *pydict = PyDict_New();
      PyDict_SetItem(pydict,PyUnicode_FromString("truth"),get_tv());
      PyDict_SetItem(pydict,PyUnicode_FromString("return"),newPyObj);
      //      reset_regs;
      return pydict;
    }
  }
}

static PyObject *px_next(PyObject *self) {
  size_t heap_offset;
  int rcode;
  reset_ccall_error(CTXT);
  //  ensurePyXSBStackSpace(CTXTc args);
  //  prolog_term return_pr = p2p_new();
  CPtr gl_bot = (CPtr)glstack.low;
  get_reg_offsets;
  //  prolog_term new_call = p2p_new();
  //  p2p_unify(reg_term(CTXTc 1),new_call);

  rcode = xsb_next(CTXT);
  if (!rcode) {
    if (ccall_error_thrown(CTXT))  {
      PyErr_SetString(PyExc_Exception,xsb_get_error_message(CTXT));
      return Py_None;
    } else {
      if (is_var(reg_term(CTXTc 1))) {
	PyObject *pydict = PyDict_New();
	Py_INCREF(Py_False);
	PyDict_SetItem(pydict,PyUnicode_FromString("truth"),Py_False);
	//	PyDict_SetItem(pydict,PyUnicode_FromString("truth"),PyLong_FromLong(PYFALSE));
	reset_regs;
	return pydict;
      }
      else {
	//      if (gl_bot != (CPtr)glstack.low) {
	//	reset_local_heap_ptrs;
	convert_prObj_pyObj(p2p_arg(reg_term(1),query_arity),&newPyObj);
	PyObject *pyDict = PyDict_New();
	PyDict_SetItem(pyDict,PyUnicode_FromString("truth"),get_tv());
	PyDict_SetItem(pyDict,PyUnicode_FromString("return"),newPyObj);
	return pyDict;
      }
    }
  }
  else
    return Py_None;
}

static PyObject *px_comp(PyObject *self,PyObject *args,PyObject *kwargs) {
  //static PyObject *px_comp(PyObject *self,PyObject *args) {
  int varnum = 1;
  int flag_arg = PLAIN_TRUTHVALS;
  PyObject *dictval = NULL;
  if (kwargs) {
    dictval = PyDict_GetItem(kwargs,PyUnicode_FromString("vars"));
    if (dictval) varnum = PyLong_AsSsize_t(dictval);
    dictval = NULL;
    //    dictval = PyDict_GetItem(kwargs,PyUnicode_FromString("truth_vals"));
    dictval = PyDict_GetItem(kwargs,PyUnicode_FromString("truth"));
    if (dictval) {
      if (PyLong_AsSsize_t(dictval) == NO_TRUTHVALS) flag_arg = NO_TRUTHVALS;
      else if (PyLong_AsSsize_t(dictval) == DELAY_LISTS) flag_arg = DELAY_LISTS;
    }
    dictval = PyDict_GetItem(kwargs,PyUnicode_FromString("set_collect"));
    if (dictval == Py_True) flag_arg = flag_arg | SET_COLLECTION;
  }
  //  printf("varnum %d collect_set %x flag_arg %d\n",
  //  	 varnum,(flag_arg&SET_COLLECTION),(flag_arg));
  size_t tuplesize = PyTuple_Size(args) + (varnum-2);   // tupsz is varnum + input args
  size_t inputsize = tuplesize-varnum;
  flag_arg = flag_arg | (inputsize << 16);
  size_t heap_offset;
  reset_ccall_error(CTXT);
  ensurePyXSBStackSpace(CTXTc args);
  prolog_term return_pr = p2p_new();
  convert_pyObj_prObj(args, &return_pr);
  CPtr gl_bot = (CPtr)glstack.low;
  get_reg_offsets;
  prolog_term new_call = p2p_new();
  c2p_functor_in_mod("janus_py","jns_comp",3,new_call);

  prolog_term inner_term = p2p_arg(new_call, 1);
  c2p_int(flag_arg,p2p_arg(new_call, 3));
  c2p_functor_in_mod(p2c_string(p2p_arg(return_pr, 1)),p2c_string(p2p_arg(return_pr, 2)),tuplesize,inner_term);
  //  printPlgTerm(new_call);
  //  if (gl_bot != (CPtr)glstack.low) printf("2 heap bot old %p new %p\n",gl_bot, glstack.low);
  for (int i = 1; i <= (int) inputsize; i++) {
    prolog_term call_arg = p2p_arg(inner_term,i); 
    p2p_unify(call_arg,p2p_arg(return_pr,i+2));
  }
  //  printPlgTerm(new_call);
  //  if (gl_bot != (CPtr)glstack.low) printf("3 heap bot old %p new %p\n",gl_bot, glstack.low);
  xsb_query_save(tuplesize);
  if (gl_bot != (CPtr)glstack.low) {
    //    printf("q4 heap bot old %p new %p\n",gl_bot, glstack.low);
    reset_local_heap_ptrs;
  }
  p2p_unify(reg_term(CTXTc 1),new_call);
  //  if (gl_bot != (CPtr)glstack.low) printf("5 heap bot old %p new %p\n",gl_bot, glstack.low);
  c2p_int(CTXTc 0,reg_term(CTXTc 3));  /* set command for calling a goal */
  xsb(CTXTc XSB_EXECUTE,0,0);
  if (ccall_error_thrown(CTXT))  {
    PyErr_SetString(PyExc_Exception,xsb_get_error_message(CTXT));
    return Py_None;
  } else {
    if (is_var(reg_term(CTXTc 1))) {
      //      return PyLong_FromLong(PYFALSE);
      Py_INCREF(Py_False);
      Py_RETURN_FALSE;
    }
    else {
      if (gl_bot != (CPtr)glstack.low) {
	reset_local_heap_ptrs;
      }
      //      printPlgTerm(new_call);
      convert_prObj_pyObj(p2p_arg(new_call,2),&newPyObj);
      //      pPO(newPyObj);
      reset_regs;
      return newPyObj;
    }
  }
}

static PyObject *px_cmd(PyObject *self,PyObject *args) {
  size_t arity;
  size_t tuplesize = PyTuple_Size(args);
  size_t heap_offset;
  arity = tuplesize-2;
  reset_ccall_error(CTXT);
  //  printf("gc margin %ld\n",flags[HEAP_GC_MARGIN]);
  //  ensurePyXSBStackSpace(CTXTc args);
  CPtr gl_bot = (CPtr)glstack.low;
  get_reg_offsets;
  prolog_term return_pr = p2p_new();
  convert_pyObj_prObj(args, &return_pr);
  //  printf("new prolog obj: ");printPlgTerm(return_pr);
  prolog_term new_call = p2p_new();
  c2p_functor_in_mod(p2c_string(p2p_arg(return_pr, 1)),p2c_string(p2p_arg(return_pr, 2)),
		     arity,new_call);
  for (int i = 1; i <= (int) arity; i++) {
    //    printPlgTerm(p2p_arg(return_pr,3));
    prolog_term call_arg = p2p_arg(new_call,i); 
    p2p_unify(call_arg,p2p_arg(return_pr,i+2));
  }
  //  printf("done with first unify\n");
  if (arity==0) xsb_query_save(1);
  else  xsb_query_save(arity);
  if (gl_bot != (CPtr)glstack.low) {
    //    printf("4 heap bot old %p new %p\n",gl_bot, glstack.low);
    reset_local_heap_ptrs;
  }
  //  printf("done with query_save\n");
  p2p_unify(reg_term(CTXTc 1),new_call);
  //  printf("about to call: ");printPlgTerm(reg_term(1));
  c2p_int(CTXTc 0,reg_term(CTXTc 3));  /* set command for calling a goal */
  //  printf("delayreg0 %p\n",delayreg);
  xsb(CTXTc XSB_EXECUTE,0,0);
  //printf("xsbext: delayreg %p %p\n",delayreg,darwinDelayregHack);
  //  printf("before conv: "); printPlgTerm(new_call);
  if (ccall_error_thrown(CTXT)) {
    PyErr_SetString(PyExc_Exception,xsb_get_error_message(CTXT));
    //    printf("Error: %s\n",xsb_get_error_message(CTXT));
    return Py_None;
    } else {
    PyObject *tv;
    if (is_var(reg_term(CTXTc 1))) {  
      //      tv = PyLong_FromLong(PYFALSE);
      Py_INCREF(Py_False);
      Py_RETURN_FALSE;
    } else {
      tv = get_tv();
    }
    reset_regs;
    return tv;
  }
}

PyObject *px_close_query() {
  int rcode = xsb_close_query();
  if (rcode == XSB_ERROR) {
    PyErr_SetString(PyExc_Exception,xsb_get_error_message(CTXT));
    return Py_None;
  }
  else return Py_None;
}


//-------------------------------------------------
// Common routines to be factored out.
//-------------------------------------------------

PyObject *printPyObj(PyObject *self, PyObject *obj1) {
	PyObject* objectsRepresentation = PyObject_Repr(obj1);
	const char* s = PyUnicode_AsUTF8(objectsRepresentation);
	printf("printPyObj: %s\n",s);
	return obj1;
}

void pPO(PyObject *obj1) {
	PyObject* objectsRepresentation = PyObject_Repr(obj1);
	const char* s = PyUnicode_AsUTF8(objectsRepresentation);
	printf("printPyObj: %s\n",s);
}

void printPlgTerm( prolog_term term) {
  XSB_StrDefine(StrArgBuf);
  XSB_StrSet(&StrArgBuf,"");
  print_pterm(CTXTc term,1, &StrArgBuf);
  printf("printPlgTerm: %s\n", StrArgBuf.string);
}

//  (is_var(reg_term(CTXTc 1))?PyLong_FromLong(PYFALSE):		 
//   (darwinDelayregHack?PyLong_FromLong(PYUNDEF):		 
//    PyLong_FromLong(PYTRUE)))
//#else
//#define get_tv()							
//  (is_var(reg_term(CTXTc 1))?PyLong_FromLong(PYFALSE):			

//#if defined(DARWIN) 
//#define get_tv()				\
//  (delayreg?PyLong_FromLong(PYUNDEF):PyLong_FromLong(PYTRUE))
//#else
//#define get_tv()				\
//   (delayreg?PyLong_FromLong(PYUNDEF):PyLong_FromLong(PYTRUE))
//#endif

/* For returning booleans */

//#define PYFALSE 0
//#define PYTRUE  1
//#define PYUNDEF 2

