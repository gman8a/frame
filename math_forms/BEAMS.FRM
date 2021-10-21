.CARRY1
.c                        DO NOT EDIT BELOW THIS LINE
.c
.c                               COMPUTATIONS
.c  --------------------------------------------------------------------------
.c  Uniform loading on beam     W = Room_Width x Area_Loading ~f4=f2*f3~
.c  Reaction                    R = W * L/2                   ~f8=f4*f1/2~
.c  Design MOMENT               M = W x L^2 / 8               ~f5=f4*f1^2/8~
.c  Allowable Bending Stress    å = 21e3 psi   Grade A36      ~f6=21e3~
.c  Section Modulus            Sx = M / å                     ~f7=f5/f6 * 12~
.c  --------------------------------------------------------------------------
.c
.c                                 OUTPUT
.c  --------------------------------------------------------------------------
.m
.z 5:1
                Floor Loading    =  %v3:8:1%  lbs/sq.-ft.
        Width of Room CARRIED    =  %v2:8:1%  ft.
                  Beam Length  L =  %v1:8:1%  ft.
.m
         Uniform Beam Loading  W =  %v4:8:0%  lbs/ft
        Reactions at each end  R =  %v8:8:0%  lbs
        Maximum Design Moment  M =  %v5:8:0%  ft-lbs
     Allowable Bending Stress  å =  %v6:8:0%  psi    (for Grade A36 Steel)
.m
     Design Section Modulus   Sx =  %v7:8:1%  inches^3
.m

     Write In the Shape Here ____________________________________________

     * Make sure your section is COMPACT for the full beam length !
       Lu <=%v1% feet
.B
.F
.E
.CARRY1

.CARRY2
.c  --------------------------------------------------------------------------
.c                        DO NOT EDIT BELOW THIS LINE
.c  --------------------------------------------------------------------------
.m
.z 5:1
 Floor`Loading`              =                                %v:8:1% #/s.f.
`Width`of Room CARRIED       =                                %v:8:1% ft.
 Beam`Length`              L =                                %v:8:1% ft.
.m
 Uniform Beam Loading      W =          `f3=Width * Loading`= %v:8:0% lbs/ft
 Reactions at each end     R = WùL/2   =`f4=f3 * Length/2`  = %v:8:0% lbs
 Maximum Design Moment     M = WùL^2/8 =`f5=f3 * Length^2/8`= %v:8:0% ft-lbs
.m
 Steel Yield Stress A36   Fy =          `f6=                    36000`psi
 Max.Allow.Shear Stress   Fv = 0.40ùFy =`f7= 0.40 * f6`     = %v:8:0% psi
 Max.Allow.Bending Stress  å = 0.66ùFy =`f8= 0.66 * f6`     = %v:8:0% psi
.m
 Min. Section Area         a = R / Fv  =`    f4      / f7`  = %v:8:1% inch^2
 Min. Section Modulus     Sx = M / å   =`    f5 * 12 / f8`  = %v:8:1% inch^3
.m

     Write In the Shape Here ____________________________________________

 * Make sure the W-Shape is fully COMPACT : Lu <= Beam`Length`=%v% feet !
.B
.F
.E
.CARRY2
