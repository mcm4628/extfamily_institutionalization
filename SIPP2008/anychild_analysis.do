* Creates an file for analysis of comp change, focusing only on comp changes involving a parent
* This is merging in anychild_change, which comes from changer_rels

* Note that hh_change is a sample of people who are ever adj_age < $adult_age
* About .25% of the observations are at age 25 or older because of dirty data in the SIPP. 


use "$tempdir/hh_change", clear

keep SSUID EPPPNUM WPFINWGT* SHHADID* adj_age* addr_change* comp_change* adult_change* child_change* my_race

reshape long adj_age addr_change comp_change WPFINWGT adult_change child_change SHHADID, i(SSUID EPPPNUM) j(SWAVE)

sort SSUID EPPPNUM SWAVE

merge m:1 SSUID EPPPNUM SWAVE using "$tempdir/demo08.dta"
* allwaves will have race and sex

keep if _merge==3 | comp_change==1 | addr_change==1

drop _merge

sort SSUID EPPPNUM SWAVE

merge 1:1 SSUID EPPPNUM SWAVE using "$tempdir/anychild_change"

gen no_change=1 if _merge ==1
replace no_change=0 if missing(no_change)

drop _merge

replace anychild=0 if no_change==1

keep if adj_age < 17

gen childchange=1 if comp_change==1 & anychild==1
replace childchange=0 if comp_change==0 | anychild==0

save "$tempdir/anychild_analysis", replace

tab comp_change childchange

global results "$projdir/Results and Papers/Household Instability (PAA17)"
putexcel set "$results/HHChange.xlsx", sheet(childchangeRaw) modify

tab adj_age childchange [aweight=WPFINWGT], matcell(agerels)

putexcel A1="Table A4. Child/Parent Change by Race-Ethnicity and Maternal Education"
putexcel A2=("Age") B2=("Total") C2=("By Race-Ethnicity") H2=("By Maternal Education")
putexcel B3=("No Change") C3=("Change") D3=("Annual Rate")
putexcel B4=matrix(agerels)

forvalues a=1/17 {
   local rw=`a'+3
   putexcel D`rw'=formula(+4*C`rw'/(B`rw'+C`rw'))
 }
 
local racegroups "NHWhite Black NHAsian NHOther Hispanic"

putexcel E3=("No Change") F3=("Change") G3=("Annual Rate")

forvalues r=1/5 {
  local rw=(`r'-1)*18+4
  tab adj_age childchange [aweight=WPFINWGT] if first_raceth==`r', matcell(agerace`r')
  putexcel E`rw'=matrix(agerace`r')
  forvalues a=1/17 {
	local arw=`rw'+`a'-1
	putexcel G`arw'=formula(+3*F`arw'/(E`arw'+F`arw'))
  }
 }

putexcel H3=("No Change") I3=("Change") J3=("Annual Rate")

forvalues e=1/4 {
  local rw=(`e'-1)*18+4
  tab adj_age childchange [aweight=WPFINWGT] if momfirstced==`e', matcell(ageeduc`e')
  putexcel H`rw'=matrix(ageeduc`e')
  forvalues a=1/17 {
	local arw=`rw'+`a'-1
	putexcel J`arw'=formula(+3*I`arw'/(H`arw'+I`arw'))
  }
}

tab first_raceth
tab momfirstced

sort SSUID EPPPNUM

duplicates drop SSUID EPPPNUM, force

tab first_raceth
tab momfirstced
