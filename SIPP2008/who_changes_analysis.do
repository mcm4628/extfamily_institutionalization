use "$tempdir/person_wide_adjusted_ages"
keep SSUID EPPPNUM adj_age*
reshape long adj_age, i(SSUID EPPPNUM) j(SWAVE)
tempfile age
save "$tempdir/adjusted_ages_long", $replace




capture program drop report_relationships
program define report_relationships
    args person_type

    use "$tempdir/adjusted_ages_long"
    rename EPPPNUM `person_type'_epppnum
    rename adj_age `person_type'_age
    tempfile `person_type'_merge_age
    save ``person_type'_merge_age'


    use "$tempdir/`person_type's_long"

    keep if (adj_age < $adult_age)

    preserve

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


    restore

    gen relfrom = EPPPNUM
    gen relto = `person_type'_epppnum
    merge m:1 SSUID SWAVE relfrom relto using "$tempdir/base_relationships"
    drop if _merge == 2
    drop _merge

    tab relationship
    tab relationship, m
    tab relationship adj_age
    tab relationship adj_age, m
    tab relationship SWAVE
    tab relationship SWAVE, m

    tab relationship if (n_`person_type's == 1)
    tab relationship if (n_`person_type's == 1), m
    tab relationship adj_age if (n_`person_type's == 1)
    tab relationship adj_age if (n_`person_type's == 1), m
    tab relationship SWAVE if (n_`person_type's == 1)
    tab relationship SWAVE if (n_`person_type's == 1), m


    * Now let's find out what we know from transitive closure about relationships we don't get from primary data.
    keep if missing(relationship)

    keep SSUID SWAVE relfrom relto
    duplicates drop
    merge 1:m SSUID SWAVE relfrom relto using "$tempdir/relationship_pairs_tc1"
    keep if _merge == 3
    drop _merge

    tab relationship1 relationship2

    save "$tempdir/`person_type'_missing_rel", $replace



    *** Now try using all the relationships we know.
    use "$tempdir/`person_type's_long"
    keep if (adj_age < $adult_age)
    gen relfrom = EPPPNUM
    gen relto = `person_type'_epppnum
    merge m:1 SSUID SWAVE relfrom relto using "$tempdir/relationships"
    drop if _merge == 2
    drop _merge

    tab relationship
    tab relationship, m
    tab relationship adj_age
    tab relationship adj_age, m
    tab relationship SWAVE
    tab relationship SWAVE, m

    tab relationship if (n_`person_type's == 1)
    tab relationship if (n_`person_type's == 1), m
    tab relationship adj_age if (n_`person_type's == 1)
    tab relationship adj_age if (n_`person_type's == 1), m
    tab relationship SWAVE if (n_`person_type's == 1)
    tab relationship SWAVE if (n_`person_type's == 1), m

    save "$tempdir/`person_type'_relationships", $replace
end

report_relationships leaver
report_relationships stayer
report_relationships arriver
* save "$tempdir/who_changes_analysis", $replace
