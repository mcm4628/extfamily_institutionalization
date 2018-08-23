//==============================================================================
//===== Children's Household Instability Project
//===== Dataset: SIPP2008
//===== Purpose:  Link individuals identified as entering, leaving, or staying in
//===== a person's (ego's) household to their relationship to ego.
//==============================================================================

use "$tempdir/comp_change.dta", clear

keep SSUID EPPPNUM SHHADID* arrivers* leavers* stayers* comp_change* comp_change_reason* adj_age* 

reshape long SHHADID adj_age arrivers leavers stayers comp_change comp_change_reason, i(SSUID EPPPNUM) j(SWAVE)

gen have_arrivers = (indexnot(arrivers, " ") != 0)
gen have_leavers = (indexnot(leavers, " ") != 0)

gen have_changers = (have_arrivers | have_leavers)

tab comp_change have_changers

assert (have_changers == 0) if (comp_change == 0)
assert (have_changers == 0) if missing(comp_change)
assert (have_changers == 1) if (comp_change == 1)

*** comp_change needs to be labeled, so does comp_change_reasons (S)
drop if missing(comp_change)

drop if (comp_change == 0)

save "$tempdir/comp_change_with_relationships", $replace

foreach changer in leaver arriver stayer {
    clear

    use "$tempdir/comp_change_with_relationships"

    * Compute max number of leavers/arrivers.
    gen n_`changer's = wordcount(`changer's)
    egen max_`changer's = max(n_`changer's)
    drop n_`changer's

    forvalues my_`changer'_num = 1/`=max_`changer's' {
        gen `changer'`my_`changer'_num' = word(`changer's, `my_`changer'_num')
    }
    drop `changer's max_`changer's

    keep SSUID EPPPNUM SHHADID SWAVE adj_age comp_change_reason `changer'* 

    reshape long `changer', i(SSUID EPPPNUM SWAVE) j(`changer'_num)

    drop if missing(`changer')

    save "$tempdir/hh_`changer's", $replace
}

********************************************************************************
* Linking those who experience a composition change to unified relationships 
********************************************************************************

foreach changer in leaver arriver stayer {
    clear

    use "$tempdir/hh_`changer's"
    drop if missing(`changer')
    gen relfrom = EPPPNUM
    destring `changer', gen(relto)
    merge m:1 SSUID relfrom relto using "$tempdir/unified_rel", keepusing(unified_rel)
	
	display "deleting relationships to self"
	drop if relfrom==relto

	replace unified_rel=40 if _merge==1

    drop if _merge == 2
    drop _merge

    display "Unified relationships for `changer's"
    tab unified_rel, m sort
    save "$tempdir/`changer'_rels", $replace
}



foreach changer in leaver arriver {
	clear
    display "Processing `changer's"
	
	use "$tempdir/`changer'_rels"

* Label relationships. 
    do "$sipp2008_code/simple_rel_label"
	
    rename adj_age from_age

    drop EPPPNUM
    gen EPPPNUM = relto
    merge m:1 SSUID EPPPNUM SWAVE using "$tempdir/demo_long", keepusing(adj_age)
    drop if (_merge == 2)
    assert (_merge == 3)
    drop _merge
    drop EPPPNUM
    rename adj_age to_age
}

gen change_type=1

append using "$tempdir/leaver_rels"
replace change_type=2 if missing(change_type)

label variable change_type "Indicator for whether this person arrive in or left from ego's household"
label define change_type 1 "arriver" 2 "leaver" 

label values change_type change_type 

simplify_relationships unified_rel simplified_rel ultra_simple_rel


merge m:1 SSUID EPPPNUM SWAVE using "$tempdir/demo_long"

save "$tempdir/changer_rels", $replace

* Tabulate relatinshps for child. 	
tab simplified_rel if (adj_age < $adult_age)
tab ultra_simple_rel if (adj_age < $adult_age)

tab simplified_rel my_race if (adj_age < $adult_age)
tab ultra_simple_rel my_race if (adj_age < $adult_age)

tab simplified_rel my_race if (adj_age < $adult_age), col
tab ultra_simple_rel my_race if (adj_age < $adult_age), col
