* Create a data file with one record for each coresident pair in each wave
* Merge onto the file the relationships data created by unify_relationships.


****************************************************************************
* create database with all pairs of coresident individuals in each wave
****************************************************************************
use "$tempdir/allwaves"

keep SSUID SHHADID EPPPNUM SWAVE ERRP

sort SSUID SHHADID SWAVE

by SSUID SHHADID SWAVE:  gen HHmembers = _N  /* Number the people in the household in each wave. */

rename EPPPNUM relto
rename ERRP ERRPto

save "$tempdir/to", $replace

use "$tempdir/allwaves", clear

keep SSUID SHHADID EPPPNUM SWAVE ERRP

rename EPPPNUM relfrom
rename ERRP ERRPfrom

joinby SSUID SHHADID SWAVE using "$tempdir/to"  

* drop pairs of ego to self
drop if relto==relfrom

save "$tempdir/pairwise_bywave", $replace

/*
********************************************************************************
* for the purpose of checking how many pairs of individuals are represented in 
* the unified relationships, create a pairwise database for all waves
********************************************************************************

duplicates drop SSUID relfrom relto, force

drop SWAVE

save "$tempdir/pairwise", $replace

*/

use "$tempdir/pairwise_bywave", clear

merge m:1 SSUID relfrom relto using "$tempdir/unified_rel"

tab unified_rel, m

* data file with one record per pair of coresident individuals per wave
* in many cases you'll collapse by hh (SSUID SHHADID SWAVE) to identify HH composition
* for example, collapse to see if ego is grandchild to anyone in the household

save "$tempdir\HHComp.dta"






