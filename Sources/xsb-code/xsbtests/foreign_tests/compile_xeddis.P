/**:- (windows_os
    ->	   (xsb_configuration(word_size,'64')
	    ->	   shell('bash -c "./make_xeddis_w64.bat"')
	    ;	   shell('bash -c "./make_xeddis.bat"')
	    )
    ; true
   ).
**/

:- [xeddis],halt.
