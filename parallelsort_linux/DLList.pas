
unit DLList;

{$I defines.inc}

interface

uses 
{$IF defined(Delphi)}
cmem,
 {$IFEND}
MLock;

type

tNodeQueue = tObject;

typecache0  = array[0..15] of integer;


 DListNode=class(TObject)
  private
  cache0:typecache0; 
  next,prev:DListNode;
  cache1:typecache0; 
  public
  cache2:typecache0;  
  obj:tNodeQueue;
  cache3:typecache0;  
  constructor create;
  destructor destroy; override;
 end;

 DList=class(TObject)
  private
  cache0:typecache0; 
  fhead,ftail:DListNode;
  fsize:int64;
  cache1:typecache0; 
  function getsize:int64;
  public
  constructor create;
  destructor destroy; override;
  procedure append(p:DListNode);
  procedure insertbefore(p,before:DListNode);
  procedure remove(p:DListNode);
  procedure delete(p:DListNode);
  function next(p:DListNode):DListNode;
  function prev(p:DListNode):DListNode;
  
  published
  property size:int64 read getsize;
  property head:DListNode read fhead;
  property tail:DListNode read ftail;
 end;

 DQueue=class(DList)     //FIFO
  private
   cache0:typecache0; 
   lock1:TMLOCK; 
   cache1:typecache0; 
   public
  constructor create(size:integer=1024);
  destructor destroy; override;
  function push(obj:tNodeQueue):boolean;
  function pop(var obj:tNodeQueue):boolean;
  function IsEmpty:boolean;
  function Count:int64; 
 end;

 DStack=class(DList)
  private
   cache0:typecache0; 
   lock1:TMLOCK; 
   cache1:typecache0; 
   public
  constructor create(size:integer=1024);
  destructor destroy; override;
  function push(obj:tNodeQueue):boolean;
  function pop(var obj:tNodeQueue):boolean;
  function IsEmpty:boolean;
  function Count:int64; 
 end;


implementation

uses Sysutils;

type EDoubleLinkedStuff=class(Exception);

constructor DListNode.create;
begin
 inherited create;
 next:=nil; prev:=nil;
end;

destructor DListNode.destroy;
begin
 inherited destroy;
end;

function DList.getsize:int64;
begin
 result:=fsize;
end;

constructor DList.create;
begin
 inherited create; fhead:=nil; ftail:=nil; fsize:=0;
end;

destructor DList.destroy;
var q:DListNode;
begin
 while head <> nil do
  begin
   q:=fhead; fhead:=fhead.next; q.destroy;
  end;
end;

procedure DList.append(p:DListNode);
begin
 if fhead=nil then begin
   fhead:=p; ftail:=p;
  end
 else begin
   p.prev:=ftail; ftail.next:=p; ftail:=p;
  end;
 inc(fsize);
end;

procedure DList.insertbefore(p,before:DListNode);
begin
 if head=nil then begin
  fhead:=p; ftail:=p;
 end
 else begin
  if before=head then begin
    p.next:=head; head.prev:=p; fhead:=p;
   end
  else begin
    p.next:=before; p.prev:=before.prev;
    p.prev.next:=p; before.prev:=p;
   end;
  end;
 inc(fsize);
end;

procedure DList.remove(p:DListNode);
begin
 if p=fhead then begin
   fhead:=fhead.next;
   if fhead=nil then ftail:=nil
   else fhead.prev:=nil;
  end
 else begin
   if p=ftail then begin
     ftail:=ftail.prev;
     if ftail=nil then fhead:=nil
     else ftail.next:=nil;
    end
   else begin
     p.prev.next:=p.next;
     p.next.prev:=p.prev;
    end;
  end;
 dec(fsize);
 p.next:=nil; p.prev:=nil;
end;

procedure DList.delete(p:DListNode);
begin
 remove(p); p.destroy;
end;

function DList.next(p:DListNode):DListNode;
begin
 if p=nil then raise EDoubleLinkedStuff.create('next(DList) is nil');
 result:=p.next;
end;

function DList.prev(p:DListNode):DListNode;
begin
 if p=nil then raise EDoubleLinkedStuff.create('prev(DList) is nil');
 result:=p.prev;
end;

constructor DQueue.create(size:integer=1024);
begin
  lock1:=TMLOCK.create();

 inherited create;
end;

destructor DQueue.destroy;
var i:int64;
  obj:tNodeQueue;
begin
if size>0 
then
begin
i:=0;
repeat
pop(obj);
i:=i+1;
until i=size;
end;
lock1.free;
inherited destroy;
end;

function DQueue.push(obj:tNodeQueue):boolean;
var p:DListNode;

begin
lock1.enter;
 p:=DListNode.create;
 p.obj:=obj;
 insertbefore(p,head);
result:=true;
lock1.leave;
end;

function DQueue.pop(var obj:tNodeQueue):boolean;
var p:DListNode;

begin

lock1.enter;

if tail=nil 
then
 begin
  result:=false;
  lock1.leave;
  exit;
 end;
 p:=tail;
 obj:=p.obj;
 result:=true;
 if tail <> nil then delete(p);
lock1.leave;
end;

function DQueue.IsEmpty:boolean;
begin
lock1.enter;
if tail=nil 
then result:=true
else result:=false;
lock1.leave;
end;

function DQueue.Count:int64;
begin
lock1.enter;
result:=size;
lock1.leave;
end;


constructor DStack.create(size:integer=1024);
begin
  lock1:=TMLOCK.create();

inherited create;
end;

destructor DStack.destroy;
var i:int64;
    obj:tNodeQueue;
begin
if size>0
then
begin
i:=0;
repeat
pop(obj);
i:=i+1;
until i=size;
end;
lock1.free;
 inherited destroy;
end;

function DStack.push(obj:tNodeQueue):boolean;
var p:DListNode;
begin
lock1.enter;
 p:=DListNode.create;
 p.obj:=obj;
 append(p);
result:=true;
lock1.leave;
end;

function DStack.pop(var obj:tNodeQueue):boolean;
var p:DListNode;
begin
lock1.enter;
if tail=nil 
then
 begin
  result:=false;
  lock1.leave;
  exit;
 end;
 p:=tail;
 obj:=p.obj;
 result:=true;;
 if tail <> nil then delete(tail);
lock1.leave;
end;

function DStack.IsEmpty:boolean;
begin
lock1.enter;
if tail=nil 
then result:=true
else result:=false;
lock1.leave;
end;

function DStack.Count:int64;
begin
lock1.enter;
result:=size;
lock1.leave;
end;


end.
