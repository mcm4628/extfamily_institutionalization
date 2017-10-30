* Pulling records with a recorded type 1 and type 2 biomom
*
*
use "$SIPPshared/badcases.dta"

sort ssuid

by ssuid: keep if _n==1

merge 1:m ssuid using "$SIPP2014data/selected.dta"

keep if _merge==3

save "$SIPPshared/t1t2biomom.dta", replace
