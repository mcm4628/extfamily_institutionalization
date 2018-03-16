
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
replace simplified_rel = "CHILD":relationship if inlist(unified_rel, "BIOCHILD":relationship, "STEPCHILD":relationship, "ADOPTCHILD":relationship. "CHILDOFPARTNER":relationship, "CHILD":relationship)
replace simplified_rel = "PARENT":relationship if inlist(unified_rel, "BIOMOM":relationship, "STEPMOM":relationship, "ADOPTMOM":relationship, "BIODAD":relationship, "STEPDAD":relationship, "ADOPTDAD":relationship)
replace simplified_rel = "GRANDCHILD":relationship if inlist(unified_rel, "GRANDCHILD":relationship, "GREATGRANDCHILD":relationship)
replace simplified_rel = "SIBLING":relationship if inlist(unified_rel, "SIBLING":relationship)
replace simplified_rel = "OTHER_REL":relationship if inlist(unified_rel, "OTHER_REL":relationship, "SPOUSE":relationship, "AUNTUNCLE_OR_PARENT":relationship, "NEPHEWNIECE":relationship)
replace simplified_rel = "NOREL":relationship if inlist(unified_rel, "NOREL":relationship, "PARTNER":relationship, "F_CHILD":relationship)
replace simplified_rel = "CONFUSED":relationship if inlist(unified_rel, "CONFUSED":relationship, .a, .m)

tab simplified_rel, m

tab simplified_rel if (from_age < $adult_age), m

sort SWAVE
by SWAVE:  tab simplified_rel, m
by SWAVE:  tab simplified_rel if (from_age < $adult_age), m

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


