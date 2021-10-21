.T
      Ultimate Strength Design of Concrete Beams
      See Page 14-10 in Engineering Review Book
      Applied to Simple Beam Span
.m
.d   #bar  = 9         ; number of bars
.d   rsz   = 7         ; bar size of main reinforcement steel (1/8 inch inc.)
.d   ssz   = 3         ; bar size of Stirrup Size useally #3
.d   ssr   = 0         ; inches   Stirrup spacing reduction if desired
.d    b    = 36.00     ; inches   width of beam.
.d    d    = 5.25      ; inches   depth to Steel
.d   cov   = 1.75      ; inches   concrete depth from  depth to beam bottom
.d    L    = 11        ; feet     Beam Span
.d   DL1   = 1800      ; #/ft     Uniform Addition Dead Load Carried
.d   LL1   =  600      ; #/ft     Uniform Addition Live Load Carried
.d   LL2   = 0000      ; #/ft     Point   Addition Live Load Carried at Center
.d   f'c   =  4000     ; psi      Compressive strength of concrete
.d   fy    = 50000     ; psi      yield strength of steel re-inforcement
.c
.c
.d   íb    = 0.90      ;          Flexure Stress Capacity Reduction Facror
.d   ív    = 0.85      ;          Flexure Stress Capacity Reduction Facror
.d   Ast = f11
.d    å  = f12
.d    a  = f13
.d   Mn  = f14
.d   Mu  = f32
.d   Mr  = f31
.d    w  = f15
.d   DL0 = f16
.d   LL  = f17
.d   MD  = f18
.d   ML2 = f30
.d   ML  = f19
.d    P  = f20
.d   á1  = f21
.d   åb  = f22
.d   Vc  = f23
.d   Vu  = f24
.d   Vst = f25
.d   Vmax= f26
.d   Vmin= f27
.d   Av  = f28
.d    s  = f29
.z 1:0
                b=~ b~"
             <----------->              Beam Length = ~ L~ feet
             ÚÄÄÄÄÄÄÄÄÄÄÄ¿ --+---
             ³           ³   |
             ³           ³   |
             ³           ³   |  d=~ d~"
             ³           ³   |
             ³  O O O O__³___|___ center of steel grouping=~#bar~#~rsz~bars
             ³  O O O O  ³   |
             ³           ³   |  cover=~cov~"
             ÀÄÄÄÄÄÄÄÄÄÄÄÙ---+---

  Dead Load caused by Conc. Beam  `DL0 = ( d+cov)* b/144*150`= %v:8:0% #/ft
  Additional Uniform Dead Load    `DL1`                      = %v:8:0% #/ft
  Additional Uniform Live Load    `LL1`                      = %v:8:0% #/ft
  Additional Point   Live Load    `LL2`                      = %v:8:0% #/ft

  Weight of concrete                                               150 pcf
  Compressive Strength of Concrete`f'c`                      = %v:8:0% psi
  Yield Strength of Steel         `fy`                       = %v:8:0% psi
  Flexure Capacity Reduction Fac. `íb`                       = %v:8:4%
  Ignore the steel weight
.m
.z 7:3
  Area Steel                   `Ast= pi*(rsz/8/2)^2 * #bar`  =     %v% in^2
  Re-inforcement Ratio         ` å = Ast/( d* b)`            =   %v:9:5%
  Height of compressive Block  ` a =  å *fy* d/(.85*f'c)`    =     %v% in.
  Nominal Strength of the Beam `Mn = Ast*fy*( d- a/2)/12`    = %v:8:0% ft-#

.m
  Ultimate moment is calculated: Mu  = 1.4 ù M_Dead +  1.7 ù M_Live

  Moment by Uniform Dead Load   `MD  =   (DL0+DL1) *  L^2 /8` = %v:8:0% ft-#
  Moment by Uniform Live Load   `ML  =   (LL1    ) *  L^2 /8` = %v:8:0% ft-#
  Moment by Point   Live Load   `ML2 =    LL2/2    *  L/2   ` = %v:8:0% ft-#
  --------------------------------------------------------------------------
  Total Factor Moment           `Mu  = 1.4*MD + 1.7* (ML+ML2)`= %v:8:0% ft-#

  Flexure strength requirment:   Mn  ò  Mu/í
  Nominal strength of the Beam  `Mn`                          = %v:8:0% ft-#
  CHECK strength requirment     `Mu / íb`                     = %v:8:0% ft-#

.m
  REMAINING LIVE LOAD CAPACITY   -There must be POSITIVE residual moment
  ============================
  Residual Moment               `Mr  = Mn -  Mu/íb`           = %v:8:0% ft-#

  Allowable Uniform Live Load   `LL    = Mr * 8  /  L^2 /1.7` = %v:8:0% #/ft
  Allowable Point   Live Load   ` P    = Mr * 4  /  L   /1.7` = %v:8:0% lbs
.B
.f
.T
  General Provisions of Beam Design
.m
  CHECK:  Steel Re-Inforcement Ratio Limits
          ACI Section 10.3.3 and 10.5.1     200/fy ó å ó 0.75 ù åb
.c
.g ó4000 ó4000 >4000  `á1=0.85`   `f'c - 4000`
.:>4000
.c `á1 = 0.85 - 0.05 * (f'c-4000)/1000`     when   4000 ó f'c ó 8000
.:ó4000
          Balance  Factor      `á1`                                 =%v:6:3%
          Balanced Ratio       `åb=.85*á1*f'c/fy*(87000/(87000+fy))`=%v:5:3%
.g åbErr1 åbOK1 åbOK1  `å-200/fy`
.:åbErr1
 ERROR: Steel ratio  å < `200/fy`
.:åbOK1
.g åbErr2 åbOK2 åbOK2  `.75*åb- å`
.:åbErr2
 ERROR: ratio å > `0.75 * åb`
.:åbOK2
.c `f99=200/fy`   `f98=.75*åb`   `f97= å`
.z 5:4

          ACI Requirement                    %v99% ó  %v97% ó  %v98%
.m
  CHECK:  Beam Depth to Width Ratio to reduce cracking from deflection.
          Requirement                       1.75 < d/b < 2
.g dbErr1 dbErr1 dbOK1  ` d/b-1.75`
.:dbErr1
 ERROR: d/b ratio    1.75 < d/b
.:dbOK1
.g dbErr2 dbErr2 dbOK2  `2 - d/b`
.:dbErr2
 ERROR: d/b ratio     d/b <  2.0
.:dbOK2
.c `f97= d/b`
.z 5:4

          Requirement                       1.75 <  %v97% <  2.00
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
.f
.T
  SHEAR Reinforcement in the Beam
.m
  Shear Capacity Reduction Fac.`ív`                           = %v:8:4%
  Shear requirement            `Vu =( DL0+DL1 + LL1+LL2)* L/2`= %v:8:0% lbs
  Shear developed by concrete  `Vc = 2 * Sqrt(f'c) * b* d`    = %v:8:0% lbs
  Shear required  by steel     `Vst= Vu/ív - Vc`              = %v:8:0% lbs

  NOTE: Shear from the residual Bending flexure `LL * L/2`    = %v:8:0% lbs
        strength is NOT applied to these calculation !
.m
  Max. shear steel reinfor.   `Vmax= 8 * Sqrt(f'c) * b* d`    = %v:8:0% lbs
.g vErr1 vErr1 vOK1  `Vmax - Vst`
.:vErr1
  Error: Maximum Shear Steel reinforcement exceeded, RE-DESIGN this beam !
.:vOK1

.z 1:0
.c `f97=ív * Vc`  `f98=Vu`  `f99=ív * Vc/2`
  Minimum shear steel reinforcement is required when   íVc > Vu    > «íVc
                                                     %v97% > %v98% > %v99%
.g vOK2 vOK2 vErr2  `ív * Vc - Vu`
.:vErr2
.g vErr3 vErr3 vOK2 `ív * Vc/2 - Vu`
.:vErr3
  Note: Minimum shear reinforcement is required.  Av = 50ùbùs / fy
  Shear required  by steel     `Vst= 50 *  b* d`             = %v:8:0% lbs
.:vOK2
.m
  Area Provide by Stirrup  2 sides  `Av = pi*(ssz/8/2)^2*2`  = %v:8:3% in.^2
  Normal stirrup spacing=«ùd ` s =  d/2 - ssr`               = %v:8:3% in.
  Note:  ssr = stirrup spacing reduction input by user.
.z 1:0
.c `f97=Vst`  `f98=2*Vc`  `Vst-2*Vc`
  Reduce spacing by « when   Vst > 2ùVc
                           %v97% > %v98%
.g sOK sOK sRed
.:sRed
  Reduce spacing to   ¬ùd    ` s =  d/2/2 -ssr`              = %v:8:3% in.
.:sOK
  Shear provided by stirrups              `Av*fy* d/ s`      = %v:8:0% lbs.
  Residual Shear strength.                `Av*fy* d/ s - Vst`= %v:8:0% lbs.
.B
.f
.T
    Check for Cracking, or if the steel is sufficiently distrubuted
    throughtout the tension region of the beam rater than being clustered
    in one spot.
.m
        use liminting parameter  z. units kips/inch
        z = fstù (dcùAe) ^1/3
        z must not exceed 145 kips/in (exterior service)
        z must not exceed 175 kips/in (interior service)

        dc is the cover depth,  dc = « bar í  +  stir í  + 1«"

        fst is the steel stress at service level, fst = 0.60ùfy

        Ae is the effective concrete area in the tension block divided
        by the total no. of steel bars.

        Ae = 2ùdstùb / #bars

        hence  z = fstù (dcù(2ùdstùb)/#bars) ^1/3

       `f1 = 0.60*fy/1000`          =  %v:7:3% ksi

       `f2 = rsz/8/2 + ssz/8 +1.5`  =  %v:6:2% inches

       `f3 = 2 * d *  b/#bar`       =  %v:8:2% sq.in.

        z = ` f1 * (f2*f3) ^(1/3)`  =  %v:8:2%

.B
.e
