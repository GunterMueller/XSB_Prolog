/* File:  janusm.c */

#define PY_SSIZE_T_CLEAN

#ifdef WIN64
//this allows varstring_xsb to compile
#define WINDOWS_IMP
#include "windows.h"
#endif

#include <Python.h>
#include <frameobject.h>
#include <traceback.h>

#ifndef WIN64
#include "janus_connect_defs.h"
#endif

#include "auxlry.h"
#include "cinterf_defs.h"
#include <basictypes.h>
#include <register.h>
//#include <emudef.h>
#include <flags_xsb.h>
#include <heap_xsb.h>
#include <memory_xsb.h>
#include <error_xsb.h>
#include "janus_defs.h"
#ifndef WIN64
#include <dlfcn.h>
#endif
#include "deref.h"
#include "debug_xsb.h"

#include "xsb_config.h"
#ifdef WIN_NT
// #define XSB_DLL // already defined?
//this allows varstring_xsb to compile
#define WINDOWS_IMP
#endif

#include <cinterf.h>
#include <context.h>
#include <inttypes.h>
#include <stdio.h>
#include <stdarg.h>

#ifndef WIN_NT
#include <stdlib.h>
#endif

int convert_pyObj_prObj(CTXTdeclc PyObject *, prolog_term *, int);
int convert_only_base_noniter(CTXTdeclc PyObject *, prolog_term *);
int convert_prObj_pyObj(CTXTdeclc prolog_term , PyObject **);
void printPlgTerm(prolog_term term2);
void printPyObj(PyObject *obj1);
void sprintPyObj(char **s, PyObject *obj1);
void printPyObjType(CTXTdeclc PyObject *obj1);

#define JANUS_MAX_BUFFER 500

/* TES: these sizes are from sys.getsizeof() on 64-bit Lunux*/
#define UTF8_SIZE         4     // usually an overestimate, but safe.
#define PYLONG_SIZE      24
#define PYFLOAT_SIZE     24
#define PYDICT_OVERHEAD 232
#define PYSET_OVERHEAD  232
#define PYLIST_OVERHEAD  56
#define PYTUP_OVERHEAD   40

int find_length_prolog_list(prolog_term V)
{
	prolog_term temp = V;
	int count= 0;
	while(!(is_nil(temp)))
	{
		p2p_car(temp);
		count++;
		temp = p2p_cdr(temp);
	}
	return count;
}

extern PyObject *PyObject_CallMethodNoArgs(PyObject *obj, PyObject *name);

// TES: tries to make a reasonable but safe approximation of the size of a Python term
// Counts 4 bytes for each character just to be sure.
Integer get_safe_python_size(PyObject *pyObj) {
  Integer size = 0;
  size_t i = 0;
  if(PyLong_Check(pyObj)) {
    return PYLONG_SIZE; 
  } else if (PyFloat_Check(pyObj)) {
    return PYFLOAT_SIZE;
  } else if (PyUnicode_Check(pyObj)) {
    return UTF8_SIZE*PyUnicode_GET_LENGTH(pyObj); 
  } else if (PyList_Check(pyObj)) {
    size_t listlength = PyList_GET_SIZE(pyObj); //change tes
    size = size + PYLIST_OVERHEAD;
    
    for(i = 0; i < listlength; i++) {
      size = size + get_safe_python_size(PyList_GetItem(pyObj, i));
    }
  } else if (PyTuple_Check(pyObj)) {
    size_t tuplesize = PyTuple_Size(pyObj);
    size = size + PYTUP_OVERHEAD;
    for (i = 0; i < tuplesize; i++) {
      size = size + get_safe_python_size(PyTuple_GetItem(pyObj, i));
      
    }
  } else if(PyDict_Check(pyObj)) {
    PyObject *key, *value;
    Py_ssize_t pos = 0;
    size = size + PYDICT_OVERHEAD;
    while (PyDict_Next(pyObj, &pos, &key, &value)) {
      size = size + PYTUP_OVERHEAD;     // TES: not sure of this 
      size = size + get_safe_python_size(key);   //printf("key %ld\n",size);
      size = size + get_safe_python_size(value);// printf("value %ld\n",size);
    }
    //    Py_DECREF(key); Py_DECREF(value);  pydict_next borrows
  } else if(PySet_Check(pyObj)) {           // maybe PyAnySet_Check
    PyObject *iterator = PyObject_GetIter(pyObj);
    PyObject *pyObjInner;
    size = size + PYDICT_OVERHEAD;
    while ((pyObjInner = PyIter_Next(iterator))) {
      size = size + get_safe_python_size(pyObjInner);      
      Py_DECREF(pyObjInner);
    }
    Py_DECREF(iterator);  
  }
  return size;
}

// On ubuntu sizeof(size_t) is 8.
// check_glstack overflow expands by Overflow margin + input
void ensureXSBStackSpace(CTXTdeclc PyObject *pyObj,int flag) {
  if (flag & SIZECHECK) {
    Integer size = get_safe_python_size(pyObj);
    check_glstack_overflow(5,pcreg,2*size*sizeof(size_t));
  }
  else if (PyList_Check(pyObj) || PySet_Check(pyObj)) {
    check_glstack_overflow(5,pcreg,8*PyList_Size(pyObj)*sizeof(size_t));
  }
  else if (PyDict_Check(pyObj)) {
    check_glstack_overflow(5,pcreg,24*PyDict_Size(pyObj)*sizeof(size_t));
  }
  else if (PyTuple_Check(pyObj)) {
    check_glstack_overflow(5,pcreg,4*PyTuple_Size(pyObj)*sizeof(size_t));
  }
}

// -------------------- Prolog to Python

int prlist2pyList(CTXTdeclc prolog_term V, PyObject *pList, int count)
{
	prolog_term temp = V;
	prolog_term head;
	int i;
	for(i = 0; i <count;i++)
	{ 
		head = p2p_car(temp);
		PyObject *pyObj = NULL;
		if( !convert_prObj_pyObj(CTXTc head, &pyObj))
			return FALSE;
		PyList_SetItem(pList, i, pyObj);
		temp = p2p_cdr(temp);
	}	
	return TRUE;
}

// Assumes error checking is done on Prolog side
void free_python_object_int(CTXTdeclc prolog_term prTerm) {
  PyObject *pyObj;
  convert_prObj_pyObj(CTXTc prTerm, &pyObj);
  Py_CLEAR(pyObj);
}

int convert_prObj_pyObj(CTXTdeclc prolog_term prTerm, PyObject **pyObj) {
  //  printPlgTerm(prTerm);
  if(is_int(CTXTc prTerm)) {
    prolog_term argument = prTerm;
    prolog_int argument_int = p2c_int(argument);
    *pyObj = PyLong_FromSsize_t(argument_int);
    return TRUE;
  }
  else if(is_string(CTXTc prTerm)) {
    prolog_term argument = prTerm;
    char *argument_char = p2c_string(argument);
    *pyObj = PyUnicode_FromString(argument_char);
    return TRUE;
  }
  else if(is_float(prTerm)) {
    prolog_term argument = prTerm;
    prolog_float argument_float = p2c_float(argument);
    *pyObj = PyFloat_FromDouble(argument_float);
    return TRUE;
  }
  else if (islist(prTerm) || isnil(prTerm) ) {
    prolog_term argument = prTerm;
    int count = find_length_prolog_list(argument);
    PyObject *pList = PyList_New(count);
    if(!prlist2pyList(CTXTc argument, pList, count))
      return FALSE;
    *pyObj = pList;
    return TRUE;
  }
  else if (is_functor(CTXTc prTerm)) {
    if(strcmp(p2c_functor(prTerm),PYTUP_C) == 0 || strcmp(p2c_functor(prTerm),":") == 0 ) {
      PyObject *tup, *arg;
      prolog_term temp;
      int arity = p2c_arity(prTerm);
      tup = PyTuple_New(arity);
      for (int i = 1; i <= arity; i++) {
	temp = p2p_arg(prTerm, i);
	convert_prObj_pyObj(CTXTc temp, &arg) ;
	PyTuple_SET_ITEM(tup,(i-1),arg);
      }
      *pyObj = tup;
      return TRUE;
    }
    else if (strcmp(p2c_functor(prTerm),PYSET_C) == 0 ) {
      PyObject *pyset, *pyelt;
      prolog_term list, elt;
      list = p2p_arg(prTerm, 1);
      pyset = PySet_New(NULL);
      if (!is_list(list)) {
	xsb_type_error_vargs(CTXTc "list",list,"(predicate not known)",
			     "In Prolog to Python translation of py_set/1\n");
      }
      while (is_list(list)) {   
	elt = p2p_car(list);
	convert_prObj_pyObj(CTXTc elt, &pyelt);
	if (!PySet_Add(pyset,pyelt)) 
	  list = p2p_cdr(list);
	else 
	  xsb_type_error_vargs(CTXTc "hashable term",elt,"(Predicate not known))",
			       "In Prolog to Python translation of py_set/1\n");
      }
      *pyObj = pyset;
      return TRUE;
    }
    else if (strcmp(p2c_functor(prTerm),PYDICT_C) == 0 ) {
      PyObject *pydict, *pykey, *pyval;
      prolog_term elt, comma_list;
      comma_list = p2p_arg(prTerm, 1);
      //      printPlgTerm(comma_list);
      pydict = PyDict_New();
      while (isconstr(comma_list) && strcmp(p2c_functor(comma_list),",") == 0 ) {
	elt = p2p_arg(comma_list,1);
	if (!isconstr(elt)) {
	  xsb_type_error_vargs(CTXTc "dictionary pair",elt,"(predicate not known)",
			       "In Prolog to Python translation of dictionary/1\n");
	}
	convert_prObj_pyObj(p2p_arg(elt,1),&pykey);
	convert_prObj_pyObj(p2p_arg(elt,2),&pyval);
	if (!PyDict_SetItem(pydict,pykey,pyval)) 
	  comma_list = p2p_arg(comma_list,2);
	else
	  xsb_type_error_vargs(CTXTc "hashable term",elt,"(Predicate not known))",
			       "In Prolog to Python translation of py_set/1\n");
	  
      }
      if (!isconstr(comma_list)) {
	xsb_type_error_vargs(CTXTc "dictionary pair",comma_list,"(predicate not known)",
			     "In Prolog to Python translation of dictionary/1\n");
	}
      convert_prObj_pyObj(p2p_arg(comma_list,1),&pykey);
      convert_prObj_pyObj(p2p_arg(comma_list,2),&pyval);
      if (!PyDict_SetItem(pydict,pykey,pyval)) {
	*pyObj = pydict;
	return TRUE;
      }
      else 
	xsb_type_error_vargs(CTXTc "hashable term",p2p_arg(comma_list,1),"(Predicate not known))",
			     "In Prolog to Python translation of py_set/1\n");
    }
    else if (strcmp(p2c_functor(prTerm),"@") == 0 ) {
      prolog_term arg = p2p_arg(prTerm,1);
      if (strcmp(p2c_string(arg),PYNONE_C) == 0) {
	*pyObj = Py_None;
	return TRUE;
      }
      else if (strcmp(p2c_string(arg),"true") == 0) {
	*pyObj = Py_True;
	return TRUE;
      }
      else if (strcmp(p2c_string(arg),"false") == 0) {
	*pyObj = Py_False;
	return TRUE;
      }
      else
	return FALSE;
    }
    else if (strcmp(p2c_functor(prTerm),PYOBJ_C) == 0 ) {
      prolog_term ref = p2p_arg(prTerm, 1);
      char *node_pointer = p2c_string(ref); 
      PyObject *pyobj_ref = (PyObject *)strtoll(node_pointer+1,NULL, 16);
      *pyObj = pyobj_ref;
      Py_INCREF(pyobj_ref);
      return TRUE;
    }
    return FALSE;
  }
  return FALSE;
}

// -------------------- Python to Prolog
// TES: need to add decrefs

int convert_pyObj_prObj_switch(CTXTdeclc PyObject *pyObj, prolog_term *prTerm, int flag) {
  if (!(flag&RETURN_PYOBJ))
    return convert_pyObj_prObj(CTXTc pyObj, prTerm, flag);
  else
    return convert_only_base_noniter(CTXTc pyObj, prTerm);
}
      
int convert_only_base_noniter(CTXTc PyObject *pyObj, prolog_term *prTerm) {
  if(PyLong_CheckExact(pyObj)) {
    prolog_int result = PyLong_AsSsize_t(pyObj);
    c2p_int(CTXTc result, *prTerm);
    return TRUE;
  }
  else if(PyUnicode_CheckExact(pyObj)) {
    const  char *result = PyUnicode_AsUTF8(pyObj);		
    if (!result) {
      PyObject *ptype, *pvalue, *ptraceback;
      PyErr_Fetch(&ptype, &pvalue, &ptraceback);
      PyObject* ptypeRepresentation = PyObject_Repr(ptype);
      PyObject* pvalueRepresentation = PyObject_Repr(pvalue);
      PyErr_Restore(ptype, pvalue, ptraceback);
      xsb_abort("++Error[janus]: A Python Error Occurred.  A Python Unicode object "
		"could not be translated to a UTF8 string: %s/%s",
		PyUnicode_AsUTF8(ptypeRepresentation),PyUnicode_AsUTF8(pvalueRepresentation));
    }
    else 
      c2p_string(CTXTc (char *) result, *prTerm);
    return 1;
  }
  else if(PyFloat_CheckExact(pyObj)) {
    double result = PyFloat_AS_DOUBLE(pyObj);
    c2p_float(CTXTc result, *prTerm);
    return TRUE;
  }
  else if(pyObj == Py_True){
      c2p_functor("@",1,*prTerm);
      prolog_term arg = p2p_arg(*prTerm,1);
      c2p_string("true",arg);
      return TRUE;
    }
  else if(pyObj == Py_False){
      c2p_functor("@",1,*prTerm);
      prolog_term arg = p2p_arg(*prTerm,1);
      c2p_string("false",arg);
      return TRUE;
    }
  else if(pyObj == Py_None){
    c2p_functor("@",1,*prTerm);
    prolog_term arg = p2p_arg(*prTerm,1);
    c2p_string(PYNONE_C,arg);
    return TRUE;
  }
  /* default -- not of a type that is handled */
  char str[30];
  sprintf(str, "p%p", pyObj);
  prolog_term ref = p2p_new(CTXT);
  c2p_functor(CTXTc PYOBJ_C, 1, ref);
  prolog_term ref_inner = p2p_arg(ref, 1);
  c2p_string(CTXTc str, ref_inner);		
  if(!p2p_unify(CTXTc ref, *prTerm))
    return FALSE;	
  return TRUE;
}

int convert_pyObj_prObj(CTXTdeclc PyObject *pyObj, prolog_term *prTerm, int flag) {
  PyObject *pyObj1;
  if(PyLong_CheckExact(pyObj)) {
    prolog_int result = PyLong_AsSsize_t(pyObj);
    c2p_int(CTXTc result, *prTerm);
    return TRUE;
  }
  else if(PyFloat_Check(pyObj)) {
    double result = PyFloat_AS_DOUBLE(pyObj);
    c2p_float(CTXTc result, *prTerm);
    return TRUE;
  }
  else if(PyUnicode_Check(pyObj)) {
    const  char *result = PyUnicode_AsUTF8(pyObj);		
    if (!result) {
      PyObject *ptype, *pvalue, *ptraceback;
      PyErr_Fetch(&ptype, &pvalue, &ptraceback);
      PyObject* ptypeRepresentation = PyObject_Repr(ptype);
      PyObject* pvalueRepresentation = PyObject_Repr(pvalue);
      PyErr_Restore(ptype, pvalue, ptraceback);
      xsb_abort("++Error[janus]: A Python Error Occurred.  A Python Unicode object "
		"could not be translated to a UTF8 string: %s/%s",
		PyUnicode_AsUTF8(ptypeRepresentation),PyUnicode_AsUTF8(pvalueRepresentation));
    }
    else 
      c2p_string(CTXTc (char *) result, *prTerm);
    return 1;
  }
  else if(PyTuple_Check(pyObj))  {
    size_t  i;
    PyObject *pyObjInner = NULL;
    size_t size = PyTuple_Size(pyObj);
    prolog_term P = p2p_new();
    c2p_functor(PYTUP_C,(int)size,P);
    for (i = 0; i < size; i++) {
      pyObjInner = PyTuple_GetItem(pyObj, i);
      prolog_term ithterm = p2p_arg(P, (int)i+1);
      convert_pyObj_prObj(pyObjInner, &ithterm,1);
    }
    // prolog_term P = convert_pyTuple_prTuple(CTXTc pyObj);
    if(!p2p_unify(CTXTc P, *prTerm))
      return FALSE;
    return TRUE;
  }
  //  else if(flag == 0 && PyList_Check(pyObj)) {
  //    char str[30];
  //    sprintf(str, "p%p", pyObj);
  //    prolog_term ref = p2p_new(CTXT);
  //    c2p_functor(CTXTc "pyList", 1, ref);
  //    prolog_term ref_inner = p2p_arg(ref, 1);
  //    c2p_string(CTXTc str, ref_inner);		
  //    if(!p2p_unify(CTXTc ref, *prTerm))
  //      return FALSE;	
  //    return TRUE;
  //  }
  //  else if(flag == 1 && PyList_Check(pyObj)) {
  else if(PyList_Check(pyObj)) {
    PyObject *pyObjInner;
    size_t size = PyList_GET_SIZE(pyObj); //change tes
    size_t i = 0;
    prolog_term head, tail;
    prolog_term P = p2p_new(CTXT);
    tail = P;
      
    for(i = 0; i < size; i++) {
      c2p_list(CTXTc tail);
      head = p2p_car(tail);
      pyObjInner = PyList_GetItem(pyObj, i);
      convert_pyObj_prObj(CTXTc pyObjInner, &head, 1);	
      //printPyObj(CTXTc pyObjInner);
      //printPyObjType(CTXTc pyObjInner);
      //printPlgTerm(CTXTc head);
      tail = p2p_cdr(tail);
    }
    c2p_nil(CTXTc tail);
    if(!p2p_unify(CTXTc P, *prTerm))
      return FALSE;
    return TRUE;
  }
  else if(PyDict_Check(pyObj)) {
    prolog_term head, tail, pkey, pval;
    prolog_term P = p2p_new(CTXT);
    int num_pairs = (int) PyDict_Size(pyObj);
    if (num_pairs > 0) {
      PyObject *key, *value;
      Py_ssize_t pos = 0;
      c2p_functor(PYDICT_C,1,P);
      tail = p2p_arg(P, 1);
      for (int iterator = 1 ; iterator < num_pairs ; iterator++) {
	PyDict_Next(pyObj, &pos, &key, &value);
	c2p_functor(",",2,tail);
	head = p2p_arg(tail, 1);
	c2p_functor(":",2,head);
	pkey = p2p_arg(head, 1);
	pval = p2p_arg(head, 2);
	convert_pyObj_prObj(CTXTc  key, &pkey, 1);	
	convert_pyObj_prObj(CTXTc  value, &pval, 1);	
	tail = p2p_arg(tail,2);
      }
      PyDict_Next(pyObj, &pos, &key, &value);
      c2p_functor(":",2,tail);
      pkey = p2p_arg(tail, 1);
      pval = p2p_arg(tail, 2);
      convert_pyObj_prObj(CTXTc  key, &pkey, 1);	
      convert_pyObj_prObj(CTXTc  value, &pval, 1);
    }
    else {
      c2p_functor(PYDICT_C,0,P);
    }
    if(!p2p_unify(CTXTc P, *prTerm))
      return FALSE;
    return TRUE;
  }
  else if(PySet_Check(pyObj)) {           // maybe PyAnySet_Check
    prolog_term head, tail;
    prolog_term P = p2p_new(CTXT);
    PyObject *pyObjInner;
    c2p_functor(PYSET_C,1,P);
    tail = p2p_arg(P, 1);
    PyObject *iterator = PyObject_GetIter(pyObj);
    while ((pyObjInner = PyIter_Next(iterator))) {
      c2p_list(CTXTc tail);
      head = p2p_car(tail);
      convert_pyObj_prObj(CTXTc pyObjInner, &head, 1);	
      tail = p2p_cdr(tail);
    }
    c2p_nil(CTXTc tail);
    if(!p2p_unify(CTXTc P, *prTerm))
      return FALSE;
    return TRUE;
  }
  else if(PyLong_Check(pyObj)) {
    if(pyObj == Py_True){
      c2p_functor("@",1,*prTerm);
      prolog_term arg = p2p_arg(*prTerm,1);
      c2p_string("true",arg);
      return TRUE;
    }
    if(pyObj == Py_False){
      c2p_functor("@",1,*prTerm);
      prolog_term arg = p2p_arg(*prTerm,1);
      c2p_string("false",arg);
      return TRUE;
    }
    /* Check subtypes of long that *aren't* boolean */
    else {
      prolog_int result = PyLong_AsSsize_t(pyObj);
      c2p_int(CTXTc result, *prTerm);
      return TRUE;
    }
  }
  else if(pyObj == Py_None){
    c2p_functor("@",1,*prTerm);
    prolog_term arg = p2p_arg(*prTerm,1);
    c2p_string(PYNONE_C,arg);
    return TRUE;
  }
  //  else if (PyIter_Check(pyObj) && (flag&MATERIALIZE_ITERS)) {
  else if ((flag&MATERIALIZE_ITERS) && ((pyObj1 = PyObject_GetIter(pyObj)) != NULL)) {
    pyObj = pyObj1;
    prolog_term head, tail;
    prolog_term P = p2p_new(CTXT);
    PyObject *pyObjInner, *nextObj;
    tail = P;
    while((nextObj = PyIter_Next(pyObj))) {
      c2p_list(CTXTc tail);
      head = p2p_car(tail);
      pyObjInner = nextObj;
      convert_pyObj_prObj(CTXTc pyObjInner, &head, 1);	
      tail = p2p_cdr(tail);
    }
    c2p_nil(CTXTc tail);
    if(!p2p_unify(CTXTc P, *prTerm))
      return FALSE;
    return TRUE;
  }
  /* default -- not of a type that is handled */
  char str[30];
  sprintf(str, "p%p", pyObj);
  prolog_term ref = p2p_new(CTXT);
  c2p_functor(CTXTc PYOBJ_C, 1, ref);
  prolog_term ref_inner = p2p_arg(ref, 1);
  c2p_string(CTXTc str, ref_inner);		
  if(!p2p_unify(CTXTc ref, *prTerm))
    return FALSE;	
  return TRUE;
}

//----------------------- Initialization and Callback support
void build_result(char *res, PyObject **lis)
{
	char * pch;
	pch = strtok (res, "|");
	//	int counter = 1;
	while(pch!= NULL){
    //		PyList_Append(*lis, PyString_FromString(pch));
    PyList_Append(*lis, PyUnicode_FromString(pch));
		pch = strtok (NULL, "|");
		
	}
}

static PyMethodDef XsbMethods[] = {
//    {"querySingle",  xsbp_querySingle, METH_VARARGS,
//     "Query XSB from Python which returns the first response."},
    {NULL, NULL, 0, NULL}        /* Sentinel */
};

static struct PyModuleDef moduledef = {				\
            PyModuleDef_HEAD_INIT, "janusm", "prolog to python", -1, XsbMethods, \
            NULL,NULL,NULL,NULL };

//struct module_state {
//    PyObject *error;
//};
//
//#define GETSTATE(m) ((struct module_state*)PyModule_GetState(m))

// make sure that '.' is in the 
PyMODINIT_FUNC 
PyInit_janusm(void)
{
  PyObject *module = PyModule_Create(&moduledef);
  if (module == NULL)
    return NULL;
    //struct module_state *st = GETSTATE(module);

    //st->error = PyErr_NewException("myextension.Error", NULL, NULL);
    //if (st->error == NULL) {
    //  Py_DECREF(module);
    //  return NULL;
    //}
    
    PyRun_SimpleString(
   "import sys\n"
   "sys.path.append('')\n");
    
    return module;
    //Py_InitModule("xsbp", XsbMethods);
}


// -------------------- py_func

 // TES needs update for Windows; Doesn't handle on path -- just syspath.
 // Also, I don't think it works correctly for relative paths.
char *set_path_name(char *module)
{
  char *directory_end = strrchr(module, '/');
  if(directory_end == NULL)
    return module;
  size_t directory_len = (size_t)(directory_end - module);//no need for last '/'
  char *directory = malloc(directory_len+1);
  memset(directory, '\0',directory_len+1);
  strncpy(directory,module, directory_len);
  PyObject* sysPath = PySys_GetObject((char*)"path");
  PyObject* newPythonDir = PyUnicode_FromString(directory);
  PyList_Append(sysPath, newPythonDir);
  Py_DECREF(newPythonDir);
  free(directory);
  module = (module + directory_len + 1);
  return module;
}

void set_python_argument(CTXTdeclc prolog_term temp, PyObject *pArgs,int i, char *funct, int arity) {
  PyObject *pValue;
  if(!convert_prObj_pyObj(CTXTc temp, &pValue)) {
    xsb_abort("++Error[janus]: argument %d of %s/%d could not be translated to python"
		"(arg 2 of py_func/[3,4,5])\n",i,funct,arity);
  }
  //  if (is_functor(temp) && strcmp(p2c_functor(temp),PYOBJ_C) == 0 ) {
  //      Py_INCREF(pValue);
  PyTuple_SetItem(pArgs, i-1, pValue);
}

DllExport int init_python() {
  if(!Py_IsInitialized()) {
    const char *pylib = getenv( "PYTHON_LIBRARY" );
    if (pylib) {
      printf("pylib is: %s\n",pylib); fflush(stdout);
#ifdef WIN_NT
      LoadLibrary(pylib);
#else
      dlopen( pylib, RTLD_LAZY | RTLD_GLOBAL );
#endif
    } else {
#ifdef WIN_NT
      xsb_abort("++Error[janus]: Python library dll not found; Is the PYTHON_LIBRARY environment variable set?\n");
#else
      dlopen(PYTHON_CONFLIB_2QUOTED, RTLD_LAZY | RTLD_GLOBAL );
#endif
    }
    Py_Initialize();
    char *path = "";
    PySys_SetArgvEx(0,(wchar_t **) &path,0);
  PyInit_janusm();
  }
  return TRUE;
}

void xp_python_error() {
  PyObject *ptype, *pvalue, *ptraceback = NULL;
  PyErr_Fetch(&ptype, &pvalue, &ptraceback);
  PyObject* ptypeRepr = PyObject_Repr(ptype);
  PyObject* pvalueRepr = PyObject_Repr(pvalue);
#if PY_MINOR_VERSION < 11
  PyTracebackObject *tb = (PyTracebackObject *)ptraceback;
  if (NULL != tb && NULL != tb->tb_frame ) {
    int buff_ctr = 0;
    buff_ctr = sprintf(forest_log_buffer_1->fl_buffer,
			  "Python traceback (most recent call last):\n");
    while (NULL != tb) {
      PyFrameObject *frame = tb ->tb_frame;
        int line = PyCode_Addr2Line(frame->f_code, frame->f_lasti);
        const char *filename = PyUnicode_AsUTF8(frame->f_code->co_filename);
        const char *funcname = PyUnicode_AsUTF8(frame->f_code->co_name);
        buff_ctr += sprintf(forest_log_buffer_1->fl_buffer+buff_ctr,
			    "  File \"%s\", line %d, in %s\n", filename, line, funcname);
        tb = tb->tb_next;
    }
    xsb_abort("Python Error;\n Type: %s \n Value: %s \n %s",
	      PyUnicode_AsUTF8(ptypeRepr),PyUnicode_AsUTF8(pvalueRepr),
	      forest_log_buffer_1->fl_buffer);
  }
  else 
    xsb_abort("Python Error;\n Type: %s \n Value: %s \n",
	    PyUnicode_AsUTF8(ptypeRepr),PyUnicode_AsUTF8(pvalueRepr));
#else
    xsb_abort("Python Error;\n Type: %s \n Value: %s \n",
	    PyUnicode_AsUTF8(ptypeRepr),PyUnicode_AsUTF8(pvalueRepr));
#endif
  //#else
  //    xsb_abort("Python Error;\n Type: %s \n Value: %s \n",
  //	    PyUnicode_AsUTF8(ptypeRepr),PyUnicode_AsUTF8(pvalueRepr));
    //  PyErr_Restore(NULL,NULL, NULL);
    //  PyErr_Print();
}

// Does not take dictionary values, as this doesn't seem to be supported
// By the Python C-API
// Tried to decref pObjIn but this didn't work. Not collecting pObjOut
DllExport int py_dot_int(CTXTdecl) {
  PyObject *pModule = NULL, *pyObjIn = NULL, *pObjOut = NULL;
  prolog_term prObjIn, prMethIn; 
  char *function, *module;
  PyErr_Clear();
  prObjIn = extern_reg_term(1);
  //  Skipping several typechecks, as Python does them.
  if(is_functor(prObjIn) && strcmp(p2c_functor(prObjIn),PYOBJ_C) == 0) {
    convert_prObj_pyObj(CTXTc prObjIn, &pyObjIn);
  }
  else if (isstring(prObjIn)) {
    module = p2c_string(prObjIn);
    module = set_path_name(module);
    pModule = PyImport_ImportModule(module);
    if(pModule == NULL) {
      PyErr_Print();
      xsb_abort("++Error[janus]: (existence) no Python module named \'%s\' could be found."
		"(in arg 1 of py_dot/4)\n",module);
    }
    pyObjIn = pModule;
  }
  else {
    xsb_type_error_vargs(CTXTc "Python module or object",prObjIn,"py_dot/[3,4]","");
  }
  prMethIn = (Cell) extern_reg_term(2);
  XSB_Deref(prMethIn);
  if (isconstr(prMethIn)) {
    PyObject *args[10];
    PyObject *pyDefVarsDict = NULL, *pyMethStr;
    prolog_term Dict;
    int i;
    function = p2c_functor(prMethIn);
    pyMethStr = PyUnicode_FromString(function);  
    int args_count = p2c_int(reg_term(4));
    if (args_count > 0) {
      //      printf("args count %d\n",args_count);
      args[0] = pyObjIn;
      for(i = 1; i <= (args_count); i++) {
	convert_prObj_pyObj(CTXTc p2p_arg(prMethIn, i),&args[i]);
      }
      Dict = extern_reg_term(3);
      convert_prObj_pyObj(CTXTc Dict,&pyDefVarsDict);
      if(PyDict_Check(pyDefVarsDict)) {
	PyObject *key, *value;
	Py_ssize_t pos = 0;
	int num_pairs = (int) PyDict_Size(pyDefVarsDict);
	//	printPyObj(pyDefVarsDict);
	PyObject *tup = PyTuple_New(num_pairs);
	for (int iterator = 1 ; iterator <= num_pairs ; iterator++) {
	  PyDict_Next(pyDefVarsDict, &pos, &key, &value);
 //	  printPyObj(key);
	  args[i] = value; i++;
	  PyTuple_SET_ITEM(tup,(iterator-1),key);
	}
	pObjOut = PyObject_VectorcallMethod(pyMethStr,args,(args_count+1),tup);
      } else {
	pObjOut = PyObject_VectorcallMethod(pyMethStr,args,(args_count+1),NULL);
      }
    }
    else {
      pObjOut = PyObject_CallMethodNoArgs(pyObjIn,pyMethStr);
    }
  }
  else if (isstring(prMethIn)) {
    pObjOut = PyObject_GetAttrString(pyObjIn,string_val(prMethIn));
    //    printPyObj(pObjOut);
  }
  else {
    xsb_type_error_vargs(CTXTc "Atom or Structure",prMethIn,"py_dot/[3,4]","");
  }
  if (pObjOut == NULL) { // TES todo change to check for python error
    xp_python_error();
  }
  //  Py_DECREF(pyMeth);
  int flag = p2c_int(extern_reg_term(5));
  ensureXSBStackSpace(CTXTc pObjOut,flag);
  prolog_term return_pr = p2p_new(CTXT);
  //  if(!convert_pyObj_prObj(CTXTc pObjOut, &return_pr, 1)) {
  if (!convert_pyObj_prObj_switch(CTXTc pObjOut, &return_pr, flag)) {
    //  TES: can we get here?
    xsb_abort("++Error[janus]: The return of py_dot/4  could not be translated to Prolog");
  }
  if(!p2p_unify(CTXTc return_pr, reg_term(CTXTc 6)))
    return FALSE;
  return TRUE;
}

void xp_pyerr_print() {
    PyErr_Print();
}

PyObject *get_module(char *mod_string) {
  PyObject *pyModule = NULL;
  mod_string = set_path_name(mod_string);
  PyObject *mod_name = PyUnicode_FromString(mod_string);
  if ((pyModule = PyImport_GetModule(mod_name))) 
    return pyModule;
  else {
    pyModule = PyImport_ImportModule(mod_string);
    if(pyModule == NULL) {
      xp_python_error();
    }
    return pyModule;
  }
}
	   
DllExport int py_func_int(CTXTdecl) {
  PyObject *pyModule = NULL, *pFunc = NULL;
  PyObject *pArgs = NULL, *pValue = NULL, *pyDefVarsDict = NULL;
  prolog_term CallTerm, temp,Dict;
  PyErr_Clear();
  prolog_term mod = extern_reg_term(1);
  char *mod_string = p2c_string(mod);
  pyModule = get_module(mod_string);
  //  Py_DECREF(pName);
  CallTerm = extern_reg_term(2);
  if(is_functor(CallTerm)) {
    char *function = p2c_functor(CallTerm);
    //    int args_count = p2c_arity(CallTerm);
    int args_count = p2c_int(reg_term(4));
    pFunc = PyObject_GetAttrString(pyModule, function);
    Py_DECREF(pyModule);  // TES move
    if(pFunc && PyCallable_Check(pFunc)) {
      int i;
      pArgs = PyTuple_New(args_count);
      for(i = 1; i <= args_count; i++) {
	temp = p2p_arg(CallTerm, i);
	set_python_argument(CTXTc temp, pArgs, i, function, args_count);
      }
    }
    else  { // it isn't callable
      xsb_existence_error(CTXTc "Python module function",CallTerm, "py_func",3, 2) ;
    }
    Dict = extern_reg_term(3);
    convert_prObj_pyObj(CTXTc Dict,&pyDefVarsDict);
    if(PyDict_Check(pyDefVarsDict)) {
      pValue = PyObject_Call(pFunc, pArgs,pyDefVarsDict);
    }
    else {  // Ignoring if not a dict -- maybe should change.
      pValue = PyObject_CallObject(pFunc, pArgs);
    }
    Py_DECREF(pFunc);
    Py_DECREF(pArgs);
    Py_DECREF(pyDefVarsDict);
    if (pValue == NULL) { // TES todo change to check for python error
      xp_python_error();
    }
    int flag = p2c_int(extern_reg_term(5));
    prolog_term return_pr;
    ensureXSBStackSpace(CTXTc pValue,flag);
    return_pr = p2p_new(CTXT);
    // ususally returns pyobject by default.
    if(!convert_pyObj_prObj_switch(CTXTc pValue, &return_pr, flag)) {
      xsb_abort("++Error[janus]: The return of %s/%d could not be translated to Prolog"
		"(in py_func/[3,4,5])\n",function,args_count);
    }
    if(!p2p_unify(CTXTc return_pr, reg_term(CTXTc 6))) 
      return FALSE;
    return TRUE;
  } /* if is_functor(CallTerm) */
  else	{
      xsb_type_error_vargs(CTXTc "callable",CallTerm,"py_func/[3,4]",
			   "not a callable function in the Python module %s\n",mod_string);
  }
  //  Py_Finalize();
  return TRUE;
}

//------------------------------- Utilities

void printPlgTerm(CTXTdeclc prolog_term term) {
  XSB_StrDefine(StrArgBuf);
  XSB_StrSet(&StrArgBuf,"");
  print_pterm(CTXTc term,1, &StrArgBuf);
  printf("printPlgTerm: %s\n", StrArgBuf.string);
}

void printPyObj(CTXTdeclc PyObject *obj1) {
	PyObject* objectsRepresentation = PyObject_Repr(obj1);
	const char* s = PyUnicode_AsUTF8(objectsRepresentation);
	printf("printPyObj: %s\n",s);
}
void printPyObjType(CTXTdeclc PyObject *obj1) {
	PyTypeObject* type = obj1->ob_type;
	const char* ptype = type->tp_name;
	printf("python type: %s\n",ptype);
}

DllExport int py_get_iter_int(CTXTdecl) {
  PyObject *pyModule = NULL, *pFunc = NULL;
  PyObject *pArgs = NULL, *pValue = NULL, *pDict = NULL;
  prolog_term V, temp,Dict;
  PyErr_Clear();
  prolog_term mod = extern_reg_term(1);
  char *module = p2c_string(mod);
  module = set_path_name(module);
  //  pName = PyUnicode_FromString(module);
  pyModule = PyImport_ImportModule(module);
  if(pyModule == NULL) {
    xp_python_error();
  }
  V = extern_reg_term(2);
  if(is_functor(V)) {
    char *function = p2c_functor(V);
    int args_count = p2c_int(reg_term(4));
    //    int args_count = p2c_arity(V);
    pFunc = PyObject_GetAttrString(pyModule, function);
    Py_DECREF(pyModule);  // TES move
    if(pFunc && PyCallable_Check(pFunc)) {
      pArgs = PyTuple_New(args_count);
      int i;
      for(i = 1; i <= args_count; i++) {
	temp = p2p_arg(V, i);
	set_python_argument(CTXTc temp, pArgs, i, function, args_count);
      }
    }
    else {  // it isn't callable (may not get here -- set_python_argument may handle)
      xsb_type_error_vargs(CTXTc "callable",V,"py_iter/[3,4]",
    		   "not a callable function in the Python module %s\n",module);
    }
    Dict = extern_reg_term(3);
    convert_prObj_pyObj(CTXTc Dict,&pDict);
    if(PyDict_Check(pDict)) {
      pValue = PyObject_Call(pFunc, pArgs,pDict);
    }
    else   // Ignoring if not a dict -- maybe should change.
      pValue = PyObject_CallObject(pFunc, pArgs);
    Py_DECREF(pFunc);
    Py_DECREF(pArgs);
    Py_DECREF(pDict);
    //    printPyObj(CTXTc pValue);
    if (pValue == NULL) { // TES todo change to check for python error
      xp_python_error();
    }
    PyObject *iterator = PyObject_GetIter(pValue); 
    if(iterator == NULL) {
      prolog_term prTerm = p2p_new(CTXT);
      convert_pyObj_prObj(CTXTc pValue, &prTerm, 0);
      if(!p2p_unify(CTXTc prTerm, reg_term(CTXTc 5)))
	return FALSE;
      return TRUE;
    }
    char str[30];
    sprintf(str, "p%p", iterator);
    prolog_term ref = p2p_new(CTXT);
    c2p_functor(CTXTc "pyIter", 1, ref);
    prolog_term ref_inner = p2p_arg(ref, 1);
    c2p_string(CTXTc str, ref_inner);		
    if(!p2p_unify(CTXTc ref, reg_term(CTXTc 5)))
      return FALSE;
    return TRUE;
  }
  else	{ // TES: may not get here
    xsb_type_error_vargs(CTXTc "callable",V,"py_iter/[3,4]","");
  }
  return TRUE;
}

	      //	     || (strcmp(p2c_functor(prTerm),PYTUP_C) == 0)
	      //	     || islist(prTerm))

DllExport int pyObj_get_iter_int(CTXTdecl) {
  prolog_term prTerm = extern_reg_term(1);
  //  printPlgTerm(prTerm);
  if  ( is_functor( prTerm) && (strcmp(p2c_functor(prTerm),PYOBJ_C) == 0))  {
    prolog_term ref_pyobj = p2p_arg(prTerm, 1);
	  char *node_pointer = p2c_string(ref_pyobj); 
	  //long long temp2 = strtoll(node_pointer+1,NULL, 16);
	  PyObject *pValue = (PyObject *)strtoll(node_pointer+1,NULL, 16);
	  PyObject *iterator; 
	  iterator = PyObject_GetIter(pValue);
	  if(iterator == NULL)
	    return FALSE;
	  char str[30];
	  sprintf(str, "p%p", iterator);
	  prolog_term ref = p2p_new(CTXT);
	  c2p_functor(CTXTc "pyIter", 1, ref);
	  prolog_term ref_inner = p2p_arg(ref, 1);
	  c2p_string(CTXTc str, ref_inner);		
	  if(!p2p_unify(CTXTc ref, reg_term(CTXTc 2)))
	    return FALSE;
	  return TRUE;
	}
	return FALSE;
}

DllExport void  pyObj_next_int(CTXTdecl) {
  prolog_term prTerm = extern_reg_term(1);
  prolog_term indicator = extern_reg_term(3);
  int flag = p2c_int(reg_term(4));
  if(strcmp(p2c_functor(prTerm),"pyIter") == 0)
    {
      prolog_term ref_pyobj = p2p_arg(prTerm, 1);
      char *node_pointer = p2c_string(ref_pyobj); 
      PyObject *iterator = (PyObject *)strtoll(node_pointer+1,NULL, 16);
      if (!PyIter_Check(iterator)) {
	xsb_abort("Non-itertor passed to px_next\n");
      }
      PyObject *obj = PyIter_Next(iterator);
      //      printPyObj(obj);
      if(obj == NULL) {
	c2p_int(CTXTc FALSE, indicator);
	return;
      }
      prolog_term return_pr = p2p_new(CTXT);
      if (!convert_pyObj_prObj_switch(CTXTc obj, &return_pr, flag)) {
	c2p_int(CTXTc FALSE, indicator);
	return;
      }
      //      printPlgTerm(return_pr);
      prolog_term prRet = extern_reg_term(2);
      if(!p2p_unify(CTXTc return_pr, prRet)) {
	c2p_int(CTXTc FALSE, indicator);
	return;
      }
      c2p_int(CTXTc TRUE, indicator);
      return;
    }
  c2p_int(CTXTc FALSE, indicator);
  return;
}

//----------------------------------------------------------------------------------------
// Not used
prolog_term make_prolog_pyObj(PyObject *pyObj) {
  char str[30];
  sprintf(str, "p%p", pyObj);
  prolog_term ref = p2p_new(CTXT);
  c2p_functor(CTXTc PYOBJ_C, 1, ref);
  prolog_term ref_inner = p2p_arg(ref, 1);
  c2p_string(CTXTc str, ref_inner);
  return ref;
}

//----------------------------------------------------------------------------------------
// Older code that we might or might not need.

// For Callback
/*
//static PyObject * xsbp_queryAll(PyObject *self, PyObject *args)
//{
//	char *cmd;
//	if(!PyArg_ParseTuple(args, "s", &cmd))
//		return NULL;
//	printf("%s", cmd);
//	int rcp;
//	XSB_StrDefine(p_return_string);
//	
//	xsb_query_save(3);
//	rcp = xsb_query_string_string(cmd,&p_return_string,"|");
//	while (rcp == XSB_SUCCESS ) {
//	 	printf("Return p %s\n",(p_return_string.string));
//	 	rcp = xsb_next_string(&p_return_string,"|");
//	 }
//	xsb_query_restore();
//	return Py_BuildValue("s", p_return_string.string);
//}
*/

//DllExport int convertPyPr(CTXTdecl)
//{
//	pyObj_GetIter();
//	return pyObj_Next();
//}

// There has to be some way to build a variadic function call
//PyObject *call_variadic_method(PyObject *pObjIn,PyObject *pyMeth,prolog_term prMethIn,
//			       int args_count) {
//  PyObject *pObjOut = NULL;
//  if (args_count == 0) {
//    pObjOut = PyObject_CallMethodNoArgs(pObjIn,pyMeth);
//  }
//  else if (args_count == 1) {
//    PyObject *pyArg1 = NULL;
//    prolog_term prArg1 = p2p_arg(prMethIn, 1);
//    convert_prObj_pyObj(CTXTc prArg1, &pyArg1);
//    pObjOut = PyObject_CallMethodObjArgs(pObjIn,pyMeth,pyArg1,NULL);
//    //    Py_DECREF(pyArg1);
//  }
//  else if (args_count == 2) {
//    PyObject *pyArg1 = NULL;    PyObject *pyArg2 = NULL;
//    prolog_term prArg1;
//    prArg1 = p2p_arg(prMethIn, 1);
//    convert_prObj_pyObj(CTXTc prArg1, &pyArg1);
//    prArg1 = p2p_arg(prMethIn, 2);
//    convert_prObj_pyObj(CTXTc prArg1, &pyArg2);
//    pObjOut = PyObject_CallMethodObjArgs(pObjIn,pyMeth,pyArg1,pyArg2,NULL);
//    //    Py_DECREF(pyArg1); Py_DECREF(pyArg2);
//  }
//  else if (args_count == 3) {
//    PyObject *pyArg1 = NULL;    PyObject *pyArg2 = NULL; PyObject *pyArg3 = NULL;
//    prolog_term prArg1;
//    prArg1 = p2p_arg(prMethIn, 1);
//    convert_prObj_pyObj(CTXTc prArg1, &pyArg1);
//    prArg1 = p2p_arg(prMethIn, 2);
//    convert_prObj_pyObj(CTXTc prArg1, &pyArg2);
//    prArg1 = p2p_arg(prMethIn, 3);
//    convert_prObj_pyObj(CTXTc prArg1, &pyArg3);
//    pObjOut = PyObject_CallMethodObjArgs(pObjIn,pyMeth,pyArg1,pyArg2,pyArg3,NULL);
//    //    Py_DECREF(pyArg1); Py_DECREF(pyArg2); Py_DECREF(pyArg3);
//  }
//  else {
//    xsb_abort("++Error[janus]: Cannot call py_dot/[3,4] with a method of arity greater than "
//	    "three: %s/%d\n",p2c_functor(prMethIn),args_count);
//  }
//  return pObjOut;
//}

//char janus_err[500];
//void janus_abort(char *fmt,...) {
//  va_list args;
//  va_start(args, fmt);
//  vsnprintf(janus_err, 500, fmt, args);
//  va_end(args);
//}

// Old initialization stuff.
  // char *directory = malloc(strlen(getenv("PYTHONPATH")) + directory_len+2);
  // memset(directory, '\0',strlen(getenv("PYTHONPATH")) + directory_len+2);
  // strncpy(directory,getenv("PYTHONPATH"), strlen(getenv("PYTHONPATH")));
  // strncpy(directory+strlen(getenv("PYTHONPATH")), ":", 1);
  // strncpy(directory+strlen(getenv("PYTHONPATH"))+1,module, directory_len);
  // setenv("PYTHONPATH", directory,1);

//static PyObject *xsbp_querySingle(PyObject *self, PyObject *args)
//{
//	char *cmd;
//	if(!PyArg_ParseTuple(args, "s", &cmd))
//		return NULL;
//	int rcp;
//	XSB_StrDefine(p_return_string);
//	PyObject* resultList = PyList_New(0);
//	xsb_query_save(4);
//	rcp = xsb_query_string_string(cmd,&p_return_string,"|");
//	xsb_close_query();
//	xsb_query_restore();
//	PyObject *lis = PyList_New(0);
//	if(rcp == XSB_SUCCESS){
//	build_result(p_return_string.string, & lis);
//	PyList_Append(resultList,lis);
//	}
//	return resultList;
//}

