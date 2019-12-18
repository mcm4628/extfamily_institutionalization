*This file creates a sample describing first transition into dropout by year/wave
*household changes refer to changes happened in previous year
*household composition and poverty status are situations at the beginning of each year (before hh changes could happen)

~~~~
<<dd_do: quietly>>

*************************************************************************
* Create dropout sample
*************************************************************************
    *collapse dropout and high school graduation by year
	   use "$tempdir/dropout.dta", clear
	   drop dropout 

	   merge 1:1 SSUID PNUM panelmonth using "$tempdir/dropout_adjust.dta"

	   keep if _merge==3
	   drop _merge
	   
	*********** create indicator of high school graduation *********
	gen hsgrad= (educ==2) if !missing(educ)

	xtset idnum panelmonth
	collapse (sum) dropout hsgrad (firstnm) par_ed_first my_racealt my_sex adj_age SSUID, by(idnum swave)
    recode dropout 1/max=1
    recode hsgrad 1/max=1
	
	* Identify first observation of the individual.
	bysort idnum: gen dropout_base=1 if swave==1 & dropout==1
	bysort idnum: gen hsgrad_base=1 if swave==1 & hsgrad==1


	* Mark for deletion all observations for individuals
	* that originated as a dropout or high school graduate
	by idnum: carryforward(dropout_base),replace
	by idnum: carryforward(hsgrad_base),replace

    drop if dropout_base==1 | hsgrad_base==1
	
   *tag first dropout wave 
	  sort idnum swave
	  egen tag_dropout=tag (idnum dropout)
	  replace tag_dropout=0 if tag_dropout==1 & dropout==0
	  tab tag_dropout

   *tag wave of high school graduation
	 sort idnum swave
	 egen tag_hsgrad=tag (idnum hsgrad)
	 replace tag_hsgrad=0 if tag_hsgrad==1 & hsgrad==0
	 tab tag_hsgrad

	 *identify wave of first dropout and carry forward/backward
	  sort idnum swave 
	  gen wave_firstd = swave if tag_dropout==1
	  by idnum: carryforward(wave_firstd), replace	
	  gsort idnum -swave 
	  by idnum: carryforward(wave_firstd), replace	
	  sort idnum swave

	  *identify wave of first hsgrad and carry forward/backward
	  gen wave_firstg = swave if tag_hsgrad==1
	  by idnum: carryforward(wave_firstg), replace	
	  gsort idnum -swave 
	  by idnum: carryforward(wave_firstg), replace	
	  sort idnum swave

	  gen censorwave=min(wave_firstg, wave_firstd)

   *drop months that come after the first dropout or hsgrad
   * (create a censored sample)
      keep if swave<=censorwave
	
      save "$tempdir/dropout_year.dta", replace
	
    *household composition by year
     use "$SIPP14keep/HHComp_pm.dta", clear
	
     egen id = concat (SSUID PNUM)
	 destring id, gen(idnum)
	 format idnum %20.0f

	 drop id
	 
	 sort idnum panelmonth
	 
	 gen swave=floor((panelmonth+11)/12)
	 *create poverty status
	gen cpov=.
	replace cpov=1 if THINCPOVT2 <= .5
	replace cpov=2 if THINCPOVT2 > .5 &  THINCPOVT2 <=1
	replace cpov=3 if THINCPOVT2 > 1 &  THINCPOVT2 <=2
	replace cpov=4 if THINCPOVT2 >2
	
	 *create poverty status, household composition at first nonmissing observation
	 local bvar cpov parcomp sibcomp extend
	 
	 foreach var in `bvar'{
     by idnum: gen countnonmissing_`var' = sum(!missing(`var')) if !missing(`var')
     bysort idnum (countnonmissing_`var') : gen firstnm_`var' =`var'[1] 
	 } 
	 
	 collapse (firstnm) firstnm_parcomp firstnm_sibcomp firstnm_extend firstnm_cpov parcomp sibcomp extend cpov, by(idnum swave)
	 save "$tempdir/hhcomp_year.dta", replace
		
    *merge back education data
     use "$tempdir/dropout_year.dta", clear
	 
     merge 1:1 idnum swave using "$tempdir/annual_instability"
	 keep if _merge==3
     drop _merge
	 
	 merge 1:1 idnum swave using "$tempdir/hhcomp_year.dta"
     keep if _merge==3 
     drop _merge
	 
     save "$tempdir/outcome_year.dta", replace
	
	
    use "$tempdir/outcome_year.dta", clear
	*recode missing independent variables
	gen age_s=adj_age*adj_age
    recode parcomp .=5
    recode par_ed_first .=5
<</dd_do>>
~~~~





~~~~
<<dd_do>>

*describe 
    tab parent_changeY dropout,row
    tab sib_changeY dropout,row
    tab other_changeY dropout,row
	
<</dd_do>>
~~~~

~~~~
<<dd_do>>

*****models****
   *household composition and dropout
logit dropout i.parcomp i.sibcomp i.extend i.cpov i.adj_age my_sex i.par_ed_first i.my_racealt, cluster (SSUID)

   *household composition change and dropout
logit dropout parent_changeY sib_changeY other_changeY i.adj_age my_sex i.par_ed_first i.my_racealt, cluster (SSUID)

   *household composition change and dropout while controling for hh composition
logit dropout parent_changeY sib_changeY other_changeY i.parcomp i.sibcomp i.extend i.cpov i.adj_age my_sex i.par_ed_first i.my_racealt, cluster (SSUID)

   *type of sibling change
logit dropout parent_changeY biosib_changeY halfsib_changeY stepsib_changeY other_changeY i.parcomp i.sibcomp i.extend i.cpov i.adj_age my_sex i.par_ed_first i.my_racealt, cluster (SSUID)

<</dd_do>>
~~~~


	
	