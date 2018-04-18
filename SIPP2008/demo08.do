****************************************************************************
* creates a basic file describing individuals' demographic characteristics *
****************************************************************************

use "$tempdir/allwaves", clear

keep SSUID EPPPNUM SHHADID SWAVE ERRP EORIGIN ERACE ESEX EEDUCATE TAGE EMS WPFINWGT

gen raceth=ERACE
replace raceth=5 if inlist(ERACE,1,3,4) & EORIGIN==1

save "$tempdir/demoperson08.dta", replace

*generating some household demographics. 

gen hheduc=EEDUCATE if ERRP==1 | ERRP==2
gen hhage=TAGE if ERRP==1 | ERRP==2

sort SSUID SHHADID SWAVE

collapse (max) hheduc hhage, by(SSUID SHHADID SWAVE)

recode hheduc (1/38=1)(39=2)(40/43=3)(43/47=4)

recode hhage (0/25=1)(26/50=2)(51/99=3), gen(hhcage)

save "$tempdir/demoHH08.dta", replace


tab hheduc

tab hhcage

