* Extracts data from nsfg 2006-2015

*local NSFGR5 "$NSFG1995\nsfg95.dta"
*local NSFGR6 "$NSFG2002\2002FemResp.dta"
* Note that earlier cycles had different variables *

local NSFGR7 "$NSFG0610\nsfg0610fem.dta"
local NSFGR8 "$NSFG1113\Female_NSFG1113.dta"
local NSFGR9 "$NSFG1315\2013_2015_FemRespData.dta"

forvalues r=7/9{
	pwd
	display "`NSFGR`r''"
	use "`NSFGR`r''", clear
	
	display "check1"

	keep CASEID HISP RSCRRACE FMARIT MARSTAT CMBIRTH MARDAT01 COHAB1 MOMDEGRE HIEDUC WGT* CMINTVW EVMARCOH COHEVER

	gen cm1union=CMINTVW if EVMARCOH==2
	replace cm1union=MARDAT01 if !missing(MARDAT01) & MARDAT01 < COHAB1
	replace cm1union=COHAB1 if !missing(COHAB1) & COHAB1 <= MARDAT01

	gen everu=1 if EVMARCOH==1
	replace everu=0 if missing(everu)

	tab everu

	sum cm1union

	gen dur2un=int((cm1union-CMBIRTH)/12)

	gen dur2mar=int((MARDAT01-CMBIRTH)/12) if !missing(MARDAT01)
	replace dur2mar=int((CMINTVW-CMBIRTH)/12) if FMARIT==5

	gen yearbirth=int((CMBIRTH-1)/12)

	recode yearbirth (60/64=2)(65/69=3)(70/74=4)(75/79=5)(80/84=6)(85/89=7)(90/94=8)(95/99=9), gen(bcohort)

	recode HIEDUC (5/8=1)(9=2)(10/11=3)(12/15=4), gen(educ)
	replace educ=5 if missing(educ)

	gen cycle=`r'

	display "check2"
	save "$combined_data\union`r'.dta", replace

	* why stop at duration 27?
	forvalues d=10/34{
		gen union`d'=0
		replace union`d'=1 if `d' >=dur2un & everu==1
	}
		
	reshape long union, i(CASEID) j(dur) 

	gen year=yearbirth+dur

	drop if dur > dur2un

	save "$combined_data\pyunion`r'.dta", replace

	use "$combined_data\union`r'.dta", clear
}

use "$combined_data\union7.dta", clear
append using "$combined_data\union8.dta"
append using "$combined_data\union9.dta"

gen weight=WGTQ1Q16 if cycle==7
replace weight=WGT2011_2013 if cycle==8
replace weight=WGT2013_2015 if cycle==9

gen iweight=int(weight)

save "$combined_data\union0615.dta", replace

use "$combined_data\pyunion7.dta", clear
append using "$combined_data\pyunion8.dta"
append using "$combined_data\pyunion9.dta"

gen weight=WGTQ1Q16 if cycle==7
replace weight=WGT2011_2013 if cycle==8
replace weight=WGT2013_2015 if cycle==9

gen yearint=int((CMINTVW)/12)

gen retro=yearint-year

gen iweight=int(weight)

save "$combined_data\pyunion0615.dta", replace



