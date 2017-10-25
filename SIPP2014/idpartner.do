* A file that creates person number of partner 
* I will merge this onto the child record after childrenHH14 creates biomom_pnum
* Will only work if mom is in the household at interview
use "$SIPP2014data/selected.dta", clear

keep ssuid pnum rrel_pnum* rrel* wpfinwgt erace eeduc monthcode

merge m:1 ssuid using "$tempdir/hhldr.dta"

drop _merge

* rrel* variables describe relationships, rrel_pnum describes person numbers.
* I am pretty sure that rrelX is missing if X is not in the household.

gen sp_pnum=-99
gen np=0
gen ns=0

gen s_pnum=-99
gen p_pnum=-99

forvalues i=1/30{
replace sp_pnum=rrel_pnum`i' if rrel`i' >=1 & rrel`i' <=4
replace s_pnum=rrel_pnum`i' if rrel`i'==1 | rrel`i'==3
replace p_pnum=rrel_pnum`i' if rrel`i'==2 | rrel`i'==4
replace ns=ns+1 if rrel`i' ==1 | rrel`i' ==3
replace np=np+1 if rrel`i' ==2 | rrel`i' ==4
}

tab np ns
tab s_pnum p_pnum 
tab sp_pnum
tab p_pnum
tab s_pnum

gen spisrefp=0 if np > 0 | ns > 0
replace spisrefp=1 if spisrefp==0 & pnum==hhldr_pnum 
replace spisrefp=1 if spisrefp==0 & sp_pnum==hhldr_pnum

* checking to see if self or spouse-partner is reference person

tab spisrefp np
tab spisrefp ns

drop rrel*

reshape wide sp_pnum spisrefp np ns s_pnum p_pnum wpfinwgt , i(ssuid pnum) j(monthcode)


* changecoh and changespo are indicators of whether there were any changes 
* in the reference year.

gen changecoh=0
gen changespo=0

forvalues i=1/11{
local j=`i'+1
replace changecoh=1 if p_pnum`i' != p_pnum`j' 
replace changespo=1 if s_pnum`i' != s_pnum`j' 
}

tab sp_pnum1 sp_pnum4

merge 1:1 ssuid pnum using "$tempdir/pchangehc.dta"

gen partner_change14=0
replace partner_change14=1 if epnspco_ehc1 != epnspco_ehc4

gen partner_change48=0
replace partner_change48=1 if epnspco_ehc4 != epnspco_ehc8

gen partner_change812=0
replace partner_change812=1 if epnspco_ehc8 != epnspco_ehc12

drop _merge

tab changecoh diffcoh
tab changespo diffspo

rename pnum biomom_pnum

save "$tempdir/idpartner.dta", replace
