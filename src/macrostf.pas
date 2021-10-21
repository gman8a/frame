unit macrostf;

{ by Gary Argraves - 1996,
  revised for SuSE Linux 7.0 and GNU Pascal for usage with Netbook 2003.0504
}

interface

type       macro_type      = string[30];
     large_macro_arr_type  = array[1..200] of ^macro_type;
           macro_arr_ptr   = ^large_macro_arr_type;

     macro_rec_type = record
                        mac_arr      : macro_arr_ptr;
                        mac_cnt      : integer;
                        mac_max      : integer; { no.of mac.allocated on heap }
                        mac_mark     : array[0..5] of integer;
                        mac_mark_cnt : integer;
                        mac_search_all_flag : boolean;
                        release_protection_level : integer;
                      end;

procedure macro_rec_init(var mac_rec: macro_rec_type; macro_arr:macro_arr_ptr);
procedure macro_mark    (var mac_rec: macro_rec_type);
procedure macro_release (var mac_rec: macro_rec_type);
procedure macro_add     (var mac_rec: macro_rec_type;      s : string);
procedure macro_replace (    mac_rec: macro_rec_type; var  s : string);
procedure macro_show    (    mac_rec: macro_rec_type);

procedure   macro_set_release_protection_level(var mac_rec: macro_rec_type);
procedure macro_reset_release_protection_level(var mac_rec: macro_rec_type);
procedure macro_set_search_all_flag(var mac_rec: macro_rec_type; f:boolean);

implementation

uses basic;

{$S-} { try to make faster be eliminating stack and range checking }
{$R-}

  procedure macro_mark;
    begin
      with mac_rec do
        begin
          mac_mark_cnt:=mini(5,mac_mark_cnt+1);
          mac_mark[mac_mark_cnt]:=mac_cnt;
        end;
    end;

  procedure macro_release;  { emac_marker[0] is always mark zero }
    begin
      with mac_rec do
        begin
          mac_cnt:=maxi( mac_mark[mac_mark_cnt],release_protection_level);
          mac_mark_cnt:=maxi(0,mac_mark_cnt-1);
        end;
    end;

  procedure macro_set_release_protection_level;
    begin
      with mac_rec do release_protection_level := mac_cnt;
    end;
  procedure macro_reset_release_protection_level;
    begin
      with mac_rec do release_protection_level := 0;
    end;

  procedure macro_set_search_all_flag;
    begin mac_rec.mac_search_all_flag:=f; end;

procedure macro_rec_init;
  begin
    fillchar(mac_rec, sizeof(mac_rec), 0);
    mac_rec.mac_arr := macro_arr;
  end;

procedure macro_show;
  var i:integer;
      f:text;
  begin
    assign(f,'macros.txt'); rewrite(f);
    with mac_rec do
      for i:=1 to mac_cnt do
        begin
          writeln(  i:3,' ':4,mac_arr^[i]^);
          writeln(f,i:3,' ':4,mac_arr^[i]^);
        end;
     close(f);
  end;

function mac_begin_no(mac_rec: macro_rec_type):integer;
  begin  { start search for macros or collisions from MARK of 1st macro }
    with mac_rec do
      if mac_search_all_flag then mac_begin_no:=1
      else mac_begin_no:=mac_mark[mac_mark_cnt]+1;
  end;

procedure macro_replace;

    var i,l,m,_pos   : integer;
        ln2,ln3 : string[30];

    procedure last_replacement_pos;
      begin
        l:=pos('"',s);                   { or printed replacements }
        if l=0 then l:=pos('''',s);      { no quoated replacements }
        if l=0 then l:=pos('?',s);       { or quested replacements }
        if l=0 then l:=pos(';',s);       { or comment replacements }
        if l=0 then l:=100;              { else replace accross entire string }
      end;

    var repl_cnt : integer;

  begin
    repeat { de-referance nested macros }
     repl_cnt:=0;
     trimleading(s);
     last_replacement_pos;

     with mac_rec do     { only allow macro replacement from last mark on }
       for i:= mac_begin_no(mac_rec) to mac_cnt do
         begin
           m   := pos('=',mac_arr^[i]^);         { parameter substitutions }
           ln2 := copy(mac_arr^[i]^,1,m-1);      { search string }
           ln3 := copy(mac_arr^[i]^,m+1,30);     { replacement string }

           _pos:=pos(ln2,s); { rev. for GNU Pascal }
           while ( (_pos>0) and (_pos<l) ) do
             begin
               m:=_pos;
               delete(s,m,length(ln2));
               insert(ln3,s,m);
               inc(repl_cnt);          { count the number of macros replaced }
               last_replacement_pos;
               _pos:=pos(ln2,s);
             end;
         end;
    until repl_cnt=0;
  end;

procedure reorder_macros(var mac_rec: macro_rec_type);
   var   i,j : integer;          { to prevent phrase overlaping }
         p   : pointer;
  begin
    with mac_rec do
      for i:=1 to mac_cnt-1 do  { sort with brut force }
        for j:=i+1 to mac_cnt do
          if pos('=',mac_arr^[i]^) < pos('=',mac_arr^[j]^)  then { swap }
            begin
               p           := mac_arr^[i];
               mac_arr^[i] := mac_arr^[j];
               mac_arr^[j] := p;
            end;
  end;

procedure error(s:string); begin writeln('Error:' ,s); halt(1);  end;

procedure macro_add;

  var phrase,replacement : macro_type;

  procedure get_1st_phrase(s: string); { meta value str }
    { Uses to find macro phrase collisions or phrase within other phrases }
    var i   : integer;
        ln2 : string[30];
    begin
       phrase:='';
       replacement:='';
       trimleading(s);
       with mac_rec do                                { macro substitutions }
         for i:=mac_begin_no(mac_rec) to mac_cnt do
           begin
             ln2:=parse(mac_arr^[i]^,1,'=');             { search string }
             if pos(ln2,s)>0 then
               begin
                 phrase:=ln2;
                 replacement:=parse(mac_arr^[i]^,2,'='); { replacement string }
                 break;
              end;
           end;
    end;

  var i,j,k              : integer;
      ln1,ln2,ln3,ln4    : string[30];

  procedure add;
   begin
     with mac_rec do
       begin                  { add the macro }
         inc(mac_cnt);
         if mac_cnt > mac_max then new(mac_arr^[mac_cnt]);
         mac_arr^[mac_cnt]^:= ln4 + '=' + ln3;
         mac_max:=maxi(mac_max,mac_cnt);
       end;
     reorder_macros(mac_rec);
   end;

  begin                                      { EVAL_MACRO   }
    trimleading(s);  { expand multi macro sting to 1 macro per array entry.  }

    j:=1;            { this will allow for fast replacement during execution }
    repeat                       { multiple macros per storage string }
      ln1:=parse(s,j,':');       { get a single macro }
      if ln1>'' then
        begin
          ln2:=parse(ln1,1,'=');  { search string }
          ln3:=parse(ln1,2,'=');  { replacement string }
          k:=1;
          repeat
            ln4 := parse(ln2,k,',');  { multiple search macro }
            if ln4>'' then
              begin
                get_1st_phrase(ln4);

                if replacement>'' then
                  begin
                    if ln4=phrase then
                      begin
                        if ln3=replacement then
                          writeln('Warning, duplicate macro: ',ln4,'=',ln3)
                        else error(' Can NOT Re-define Macro: '+ln4)
                      end
                    else add; { subset or Overlapping macro's are NOW allowed }
                  end
                else add;
              end;
            inc(k);
          until ln4='';
        end;
      inc(j);
    until ln1='';
  end;


end.

