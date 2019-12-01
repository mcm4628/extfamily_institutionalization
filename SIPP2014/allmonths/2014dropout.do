********************************************************************************
* Does household instability predict school enrollment?
*
* This analysis focuses on those observations between age 13 and 18.

cd "T:\GitHub\ChildHH"
do setup_childhh_environment

*excute extract_and_format, convert_to_wide, normalize_ages first to get more variables 
use "$SIPP14keep/HHchangeWithRelationships_am.dta", $replace

*fill in missing educ
egen id = concat (SSUID PNUM)
destring id, gen(idnum)
format idnum %20.0f
duplicates tag idnum panelmonth, gen(isdup)
drop if isdup !=0

keep if educ==1 | educ==.
xtset idnum panelmonth
gsort idnum -panelmonth
by idnum: replace educ = educ[_n-1] if missing(educ)
sort idnum panelmonth

*create high school dropout
*children aged 14-20 without a high school diploma are at risk of high school dropout
keep if adj_age >=14 & adj_age <=20 & educ==1 
recode RENROLL (1=0) (2=1), gen (dropout)

*indicator of month: Jan-Dec
gen month=panelmonth
replace month=1 if inlist(month,1,13,25,37)
replace month=2 if inlist(month,2,14,26,38)
replace month=3 if inlist(month,3,15,27,39)
replace month=4 if inlist(month,4,16,28,40)
replace month=5 if inlist(month,5,17,29,41)
replace month=6 if inlist(month,6,18,30,42)
replace month=7 if inlist(month,7,19,31,43)
replace month=8 if inlist(month,8,20,32,44)
replace month=9 if inlist(month,9,21,33,45)
replace month=10 if inlist(month,10,22,34,46)
replace month=11 if inlist(month,11,23,35,47)
replace month=12 if inlist(month,12,24,36,48)

save "$SIPP14keep/dropout.dta", $replace

*adjust dropout measure
*recode dropout in summer (6-8) to 0 if they report enrolled in September
keep SSUID PNUM panelmonth dropout RENROLL
reshape wide dropout RENROLL, i(SSUID PNUM) j(panelmonth)

replace dropout6=0 if dropout9==0
replace dropout7=0 if dropout9==0
replace dropout8=0 if dropout9==0

replace dropout18=0 if dropout21==0
replace dropout19=0 if dropout21==0
replace dropout20=0 if dropout21==0

replace dropout30=0 if dropout33==0
replace dropout31=0 if dropout33==0
replace dropout32=0 if dropout33==0

replace dropout42=0 if dropout45==0
replace dropout43=0 if dropout45==0
replace dropout44=0 if dropout45==0

reshape long dropout RENROLL, i(SSUID PNUM) j(panelmonth)

save "$SIPP14keep/dropout_adjust.dta", $replace

use "$SIPP14keep/dropout.dta", $replace
drop dropout RENROLL
merge 1:1 SSUID PNUM panelmonth using "$SIPP14keep/dropout_adjust.dta"
keep if _merge==3
drop _merge

*drop already droped out at baseline
xtset idnum panelmonth
bysort idnum: gen count=_n
bysort idnum: gen dropout_base=1 if count==1 &dropout==1
sort idnum panelmonth
by idnum: carryforward(dropout_base),replace
drop if dropout_base==1 
*7,961 observations deleted

*tag first dropout month 
sort idnum panelmonth
egen tag_dropout=tag (idnum dropout)
replace tag_dropout=0 if tag_dropout==1 & dropout==0
tab tag_dropout

*create indicator of ever dropout
bysort idnum: egen ever_dropout= max(dropout)

*identify panelmonth of first dropout and carry forward/backward
sort idnum panelmonth 
gen month_firstd = panelmonth if tag_dropout==1
by idnum: carryforward(month_firstd), replace	
gsort idnum -panelmonth 
by idnum: carryforward(month_firstd), replace	
sort idnum panelmonth

*drop months that come after the first week of dropout (create a censored sample)
keep if ever_dropout==0 | (panelmonth<=month_firstd)	

*describe sample
sort idnum panelmonth
egen tagid = tag(idnum)
tab tagid  
//5,887 children,  124,203 observations

*household composition changes (8 categories just in case)
gen cchange=.
replace cchange=1 if parent_change==0 & sib_change==0 & other_change==0 //no change
replace cchange=2 if parent_change==1 & sib_change==0 & other_change==0 //only parent change
replace cchange=3 if parent_change==1 & sib_change==1 & other_change==0 //parent change & sibling change
replace cchange=4 if parent_change==1 & sib_change==0 & other_change==1 //parent change & other change
replace cchange=5 if parent_change==0 & sib_change==1 & other_change==0 //only sibling change
replace cchange=6 if parent_change==0 & sib_change==1 & other_change==1 //sibling change & other change
replace cchange=7 if parent_change==0 & sib_change==0 & other_change==1 //only other change
replace cchange=8 if parent_change==1 & sib_change==1 & other_change==1 //3 change

*create poverty status
gen cpov=.
replace cpov=1 if THINCPOVT2 <= .5
replace cpov=2 if THINCPOVT2 > .5 &  THINCPOVT2 <=1
replace cpov=3 if THINCPOVT2 > 1 &  THINCPOVT2 <=2
replace cpov=4 if THINCPOVT2 >2

*merge in hh composition
merge 1:1 SSUID PNUM panelmonth using "$SIPP14keep/HHComp_pm.dta", keepusing (parcomp sibcomp extend WPFINWGT)

keep if _merge==3 | _merge==1
drop _merge

*create lagged variables 
local cvar comp_change bioparent_change parent_change sib_change biosib_change ///
 halfsib_change stepsib_change other_change gp_change nonrel_change otherrel_change cchange ///
 parcomp sibcomp extend RHNUMPERWT2 RHNUMU18WT2 cpov
foreach var in `cvar'{
 bysort idnum (panelmonth): gen `var'lag=`var'[_n-1]
}

label define parcomp 1 "2 bioparents" 2 "single parent" 3 "step parent" 4 "no parent"
label define sibcomp 0 "no siblings" 1 "only biosibs" 2 "step/half sibs"
label define extend 0 "nuclear" 1 "grandparent" 2 "horizontal extension"

label values parcomp parcomp
label values parcomplag parcomp
label values sibcomp sibcomp
label values sibcomplag sibcomp
label values extend extend
label values extendlag extend

label define edu 1 "Less than HS" 2"HS Grad" 3"Some College" 4"College Grad"
label values par_ed_first edu
label values par_ed_firstlag edu

label define poverty 1 "Deep poverty" 2"Poor" 3"Near Poor" 4"Not Poor"
label values cpov poverty
label values cpovlag poverty

label define cchange 1 "no change" 2 "only parent change" 3 "par&sib change" 4 "par&other change" 5 "only sib change" 6 "sib&other change" 7 "only other change" 8 "3 changes"
label values cchange cchange
label values cchangelag cchange

save "$SIPP14keep/dropout_month.dta", $replace

