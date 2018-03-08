use "$tempdir/person_wide_adjusted_ages"

keep SSUID EPPPNUM shhadid_members* max_shhadid_members*

gen potential_rels = " "
forvalues wave = $first_wave/$final_wave {
    forvalues my_hh_member_num = 1/`=max_shhadid_members`wave'' {
        gen my_hh_member = word(shhadid_members`wave', `my_hh_member_num')
        replace my_hh_member = "X" if missing(my_hh_member)
        replace potential_rels = potential_rels + my_hh_member + " " if ((my_hh_member != "X") & (my_hh_member != string(EPPPNUM)) & (strpos(potential_rels, " " + my_hh_member + " ") == 0))
        drop my_hh_member
    }
}

gen num_potential_rels = wordcount(potential_rels)

summ num_potential_rels

save "$tempdir/potential_rels", $replace




use "$tempdir/person_wide_adjusted_ages"

keep SSUID EPPPNUM shhadid_members* max_shhadid_members* adj_age*

gen potential_rels = " "
forvalues wave = $first_wave/$final_wave {
    forvalues my_hh_member_num = 1/`=max_shhadid_members`wave'' {
        gen my_hh_member = word(shhadid_members`wave', `my_hh_member_num')
        replace my_hh_member = "X" if missing(my_hh_member)
        replace potential_rels = potential_rels + my_hh_member + " " if ((my_hh_member != "X") & (my_hh_member != string(EPPPNUM)) & (strpos(potential_rels, " " + my_hh_member + " ") == 0) & (adj_age`wave' < $adult_age))
        drop my_hh_member
    }
}

gen num_potential_rels = wordcount(potential_rels)

summ num_potential_rels

save "$tempdir/child_potential_rels", $replace




