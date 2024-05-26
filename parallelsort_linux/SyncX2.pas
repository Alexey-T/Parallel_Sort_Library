unit SyncX2;

{$I defines.inc}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;


type 

{$IFDEF CPU64}
long = uint64;
int = int64;
{$ENDIF CPU64}
{$IFDEF CPU32}
long = longword;
int = integer;
{$ENDIF CPU32}

function LockedIncLong(var Target: long): long;
function LockedDecLong(var Target: long): long;
function CAS(var Target:int;Comp ,Exch : int): boolean;
function LockedExchangeAdd(var Target: int; Value: int): int;
function LockedExchangeAddLong(var Target: long; Value: long):long;
function LockedIncInt(var Target: int): int;
function LockedDecInt(var Target: int): int;
function CASLong(var Target:long;Comp ,Exch : long): boolean;
function LockedExchange(var Target: long; Value: long): long;

implementation


function LockedIncLong(var Target: long): long;
begin
        {$IFDEF CPU32}
        result:=InterLockedIncrement(Target);
       {$ENDIF CPU32}
        {$IFDEF CPU64}
         result:=InterLockedIncrement64(Target);
        {$ENDIF CPU64}
end;

function LockedDecLong(var Target: long): long;
begin
        {$IFDEF CPU32}
        result:=InterLockedDecrement(Target);
       {$ENDIF CPU32}
        {$IFDEF CPU64}
         result:=InterLockedDecrement64(Target);
        {$ENDIF CPU64}
end;


function LockedIncInt(var Target: int): int;
begin
        {$IFDEF CPU32}
        result:=InterLockedIncrement(Target);
       {$ENDIF CPU32}
        {$IFDEF CPU64}
         result:=InterLockedIncrement64(Target);
        {$ENDIF CPU64}
end;

function LockedDecInt(var Target: int): int;
begin
        {$IFDEF CPU32}
        result:=InterLockedDecrement(Target);
       {$ENDIF CPU32}
        {$IFDEF CPU64}
         result:=InterLockedDecrement64(Target);
        {$ENDIF CPU64}
end;


function CAS(var Target:int;Comp ,Exch : int): boolean;
var ret:int;
begin
{$IFDEF CPU32}
 ret:= InterlockedCompareExchange(Target,Exch,Comp);
{$ENDIF CPU32}
{$IFDEF CPU64} 
ret:= InterlockedCompareExchange64(Target,Exch,Comp);
{$ENDIF CPU64}
if ret=comp
 then result:=true
 else result:=false;  
end; { CAS }


function CASLong(var Target:long;Comp ,Exch : long): boolean;
var ret:long;
begin
{$IFDEF CPU32}
 ret:= InterlockedCompareExchange(Target,Exch,Comp);
{$ENDIF CPU32}
{$IFDEF CPU64} 
ret:= InterlockedCompareExchange64(Target,Exch,Comp);
{$ENDIF CPU64}
if ret=comp
 then result:=true
 else result:=false;  
end; { CAS }



function LockedExchangeAdd(var Target: int; Value: int): int;
begin

{$IFDEF CPU32}
 result:=InterLockedExchangeAdd(Target,Value);
{$ENDIF CPU32}
{$IFDEF CPU64} 
 result:=InterLockedExchangeAdd64(Target,Value);
{$ENDIF CPU64}
end;

function LockedExchangeAddLong(var Target: long; Value: long):long;
begin
{$IFDEF CPU32}
 result:=InterLockedExchangeAdd(Target,Value);
{$ENDIF CPU32}
{$IFDEF CPU64} 
 result:=InterLockedExchangeAdd64(Target,Value);
{$ENDIF CPU64}
end;


function LockedExchange(var Target: long; Value: long): long;
begin
{$IFDEF CPU32}
result:=InterLockedExchange(Target,Value);
{$ENDIF CPU32}
{$IFDEF CPU64} 
result:=InterLockedExchange64(Target,Value);
{$ENDIF CPU64}
end;


end.

