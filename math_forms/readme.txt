This folder holds many example forms having file extension .FRM or .frm

They can be processed from a linux command line as follows:

~/frame/math_forms$ cat CARRY-15.FRM|./frame|iconv --from-code=IBM437 --to-code=UTF-8

 Many of the sample forms were developed using DOS-OS, thus the character set was Code-Page-437 aka CP437, aka IBM437
 To maintain backwards compadibility these forms are kept and used as CP437 forms,
 and the resulting 'frame' output is converted to UTF-8 character set for proper display on modern terminal and web/browser portals.
 
 Here is a sample 80 character wide page 'frame' output.
 
 ~/frame/math_forms$ cat CARRY-15.FRM|../frame|iconv --from-code=IBM437 --to-code=UTF-8
 
+=============================================================================+
|      Ultimate Strength Design of Concrete Beams                             |
|      See Page 14-10 in Engineering Review Book                              |
|      Applied to Simple Beam Span                                            |
+-----------------------------------------------------------------------------+
|                b=  14.50"                                                   |
|             <----------->              Beam Length =   15 feet              |
|             ┌───────────┐ --+---                                            |
|             │           │   |                                               |
|             │           │   |                                               |
|             │           │   |  d=  26.25"                                   |
|             │           │   |                                               |
|             │  O O O O__│___|___ center of steel grouping= 12   # 7   bars  |
|             │  O O O O  │   |                                               |
|             │           │   |  cover= 5.25"                                 |
|             └───────────┘---+---                                            |
|                                                                             |
|  Dead Load caused by Conc. Beam   DL0 = ( d+cov)* b/144*150 =     476 #/ft  |
|  Additional Uniform Dead Load     DL1                       =    7568 #/ft  |
|  Additional Uniform Live Load     LL1                       =    2200 #/ft  |
|  Additional Point   Live Load     LL2                       =       0 #/ft  |
|                                                                             |
|  Weight of concrete                                               150 pcf   |
|  Compressive Strength of Concrete f'c                       =    3500 psi   |
|  Yield Strength of Steel          fy                        =   40000 psi   |
|  Flexure Capacity Reduction Fac.  φb                        =  0.9000       |
|  Ignore the steel weight                                                    |
+-----------------------------------------------------------------------------+
|  Area Steel                    Ast= pi*(rsz/8/2)^2 * #bar   =   7.216 in^2  |
|  Re-inforcement Ratio           σ = Ast/( d* b)             =   0.01896     |
|  Height of compressive Block    a =  σ *fy* d/(.85*f'c)     =   6.691 in.   |
|  Nominal Strength of the Beam  Mn = Ast*fy*( d- a/2)/12     =  550918 ft-#  |
|                                                                             |
+-----------------------------------------------------------------------------+
|  Ultimate moment is calculated: Mu  = 1.4 ∙ M_Dead +  1.7 ∙ M_Live          |
|                                                                             |
|  Moment by Uniform Dead Load    MD  =   (DL0+DL1) *  L^2 /8  =  226231 ft-# |
|  Moment by Uniform Live Load    ML  =   (LL1    ) *  L^2 /8  =   61875 ft-# |
|  Moment by Point   Live Load    ML2 =    LL2/2    *  L/2     =       0 ft-# |
|  -------------------------------------------------------------------------- |
|  Total Factor Moment            Mu  = 1.4*MD + 1.7* (ML+ML2) =  421911 ft-# |
|                                                                             |
|  Flexure strength requirment:   Mn  ≥  Mu/φ                                 |
|  Nominal strength of the Beam   Mn                           =  550918 ft-# |
|  CHECK strength requirment      Mu / φb                      =  468790 ft-# |
|                                                                             |
+-----------------------------------------------------------------------------+
|  REMAINING LIVE LOAD CAPACITY   -There must be POSITIVE residual moment     |
|  ============================                                               |
|  Residual Moment                Mr  = Mn -  Mu/φb            =   82127 ft-# |
|                                                                             |
|  Allowable Uniform Live Load    LL    = Mr * 8  /  L^2 /1.7  =    1718 #/ft |
|  Allowable Point   Live Load     P    = Mr * 4  /  L   /1.7  =   12883 lbs  |
+=============================================================================+

+=============================================================================+
|  General Provisions of Beam Design                                          |
+-----------------------------------------------------------------------------+
|  CHECK:  Steel Re-Inforcement Ratio Limits                                  |
|          ACI Section 10.3.3 and 10.5.1     200/fy ≤ σ ≤ 0.75 ∙ σb           |
|          Balance  Factor       ß1                                  =  0.850 |
|          Balanced Ratio        σb=.85*ß1*f'c/fy*(87000/(87000+fy)) =  0.043 |
|                                                                             |
|          ACI Requirement                   0.0050 ≤ 0.0190 ≤ 0.0325         |
+-----------------------------------------------------------------------------+
|  CHECK:  Beam Depth to Width Ratio to reduce cracking from deflection.      |
|          Requirement                       1.75 < d/b < 2                   |
|                                                                             |
|          Requirement                       1.75 < 1.8103 <  2.00            |
+-----------------------------------------------------------------------------+
|  CHECK: Concrete Cover                                                      |
|                                                                             |
|     *   All Steel including the reinforcement, must be adequately           |
|         covered by concrete.  Appendix A lists the cover on reinforcing     |
|         steel in detail (page 14-37).  However a minimum of 1-1/2 inches    |
|         of cover is generally required.                                     |
|                                                                             |
|     *   The clear distance between bars:                                    |
|         one bar diameter or 1 inch minimum, which ever is greater.          |
|                                                                             |
|     *   The minimum clear distance between layers is 1".                    |
|                                                                             |
|     *   Table 14.5 is easily derived from the clear spacing and depth       |
|         of cover requirements of the ACI code (see Appendix A). The table   |
|         assumes that #3 stirrups will be used, and cover is provided for    |
|         them.  If no stirrups are used then deduct 3/4" from the table      |
|         values.  For additional bars horizontally, increase the beam        |
|         width by adding the value in the last column.                       |
|                                                                             |
|                Table 14.5 MINIMUM BEAM WIDTH w/#3 Stirrups                  |
|                                                                add for      |
|         bar     No. of bars in single layer of reinforcement   each         |
|         size    2      3      4      5      6      7      8    added bar    |
|         ----- -----  -----  -----  -----  -----  -----  -----  ---------    |
|         #4     6.1    7.6    9.1   10.6   12.1   13.6   15.1     1.5        |
|         #5     6.3    7.9    9.6   11.2   12.8   14.4   16.1     1.63       |
|         #6     6.5    8.3   10.0   11.8   13.5   15.3   17.0     1.75       |
|         #7     6.7    8.6   10.5   12.4   14.2   16.1   18.0     1.88       |
|         #8     6.9    8.9   10.9   12.9   14.9   16.9   18.9     2.0        |
|         #9     7.3    9.5   11.8   14.0   16.3   18.6   20.8     2.26       |
|         #10    7.7   10.2   12.8   15.3   17.8   20.4   22.9     2.54       |
|         #11    8.0   10.8   13.7   16.5   19.3   22.1   24.9     2.82       |
|         #14    8.9   12.3   15.6   19.0   22.4   25.8   29.2     3.39       |
|         #18   10.5   15.0   19.5   24.0   28.6   33.1   37.6     4.51       |
+=============================================================================+

+=============================================================================+
|  SHEAR Reinforcement in the Beam                                            |
+-----------------------------------------------------------------------------+
|  Shear Capacity Reduction Fac. φv                            =  0.8500      |
|  Shear requirement             Vu =( DL0+DL1 + LL1+LL2)* L/2 =   76828 lbs  |
|  Shear developed by concrete   Vc = 2 * Sqrt(f'c) * b* d     =   45036 lbs  |
|  Shear required  by steel      Vst= Vu/φv - Vc               =   45350 lbs  |
|                                                                             |
|  NOTE: Shear from the residual Bending flexure  LL * L/2     =   12883 lbs  |
|        strength is NOT applied to these calculation !                       |
+-----------------------------------------------------------------------------+
|  Max. shear steel reinfor.    Vmax= 8 * Sqrt(f'c) * b* d     =  180145 lbs  |
|                                                                             |
|  Minimum shear steel reinforcement is required when   φVc > Vu    > ½φVc    |
|                                                     38281 > 76828 > 19140   |
+-----------------------------------------------------------------------------+
|  Area Provide by Stirrup  2 sides   Av = pi*(ssz/8/2)^2*2   =   0.393 in.^2 |
|  Normal stirrup spacing=½∙d   s =  d/2 - ssr                =   7.000 in.   |
|  Note:  ssr = stirrup spacing reduction input by user.                      |
|  Reduce spacing by ½ when   Vst > 2∙Vc                                      |
|                           45350 > 90072                                     |
|  Shear provided by stirrups               Av*fy* d/ s       =   58905 lbs.  |
|  Residual Shear strength.                 Av*fy* d/ s - Vst =   13555 lbs.  |
+=============================================================================+

+=============================================================================+
|    Check for Cracking, or if the steel is sufficiently distrubuted          |
|    throughtout the tension region of the beam rater than being clustered    |
|    in one spot.                                                             |
+-----------------------------------------------------------------------------+
|        use liminting parameter  z. units kips/inch                          |
|        z = fst∙ (dc∙Ae) ^1/3                                                |
|        z must not exceed 145 kips/in (exterior service)                     |
|        z must not exceed 175 kips/in (interior service)                     |
|                                                                             |
|        dc is the cover depth,  dc = ½ bar φ  +  stir φ  + 1½"               |
|                                                                             |
|        fst is the steel stress at service level, fst = 0.60∙fy              |
|                                                                             |
|        Ae is the effective concrete area in the tension block divided       |
|        by the total no. of steel bars.                                      |
|                                                                             |
|        Ae = 2∙dst∙b / #bars                                                 |
|                                                                             |
|        hence  z = fst∙ (dc∙(2∙dst∙b)/#bars) ^1/3                            |
|                                                                             |
|        f1 = 0.60*fy/1000           =   24.000 ksi                           |
|                                                                             |
|        f2 = rsz/8/2 + ssz/8 +1.5   =     2.44 inches                        |
|                                                                             |
|        f3 = 2 * d *  b/#bar        =    63.44 sq.in.                        |
|                                                                             |
|        z =   f1 * (f2*f3) ^(1/3)   =   128.82                               |
|                                                                             |
+=============================================================================+

#---End of file
