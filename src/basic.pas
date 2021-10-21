unit basic;

{ by Gary Argraves - 1996,
  revised for SuSE Linux 7.0 and GNU Pascal for usage with Netbook 2003.0504
}

interface

Const
  DayName: Array [1..7] Of String[3]=
    ('Sun','Mon','Tue','Wed','Thu','Fri','Sat');
  MonName: Array [1..12] Of String[3]=
    ('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec');

function pw(b,n:real):real;
Function V2(I:Integer):String;
function  date:string;
function  time:string;
procedure trimleading(var as:string);
procedure trimtrailing(var as:string);
function parse(ln1:string; i:integer; c:string):string;
function rpt(c:char; i:integer):string;
procedure caps(var as:string);
function  maxi(i1,i2:integer):integer;
function  mini(i1,i2:integer):integer;

implementation

uses dos;

function pw(b,n:real):real;
  begin if b=0 then pw:=0 else pw:=exp(ln(b)*n); end;  {  b^ n     }
(*
function rt(b,n:real):real;
  begin if b=0 then rt:=0 else rt:=exp(ln(b)/n); end;  {  b^(1/n)  }
*)


Function V2(I:Integer):String;
    Begin V2:=Chr(48+I Div 10)+Chr(48+I Mod 10); End;

function  date:string;
  Var   y,mon,d,dw : word;
        i          : string[4];
  begin
    getdate(y,mon,d,dw);
    str(y:4,i);
    date:= dayname[dw+1]+', '+monname[mon]+' '+v2(d)+', '+i;
  End;

function  time:string;
  Var
    h,m,s,sh   : word;
    ap         : string[2];
    i          : string[4];
  begin
    gettime(h,m,s,sh);
    AP:='am';    If H>11 Then AP:='pm';
    H:=H Mod 12; If H=0 Then H:=12;
    time := v2(h) + ':' + v2(m)+ap;
  End;

procedure trimleading(var as:string);
 var l:integer;
 begin
   l:=length(as);
   while (l>0) and (as[1]=' ') do begin delete(as,1,1); l:=length(as); end;
 end;

procedure trimtrailing(var as:string);
 var l:integer;
 begin
   l:=length(as);
   while (l>0) and (as[l]=' ') do begin delete(as,l,1); l:=length(as); end;
 end;

function parse(ln1:string; i:integer; c:string):string;
  var ln2 : string;
      j   : integer;
  begin
    ln2:=ln1;
    while i>0 do
      begin
        dec(i); j:=pos(c,ln1);
        if j>0 then
          begin ln2:=copy(ln1,1,j-1); delete(ln1,1,j+length(c)-1); end
        else begin ln2:=ln1; ln1:=''; end;
      end;
    trimleading(ln2); trimtrailing(ln2);
    parse:=ln2;
  end;

function rpt(c:char; i:integer):string;
  var c2:string;
  begin c2:=''; while i>0 do begin dec(i); c2:=c2+c; end; rpt:=c2; end;

procedure caps(var as:string);
 var i:integer;
 begin
   for i:=1 to length(as) do as[i]:=upcase(as[i]);
 end;

function  maxi(i1,i2:integer):integer; begin if i1>i2 then maxi:=i1 else maxi:=i2; end;
function  mini(i1,i2:integer):integer; begin if i1<i2 then mini:=i1 else mini:=i2; end;

end.

