
use "$tempdir/comp_change.dta", clear

merge 1:1 SSUID EPPPNUM using "$tempdir/demo_wide.dta"

keep comp_change* adj_age* biomom_age* WPFINWGT* my_race mom_educ* SSUID EPPPNUM  

reshape long adj_age comp_change comp_change_reason WPFINWGT biomom_age mom_educ, i(SSUID EPPPNUM) j(SWAVE)

save "$tempdir/comp_change_long.dta", $replace

merge 1:1 SSUID EPPPNUM SWAVE using "$tempdir/hh_change.dta"
