@echo off
REM   makexsb64arm.bat
REM   Script for compiling XSB under Windows arm64 using VC++

set XSBCONFIGdir=..\config\arm64-pc-windows

IF NOT EXIST %XSBCONFIGdir%\saved.o MKDIR %XSBCONFIGdir%\saved.o
IF NOT EXIST %XSBCONFIGdir%\bin mkdir %XSBCONFIGdir%\bin
IF NOT EXIST %XSBCONFIGdir%\lib mkdir %XSBCONFIGdir%\lib

IF NOT EXIST ..\emu\private_builtin.c  copy private_builtin.in ..\emu\private_builtin.c

@copy xsb64arm.bat.in ..\bin\xsb64arm.bat

@copy odbc\* %XSBCONFIGdir%
@copy windows64arm\banner.msg %XSBCONFIGdir%
@copy windows64arm\xsb_configuration.P %XSBCONFIGdir%\lib
@copy windows64arm\xsb_config.h %XSBCONFIGdir%
@copy windows64arm\xsb_config_aux.h %XSBCONFIGdir%
@copy windows64arm\xsb_debug.h %XSBCONFIGdir%

@cd ..\emu

REM Concatenate MSVC_mkfile.mak & MSVC.dep into emu\MSVC_mkfile.mak
@copy ..\build\windows64arm\MSVC_mkfile.mak+..\build\MSVC.dep MSVC_mkfile.mak


@nmake /nologo /f "MSVC_mkfile.mak" %1 %2 %3 %4 %5 %6 %7

@if exist MSVC_mkfile.mak del MSVC_mkfile.mak

@cd ..\gpp
@nmake /nologo /s /f "MSVC_mkfile64arm.mak" %1 %2 %3 %4 %5 %6 %7

@cd ..\packages

@cd dbdrivers
@nmake /nologo /s /f NMakefile64arm.mak %1 %2 %3 %4 %5 %6 %7
@cd ..

REM Must build curl before sgml and xpath
@cd curl
@nmake /nologo /f NMakefile64arm.mak %1 %2 %3 %4 %5 %6 %7
@cd ..

@cd sgml\cc
@nmake /nologo /f NMakefile64arm.mak %1 %2 %3 %4 %5 %6 %7
@cd ..\..

@cd xpath\cc
@nmake /nologo /f NMakefile64arm.mak %1 %2 %3 %4 %5 %6 %7
@cd ..\..

@cd pcre
@nmake /nologo /f NMakefile64arm.mak %1 %2 %3 %4 %5 %6 %7
@cd ..

@cd json\cc
@nmake /nologo /f NMakefile64arm.mak %1 %2 %3 %4 %5 %6 %7
@cd ..\..

@cd ..\build

..\bin\xsb64arm --noprompt --quietload --nofeedback --nobanner -e "writeln('### Running XSB for the first time.\n'), halt."

