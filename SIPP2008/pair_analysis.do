
forvalues tc = 0/$max_tc {
    use "$tempdir/child_pairs_long"
    drop overall_max_shhadid_members
    gen relfrom = EPPPNUM
    gen relto = real(my_pair)
    merge 1:1 SSUID relfrom relto SWAVE using "$tempdir/relationships_tc`tc'"
    drop if (_merge == 2)
    tab _merge
    drop _merge
    drop relfrom my_pair

    sort SWAVE
    by SWAVE:  tab relationship, m

    * This generates numerical categories and tells you how many there are.
    * But I've decided I don't want that.  I think.
    * egen rel_cat = group(relationship), label lname(rel_lbl)
    * tempvar max_rel_cat
    * egen `max_cat' = max(rel_cat)
    * label max_rel_cat `=`max_cat''

    save "$tempdir/child_pair_rels_long_tc`tc'", $replace

    reshape wide SHHADID adj_age relationship relationship_source, i(SSUID EPPPNUM relto) j(SWAVE)
    save "$tempdir/child_pair_rels_wide_tc`tc'", $replace


    use "$tempdir/child_pair_rels_long_tc`tc'"

    levelsof relationship, local(rel_labels)

    gen num_relationships = 1
    gen num_rel_missing = missing(relationship)
    gen num_rel_nonmissing = 1 - num_rel_missing
    local collapse_list "num_relationships num_rel_missing num_rel_nonmissing"
    local num_rel_list "num_rel_missing"
    local num_rel_nomiss_list ""
    foreach r of local rel_labels {
        gen num_`r' = (relationship == "`r'")
        local collapse_list "`collapse_list' num_`r'"
        local num_rel_list "`num_rel_list' num_`r'"
        local num_rel_nomiss_list "`num_rel_nomiss_list' num_`r'"
    }

    collapse (sum) `collapse_list', by(SSUID EPPPNUM relto)

    egen max_num_rel = rowmax(`num_rel_list')
    gen unique_rel = (max_num_rel == num_relationships)
    tab unique_rel

    egen max_num_nomiss_rel = rowmax(`num_rel_nomiss_list')
    gen unique_nomiss_rel = (max_num_nomiss_rel == num_rel_nonmissing) if (num_rel_nonmissing > 0)
    tab unique_nomiss_rel

    gen all_rels = ""
    foreach r of local rel_labels {
        replace all_rels = all_rels + " " + "`r'" if (num_`r' > 0)
    }
    replace all_rels = all_rels + " "

    tab all_rels
    tab all_rels if (wordcount(all_rels) > 1)
    tab all_rels if (num_rel_missing > 0)
    tab all_rels if ((wordcount(all_rels) > 1) & (num_rel_missing > 0))
    tab num_relationships if (wordcount(all_rels) == 0)

    save "$tempdir/child_pair_rels_unified_tc`tc'", $replace
}
