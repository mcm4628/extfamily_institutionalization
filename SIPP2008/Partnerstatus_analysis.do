*****************************
* This file analyzes data created by partnerstatus.do
* 
use "$tempdir/partner_type", clear

merge m:1 SSUID EPPPNUM SWAVE using "$tempdir/demoperson08.dta"

tab year adj_age

tab partner_type adj_age

tab partner_type adj_age [aweight=WPFINWGT]

keep if year > 2008
keep if year < 2013

keep if partner_type==0 & !missing(partrans)
* limit to those single at the start of period

keep if adj_age > 19 & adj_age < 25
* focus on young adults

global results "$projdir/Results and Papers\Union Formation Trends"
putexcel set "$results/union.xlsx", sheet(unionRAW SIPP) modify

tab year partrans [aweight=WPFINWGT], matcell(yeartrans)

putexcel A1="Table A1. Transitions into cohabitation/marriage by year"
putexcel A2=("year") B2=("No Transition") C2=("Single to Cohab") D2=("Single to Marriage") E2=("Any Union") F2=("Total")
putexcel B3=matrix(yeartrans)

forvalues y=1/6 {
   local rw=`y'+2
   putexcel E`rw'=formula(+C`rw'+D`rw')
   putexcel F`rw'=formula(+B`rw'+E`rw')
 }
 
local racegroups "NHWhite Black NHAsian NHOther Hispanic"

