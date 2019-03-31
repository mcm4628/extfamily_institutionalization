********************************************************************************
* Does household instability predict dropping out of high school?
*
* This analysis focuses on those observations between age 15 and 17.
* We measure household characteristics in this wave, household instability between the previous wave 
* and this one and a set of controls
*
* The sample includes observations between Wave 2 (so that we can use instability between Wave 1 and 2 
* as a predictor) that had not dropped out in previous waves (i.e. standard ensoring). 

use "$tempdir/PovbyWave", clear

merge 1:1 SSUID EPPPNUM SWAVE using "$SIPP08keep/HHCompbyWave", gen(povcomp)

keep if povcomp==3

drop povcomp
drop _merge

merge 1:1 SSUID EPPPNUM SWAVE using "$SIPP08keep/HHchangeWithRelationships.dta", keepusing (parent_change sib_change other_change addr_change)

keep if _merge==3

drop _merge

rename parent_change parent_changenw
rename sib_change sib_changenw
rename other_change other_changenw
rename addr_change addr_changenw

replace SWAVE=SWAVE+1

merge 1:1 SSUID EPPPNUM SWAVE using "$SIPP08keep/HHchangeWithRelationships.dta", keepusing (parent_change sib_change other_change addr_change)

replace SWAVE=SWAVE-1

drop if SWAVE < 2
tab _merge

keep if _merge==3

drop _merge

keep if adj_age >= 15 & adj_age < 18

keep if everdropout==0

tab adj_age dropoutnw

global model i.par_ed_first i.my_racealt my_sex 

local ivs1 "i.par_ed_first i.my_racealt my_sex"
local ivs2 "i.cpov b2.parents anyotheradults num_child"
local ivs3 "parent_change sib_change other_change addr_change"

forvalues set=1/3 {
	foreach var in `ivs`set'' {
		logistic dropoutnw i.adj_age `var' if dropout !=1, cluster(SSUID)
	}
}

logistic dropoutnw i.adj_age $model if dropout !=1, cluster(SSUID) 
logistic dropoutnw i.adj_age $model i.cpov b2.parents anyotheradults num_child if dropout !=1, cluster(SSUID)
logistic dropoutnw i.adj_age $model i.cpov b2.parents anyotheradults num_child parent_change i.sib_change other_change addr_change if dropout !=1, cluster(SSUID)
