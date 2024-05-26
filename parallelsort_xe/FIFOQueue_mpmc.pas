
{$OPTIMIZATION OFF}


// A fast and efficient concurrent FIFO queue 
// based on Dmitry Vyukov concurrent FIFO queue 
// and enhanced by Amine Moulay Ramdane.


unit FIFOQueue_mpmc;

{$I defines.inc}

interface

{$IFDEF FPC}
{$ASMMODE intel}
{$ENDIF FPC}


uses 
{$IF defined(XE)}
cmem,
 {$IFEND}
system.classes,system.syncobjs,system.sysutils,MLock;
  
const
Alignment = 64; // alignment, needs to be power of 2
kernel32  = 'kernel32.dll';

Type

long = pointer;

tNodeQueue = tObject;

typecache  = array[0..15] of integer;
typecache1  = array[0..12] of integer;
typecache2  = array[0..9] of integer;


 {$IFDEF CPU64}
 int = int64;
 long1 = uint64;
 {$ENDIF CPU64}
 {$IFDEF CPU32}
 int = integer;
 long1 = longword;
 {$ENDIF CPU32}
 
  PListEntry = ^TListEntry;
  TListEntry = record
    Next: PListEntry;
    Data: pointer;
    mem:pointer;
    {$IFDEF CPU32}
    cache:typecache1;
    {$ENDIF CPU32}
    {$IFDEF CPU64}
    cache:typecache2;
    {$ENDIF CPU64}
  end;
  TFIFOQueue_mpmc=Class
 private
      tmp:typecache; 
      m_tail:PListEntry;
      tmp0:typecache; 
      m_head:PListEntry;
      tmp1:typecache; 
      count1:long1;
      tmp2:typecache; 
      mem2:pointer;
      buffer:pointer;
      fwait:boolean;
      lock1,lock2:TMLOCK; 
      tmp3:typecache; 
     Public
      constructor create(size:integer=1024);
      destructor  Destroy; override;
      function IsEmpty:boolean;
      function Push(item: tNodeQueue):boolean;
      function Pop(var obj:tNodeQueue):boolean;
      function sPop(var obj:tNodeQueue):boolean;
      function count:long1;

     end;

function LockedExchange(var Target: long1; Value: long1): long1;

{$IF defined(Windows32) or  defined(Windows64) }
function SwitchToThread: LongBool; stdcall; external kernel32 name 'SwitchToThread';
{$IFEND}

implementation


{$IF defined(CPU64) }
function LockedCompareExchange(CompareVal, NewVal: Int; var Target: int): Int; overload;
asm
mov rax, rcx
lock cmpxchg [r8], rdx
end;
{$IFEND}
{$IF defined(CPU32) }
function LockedCompareExchange(CompareVal, NewVal: int; var Target: int): int; overload;
asm
lock cmpxchg [ecx], edx
end;
{$IFEND}

function CAS(var Target:int;Comp ,Exch : int): boolean;
var ret:int;
begin

ret:=LockedCompareExchange(Comp,Exch,Target);
if ret=comp
 then result:=true
 else result:=false;  

end; { CAS }

function LockedIncLong(var Target: long1): long1;
asm
        {$IFDEF CPU32}
        // --> EAX Target
        // <-- EAX Result
        MOV     ECX, EAX
        MOV     EAX, 1
        //sfence
       LOCK XADD [ECX], EAX
        inc     eax
        {$ENDIF CPU32}
        {$IFDEF CPU64}
        // --> RCX Target
        // <-- EAX Result
        MOV     rax, 1
        //sfence
        LOCK XADD [rcx], rax
        INC     rax
        {$ENDIF CPU64}
end;

function LockedDecLong(var Target: long1): long1;
asm
        {$IFDEF CPU32}
        // --> EAX Target
        // <-- EAX Result
        MOV     ECX, EAX
        MOV     EAX, -1
        //sfence
       LOCK XADD [ECX], EAX
        dec     eax
        {$ENDIF CPU32}
        {$IFDEF CPU64}
        // --> RCX Target
        // <-- EAX Result
        MOV     rax, -1
        //sfence
        LOCK XADD [rcx], rax
        dec     rax
        {$ENDIF CPU64}
end;

function LockedExchange(var Target: long1; Value: long1): long1;
asm
        {$IFDEF CPU32}
        // --> EAX Target
        //     EDX Value
        // <-- EAX Result
        MOV     ECX, EAX
        MOV     EAX, EDX
        //     ECX Target
        //     EAX Value
        LOCK XCHG [ECX], EAX
        {$ENDIF CPU32}
        {$IFDEF CPU64}
        // --> RCX Target
        //     RDX Value
        // <-- RAX Result
        MOV     RAX, RDX
        //     RCX Target
        //     RAX Value
        LOCK XCHG [RCX], RAX
        {$ENDIF CPU64}
end;

constructor TFIFOQueue_mpmc.create(size:integer=1024);
var Buffer1:pointer;
      FCount1: PListEntry;
begin
count1:=0;
Buffer1 := AllocMem(SizeOf(TListEntry) + Alignment);
FCount1 := PListEntry((int(Buffer1) + Alignment - 1)
                           and not (Alignment - 1));  

   fcount1^.Data:=nil;
   fcount1^.Next:=nil;
   m_tail:=fcount1;
   m_head:=fcount1;

mem2:=nil;
buffer:=buffer1;

  lock1:=TMLOCK.create();
  lock2:=TMLOCK.create();


end;

destructor TFIFOQueue_mpmc.Destroy;
begin
if assigned(mem2) then freemem(mem2);
freemem(buffer);

lock1.free;
lock2.free;

 inherited Destroy;

end;

function TFIFOQueue_mpmc.Push(item:tNodeQueue):boolean;
var fcount1,prev:PListEntry;
    buffer1:pointer;

begin


 Buffer1 := AllocMem(SizeOf(TListEntry) + Alignment);
FCount1 := PListEntry((int(Buffer1) + Alignment - 1)
                           and not (Alignment - 1));  

fcount1^.Data:=pointer(item);
fcount1^.Next:=nil;
fcount1^.mem:=buffer1;
lock1.enter;


long1(prev) := LockedExchange(long1(m_head), long1(fcount1));
prev.next := fcount1;
LockedIncLong(count1);
result:=true;
lock1.leave;
end;


function TFIFOQueue_mpmc.sPop(var obj:tNodeQueue):boolean;
var cmp,next:PListEntry;
begin


cmp := m_tail;
next := cmp.next;

if (next = nil) 
 then 
  begin
    result:=false;
    exit;   
  end;

obj := next.Data;   

m_tail:=next;
freemem(cmp^.mem);
result:=true;

end;

function TFIFOQueue_mpmc.Pop(var obj:tNodeQueue):boolean;
var cmp,cmptmp,next:PListEntry;
t,i:integer;
ret:boolean;
mem:pointer;
begin
lock2.enter;
repeat

cmp := m_tail ;
next := cmp.next;

if (next = nil) 
 then 
  begin
    result:=false;
    lock2.leave;
    exit;   
    
  end;


obj := tNodeQueue(next.Data);   
mem2:=next.mem;

ret:=CAS(int(m_tail),int(cmp),int(next));
if ret then break;
//t:=backoff.delay;
//for i:=0 to 35*t do asm pause end; 
{$IFDEF FPC}
ThreadSwitch;
{$ENDIF}
{$IFDEF XE}
System.Classes.TThread.Yield;
{$ENDIF}
until false; 

mem:=cmp^.mem;
//freemem(mem);
LockedDecLong(count1);

result:=true;

lock2.leave;
freemem(mem);

end;

function TFIFOQueue_mpmc.IsEmpty:boolean;
var cmp,next:PListEntry;

begin

lock2.enter;

cmp := m_tail ;
next := cmp.next;

if (next = nil) 
 then result:=true
 else result:=false;
lock2.leave;

end;

function TFIFOQueue_mpmc.count:long1;

begin
lock1.enter;
lock2.enter;
result:=count1;
lock2.leave;
lock1.leave;
end;
end.

{$OPTIMIZATION ON}
