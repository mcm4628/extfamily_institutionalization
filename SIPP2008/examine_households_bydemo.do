use "$tempdir/examine_hh", clear

tab ultra_simple_rel if (from_age < $adult_age), m sort

tab unified_rel if (from_age < $adult_age), m sort

rename relfrom EPPPNUM

sort SSUID EPPPNUM SWAVE

merge m:1 SSUID EPPPNUM SWAVE using "$tempdir/demoperson08.dta"

tab TAGE _merge

keep if _merge==3

drop _merge

sort SSUID SHHADID SWAVE

merge m:1 SSUID SHHADID SWAVE using "$tempdir/demoHH08.dta"

keep if _merge==3



tab ultra_simple_rel if (from_age < $adult_age), m sort

sort raceth 
by raceth: tab ultra_simple_rel if (from_age < $adult_age), m sort

sort hheduc
by hheduc: tab ultra_simple_rel if (from_age < $adult_age), m sort

preserve

keep if hheduc==4 & raceth==1

tab ultra_simple_rel if (from_age < $adult_age), m sort

restore
