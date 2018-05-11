* Creates an analysis file with demographic variables

use "$tempdir/hh_change", clear

keep SSUID EPPPNUM SHHADID* WPFINWGT* adj_age* addr_change* comp_change* adult_change* child_change* my_race

reshape long adj_age addr_change comp_change WPFINWGT adult_change child_change SHHADID, i(SSUID EPPPNUM) j(SWAVE)

sort SSUID EPPPNUM SWAVE

merge m:1 SSUID EPPPNUM SWAVE using "$tempdir/demo08.dta"
* allwaves will have race and sex but not maternal education

tab adj_age _merge, m

keep if _merge==3 | comp_change==1 | addr_change==1

drop _merge

gen anychange=addr_change
replace anychange=1 if comp_change==1

keep if adj_age < 17

save "$tempdir/hhchange_analysis", replace

tab first_raceth
tab momfirstced

duplicates drop SSUID EPPPNUM, force

tab first_raceth
tab momfirstced

* Why is this sample smaller than for Table 1? Is it because one needs to be observed in two waves? 
