use "$tempdir/person_wide_adjusted_ages"

keep SSUID EPPPNUM SHHADID* shhadid_members* max_shhadid_members* adj_age* my_race my_sex

forvalues wave = $first_wave/$penultimate_wave {
    local next_wave = `wave' + 1


    *** Start by assuming this wave is not interesting.
    gen addr_change`wave' = .
    gen comp_change`wave' = .


    *** If we have data in both waves, just compare HH members.
    replace addr_change`wave' = (SHHADID`wave' != SHHADID`next_wave') if ((!missing(SHHADID`wave')) & (!missing(SHHADID`next_wave')))
    replace comp_change`wave' = (shhadid_members`wave' != shhadid_members`next_wave') if ((!missing(SHHADID`wave')) & (!missing(SHHADID`next_wave')))
    gen comp_change_case = ((shhadid_members`wave' != shhadid_members`next_wave') & (!missing(SHHADID`wave')) & (!missing(SHHADID`next_wave')))

    gen leavers`wave' = ""
    gen stayers`wave' = ""
    gen arrivers`wave' = ""

    forvalues my_hh_member_num = 1/`=max_shhadid_members`wave'' {
        gen my_hh_member = word(shhadid_members`wave', `my_hh_member_num') if (comp_change_case == 1)

        replace leavers`wave' = leavers`wave' + " " + my_hh_member if ((comp_change_case == 1) & (!missing(my_hh_member)) & (strpos(shhadid_members`next_wave', " " + my_hh_member + " ") == 0))
        replace stayers`wave' = stayers`wave' + " " + my_hh_member if ((comp_change_case == 1) & (!missing(my_hh_member)) & (strpos(shhadid_members`next_wave', " " + my_hh_member + " ") != 0))

        drop my_hh_member
    }

    forvalues my_hh_member_num = 1/`=max_shhadid_members`next_wave'' {
        gen my_hh_member = word(shhadid_members`next_wave', `my_hh_member_num') if (comp_change_case == 1)

        replace arrivers`wave' = arrivers`wave' + " " + my_hh_member if ((comp_change_case == 1) & (!missing(my_hh_member)) & (strpos(shhadid_members`wave', " " + my_hh_member + " ") == 0))

        drop my_hh_member
    }


    * Add spaces at beginning and end for easy search.
    replace leavers`wave' = " " + leavers`wave' + " "
    replace stayers`wave' = " " + stayers`wave' + " "
    replace arrivers`wave' = " " + arrivers`wave' + " "

    drop comp_change_case
}

save "$tempdir/who_changes", $replace
