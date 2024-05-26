program test;


var fic:text;
    a,i:integer;
    nom_fic:string;
   

begin

randomize;
nom_fic:='amine.txt';
assign(fic,nom_fic);
rewrite(fic);

for i:=0 to 8000000-1

do
 begin
 writeln(fic,10+random(999));
//writeln(fic,random(999999999));
 end;

//reset(fic);

for i:=0 to 5000-1

do
 begin
 // read(fic,a);
 // writeln(a);
 end;




close(fic);
 end.



