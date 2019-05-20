/*
This do file identifies problems with the EBORNUS variable. 
This variable indicates whether the individual was born in the US or not.
It is especially important variable for the papers that deals with immigrants.
In the 2004 HH_change.dta 39.4% of the observations (person-waves) have missing values 
in EBORNUS. Most of these cases are due to missing waves- the individual was missing in this 
specific wave and therefore no value wavs given. However, in 4,220 cases composition change is 
counted for these missing cases, probably due to changes that observed among other members of 
the household. 
In order to fix this problem EBORNUS is coded based on other waves that the individual 
was observed in.
*/

use "$tempdir/hh_change.dta", clear

/*Keep only cases that nativity was observed and drop duplicsates so each person 
will have one observation*/
keep SSUID EPPPNUM EBORNUS 
drop if EBORNUS==.

/*In 2,435 cases EBRONUS changed over time. We use the most common value of EBORNUS
for the missing values. However, in 782 cases EBORNUS has an equal number of observations
with different values*/
collapse (mean)EBORNUS , by(SSUID EPPPNUM)
replace EBORNUS=1 if EBORNUS<1.5
replace EBORNUS=2 if EBORNUS>1.5

save "$tempdir/nativity.dta", replace

*merging to original file:
use "$tempdir/hh_change.dta", clear
drop EBORNUS
merge m:1 SSUID EPPPNUM using "$tempdir/nativity.dta"


/*The 782 cases with equal number of values of nativity equal to 1,260 person waves
of children under 17 with an observed comp_change (0.6%)*/

save "$tempdir/hh_change.dta",replace
