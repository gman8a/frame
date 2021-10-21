.T
Given:    A series of 45-ft. span composite beams at 10 ft. o/c are
carrying the loads shown below.  The beams are ASTM A992 and are
unshored. The concrete has f′c = 4 ksi. Design a typical floor beam
with 3 in. 18 gage composite deck,   and 4½ in. normal weight concrete
above the deck,    for fire protection and mass.    Select an
appropriate beam and determine the required number of shear studs.

see: http://www.civil.umd.edu/ccfu/ref/AISC_ExamI1&2&3.pdf
see: http://faculty.delhi.edu/hultendc/AECT250-Lecture%207.pdf

.m
.c Material Properties:
.c note: The preferred material specification for W-shapes
.c    is ASTM A992 (Fy = 50 ksi, Fu = 65 ksi)
.d f'c = 4   ; ksi  Concrete Compressive Strength 
.d Fy  = 50  ; Beam ksi 
.d Fu  = 65  ; Beam ksi
.c
.c Layout:
.d len     = 45  ; feet  span composite beams
.d bm_sp = 10  ; feet beam spacing o/c
.d t_slab  = 7.5 ; inches slab thickness

.c
.c Loading:
.d dl_slab    = 0.075  ; conc. slab weight kips/ft2  (6"deep / 12"/ft x 150#/ft3)
.d dl_beam_wt = 0.008  ; steel beam weight kips/ft2  (assumed) 
.d dl_misc    = 0.010  ; Miscellaneous     kips/ft2  (ceiling etc.) 
.d ll_non_red = 0.100  ; Non-reduced       kips/ft2  (live loading)
.c ----------------------------------------------------------------
.c
.c
Material Properties:
  f'c =  ~f'c~  Ksi Concrete Compressive Strength
  Fy  =  ~Fy~   ksi Steel Beam Yield Strength
  Fu  =  ~Fu~   ksi Steel Beam Ultimate strength
  
Layout:
  len     = ~len~     feet   span composite beams
  bm_sp = ~bm_sp~ feet   beam spacing feet o/c
  t_slab  = ~t_slab~  inches slab thickness

Loading:
  dl_slab    = ~dl_slab~    conc. slab weight kip/ft2 (6"/12 ftx150#/ft3)
  dl_beam_wt = ~dl_beam_wt~ Steel beam weight kip/ft2 (assumed) 
  dl_misc    = ~dl_misc~    Miscellaneous     kip/ft2 (ceiling etc.) 
  ll_non_red = ~ll_non_red~ Non-reduced       kip/ft2 (live loading)

.c-----------------------------------------------------------------
.d wd = f48  ; total dead load
.d wl = f49  ; total live load
.d wu = f50  ; ultimate loading = 1.2 * wd + 1.6 * wl
.d wa = f51  ; service loading
.d Mu = f52  ; ultimate moment
.d Ma = f53  ; service moment
.d beff =f54 ; The effective width of the concrete slab 
.d beff1=f55
.d beff2=f56
.d a  =f57 ; Effective concrete thickness
.d Y2 =f58 ; moment arm for the concrete force measured from the top of the steel shape

Solution:

Loading:
.c `bm_sp`
  Since each beam is spaced at %v:6:2% feet o.c.
  Dead load total=`wd=(dl_slab+dl_beam_wt+dl_misc)*bm_sp`=%v:6:3% kips/ft
  Live load total=`wl=(ll_non_red)                *bm_sp`=%v:6:3% kips/ft 

Construction dead load (unshored) = 0.083 kip/ft2  (10 ft) = 0.83 kips/ft 
Construction live load (unshored) = 0.020 kip/ft2  (10 ft) = 0.20 kips/ft 
.m
Determine the required flexural strength:
LRFD:
   `wu = 1.2 * wd + 1.6 * wl` = %v:6:2%  kip/ft
   `Mu = wu * len^2 / 8`      = %v:6:1%  kip-ft
ASD:
   `wa = wd  + wl`            = %v:6:2%  kip/ft
   `Ma = wa * len^2 / 8`      = %v:6:1%  kip-ft
.m
Determine beff:
  The effective width of the concrete slab is the sum of the effective
  widths for each side of the beam centerline, which shall not exceed:
   
  (case 1) one-eighth of the beam span, center to center of supports 
    `beff1 = len / 8 * 2`    = %v:8:2% feet
  (case 2) one-half the distance to center-line of the adjacent beam 
    `beff2 = bm_sp /2 * 2` = %v:8:2% feet
  (case 3) the distance to the edge of the slab 
     Not applicable 

.c `beff1 - beff2`
.g lt1 eq1 gt1
.:lt1
  `beff = beff1` = %v:8:2% feet   case #1 controls
.g next1     
.:eq1
.:gt1
  `beff = beff2` = %v:8:2% feet   case #2 controls
.m
Calculate the moment arm for the concrete force measured from the top  
  of the steel shape, Y2. 

  Assume a=1 Effective concrete thickness
  Some assumption must be made to start the design process. An
  assumption of 1.0 in. has proven to be a reasonable starting point in
  many design problems.

.d Ast = 20  ; sq.in. area of steel beam
 `a = Ast * Fy / (0.85 * f'c * (bm_sp*12))` = %v:6:2%
.c `a = 1.0`
  Assume a = %v:5:2%   (or 2 in. for initial trial size)
  `Y2 = t_slab - a/2` = %v:6:2% inches
.B