use "$SIPP2008/TM4/childwellbeing.dta"
destring epppnum, replace

save "$SIPP2008/TM4/childwellbeing.dta", replace


***create hhtype*********
use "$SIPP08keep/HHComp_asis.dta", clear

**keep sample to wave6
keep if SWAVE==4
keep if adj_age<=15
****sample size 19153***//

keep SSUID EPPPNUM SHHADID relationship adj_age to_age to_sex
sort SSUID EPPPNUM
by SSUID EPPPNUM: gen n=_n

****give the relationship backwards to children***
gen parent=1 if inlist(relationship,1,4,7,19,21)
gen grandparent=1 if inlist(relationship,13,14,27)
gen grandmother=1 if inlist(relationship,13,14,27) & to_sex==2
gen other_rel=1 if inlist(relationship, 15,16,24,25,26,28,29,30,31,33,32,35,36) 
gen other_femrel=1 if inlist(relationship, 15,16,24,25,26,28,29,30,31,33,32,35,36) & to_sex==2 
gen unknown=1 if relationship==40 | missing(relationship)

gen otheradult30=. 
recode otheradult30 .=1 if parent==.  & to_age>30
gen otherfemadult30=1 if otheradult30==1 & to_sex==2
gen othermaladult30=1 if otheradult30==1 & to_sex==1

gen otheradult=.
recode otheradult .=1 if parent==.  & to_age>=18
gen otherfemadult =1 if otheradult==1 & to_sex==2
gen othermaladult =1 if otheradult==1 & to_sex==1
gen child=1 if to_age<=16

reshape wide to_age to_sex relationship parent grandparent grandmother other_rel other_femrel child otheradult30 otherfemadult30 othermaladult30 otheradult otherfemadult othermaladult unknown, i(SSUID EPPPNUM) j(n)

****count number of each type of people in hh****
egen parents=anycount(parent*), v(1)
egen otheradults30=anycount(otheradult30*), v(1)
egen otherfemadult30=anycount(otherfemadult30*), v(1)
egen othermaladult30=anycount(othermaladult30*), v(1)
egen grandmother=anycount(grandmother*), v(1)
egen otheradults=anycount(otheradult*), v(1)
egen otherfemadults=anycount(otherfemadult*), v(1)
egen othermaladults=anycount(othermaladult*), v(1)
egen children=anycount(child*), v(1)
gen num_child=children+1
recode otheradults30 (2/max=1), gen (anyotheradults30)
recode otheradults (2/max=1), gen (anyotheradults)
tab parents
recode parents 3=2

recode otherfemadult30 (0=0)(1/3=1), gen(anyofem30)
recode othermaladult30 (0=0)(1/3=1), gen(anyomal30)
recode otherfemadults (0=0)(1/9=1), gen(anyofem18)
recode othermaladults (0=0)(1/9=1), gen(anyomal18)

merge 1:1 SSUID EPPPNUM using "$tempdir/person_wide.dta", keepusing (par_ed_first my_racealt)

keep if _merge==3

drop _merge

rename SSUID ssuid
rename EPPPNUM epppnum 

merge 1:1 ssuid epppnum using "$SIPP2008/TM4/childwellbeing.dta"
keep if _merge==3
drop _merge

save "$tempdir/cwb4.dta", $replace

tab ehltstat parents, col
tab erepgrad parents, col
tab efarscho parents, col
tab etvrules parents, col
