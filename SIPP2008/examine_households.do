//========================================================================================//
//===== Children's Household Instability Project                
//===== Dataset: SIPP2008                                       
//===== Purpose: Creates a pairwise dataset with every pair of people living together in a wave represented. 
//===== Logic: The result is integrated with a "dictionary" of relationships so that we can descibe the characteristics of 
//             people living together using either a complete list of relationship types (unified_rel) or a collapsed set of
//             relationship types.
//=======================================================================================//


//=================================================================//
//== Purpose: Preparation for dataset. 
//=================================================================//
use "$tempdir/allwaves"

do "$sipp2008_code/simple_rel_label"

keep SSUID EPPPNUM SWAVE SHHADID

merge 1:1 SSUID EPPPNUM SWAVE using "$tempdir/adjusted_ages_long"
drop if (_merge == 2)
assert (_merge == 3)
drop _merge

*********************************************************************
** Function: Create a temporary dataset for every person (from) in that person's household in a wave.
*********************************************************************

tempfile people
save `people'

rename EPPPNUM relfrom
rename adj_age from_age


*********************************************************************
** Function: Merge every person (from) to every other person (to) in that person's hosuehold in a wave.
**
** Logic: Each observation in the resulting data set represents a pair of people living together.
*********************************************************************
joinby SSUID SHHADID SWAVE using `people'

rename EPPPNUM relto
rename adj_age to_age

*********************************************************************
** Function: drop pairs that are ego and her/himself.
*********************************************************************
drop if (relfrom == relto)

*********************************************************************
** Function: Merge with "unified_rel" to determine the relationship of each pair. 
**
** Logic: Every pair of people has a relationship. These pairs are defined in "unified_rel"
*********************************************************************
merge m:1 SSUID relfrom relto using "$tempdir/unified_rel"
replace unified_rel = .a if (_merge == 1) & (missing(unified_rel))
replace unified_rel = .m if (_merge == 3) & (missing(unified_rel))

assert (unified_rel != .)
drop _merge

tab unified_rel, m

tab unified_rel if (from_age < $adult_age), m


******************************************************************
** Function: This calls a program defined in "project_macros". 
******************************************************************
simplify_relationships unified_rel simplified_rel ultra_simple_rel

display "Unhandled relationships"
tab unified_rel if missing(simplified_rel), m sort
display "Unhandled child relationships"
tab unified_rel if (missing(simplified_rel) & (from_age < $adult_age)), m sort

******************************************************************
** Function: Tabulate relationships and child relationships. 
******************************************************************
tab simplified_rel, m sort
tab simplified_rel if (from_age < $adult_age), m sort

sort SWAVE
by SWAVE:  tab simplified_rel, m sort
by SWAVE:  tab simplified_rel if (from_age < $adult_age), m sort


tab ultra_simple_rel, m sort
tab ultra_simple_rel if (from_age < $adult_age), m sort

save "$tempdir/examine_hh", $replace


******************************************************************
** Function: Reshape the household members data from long (by wave) to wide. 
******************************************************************

use "$tempdir/shhadid_members"

keep SSUID SHHADID SWAVE shhadid_members

reshape wide shhadid_members, i(SSUID SHHADID) j(SWAVE)

******************************************************************
** Function: Loop through waves to flag same members. 
**
** Logic: If member is missing in the first wave, replace it with later wave's information. 
******************************************************************
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


******************************************************************
** Function: Tabulate relationships and child relationships for members. 
******************************************************************
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


