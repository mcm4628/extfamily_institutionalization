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

merge 1:1 SSUID EPPPNUM SWAVE using "$SIPP08keep/HHchangeWithRelationships.dta", keepusing (parent_change sib_change other_change addr_change infant_arrive adultsib_leave)

keep if _merge==3

drop _merge

* because the household change variables indicate change between this wave and the next, they are measuring household change contemporanous to 
* dropoutnw
rename parent_change parent_changenw
rename sib_change sib_changenw
rename other_change other_changenw
rename addr_change addr_changenw
rename infant_arrive infant_arrivenw
rename adultsib_leave adultsib_leavenw

replace SWAVE=SWAVE+1

merge 1:1 SSUID EPPPNUM SWAVE using "$SIPP08keep/HHchangeWithRelationships.dta", keepusing (parent_change sib_change other_change addr_change infant_arrive adultsib_leave)
* merging on household change between the wave before this one and this one. 

replace SWAVE=SWAVE-1

drop if SWAVE < 2
*have no measures of household change in SWAVE=1
tab _merge

keep if _merge==3

drop _merge

keep if adj_age >= 15 & adj_age < 18

keep if everdropout==0

drop if missing(parent_change)

********************************************************************************
* Fix missing values
********************************************************************************

replace par_ed_first=5 if missing(par_ed_first)
replace parents=0 if missing(parents)
replace anynnadult=0 if missing(anynnadult)
replace num_child=1 if missing(num_child)
replace addr_change=2 if missing(addr_change)

****code sibling change into 3 types*******
gen sibchange3=.
recode sibchange3 .=1 if sib_change==0 //no change
recode sibchange3 .=2 if infant_arrive==1 //infant born note 13 cases experienced both infant arrive and adult sibchange were coded into this category
recode sibchange3 .=3 if sib_change==1 & infant_arrive==0 // other sibling changes

local basevar "i.adj_age i.par_ed_first i.my_racealt my_sex"
local compvar "b2.parents i.anynnadult num_child b3.cpov"
local changevar "parent_change i.sibchange3 other_change i.addr_change"

local tabvar "adj_age par_ed_first my_racealt my_sex parents anynnadult num_child cpov parent_change sibchange3 other_change addr_change"
foreach var in `tabvar'{
 tab `var'
}

eststo clear
eststo: quietly logit dropoutnw `basevar' `changevar', cluster(SSUID) 
eststo: quietly logit dropoutnw `basevar' `compvar', cluster(SSUID)
eststo: quietly logit dropoutnw `basevar' `changevar' `compvar', cluster(SSUID) 
esttab using "$cwb_results/dropout.csv", $replace
logit dropoutnw `basevar' `changevar' `compvar', cluster(SSUID) 
