* This creates a data file with one observation per person
* with person-number of all spouses and cohabiting persons
*
* These variables are epncohab_ehcX and epnspous_ehcX where X refers to the 
* month. I also created epnspco_ehcX so that I can avoid counting transitions
* from cohabitation to marriage, something we'd rather not catch.
*
* Obviously, to link to children one also needs the person-number of parent(s)

use "$SIPP2014data/selected.dta", clear

keep ssuid pnum epnspous_ehc epncohab_ehc monthcode

reshape wide epnspous_ehc epncohab_ehc, i(ssuid pnum) j(monthcode)

* I checked to see whether anyone has both a spouse and a cohabitor in the same month and that person is different. No cases 
*gen twospco=0
*forvalues i=1/12{
*replace twospco=1 if epncohab_ehc`i' != epnspous_ehc`i' & epncohab_ehc`i' > 10 & epncohab_ehc`i' < 999 & epnspous_ehc`i' > 10 & epnspous_ehc`i' < 999
*}
*tab twospco

* So, creating an array with person-number of spouse/cohabitor

forvalues i=1/12{
gen epnspco_ehc`i'=999
replace epnspco_ehc`i'=epncohab_ehc`i' if epncohab_ehc`i' > 10 & epncohab_ehc`i' < 999
replace epnspco_ehc`i'=epnspous_ehc`i' if epnspous_ehc`i' > 10 & epnspous_ehc`i' < 999
}

tab epncohab_ehc1 epnspco_ehc1

gen anycoh=0
gen anyspo=0
gen anyspco=0

gen diffcoh=0
gen diffspo=0

forvalues i=1/12{
replace anycoh=1 if epncohab_ehc`i' !=.
replace anyspo=1 if epnspous_ehc`i' !=.
replace anyspco=1 if epnspco_ehc`i' !=999 & epnspco_ehc`i' !=.
}
tab anyspo anyspco


forvalues i=1/11{
local j=`i'+1
replace diffcoh=1 if epnspco_ehc`i' != epnspco_ehc`j' 
replace diffspo=1 if epnspous_ehc`i' != epnspous_ehc`j' 
}

tab anycoh diffcoh
tab anyspo diffspo

keep ssuid pnum anycoh anyspo anyspco diffcoh diffspo epnspco_ehc*

save "$tempdir/pchangehc.dta", replace
