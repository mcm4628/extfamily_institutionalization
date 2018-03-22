
use "$tempdir/allwaves"

keep SSUID EPPPNUM SWAVE SHHADID

merge 1:1 SSUID EPPPNUM SWAVE using "$tempdir/adjusted_ages_long"
drop if (_merge == 2)
assert (_merge == 3)
drop _merge

tempfile people
save `people'

rename EPPPNUM relfrom
rename adj_age from_age

joinby SSUID SHHADID SWAVE using `people'

rename EPPPNUM relto
rename adj_age to_age

drop if (relfrom == relto)

merge m:1 SSUID relfrom relto using "$tempdir/unified_rel"
replace unified_rel = .a if (_merge == 1) & (missing(unified_rel))
replace unified_rel = .m if (_merge == 3) & (missing(unified_rel))

assert (unified_rel != .)
drop _merge


tab unified_rel, m

tab unified_rel if (from_age < $adult_age), m


gen simplified_rel = .
label values simplified_rel relationship
replace simplified_rel = "CHILD":relationship if inlist(unified_rel, "BIOCHILD":relationship, "STEPCHILD":relationship, "ADOPTCHILD":relationship, "CHILDOFPARTNER":relationship, "CHILD":relationship)
replace simplified_rel = "PARENT":relationship if inlist(unified_rel, "BIOMOM":relationship, "STEPMOM":relationship, "ADOPTMOM":relationship, "BIODAD":relationship, "STEPDAD":relationship, "ADOPTDAD":relationship, "PARENT":relationship)
replace simplified_rel = "GRANDCHILD":relationship if inlist(unified_rel, "GRANDCHILD":relationship, "GREATGRANDCHILD":relationship)
replace simplified_rel = "GRANDPARENT":relationship if inlist(unified_rel, "GRANDPARENT":relationship, "GREATGRANDPARENT":relationship)
replace simplified_rel = "SIBLING":relationship if inlist(unified_rel, "SIBLING":relationship)
replace simplified_rel = "OTHER_REL":relationship if inlist(unified_rel, "OTHER_REL":relationship, "SPOUSE":relationship, "AUNTUNCLE_OR_PARENT":relationship, "AUNTUNCLE":relationship, "NEPHEWNIECE":relationship, "SIBLING_OR_COUSIN":relationship, "CHILD_OR_NEPHEWNIECE":relationship)
replace simplified_rel = "NOREL":relationship if inlist(unified_rel, "NOREL":relationship, "PARTNER":relationship, "F_CHILD":relationship)

replace simplified_rel = "F_PARENT":relationship if inlist(unified_rel, "F_PARENT":relationship)

replace simplified_rel = "GRANDCHILD_P":relationship if inlist(unified_rel, "GRANDCHILD_P":relationship)
replace simplified_rel = "GRANDPARENT_P":relationship if inlist(unified_rel, "GRANDPARENT_P":relationship)
replace simplified_rel = "OTHER_REL_P":relationship if inlist(unified_rel, "OTHER_REL_P":relationship)

replace simplified_rel = "DONTKNOW":relationship if inlist(unified_rel, "DONTKNOW":relationship)

replace simplified_rel = "CONFUSED":relationship if inlist(unified_rel, "CONFUSED":relationship, .a, .m)

display "Unhandled relationships"
tab unified_rel if missing(simplified_rel), m sort
display "Unhandled child relationships"
tab unified_rel if (missing(simplified_rel) & (from_age < $adult_age)), m sort

tab simplified_rel, m sort

tab simplified_rel if (from_age < $adult_age), m sort

sort SWAVE
by SWAVE:  tab simplified_rel, m sort
by SWAVE:  tab simplified_rel if (from_age < $adult_age), m sort


local lnum = 1
foreach r in CHILD SIBLING GRANDCHILD OTHER_ADULT OTHER_CHILD {
    local llist = `"`llist' `lnum' "`r'""'
    local lnum = `lnum' + 1
}
label define ultra_simple_rel `llist'

gen ultra_simple_rel = .
label values ultra_simple_rel ultra_simple_rel
* TODO:  automate choosing the right label to dereference.
replace ultra_simple_rel = "CHILD":ultra_simple_rel if (simplified_rel == "CHILD":relationship)
replace ultra_simple_rel = "SIBLING":ultra_simple_rel if (simplified_rel == "SIBLING":relationship)
replace ultra_simple_rel = "GRANDCHILD":ultra_simple_rel if (simplified_rel == "GRANDCHILD":relationship)
replace ultra_simple_rel = "OTHER_CHILD":ultra_simple_rel if (missing(ultra_simple_rel) & (to_age < $adult_age))
replace ultra_simple_rel = "OTHER_ADULT":ultra_simple_rel if (missing(ultra_simple_rel))
tab ultra_simple_rel, m sort

tab ultra_simple_rel if (from_age < $adult_age), m sort

save "$tempdir/examine_hh", $replace




use "$tempdir/shhadid_members"

keep SSUID SHHADID SWAVE shhadid_members
reshape wide shhadid_members, i(SSUID SHHADID) j(SWAVE)

gen members = shhadid_members$first_wave
gen same_members = 1
gen num_waves = !missing(shhadid_members$first_wave)
forvalues wave = $second_wave/$final_wave {
    replace members = shhadid_members`wave' if missing(members)

    replace same_members = 0 if ((!missing(members)) & (!missing(shhadid_members`wave')) & (members != shhadid_members`wave'))

    replace num_waves = num_waves + 1 if !missing(shhadid_members`wave')
}
drop members
drop shhadid_members*

save "$tempdir/hh_same_stats", $replace



use "$tempdir/examine_hh"

merge m:1 SSUID SHHADID using "$tempdir/hh_same_stats"

drop if (_merge == 2)
assert (_merge == 3)
drop _merge


tab same_members simplified_rel, m row
tab same_members simplified_rel if (from_age < $adult_age), m row

save "$tempdir/examine_hh_2", $replace

keep if (num_waves > 2)
tab same_members simplified_rel, m row
tab same_members simplified_rel if (from_age < $adult_age), m row

clear


