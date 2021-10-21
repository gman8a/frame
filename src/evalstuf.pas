unit evalstuf;

{ by Gary Argraves - 1996,
  revised for SuSE Linux 7.0 and GNU Pascal for usage with Netbook 2003.0504

  History:
    - 7/11/2009  fix alias of intrinsic functions: SQRT, SQR, PI, _MOD, _DIV, _SHR, _SHL
                                                   i,    j,   k,  m,    n,    o,    p
      These function were using single characters that were not normal printable ASCII
}

interface

uses macrostf;

var  f_var          : array[0..299] of real;      { 'F'unction variable type }
     { note: f_var's 100-299 are not used to store real numbers, because
             s_var'  are stored here.  the s_var overlays f'vars so that
             the register record include both s_var and f_vars. }

     eval_macros    : large_macro_arr_type; { array[1..100] of ^macro_type; }
     eval_macro_rec : macro_rec_type;

var rpn_str : array[0..10] of string[160]; { was 80 GLA-7/11/2009 }
{ make global so caller can use with rpn_eval and |Storage strings }

procedure val2(    infix    : string;
               var v        : real;
               var err_code : integer);

procedure val3(  register   : integer; { by pass overhead in val2 by using }
               var v        : real;    { a stored RPN equation }
               var err_code : integer);

procedure rpn_eval(rpn:string; var v:real; var err_code:integer);
 { same as val3 except a tad faster because there is 1 less call }

function  rval(s:string):real;                { val2 with err check/acction }
function  ival(s:string):integer;
function  parse_rval(var ln1:string):real;
function  parse_rval2(var ln1:string):real;

function  int_parse(var ln1:string):integer;

implementation

uses basic;

procedure error(s:string);
  begin
    writeln('Error: ',s);
    halt(1);
  end;

var err: integer;

  function  int_parse(var ln1:string):integer;
    begin int_parse:=round(parse_rval2(ln1)); end;

  function rval(s:string):real;
    var r:real;
    begin
      val2(s,r,err);
      if err>0 then error('REAL No. Conversion: '+s);
      rval:=r;
    end;
  function ival(s:string):integer;
    var i:integer;
    begin
      val(s,i,err);
      if err>0 then error('Integer No. Conversion: '+s);
      ival:=i;
    end;

  function parse_rval(var ln1:string):real;
    begin
      trimleading(ln1);
      parse_rval:=rval(parse(ln1,1,' '));
      while ln1[1]>' ' do delete(ln1,1,1);
    end;

  function parse_rval2(var ln1:string):real;
    var i : integer;
    begin
      trimleading(ln1);
      parse_rval2:=rval(parse(ln1,1,','));
      i:=pos(',',ln1);
      if (i>0) and (length(ln1)>i) then ln1:=copy(ln1,i+1,100)
      else ln1:='';
    end;


function infix_to_rpn(infix:string):string; { was local to procedure val2 }
     var
       digit_expected     : boolean;
       digit_err          : boolean;

        function e_parse:string;

          type str01=string[1];

          function intrinsic:str01; { return single char. of intrinsic function }
            var i : integer;
                ln1 : string[60]; { was 20  GLA-7/11/2009 }
            const
              intrintics = 33;
              intrinsic_func : array[1..intrintics] of string[4]=(
                 '+','-','**','*','/','^','(',')','X','F',
                 'LN','EXP','LOG',
                 'SQRT','SQR','PI',
                 'SIN','COS','TAN',
                 'ASIN','ACOS','ATAN',
                 'INT','ABS','RND',
                 '_AND','_OR','_XOR',
                 '_MOD','_DIV','_SHR','_SHL',
                 '|');

              subst_func : string[intrintics] =
                                        '+-^*/^()XFNELijkSCTsctIAR&#!mnop|';  {i,j,k,m,n,o,p  GLA - 7/11/2009}
                                        {123456789012345678901234567890}

            begin
              i:=1;
              while (i<intrintics) and (pos(intrinsic_func[i],infix)<>1) do
                inc(i);

              case i of                                    { substitutions }
                 2:if digit_expected then i:=0;            { -    }
   9,10,intrintics:i:=0;                                   { X# F## |  }
                16:begin                                   { PI   }
                    str(pi,ln1);
                    if ln1[1]=' ' then ln1:=copy(ln1,2,200);
                    infix:=ln1 + copy(infix,3,200);
                    {writeln('debug: infix=',infix);
                    writeln('debug: pi=',pi);}
                    i:=0;
                   end;
              end{case};

              if i>0 then
                begin
                   infix:=copy(infix,length(intrinsic_func[i])+1,200);
                   intrinsic:=subst_func[i];
                   digit_expected:=subst_func[i] <> ')';
                   { never expect a digit after a end ) }
                end
              else intrinsic:='';
            end;

          var s : string;

          procedure get_digit;
            begin
              digit_err:=not
                     (infix[1] in ['A'..'D','0'..'9','.','E','-','F','X','$']);
              s:=s+infix[1];
              if infix[1]='E' then      { check for the exponensial sign }
                if infix[2] in ['+','-'] then
                  if pos('$',s)=0 then
                    begin s:=s+infix[2]; infix:=copy(infix,2,200); end;
              infix:=copy(infix,2,200);
            end;

          begin{e_parse}
            s:='';
            if infix>'' then
              begin
                s:=intrinsic;   { check for intrinsic functions }
                if s='' then    { get number }
                  begin
                    get_digit;  { do once to get a negative # }
                    while       (infix > '')
                        and not (infix[1] in ['+','-','*','/','^','(',')','_'])
                        and not digit_err
                      do get_digit;
                    digit_expected:=false;
                  end;
              end;
            if not digit_err then e_parse:=s else e_parse:='';
          end{e_parse};

        function priority(s:string):integer;
          begin
            case s[1] of
               'N','E','L',  { natural_log  exponenial  Log_base_10 }
               'S','C','T',  {    sin    cos    tan }
               's','c','t',  { arcsin arccos arctan }
               'I','A','R',  { INT, ABS, RND }
               'i','j'   :priority:=5; { SQRT, SQR,  GLA- 7/11/2009 }
                      '^':priority:=4;
                  '*','/':priority:=3;

      'm','n','o','p', { _MOD, _DIV, _SHR, _SHL,   GLA- 7/11/2009 }
      '!','#','&','+','-':priority:=2;

     'F','X','0'..'9','.':priority:=1;
                 else     priority:=0;
            end{case};
            if length(s)>1 then priority:=1;    { must be a number }
          end;

      var
        stack : array[1..30] of char;
        top,p : integer;
        rpn,s : string;

    begin{infix_to_rpn}
      top:=0;
      rpn:='';
      digit_expected:=true;  { for reuse of negative sign in negative numbers }
      digit_err:=false;

      while infix>'' do
        begin
          s:=e_parse;
          if digit_err then begin infix_to_rpn:=''; exit; end;
          p:=priority(s);
          if p=1 then rpn:=rpn+' '+s  { string expression is a number }
          else if p>1 then            { string expression is a operator }
                 begin
                   while (top>0) and (priority(stack[top])>=p) do
                     begin
                       rpn:=rpn+' '+stack[top];
                       dec(top);
                     end;
                   inc(top);
                   stack[top]:=s[1];
                 end
               else
                 case s[1] of
                     '(':begin inc(top); stack[top]:=s[1]; end;
                     ')':begin
                           while stack[top]<>'(' do
                             begin rpn:=rpn+' '+stack[top]; dec(top); end;
                           dec(top);  { get rid of matching '(' on stack }
                         end;
                 end{case};
        end{while infix>''};

      while top>0 do          { put remainder of operation in RPN str. }
        begin
          rpn:=rpn+' '+stack[top];
          dec(top);
        end;
      infix_to_rpn:=rpn;
    end{infix_to_rpn --------------------------------------------------------};

  var x_var : array[1..9] of real;   { was local to procedure val2 }

  {$S-} { try to make faster be eliminating stack and range checking }

  procedure rpn_eval(rpn:string; var v:real; var err_code:integer);
                                     { was local to procedure val2 }
    var
      stack : array[0..30] of real;
      top   : integer;
      s,s2  : string;
      i,j   : integer;
      r1    : real;
      l1    : longint;

    begin
      top:=0;
      stack[0]:=0;
      err_code:=0;
      v:=0;

      while (rpn>'') and (err_code=0) do
        begin
          i:=1;
          while rpn[i]=' ' do inc(i);                  { parse spaces }
          rpn:=copy(rpn,i,200);

          j:=length(rpn);                              { parse rpn term }
          i:=1;
          while (i<=j) and (rpn[i]>' ') do inc(i);
          s:=copy(rpn,1,i-1);
          rpn:=copy(rpn,i,200);

          if i>2 then   { number }
            begin
              if s[1]='-' then begin j:=-1; s:=copy(s,2,200); end else j:=1;
              case s[1] of
                'F':begin
                      s2:=s[2];
                      if (s[3] in ['0'..'9']) and (length(s)>2) then s2:=s2+s[3];
                      val(s2,i,err_code);
                      r1:=f_var[i];
                    end;
                'X':r1:=x_var[ord(s[2])-48];
                '$':begin val(s,l1,err_code); r1:=l1; end;
                else val(s,r1,err_code);
              end{case};
              inc(top);
              stack[top]:=j*r1;
            end
          else
            if s[1] in ['-','+','/','*','^','&','#','!','m','n','o','p'] then
              begin
                if top>1 then
                  begin
                    dec(top);
                    case s[1] of
                     '-':stack[top]:=stack[top]  - stack[top+1];
                     '+':stack[top]:=stack[top]  + stack[top+1];
                     '/':stack[top]:=stack[top]  / stack[top+1];
                     '*':stack[top]:=stack[top]  * stack[top+1];
                     '^':stack[top]:=pw(stack[top],stack[top+1]);
                     '&':stack[top]:=round(stack[top]) and round(stack[top+1]);
                     '#':stack[top]:=round(stack[top]) or  round(stack[top+1]);
                     '!':stack[top]:=round(stack[top]) xor round(stack[top+1]);
                     'm':stack[top]:=round(stack[top]) mod round(stack[top+1]);  {GLA- 7/11/2009}
                     'n':stack[top]:=round(stack[top]) div round(stack[top+1]);  {GLA- 7/11/2009}
                     'o':stack[top]:=round(stack[top]) shr round(stack[top+1]);  {GLA- 7/11/2009}
                     'p':stack[top]:=round(stack[top]) shl round(stack[top+1]);  {GLA- 7/11/2009}
                    end{case};
                  end
                else error('Eval Needs 2 #''s');
              end{if}
            else

            case s[1] of
              'I':stack[top]:= int(  stack[top]);               { integer     }
              'A':stack[top]:= abs(  stack[top]);               { absolute    }
              'R':stack[top]:= round(stack[top]);               { round       }
              'N':stack[top]:= ln(   stack[top]);               { natural log }
              'E':stack[top]:= exp(  stack[top]);               { exponenial  }
              'L':stack[top]:= ln(   stack[top])/ln(10);        { log base 10 }
              'j':stack[top]:= sqr(  stack[top]);               { square,      GLA- 7/11/2009      }
              'i':stack[top]:= sqrt( stack[top]);               { square root, GLA- 7/11/2009 }
              'S':stack[top]:= sin(  stack[top]);               { sine        }
              'C':stack[top]:= cos(  stack[top]);               { cosine      }
              'T':stack[top]:= sin(  stack[top])/cos(stack[top]);{ tangant    }

              's':if stack[top]=1.0 then stack[top]:=pi/2       { arc sine    }
                  else stack[top]:=arctan(stack[top]/sqrt(1-sqr(stack[top])));
              'c':if stack[top]=0.0 then stack[top]:=pi/2       { arc cosine  }
                  else begin
                         r1:=arctan(sqrt(1-sqr(stack[top]))/stack[top]);
                         if stack[top]<0.0 then stack[top]:=r1+pi
                         else stack[top]:=r1;
                       end;
              't':stack[top]:=arctan(stack[top]);               { arc tangant }
              else
                inc(top);
                val(s,stack[top],err_code);
            end{case};

        end{while};

      if err_code=0 then
        begin if top=1 then v:=stack[1] else err_code:=1; end;
    end{rpn_eval ------------------------------------------------------------};

{$S+}

procedure val2(infix:string; var v:real; var err_code:integer);

    var i,j,e    : integer;
        rpn      : string;
        ln1,ln2  : string;
        register : integer;
        sto_flg  : boolean;
        rcl_flg  : boolean;

    type sto_str_type = string[2];  { indicate to store/recall rpn string }
    function get_storage_flag(sto_str_indicator:sto_str_type):boolean;
      begin                         { get storage register }
        i:=pos(sto_str_indicator,infix);
        get_storage_flag:=(i>0);
        if i>0 then delete(infix,i,2);
      end;

    procedure set_x_vars;         { parse out variables (x1,x2,x3) ect. }
      begin
        i:=pos('(',ln1);
        j:=pos(')',ln1);
        if i*j=0 then exit;

        { X# var's exist between "()" so now set the X# variables }
        ln1:=copy(ln1,i+1,j-i-1);
        i:=1;
        repeat
          ln2:=parse(ln1,i,',');  { parse ln1 between "," markes into ln2 }

          if ln2[1]='F' then  { set X# var to an existing f_var value }
            begin
              val(copy(ln2,2,10),j,e);
              x_var[i]:=f_var[j];
            end
          else if ln2='PI' then x_var[i]:=pi
               else if ln2>'' then val(ln2,x_var[i],e);

               { can not use equation type parameters like 1/2 or 2*f1 }
          inc(i);
        until ln2='';
      end;

    procedure expression_err;
      begin
        writeln('EVAL Error: Invalid expression on Left: ',ln1,^G);
        err_code:=1;
      end;

    begin { val2 }
      macro_replace(eval_macro_rec,infix);

      caps(infix);                                { capitalize infix string }
      for i:=length(infix) downto 1 do            { delete spaces }
        if infix[i]=' ' then delete(infix,i,1);

      sto_flg:=get_storage_flag('|S');            { check for store  RPN str }
      rcl_flg:=get_storage_flag('|R');            { check for recall RPN str }

{----------------------------------------------------------------------------}
      i:=pos('=',infix);
      if i>0 then                         { parse both sides of the "=" sign }
        begin
          ln1  :=copy(infix,  1,i-1); { ln1 is the left side of the "=" sign }
          infix:=copy(infix,i+1,200); { infix is the right side of  "=" sign }
        end
      else ln1:=infix;

      fillchar(x_var[1],sizeof(x_var),0);    { initialize X# variables  }
      register:=-1;
      if (ln1[1]='F') and (rcl_flg or (i>1)) then
        begin                                 { get storage register     }
          ln2:=copy(ln1,2,50);                { parse out  "F" character }
          i:=pos('(',ln2);                    { up to "("; #(  ##(  ###( }
          if i>0 then ln2:=copy(ln2,1,i-1);   { now we have multi # char.}
          if ln2>'' then val(ln2,register,e); { set register if exist    }
          if e>0 then  begin expression_err; exit; end;
          set_x_vars;
        end
      else if i>0 then begin expression_err; exit; end;

      if rcl_flg then rpn:=rpn_str[register]      { recall  rpn string }
      else            rpn:=infix_to_rpn(infix);   { set new rpn string }

      if rpn>'' then
        begin
          rpn_eval(rpn,v,err_code);
          if err_code=0 then
            begin
             if  register in [0..99] then f_var[register]:=v;
             if (register in [0..10]) and sto_flg then rpn_str[register]:=rpn;
            end;
        end
      else begin writeln('RPN Error: ',rpn,^G); err_code:=1; end;
    end{proc. val2};

procedure val3(register:integer; var v:real; var err_code:integer);
  begin     { by pass overhead in eval2 by using a stored RPN equation }
            { must 1st call val2 to store string with syntax |S1=f10/3 }
     rpn_eval( rpn_str[register], v, err_code);
  end;

begin
   fillchar(f_var[0],sizeof(f_var),0);
   macro_rec_init(eval_macro_rec,@eval_macros);
end.

