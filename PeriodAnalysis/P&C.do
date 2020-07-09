clear
use "$SIPP08keep/HHComp_asis.dta"
append using "$SIPP04keep/HHComp_asis.dta"

****** Family members in the hh *****

/*1. Shared household: a child lives with an additional adult beyond the parent/stepparent, sibling, or the cohabiting partner of the parent (also known as doubled-up households; Pilkauskas et al.2014). 
2. Extended family: a child lives with any adult relative beyond the parents/stepparents, sibling, or parent’s cohabiting partner. This includes grandparents, aunts/ uncles, nieces/nephews, and other relatives (e.g., cousins). 
3. Grandparents: a child lives with at least one grandparent. 
4. Aunt/uncle: a child lives with at least one adult aunt/uncle. 
5. Other relative: a child lives with at least one adult relative who was not the grandparent, aunt/uncle, sibling, or parent/parent’s partner. 
6. Nonrelative: a child lives with at least one adult nonrelative. */

*Granparent
gen _gp=0
replace _gp=1 if relationship==15|relationship==16
egen gp=max(_gp), by(SWAVE SSUID)
drop _gp


* Aunt/uncle
gen _aunt=0
replace _aunt=1 if relationship==24|relationship==25
egen aunt=max(_aunt), by(SWAVE SSUID)
drop _aunt

* Other relative
gen _other_rel=0
replace _other_rel=1 if relationship==35
egen other_rel=max(_other_rel), by(SWAVE SSUID)
drop _other_rel


* Non-relative
gen _non_rel=0
replace _non_rel=1 if relationship==37
egen non_rel=max(_non_rel), by(SWAVE SSUID)
drop _non_rel

* At least one parent
gen _par=0
replace _par=1 if relationship==2|relationship==3|relationship==5|relationship==6
egen par=max(_par), by(SWAVE SSUID)
drop _par

* At least one parent - using type of parent
* All children
gen child=0
replace child=1 if (ETYPMOM!=-1|ETYPDAD!=-1)

* Only biological children
gen child_bio=0
replace child_bio=1 if (ETYPMOM==1|ETYPDAD==1)


***** Type of family ********


* Extended HH arrangements

gen exthh=0
replace exthh=1 if (other_rel==1|gp==1|aunt==1) & non_rel==0

* Extended HH arrangements

gen exthh2=0
replace exthh2=1 if (other_rel==1|gp==1|aunt==1) 


* Non-relatives 

gen nonhh=0
replace nonhh=1 if non_rel==1


* Nuclear

gen nuclearhh=1
replace nuclearhh=0 if other_rel==1|gp==1|non_rel==1|aunt==1

egen id=group(SSUID EPPPNUM)


save "$SIPP08keep/P&C_08", replace


* Sample
keep if SWAVE==2
bys id: sample 1, count
keep if TAGE<18

tab gp [aw=WPFINWGT] 
tab aunt [aw=WPFINWGT] 
tab other_rel [aw=WPFINWGT] 
tab non_rel [aw=WPFINWGT] 





