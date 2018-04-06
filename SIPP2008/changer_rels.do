*** This code is hot off the press and ended up being more of a hack than I expected.
* Use results with caution (for a few days).


foreach changer in leaver arriver stayer leaver_and_arriver {
    display "Processing `changer's"

    if ("`changer'" == "leaver_and_arriver") {
        use "$tempdir/leaver_rels"
        append using "$tempdir/arriver_rels"
    }
    else {
        use "$tempdir/`changer'_rels"
    }

    do "$sipp2008_code/simple_rel_label"

    rename adj_age from_age

    drop EPPPNUM
    gen EPPPNUM = relto
    merge m:1 SSUID EPPPNUM SWAVE using "$tempdir/adjusted_ages_long", keepusing(adj_age)
    drop if (_merge == 2)
    assert (_merge == 3)
    drop _merge
    drop EPPPNUM
    rename adj_age to_age


    simplify_relationships unified_rel simplified_rel ultra_simple_rel


    tab simplified_rel if (from_age < $adult_age)
    tab ultra_simple_rel if (from_age < $adult_age)

    tab simplified_rel my_race if (from_age < $adult_age)
    tab ultra_simple_rel my_race if (from_age < $adult_age)

    tab simplified_rel my_race if (from_age < $adult_age), col
    tab ultra_simple_rel my_race if (from_age < $adult_age), col

    save "$tempdir/simpler_`changer'_rels", $replace
}
