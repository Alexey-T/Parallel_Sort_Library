
{$OPTIMIZATION OFF}

{*************************************************************
*       Module: Scalable lock that is FIFO fair and starvation-free  
*      Version: 1.24
*      Author: Amine Moulay Ramdane                
*     Company: Cyber-NT Communications           
*     
*       Email: aminer@videotron.ca   
*     Website: http://pages.videotron.com/aminer/
*        Date: May 12, 2014
*    Last update: April 30, 2016
*    
* Copyright © 2013 Amine Moulay Ramdane.All rights reserved
*
*************************************************************}

unit MLock;

{$I defines.inc}

interface

{$IFDEF FPC}
{$ASMMODE intel}
{$ENDIF FPC}
{$R-}
{$Q-}

uses 
{$IF defined(Delphi)}
cmem,
{$IFEND}
SyncX,classes;

const
  Alignment = 64; // alignment, needs to be power of 2
  kernel32  = 'kernel32.dll';

Type

typecache1  = array[0..12] of integer;
typecache2  = array[0..9] of integer;

 {$IFDEF CPU64}
 int = int64;
 Long = uint64;
 {$ENDIF CPU64}
 {$IFDEF CPU32}
 int = integer;
 Long = longword;
 {$ENDIF CPU32}
 
typecache  = array[0..15] of integer;

 PInt = ^int;
  PListEntry = ^TListEntry;
  TListEntry = record
    Next: PListEntry;
    Data: Int;
    mem:pointer;
    {$IFDEF CPU32}
    cache:typecache1;
    {$ENDIF CPU32}
    {$IFDEF CPU64}
    cache:typecache2;
    {$ENDIF CPU64}
   end;
  TMLock=Class
   private
      cache0:typecache;
      m_tail:PListEntry;
      cache1:typecache;
      m_head:PListEntry;
      cache2:typecache;
      flag:int;
      cache3:typecache;
      n1:PListEntry;
      cache4:typecache;
      buffer:pointer;
      cache5:typecache;

   Public
      count1:Integer;
      cache6:typecache; 
      constructor create;
      destructor  Destroy; override;
      procedure Enter;
      procedure Leave;
     end;

{$IF defined(Windows32) or  defined(Windows64) }
function SwitchToThread: LongBool; stdcall; external kernel32 name 'SwitchToThread';
{$IFEND}

implementation

uses SysUtils;

procedure mfence;assembler;
asm 
 mfence
end;

constructor TMLock.create;
 var  Buffer1:pointer;
      FCount1: PListEntry;

begin
Buffer1 := AllocMem(SizeOf(TListEntry) + Alignment);
FCount1 := PListEntry((int(Buffer1) + Alignment - 1)
                           and not (Alignment - 1));  
 
   fcount1^.Data:=0;
   fcount1^.Next:=nil;
   m_tail:=fcount1;
   m_head:=fcount1;
buffer:=buffer1;
flag:=1;
end;

destructor TMLock.Destroy;
begin
if assigned(m_tail^.mem) then freemem(m_tail^.mem);
if assigned(m_head^.mem) then freemem(m_head^.mem);
freemem(buffer);
 inherited Destroy;

end;

procedure TMLock.Enter;
var prev,fcount1:PListEntry;
    k:integer; 
    Buffer1:pointer;
   

begin
Buffer1 := AllocMem(SizeOf(TListEntry) + Alignment);
FCount1 := PListEntry((int(Buffer1) + Alignment - 1)
                           and not (Alignment - 1));  

fcount1^.Data:=0;
fcount1^.Next:=nil;
fcount1^.mem:=buffer1;

long(prev) := LockedExchange(long(m_head), long(fcount1));

prev.next := fcount1;

repeat

if fcount1^.data=1 
then 
begin
freemem(fcount1^.mem); 
break;
end
else if fcount1^.data=2
then 
 begin
  fcount1^.Data:=-1; 
  break
 end;
if flag=1
then
begin
if CAS(flag,1,0) 
     then 
      begin
       fcount1^.Data:=-1; 
       break;
      end;
end;
{$IFDEF FPC}
ThreadSwitch;
{$ENDIF}
{$IFDEF Delphi}
SwitchToThread();
{$ENDIF}
until false;


end;


procedure TMLock.Leave;
var next:PListEntry;
   
begin

mfence;

repeat
next := m_tail.next;

if (next = nil) 
 then 
  begin
    flag:=1;
    break;   
  end
else if (next.data=0)
 then 
  begin
 
   if next.next<>nil
   then  
    begin
	 m_tail.next:=next.next;
       next.data:=1;
       break;
	 end
	 else 
       begin
        next.data:=2;
        break;
       end;
   
  end
else if next.data=-1
   then 
    begin
	 if next.next<>nil
    then 
	 begin
	  m_tail.next:=next.next;
	  freemem(next^.mem); 
       end
    else
     begin
      flag:=1; 
      break;
     end;
    end;
until false;

mfence;

end;


end.

{$R+}
{$Q+}
{$OPTIMIZATION ON}
