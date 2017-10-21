* The goal of this is to merge the dummy indicator of household change to the month12 data
* The first interval is month 1 to month 4. Create one record per child
* The second intervial is month 4 to 8. The third is month 8 to month 12.

* Interval 3
use "$SIPP2014data/selected.dta", clear

keep if monthcode==12 

merge 1:1 ssuid pnum using "$tempdir/anydiff812.dta"

drop _merge

gen interval=812
gen anydiff=anydiff812
gen born=born812
gen moved=moved812
gen age_start=tage8
replace age_start=tage if in12not8==1 & born==0

save "$tempdir/int3.dta", replace

tab age_start

* Interval 2

use "$SIPP2014data/selected.dta", clear

keep if monthcode==12 

merge 1:1 ssuid pnum using "$tempdir/anydiff48.dta"
drop _merge

gen interval=48
gen anydiff=anydiff48
gen born=born48
gen moved=moved48
gen age_start=tage4
replace age_start=tage if in8not4==1 & born==0

save "$tempdir/int2.dta", replace

tab age_start

* Interval 1

use "$SIPP2014data/selected.dta", clear

keep if monthcode==12 

merge 1:1 ssuid pnum using "$tempdir/anydiff14.dta"

drop _merge

gen interval=14
gen anydiff=anydiff14
gen born=born14
gen moved=moved14
gen age_start=tage1
replace age_start=tage if in4not1==1 & born==0

save "$tempdir/int1.dta", replace

tab age_start

append using "$tempdir/int2.dta"
append using "$tempdir/int3.dta"


merge m:1 ssuid pnum using "$tempdir/partner_change.dta

gen partner_change=partner_change14 if interval==14
replace partner_change=partner_change48 if interval==48
replace partner_change=partner_change812 if interval==812

gen mom_educ=biomomeduc12
recode mom_educ (31/38=1)(39=2)(40/43=3)(44/47=4), gen (momced)

save "$SIPPshared/threeinterval2014.dta", replace




