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

    rename adj_age from_age

    drop EPPPNUM
    gen EPPPNUM = relto
    merge m:1 SSUID EPPPNUM SWAVE using "$tempdir/adjusted_ages_long", keepusing(adj_age)
    drop if (_merge == 2)
    assert (_merge == 3)
    drop _merge
    drop EPPPNUM
    rename adj_age to_age


    # Unacceptable replication of code.  Make it a program that can be called in multiple places?
    gen simplified_rel = .
    label values simplified_rel relationship
    replace simplified_rel = "CHILD":relationship if inlist(unified_rel, "BIOCHILD":relationship, "STEPCHILD":relationship, "ADOPTCHILD":relationship, "CHILDOFPARTNER":relationship, "CHILD":relationship)
    replace simplified_rel = "PARENT":relationship if inlist(unified_rel, "BIOMOM":relationship, "STEPMOM":relationship, "ADOPTMOM":relationship, "BIODAD":relationship, "STEPDAD":relationship, "ADOPTDAD":relationship, "PARENT":relationship)
    replace simplified_rel = "GRANDCHILD":relationship if inlist(unified_rel, "GRANDCHILD":relationship, "GREATGRANDCHILD":relationship)
    replace simplified_rel = "GRANDPARENT":relationship if inlist(unified_rel, "GRANDPARENT":relationship, "GREATGRANDPARENT":relationship)
    replace simplified_rel = "SIBLING":relationship if inlist(unified_rel, "SIBLING":relationship)
    replace simplified_rel = "OTHER_REL":relationship if inlist(unified_rel, "OTHER_REL":relationship, "SPOUSE":relationship, "AUNTUNCLE_OR_PARENT":relationship, "AUNTUNCLE":relationship, "NEPHEWNIECE":relationship, "SIBLING_OR_COUSIN":relationship, "CHILD_OR_NEPHEWNIECE":relationship)
    replace simplified_rel = "NOREL":relationship if inlist(unified_rel, "NOREL":relationship, "PARTNER":relationship, "F_CHILD":relationship)

    replace simplified_rel = "F_PARENT":relationship if inlist(unified_rel, "F_PARENT":relationship)

    replace simplified_rel = "GRANDCHILD_P":relationship if inlist(unified_rel, "GRANDCHILD_P":relationship)
    replace simplified_rel = "GRANDPARENT_P":relationship if inlist(unified_rel, "GRANDPARENT_P":relationship)
    replace simplified_rel = "OTHER_REL_P":relationship if inlist(unified_rel, "OTHER_REL_P":relationship)

    replace simplified_rel = "DONTKNOW":relationship if inlist(unified_rel, "DONTKNOW":relationship)

    replace simplified_rel = "CONFUSED":relationship if inlist(unified_rel, "CONFUSED":relationship, .a, .m)



    # Unacceptable replication of code.  Make it a program that can be called in multiple places?
    local lnum = 1
    foreach r in CHILD SIBLING GRANDCHILD OTHER_ADULT OTHER_CHILD {
        local llist = `"`llist' `lnum' "`r'""'
        local lnum = `lnum' + 1
    }
    label define ultra_simple_rel `llist'

    gen ultra_simple_rel = .
    label values ultra_simple_rel ultra_simple_rel
    * TODO:  automate choosing the right label to dereference.
    replace ultra_simple_rel = "CHILD":ultra_simple_rel if (simplified_rel == "CHILD":relationship)
    replace ultra_simple_rel = "SIBLING":ultra_simple_rel if (simplified_rel == "SIBLING":relationship)
    replace ultra_simple_rel = "GRANDCHILD":ultra_simple_rel if (simplified_rel == "GRANDCHILD":relationship)
    replace ultra_simple_rel = "OTHER_CHILD":ultra_simple_rel if (missing(ultra_simple_rel) & (to_age < $adult_age))
    replace ultra_simple_rel = "OTHER_ADULT":ultra_simple_rel if (missing(ultra_simple_rel))



    tab simplified_rel if (from_age < $adult_age)
    tab ultra_simple_rel if (from_age < $adult_age)

    tab simplified_rel my_race if (from_age < $adult_age)
    tab ultra_simple_rel my_race if (from_age < $adult_age)

    tab simplified_rel my_race if (from_age < $adult_age), col
    tab ultra_simple_rel my_race if (from_age < $adult_age), col

    save "$tempdir/simpler_`changer'_rels", $replace
}
