*use "$tempdir/comp_change.dta"

*drop _*

*reshape long SHHADID adj_age arrivers leavers stayers comp_change comp_change_reason, i(SSUID EPPPNUM) j(SWAVE)

use "$tempdir/comp_change_long.dta", clear

merge 1:m SSUID EPPPNUM SWAVE using "$tempdir/changer_rels", keepusing(unified_rel simplified_rel ultra_simple_rel change_type)

local reltyp "parent sib other"

foreach r of `reltyp'{
	gen `r'_change=1
}

replace parent_change=1 if comp_change==1 & ultra_simple_rel==1
replace sibling_change=1 if comp_change==1 & ultra_simple_rel==2
replace other_change=1 if comp_change==1 & inlist(ultra_simple_rel,3,4)

collapse (max) parent_change sibling_change other_change. by(SSUID EPPPNUM SWAVE)

merge 1:1 SSUID EPPPNUM SWAVE using "$tempdir/comp_change_long.dta"

save "$tempdir/changebytype.dta", $replace
