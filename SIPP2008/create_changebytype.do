use "$tempdir/comp_change.dta"

merge 1:1 SSUID EPPPNUM using "$tempdir/demo_wide.dta"

keep comp_change* adj_age* biomom_age* WPFINWGT* SSUID EPPPNUM  

reshape long adj_age comp_change comp_change_reason WPFINWGT biomom_age, i(SSUID EPPPNUM) j(SWAVE)

save "$tempdir/comp_change_long.dta", $replace

merge 1:m SSUID EPPPNUM SWAVE using "$tempdir/changer_rels", keepusing(relationship parent sibling change_type my_race my_race2 my_sex biomom_age)

tab _merge if comp_change==1

local reltyp "parent sib other"

tab comp_change relationship, m

gen parent_change=1 if comp_change==1 & parent==1
gen sib_change=1 if comp_change==1 & sibling==1
gen other_change=1 if comp_change==1 & parent!=1 & sibling !=1

collapse (max) comp_change parent_change sib_change other_change, by(SSUID EPPPNUM SWAVE)

merge 1:1 SSUID EPPPNUM SWAVE using "$tempdir/comp_change_long.dta"

drop _merge

* set relationship-specific composition change variables to 0 if comp_change is not missing and specific relationship type wasn't observed among the changers.
foreach r in `reltyp'{
	replace `r'_change=0 if missing(`r'_change) & !missing(comp_change)
}

tab parent_change comp_change, m

save "$tempdir/changebytype.dta", $replace

tab comp_change

tab comp_change parent_change, m
tab comp_change sib_change, m
tab comp_change other_change, m
