//==============================================================================
//===== Children's Household Instability Project
//===== Dataset: SIPP2008
//===== Purpose:  Create a single relationship for each pair of people appearing 
//===== at the same address together so that it is consistent across waves.
//===== This requires some relationships (i.e. partner/spouse/other) to lose
//===== some information.
//==============================================================================

capture program drop unify_relationship
program define unify_relationship
    args primary_list secondary_list
    * primary_list is the list of relationships to be considered definitively compatible.
    * secondary_list is the list of additional relationships that may be compatible with the primary_list,
    * but if only erlationships from the secondary_list are present we cannot conclude this relationship is of the class.
    * E.g., OTHER_REL won't prevent us from declaring someone a child, but we cannot declare them a child if OTHER_REL is the only information we have.
	
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

capture program drop flag_relationship
program define flag_relationship
    * flagvar is the flag variable to create.
    * rel_list is the list of relationships to be searched for.
    * We set flagvar = 1 if we ever see any of the relationships in rel_list and to 0 otherwise.
    args flagvar rel_list

    if (wordcount("`rel_list'") == 0) {
        display as error "flag_relationship:  argument rel_list must be non-blank"
        error 111
    }

    local flag_rels `""`=word("`rel_list'", 1)'":relationship"'
    forvalues i = 2/`=wordcount("`rel_list'")' {
        local flag_rels `"`flag_rels', "`=word("`rel_list'", `i')'":relationship"'
    }

    gen `flagvar' = 0
    foreach r of varlist relationship* {
        replace `flagvar' = 1 if ((!missing(`r')) & inlist(`r', `flag_rels'))
    }
end

use "$tempdir/relationship_pairs_bywave"

keep SSUID relfrom relto relationship

tab relationship, m

drop if missing(relationship)

* identify number of different types of relationships a pair is identified as having
sort SSUID relfrom relto relationship
by SSUID relfrom relto:  gen total_instances = _N
by SSUID relfrom relto relationship:  gen rel_instances = _N
by SSUID relfrom relto relationship:  gen first_rel_instance = (_n == 1)
keep if (first_rel_instance == 1)

* take only one observation to represent this type of relationship
* For example, if this pair is observe as siblings 5 times, we only take
* one observation
drop first_rel_instance

* Wide file has each observed relationship type for pair 
by SSUID relfrom relto:  gen relnum = _n
reshape wide relationship rel_instances, i(SSUID relfrom relto) j(relnum)

* how often is there only one relationship type observed (over 90%)
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

* If coded as OTHER_REL and CHILD, set relationship as child
unify_relationship "BIOCHILD STEPCHILD ADOPTCHILD CHILDOFPARTNER CHILD CHILD_OR_NEPHEWNIECE" "OTHER_REL OTHER_REL_P DONTKNOW"
*etc
unify_relationship "BIOMOM STEPMOM ADOPTMOM BIODAD STEPDAD ADOPTDAD PARENT AUNTUNCLE_OR_PARENT" "OTHER_REL OTHER_REL_P DONTKNOW"
unify_relationship "GRANDCHILD GREATGRANDCHILD GRANDCHILD_P" "OTHER_REL OTHER_REL_P DONTKNOW"
unify_relationship "GRANDPARENT GREATGRANDPARENT GRANDPARENT_P" "OTHER_REL OTHER_REL_P DONTKNOW"
unify_relationship "SIBLING SIBLING_OR_COUSIN" "OTHER_REL OTHER_REL_P DONTKNOW"
unify_relationship "SPOUSE PARTNER" "OTHER_REL OTHER_REL_P NOREL DONTKNOW"
unify_relationship "AUNTUNCLE AUNTUNCLE_OR_PARENT" "OTHER_REL OTHER_REL_P DONTKNOW"
unify_relationship "NEPHEWNIECE CHILD_OR_NEPHEWNIECE" "OTHER_REL OTHER_REL_P DONTKNOW"
unify_relationship "F_CHILD DONTKNOW"
unify_relationship "F_PARENT DONTKNOW"
unify_relationship "F_SIB DONTKNOW"
unify_relationship "SIBLING" "F_SIB NOREL DONTKNOW"
unify_relationship "OTHER_REL OTHER_REL_P" "DONTKNOW"
unify_relationship "NOREL DONTKNOW"

display "Possible relationships after unifying relationships"
egen group = group(relationship*) if missing(unified_rel), label missing
tab group, sort
*drop group /*group is not dropped, later use it to create flag*/

replace unified_rel = "CONFUSED":relationship if missing(unified_rel)


/**** Creating flags indicating child/sibling ****/ 
gen childflag = 0
gen sibflag = 0
  foreach flag of varlist relationship* {
        replace childflag = 1 if inlist(`flag', "BIOCHILD":relationship, "STEPCHILD":relationship, "ADOPTCHILD":relationship, "CHILDOFPARTNER":relationship, "CHILD":relationship, ///
		"CHILD_OR_NEPHEWNIECE":relationship) & (!missing(group))
        replace sibflag = 1 if inlist(`flag', "SIBLING":relationship, "SIBLING_OR_COUSIN":relationship) & (!missing(group))
    }


gen rel_is_confused = (unified_rel == "CONFUSED":relationship)
flag_relationship rel_is_ever_child "BIOCHILD STEPCHILD ADOPTCHILD CHILDOFPARTNER CHILD CHILD_OR_NEPHEWNIECE"
flag_relationship rel_is_ever_sibling "SIBLING SIBLING_OR_COUSIN"
flag_relationship rel_is_ever_parent "BIOMOM STEPMOM ADOPTMOM BIODAD STEPDAD ADOPTDAD PARENT AUNTUNCLE_OR_PARENT"

tab rel_is_ever_child childflag if (rel_is_confused)
tab rel_is_ever_child childflag

tab rel_is_ever_sibling sibflag if (rel_is_confused)
tab rel_is_ever_sibling sibflag
        
/*childflag N=2385; sibflag N=1,586 */
 
drop group /*group can be dropped now */
 
**drop relationship* rel_instances* total_instances rels
save "$tempdir/unified_rel", $replace
