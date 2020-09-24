****************************************************************************
* Predict household instability by household composition
****************************************************************************
* need comp_change, which is a wide file. Make it long

use "$SIPP08keep/comp_change_am.dta", clear

keep SSUID EPPPNUM SHHADID* comp_change* comp_change_reason* adj_age* 

reshape long SHHADID adj_age comp_change comp_change_reason, i(SSUID EPPPNUM) j(panelmonth)

tab comp_change, m

keep if !missing(comp_change)
keep if adj_age < 18

* merge in relationships data 

merge 1:1 SSUID EPPPNUM panelmonth using "$tempdir/relationships.dta"
*need to revisit restrictions on relationships.dta
* I suspect that many of the observations in relationships.dta that aren't in comp_change
* have to do with missing the next wave.
* perhaps an easy way to check would be to look at panelmonth by _merge

tab panelmonth _merge

keep if _merge==3

drop _merge

save "$SIPP08keep/faminst_analysis.dta", replace
