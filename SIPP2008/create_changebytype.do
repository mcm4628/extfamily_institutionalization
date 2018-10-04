use "$tempdir/comp_change.dta"

keep comp_change* adj_age* biomom_age* WPFINWGT* SSUID EPPPNUM  

reshape long adj_age comp_change comp_change_reason WPFINWGT biomom_age, i(SSUID EPPPNUM) j(SWAVE)

save "$tempdir/comp_change_long.dta", $replace

merge 1:m SSUID EPPPNUM SWAVE using "$tempdir/changer_rels", keepusing(unified_rel simplified_rel ultra_simple_rel change_type my_race my_race2 my_sex biomom_age)

tab _merge if comp_change==1

local reltyp "parent sib other"

tab comp_change ultra_simple_rel, m

gen parent_change=1 if comp_change==1 & ultra_simple_rel==1
gen sib_change=1 if comp_change==1 & ultra_simple_rel==2
gen other_change=1 if comp_change==1 & inlist(ultra_simple_rel,3,4)

collapse (max) comp_change parent_change sib_change other_change, by(SSUID EPPPNUM SWAVE)

merge 1:1 SSUID EPPPNUM SWAVE using "$tempdir/comp_change_long.dta"

drop _merge

foreach r in `reltyp'{
	replace `r'_change=0 if missing(`r'_change) & comp_change==0
}

save "$tempdir/changebytype.dta", $replace

tab comp_change

tab comp_change parent_change, m
tab comp_change sib_change, m
tab comp_change other_change, m
