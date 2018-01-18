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
    generate_relationship "GRANDCHILD"		"CHILD"			"CHILD"
    generate_relationship "GRANDCHILD"		"BIOCHILD"		"BIOCHILD"
    generate_relationship "GRANDCHILD"		"BIOCHILD"		"CHILD"

    generate_relationship "GRANDPARENT"		"BIOMOM"		"BIOMOM"
    generate_relationship "GRANDPARENT"		"BIOMOM"		"BIODAD"
    generate_relationship "GRANDPARENT"		"BIODAD"		"BIOMOM"
    generate_relationship "GRANDPARENT"		"BIODAD"		"BIODAD"

    generate_relationship "GREATGRANDCHILD"	"CHILD"			"GRANDCHILD"
    generate_relationship "GREATGRANDCHILD"	"GRANDCHILD"		"CHILD"

    generate_relationship "SIBLING"		"CHILD"			"PARENT"
    generate_relationship "SIBLING"		"BIOCHILD"		"BIOMOM"
    generate_relationship "SIBLING"		"BIOCHILD"		"BIODAD"

    generate_relationship "PARENT"		"SPOUSE"		"BIOMOM"
    generate_relationship "PARENT"		"SPOUSE"		"BIODAD"

    generate_relationship "PARTNER"		"BIODAD"		"BIOCHILD"
    generate_relationship "PARTNER"		"BIOMOM"		"BIOCHILD"

    generate_relationship "CHILDOFPARTNER"	"CHILD"			"PARTNER"

    generate_relationship "NEPHEWNIECE"		"CHILD"			"SIBLING"

    generate_relationship "CHILD"		"CHILD"			"SPOUSE"

    generate_relationship "COUSIN"		"CHILD"			"AUNTUNCLE"

    generate_relationship "OTHER_REL"		"CHILD"			"OTHER_REL"
    generate_relationship "OTHER_REL"		"GRANDCHILD"		"OTHER_REL"

    *** TODO:  Validate these relationships with Kelly.  The PARTNER ones in particular.

    *** TODO:  Add the easy, but smaller, cases of MOM/DAD type other than BIO.

    *** TODO:  Handle these.  I'm removing them for a moment.
    * generate_relationship "SIB_OR_COUSIN" "GRANDCHILD" "GRANDPARENT"
    * generate_relationship "NEPHEWNIECE" "GRANDCHILD" "PARENT"

    *** TODO:  Fix this.
    * This is too general.  I could be the partner of the bio parent.  See 019925587235 wave 15, 1201 to 1203:  
    * sibling via 1201, sibling or cousin via 101, cousin via 902 because 902 is judged aunt-uncle by virtue of 
    * child --> grandparent.
    * replace relationship = "AUNTUNCLE" if ((relationship1 == "CHILD") & (relationship2 == "GRANDPARENT"))


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

    *** TODO:  Probably need some fixups here, or maybe after merge.
    save "$tempdir/relationships_tc`iteration'_wide", $replace


    * Merge the previous iteration at the "wide" stage, meaning we have done some fixup of 
    * conflicting relationships, but it's judged to be safe and clear.  So now we're looking
    * at all reasonable possibilities.
    * Note that we've not yet done fixup for iteration > 0, so it will probably be cluttered.

    display "Merge the previous iteration"
    *** TODO:  Careful here.  At iteration > 1 we need to get everything from 0 through prev_iter.
    * So check that that's what we've decided to store in this dataset,
    * and I fear on current course that is *not* what we';; have at tc2.
    merge 1:1 SSUID SHHADID SWAVE relfrom relto using "$tempdir/relationships_tc`prev_iter'_wide"

    sort SSUID SHHADID SWAVE relfrom relto
    by SSUID SHHADID SWAVE relfrom relto:  gen numrels_total = _N
    display "Total number of relationships at this point"
    tab numrels_total
    display "Mismatch betweeh this and expected total?"
    count if (numrels_total != numrels_tc`iteration' + numrels_tc`prev_iter')
    * Temporary save so we can see where we stand.
    save "$tempdir/relationships_tc`iteration'_wide_working", $replace

    *** Finish this off, meaning, choose a relationship and merge with the earlier choice
    * OR don't choose yet, merge, and then decide!
    /*
    sort SSUID SHHADID SWAVE relfrom relto
    by SSUID SHHADID SWAVE relfrom relto:  gen n = _N

    * List anomalies in case we want to try to understand and recover them.
    * "Anomaly" means we generated two different relationships for the same pair of people.
    * TODO:  Review these!
    display "Anomalies in transitive relationships at iteration `iteration', before corrections"
    count if (n > 1)
    tab n

    drop_conflicts

    display "Anomalies in transitive relationships at iteration `iteration', after corrections"
    sort SSUID SHHADID SWAVE relfrom relto
    by SSUID SHHADID SWAVE relfrom relto:  gen n = _N
    count if (n > 1)
    tab n
    list if (n > 1)
    * And then get rid of them, for now.
    drop if (n > 1)

    drop n
    drop intermediate_person relationship1 relationship2 relsource1 relsource2
    gen relationship_source = `iteration'
    save "$tempdir/relationships_from_tc`iteration'", $replace


    *** Append the new relationships to the old ones.
    * Also, keep track of where we discovered the relationships.
    use "$tempdir/relationships_tc`prev_iter'"
    append using "$tempdir/relationships_from_tc`iteration'"

    * The only duplicates should be due to finding the same relationship in 
    * this iteration as we had before.
    duplicates drop SSUID SHHADID SWAVE relfrom relto relationship, force

    * See if we have generated conflicting relationships by adding in the new iteration.
    sort SSUID SHHADID SWAVE relfrom relto
    by SSUID SHHADID SWAVE relfrom relto:  gen n = _N

    * How many anomalies?
    display "Number of anomalies after appending iteration `iteration', before corrections"
    count if (n > 1)
    tab n

    drop_conflicts

    * List anomalies in case we want to try to understand and recover them.
    * TODO:  Review these.
    by SSUID SHHADID SWAVE relfrom relto:  gen n = _N
    display "Anomalies after appending iteration `iteration'"
    count if (n > 1)
    tab n
    list if (n > 1)

    * For now, we'll prefer the original relationship in case of conflicts.
    drop if ((n > 1) & (relationship_source == `iteration'))

    drop n

    */
end

* We need an extra pass to be able to report on the pairs
* we might be able to use if we went one more pass.
local num_tc = $max_tc + 1
forvalues tc = 1/`num_tc' {
    compute_transitive_relationships `tc'
}
