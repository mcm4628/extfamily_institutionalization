use "$SIPP08keep/changebytype.dta", clear

* this doesn't really matter since comp_change is missing if SWAVE==15
drop if SWAVE==15

* limit to cases that have fully-observed intervals or we were able to infer hh_change
drop if insample==0

keep if adj_age < $adult_age 

*******************************************************************************
* Total
*******************************************************************************

global results "$projdir/Results and Papers/Household Instability (PAA17)"
putexcel set "$results/CompChangeType.xlsx", sheet(TypeChangeRaw) modify


* Parents
tab adj_age parent_change [aweight=WPFINWGT], matcell(agerels)

putexcel A1="Table 3A. Composition Change"
putexcel A2=("Age") B2=("Parent") E2=("Sibling") H2=("Other") K2=("Young Mom") N2=("Grandparent") Q2=("Nonrelative") T2=("Other Rel") W2=("partner/child")
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

 * Moms less than 30 years old at child's birth
gen momlt30yrsolder=0 if !missing(biomom_age)
replace momlt30yrsolder=1 if !missing(biomom_age) & biomom_age-adj_age < 30

tab momlt30yrsolder, m

preserve

keep if momlt30yrsolder==1

tab adj_age parent_change [aweight=WPFINWGT], matcell(agerels)

putexcel K3=("No Change") L3=("Change") M3=("Annual Rate")
putexcel K4=matrix(agerels)
 
 forvalues a=1/18 {
   local rw=`a'+3
   putexcel M`rw'=formula(+3*L`rw'/(K`rw'+L`rw'))
 }

restore 
 
* Grandparents

tab adj_age gp_change [aweight=WPFINWGT], matcell(agerels)

putexcel N3=("No Change") O3=("Change") P3=("Annual Rate")
putexcel N4=matrix(agerels)

forvalues a=1/18 {
   local rw=`a'+3
   putexcel P`rw'=formula(+3*O`rw'/(N`rw'+O`rw'))
 }

* Nonrelatives

tab adj_age nonrel_change [aweight=WPFINWGT], matcell(agerels)

putexcel Q3=("No Change") R3=("Change") S3=("Annual Rate")
putexcel Q4=matrix(agerels)

forvalues a=1/18 {
   local rw=`a'+3
   putexcel S`rw'=formula(+3*R`rw'/(Q`rw'+R`rw'))
 }
 
 * Other relatives (relatives not parents, siblings, children, spouses, or grandparents

tab adj_age otherrel_change [aweight=WPFINWGT], matcell(agerels)

putexcel T3=("No Change") U3=("Change") V3=("Annual Rate")
putexcel T4=matrix(agerels)

forvalues a=1/18 {
   local rw=`a'+3
   putexcel V`rw'=formula(+3*U`rw'/(T`rw'+U`rw'))
 }
 
* All else including children, spouses, partners, and foster

tab adj_age allelse_change [aweight=WPFINWGT], matcell(agerels)

putexcel W3=("No Change") X3=("Change") Y3=("Annual Rate")
putexcel W4=matrix(agerels)

forvalues a=1/18 {
   local rw=`a'+3
   putexcel Y`rw'=formula(+3*X`rw'/(W`rw'+X`rw'))
 }
 
*******************************************************************************
* By Race
*******************************************************************************

putexcel set "$results/CompChangeType.xlsx", sheet(ByRaceRaw) modify
 
putexcel A1="Table 3B. Composition Change by Race-Ethnicity"
putexcel A2=("Age") B2=("Parent") E2=("Sibling") H2=("Other") K2=("Grandparent") N2=("Nonrelative") Q2=("Other Rel")

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
  putexcel H`rw'=matrix(agerels`r')
  forvalues a=1/18 {
	local arw=`rw'+`a'-1
	putexcel J`arw'=formula(+3*I`arw'/(H`arw'+I`arw'))
  }
 }
 
  * Grandparent
 putexcel K3=("No Change") L3=("Change") M3=("Annual Rate")
 
 forvalues r=1/5 {
  local rw=(`r'-1)*18+4
  tab adj_age gp_change [aweight=WPFINWGT] if my_race==`r', matcell(agerels`r')
  putexcel K`rw'=matrix(agerels`r')
  forvalues a=1/18 {
	local arw=`rw'+`a'-1
	putexcel M`arw'=formula(+3*L`arw'/(K`arw'+L`arw'))
  }
 }
 
  * non relatives (including foster)
 putexcel N3=("No Change") O3=("Change") P3=("Annual Rate")
 
 forvalues r=1/5 {
  local rw=(`r'-1)*18+4
  tab adj_age nonrel_change [aweight=WPFINWGT] if my_race==`r', matcell(agerels`r')
  putexcel N`rw'=matrix(agerels`r')
  forvalues a=1/18 {
	local arw=`rw'+`a'-1
	putexcel P`arw'=formula(+3*O`arw'/(N`arw'+O`arw'))
  }
 }
 
 * Other relatives (relatives not parents, siblings, children, spouses, or grandparents
 putexcel Q3=("No Change") R3=("Change") S3=("Annual Rate")
 
 forvalues r=1/5 {
  local rw=(`r'-1)*18+4
  tab adj_age otherrel_change [aweight=WPFINWGT] if my_race==`r', matcell(agerels`r')
  putexcel Q`rw'=matrix(agerels`r')
  forvalues a=1/18 {
	local arw=`rw'+`a'-1
	putexcel S`arw'=formula(+3*R`arw'/(Q`arw'+R`arw'))
  }
 }
*******************************************************************************
* By Parental Educ
*******************************************************************************

putexcel A1="Table 3C. Composition Change by Parental Education"
putexcel A2=("Age") B2=("Parent") E2=("Sibling") H2=("Other") K2=("Grandparent") N2=("Nonrelative") Q2=("Other Rel")
putexcel set "$results/CompChangeType.xlsx", sheet(ByPedRaw) modify

* Parents
putexcel B3=("No Change") C3=("Change") D3=("Annual Rate")

forvalues r=1/5 {
  local rw=(`r'-1)*18+4
  tab adj_age parent_change [aweight=WPFINWGT] if par_ed_first==`r', matcell(agerels`r')
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
  tab adj_age sib_change [aweight=WPFINWGT] if par_ed_first==`r', matcell(agerels`r')
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
  tab adj_age other_change [aweight=WPFINWGT] if par_ed_first==`r', matcell(agerels`r')
  putexcel H`rw'=matrix(agerels`r')
  forvalues a=1/18 {
	local arw=`rw'+`a'-1
	putexcel J`arw'=formula(+3*I`arw'/(H`arw'+I`arw'))
  }
 }
 
   * Grandparent
 putexcel K3=("No Change") L3=("Change") M3=("Annual Rate")
 
 forvalues r=1/5 {
  local rw=(`r'-1)*18+4
  tab adj_age gp_change [aweight=WPFINWGT] if par_ed_first==`r', matcell(agerels`r')
  putexcel K`rw'=matrix(agerels`r')
  forvalues a=1/18 {
	local arw=`rw'+`a'-1
	putexcel M`arw'=formula(+3*L`arw'/(K`arw'+L`arw'))
  }
 }
 
  * non relatives (including foster)
 putexcel N3=("No Change") O3=("Change") P3=("Annual Rate")
 
 forvalues r=1/5 {
  local rw=(`r'-1)*18+4
  tab adj_age nonrel_change [aweight=WPFINWGT] if par_ed_first==`r', matcell(agerels`r')
  putexcel N`rw'=matrix(agerels`r')
  forvalues a=1/18 {
	local arw=`rw'+`a'-1
	putexcel P`arw'=formula(+3*O`arw'/(N`arw'+O`arw'))
  }
 }
 
 * Other relatives (relatives not parents, siblings, children, spouses, or grandparents
 putexcel Q3=("No Change") R3=("Change") S3=("Annual Rate")
 
 forvalues r=1/5 {
  local rw=(`r'-1)*18+4
  tab adj_age otherrel_change [aweight=WPFINWGT] if par_ed_first==`r', matcell(agerels`r')
  putexcel Q`rw'=matrix(agerels`r')
  forvalues a=1/18 {
	local arw=`rw'+`a'-1
	putexcel S`arw'=formula(+3*R`arw'/(Q`arw'+R`arw'))
  }
 }
 
 *******************************************************************************
* By Race
*******************************************************************************

putexcel set "$results/CompChangeType.xlsx", sheet(ByAltRaceRaw) modify
 
putexcel A1="Table 3B. Composition Change by Race-Ethnicity"
putexcel A2=("Age") B2=("Parent") E2=("Sibling") H2=("Other") K2=("Grandparent") N2=("Nonrelative") Q2=("Other Rel")

* Parents
putexcel B3=("No Change") C3=("Change") D3=("Annual Rate")

forvalues r=1/5 {
  local rw=(`r'-1)*18+4
  tab adj_age parent_change [aweight=WPFINWGT] if my_racealt==`r', matcell(agerels`r')
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
  tab adj_age sib_change [aweight=WPFINWGT] if my_racealt==`r', matcell(agerels`r')
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
  tab adj_age other_change [aweight=WPFINWGT] if my_racealt==`r', matcell(agerels`r')
  putexcel H`rw'=matrix(agerels`r')
  forvalues a=1/18 {
	local arw=`rw'+`a'-1
	putexcel J`arw'=formula(+3*I`arw'/(H`arw'+I`arw'))
  }
 }
 
  * Grandparent
 putexcel K3=("No Change") L3=("Change") M3=("Annual Rate")
 
 forvalues r=1/5 {
  local rw=(`r'-1)*18+4
  tab adj_age gp_change [aweight=WPFINWGT] if my_racealt==`r', matcell(agerels`r')
  putexcel K`rw'=matrix(agerels`r')
  forvalues a=1/18 {
	local arw=`rw'+`a'-1
	putexcel M`arw'=formula(+3*L`arw'/(K`arw'+L`arw'))
  }
 }
 
  * non relatives (including foster)
 putexcel N3=("No Change") O3=("Change") P3=("Annual Rate")
 
 forvalues r=1/5 {
  local rw=(`r'-1)*18+4
  tab adj_age nonrel_change [aweight=WPFINWGT] if my_racealt==`r', matcell(agerels`r')
  putexcel N`rw'=matrix(agerels`r')
  forvalues a=1/18 {
	local arw=`rw'+`a'-1
	putexcel P`arw'=formula(+3*O`arw'/(N`arw'+O`arw'))
  }
 }
 
 * Other relatives (relatives not parents, siblings, children, spouses, or grandparents
 putexcel Q3=("No Change") R3=("Change") S3=("Annual Rate")
 
 forvalues r=1/5 {
  local rw=(`r'-1)*18+4
  tab adj_age otherrel_change [aweight=WPFINWGT] if my_racealt==`r', matcell(agerels`r')
  putexcel Q`rw'=matrix(agerels`r')
  forvalues a=1/18 {
	local arw=`rw'+`a'-1
	putexcel S`arw'=formula(+3*R`arw'/(Q`arw'+R`arw'))
  }
 }
