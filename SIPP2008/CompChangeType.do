use "$tempdir/changebytype.dta", clear

keep if adj_age < 18

global results "$projdir/Results and Papers/Household Instability (PAA17)"
putexcel set "$results/CompChangeType.xlsx", sheet(ParentChangeRaw) modify

tab adj_age parent_change [aweight=WPFINWGT], matcell(agerels)

putexcel A1="Table B1. Composition Change by Race-Ethnicity and Maternal Education"
putexcel A2=("Age") B2=("Parent") E2=("Sibling") H2=("Other") K2=("Young Mom")
putexcel B3=("No Change") C3=("Change") D3=("Annual Rate")
putexcel B4=matrix(agerels)

forvalues a=1/18 {
   local rw=`a'+3
   putexcel D`rw'=formula(+3*C`rw'/(B`rw'+C`rw'))
 }

tab adj_age sib_change [aweight=WPFINWGT], matcell(agerels)

putexcel E3=("No Change") F3=("Change") G3=("Annual Rate")
putexcel E4=matrix(agerels)

forvalues a=1/18 {
   local rw=`a'+3
   putexcel G`rw'=formula(+3*F`rw'/(E`rw'+F`rw'))
 }
 
tab adj_age other_change [aweight=WPFINWGT], matcell(agerels)

putexcel H3=("No Change") I3=("Change") J3=("Annual Rate")
putexcel H4=matrix(agerels)

forvalues a=1/18 {
   local rw=`a'+3
   putexcel J`rw'=formula(+3*I`rw'/(H`rw'+I`rw'))
 }
 
keep if biomom_age < 30
 
tab adj_age parent_change [aweight=WPFINWGT], matcell(agerels)

putexcel K3=("No Change") L3=("Change") M3=("Annual Rate")
putexcel K4=matrix(agerels)
 
 forvalues a=1/18 {
   local rw=`a'+3
   putexcel M`rw'=formula(+3*L`rw'/(K`rw'+L`rw'))
 }
 
 /*
 
 
local racegroups "NHWhite Black NHAsian NHOther Hispanic"

putexcel E3=("No Change") F3=("Change") G3=("Annual Rate")

forvalues r=1/5 {
  local rw=(`r'-1)*18+4
  tab adj_age comp_change [aweight=WPFINWGT] if my_race==`r', matcell(agerace`r')
  putexcel E`rw'=matrix(agerace`r')
  forvalues a=1/17 {
	local arw=`rw'+`a'-1
	putexcel G`arw'=formula(+3*F`arw'/(E`arw'+F`arw'))
  }
 }

putexcel H3=("No Change") I3=("Change") J3=("Annual Rate")

forvalues e=1/4 {
  local rw=(`e'-1)*18+4
  tab adj_age comp_change [aweight=WPFINWGT] if mom_educ==`e', matcell(ageeduc`e')
  putexcel H`rw'=matrix(ageeduc`e')
  forvalues a=1/17 {
	local arw=`rw'+`a'-1
	putexcel J`arw'=formula(+3*I`arw'/(H`arw'+I`arw'))
  }
}
