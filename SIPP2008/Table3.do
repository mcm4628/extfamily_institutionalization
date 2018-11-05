use "$SIPP08keep/changebytype.dta", clear

* this doesn't really matter since comp_change is missing if SWAVE==15
drop if SWAVE==15

* limit to cases that have fully-observed intervals or we were able to infer hh_change
drop if insample==0

keep if adj_age < $adult_age 

gen par_educ=mom_educ
replace par_educ=dad_educ if missing(par_educ) 

*******************************************************************************
* Total
*******************************************************************************


global results "$projdir/Results and Papers/Household Instability (PAA17)"
putexcel set "$results/CompChangeType.xlsx", sheet(TypeChangeRaw) modify


* Parents
tab adj_age parent_change [aweight=WPFINWGT], matcell(agerels)

putexcel A1="Table 3A. Composition Change"
putexcel A2=("Age") B2=("Parent") E2=("Sibling") H2=("Other") K2=("Young Mom")
putexcel B3=("No Change") C3=("Change") D3=("Annual Rate")
putexcel B4=matrix(agerels)

forvalues a=1/18 {
   local rw=`a'+3
   putexcel D`rw'=formula(+3*C`rw'/(B`rw'+C`rw'))
 }

 * Siblings
tab adj_age sib_change [aweight=WPFINWGT], matcell(agerels)

putexcel E3=("No Change") F3=("Change") G3=("Annual Rate")
putexcel E4=matrix(agerels)

forvalues a=1/18 {
   local rw=`a'+3
   putexcel G`rw'=formula(+3*F`rw'/(E`rw'+F`rw'))
 }

* Others
tab adj_age other_change [aweight=WPFINWGT], matcell(agerels)

putexcel H3=("No Change") I3=("Change") J3=("Annual Rate")
putexcel H4=matrix(agerels)

forvalues a=1/18 {
   local rw=`a'+3
   putexcel J`rw'=formula(+3*I`rw'/(H`rw'+I`rw'))
 }

gen momlt30yrsolder=0 if !missing(biomom_age)
replace momlt30yrsolder=1 if !missing(biomom_age) & biomom_age-adj_age < 30

tab momlt30yrsolder, m

keep if momlt30yrsolder==1

tab adj_age parent_change [aweight=WPFINWGT], matcell(agerels)

putexcel K3=("No Change") L3=("Change") M3=("Annual Rate")
putexcel K4=matrix(agerels)
 
 forvalues a=1/18 {
   local rw=`a'+3
   putexcel M`rw'=formula(+3*L`rw'/(K`rw'+L`rw'))
 }

*******************************************************************************
* By Race
*******************************************************************************

putexcel set "$results/CompChangeType.xlsx", sheet(ByRaceRaw) modify
 
putexcel A1="Table 3B. Composition Change by Race-Ethnicity"
putexcel A2=("Age") B2=("Parent") E2=("Sibling") H2=("Other")

* Parents
putexcel B3=("No Change") C3=("Change") D3=("Annual Rate")

forvalues r=1/5 {
  local rw=(`r'-1)*18+4
  tab adj_age parent_change [aweight=WPFINWGT] if my_race==`r', matcell(agerels`r')
  putexcel B`rw'=matrix(agerels`r')
  forvalues a=1/18 {
	local arw=`rw'+`a'-1
	putexcel D`arw'=formula(+3*C`arw'/(B`arw'+C`arw'))
  }
 }
 
 * Siblings
 putexcel E3=("No Change") F3=("Change") G3=("Annual Rate")
 
 forvalues r=1/5 {
  local rw=(`r'-1)*18+4
  tab adj_age sib_change [aweight=WPFINWGT] if my_race==`r', matcell(agerels`r')
  putexcel E`rw'=matrix(agerels`r')
  forvalues a=1/18 {
	local arw=`rw'+`a'-1
	putexcel G`arw'=formula(+3*F`arw'/(F`arw'+E`arw'))
  }
 }
 
 * Other
 putexcel H3=("No Change") I3=("Change") J3=("Annual Rate")
 
 forvalues r=1/5 {
  local rw=(`r'-1)*18+4
  tab adj_age other_change [aweight=WPFINWGT] if my_race==`r', matcell(agerels`r')
  forvalues a=1/18 {
	local arw=`rw'+`a'-1
	putexcel J`arw'=formula(+3*I`arw'/(H`arw'+I`arw'))
  }
 }
 
*******************************************************************************
* By Parental Educ
*******************************************************************************

putexcel A1="Table 3C. Composition Change by Parental Education"
putexcel A2=("Age") B2=("Parent") E2=("Sibling") H2=("Other")
putexcel set "$results/CompChangeType.xlsx", sheet(ByPedRaw) modify

* Parents
putexcel B3=("No Change") C3=("Change") D3=("Annual Rate")

forvalues r=1/5 {
  local rw=(`r'-1)*18+4
  tab adj_age parent_change [aweight=WPFINWGT] if par_educ==`r', matcell(agerels`r')
  putexcel B`rw'=matrix(agerels`r')
  forvalues a=1/18 {
	local arw=`rw'+`a'-1
	putexcel D`arw'=formula(+3*C`arw'/(B`arw'+C`arw'))
  }
 }
 
 * Siblings
 putexcel E3=("No Change") F3=("Change") G3=("Annual Rate")
 
 forvalues r=1/5 {
  local rw=(`r'-1)*18+4
  tab adj_age sib_change [aweight=WPFINWGT] if par_educ==`r', matcell(agerels`r')
  putexcel E`rw'=matrix(agerels`r')
  forvalues a=1/18 {
	local arw=`rw'+`a'-1
	putexcel G`arw'=formula(+3*F`arw'/(E`arw'+F`arw'))
  }
 }
 
 * Other
 putexcel H3=("No Change") I3=("Change") J3=("Annual Rate")
 
 forvalues r=1/5 {
  local rw=(`r'-1)*18+4
  tab adj_age other_change [aweight=WPFINWGT] if par_educ==`r', matcell(agerels`r')
  putexcel H`rw'=matrix(agerels`r')
  forvalues a=1/18 {
	local arw=`rw'+`a'-1
	putexcel J`arw'=formula(+3*I`arw'/(H`arw'+I`arw'))
  }
 }
 