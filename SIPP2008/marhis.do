use "$SIPP2008/marhis.dta", clear

drop if TAGE > 40

/* keep women */
drop if ESEX !=2

gen mar1yr=9999
replace mar1yr=TFMYEAR if EXMAR > 1
replace mar1yr=TLMYEAR if EXMAR==1

 gen dur2mar=int(mar1yr-TBYEAR) 
	
gen evermar=1
replace evermar=0 if EMS==6
	
	*Replicate person-year marriage variable
	forvalues d=10/34{
		gen mar`d'=0
		replace mar`d'=1 if `d' >=dur2mar & evermar==1
	}
		
gen person=_n
		
	reshape long mar, i(person) j(dur) 

	gen year=TBYEAR+dur

	drop if dur > dur2mar

save  "$SIPP2008\SIPP_pymar.dta", replace

keep if 2000 < year & year < 2009
keep if dur > 17 & dur < 30

tab year mar [aweight=WPFINWGT], nofreq row
