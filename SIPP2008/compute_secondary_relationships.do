*** TODO:  Is it more efficient to use categories?



capture program drop generate_relationship
program define generate_relationship
    args result_rel rel1 rel2
    display "Generating `result_rel' from `rel1' `rel2'"
    replace relationship = "`result_rel'" if ((relationship1 == "`rel1'") & (relationship2 == "`rel2'"))
end



/*
 * I don't think in our more careful paradigm this will be exactly what we want.

capture program drop drop_conflicts
program define drop_conflicts
    * There are some "conflicts" that aren't really conflicting.
    * We need more complicated code if we get more than two relationships to consider.
    * assert n <= 2
    * For now we'll just drop offenders and come back to this later.
    *** TODO!!!  Deal with more than two conflicts.
    drop if n > 2
    
    
    * Copy the second relationship into the first record and the first into the second 
    * so we can figure out what we want.
    by SSUID SHHADID SWAVE relfrom relto:  gen relationship_2 = relationship[_n + 1] if ((n == 2) & (_n == 1))
    by SSUID SHHADID SWAVE relfrom relto:  replace relationship_2 = relationship[_n - 1] if ((n == 2) & (_n == 2))

    * We drop the record that has the less desirable relationship.
    drop if ((n == 2) & (relationship == "CHILDOFPARTNER") & (relationship_2 == "CHILD"))
    drop if ((n == 2) & (relationship == "OTHER_REL") & (relationship_2 == "NEPHEWNIECE"))
    drop if ((n == 2) & (relationship == "SIB_OR_COUSIN") & (relationship_2 == "SIBLING"))

    * Surprising these were coded as OTHER_REL in the first place.
    drop if ((n == 2) & (relationship == "OTHER_REL") & (relationship_2 == "SIBLING"))
    drop if ((n == 2) & (relationship == "OTHER_REL") & (relationship_2 == "GRANDCHILD"))
    drop if ((n == 2) & (relationship == "OTHER_REL") & (relationship_2 == "GREATGRANDCHILD"))

    * OK?  We're elevating other relative and no relationship to child of partner.
    drop if ((n == 2) & (relationship == "OTHER_REL") & (relationship_2 == "CHILDOFPARTNER"))
    drop if ((n == 2) & (relationship == "NOREL") & (relationship_2 == "CHILDOFPARTNER"))
    drop n relationship_2
end
*/


capture program drop compute_transitive_relationships
program define compute_transitive_relationships

    args iteration
    
    local prev_iter = `iteration' - 1

    use "$tempdir/relationships_tc`prev_iter'_resolved"

    * We're going to create a dataset that has all the transitive
    * relationships we can find.  So, if we have A --> B and B --> C
    * we generate a dataset that tells us A --> B --> C by merging
    * (actually joining) on B.
    rename relfrom intermediate_person
    rename relationship relationship2
    rename reason reason2
    label variable relationship2 "rel2"
    label variable reason2 "reason2"
    tempfile relmerge
    save `relmerge'


    use "$tempdir/relationships_tc`prev_iter'_resolved"
    rename relto intermediate_person
    rename relationship relationship1
    rename reason reason1
    label variable relationship1 "rel1"
    label variable reason1 "reason1"

    * Note the use of joinby rather than m:m merge.
    * Because joinby does what you think m:m merge ought to do.
    joinby SSUID SHHADID SWAVE intermediate_person using `relmerge'

    * We don't care to keep (or validate correctness of) relationship of self to self.
    display "Dropping self-relationships"
    drop if (relfrom == relto)

    display "Tab of A -- > B and B --> C relationships, where we are trying to find A --> C, rowsort"
    tab relationship1 relationship2, rowsort
    display "Tab of A -- > B and B --> C relationships, where we are trying to find A --> C, colsort"
    tab relationship1 relationship2, colsort

    save "$tempdir/relationship_pairs_tc`iteration'_all", $replace


    * Now given the A --> B --> C relationships, what can we figure
    * out for A --> C?
    gen relationship = ""

    local all_child_types CHILD BIOCHILD STEPCHILD ADOPTCHILD
    local all_parent_types MOM BIOMOM STEPMOM ADOPTMOM DAD BIODAD STEPDAD ADOPTDAD PARENT

    foreach rel1 in `all_child_types' {
        foreach rel2 in `all_child_types' {
            generate_relationship "GRANDCHILD" "`rel1'" "`rel2'"
        }
    }

    foreach rel1 in `all_parent_types' {
        foreach rel2 in `all_parent_types' {
            generate_relationship "GRANDPARENT" "`rel1'" "`rel2'"
        }
    }

    foreach rel1 in `all_child_types' {
        generate_relationship "GREATGRANDCHILD" "`rel1'" "GRANDCHILD"
    }
    foreach rel2 in `all_child_types' {
        generate_relationship "GREATGRANDCHILD" "GRANDCHILD" "`rel2'"
    }

    foreach rel1 in `all_child_types' {
        foreach rel2 in `all_parent_types' {
            generate_relationship "SIBLING" "`rel1'" "`rel2'"
        }
    }

    foreach rel1 in `all_child_types' {
        generate_relationship "CHILD" "`rel1'" "SPOUSE"
    }

    * Should this just be CHILD?
    foreach rel1 in `all_child_types' {
        generate_relationship "CHILDOFPARTNER" "`rel1'" "PARTNER"
    }

    * Dunno if this will actually be useful, but there are 33K of them so let's try it.
    foreach rel1 in `all_child_types' {
        generate_relationship "AUNTUNCLE_OR_PARENT" "`rel1'" "GRANDPARENT"
    }

    foreach rel1 in `all_child_types' {
        generate_relationship "NEPHEWNIECE" "`rel1'" "SIBLING"
    }

    foreach rel1 in `all_child_types' {
        generate_relationship "COUSIN" "`rel1'" "AUNTUNCLE"
    }

    * Is this right?
    foreach rel1 in `all_child_types' {
        generate_relationship "NOREL" "`rel1'" "NOREL"
    }

    * OK with this?
    foreach rel2 in `all_parent_types' {
        generate_relationship "PARENT" "SPOUSE" "`rel2'"
    }

    * Should we call these PARTNERS?  Or something less certain?
    foreach rel1 in `all_parent_types' {
        foreach rel2 in `all_child_types' {
            generate_relationship "PARTNER" "`rel1'" "`rel2'"
        }
    }


    * generate_relationship "OTHER_REL"		"GRANDCHILD"		"OTHER_REL"

    *** TODO:  Validate these relationships with Kelly.  The PARTNER ones in particular.

    *** TODO:  Add the easy, but smaller, cases of MOM/DAD type other than BIO.

    *** TODO:  Handle these.  I'm removing them for a moment.
    * generate_relationship "SIB_OR_COUSIN" "GRANDCHILD" "GRANDPARENT"
    * generate_relationship "NEPHEWNIECE" "GRANDCHILD" "PARENT"


    display "How are we doing at finding relationships?"
    mdesc relationship 

    * Report relationship pairs we're not handling yet.
    preserve
    display "Keeping just missing relationships so we can show the pairs"
    keep if (missing(relationship))
    display "Relationship pairs we do not currently handle, rowsort"
    tab relationship1 relationship2, rowsort
    display "Relationship pairs we do not currently handle, colsort"
    tab relationship1 relationship2, colsort
    restore

    * Save just records for which we understand A --> C.
    display "Keeping only those for which we understand relationships"
    keep if (!missing(relationship))

    * We force the drop because we don't care about the details if the end result is the same.
    duplicates drop SSUID SHHADID SWAVE relfrom relto relationship, force


    rename relationship relationship_tc`iteration'
    gen reason_tc`iteration' = relationship1 + " " + relationship2 + " via " + string(intermediate_person)
    drop intermediate_person relationship1 relationship2 reason1 reason2
    save "$tempdir/relationships_tc`iteration'_all", $replace


    sort SSUID SHHADID SWAVE relfrom relto
    by SSUID SHHADID SWAVE relfrom relto:  gen numrels_tc`iteration' = _N
    by SSUID SHHADID SWAVE relfrom relto:  gen relnum_tc`iteration' = _n

    display "How many relationships have we generated per person-wave?"
    tab numrels_tc`iteration'

    reshape wide relationship_tc`iteration' reason_tc`iteration', i(SSUID SHHADID SWAVE relfrom relto) j(relnum_tc`iteration')

    save "$tempdir/relationships_tc`iteration'_wide", $replace


    * Merge the previous iteration at the "wide" stage, meaning we have done some fixup of 
    * conflicting relationships, but it's judged to be safe and clear.  So now we're looking
    * at all reasonable possibilities.
    * Note that we've not yet done fixup for iteration > 0, so it will probably be cluttered.

    display "Merge the previous iteration"
    *** TODO:  Careful here.  At iteration > 1 we need to get everything from 0 through prev_iter.
    * So check that that's what we've decided to store in this dataset,
    * and I fear on current course that is *not* what we'll have at tc2.
    merge 1:1 SSUID SHHADID SWAVE relfrom relto using "$tempdir/relationships_tc`prev_iter'_wide", nogenerate

    * Fix up the counts
    replace numrels_tc`iteration' = 0 if missing(numrels_tc`iteration')
    replace numrels_tc`prev_iter' = 0 if missing(numrels_tc`prev_iter')

    display "Total number of relationships at this point"
    * TODO:  May want to generate this differently and compare to the sum of TC to make sure it's all correct.
    * TODO:  This is probably wrong after TC1.  It needs to sum from TC0, probably.
    gen numrels_total = numrels_tc`iteration' + numrels_tc`prev_iter'
    tab numrels_total

    * Temporary save so we can see where we stand.
    save "$tempdir/relationships_tc0to`iteration'_wide", $replace

    *** TODO:  Comment/explain this and the following.
    tempfile allrelnames
    preserve
    clear
    set obs 1
    gen relationship = ""
    save `allrelnames'
    restore
    foreach v of varlist relationship_tc* {
        preserve
        keep `v'
        duplicates drop
        rename `v' relationship
        append using `allrelnames'
        duplicates drop
        save `allrelnames', replace
        restore
    }
    preserve
    use `allrelnames'
    display "All relationship names so far"
    list
    restore

    local dad_relations " BIODAD STEPDAD ADOPTDAD DAD F_PARENT PARENT AUNTUNCLE_OR_PARENT "
    local mom_relations " BIOMOM STEPMOM ADOPTMOM MOM F_PARENT PARENT AUNTUNCLE_OR_PARENT "
    local child_relations " BIOCHILD STEPCHILD ADOPTCHILD CHILDOFPARTNER F_CHILD CHILD "
    local spouse_relations " SPOUSE PARTNER "
    local sibling_relations " SIBLING "
    local grandparent_relations " GRANDPARENT "
    local grandchild_relations " GRANDCHILD "
    local greatgrandchild_relations " GREATGRANDCHILD "
    local nephewniece_relations " NEPHEWNIECE "

    gen relationship = ""

    *** Make the easy decision that if there is only one piece of information we will take it.
    * First compute the number of non-missing.
    gen num_nonmissing = 0
    foreach v of varlist relationship_tc* {
        replace num_nonmissing = num_nonmissing + 1 if (!missing(`v'))
    }

    * Now that we know how many are non-missing, use the ones that have just one non-missing.
    foreach v of varlist relationship_tc* {
        replace relationship = `v' if ((num_nonmissing == 1) & (!missing(`v')))
    }
    drop num_nonmissing

    display "Relationships for which there is only one candidate"
    tab relationship


    display "Now working on resolving consistent relationships"
    foreach r in dad mom child spouse sibling grandparent grandchild greatgrandchild {
        display "Looking for `r'"
        gen best_foundpos = .
        gen best_foundlen = .
        foreach v of varlist relationship_tc* {
            display "Processing `v'"
            gen foundpos = strpos("``r'_relations'", " " + `v' + " ") if (`v' != "")
            replace best_foundlen = strlen(`v') if (foundpos < best_foundpos)
            replace best_foundpos = foundpos if (foundpos < best_foundpos)
            list `v' best_foundpos best_foundlen in 1/20
            drop foundpos
        }
        replace relationship = substr("``r'_relations'", best_foundpos + 1, best_foundlen) if (missing(relationship) & (!missing(best_foundpos)) & (best_foundpos > 0))
        display "Made relationship decision"
        list relationship relationship_tc* best_foundpos best_foundlen in 1/20
        drop best_foundpos best_foundlen
    }

    display "Where to we stand with relationships?"
    tab relationship, m

    drop relationship_tc* reason_tc* numrels*
    *** TODO:  Get a real reason if I still want it.
    gen reason = ""

    save "$tempdir/relationships_tc`iteration'_resolved", $replace
end

/*
  3. |           OTHER_REL |
 10. |               NOREL |
*/

* We need an extra pass to be able to report on the pairs
* we might be able to use if we went one more pass.
local num_tc = $max_tc + 1
forvalues tc = 1/`num_tc' {
    compute_transitive_relationships `tc'
}
