* Creates an excel spreadsheet with tables for estimates of HHchange, all inclusive, for total and by race-ethnicity and by householder education

global results "$projdir/Results and Papers/Household Instability (PAA17)"
putexcel set "$results/HHChange.xlsx", sheet(HHchangeRaw) modify

tab adj_age anychange [aweight=WPFINWGT], matcell(agerels)

putexcel A1="Table A1. Household Change by Race-Ethnicity and Maternal Education"
putexcel A2=("Age") B2=("Total") C2=("By Race-Ethnicity") H2=("By Maternal Education")
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
  tab adj_age anychange [aweight=WPFINWGT] if first_raceth==`r', matcell(agerace`r')
  putexcel E`rw'=matrix(agerace`r')
  forvalues a=1/16 {
	local arw=`rw'+`a'-1
	putexcel G`arw'=formula(+4*F`arw'/(E`arw'+F`arw'))
  }
 }

putexcel H3=("No Change") I3=("Change") J3=("Annual Rate")

forvalues e=1/4 {
  local rw=(`e'-1)*17+4
  tab adj_age anychange [aweight=WPFINWGT] if momfirstced==`e', matcell(ageeduc`e')
  putexcel H`rw'=matrix(ageeduc`e')
  forvalues a=1/16 {
	local arw=`rw'+`a'-1
	putexcel J`arw'=formula(+4*I`arw'/(H`arw'+I`arw'))
  }
}
