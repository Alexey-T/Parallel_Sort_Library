program test;

{$I defines.inc}

uses 
{$IF defined(Windows32) or  defined(Windows64) }
cmem,
{$IFEND}
ParallelSort,system.sysutils,system.classes,timer;

type

TStudent = Class
public
 Name: string;
end;

var tab:Ttabpointer;
    myobj:TParallelSort;
    student:TStudent;
     i,j:integer;
    
   
function comp(Item1, Item2: Pointer): integer;
begin


if TStudent(Item1).name > TStudent(Item2).name  
then 
 begin 
  result:=1;
  exit;
 end;
if TStudent(Item1).name < TStudent(Item2).name 
 then 
 begin 
  result:=-1;
  exit;
 end;

if TStudent(Item1).name = TStudent(Item2).name 
then 
 begin 
  result:=0;
  exit;
 end;
end;



begin

randomize;
myobj:=TParallelSort.create(4,ctQuicksort); // set the number of threads and the sort's type
                                             // ctQuickSort or ctHeapSort or ctMergeSort ..
                                             // you have to set the number of cores to power of 2 
setlength(tab,10000);                       

for i:=low(tab) to high(tab)

do
 begin
  student:=TStudent.create;
  student.name:= inttostr(i);
  tab[high(tab)-i]:= student;
 
end;


HPT.Timestart;

myobj.sort(tab,comp);

writeln('Time in microseconds: ',hpt.TimePeriod);

write('Type on a key to print your sorted array...: ');

readln;


for i := LOW(tab) to HIGH(Tab)-1 
 do
 begin
   if tstudent(tab[i]).name > tstudent(tab[i+1]).name 
 then 
 begin
writeln('sort has failed...');
halt;
end; 
end;


for i := 0 to high(tab)
 do
 begin
   writeln(TStudent(tab[i]).name,' ');
 end;


for i := 0 to high(tab) do freeandnil(tstudent(tab[i]));


setlength(tab,0);
myobj.free;

end.


