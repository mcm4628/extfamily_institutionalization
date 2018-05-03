* This program determines the marital-cohabitation status of individuals age 17-25.
*
* It starts with data files created by do_all that have partner status based on household roster, each individual's relationship to head and
* parent and spouse pointers. This is the partner_type_tc0 file (based on base relationships). partner_type_tc1 adds infomation gleaned from 
* transitive closure. That is, I can guess that A and C are partners if both A and C are parents of B (and not married). 

local min_age 17
local max_age 25

/**** 
* Merging two baseline and transive measures of marital-cohabitation status into one file
* to create a combined measure                                                  
*/

use "$tempdir/partner_type_tc1", clear

sort SSUID EPPPNUM SWAVE

save "$tempdir/partner_type_tc1", replace

use "$tempdir/partner_type_tc0", clear

rename partner_type partner_type0

drop adj_age

sort SSUID EPPPNUM SWAVE

merge 1:1 SSUID EPPPNUM SWAVE using "$tempdir/partner_type_tc1"

drop _merge

rename partner_type partner_type1

tab partner_type1 partner_type0

* Use base relationships value except when transitive closure identified a partnership. 
gen partner_type=partner_type0
replace partner_type=1 if partner_type0==0 & partner_type1==1

tab partner_type

sort SSUID EPPPNUM SWAVE

save "$tempdir/partner_type", replace

* Adding the weight variable 

use "$tempdir/person_wide_adjusted_ages", clear

keep SSUID EPPPNUM SHHADID* WPFINWGT* mom_educ1

reshape long SHHADID WPFINWGT, i(SSUID EPPPNUM) j(SWAVE)

sort SSUID EPPPNUM SWAVE

merge 1:1 SSUID EPPPNUM SWAVE using "$tempdir/partner_type"

keep if _merge==3

drop partner_type0 partner_type1 _merge

reshape wide SHHADID adj_age WPFINWGT partner_type, i(SSUID EPPPNUM) j(SWAVE)

/*****
* identifying partner transitions
*/

forvalues w=1/14{
local x=`w'+1
gen partrans`w'=0 if partner_type`w'==partner_type`x'
replace partrans`w'=1 if partner_type`w'==0 & partner_type`x'==1
replace partrans`w'=2 if partner_type`w'==0 & partner_type`x'==2
replace partrans`w'=3 if partner_type`w'==1 & partner_type`x'==2
replace partrans`w'=4 if partner_type`w'==1 & partner_type`x'==0
replace partrans`w'=5 if partner_type`w'==2 & partner_type`x'==0
replace partrans`w'=0 if partner_type`w'==2 & partner_type`x'==1
}

/******
* Create a long file where every observation represents an interval between waves
*/

reshape long SHHADID adj_age WPFINWGT partner_type partrans, i(SSUID EPPPNUM) j(SWAVE)

gen year=2008 if SWAVE==1
replace year=2009 if SWAVE >= 2 & SWAVE <= 4
replace year=2010 if SWAVE >= 5 & SWAVE <= 7
replace year=2011 if SWAVE >= 8 & SWAVE <= 10
replace year=2012 if SWAVE >= 11 & SWAVE <= 13
replace year=2013 if SWAVE >= 14 & SWAVE <= 15

label var partrans "marital-cohabitation transition type this wave to next"

label define partrans 0 "No change" ///
					  1 "Single to cohabitation" ///
					  2 "Single to marriage" ///
					  3 "Cohabitation to marriage" ///
					  4 "Cohabitation to single" ///
					  5 "Married to single" ///
					  6 "Married to cohabitation"
					  
label values partrans partrans


save "$tempdir/partner_type", replace

