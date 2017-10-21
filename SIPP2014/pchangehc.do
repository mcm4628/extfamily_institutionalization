use "$SIPP2014data/selected.dta", clear

keep ssuid pnum epnspous_ehc epncohab_ehc monthcode

reshape wide epnspous_ehc epncohab_ehc, i(ssuid pnum) j(monthcode)

tab epncohab_ehc1

gen anycoh=0
gen anyspo=0

gen diffcoh=0
gen diffspo=0

forvalues i=1/12{
replace anycoh=1 if epncohab_ehc`i' !=.
replace anyspo=1 if epnspous_ehc`i' !=.

tab anyspo
}

forvalues i=1/11{
local j=`i'+1
replace diffcoh=1 if epncohab_ehc`i' != epncohab_ehc`j' 
replace diffspo=1 if epnspous_ehc`i' != epnspous_ehc`j' 
}

tab anycoh diffcoh
tab anyspo diffspo

keep ssuid pnum anycoh anyspo diffcoh diffspo 

save "$tempdir/pchangehc.dta", replace
