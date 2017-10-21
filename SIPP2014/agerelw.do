*Make it possible to relate the age variables to the relationship to householder variables.
*For every person in the household create a new variable agerrel`i' that equals age
* where `i' indexes the same person as in the rrel`i' variables.
*****
* code uses hhcompagemX to identify age for those in household at time of interview (type 1 people) 
* in this program `i' corresponds to `i' in rrel`i' and rrel`i'_pnum variables.
*
* to get age of those not in household at time of interview (type 2 people)
* we need to look at the ET2_LNO`s' and T2_age`s' variables
* so, to start, we'll create a small file with just these variables, one for 
* each month (1,4,8,& 12) 

use "$SIPP2014data/selected.dta", clear

keep ssuid pnum monthcode et2_ln* tt2_age*

forvalues s=1/10 {
	tostring et2_lno`s', gen(set2_lno`s')
	recode tt2_age`s' (0=0)(1/17=1)(18/29=2)(30/64=3)(65/90=4)
}

preserve

keep if monthcode==1

save "$tempdir/t2age1.dta", replace

restore
preserve

keep if monthcode==4

save "$tempdir/t2age4.dta", replace

restore
preserve

keep if monthcode==8

save "$tempdir/t2age8.dta", replace

restore

keep if monthcode==12

save "$tempdir/t2age12.dta", replace



********************************************************************************
* now matching rre_pnums to et2lno for type 2 people and to scagem1_pnums for type 1 people
********************************************************************************

use "$tempdir/hhcompm1.dta", clear

merge 1:1 ssuid pnum using "$tempdir/t2age1.dta"

drop _merge

merge m:1 ssuid eresidenceid1 using "$tempdir/hhcompagem1.dta"

drop _merge

forvalues i=1/30 {
    gen agerrelm1_`i'=99
	forvalues s=1/10 {
		replace agerrelm1_`i'=tt2_age`s' if sm1rrel_pnum`i'==set2_lno`s' & et2_lno`s' >= 60 & et2_lno`s' < 70
		}
	forvalues h=1/19 {
		replace agerrelm1_`i'=cagem1_`h' if sm1rrel_pnum`i'==scagem1_pnum`h' & cagem1_pnum`h' >= 60 & cagem1_pnum`h' < 200
		}
}

keep ssuid eresidenceid1 pnum agerrelm1_*

save "$tempdir/agerrelm1.dta", replace

use "$tempdir/hhcompm4.dta", clear

merge 1:1 ssuid pnum using "$tempdir/t2age4.dta"

drop _merge

merge m:1 ssuid eresidenceid4 using "$tempdir/hhcompagem4.dta"

drop _merge

forvalues i=1/30 {
    gen agerrelm4_`i'=99
	forvalues s=1/10 {
		replace agerrelm4_`i'=tt2_age`s' if sm4rrel_pnum`i'==set2_lno`s' & et2_lno`s' >= 60 & et2_lno`s' < 200
		}
	forvalues h=1/19 {
		replace agerrelm4_`i'=cagem4_`h' if sm4rrel_pnum`i'==scagem4_pnum`h' & cagem4_pnum`h' >= 60 & cagem4_pnum`h' < 200
		}
}

keep ssuid eresidenceid4 pnum agerrelm4_*

save "$tempdir/agerrelm4.dta", replace

use "$tempdir/hhcompm8.dta", clear

merge 1:1 ssuid pnum using "$tempdir/t2age8.dta"

drop _merge

merge m:1 ssuid eresidenceid8 using "$tempdir/hhcompagem8.dta"

forvalues i=1/30 {
    gen agerrelm8_`i'=99
	forvalues s=1/10 {
		replace agerrelm8_`i'=tt2_age`s' if sm8rrel_pnum`i'==set2_lno`s' & et2_lno`s' >= 60 & et2_lno`s' < 200
		}
	forvalues h=1/19 {
		replace agerrelm8_`i'=cagem8_`h' if sm8rrel_pnum`i'==scagem8_pnum`h' & cagem8_pnum`h' >= 60 & cagem8_pnum`h' < 200
		}
}


keep ssuid eresidenceid8 pnum agerrelm8_*

save "$tempdir/agerrelm8.dta", replace

use "$tempdir/hhcompm12.dta", clear

merge 1:1 ssuid pnum using "$tempdir/t2age12.dta"

drop _merge

merge m:1 ssuid eresidenceid12 using "$tempdir/hhcompagem12.dta"

forvalues i=1/30 {
    gen agerrelm12_`i'=99
	forvalues s=1/10 {
		replace agerrelm12_`i'=tt2_age`s' if sm12rrel_pnum`i'==set2_lno`s' & et2_lno`s' >= 60 & et2_lno`s' < 200
		}
	forvalues h=1/19 {
		replace agerrelm12_`i'=cagem12_`h' if sm12rrel_pnum`i'==scagem12_pnum`h' & cagem12_pnum`h' >= 60 & cagem12_pnum`h' < 200
		}
}


keep ssuid eresidenceid12 pnum agerrelm12_*

save "$tempdir/agerrelm12.dta", replace
