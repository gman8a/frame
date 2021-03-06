.T
      Ultimate Strength Design of Concrete Beams
      See Page 14-10 in Engineering Review Book
      Applied to Simple Beam Span
.m
.d   #bar  = 11        ; number of bars
.d   rsz   = 6         ; bar size of main reinforcement steel (1/8 inch inc.)
.d   ssz   = 3         ; bar size of Stirrup Size useally #3
.d   ssr   = -2        ; inches   Stirrup spacing reduction if desired
.d   _b    = 36.0      ; inches   width of beam.
.d   _d    =  5.0      ; inches   depth to Steel
.d   cov   = 2.0       ; inches   concrete depth from _depth to beam bottom
.d   _L    = 11        ; feet     Beam Span
.d   DL1   = 1500      ; #/ft     Uniform Addition Dead Load Carried
.d   fc    =  3500     ; psi      Compressive strength of concrete
.d   fy    = 40000     ; psi      yield strength of steel re-inforcement
.c
.c
.d   �b    = 0.90      ;          Flexure Stress Capacity Reduction Facror
.d   �v    = 0.85      ;          Flexure Stress Capacity Reduction Facror
.d   Ast = f11
.d   _�  = f12
.d   _a  = f13
.d   Mn  = f14
.d   _w  = f15
.d   DL0 = f16
.d   LL  = f17
.d   MD  = f18
.d   ML  = f19
.d   _P  = f20
.d   �1  = f21
.d   �b  = f22
.d   Vc  = f23
.d   Vu  = f24
.d   Vst = f25
.d   Vmax= f26
.d   Vmin= f27
.d   Av  = f28
.d   _s  = f29
.z 1:0
                b=~_b~"
             <----------->              Beam Length = ~_L~ feet
             �����������Ŀ --+---
             �           �   |
             �           �   |
             �           �   |  d=~_d~"
             �           �   |
             �  O O O O__�___|___ center of steel grouping=~#bar~#~rsz~bars
             �  O O O O  �   |
             �           �   |  cover=~cov~"
             �������������---+---

  Dead Load caused by Conc. Beam  `DL0 = (_d+cov)*_b/144*150`= %v:8:0% #/ft
  Additional Uniform Dead Load    `DL1`                      = %v:8:0% #/ft
  Weight of concrete                                               150 pcf
  Compressive Strength of Concrete`fc`                       = %v:8:0% psi
  Yield Strength of Steel         `fy`                       = %v:8:0% psi
  Flexure Capacity Reduction Fac. `�b`                       = %v:8:4%
  Ignore the steel weight
.m
.z 7:3
  Area Steel                   `Ast= pi*(rsz/8/2)^2 * #bar`  =     %v% in^2
  Re-inforcement Ratio         `_� = Ast/(_d*_b)`            =   %v:9:5%
  Height of compressive Block  `_a = _�*fy*_d/(.85*fc)`      =     %v% in.
  Nominal Strength of the Beam `Mn = Ast*fy*(_d-_a/2)/12`    = %v:8:0% ft-#
  Flexure Capacity Reduction   `Mn = �b * Mn`                = %v:8:0% ft-#
.m
  Mu  = 1.4�M_Dead + 1.7�M_Live
  Mu  � Mn � �b

  Moment caused by Dead Load   `MD    = (DL0+DL1) * _L^2 /8` = %v:8:0% #-ft
  Nominal Moment Reduced by DL `Mn    = Mn -  1.4 * MD`      = %v:8:0% #-ft
.m
  REMAINING LIVE LOAD CAPACITY
  ============================
  Allowable Uniform Live Load  `LL    = Mn * 8  / _L^2 /1.7` = %v:8:0% #/ft
  Allowable Point   Live Load  `_P    = Mn * 4  / _L   /1.7` = %v:8:0% lbs
.B
.f
.T
  General Provisions of Beam Design
.m
  CHECK:  Steel Re-Inforcement Ratio Limits
          ACI Section 10.3.3 and 10.5.1     200/fy � � � 0.75 � �b
.c
.c `�1=0.85`   `fc - 4000`
.g �4000 �4000 >4000
.:>4000
.c `�1 = 0.85 - 0.05 * (fc-4000)/1000`     when   4000 � f'c � 8000
.:�4000
          Balance  Factor      `�1`                                 =%v:6:3%
          Balanced Ratio       `�b=.85*�1*fc/fy*(87000/(87000+fy))` =%v:5:3%
.c `_�-200/fy`
.g �bErr1 �bOK1 �bOK1
.:�bErr1
 ERROR: Steel ratio  � < `200/fy`
.:�bOK1
.c `.75*�b-_�`
.g �bErr2 �bOK2 �bOK2
.:�bErr2
 ERROR: ratio � > `0.75 * �b`
.:�bOK2
.c `f99=200/fy`   `f98=.75*�b`   `f97=_�`
.z 5:4

          ACI Requirement                    %v99% �  %v97% �  %v98%
.m
  CHECK:  Beam Depth to Width Ratio to reduce cracking from deflection.
          Requirement                       1.75 < d/b < 2
.c `_d/_b-1.75`
.g dbErr1 dbErr1 dbOK1
.:dbErr1
 ERROR: d/b ratio    1.75 < d/b
.:dbOK1
.c `2-_d/_b`
.g dbErr2 dbErr2 dbOK2
.:dbErr2
 ERROR: d/b ratio     d/b <  2.0
.:dbOK2
.c `f97=_d/_b`
.z 5:4

          Requirement                       1.75 <  %v97% <  2.00
.m
  CHECK: Concrete Cover
     *   All Steel including the reinforcement, must be adequately
         covered by concrete.  Appendix A lists the cover on reinforcing
         steel in detail (page 14-37).  However a minimum of 1-1/2 inches
         of cover is generally required.

     *   The clear distance between bars in the maximum of one bar
         diameter or 1".

     *   The minimum clear distance between layers is 1".

     *   Table 14.5 is easily derived from the clear spacing and depth
         of cover requirements of the ACI code (see Appendix A). The table
         assumes that #3 stirrups will be used, and cover is provided for
         them.  If no stirrups are used then deduct 3/4" from the table
         values.  For additional bars horizontally, increase the beam
         width by adding the value in the last column.

                Table 14.5 MINIMUM BEAm WIDTH w/#3 Stirrups     add for
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
  Shear Capacity Reduction Fac.`�v`                          = %v:8:4%
  Shear requirement            `Vu = (_P+ (DL0+DL1)*_L) / 2` = %v:8:0% lbs
  Shear developed by concrete  `Vc = 2 * sqrt(fc) *_b*_d`    = %v:8:0% lbs
  Shear required  by steel     `Vst= Vu/�v - Vc`             = %v:8:0% lbs
.m
  Max. shear steel reinfor.   `Vmax= 8 * sqrt(fc) *_b*_d`    = %v:8:0% lbs
.c `Vmax - Vst`
.g vErr1 vErr1 vOK1
.:vErr1
  Error: Maximum Shear Steel reinforcement exceeded, RE-DESIGN this beam !
.:vOK1

.z 1:0
.c `f97=�v * Vc`  `f98=Vu`  `f99=�v * Vc/2`
  Minimum shear steel reinforcement is required when   �Vc > Vu    > ��Vc
                                                     %v97% > %v98% > %v99%
.c `�v * Vc - Vu`
.g vOK2 vOK2 vErr2
.:vErr2
.c `�v * Vc/2 - Vu`
.g vErr3 vErr3 vOK2
.:vErr3
  Note: Minimum shear reinforcement is required.  Av = 50�b�s / fy
  Shear required  by steel     `Vst= 50 * _b*_d`             = %v:8:0% lbs
.:vOK2
.m
  Area Provide by Stirup     `Av = pi*(ssz/8/2)^2*2` 2 sides = %v:8:3% in.^2
  Normal stirrup spacing=��d `_s = _d/2 - ssr`               = %v:8:3% in.
  Note:  ssr = stirrup spacing reduction input by user.
.z 1:0
.c `f97=Vst`  `f98=2*Vc`  `Vst-2*Vc`
  Reduce spacing by � when   Vst > 2�Vc
                           %v97% > %v98%
.g sOK sOK sRed
.:sRed
  Reduce spacing to   ��d    `_s = _d/2/2 -ssr`              = %v:8:3% in.
.:sOK
  Shear provided by stirrups              `Av*fy*_d/_s`      = %v:8:0% lbs.
  Residual Shear strength.                `Av*fy*_d/_s - Vst`= %v:8:0% lbs.
.B
.e
