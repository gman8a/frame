.c NOTE: this form uses character mapping: Unicode character UTF-8; as sourced from within the PDF file.
.c  using frame .Look 3 because not converting the framing characters from CP437 to UTF-8
.c		This is because some UTF-8 char. do not map into CP437, in particular:
.c		GREEK SMALL LETTER BETA:  UTF9: <CE><B2>   CP437: 225
.c
.c		see URL: https://en.wikipedia.org/wiki/Code_page_437
.c		see URL: https://jdhao.github.io/2020/10/07/nvim_insert_unicode_char/
.c 
.c BEAM DESIGN SOURCE
.c	http://www.civilpe.net/wp-content/uploads/2012/08/Reinforced-Concrete-Beam-Design-ACI-318-08.pdf
.c	https://pdfcoffee.com/reinforced-concrete-beam-design-aci-318-08-pdf-free.html              
.c
.c  How to Insert Unicode Characters in Neovim/Vim;   https://jdhao.github.io/2020/10/07/nvim_insert_unicode_char/
.L3
.T
	Reinforced Concrete Beam Design ACI 318-08

  Required:
    - Determine the nominal moment capacity, ΦMn
    - Determine the nominal shear capacity, ΦVn

  Assumptions:
    1. Plain sections remain plain (ACI 318-08 section 10.2.2)
    2. Maximum concrete strain at extreme compression 
        fiber = 0.003 (ACI section 10.2.3)
    3. Tensile strength of concrete is neglected (10.2.5)
    4. Compression steel is neglected in this calculation.
.m
.c === User input below ================================================
.c
.c ----- Material properties -----------
.d f'c =  6000  ; Concrete Compressive Strength, psi
.d fy  = 60000  ; Steel Yield Strength, psi
.c ----- Beam overall dimensions ----- 
.d h   = 24     ; Total Height of beam, Overall height of beam
.d b   = 12     ; width of beam, = width of compression zone
.c
.c ----- Main reinforcement steel -------------------------------
.d barSz =  6      ; Bar size in 1/8" inc.  (i.e. #4 is a ½" bar)
.d #Bar  =  3      ; number of bars
.d #Lay  =  1      ; number of LAYERS of main steel rebar
.d dLay  =  1.5    ; CLEAR distance between layers, (1" minimum.)
.c
.c ----- Stirrup reinforcement steel ---------------------------
.d stirSz=  4      ; STIRrup size in 1/8" inc.
.d clrCov= 1.5     ; inches   concrete depth from _depth to beam bottom
.c === End of user input ==============================================
.c Note: a double blank comment ends the user input 
.c   and is key to PHP pre-processor code to cut input page.
.c
.c
.d d       = f50  ; effective depth of beam (top of beam to centroid of steel)
.d tmp1    = f51
.d Tsteel  = f52  ; Tension force in steel
.d Area    = f53  ; area of a single bar
.d a       = f54  ; depth of Whitney stress block
.d c       = f55  ; depth to the neutral axis
.c
.d β1      = f21
.d εc      = 0.003 ; assumed concrete compression strain at nominal strength.
.d εt      = f56
.d εy      = f57   ; yield strain
.d E       = 29e6  ; Young's modulus which is generally accepted to be 29,000 ksi for steel
.d σb      = f58   ; balanced ratio of steel to concrete
.d σ       = f59   ; working  ratio of steel to concrete
.d σ_min   = f60   ; working  ratio of steel to concrete
.d Ast     = f63   ; Total area of main steel re-bars
.d Ast_min = f64   ; minimum total area of main steel re-bars per ACI code
.d Av      = f65   ; 2 x Astirrup  (there are 2 legs at each stirrup location)
.d Vc      = f66   ; shear capacity of the concrete section
.d Vs      = f67   ; shear capacity of the stirrups

.c
User input:
 ---Material strength ---------------------------------
  Concrete Compressive Strength:   `f'c` = %v:6:0% psi
  Steel Yield Strength             `fy`  = %v:6:0% psi
  Young's modulus of steel         `E`   = %v:8% psi  
    
---Beam Dimensions -----------------------------------
  Total height of beam (overall)   `h`   = %v:6:2% in.
  Width of beam/compression zone   `b`   = %v:6:2% in.
    
---Main reinforcement steel --------------------------
  Bar size in 1/8" inc.          `barSz` = %v:4:0%
  number of bars                 `#Bar`  = %v:4:0%
  number of layers of main rebar `#Lay`  = %v:4:0%
  clear distance between layers  `dLay`  = %v:5:2%  in.

  Area of a single bar: `Area= pi * (barSz/8/2)^2`=%v:6:4% sq.in.

---Stirrup reinforcement steel -----------------------
  Stirrup size in 1/8" inc.     `stirSz` = %v:4:0%
  clear cover at beam bottom    `clrCov` = %v:5:2%
    
---Assumed values for design -----------------------------------
  Concrete compression strain at nominal strength `εc` = %v:6:4%
  
.m
-Next, we will calculate d, the depth from the extreme compression fiber
   to the center of reinforcement in the tensile zone.

    d = h - Clear Spacing - dstirrup   - dreinforcement/2
   `d = h - clrCov        - (stirSz/8) - (barSz/8/2)`    = %v:8:3% inches
.m
-Next, we want to use equilibrium to solve for a, the depth of the 
   Whitney stress block:

  - As a side note, the Whitney stress block refers to the method ACI 
    provides for approximating the stress in concrete under a given strain.
    This method was developed by an engineer name Charles Whitney,
    and was adopted by ACI in 1956.
    
               +-->|--+-----+   top of beam
    C -------->!-->|  a     |
               +-->|--+     |
                   |        |
                   |        d
                   |        |
                   |        |
                   |<-------+--- T     centroid of steel

    From the rules of equilibrium we know that C must equal T

    C = T

    C   = 0.85 * f'c * b * a
    
	- Defined in ACI section 10.2.7.1
	- b = width of compression zone
	- a = depth of Whitney stress block

   `tmp1= 0.85 *  f'c     *  b`        =  %v51:8:0% lb/in  (partial calc.)
    C   = 0.85 x ~f'c~psi x ~b~ in x a =  %v51:8:0% lb/in x a

    T = fs x As

	- fs = stress in the steel (we make the assumption that the 
	    steel yields, and will later confirm if it does).
	- As = area of tensile steel: `Ast = #Bar * Area`=%v:6:2% sq.in.

    Tension force in steel:
       `Tsteel =  fy        * (#Bar   *    Area)`
        T      = ~fy~ psi x (~#Bar~ x %v53:6:4% sq.in.) = %v52:8:0% lbs
    
    Solve for a:
     `a = Tsteel      / tmp1`          }=   %v:8:3% in.
      a =%v52:8:0% lb /%v51:8:2% lb/in }= %v54:8:3% in.
.m
- Now that we know the depth of the stress block, we can 
    calculate c, the depth to the neutral axis.

  From ACI 318 section 10.2.7.1:
    - a = β1 x c

    - β1 is a factor that relates the depth of the Whitney stress block to 
      the depth of the neutral axis based on the concrete strength.
      It is defined in 10.2.7.3

      β1 = 0.65 <= 0.85 - ((f'c - 4000psi)/1000)) x 0.05 <= 0.85
      
.c
.c `β1=0.85`   `f'c - 4000`
.g lt4000 eq4000 gt4000
.:gt4000
.c `β1 = 0.85 - 0.05 * (f'c-4000)/1000`     when   4000 ≤ f'c ≤ 8000
.:lt4000
.:eq4000
    Balance  Factor   `β1` = %v:6:3%

Solve for c:
   `c = a / β1` = %v:8:3% in.
.m
- With c, we can calculate the strain in the steel using similar triangles. 
    With this strain calculated, we can check our assumption that the steel 
    yields, and determine if the section is tension controlled

     c/εc = d/(εc + εt)

Solve for εt:
     εt = (d x εc)/c - εc
    `εt = (d * εc)/c - εc` = %v:8:4%
    
    note: The assumed concrete compression strain (εc) 
          was 0.003 at nominal strength.
.m
- Check our assumption that the steel yields, 
    and determine if the section is tension controlled:
    
    - Determine the strain at which the steel yields:

       E = fy/εy
       E = Young's modulus which is generally accepted 
             to be 29,000 ksi for steel = ~E~ psi
       fy = steel yield stress = ~fy~ psi
       εy = yield strain

  Solve for εy:
    `εy = fy / E`  = %v:8:5%

  Check if  εy < εt:
.c `εy - εt`
.g lt eq gt
.:eq
  *** ERROR: 
     The concrete yields when the steel yields.
     This condition is not allowed in the design process.
  ***
.g END END END  
.:gt
  *** ERROR: 
     The concrete yields before the steel.
     This condition is not allowed in the design process.
  ***
.g END END END
.:lt
   `εy`=%v:8:5% is less than
   `εt`=%v:8:5%
    Therefore our assumption that the steel yields is correct,
    and the stress in the steel may be taken as 60 ksi at failure.

- Determine if the section is tension controlled:
  - Per ACI section 10.3.4 a beam is considered tension controlled if the
    strain in the extreme tension steel is greater than 0.005.
  - The calculated steel strain in our section is `εt` = %v:8:5% 
.c `εt-0.005`
.g lt2 eq2 gt2
.:eq2
  *** ERROR:
   is equal than 0.005 therefore this beam section is NOT tension controlled.
   This condition is not allowed in the design process.
  ***
.g END END END  
.:lt2
  *** ERROR:
   is less than 0.005 therefore this beam section is NOT tension controlled.
   This condition is not allowed in the design process.
  ***
.g END END END  
.:gt2
    is greater than 0.005 therefore this beam section is tension controlled.
.m
- Next, let's determine if the beam section satisfies the minimum steel 
  requirements of ACI:
  - Per ACI section 10.5.1, the minimum steel requirement is:
    As, min = ((3 x sqrt(f'c))/fy) x bw x d   ≥  (200/fy) x bw x d
  - note: the `σ_min=200/fy`=%v:6:4% minimum controls when f'c < 4500 psi
  
  -`Ast_min = ((3*sqrt(f'c))/fy) * b * d`  =%v:5:2% sq.in.
  - Area of main reinforcement steel: `Ast`=%v:5:2% sq.in.
.c `Ast - Ast_min`
.g lt3 eq3 gt3
.:lt3
  *** ERROR:
    The minimum steel requirement is not satisfied.
    This condition is not allowed in the design process.
  ***
.g END END END  
.:eq3
.:gt3
  - Ast > Ast_min, therefore we satisfy the ACI minimum steel requirements.
.m
- Finally, let's calculate the nominal moment capacity of the section:
  Using moment equilibrium, we can calculate the moment capacity by taking
  the moment about the center of the tensile force, or the center of the
  compressive force.

               +-->|--+-----+   top of beam
    C -------->!-->|  a     |
               +-->|--+     |
                   |        |
                   |        d
                   |        |
                   |        |
                   |<-------+--- T   centroid of steel
                   
                 STRESS DIAGRAM
  
  Calculate the moment about the center of the compressive force:
    ΦMn = Φ x T x (d - a/2)
      - Φ = 0.9 for a tension controlled section per ACI 9.3.2.1
      - T = `Ast * fy` = %v:9:1% lbs
      
  ΦMn = `0.9 * Tsteel * (d-a/2)  /1000/12` = %v:8:1% kip feet

- Let's check our solution by calculating the nominal moment capacity 
  about the center of the tensile force.

  Calculate the moment about the center of the Tensile force:
    ΦMn = Φ x C x (d – a/2)
      - Φ = 0.9 for a tension controlled section per ACI 9.3.2.1
      - C = `0.85 * f'c * b * a` = %v:9:1% lbs
    
  ΦMn = `0.9 * 0.85 * f'c * b * a * (d-a/2)  /1000/12` = %v:8:1% kip feet
.m
- Now let's calculate the shear capacity of our section:
  Per ACI equation 11-2:
    ΦVn = Φ(Vc + Vs)
      - Φ = 0.75 per ACI section 9.3.2.3
      - Vc = shear capacity of the concrete section
      - Vs = shear capacity of the stirrups
      
    Vc = 2 x λ x squareroot(f'c) x bw x d   (ACI eqn 11-4)
      - λ = modification factor for lightweight concrete
        (See ACI section 8.6.1)

   `Vc = 2 * 1.0 * sqrt(f'c) * b * d` = %v:6:0% lbs

    Vs = (Av x fyt x d)/s (ACI eqn 11-15)
      - Av = 2 x Astir  (there are 2 legs at each stirrup location)
       `Av = 2 * pi * (stirSz/8/2)^2` = %v:6:2% sq.in.
       
   `Vs = (Av * fy * d) / 12` = %v:8:0% lbs

- Per ACI equation 11-2:
  ΦVn = Φ(Vc + Vs)
  ΦVn = `0.75 * (Vc + Vs)` = %v:8:0% lbs
.:END
.B
