type subst_str_type = string[3];

procedure subst_no(c:subst_str_type; n:real);
  var  f,f2    : integer;
       i,j,e   : integer;
       ln2,ln3 : string;
  begin                          { places last digit at last % mark pos. }

    i:=pos('%'+c,ln1);           { is the math expresion result requested }
    if i=0 then exit;

    j:=i+length(c);
    if c[length(c)] in ['%',':'] then dec(j); { special case, %v% or %v:8:2% }

    ln2:='';
    while j < length(ln1) do     { get subst. string }
      begin
        inc(j);
        if ln1[j]='%' then break;
        ln2:= ln2 + ln1[j];
      end;

    ln3:=copy(ln1,j+1,200);    { save after %v% mark }
    delete(ln1,i,200);         { delete %v% mark }
    trimtrailing(ln1);

    val(parse(ln2,2,':'),f, e);
    if e>0 then val(parse(field_mod,1,':'),f,e);
    if e>0 then f:=6;

    val(parse(ln2,3,':'),f2,e);
    if e>0 then val(parse(field_mod,2,':'),f2,e);
    if e>0 then f2:=6;

    if f=f2 then str(n:f,ln2) else str(n:f:f2,ln2);

    ln1:=ln1 + rpt(' ',j-length(ln1)-length(ln2)) + ln2 + ln3;
  end;

procedure subst_last_eval;  { Subst for LAST EVALuation Only }

  procedure do_it;          { allow term %v% for last evaluation }
    begin                   { do not subst for type %v1% }
      if pos('%v',ln1) + pos('%V',ln1) = 0 then exit;
      subst_no('v:',value);
      subst_no('v%',value);
      subst_no('V:',value);
      subst_no('V%',value);
    end;

  begin
    do_it;
    do_it;
  end;

procedure subst_f_vars;
    var i     : integer;
        s_str : string[2];    { for sum substitution accumulator number }

        procedure do_it;
          begin
            if pos('%v',ln1) + pos('%V',ln1) > 0 then
              begin
                subst_no('v'+s_str,f_var[i]);
                subst_no('V'+s_str,f_var[i]);
              end;
          end;

    begin
      for i:=99 downto 0 do               { look for EVAL's and SUM quests }
        begin
          str(i:1,s_str);
          do_it;           { in case same f-var is repeated on single line }
          do_it;
          do_it;
        end;
    end;

procedure subst_sums;
  var s_str : string[2];
      i     : integer;


  procedure do_it;            { allow terms %s% or s:10:0%   for %s0%  }
    begin                     { Subst for LAST EVALuation Only }
                              { do not subst for type %s1% }

      if pos('%s',ln1) + pos('%S',ln1) = 0 then exit;
      if pos('s:',ln1)>0 then subst_no('s:',sum[0]);
      if pos('s%',ln1)>0 then subst_no('s%',sum[0]);
      if pos('S:',ln1)>0 then subst_no('S:',sum[0]);
      if pos('S%',ln1)>0 then subst_no('S%',sum[0]);
    end;

  begin
    do_it;
    do_it;

    for i:=0 to 9 do               { for sum substitution accumulator number }
      begin
        if pos('%s',ln1) + pos('%S',ln1) = 0 then break;
        str(i:1,s_str);
        subst_no('s'+s_str,sum[i]);
        subst_no('S'+s_str,sum[i]);
        subst_no('s'+s_str,sum[i]);  { allow 2 sums per line for check book look }
        subst_no('S'+s_str,sum[i]);
      end;
  end;

procedure subst_balances;
  var i     : integer;
      s_str : string[2];    { for sum substitution accumulator number }
  begin
    for i:=0 to 9 do
      begin
        str(i:1,s_str);
        if (balance_col[i] > 0) and
           (length(ln1)+4 <= balance_col[i] ) then
           ln1:=ln1 + rpt(' ',balance_col[i]-length(ln1)-4) + '%s'+s_str+'%' ;
      end;
    subst_sums;   { replace numeric value for requested accumulators }
  end;

procedure sum_columns;
  var
    i,e     : integer;
    r       : real;
    ln2,ln3 : string[128];

  begin
    for i:=0 to 9 do
      if sum_column[i] > 0 then
        begin
          ln2:=copy(ln1,sum_column[i],200);
          trimleading(ln2);
          ln2:=parse(ln2,1,' ');
          val(ln2,r,e);

          if e=0 then
            begin
              sum[i] := sum[i] + r;
              str(i,ln3);
              str(sum[i],ln2);
              val2('F'+ln3+'='+ln2, r, e);
            end;
        end;
  end;

