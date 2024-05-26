

// You have to  compile and run gendata.pas first and after that compile and run test.pas... 


program test;

{$I defines.inc}

uses 
{$IF defined(Windows32) or  defined(Windows64) }
cmem,
{$IFEND}
ParallelSort,system.sysutils,timer,mtpcpu;

type 
TStudent = Class
public
 Name: string;
   end;


var tab:Ttabpointer;
     myobj:TParallelSort;
     student:TStudent;
     i:integer;
fic:text;
 t:array of string;
    a:integer;
    nom_fic,name:string;


function comp(Item1, Item2: Pointer): integer;
begin

if TStudent(Item1).name < TStudent(Item2).name 
 then 
 begin 
  result:=-1;
  exit;
 end;

if TStudent(Item1).name > TStudent(Item2).name  
then 
 begin 
  result:=1;
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

myobj:=TParallelSort.create(4,ctQuicksort); // set the number of threads and the sort's type
                                                                 // ctQuickSort or ctHeapSort or ctMergeSort ..
                                                                 // you have to set the number of cores to power of 2 

  
setlength(tab,2000000);




nom_fic:='amine.txt';
assign(fic,nom_fic);
reset(fic);

for i:=0 to 2000000-1

do
 begin
  readln(fic,a);
  student:=TStudent.create;
  student.name:= inttostr(a);
  tab[i]:= student;

 end;

HPT.Timestart;

myobj.sort(tab,comp);

writeln;
writeln('Time in microseconds: ',hpt.TimePeriod);


writeln;
writeln('Please press a key to continu...');
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


for i := LOW(tab) to HIGH(Tab) 
 do
 begin
   writeln(TStudent(tab[i]).name,' ');
 end;


for i := 0 to HIGH(Tab) do freeandnil(TStudent(tab[i]));

setlength(tab,0);

myobj.free;

end.





