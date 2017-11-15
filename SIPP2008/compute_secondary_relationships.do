*** TODO:  Is it more efficient to use categories?


capture program drop compute_transitive_relationships
program define compute_transitive_relationships

    args iteration
    
    local prev_iter = `iteration' - 1

    use "$tempdir/relationships_tc`prev_iter'"

    * We're going to create a dataset that has all the transitive
    * relationships we can find.  So, if we have A --> B and B --> C
    * we generate a dataset that tells us A --> B --> C by merging
    * (actually joining) on B.
    rename relfrom relative2
    rename relationship relationship2
    rename relationship_source relsource2
    tempfile relmerge
    save `relmerge'


    use "$tempdir/relationships_tc`prev_iter'"
    rename relto relative2
    rename relationship relationship1
    rename relationship_source relsource1

    * Note the use of joinby rather than m:m merge.
    * Because joinby does what you think m:m merge ought to do.
    joinby SSUID SHHADID SWAVE relative2 using `relmerge'

    * We don't care to keep (or validate correctness of) relationship of self to self.
    drop if (relfrom == relto)

    tab relationship1 relationship2

    save "$tempdir/relationship_pairs_tc`iteration'", $replace


    * Now given the A --> B --> C relationships, what can we figure
    * out for A --> C?
    gen relationship = ""
    replace relationship = "GRANDCHILD" if ((relationship1 == "CHILD") & (relationship2 == "CHILD"))
    replace relationship = "GREATGRANDCHILD" if ((relationship1 == "CHILD") & (relationship2 == "GRANDCHILD"))
    replace relationship = "GREATGRANDCHILD" if ((relationship1 == "GRANDCHILD") & (relationship2 == "CHILD"))
    replace relationship = "SIBLING" if ((relationship1 == "CHILD") & (relationship2 == "PARENT"))
    replace relationship = "CHILDOFPARTNER" if ((relationship1 == "CHILD") & (relationship2 == "PARTNER"))
    replace relationship = "NEPHEWNIECE" if ((relationship1 == "CHILD") & (relationship2 == "SIBLING"))
    replace relationship = "CHILD" if ((relationship1 == "CHILD") & (relationship2 == "SPOUSE"))

    * Save just records for which we understand A --> C.
    keep if (!missing(relationship))

    * We force the drop because we don't care about the details if the end result is the same.
    duplicates drop SSUID SHHADID SWAVE relfrom relto relationship, force

    sort SSUID SHHADID SWAVE relfrom relto
    by SSUID SHHADID SWAVE relfrom relto:  gen n = _N

    * List anomalies in case we want to try to understand and recover them.
    * "Anomaly" means we generated two different relationships for the same pair of people.
    * TODO:  Review these!
    display "Anomalies in transitive relationships at iteration `iteration'"
    list if (n > 1)

    * And then get rid of them, for now.
    drop if (n > 1)

    drop n
    drop relative2 relationship1 relationship2 relsource1 relsource2
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

    * There are some "conflicts" that aren't really conflicting.
    * We need more complicated code if we get more than two relationships to consider.
    assert n <= 2
    
    
    * Copy the second relationship into the first record and the first into the second 
    * so we can figure out what we want.
    by SSUID SHHADID SWAVE relfrom relto:  gen relationship_2 = relationship[_n + 1] if ((n == 2) & (_n == 1))
    by SSUID SHHADID SWAVE relfrom relto:  replace relationship_2 = relationship[_n - 1] if ((n == 2) & (_n == 2))

    * We drop the record that has the less desirable relationship.
    drop if ((n == 2) & (relationship == "CHILDOFPARTNER") & (relationship_2 == "CHILD"))
    drop if ((n == 2) & (relationship == "OTHER_REL") & (relationship_2 == "NEPHEWNIECE"))

    * Surprising these were coded as OTHER_REL in the first place.
    drop if ((n == 2) & (relationship == "OTHER_REL") & (relationship_2 == "SIBLING"))
    drop if ((n == 2) & (relationship == "OTHER_REL") & (relationship_2 == "GRANDCHILD"))
    drop if ((n == 2) & (relationship == "OTHER_REL") & (relationship_2 == "GREATGRANDCHILD"))

    * OK?  We're elevating other relative and no relationship to child of partner.
    drop if ((n == 2) & (relationship == "OTHER_REL") & (relationship_2 == "CHILDOFPARTNER"))
    drop if ((n == 2) & (relationship == "NOREL") & (relationship_2 == "CHILDOFPARTNER"))
    drop n relationship_2

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

    save "$tempdir/relationships_tc`iteration'", $replace
end

* We need an extra pass to be able to report on the pairs
* we might be able to use if we went one more pass.
local num_tc = $max_tc + 1
forvalues tc = 1/`num_tc' {
    compute_transitive_relationships `tc'
}
