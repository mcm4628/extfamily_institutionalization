
use "$tempdir/allwaves"

do "$sipp2008_code/simple_rel_label"

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


simplify_relationships unified_rel simplified_rel ultra_simple_rel

display "Unhandled relationships"
tab unified_rel if missing(simplified_rel), m sort
display "Unhandled child relationships"
tab unified_rel if (missing(simplified_rel) & (from_age < $adult_age)), m sort

tab simplified_rel, m sort

tab simplified_rel if (from_age < $adult_age), m sort

sort SWAVE
by SWAVE:  tab simplified_rel, m sort
by SWAVE:  tab simplified_rel if (from_age < $adult_age), m sort


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


