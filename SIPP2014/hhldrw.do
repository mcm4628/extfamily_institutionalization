use "$SIPP2014data/selected.dta", clear

keep if monthcode==12

keep ssuid pnum erelrp

gen hhldr_pnum=0
replace hhldr_pnum=pnum if erelrp==1 | erelrp==2

tab pnum
tab hhldr_pnum

keep if hhldr_pnum > 0

tab hhldr_pnum

drop erelrp

sort ssuid

save "$tempdir/hhldr.dta", replace
