use "$tempdir/hh_change", clear

keep EPPPNUM SSUID SHHADID* comp_change*

gen nmis_compchange=0
gen numchange=0

forvalues i=1/5 {
	replace nmis_compchange=nmis_compchange+1 if missing(comp_change`i')
	replace numchange=numchange+1 if comp_change`i'==1
}

*drop cases that don't appear in the data before Wave 6
drop if nmis_compchange==5


tab nmis_compchange

tab numchange

tab numchange nmis_compchange

keep EPPPNUM SSUID numchange nmis_compchange

