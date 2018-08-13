* Create a data file with one record for each coresident pair

use "$tempdir/allwaves"

keep SSUID SHHADID EPPPNUM SWAVE 

rename EPPPNUM relto

save "$tempdir/to", $replace

use "$tempdir/allwaves", clear

keep SSUID SHHADID EPPPNUM SWAVE 

rename EPPPNUM relfrom

joinby SSUID SHHADID SWAVE using "$tempdir/to"  

drop if relto==relfrom

save "$tempdir/pairwise_bywave", $replace

duplicates drop SSUID relfrom relto, force

save "$tempdir/pairwise", $replace

use "$tempdir/pairwise_bywave", clear

merge 1:1 SSUID relfrom relto SWAVE using "$tempdir/relationships_tc1_wide"

tab numrels_tc0, m
