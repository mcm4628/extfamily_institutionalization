use "$tempdir/person_wide_adjusted_ages"

keep SSUID EPPPNUM SHHADID* shhadid_members* max_shhadid_members* adj_age* my_race my_sex

forvalues wave = $first_wave/$penultimate_wave {
    forvalues my_hh_member_num = 1/`=max_shhadid_members`wave'' {
        gen my_pair_`my_hh_member_num'_`wave' = word(shhadid_members`wave', `my_hh_member_num')
    }
}

* TODO:  Probably ought to remove pairing with myself.  I take care of it in the long form, but not the wide.
save "$tempdir/pairs_wide", $replace



egen my_max_shhadid_members = rowmax(max_shhadid_members*)
egen overall_max_shhadid_members = max(my_max_shhadid_members)
drop my_max_shhadid_members

display "MAX SHHADID MEMBERS = `=overall_max_shhadid_members'"

local pair_vars ""
forvalues my_hh_member_num = 1/`=overall_max_shhadid_members' {
    local pair_vars "`pair_vars' my_pair_`my_hh_member_num'_"
}

display "PAIR VARS:  `pair_vars'"

drop shhadid_members* max_shhadid_members*

reshape long SHHADID adj_age `pair_vars', i(SSUID EPPPNUM) j(SWAVE)

forvalues my_hh_member_num = 1/`=overall_max_shhadid_members' {
    rename my_pair_`my_hh_member_num'_ my_pair_`my_hh_member_num'
}


reshape long my_pair_, i(SSUID EPPPNUM SWAVE) j(memnum)
drop memnum
rename my_pair_ my_pair
drop if missing(my_pair)
drop if (real(my_pair) == EPPPNUM)

save "$tempdir/pairs_long", $replace


drop if adj_age >= $adult_age

save "$tempdir/child_pairs_long", $replace
