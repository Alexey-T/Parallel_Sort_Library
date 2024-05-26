{ System depending code for light weight threads.

  This file is part of the Free Pascal run time library.

  Copyright (C) 2008 Mattias Gaertner mattias@freepascal.org

  See the file COPYING.FPC, included in this distribution,
  for details about the copyright.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}
unit MTPCPU;

{$I defines.inc}

{$IFDEF FPC}
{$mode objfpc}{$H+}
{$inline on}

{$ENDIF FPC}


interface


{$IF defined(windows) or defined(Windows32) or defined(Windows64)}
uses Windows;
{$ELSEIF defined(freebsd) or defined(darwin)}
uses ctypes, sysctl;
{$ELSEIF defined(OSX)}
uses Posix.SysTypes,
  Posix.SysSysctl,
  System.SysUtils;
{$ELSEIF defined(linux)}
//{$linklib c}
uses ctypes;
{$IFEND}

const ALL_PROCESSOR_GROUPS = $ffff;

TYPE 

PtrInt = ^integer;


function GetSystemThreadCount: int64;

procedure CallLocalProc(AProc, Frame: Pointer; Param1: PtrInt;
  Param2, Param3: Pointer); //inline;

//function  GetActiveProcessorCount(GroupNumber:word):longword; stdcall; external 'kernel32' name 'GetActiveProcessorCount';


implementation

{$IFDEF OSX}
function NumberOfCPU: Integer;
var
  res : Integer;
  len : size_t;
begin
  len := SizeOf(Result);
  res:=SysCtlByName('hw.logicalcpu', @Result, @len, nil, 0);
  if res<>0 then
    RaiseLastOSError;
end;
 {$ENDIF OSX}

{$IFDEF Windows64}
function GetProcessAffinityMask1(hProcess: THandle;
  var lpProcessAffinityMask, lpSystemAffinityMask: qword): BOOL; stdcall; external kernel32 name 'GetProcessAffinityMask'; 
{$ENDIF Windows64}
{$IFDEF Windows32}
function GetProcessAffinityMask1(hProcess: THandle;
  var lpProcessAffinityMask, lpSystemAffinityMask: DWORD): BOOL; stdcall; external kernel32 name 'GetProcessAffinityMask'; 
{$ENDIF Windows32}

{$IFDEF Linux}
const _SC_NPROCESSORS_ONLN = 83;
function sysconf(__name:longint):longint; cdecl; external 'libc.so' name 'sysconf';
{$ENDIF}

function GetSystemThreadCount: int64;
// returns a good default for the number of threads on this system
{$IF defined(windows) or defined(Windows32) or defined(Windows64)}
//returns total number of processors available to system including logical hyperthreaded processors
var
  i: Integer;
{$IFDEF Windows32}
ProcessAffinityMask, SystemAffinityMask: DWORD;
{$ENDIF Windows32} 
 {$IFDEF Windows64}
ProcessAffinityMask, SystemAffinityMask: qword;
{$ENDIF Windows64}

  Mask: DWORD;
begin
 
    
    Result := GetActiveProcessorCount(ALL_PROCESSOR_GROUPS);
 end;
{$ELSEIF defined(UNTESTEDsolaris)}
  begin
    t = sysconf(_SC_NPROC_ONLN);
  end;
{$ELSEIF defined(freebsd) or defined(darwin)}
var
  mib: array[0..1] of cint;
  len: cint;
  t: cint;
begin
  mib[0] := CTL_HW;
  mib[1] := HW_NCPU;
  len := sizeof(t);
  fpsysctl(pchar(@mib), 2, @t, @len, Nil, 0);
  Result:=t;
end;
{$ELSEIF defined(OSX)}
begin
result:=NumberOfCPU();
end;
{$ELSEIF defined(linux)}
  begin
    Result:=sysconf(_SC_NPROCESSORS_ONLN);
  end;

{$ELSE}
  begin
    Result:=1;
  end;
{$IFEND}

procedure CallLocalProc(AProc, Frame: Pointer; Param1: PtrInt;
  Param2, Param3: Pointer); //inline;
type
  PointerLocal = procedure(_EBP: Pointer; Param1: PtrInt;
                           Param2, Param3: Pointer);
begin
  PointerLocal(AProc)(Frame, Param1, Param2, Param3);
end;

end.

