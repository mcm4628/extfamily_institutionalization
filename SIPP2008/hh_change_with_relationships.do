//==============================================================================
//===== Children's Household Instability Project
//===== Dataset: SIPP2008
//===== Purpose:  Link individuals identified as entering, leaving, or staying in
//===== a person's (ego's) household to their relationship to ego.
//==============================================================================

use "$tempdir/hh_change_for_relationships"

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

save "$tempdir/hh_change_with_relationships", $replace

foreach changer in leaver arriver stayer {
    clear

    use "$tempdir/hh_change_with_relationships"

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
