//==============================================================================
//===== Children's Household Instability Project                                                    
//==============================================================================

* first annualize the demographic variables 
use "$SIPP04keep/demo_long_all_am.dta", clear

gen year=floor((panelmonth)/12)+1

collapse (firstnm) adj_age par_ed_first my_sex my_race my_racealt WPFINWGT, by(SSUID EPPPNUM year)

tab par_ed_first
tab my_sex
tab my_race
tab my_racealt

gen panelmonth=year*12

save "$tempdir/annualized_demo04.dta", replace

use "$SIPP04keep/hh_change_am.dta", clear
* Created by create_hh_change_am.do, this file has one record per panelmonth
* it is rectangular with 131949 person-months of all ages.

* We want to parallel the analysis using SIPP 2014 and so we create a measure of 
* whether the child experienced any household instability in a year. We don't 
* include panemonth 12 in year 1 (for example) because it indicates comp_change
* between panemonth 12 and panelmonth 13. 

gen year=floor((panelmonth)/12)+1

collapse (sum) comp_change addr_change hh_change (count) nobs=hh_change, by(SSUID EPPPNUM year)

tab nobs

* restrict to years where individual is observed at least once (378021)
keep if nobs > 0

gen panelmonth=year*12

merge 1:1 SSUID EPPPNUM panelmonth using "$tempdir/annualized_demo04.dta"

tab my_race _merge, row

* The file will have at most one observation per year. Includes only years that
* the individual was observed at least once.
keep if _merge==3

drop _merge

recode hh_change (0=0)(1/12=1), gen(anychange_hh)
recode comp_change (0=0)(1/12=1), gen(anychange_c)
recode addr_change (0=0)(1/12=1), gen(anychange_a)

save "$SIPP04keep/annualized_change04.dta", replace


	

