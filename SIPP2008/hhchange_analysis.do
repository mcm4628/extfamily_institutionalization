* Creates an analysis file with demographic variables

use "$tempdir/hh_change", clear

keep SSUID EPPPNUM WPFINWGT* adj_age* addr_change* comp_change* adult_change* child_change* my_race

reshape long adj_age addr_change comp_change WPFINWGT adult_change child_change, i(SSUID EPPPNUM) j(SWAVE)

sort SSUID EPPPNUM SWAVE

merge m:1 SSUID EPPPNUM SWAVE using "$tempdir/demoperson08.dta"

tab TAGE _merge

keep if _merge==3

drop _merge

sort SSUID SHHADID SWAVE

merge m:1 SSUID SHHADID SWAVE using "$tempdir/demoHH08.dta"

keep if _merge==3

gen anychange=addr_change
replace anychange=1 if comp_change==1

keep if adj_age < 16

save "$tempdir/hhchange_analysis", replace

global results "$projdir/Results and Papers/Household Instability (PAA17)"
putexcel set "$results/HHChange.xlsx", sheet(HHchangeRaw) modify

tab adj_age anychange [aweight=WPFINWGT], matcell(agerels)

putexcel A1="Table A1. Household Change by Race-Ethnicity and Householder Education"
putexcel A2=("Age") B2=("Total") C2=("By Race-Ethnicity") H2=("By Householder Education")
putexcel B3=("No Change") C3=("Change") D3=("Annual Rate")
putexcel B4=matrix(agerels)

forvalues a=1/16 {
   local rw=`a'+3
   putexcel D`rw'=formula(+4*C`rw'/(B`rw'+C`rw'))
 }
 
local racegroups "NHWhite Black NHAsian NHOther Hispanic"

putexcel E3=("No Change") F3=("Change") G3=("Annual Rate")

forvalues r=1/5 {
  local rw=(`r'-1)*17+4
  tab adj_age anychange [aweight=WPFINWGT] if raceth==`r', matcell(agerace`r')
  putexcel E`rw'=matrix(agerace`r')
  forvalues a=1/16 {
	local arw=`rw'+`a'-1
	putexcel G`arw'=formula(+4*F`arw'/(E`arw'+F`arw'))
  }
 }

putexcel H3=("No Change") I3=("Change") J3=("Annual Rate")

forvalues e=1/4 {
  local rw=(`e'-1)*17+4
  tab adj_age anychange [aweight=WPFINWGT] if hheduc==`e', matcell(ageeduc`e')
  putexcel H`rw'=matrix(ageeduc`e')
  forvalues a=1/16 {
	local arw=`rw'+`a'-1
	putexcel J`arw'=formula(+4*I`arw'/(H`arw'+I`arw'))
  }
}
