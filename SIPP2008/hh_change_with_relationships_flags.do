use "$tempdir/hh_change_for_relationships"

capture program drop unify_relationship
program define unify_relationship
    * primary_list is the list of relationships to be considered definitively compatible.
    * secondary_list is the list of additional relationships that may be compatible with the primary_list,
    * but if only erlationships from the secondary_list are present we cannot conclude this relationship is of the class.
    * E.g., OTHER_REL won't prevent us from declaring someone a child, but we cannot declare them a child if OTHER_REL is the only information we have.
    args primary_list secondary_list

    if (wordcount("`primary_list'") == 0) {
        display as error "unify_relationship:  argument primary_list must be non-blank"
        error 111
    }

    local primary_rels `""`=word("`primary_list'", 1)'":relationship"'
    forvalues i = 2/`=wordcount("`primary_list'")' {
        local primary_rels `"`primary_rels', "`=word("`primary_list'", `i')'":relationship"'
    }

    if (wordcount("`secondary_list'") > 0) {
        local secondary_rels `""`=word("`secondary_list'", 1)'":relationship"'
        forvalues i = 2/`=wordcount("`secondary_list'")' {
            local secondary_rels `"`secondary_rels', "`=word("`secondary_list'", `i')'":relationship"'
        }
    }

    foreach r of varlist relationship* {
        gen isprimary_`r' = inlist(`r', `primary_rels') if (!missing(`r'))
        if (wordcount(`"`secondary_list'"') > 0) {
            gen maybeclass_`r' = inlist(`r', `primary_rels', `secondary_rels') if (!missing(`r'))
        }
        else {
            gen maybeclass_`r' = isprimary_`r'
        }
    }

    * This tells us if any relationship is in the primary class.
    egen includesprimary = rowmax(isprimary_relationship*)
    * This tells us if all non-missing relationships are in the primary class or the secondary class.
    egen allmaybeclass = rowmin(maybeclass_relationship*)
    drop isprimary_relationship* maybeclass_relationship*

    * So if all the relationships could be in the class
    * AND at least one is definitely in the primary set
    * we choose the smallest (highest precedence) relationship as the one to use.
    egen urel = rowmin(relationship*) if ((includesprimary == 1) & (allmaybeclass == 1))
    replace unified_rel = urel if ((includesprimary == 1) & (allmaybeclass == 1))
    drop urel includesprimary allmaybeclass
end

keep SSUID EPPPNUM SHHADID* adj_age* arrivers* leavers* stayers* comp_change* comp_change_reason* my_race my_sex 


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

egen rels = concat(relationship*), punct(",")
replace rels = subinstr(rels, ".,", "", .)
replace rels = subinstr(rels, ",.", "", .)

tab rels, sort

tab rels if (total_instances == rel_instances1), sort

display "Possible relationships before handling children"
egen group = group(relationship*), label missing
tab group, m sort
drop group

*** TODO:  Add a flag indicating consistent versus computed.
gen unified_rel = .
label values unified_rel relationship
unify_relationship "BIOCHILD STEPCHILD ADOPTCHILD CHILDOFPARTNER CHILD CHILD_OR_NEPHEWNIECE" "OTHER_REL OTHER_REL_P"
unify_relationship "BIOMOM STEPMOM ADOPTMOM BIODAD STEPDAD ADOPTDAD PARENT AUNTUNCLE_OR_PARENT" "OTHER_REL OTHER_REL_P"
unify_relationship "GRANDCHILD GREATGRANDCHILD GRANDCHILD_P" "OTHER_REL OTHER_REL_P"
unify_relationship "GRANDPARENT GREATGRANDPARENT GRANDPARENT_P" "OTHER_REL OTHER_REL_P"
unify_relationship "SIBLING SIBLING_OR_COUSIN" "OTHER_REL OTHER_REL_P"
unify_relationship "SPOUSE PARTNER" "OTHER_REL OTHER_REL_P"
unify_relationship "AUNTUNCLE AUNTUNCLE_OR_PARENT" "OTHER_REL OTHER_REL_P"
unify_relationship "NEPHEWNIECE CHILD_OR_NEPHEWNIECE" "OTHER_REL OTHER_REL_P"
unify_relationship "F_CHILD"
unify_relationship "F_PARENT"
unify_relationship "OTHER_REL OTHER_REL_P"
unify_relationship "NOREL DONTKNOW"

display "Possible relationships after unifying relationships"
egen group = group(relationship*) if missing(unified_rel), label missing
tab group, sort
*drop group /*group is not dropped, later use it to create flag*/

replace unified_rel = "CONFUSED":relationship if missing(unified_rel)


/** generate a flag indicating confused but ever a child **/
* find child in group
decode group, gen(group1) 
gen grandchild_confused = 0
replace grandchild_confused = 1 if strpos(group1, "GRANDCHILD")>0  /*N=510 */

gen child_confused = 0
replace child_confused = 1 if strpos(group1, "CHILD")>0 & grandchild_confused != 1 /* N=1392 */

/** generate a flag indicating confused but ever a sibling **/
*find sibling in group
gen sib_confused = 0 
replace sib_confused = 1 if strpos(group1, "SIBLING")>0 /*N=1896 */
 
	
**drop relationship* rel_instances* total_instances rels
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


*** TODO: * I see weirdness in adjusted ages, like a single 1 in the midst of large ages.  Examples:  459925246366/201, 077925358381/102.
