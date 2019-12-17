clear
use "$SIPP08keep/HHComp_asis_am.dta"

merge m:1 SSUID EPPPNUM panelmonth using "C:\Users\Carolina Aragao\Box\sipp files\WorkingFiles2008\hh_change_am.dta"

merge m:1 SSUID EPPPNUM panelmonth using "$SIPP2008/hh_change_am.dta"

drop if _merge==2
drop _merge

merge m:1 SSUID EPPPNUM panelmonth using "$tempdir/allmonths.dta"

drop if _merge==2
drop _merge

************************ New Variables *******************************

****** Family members in the hh *****

*Granparent
gen _gp=0
replace _gp=1 if relationship==13|relationship==14
egen gp=max(_gp), by(panelmonth SSUID)
drop _gp

*Other relative
gen _other=0
replace _other=1 if relationship>=24
egen other=max(_other), by(panelmonth SSUID)
drop _other



***** Type of family ********

* Other HH arrangements

gen otherhh=0
replace otherhh=1 if other==1

* Multigenerational - only grandparents

gen multihh=0
replace multi=1 if gp==1 & otherhh==0

* Nuclear

gen nuclearhh=1
replace nuclearhh=0 if otherhh==1|multihh==1


* Household structure
gen sharehh=.
replace sharehh=0 if nuclearhh==1
replace sharehh=1 if multihh==1
replace sharehh=2 if otherhh==1

* Mothers education
gen mom_educ2=.
replace mom_educ2=1 if mom_educ==1|mom_educ==2
replace mom_educ2=2 if mom_educ==3
replace mom_educ2=3 if mom_educ==4
label def mom_educ2 1 "hsol" 2 "ltcol" 3 "coll" 


* Household size
egen id=group(SSUID EPPPNUM)
egen hhsize=count(id), by(SSUID EPPPNUM)

recode TBRSTATE -1=.
recode ETENURE 1=0 2=1 3=1
rename ETENURE tenure
label def tenure 0 "owned" 1 "rented or occupied" 


keep SSUID EPPPNUM panelmonth mom_educ2 sharehh id hhsize TAGE mom_immigrant mom_educ my_race my_sex tenure comp_change addr_change comp_change_reason hh_change RHCHANGE TBRSTATE nuclearhh otherhh multihh WPFINWGT
save "$SIPP2008/change&comp_am.dta", replace


* Sample

bys SSUID EPPPNUM panelmonth: sample 1, count // I am in only one observation per month for each individual
keep if TAGE<=18
keep if comp_change!=.

* Regressions

logistic comp_change i.sharehh i.my_race i.mom_educ2 i.mom_immigrant i.tenure hhsize [pw=WPFINWGT]
outreg2 using hh.xls, replace ctitle(Model 1) eform


logistic comp_change i.sharehh##i.my_race i.mom_educ2 i.mom_immigrant i.tenure hhsize [pw=WPFINWGT]
outreg2 using sipp.xls, append ctitle(Model 2) eform


logistic comp_change i.sharehh##i.mom_educ2 i.my_race i.mom_immigrant i.tenure hhsize [pw=WPFINWGT]
outreg2 using sipp.xls, append ctitle(Model 3) eform




