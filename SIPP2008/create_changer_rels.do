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
* Linking those who experience a composition change to relationships
********************************************************************************

foreach changer in leaver arriver stayer {
    clear

    use "$tempdir/hh_`changer's"
    drop if missing(`changer')
    gen relfrom = EPPPNUM
    destring `changer', gen(relto)
    merge 1:1 SSUID relfrom relto SWAVE using "$tempdir/relationship_pairs_bywave", keepusing(relationship)
	
	display "deleting relationships to self"
	drop if relfrom==relto

	replace relationship=40 if _merge==1

    drop if _merge == 2
    drop _merge

    display "Relationships for `changer's"
    tab relationship, m sort
    save "$tempdir/`changer'_rels", $replace
}


*getting the age of each person so that we can calculate an age difference

foreach changer in leaver arriver {
	clear
    display "Processing `changer's"
	
	use "$tempdir/`changer'_rels"

    rename adj_age from_age

	drop EPPPNUM
	
	* get changer age *
    gen EPPPNUM = relto
    merge m:1 SSUID EPPPNUM SWAVE using "$tempdir/demo_long_all", keepusing(adj_age)
    drop if (_merge == 2)
    assert (_merge == 3)
	
    drop _merge
    drop EPPPNUM
    rename adj_age to_age
	
	* bring back ego's person number
	rename relfrom EPPPNUM
	
	save "$tempdir/`changer'_rels_withage", $replace
}    

gen change_type=1

append using "$tempdir/leaver_rels_withage"
replace change_type=2 if missing(change_type)

label variable change_type "Indicator for whether this person arrive in or left from ego's household"
label define change_type 1 "arriver" 2 "leaver" 

label values change_type change_type 

* Label relationships. 
do "$sipp2008_code/simple_rel_label"

gen bioparent=1 if relationship==1
gen parent=1 if inlist(relationship,1,4,7,19,20,21,30,31,38)
gen sibling=1 if inlist(relationship, 17,33,34)
gen child=1 if inlist(relationship,2,3,5,6,8,9,10,11,22,23,25,26)
gen spartner=1 if inlist(relationship,12,18)
gen nonrel=1 if relationship==37
gen grandparent=1 if inlist(relationship,13,14,27)
gen other_rel=1 if inlist(relationship, 15,16,24,28,29,32,35)
gen unknown=1 if relationship==40 | missing(relationship)
gen nonnuke=1 if nonrel==1 | grandparent==1 | other_rel==1 | unknown==1 

merge m:1 SSUID EPPPNUM SWAVE using "$tempdir/demo_long_all"

*need to match all leavers and arrivers in the demographic data
 drop if (_merge == 2)
 assert (_merge == 3)

keep if _merge==3

save "$tempdir/changer_rels", $replace


