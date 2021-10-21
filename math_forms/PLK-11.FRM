.T
   STRENGTH DESIGN OF CONCRETE BEAMS
.m
.c ============================================================================
.c
.d f'c =  3500           ; Concrete Compressive Strength, psi
.d fy  = 40000           ; Steel Yield Strength, psi
.c
.d wL  = (100+100)*3     ; Uniform Live Load, #/FT  People + Snow + Ice
.d wD  = (4*150)*3       ; Uniform Dead Load, #/FT  w/4'soil
.d ˜dim=  36*7           ; Approx.Overall Conc.Beam Dim., in˝ (calc.Dead Load)
.c
.d l   =  11     ; Length of beam, feet
.d d/b =  .1458  ; beam Depth to Base ratio  1.75 < b/d < 2.0
.d prot=  1.25   ; protection is clear concrete cover on bottom of beam, inches
.d Bar =  7      ; Bar     size in 1/8" inc.  (i.e. #4 is a ´" bar)
.d Stir=  3      ; STIRrup size in 1/8" inc.
.d #Lay=  1      ; number of LAYERS of main steel rebar
.d dLay=  1.5    ; CLEAR distance between layers, (1" minimum.)
.c ============================================================================
.c
.c
.c
.d Area= pi*(Bar/8/2)^2 ; area of a single bar
.d Âb  =  f89           ; balanced ratio of steel to concrete
.d Â   =  f88           ; working  ratio of steel to concrete
.d ru  =  f87           ; coefficient of resistance (revised)
.d Ru  =  f86           ; coefficient of resistance
.d m   =  f85           ; intermidiate constant for Ru calc.
.d MD  =  f84           ; dead load moment
.d ML  =  f83           ; Live load moment
.d Mu  =  f82           ; Ultimate  moment
.d bd˝ =  f81           ; Beam dimensions
.d d   =  f80           ; beam depth
.d b   =  f79           ; beam base
.d Ast =  f78           ; Total area of main steel re-bars
.d #bar=  f77           ; # of rebars
.d dc  =  f76           ; Cover depth
.d h   =  f75           ; Total Height of beam
.d dst =  f74           ; distance from center of steel to C.L. of bot.layer
.d wDbm=  f73
.d Ì   =  0.90          ; moment capacity reduction factor
.g ] ] [ `f'c-4000`
.:[
.d ·1  =.85-.05*(f'c-4000)/1000    ;  when   4000 Û f'c Û 8000
.g ]] ]] ]]
.:]
.d ·1  =  0.85          ; when f'c<4000, this factor must NOT be less than 0.65
.:]]
.c
.c
.c
.c ========================================================================
  Step 1. Select Tension reinforcement Ratio  Â = Ast/Ac = Ast/(b˘d)

          Cracking will be minimized by keeping Â to less than half
          the maximum allowable (i.e., 0.375 of Âbalanced), particularly
          when grade 40 of higher steel is used.  A general rule used to
          design economical beams is to try to satisfy the equation:

              Â˘fy/f'c ˜ 0.18   (beams only)         EQ.#1


  ·1         =   ~·1~  =  %v:4:2%
  f'c        =   ~f'c~
  fy         =  ~fy~


  Â_Bal.     = `Âb = 0.85 * (·1) * f'c/fy * (87000/(87000+fy))` = %v:7:4%
  Â_Max.     = `     0.75 * Âb`                                 = %v:7:4%
  Â          = `Â  = 0.18 *f'c / fy`     from EQ.#1             = %v:7:4%
  Â_Min.     = `     200 / fy`                                  = %v:7:4%

  Ckeck : Â_Min < Â < Â_Max

.m

  Step 2.  Calculate the Coefficient of resistance, Ru, defined as Mn/(bd˝).

 ` m               = fy / (0.85*f'c)`                           = %v:7:2%
 `Ru               = Â * fy * (1 - Â*m/2)`                      = %v:7:2%

.m
  Step 3.  Calculate the required value of bd˝ from Equation #2

   Moment capacity reduction factor  Ì = ~Ì~

                     bd˝ = Mu/(Ì˘Ru) = Mn / Ru          EQ.#2

  Ultimate Moment    Mu  = 1.4 ˘ MD  +  1.7 ˘ ML        EQ.#3


  Uniform   Live Load  wL  =~wL~                      }=  %v%  #/ft
  Uniform   Dead Load  wD  =~wD~                      }=  %v%  #/ft
  Conc.Beam Dead Load  ~wDbm=(˜dim)/144*150~          }=  %v%  #/ft
  Length of Beam         l =~l ~                      }=  %v%  feet

  Moment due to Live Load  `ML = (wL)     * l^2/8`    =  %v:8:0% ft-#
  Moment due to Dead Load  `MD = (wD+wDbm)* l^2/8`    =  %v:8:0% ft-#

  Factored Moment          `Mu = 1.4 * MD + 1.7 * ML` =  %v:8:0% ft-#

  Calculated bd˝           `bd˝= Mu*12 / (Ì * Ru)`    =  %v:8:1% in^3

.m
  Step 4. Size the Conc. Beam so that bd˝ is approimately equal to the
          value calculated in step 3.  A good choice is to keep d/b between
          1.75 and 2.00. Size the beam to the nearest ¨ inch.

           d/b = ~ d/b~
          `d   = ( d/b * bd˝)^ (1/3)`   =   %v:6:2% inches
          `b   = d / d/b`               =   %v:6:2% inches

          `d   = RND(d*4)/4`            =   %v:6:2% inches rounded to ¨"
          `b   = RND(b*4)/4`            =   %v:6:2% inches rounded to ¨"

.c
.m
  Step 5. If  the actual bd˝ quantity is greatly different from
          the calculated bd˝ value of step 3 then recalculate Â.

  Actual bd˝         `bd˝= b * d^2`       =  %v:8:1% in^3

  Ru,revised         `ru= Mu*12/Ì /bd˝`   =   %v:7:2% in-#

  Â ,revised         `Â  = Â * ru/Ru`     =   %v:7:5%

.m
  Step 6. Calculate the required Steel.

           `Ast = Â * b * d `    =   %v:6:2% sq.inches

.m
  Step 7. Select the reinforcement steel bars to satisfy the distribution
          and placement requirements of the ACI code.
          Refer to table 14.5 and 14.6.


          Bars Size = #~Bar~

          Single Bar Area =~Area~          }=  %v:6:3%  sq.in.

          Try Using `#bar=Ast/(Area)`      }=  %v:5:2%  Bars

.B
.F
.T
  Step 8.  Specify the depth of concrete protection to satisfy the ACI code.
           Cover should be measured from the lower stirrup surface.
           Note: Concrete protection and cover depth, dc, are different.

           Concrete protection = ~prot~

            dst is the distance from the steel C.L. to the bottom layer.

            dc = ´ bar Ì  +  stir Ì  + ~prot~"
           `dc = Bar/8/2  +  Stir/8  +  prot` = %v:8:2% inches
           `dst=(Bar/8+dLay) * (#Lay-1)/2`    = %v:8:2% in.

           `dst= RND(dst*4)/4` rounded to ¨"  = %v:8:2% in.
           `dc = RND(dc *4)/4` rounded to ¨"  = %v:8:2% in.
           `d` =                                %v:6:2% in.
           ===================================================
           `h  =  d + dc + dst`               = %v:6:2% inches


            f'c   =  ~f'c~  }psi
            fy    = ~fy~    }psi

.z 5:2
.c `f1=Bar` `f2=#bar`
              Use   %v2% }#%v1:2:0% Bars

                          +---`b`=%v:5:2%in.--+
                          |                   |
        _____ Beam Top ___|                   |______
        |                 ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞     |
        |                 ∞                   ∞     |
        |                 ∞  ›             ﬁ  ∞     |
        |                 ∞  ›             ﬁ  ∞     |
        |                 ∞  ›   #~Stir~  }ﬁ  ∞     |
        |                 ∞  ›   Stirrup-->ﬁ  ∞     |
        |                 ∞  ›             ﬁ  ∞     |
        |                 ∞  ›             ﬁ  ∞     |
        |                 ∞  ›             ﬁ  ∞  `d`=%v:5:2% in.
        |                 ∞  ›             ﬁ  ∞     |
    `h`=%v:5:2% in.}      ∞  ›             ﬁ  ∞     |
        |                 ∞  ›             ﬁ  ∞     |
        |                 ∞  ›             ﬁ  ∞     |
        |                 ∞  ›  rebars     ﬁ  ∞     |
        |                 ∞  › /           ﬁ  ∞     |
        |                 ∞  ›*  *  *  *  *ﬁ- ∞     |  - - -+
        |                 ∞  ›             ﬁ  ∞     |       | 1" min. clear
        |  Center Steel---∞ -›*  *  *  *  *ﬁ- ∞-----+  - - -+
        |                 ∞  ›             ﬁ  ∞             | dsteel
        |                 ∞  ›*  *  *  *  *ﬁ-_∞-----+-_-_-_-+ ´ rebar Ì
        |    Stir. Bot.---∞--ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ- ∞     |- - - -+ stirrup Ì
        |                 ∞   |  |            ∞     dc      | ˜1´" protection
        |___ Beam  Bot.___∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞_____|  _ _ _|
                          |   |  |
                          |   |  |
                          +---+--+
.z 5:2
 clear cover on stirrup    1´"  ¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ barÌ   C.L. to C.L. or bars
       stirrup diameter  ˜3/8"                     1"   clear spacing=1" min.
     to center of rebar  ´barÌ                 ======
                       =======       `1+Bar/8`=   %v% in. min.
  `1.5+Stir/8+Bar/8/2`=    %v% in.min.

.m
  CHECK: Concrete Cover

     *   All Steel including the reinforcement, must be adequately
         covered by concrete.  Appendix A lists the cover on reinforcing
         steel in detail (page 14-37).  However a minimum of 1-1/2 inches
         of cover is generally required.

     *   The clear distance between bars:
         one bar diameter or 1 inch minimum, which ever is greater.

     *   The minimum clear distance between layers is 1".

     *   Table 14.5 is easily derived from the clear spacing and depth
         of cover requirements of the ACI code (see Appendix A). The table
         assumes that #3 stirrups will be used, and cover is provided for
         them.  If no stirrups are used then deduct 3/4" from the table
         values.  For additional bars horizontally, increase the beam
         width by adding the value in the last column.

                Table 14.5 MINIMUM BEAM WIDTH w/#3 Stirrups
                                                                add for
         bar     No. of bars in single layer of reinforcement   each
         size    2      3      4      5      6      7      8    added bar
         ----- -----  -----  -----  -----  -----  -----  -----  ---------
         #4     6.1    7.6    9.1   10.6   12.1   13.6   15.1     1.5
         #5     6.3    7.9    9.6   11.2   12.8   14.4   16.1     1.63
         #6     6.5    8.3   10.0   11.8   13.5   15.3   17.0     1.75
         #7     6.7    8.6   10.5   12.4   14.2   16.1   18.0     1.88
         #8     6.9    8.9   10.9   12.9   14.9   16.9   18.9     2.0
         #9     7.3    9.5   11.8   14.0   16.3   18.6   20.8     2.26
         #10    7.7   10.2   12.8   15.3   17.8   20.4   22.9     2.54
         #11    8.0   10.8   13.7   16.5   19.3   22.1   24.9     2.82
         #14    8.9   12.3   15.6   19.0   22.4   25.8   29.2     3.39
         #18   10.5   15.0   19.5   24.0   28.6   33.1   37.6     4.51
.B
.E


.c 40 ≥ (  )  *  +  ,  -  .  /  0  1  ∫ ∫ 170 ≥ ™  ´  ¨  ≠  Æ  Ø  ∞  ±  ≤  ≥
.c 50 ≥ 2  3  4  5  6  7  8  9  :  ;  ∫ ∫ 180 ≥ ¥  µ  ∂  ∑  ∏  π  ∫  ª  º  Ω
.c 60 ≥ <  =  >  ?  @  A  B  C  D  E  ∫ ∫ 190 ≥ æ  ø  ¿  ¡  ¬  √  ƒ  ≈  ∆  «
.c 70 ≥ F  G  H  I  J  K  L  M  N  O  ∫ ∫ 200 ≥ »  …     À  Ã  Õ  Œ  œ  –  —
.c 80 ≥ P  Q  R  S  T  U  V  W  X  Y  ∫ ∫ 210 ≥ “  ”  ‘  ’  ÷  ◊  ÿ  Ÿ  ⁄  €
.c 90 ≥ Z  [  \  ]  ^  _  `  a  b  c  ∫ ∫ 220 ≥ ‹  ›  ﬁ  ﬂ  ‡  ·  ‚  „  ‰  Â
.c100 ≥ d  e  f  g  h  i  j  k  l  m  ∫ ∫ 230 ≥ Ê  Á  Ë  È  Í  Î  Ï  Ì  Ó  Ô
.c110 ≥ n  o  p  q  r  s  t  u  v  w  ∫ ∫ 240 ≥   Ò  Ú  Û  Ù  ı  ˆ  ˜  ¯  ˘
.c120 ≥ x  y  z  {  |  }  ~    Ä  Å  ∫ ∫ 250 ≥ ˙  ˚  ¸  ˝  ˛  ˇ
.c
