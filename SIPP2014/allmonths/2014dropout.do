*******************************************************************************
* Does household instability predict high school dropout and/or high school graduation?
* This file creates variables describing (first) transition to dropout or high school graduation


* !!!! NOTE: ssc install carryforward prior to running
*******************************************************************************

*excute do_all_months.do to create HHchangeWithRelationships_am.dta 
use "$SIPP14keep/HHchangeWithRelationships_am.dta", clear

*******************************************************************************
* Section: Create measures of educational attainment
*******************************************************************************

************fill in missing educ***************************

egen id = concat (SSUID PNUM)
destring id, gen(idnum)
format idnum %20.0f
duplicates tag idnum panelmonth, gen(isdup)
drop if isdup !=0

* drop observations where individuals have more than a high school degree
* Note that I don't drop cases with a high school degree so that I can model the transition
* to a high school degree in addition to drop out.
keep if inlist(educ,1,2,.)

xtset idnum panelmonth

gsort idnum -panelmonth

* carry forward education from the previous month if education is missing in the current month
by idnum: replace educ = educ[_n-1] if missing(educ)
sort idnum panelmonth

************restrict sample ********************************
*children aged 14-20 without a high school diploma are at risk of high school dropout
keep if adj_age >=14 & adj_age <=20 & educ==1|educ==2 

************create indicator for high school dropout adjusted for summer *********

gen dropout= (educ==1 & RENROLL==2) if !missing(RENROLL)

tab dropout

** now adjusting for summer
* create indicators for wave and month
*gen swave=floor((panelmonth+11)/12)

*indicator of month: Jan-Dec
*gen month=12-(swave*12-panelmonth)

*adjust dropout measure
*recode dropout in summer (6-8) to 0 if they report enrolled in September

save "$tempdir/dropout.dta", $replace

keep SSUID PNUM panelmonth dropout RENROLL
reshape wide dropout RENROLL, i(SSUID PNUM) j(panelmonth)

* loop across years
forvalues y=0/3{
* loop for june, july, and august     
    forvalues mon=6/8{
        local pm=`y'*12+`mon'
        local september=`y'*12+9
        replace dropout`pm'=0 if dropout`september'==0
    }
}

reshape long dropout RENROLL, i(SSUID PNUM) j(panelmonth)

save "$tempdir/dropout_adjust.dta", $replace

use "$tempdir/dropout.dta", clear
drop dropout RENROLL

merge 1:1 SSUID PNUM panelmonth using "$tempdir/dropout_adjust.dta"

keep if _merge==3
drop _merge

*********** create indicator of high school graduation *********
gen hsgrad= (educ==2) if !missing(educ)

tab hsgrad

*********** identify and drop cases that have dropped out or graduated at first observation **

xtset idnum panelmonth

* Identify first observation of the individual. (Note that this is not always January 2013).
bysort idnum: gen count=_n
bysort idnum: gen dropout_base=1 if count==1 & dropout==1
bysort idnum: gen hsgrad_base=1 if count==1 & hsgrad==1

sort idnum panelmonth

* Mark for deletion all observations for individuals that originated as a dropout or high school graduate
by idnum: carryforward(dropout_base),replace
by idnum: carryforward(hsgrad_base),replace
drop if dropout_base==1 | hsgrad_base==1

************************* create indicator of ever dropout***************
*tag first dropout month 
sort idnum panelmonth
egen tag_dropout=tag (idnum dropout)
replace tag_dropout=0 if tag_dropout==1 & dropout==0
tab tag_dropout

bysort idnum: egen ever_dropout= max(dropout)

************************* create indicator of ever hs graduate***********

*tag month of high school graduation
sort idnum panelmonth
egen tag_hsgrad=tag (idnum hsgrad)
replace tag_hsgrad=0 if tag_hsgrad==1 & hsgrad==0
tab tag_hsgrad

bysort idnum: egen ever_hsgrad= max(hsgrad)

*identify panelmonth of first dropout and carry forward/backward
sort idnum panelmonth 
gen month_firstd = panelmonth if tag_dropout==1
by idnum: carryforward(month_firstd), replace	
gsort idnum -panelmonth 
by idnum: carryforward(month_firstd), replace	
sort idnum panelmonth

*identify panelmonth of first hsgrad and carry forward/backward
sort idnum panelmonth 
gen month_firstg = panelmonth if tag_hsgrad==1
by idnum: carryforward(month_firstg), replace	
gsort idnum -panelmonth 
by idnum: carryforward(month_firstg), replace	
sort idnum panelmonth

*************************************************************************
* Section: select person-months at risk of high school dropout or high school graduation
*************************************************************************

gen censormonth=min(month_firstg, month_firstd)

*drop months that come after the first dropout or hsgrad (create a censored sample)
keep if panelmonth <= censormonth

*describe sample
sort idnum panelmonth
egen tagid = tag(idnum)
tab tagid  
//5,846 children,  136,775 observations

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


label values parcomplag parcomp
label values sibcomplag sibcomp
label values extendlag extend

label define edu 1 "Less than HS" 2"HS Grad" 3"Some College" 4"College Grad"
label values par_ed_first edu

label define poverty 1 "Deep poverty" 2"Poor" 3"Near Poor" 4"Not Poor"
label values cpov poverty
label values cpovlag poverty

label define cchange 1 "no change" 2 "only parent change" 3 "par&sib change" 4 "par&other change" 5 "only sib change" 6 "sib&other change" 7 "only other change" 8 "3 changes"
label values cchange cchange
label values cchangelag cchange

save "$SIPP14keep/dropout_month.dta", $replace

