
use "$tempdir/hh_change_for_relationships"

keep SSUID EPPPNUM SHHADID* adj_age* arrivers* leavers* stayers* comp_change* comp_change_reason* my_race my_sex 


reshape long SHHADID adj_age arrivers leavers stayers comp_change comp_change_reason, i(SSUID EPPPNUM) j(SWAVE)

gen have_arrivers = (indexnot(arrivers, " ") != 0)
gen have_leavers = (indexnot(leavers, " ") != 0)

gen have_changers = (have_arrivers | have_leavers)

tab comp_change have_changers

assert (have_changers == 0) if (comp_change == 0)
assert (have_changers == 0) if missing(comp_change)
assert (have_changers == 1) if (comp_change == 1)

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

    keep SSUID EPPPNUM SHHADID SWAVE my_race my_sex adj_age comp_change_reason `changer'* 

    reshape long `changer', i(SSUID EPPPNUM SWAVE) j(`changer'_num)

    drop if missing(`changer')

    save "$tempdir/hh_`changer's", $replace
}



*** NEED to confirm correctness of hh_chnage.
*** AND comment the code as part of that.

*** NEED to unify relationships (pretty much necessary to deal with arrivers).

*** THEN understand how many we don't know relationships for and what we can do about it.


use "$tempdir/hh_leavers"
drop if missing(leaver)
gen relfrom = EPPPNUM
destring leaver, gen(relto)
merge 1:1 SSUID SWAVE relfrom relto using "$tempdir/relationships_tc1_resolved", keepusing(relationship)

list if _merge == 1

keep if _merge == 3
drop _merge

tab relationship, m sort



* Quick stats on amount of unification needed.

clear

use "$tempdir/relationships_tc1_resolved"

keep SSUID relfrom relto relationship

drop if missing(relationship)


sort SSUID relfrom relto relationship
by SSUID relfrom relto:  gen total_instances = _N
by SSUID relfrom relto relationship:  gen rel_instances = _N
by SSUID relfrom relto relationship:  gen first_rel_instance = (_n == 1)
keep if (first_rel_instance == 1)
drop first_rel_instance

by SSUID relfrom relto:  gen relnum = _n
reshape wide relationship rel_instances, i(SSUID relfrom relto) j(relnum)

count if (total_instances == rel_instances1)

egen rels = concat(relationship*), punct(" ")

tab rels, sort

tab rels if (total_instances == rel_instances1), sort


*** TODO:  Add a flag indicating consistent versus computed.
gen unified_rel = rels if (total_instances == rel_instances1)
replace unified_rel = "SPOUSE" if (rels == "PARTNER SPOUSE")
replace unified_rel = "CHILD" if (rels == "BIOCHILD STEPCHILD")
replace unified_rel = "MOM" if (rels == "BIOMOM STEPMOM")
replace unified_rel = "DAD" if (rels == "BIODAD STEPDAD")
replace unified_rel = "STEPCHILD" if (rels == "CHILDOFPARTNER STEPCHILD")
replace unified_rel = "BIOMOM" if (rels == "AUNTUNCLE_OR_PARENT BIOMOM")
replace unified_rel = "CHILD" if (rels == "BIOCHILD CHILDOFPARTNER")

replace unified_rel = "SPOUSE" if (rels == "OTHER_REL SPOUSE")

replace unified_rel = "CONFUSED" if missing(unified_rel)

tab rels if (unified_rel == "CONFUSED"), sort

drop relationship* rel_instances* total_instances rels
save "$tempdir/unified_rel", $replace


foreach changer in leaver arriver stayer {
    clear

    use "$tempdir/hh_`changer's"
    drop if missing(`changer')
    gen relfrom = EPPPNUM
    destring `changer', gen(relto)
    merge m:1 SSUID relfrom relto using "$tempdir/unified_rel", keepusing(unified_rel)

    preserve
    keep if _merge == 1
    keep SSUID EPPPNUM relto
    duplicates drop
    sort SSUID EPPPNUM relto
    by SSUID EPPPNUM:  gen relto_num = _n
    reshape wide relto, i(SSUID EPPPNUM) j(relto_num)
    merge 1:m SSUID EPPPNUM using "$tempdir/allwaves", keepusing(ERRP EPNMOM EPNDAD EPNSPOUS SWAVE)
    keep if (_merge == 3)
    drop _merge
    save "$tempdir/norel_`changer's", $replace
    restore

    keep if _merge == 3
    drop _merge

    display "Unified relationships for `changer's"
    tab unified_rel, m sort
    save "$tempdir/`changer'_rels", $replace
}


*** TODO:
* Looks like grandchild of x who is grandparent of y is useful (at least one case -- who knows how many).
* Looks like more transitive NOREL might help, too.
*
* I see weirdness in adjusted ages, like a single 1 in the midst of large ages.  Examples:  459925246366/201, 077925358381/102.
