****************************************************************************
* creates a basic file describing individuals' demographic characteristics *
****************************************************************************

use "$SIPP2014data/selected.dta", clear

keep if monthcode==12

keep ssuid eresidenceid pnum monthcode eorigin erace esex eeduc tage ems wpfinwgt

save "$tempdir/demo.dta", replace
