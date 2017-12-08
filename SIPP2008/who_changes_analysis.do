* Look at ages of people who come, go, and stay.
capture program drop examine_change_ages
program define examine_change_ages
    args person_type

    * Build a dataset to merge in the age of the leaver/stayer/arriver.
    use "$tempdir/adjusted_ages_long"
    rename EPPPNUM `person_type'_epppnum
    rename adj_age `person_type'_age
    tempfile `person_type'_merge_age
    save ``person_type'_merge_age'

    * Let's just look at children.
    use "$tempdir/`person_type's_long"
    keep if (adj_age < $adult_age)

    * Restricting to `person_type'_num == 1 means we use just a single
    * report from each group of `person_type's, which is what we want.
    tab n_`person_type's if (`person_type'_num == 1)
    tab adj_age n_`person_type's if (`person_type'_num == 1)
    tab adj_age n_`person_type's if (`person_type'_num == 1), row
    tab SWAVE n_`person_type's if (`person_type'_num == 1)
    tab SWAVE n_`person_type's if (`person_type'_num == 1), row


    merge m:1 SSUID SWAVE `person_type'_epppnum using ``person_type'_merge_age'
    assert _merge != 1
    keep if _merge == 3
    drop _merge

    tab `person_type'_age

    collapse (min) min_`person_type'_age=`person_type'_age  (max) max_`person_type'_age=`person_type'_age  (mean) mean_`person_type'_age=`person_type'_age  (median) median_`person_type'_age=`person_type'_age, by(SSUID EPPPNUM SWAVE adj_age)
    replace mean_`person_type'_age = round(mean_`person_type'_age)
    replace median_`person_type'_age = round(median_`person_type'_age)

    tab min_`person_type'_age
    tab max_`person_type'_age
    tab mean_`person_type'_age
    tab median_`person_type'_age
    
    tab min_`person_type'_age adj_age
    tab max_`person_type'_age adj_age
    tab mean_`person_type'_age adj_age
    tab median_`person_type'_age adj_age

    tab min_`person_type'_age SWAVE
    tab max_`person_type'_age SWAVE
    tab mean_`person_type'_age SWAVE
    tab median_`person_type'_age SWAVE
    
    * Maybe ought to save this to be poked at.
    clear
end


capture program drop report_relationships
program define report_relationships
    args person_type iteration
    
    local next_iter = `iteration' + 1
    
    * Let's just look at children.
    use "$tempdir/`person_type's_long"
    keep if (adj_age < $adult_age)

    * Bring in the relationships.
    gen relfrom = EPPPNUM
    gen relto = `person_type'_epppnum
    drop if relfrom == relto
    merge m:1 SSUID SWAVE relfrom relto using "$tempdir/relationships_tc`iteration'"
    drop if _merge == 2
    drop _merge

    display "Tabs for `person_type's at iteration `iteration'"
    tab relationship
    tab relationship, m
    tab relationship adj_age
    tab relationship adj_age, m
    tab relationship SWAVE
    tab relationship SWAVE, m

    display "Tabs for solo `person_type's at iteration `iteration'"
    tab relationship if (n_`person_type's == 1)
    tab relationship if (n_`person_type's == 1), m
    tab relationship adj_age if (n_`person_type's == 1)
    tab relationship adj_age if (n_`person_type's == 1), m
    tab relationship SWAVE if (n_`person_type's == 1)
    tab relationship SWAVE if (n_`person_type's == 1), m

    save "$tempdir/`person_type'_relationships_tc`iteration'", $replace

    * Now let's find out what we know from the next step of transitive closure
    * about relationships we don't get from this step.
    keep if missing(relationship)

    keep SSUID SWAVE relfrom relto
    duplicates drop
    merge 1:m SSUID SWAVE relfrom relto using "$tempdir/relationship_pairs_tc`next_iter'"
    keep if _merge == 3
    drop _merge

    display "Tabs of `person_type's relationship pairs available at next iteration `next_iter' for relationships missing in iteration `iteration'"
    tab relationship1 relationship2

    save "$tempdir/`person_type'_missing_rel_tc`iteration'", $replace
end

examine_change_ages leaver
examine_change_ages stayer
examine_change_ages arriver

forvalues tc = 1/$max_tc {
    report_relationships leaver `tc'
    report_relationships stayer `tc'
    report_relationships arriver `tc'
}

* save "$tempdir/who_changes_analysis", $replace
