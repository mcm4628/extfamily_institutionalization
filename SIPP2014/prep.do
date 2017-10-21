*******************************************************************************************
* File created by Kelly Raley
*
* This file creates a string by concatinating all person-numbers in the 
* household at months 1, 4, 8, and 12. Laster programs (anydiff) will compare 
* the string in one month to the individual variables for each person in the household
* to identify who enters and who leaves. To make this comparison, the individual variables
* must be converted from numeric to string
*******************************************************************************************

********************************************************************************
* A second function of this code is to create wide data files with the age of 
* every household member -> hhcompagemX.dta. Ages are 0, 1-17, 18-29, 30-64, 65+
********************************************************************************


use "$SIPP2014data/selected.dta", clear

egen allHH = concat(rrel_pnum*), punct(" ")

replace allHH=" " + allHH + " "

keep ssuid pnum monthcode allHH rrel_pnum* rrel* eresidenceid tage_ehc

sort ssuid pnum

preserve
*****************************************
* Create month 1 variables
*****************************************

keep if monthcode==1

rename allHH allHH1
rename eresidenceid eresidenceid1
rename tage_ehc tage1

*need to string pnum variables in wave 1 to search in wave 4 allHH8 string
forvalues i=1/30{
gen srrel_pnum`i'=string(rrel_pnum`i')
replace srrel_pnum`i'="999" if srrel_pnum`i'=="."
rename srrel_pnum`i' sm1rrel_pnum`i'
rename rrel`i' rrel`i'_m1
}

drop rrel_pnum*

save "$tempdir/hhcompm1.dta", replace

keep ssuid pnum tage1 eresidenceid1

sort ssuid eresidenceid1
by ssuid eresidenceid1: gen hhmemnum=_n

recode tage1 (0=0)(1/17=1)(18/29=2)(30/64=3)(65/99=4), gen(cagem1_)

gen cagem1_pnum=pnum

drop tage1 pnum

reshape wide cagem1_ cagem1_pnum, i(ssuid eresidenceid1) j(hhmemnum)

forvalues h=1/19 {
tostring cagem1_pnum`h', gen(scagem1_pnum`h')
} 

save "$tempdir/hhcompagem1.dta", replace

restore

*****************************************
* Create month 4 variables
*****************************************
preserve

keep if monthcode==4

rename allHH allHH4
rename eresidenceid eresidenceid4
rename tage_ehc tage4

*need to string pnum variables in wave 4 to search in wave 8 allHH8 string
forvalues i=1/30{
gen srrel_pnum`i'=string(rrel_pnum`i')
replace srrel_pnum`i'="999" if srrel_pnum`i'=="."
rename srrel_pnum`i' sm4rrel_pnum`i'
rename rrel`i' rrel`i'_m4
}

drop rrel_pnum*

save "$tempdir/hhcompm4.dta", replace

keep ssuid pnum tage4 eresidenceid4

sort ssuid eresidenceid4
by ssuid eresidenceid4: gen hhmemnum=_n

recode tage4 (0=0)(1/17=2)(18/29=3)(30/64=4)(65/99=5), gen(cagem4_)

gen cagem4_pnum=pnum

drop tage4 pnum

reshape wide cagem4_ cagem4_pnum, i(ssuid eresidenceid4) j(hhmemnum)

forvalues h=1/19 {
tostring cagem4_pnum`h', gen(scagem4_pnum`h')
} 
save "$tempdir/hhcompagem4.dta", replace

restore
*****************************************
* Create month 8 variables
*****************************************
preserve

keep if monthcode==8

rename allHH allHH8
rename eresidenceid eresidenceid8
rename tage_ehc tage8

*need to string pnum variables in wave 8 to search in wave 12 allHH12 string
forvalues i=1/30{
gen srrel_pnum`i'=string(rrel_pnum`i')
replace srrel_pnum`i'="999" if srrel_pnum`i'=="."
rename srrel_pnum`i' sm8rrel_pnum`i'
rename rrel`i' rrel`i'_m8
}

drop rrel_pnum*

save "$tempdir/hhcompm8.dta", replace

keep ssuid pnum tage8 eresidenceid8

sort ssuid eresidenceid8
by ssuid eresidenceid8: gen hhmemnum=_n

recode tage8 (0=0)(1/17=2)(18/29=3)(30/64=4)(65/99=5), gen(cagem8_)

gen cagem8_pnum=pnum

drop tage8 pnum

reshape wide cagem8_ cagem8_pnum, i(ssuid eresidenceid8) j(hhmemnum)

forvalues h=1/20 {
tostring cagem8_pnum`h', gen(scagem8_pnum`h')
} 

save "$tempdir/hhcompagem8.dta", replace

restore

*****************************************
* Create month 12 variables
*****************************************

keep if monthcode==12

rename allHH allHH12
rename eresidenceid eresidenceid12
rename tage_ehc tage12

forvalues i=1/30{
gen srrel_pnum`i'=string(rrel_pnum`i')
replace srrel_pnum`i'="999" if srrel_pnum`i'=="."
rename srrel_pnum`i' sm12rrel_pnum`i'
rename rrel`i' rrel`i'_m12
}

drop rrel_pnum*

save "$tempdir/hhcompm12.dta", replace

keep ssuid pnum tage12 eresidenceid12

sort ssuid eresidenceid12
by ssuid eresidenceid12: gen hhmemnum=_n

recode tage12 (0=0)(1/17=2)(18/29=3)(30/64=4)(65/99=5), gen(cagem12_)

gen cagem12_pnum=pnum

drop tage12 pnum

reshape wide cagem12_ cagem12_pnum, i(ssuid eresidenceid12) j(hhmemnum)

forvalues h=1/20 {
tostring cagem12_pnum`h', gen(scagem12_pnum`h')
} 
save "$tempdir/hhcompagem12.dta", replace

use "$tempdir/hhcompm12.dta", clear

merge 1:1 ssuid pnum using "$tempdir/hhcompm8.dta"

*finds individuals who moved in during the reference month
gen in12not8=1 if _merge==1
replace in12not8=0 if missing(in12not8)

gen babyin=1 if _merge==1 & tage12==0
replace babyin=0 if missing(babyin)

drop _merge

sort ssuid eresidenceid12

save "$tempdir/SIPP14_8to12.dta", replace

* creating a household-level dummy for whether a baby was born into household
keep ssuid eresidenceid12 babyin

sort ssuid eresidenceid12

collapse (max) anybabyin=babyin, by(ssuid eresidenceid12)

save "$tempdir/babyin12.dta", replace

* Month 4 to 8 interval *

use "$tempdir/hhcompm8.dta", clear

merge 1:1 ssuid pnum using "$tempdir/hhcompm4.dta"

*finds individuals who moved in during the reference month
gen in8not4=1 if _merge==1
replace in8not4=0 if missing(in8not4)

gen babyin=1 if _merge==1 & tage8==0
replace babyin=0 if missing(babyin)

drop _merge

sort ssuid eresidenceid8

save "$tempdir/SIPP14_4to8.dta", replace

* creating a household-level dummy for whether a baby was born into household
keep ssuid eresidenceid8 babyin

collapse (max) anybabyin=babyin, by(ssuid eresidenceid8)

save "$tempdir/babyin8.dta", replace

*************************
* Month 1 to 4 interval *
*************************

use "$tempdir/hhcompm4.dta", clear

merge 1:1 ssuid pnum using "$tempdir/hhcompm1.dta"

*finds individuals who moved in during the reference month
gen in4not1=1 if _merge==1
replace in4not1=0 if missing(in4not1)

gen babyin=1 if _merge==1 & tage4==0
replace babyin=0 if missing(babyin)

drop _merge

sort ssuid eresidenceid4

save "$tempdir/SIPP14_1to4.dta", replace

* creating a household-level dummy for whether a baby was born into household
keep ssuid eresidenceid4 babyin

collapse (max) anybabyin=babyin, by(ssuid eresidenceid4)

save "$tempdir/babyin4.dta", replace


