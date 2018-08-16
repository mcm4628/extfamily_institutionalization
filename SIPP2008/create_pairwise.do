* Create a data file with one record for each coresident pair

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

drop if relto==relfrom

save "$tempdir/pairwise_bywave", $replace

duplicates drop SSUID relfrom relto, force

save "$tempdir/pairwise", $replace

use "$tempdir/pairwise_bywave", clear

merge 1:1 SSUID relfrom relto SWAVE using "$tempdir/relationship_pairs_bywave"

gen anyrels=0
replace anyrels=1 if !missing(relationship) 

tab anyrels, m

tab HHmembers if anyrels==0


use "$tempdir/pairwise", clear

merge 1:1 SSUID relfrom relto SWAVE using "$tempdir/relationship_pairs_bywave"

gen anyrels=0
replace anyrels=1 if !missing(relationship) 

tab anyrels, m
