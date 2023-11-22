:- foreign_pred paddints(+a, +b, -retval) from 
	add_integers(a:int,b:int):int.
:- foreign_pred paddfloats(+a,+b,-retval) from 
	add_floats(a:float, b:float):float.
:- foreign_pred pswapints(+a,+b,-a,-b) from 
	swap_ints(a:intptr, b:intptr):void.
:- foreign_pred psort(+a,-a) from
	sort(a:string(80)):void.
:- foreign_pred plcsort(+a,-a) from
	sort(a:chars(80)):void.
	
:- private_foreign_pred context_paddints(+a, +b, -retval) from 
	context_add_integers(a:int,b:int):int.
:- private_foreign_pred context_paddfloats(+a,+b,-retval) from 
	context_add_floats(a:float, b:float):float.
:- private_foreign_pred context_pswapints(+a,+b,-a,-b) from 
	context_swap_ints(a:intptr, b:intptr):void.
:- private_foreign_pred context_psort(+a,-a) from
	context_sort(a:string(80)):void.
:- private_foreign_pred context_plcsort(+a,-a) from
	context_sort(a:chars(80)):void.
	
