REM run this file to make the dll's necessary to test all the
REM   foreign calls in this directory under --mswin64 testing.

nmake /f MakefileCinter1_w64
nmake /f MakefileCinter2_w64
nmake /f MakefileCinter3_w64
nmake /f MakefileFibr_w64
nmake /f MakefileCCallsXSB_w64
nmake /f MakefileXeddis_w64
