* Create a record for every type 2 person with their ssuid, pnum, sex, and age
*
*

use "$SIPP2014data/selected.dta", clear

keep ssuid pnum monthcode et2_lno* tt2_age* et2_sex*

reshape long et2_lno tt2_age et2_sex, i(ssuid pnum monthcode) j(t2pno)

keep if et2_lno != .

sort ssuid et2_lno

drop monthcode t2pno pnum

rename et2_lno pnum

by ssuid pnum: gen first=1 if _n==1
by ssuid pnum: gen last=1 if _N==_n

tab tt2_age if first==1
tab tt2_age if last==1

by ssuid pnum: keep if _n==1

save "$SIPP2014data/t2persons.dta", replace
