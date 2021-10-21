program frame_text;  // frame-up text files and resolve mathmatical statements

{ by Gary Argraves - 1996,
  revised for SuSE Linux 7.0 and GNU Pascal for usage with Netbook 2003.0504

	TODO many characters are from code-page 437; see URL https://en.wikipedia.org/wiki/Code_page_437
		Try and adapt output so use this char. set.

	Code page 437 (CCSID 437) is the character set of the original IBM PC (personal computer).[2] It is also known as CP437, OEM-US, OEM 437,[3] PC-8,[4] or DOS Latin US.[5] 
	The set includes all printable ASCII characters, extended codes for accented letters (diacritics), some Greek letters, icons, and line-drawing symbols. 
	It is sometimes referred to as the "OEM font" or "high ASCII", or as "extended ASCII"[4] (one of many mutually incompatible ASCII extensions).

	This character set remains the primary set in the core of any EGA and VGA-compatible graphics card. 
	As such, text shown when a PC reboots, before fonts can be loaded and rendered, is typically rendered using this character set.[note 1] 
	Many file formats developed at the time of the IBM PC are based on code page 437 as well.

	https://stackoverflow.com/questions/40953596/linux-console-how-to-change-the-codepage-to-dos-cp437
	https://github.com/keaston/cp437

	this works:
		cat frame_help.txt|./frame|iconv --from-code=IBM437 --to-code=UTF-8
		cat BEAM.FRM|./frame|iconv --from-code=IBM437 --to-code=UTF-8

}

{$mode tp} // put Free Pascal Complier (FPS) turbo pascal (tp) mode, can be: fpc,tp,delphi,objfcp,macfcp
			// https://www.freepascal.org/docs-html/prog/progsu104.html#x112-1130001.3.21

{$m $B000,$4000,$4000}

{ $N+}  //  un-supported in FPC  1.3.23 $N : Numeric processing
		// This switch is recognized for Turbo Pascal compatibility, but is otherwise ignored, since the compiler always uses the coprocessor for floating point mathematics.

{ $E+}   //  $E : Emulation of coprocessor

{ $FPUTYPE LIBGCC} // arm: LIBGCC, FPA, FPA10, FPA11,VFP.
				//https://www.freepascal.org/docs-html/prog/progsu23.html#x30-290001.2.23

{$V-}   // Var-string checking
		// https://www.freepascal.org/docs-html/prog/progsu77.html#x84-830001.2.77

//uses sysutils;
//uses basic, macrostf, evalstuf;

uses baseunix, dos, basic, macrostf, evalstuf;

const line_length: integer = 78; // default is 78 for letter size page output.

procedure replace_all(search: string; replace: string; s: string);
var  j,sl: Integer;
begin
  sl:=length(search); // search str length
  
  if pos(search, s)>0 then // test if any occurance
    for j:=length(s) downto 1 do // do in reverse to avoid replacement to already replaced.
      if copy(s, j, sl) = search then 
        begin
            delete(s, j, sl);
            insert(replace, s, j);
        end;
end;

function amt_str(a:real):string;

    function say_amt(a:integer):string;

      const evl1 : array[1..19] of string[9] =
                    ('ONE',    'TWO',      'THREE',    'FOUR',    'FIVE',
                     'SIX',    'SEVEN',    'EIGHT',    'NINE',    'TEN',
                     'ELEVEN', 'TWELVE',   'THIRTEEN', 'FOURTEEN','FIFTEEN',
                     'SIXTEEN','SEVENTEEN','EIGHTEEN', 'NINETEEN');

            evl2 : array[2..9] of string[7] =
                    ('TWENTY', 'THIRTY',  'FORTY',  'FIFTY',
                     'SIXTY',  'SEVENTY', 'EIGHTY', 'NINETY');

        var ln1 : string;
            b   : integer;

      begin
        ln1:='';
        if a>100 then begin b:=a div 100; a:=a-b*100; ln1:=evl1[b]+' HUNDRED ';
                      end;
        case a of
             1..19:ln1:=ln1+evl1[a]+' ';
            20..99:begin    b:=a div 10;  a:=a-b*10;  ln1:=ln1+evl2[b]+' ';
                            if a in [1..9]  then      ln1:=ln1+evl1[a]+' ';
                   end;
        end{case};
        say_amt:=ln1;
      end;

  var a1 ,at,ah,ad,ac : longint;
      ln1 : string;
      ln2 : string[2];

  begin
    a1:=round(a*100);
    at:=a1 div 100000;
    ah:=(a1-100000*at) div 10000;
    ad:=(a1-100000*at-10000*ah) div 100;
    ac:=a1-100000*at-10000*ah-100*ad;
    str(ac:2,ln2); if ln2[1]=' ' then ln2[1]:='0';

    ln1:='';
    if at>0 then ln1:=say_amt(at)+'THOUSAND ';
    if ah>0 then ln1:=ln1+say_amt(ah)+'HUNDRED ';
    if ad>0 then ln1:=ln1+say_amt(ad);
    if ln1='' then ln1:='ZERO ';
    ln1:='**'+ln1 + 'DOLLARS AND '+ln2+' CENTS**';
    amt_str:=ln1;
  end;

type  str3     = string[3];
const out_cnt  : integer = 0;

procedure write_ln(ln1:string);  begin inc(out_cnt); writeln(ln1);   end;
procedure write_graf_ln(c:str3); begin write_ln(c[1]+rpt(c[2],line_length-1)+c[3]); end;

var   ln1         :  string;

const
    field_mod : string[6] = '1:0'; { default output field modifiers }

    sum_column  :  array[0..9] of integer = (0,0,0,0,0,0,0,0,0,0);
    sum         :  array[0..9] of real    = (0,0,0,0,0,0,0,0,0,0);
    balance_col :  array[0..9] of integer = (0,0,0,0,0,0,0,0,0,0);
                 { display balance or sum in column }

    value       :  real    = 0;       { last eval value calculated }
    eval_flag   :  boolean = true;

    repeat_cnt  :  integer = 0;

    comment_wrt_del : string[20] = '';  { write comment data after delimeter }
    comment_occur   : integer    = 2;   { write comment parse occurance      }
    truncate_len    : integer    = 255; { to truncate input lines on output  }

    eec             : char       = '~'; { Expand_Eval_Char }

const
   dot_codes = 'TMBtmbPpLlIiCcEeSsDdVvFfGg:ZzWwXxOo"_Uu=Yy.QqRr';
             { TOP       line             .T or .t
               MIDDLE    line             .M or .m
               BOTTOM    line             .B or .b
               PAD       spaces           .P 5   5 line of white space

               Look      of characters    .L 0/1
               Include   frame file       .i Filename
               Comment   ignore line      .c math string may be evaluated here
               End       session          .e end the frame session
               Sum       columns          .s 50  sum number in column 50
               Define    macros           .d unity=1
               View      macros           .v view/show all macros definitions
               zField    modifiers        .z 8:2 default field modifier

               %s:12:2%                   display running column sum
               %v:12:2%                   display last math evaluation

             }

   line_set  : integer = 0;

   side      : array[0..9] of char = ('³','º',' ','|','|',
                                      ' ',' ',' ',' ',' ' { GLA - 2003-6-30 }
                                     );

   const no_of_line_sets : integer = 5; { GLA - 2003-6-30 }

   frame : array[0..4, 1..6] of str3 = (
                ('ÕÍ¸',    { 0 }
                 'ÆÍµ',
                 'ÔÍ¾',
                 'ÚÄ¿',
                 'ÃÄ´',
                 'ÀÄÙ'),

                ('ÉÍ»',    { 1 }
                 'ÌÍ¹',
                 'ÈÍ¼',
                 'ÖÄ·',
                 'ÇÄ¶',
                 'ÓÄ½'),

                ('   ',    { 2 }
                 '   ',
                 '   ',
                 '   ',
                 '   ',
                 '   '),

                ('+=+',    { 3 }
                 '+=+',
                 '+=+',
                 '+-+',
                 '+-+',
                 '+-+'),

                ('|=|',    { 4 }
                 '|=|',
                 '|=|',
                 '|-|',
                 '|-|',
                 '|_|')
                );


 procedure alt_line_set;
    var i,e:integer;
    begin val(ln1,i,e); line_set:= i mod 10; end;

  procedure pad;  { send blank lines to output stream }
    var i,e:integer;
    begin
        val(ln1,i,e);
        i:= i + out_cnt;
        while out_cnt < i do { output a blank line }
          begin write_graf_ln(side[line_set]+' '+side[line_set]); end;
    end;

  function frame_line(ln1:string):string;
    var i      : integer;
        ln_len : integer;
        ln2    : string;
    begin
      trimtrailing(ln1);

      { note: this tab expansion is NOT correct. GLA- 2003-6-30}
      while pos(^I,ln1)>0 do { expand tabs }
        begin i:=pos(^I,ln1);
              insert('        ',ln1,i);
              delete(ln1,i+8,1);
        end;

      ln2:=ln1;
      ln_len:=line_length;
      while pos(char(27),ln2) > 0 do  { Count ESCape Sequences Characters }
         begin
            ln2    := copy(ln2, pos(char(27),ln2), 200);
            ln_len := ln_len +  pos('!',ln2) - 1;
            ln2    := copy(ln2, pos('!',ln2)+1, 200) ;
            delete(ln1,pos('!',ln1),1);
         end;

      if line_set < no_of_line_sets then
        begin
          ln1:= side[line_set] + ln1;
          ln1:= ln1 + rpt(' ',ln_len-length(ln1)) + side[line_set];
        end;

      if pos('{',ln1)>0 then
            frame_line := copy(ln1,1,pos('{',ln1)-2) + side[line_set]
      else  frame_line := ln1;
    end;

function dot:char;
    var c1:string[1];
    begin
      c1:=' ';
      if pos('.',ln1)=1 then
        begin
          c1:=copy(ln1,2,1);
          ln1:=copy(ln1,3,200);
          trimleading(ln1);

          { if dot command has more than one parameter }

          if not (c1[1] in ['d','D',      { Define Macro }
                            'G','g',      { Goto Label   }
                            'S','s',      { Sum column   }
                            'C','c',      { Comments for write thur }
                            'I','i',      { Include file , block }
                            '"',          { dot command write thru  }
                            'U','u','_',  { Underscore / break line }
                            '=',          { match command }
                            'R','r'       { Run/Shell to external command }
                           ])
             then
             ln1:=parse(ln1,1,' ');
        end;

      dot:=c1[1];
    end;

procedure eval_check(c:char; expand:boolean); { evaluate a math string     }
    var   i,j,k,e : integer;
          ln2,ln3 : string;
  begin
    i:=pos(c,ln1);                    { is there a math expression }
    if i=0 then exit;                 { no macros in line }

    j:=i;                             { 1st pos. of unexpanded macro }
    ln2:='';
    ln1[j]:=' ';
    while j < length(ln1) do
      begin
        inc(j);
        if ln1[j]=c then begin ln1[j]:=' '; break; end;
        ln2:= ln2 + ln1[j];
      end;
    val2(ln2,value,e);

    if expand then
      begin
        k:=1;   { count spaces in after~}
        while (length(ln2)>k) and (ln2[k]=' ') do inc(k);

        macro_replace(eval_macro_rec,ln2); { get expanded macro string }
        ln3:=copy(ln1,j+1,200);
        delete(ln1,i,200);
        ln1:= ln1 + rpt(' ',k)              +  ln2;
        ln1:= ln1 + rpt(' ',j-length(ln1))  +  ln3;
      end;
  end;

procedure date_time_check;
  var i : integer;
  begin
    i:=pos('%d%',ln1);
    if i>0 then begin insert(date,ln1,i); delete(ln1,i+17,3); end;

    i:=pos('%t%',ln1);
    if i>0 then begin insert(time,ln1,i); delete(ln1,i+7,3); end;
  end;

procedure dollar_cent_check;
  var i : integer;
  begin
    i:=pos('%$%',ln1);
    if i>0 then begin delete(ln1,i,3); insert(amt_str(value),ln1,i); end;
  end;

{$i frm-sum}

procedure delete_dual_space(var ln1:string);
  begin  { no double space;  parse on space }
    while pos('  ',ln1)>0 do delete(ln1,pos('  ',ln1),1);
  end;

procedure maintain_columns_pos(non_expand_marker: integer);
  begin

    if non_expand_marker = 0 then exit;

    if pos('}',ln1) > non_expand_marker then
      while pos('}',ln1) <> non_expand_marker do delete(ln1,pos('}',ln1)-1,1)

    {          not required if subst.length is < macro name length }
    else
      while pos('}',ln1) <> non_expand_marker do insert(' ',ln1,pos('}',ln1)-1);


    ln1[pos('}',ln1)]:=' ';
  end;

procedure eval_chk_and_subst;
  begin
    eval_check('`',false);  { do NOT expand macros }
    eval_check(eec,true);   { expand macros }
    subst_last_eval;  { replace numeric value for requested Last eval }
  end;

{-----------------------------------------------------------------------------}
procedure process_file(fn,blk: string);
{-----------------------------------------------------------------------------}

type word_rec =  record word:string[3]; sub:string[45] end;
var
    break_col  : integer;     { these vars got here for recursive action }
    break_flag : boolean;
    break_len  : integer;
    break_fn   : string[30];
    break_blk1 : string[30];
    break_blk2 : string[30];
    break_blk3 : string[30];
    last_break : string[50];

    match_col  : integer;
    match_flag : boolean;
    match_fn   : string[30];
    match_blk1 : string[30];
    match_blk2 : string[30];
    match      : string[30];
    post_match : boolean;
    word_sub   : array[1..10] of word_rec; { word substitude,recursive nest }

  var  dot_code  : integer;
       i,e       : integer;
       f         : text;
       r         : real;
       rpt_ln    : string;
       s_str     : string[2];    { for sum substitution accumulator number }
       data_flag : boolean;
       ln2,ln3   : string;       { to save global ln1 thur recursive break }

    function end_of_file:boolean;   { either file input or standard input }
      begin
        if fn='' then end_of_file := eof(input)
        else          end_of_file := eof(f);
      end;


    procedure find_label(blk:string);
      var ln1 : string;

      function start_of_blk:boolean;
        begin
          start_of_blk:=(blk>'') and
                      ((pos( '.'+blk,ln1)=1) or (pos('..'+blk,ln1)=1));
        end;

      begin
        if blk > '' then                 { look for start of frame block }
          begin
            if fn>'' then
              while not eof(f) do
                begin readln(f,ln1);  if start_of_blk then break; end
            else
              while not eof(input) do
                begin readln(ln1);    if start_of_blk then break; end
          end;
      end;

     function start_of_blk:boolean;
        begin
          start_of_blk:=(blk>'') and
                      ((pos( '.'+blk,ln1)=1) or (pos('..'+blk,ln1)=1));
        end;

    function end_of_blk:boolean; begin end_of_blk:=start_of_blk; end;

    procedure read_data;  { get input line and save data for repeat }
      var i   : integer;
          ln2 : string;
      begin

        if fn='' then readln(ln1) else readln(f,ln1);
        i := pos('&&',ln1);
        if ((i>0) and (i=length(ln1)-1)) then       { append the next line }
          begin                { this is a custom function for gMenu or MM }
            if fn='' then readln(ln2) else readln(f,ln2);
            ln1 := copy(ln1,1,i-1) + ln2; { exclude the append line marker && }
          end;

        data_flag:=true;
        rpt_ln   :=ln1;
      end;

    procedure process_mid_breaks;  { --- Break LOGIC for middle of file ---- }
      begin
        if break_flag then
          begin
            ln2:=ln1;
            if (last_break>'') and
               (last_break <> copy(ln1,break_col,break_len)) then
              process_file(break_fn,break_blk2);
            last_break:=copy(ln2,break_col,break_len);
            ln1:=ln2;
          end;
      end;

    procedure process_matches;  { --- Match LOGIC  ---- }
      var i : integer;
      begin
        post_match:=false;
        if match_flag then
          begin
            ln2:=ln1;
            i:=pos(match,ln1);
            if i>0 then
              if (match_col=0) or (match_col=i) then
                begin
                  process_file(match_fn,match_blk1);
                  post_match:=true;
                end;
            ln1:=ln2;
          end;
      end;


procedure process_inner_repeat_loop;
  var fn2,fn3 : string;
      non_expand_marker: integer; { keep line spacing to the right of marker }
      p1 : integer;
      ii : integer;
      outfile:text;

  begin
    repeat
      case data_flag of
         false: read_data;
         true : if repeat_cnt < 1 then read_data
                else begin ln1:=rpt_ln; dec(repeat_cnt); end;
      end{case};

      ln1:=copy(ln1,1,truncate_len);

      non_expand_marker := pos('}',ln1);

      for ii:=1 to 10 do           { substitude words in block calls }
        while   pos('%'+ word_sub[ii].word,ln1) > 0 do
          begin
            p1:=pos('%'+ word_sub[ii].word,ln1);
            delete(ln1,p1,length(word_sub[ii].word)+1);
            insert(word_sub[ii].sub,ln1,p1);
          end;

      while pos('®',ln1)>0 do  { substitute file I/O redirection char. }
        ln1[pos('®',ln1)]:='<';
        {begin ii:=pos('®',ln1); delete(ln1,ii,1); insert('<<',ln1,ii); end;}
      while pos('¯',ln1)>0 do  { substitute file I/O redirection char. }
        ln1[pos('¯',ln1)]:='>';
        {begin ii:=pos('¯',ln1); delete(ln1,ii,1); insert('>>',ln1,ii); end;}

      process_matches;
      process_mid_breaks;

      if end_of_blk then break;  { exit on end_of_block }

      if eval_flag then           { in case ~~ marks are used for PIK program }
        begin
          eval_chk_and_subst;     { allow only 4 eval. calc's per line }
          eval_chk_and_subst;
          eval_chk_and_subst;
          eval_chk_and_subst;
        end{if};

      subst_last_eval;  { replace numeric value for requested Last eval }
      subst_f_vars;     { replace numeric value for requested F_vars    }

      maintain_columns_pos(non_expand_marker);

      if pos('.',ln1)<>1 then { do NOT sum comments }
        sum_columns;      { sum ALL accumulators as requested }

      subst_sums;       { replace numeric value for requested accumulators }
      subst_balances;   { replace numeric value for AUTO requested accum.  }

      date_time_check;
      dollar_cent_check;

      dot_code:=pos(dot,dot_codes);
      case dot_code of
           1..6: if line_set < no_of_line_sets then { GLA - 2003-6-30 }
                   write_graf_ln( frame[line_set,dot_code] ); { make Top Bottom or Middle lines }
            7,8: pad;                    { pad blank lines }
           9,10: alt_line_set;

          11,12: begin                   { Recursive Include }
                   ln3:=ln1;
                   delete_dual_space(ln3);
                   fn2:=parse(ln3,1,' ');
                   if fn2='=' then fn2:=fn;
                   process_file( fn2, parse(ln3,2,' ') );
                 end;

          13,14: if comment_wrt_del>'' then  {.Comment w/write thur delimeter}
                   write_ln(frame_line(' '+
                                       parse(ln1,comment_occur,comment_wrt_del)
                                      ));

          15,16: halt(0);                { .E Normal ending }

          17,18: begin                   { .S # [# #]  *** .SUM ***  }
                   delete_dual_space(ln1);
                   s_str:=parse(ln1,1,' ');
                   val(s_str,i,e);
                   sum[i]:=0;                       { reset accumulator }
                   val2('F'+s_str+'=0',r,e);        { and mirror image  }
                   val(parse(ln1,2,' '), sum_column[i],e);
                   val(parse(ln1,3,' '),balance_col[i],e);
                 end;
          19,20: begin
                   {caps(ln1);}
                   macro_add(eval_macro_rec, parse(ln1,1,';') );
                 end;
          21,22: macro_show( eval_macro_rec);

          23,24: if ln1='' then write(^L)         { output a FORMFEED char. }
                 else           write(ln1);       { output other control    }

          25,26: {if fn>'' then }        { GOTO to label of type .:LABEL_NAME }
                   begin                 { does NOT work on DOS PIPE file }

                     if fn>'' then  { will scan down only on pipes }
                       begin
                         reset(f);
                         find_label(blk);   { continue w/blk we are in }
                       end;

                     if value<0 then e:=1 else if value=0 then e:=2 else e:=3;
                     delete_dual_space(ln1);
                     find_label(':'+parse(ln1,e,' '));
                   end;

             27: begin end;                       { .:Label }
          28,29: field_mod:=ln1;                  { default FIELD MODifiers }
          30,31,                            { .x White space, Compatibility }
          32,33: begin                      { .w White Space w/o framing    }
                   val(parse(ln1,1,' '),i,e);
                   while i>0 do begin dec(i); writeln; end;
                 end;
          34,35: eval_flag:=ln1='+';                   { toggle EVAL ON/OFF }

             36: write_ln(frame_line(' '+ln1)); { ." Write thur dot command }

       37,38,39: begin     { .U ._   Under score sums or  insert Break Lines }
                   delete_dual_space(ln1);
                   val(        parse(ln1,1,' '), break_col,e);
                   val(        parse(ln1,2,' '), break_len,e);
                   break_fn  :=parse(ln1,3,' ');
                   break_blk1:=parse(ln1,4,' ');
                   break_blk2:=parse(ln1,5,' ');
                   break_blk3:=parse(ln1,6,' ');

                   if break_col>0 then process_file(break_fn, break_blk1);
                   break_flag := break_col>0;
                   last_break  := ''; { reset for breaking }
                 end;
             40: begin
                   delete_dual_space(ln1);
                   val(        parse(ln1,1,' '), match_col,e);
                   match     :=parse(ln1,2,' ');
                   match_fn  :=parse(ln1,3,' ');
                   match_blk1:=parse(ln1,4,' ');
                   match_blk2:=parse(ln1,5,' ');
                   match_flag := match>'';
                 end;
          41,42: val(parse(ln1,1,' '),truncate_len,e); { truncate length }

             43: begin end;    { ..BLOCK_NAME pass thur }
          44,45: eec:=ln1[1];  { change the default Eval. delimeter ~ }
          
          46,47: begin
          
				  (*
					DOS example: http://community.freepascal.org:10000/bboards/message?message_id=217912&forum_id=24084
				  
					program Filelist;
					uses Dos;
					var Shell: string;
					begin
					  Shell := GetEnv ('COMSPEC');  // Get path to command shell from environment 
					  // Parameter "/C" instructs the shell to run the command and terminate 
					  Exec(Shell, '/C cls');
					  Exec(Shell, '/C dir > Files.txt');
					end. 
					
					http://freepascal.org/docs-html/rtl/dos/dosexitcode.html         
					Program Example5;
					uses Dos;
					{ Program to demonstrate the Exec and DosExitCode function. }
					
					begin
					{$IFDEF Unix}
					  WriteLn('Executing /bin/ls -la');
					  Exec('/bin/ls','-la');
					{$ELSE}
					  WriteLn('Executing Dir');
					  Exec(GetEnv('COMSPEC'),'/C dir');
					{$ENDIF}
					WriteLn('Program returned with ExitCode ',Lo(DosExitCode));
					end.
				  *)

                 // if fn>'' then { can not shell from re-directed input }
                   begin

					// *** TODO, make work for Linux OS ***


                     //950313NC.LOG:.r command /Cecho   20  Remove rotted areas GREEN}      0      0      0    501      0     501>>misc.sum
                    
					 // was for DOS  OS
                     if (pos('command /Cecho ', ln1)=1) // support this command only from BSCC system
                         and (pos('>>',ln1)>15) then 
                       begin
                
                        fn3 := copy(ln1, pos('>>',ln1)+2, 100); // get filename
                        delete(ln1,1,15); // clear echo out
                        delete(ln1,pos('>>',ln1), 30); // clear output
                        assign(outfile, fn3); append(outfile); writeln(outfile,ln1); close(outfile);
                        
                        (*
                          swapvectors; // http://www.freepascal.org/docs-html/rtl/dos/swapvectors.html
                          delete(ln1, pos('command /C echo', ln1), 10); // command is defaulted here
                          replace_all('"',     '\042', ln1); // escape double quote with octal
                          replace_all(chr(39), '\047', ln1); // escape single quote with octal
                          exec('/bin/sh', '-c ' + chr(39)+ ln1 + chr(39) ); { use sh or bash  }
                          swapvectors;
                        *)
                         
                       end;
                   end;
                 end;

         else write_ln(frame_line(ln1));
      end{case};

      if post_match then process_file(match_fn,match_blk2);

    until repeat_cnt<1;
  end;

  procedure move_to_start_of_block;
    begin
      if fn>'' then                         { recursive file handle }
        begin
          if pos('.',fn)=0 then fn:=fn+'.FRM';
          assign(f,fn);
          {$I-} reset(f); {$I+}
          if IOresult>0 then
            begin writeln('Error: Can NOT find file: ',fn); halt(1); end;
          find_label(blk);
        end
      else
        if blk > '' then  { look for start of frame block on STANDARD INPUT }
          while not eof(input) do
            begin
              readln(ln1);
              if start_of_blk then break;  { exit on end_of_block }
            end;
    end;

  var i1,i2 : integer;

  begin                      { Proc.---- PROCESS_FILE ---- }

    for i1:=1 to 10 do word_sub[i1].word:='ù';  { init word }
    i1 :=0;
    ln3:=ln1;
    while pos('[',ln3) > 0 do
      begin
        inc(i1);
        i2 := pos('[',ln3);
        while (ln3[i2]<>' ') and (i2>1) do dec(i2);
        ln3:=copy(ln3,i2,200);
        word_sub[i1].word:=parse(ln3,1,'[');          delete(ln3,1,pos('[',ln3));
        word_sub[i1].sub :=copy(ln3,1,pos(']',ln3)-1);delete(ln3,1,pos(']',ln3));
      end;


    data_flag  :=false;
    match_flag :=false;
    break_flag :=false;      { set here for recursive file action }

    move_to_start_of_block;

    if not end_of_file then
      repeat
        process_inner_repeat_loop;
        if end_of_blk then break;  { exit on end_of_block }
      until end_of_file;

    if break_flag then process_file(break_fn,break_blk3);
    if fn>'' then close(f);
{-----------------------------------------------------------------------------}
  end{proc};
{-----------------------------------------------------------------------------}

  procedure help;
    begin

      writeln('FRAME  by: Gary Argraves - 9612.15,   (c) KAS Software Collection'^m^j);

      writeln('usage: FRAME [/fInFile /bBlkName /Off /Repeat /C#dStr] [<InFile] [>OutFile]'^m^j);

      write  ('/File     Input file      /Fjob1       File re-direction doesn''t work GOTO Op.'^m^j,
              '/Block    Name to begin   /BUDGET      Any Case Sensitive Name.'^m^j,
              '/OFF      evaluation      /O           turn Math EVALuation off.'^m^j,
              '/REPEAT   1st line        /R3          Repeat the 1st input line # times.'^m^j,
              '/Comment  write-thur      /C2!         PARSED Comments will wrt.thru; _=space.'^m^j^m^j,

              'DOT cmds. alway begin in column 1.'^m^j,
              '=================================='^m^j,
              'Top/Middle/Bottom line    .T or .t     up/low case=double/single horizontal'^m^j,
              'Pad lines                 .P 5         add white space.'^m^j,
              'Look      of characters   .L 0         0/sing.1/dbl.2/off 3&4/+-= horz/vert.'^m^j,
              'Include   FRAME file      .i fn Block  the default ext=.FRM'^m^j,
              'Comment   ignore line     .c hello     but math strings will be evaluated.'^m^j,
              'End       session         .e           end the FRAME session.'^m^j,
              'Sum       accum#,columns  .s 1 50 70   A#1, column, balance output col.& reset.'^m^j,
              'Define    macros          .d ten=10    to be substituted in eval.math str.'^m^j,
              'View      macros          .v           view all macros definitions.'^m^j,
              'OFF       same as /Oñ     .o+          toggle math evaluation on/off.'^m^j,
              'Eval.     char.~          .q #         change default math eval.delimeter.'^m^j,
              'Formfeed  output          .f           output the FF=^L chr. or other ctrl.'^m^j,
              'Goto      Label           .g L1 L2 L3  On last math evaluation < = >  zero.'^m^j,
              'Label     for GOTO cmd    .:L1         NO spaces allowed here.'^m^j,
              'White     space,no frame  .w 5         (also .x) output 5 blank lines.'^m^j,
              'Truncate  lines to length .y 77        no line will be greater than 77 chr.'^m^j,
              'zField    Dflt.Field Mod. .z 8:2       if NOT specified, for EXP.use 1:1 or 2:2'^m^j,
              '"         dotCmd.wrt.thur ." hello     same as NO dot cmd'^m^j,
              'UnderScore or Break Line  .u 20 3 fn B1 B2 B3 break_COL&LEN, incl_FILE, BLKS123'^m^j,
              'Match     str.in col      .= 10 Hello fn B1 B2  then pre-fn:Blk1 post-fn:Blk2'^m^j,
              'Run       shell program   .r dir/w     run any external program'^m^j,
              'SOB/EOB   Start/End_of_Blk  .BUDGET    use to mark Blocks.'^m^j,
              'SOB/EOB   Start/End_of_Blk ..BUDGET    BEST way to mark Blocks.'^m^j,

              'Subst.Sum  registers 0-9  %s1:12:2%   subst.running sum; NO reg.# = #0.'^m^j,
              'Subst.Eval register 0-99  %v98:12:2%  math evaluation w/field modifier.'^m^j,
              'Subst.time  w/o param.    %d% or %t%  current DATE or TIME strings.'^m^j^m^j,
              'Subst.dollar and cents    %$%         current value to money strings.'^m^j^m^j,

              '~1/3~       Math Evaluation strings are enclosed in tildas ~~.'^m^j,
              '`1/3`       Same as above except Macros are NOT expanded.'^m^j,
              '~F1=10*10~  Math Var. F1-F99 may be used to save numbers.'^m^j,
              ' F0 to F9   Evaluation var.F0-F9 ALWAYS mirror the Column SUMS.'^m^j,
              ' TAB char.  ^I are expanded to 8 spaces.'^m^j,
              ' .u 0       will shut break checking off.'^m^j,
              ' .= 0 TEST  will match TEST anywhere.'^m^j,
              ' .= 0       will shut match checking off.'^m^j,
              'If no blk_name is specified, a blk_name could be seen as a dot cmd.'^m^j,
              'Math Eval. can be performed on the same line as a dot cmd.'^m^j,
              'Summing is NOT performed on any Dot command.'^m^j,
              'Use include filename ''='' if block is in current frame file, .i = BlkName'^m^j,
              'Use "}" to maintain column line positions thur macro substitutions.'^m^j,
              'Use "{" to truncate output w/o end_frame, For use w/ print ctrl. codes.'^m^j,
              'Other ctrl.char. can be output with the .FormFeed cmd.'^m^j,
              'GOTO cmd.& LABELed lines can have math eval.str.on same line, .g [ [ ] `1+1`'^m^j,
              'GOTO cmd.ONLY scans ahead w/re-directed input, allowing non-unique labels.'^m^j,
              'To re-direct shelled output use FRAME''s cmd.line param. /Ffilename.'^m^j,
              'Embedded ESCape sequences use a ! as an END of SEQ. delimeter.'^m^j,
              'Look 9 will NOT FRAME lines, (use ANSI codes to position and color)'^m^j,
              'use && as EOL marker to append the next line. useful w/echo cmd.>100 char'^m^j,
              'file I/O direction char. ¯ is subst. w/>>, char.® is subst. w/<<'
              );

      halt(0); { normal ending }
    end;


  const fn  : string[127] = '';
  const blk : string[32] = '';

  procedure param(p:string);
    var e  : integer;
        p2 : string[20];
    begin
      p2:=p;
      p:=p+'  ';
      case p[1] of
        '-': case p[2] of
               'R','r' : val(copy(p2,3,200),repeat_cnt,e);      { Repeat line }
               'O','o' : eval_flag:=p[3]='+';                   { OFF eval }
               'B','b' : blk := copy(p,3,200);                  { BLOCK Name }
               'F','f' :  fn := copy(p,3,200);                  { File name }
               'C','c' : begin                  { comment wrt.thur delimeter }
                           val(p2[3],comment_occur,e);
                           comment_wrt_del:=copy(p2,4,200);
                           while pos('_',comment_wrt_del) > 0 do
                             comment_wrt_del[pos('_',comment_wrt_del)]:=' '
                         end;
               '?'     : help;                             { help }
             end{case};
        '?' : help;
      end{case};
      trimtrailing(fn);
      trimtrailing(blk);
    end;

begin
  param(paramstr(1));
  param(paramstr(2));
  param(paramstr(3));
  param(paramstr(4));
  process_file(fn,blk);  { null file is the same as 'CON' }
end.

