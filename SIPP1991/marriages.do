use "$tempdir/person_wide_adjusted_ages", clear

gen firstobserved=0
gen firstms=0

forvalues wave=1/8 {
	replace firstobserved=`wave' if firstobserved==0 & in`wave'==1
	replace firstms=EMS`wave' if firstobserved==`wave'
}

gen gotmarried=0

forvalues wave=1/8 {
	replace gotmarried=`wave' if gotmarried==0 & firstms > 2 & EMS`wave' <=2	
}
*limited to those unmarried at first observation 
