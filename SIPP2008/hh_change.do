* This code comes from the old Robert/PAA/hh_analysis.do file.
* It needs to be reviewed, commented, and probably improved.
* In the interest of expediency I'm bringing it forward pretty much as is for now.
* See the old hh_analysis.do file for TODO type comments I am removing here
* (because, really, we need to look this over and generate a new set of TODO.

*** comp_change
*
*
* The comparison to determine composition change is:
*    Are the members of the household identical in the two waves being compared?
* We do not consider age when computing this.
*
*
* For adjacent waves that both have data, simply compare the people in the HH in the two waves.
*
*
* For transition from having data to going missing (wave D to wave F) 
* we need to know the status of household members in waves F through L.
* Specifically, we need to know if anyone in the household with ego at wave D
* appears in SIPP in any wave F through L.
*
*     If no such person appears we compare household composition at wave D with that at wave R
*     as if those waves were adjacent.  The result of the comparison determines the value of
*     comp_change in wave D.
*
*     If such a person does appear this implies that ego has experienced at least one composition
*     change.  We set comp_change = 1 in wave D.
*     
*
* For transition from missing to having data we need similar information to that above.
* In this case we need to know if anyone present in ego's household at wave R also present in any wave F through L.
*
*     If no such person appears there is no information about composition change.  We have already accounted
*     for the possible composition change between waves D and R.  We set comp_change to missing.
*
*     If such a person does appear there must be at least one composition change between
*     ego's situation in waves F through L and ego's situation at wave R.  We set comp_change = 1
*     in wave L.  NOTE THAT ego has no data at wave L so we must use 
*     any necessary values, such as age and weight, from a different wave.  We choose 
*     wave R for this purpose.  Thus if ego is an adult in wave R we will *not* count this
*     as a composition change.
*
*
* Initial appearance in SIPP is a special case of the transition from missing to having data.
*
*     If first appearance is in wave 1, this has no meaning for comp_change.
*
*     If appearance is after wave 1 and age is zero, this is ego's birth.  This is not a composition change.
*     comp_change = missing.
*
*     If appearance is after wave 1 and age is greater than zero, this is a composition change;
*     by virtue of the way SIPP is designed we know that someone in ego's household at wave R must
*     have been present somewhere in a previous wave.  The composition change is placed in the wave prior 
*     to first appearance and has the same liabilities noted above for placing a transition in a wave
*     where ego has no data.  
*
*
* Last appearance is treated identically to transition from having data to missing, as described above.
* The missing period is F through L, where L is the last SIPP wave.
*
*
* Transition from missing to missing.  We know nothing of substance about ego.  We mark
* comp_change as missing so that it does not enter the denominator of our calculations.
* Note that this does not mean all waves in which ego is missing get a composition change of missing!
* (The last missing wave may get a comp_change.)



*** addr_change
*
*
* The comparison to determine address change is:
*    1) Are the SHHADID identical in the two waves being compared?
*    2) Is ego a child in both waves.  We do not count changes that include transition to adulthood.
*
*
* For adjacent waves that both have data, simply compare SHHADID in the two waves.
*
*
* For transition from having data to going missing (wave D to wave F) 
* we need to know the status of SHHADID in waves F through L.
* Specifically, we need to know if both ego's SHHADID at wave D and
* ego's SHHADID at wave R appear in waves F through L.
*
*     If both SHHADID appear this implies ego must have been at at least one other address.
*     We set addr_change = 1 in wave D.
*
*     Otherwise we cannot be sure ego experienced a different address during F through L.
*     We compare SHHADID at wave D with that at wave R
*     as if those waves were adjacent.  The result of the comparison determines the value of
*     addr_change in wave D.
*     
*
* For transition from missing to having data we need the same information as above 
* (were both SHHADID at wave D and wave R present at some point in waves F through L).
*
*     If both SHHADID appear there must be at least one address change between
*     ego's situation in waves F through L and ego's situation at wave R.  We set addr_change = 1
*     in wave L.  NOTE THAT ego has no data at wave L so we must use 
*     any necessary values, such as age and weight, from a different wave.  We choose 
*     wave R for this purpose.  Thus if ego is an adult in wave R we will *not* count this
*     as a composition change.
*
*     Otherwise there is no information about address change.  We have already accounted
*     for the possible address change between waves D and R.  We set addr_change to missing.
*
*
* Initial appearance in SIPP is a special case of the transition from missing to having data.
*
*     If first appearance is in wave 1, this has no meaning for addr_change.
*
*     If appearance is after wave 1 and age is zero, this is ego's birth.  This is not an address change.
*     addr_change = missing
*
*     If appearance is after wave 1 and age is greater than zero, this may or may not be an address change.
*     We need the same information as before, except there is no prior address.  So if ego appears at wave R
*     we just need to know if SHHADID at wave R showed up in prior waves.  If so there must have been an
*     address change, which we place at wave R - 1.  This has the aforementioned problems of ego not having data in that wave.
*
*
* Last appearance is similar to initial appearance in that there is only one address to check.
* In this case there is only a prior address, not a subsequent one.  
* The missing period is F through L, where L is the last SIPP wave.
*
*
* Transition from missing to missing.  We know nothing of substance about ego.  We mark
* addr_change as missing so that it does not enter the denominator of our calculations.


use "$tempdir/person_wide_adjusted_ages"


* In the interest of expediency, try to speed things up by keeping only people who are
* children at some point in their SIPP existence.
gen is_ever_child = 0
forvalues wave = $first_wave/$final_wave {
    replace is_ever_child = 1 if (adj_age`wave' < $adult_age)
}
keep if is_ever_child
drop is_ever_child



#delimit ;
label define comp_change_reason   1 "data both waves"
                                  2 "initial non-birth"
                                  4 "gap exit found future"
                                  8 "gap entry found past"
                                  16 "gap empty A ne D";
#delimit cr

* Propagate shhadid_members forward into prev_hh_members for missing waves.  Similar for SHHADID.
gen prev_hh_members$first_wave = ""
gen prev_hh_children$first_wave = ""
gen prev_hh_adults$first_wave = ""
gen prev_SHHADID$first_wave = .
forvalues wave = $second_wave/$final_wave {
    local prev_wave = `wave' - 1
    gen prev_hh_children`wave' = shhadid_children`prev_wave' if (missing(SHHADID`wave') & missing(prev_hh_members`prev_wave'))
    replace prev_hh_children`wave' = prev_hh_children`prev_wave' if (missing(SHHADID`wave') & (!missing(prev_hh_members`prev_wave')))
    gen prev_hh_adults`wave' = shhadid_adults`prev_wave' if (missing(SHHADID`wave') & missing(prev_hh_members`prev_wave'))
    replace prev_hh_adults`wave' = prev_hh_adults`prev_wave' if (missing(SHHADID`wave') & (!missing(prev_hh_members`prev_wave')))
    gen prev_hh_members`wave' = shhadid_members`prev_wave' if (missing(SHHADID`wave') & missing(prev_hh_members`prev_wave'))
    replace prev_hh_members`wave' = prev_hh_members`prev_wave' if (missing(SHHADID`wave') & (!missing(prev_hh_members`prev_wave')))
    gen prev_SHHADID`wave' = SHHADID`prev_wave' if (missing(SHHADID`wave') & missing(prev_SHHADID`prev_wave'))
    replace prev_SHHADID`wave' = prev_SHHADID`prev_wave' if (missing(SHHADID`wave') & (!missing(prev_SHHADID`prev_wave')))
}

* Propagate shhadid_members backward into future_hh_members for missing waves.  Similar for SHHADID.
gen future_hh_members$final_wave = ""
gen future_hh_children$final_wave = ""
gen future_hh_adults$final_wave = ""
gen future_SHHADID$final_wave = .
forvalues wave = $penultimate_wave (-1) $first_wave {
    local next_wave = `wave' + 1
    gen future_hh_children`wave' = shhadid_children`next_wave' if (missing(SHHADID`wave') & missing(future_hh_members`next_wave'))
    replace future_hh_children`wave' = future_hh_children`next_wave' if (missing(SHHADID`wave') & (!missing(future_hh_members`next_wave')))
    gen future_hh_adults`wave' = shhadid_adults`next_wave' if (missing(SHHADID`wave') & missing(future_hh_members`next_wave'))
    replace future_hh_adults`wave' = future_hh_adults`next_wave' if (missing(SHHADID`wave') & (!missing(future_hh_members`next_wave')))
    gen future_hh_members`wave' = shhadid_members`next_wave' if (missing(SHHADID`wave') & missing(future_hh_members`next_wave'))
    replace future_hh_members`wave' = future_hh_members`next_wave' if (missing(SHHADID`wave') & (!missing(future_hh_members`next_wave')))
    gen future_SHHADID`wave' = SHHADID`next_wave' if (missing(SHHADID`wave') & missing(future_SHHADID`next_wave'))
    replace future_SHHADID`wave' = future_SHHADID`next_wave' if (missing(SHHADID`wave') & (!missing(future_SHHADID`next_wave')))
}


* Walk backward through the waves and for each wave in which ego is missing
* compare prev_hh_members to ssuid_members to see if we find anyone.
* Also, once a member is found propagate this fact down to the first missing wave in the gap.
* This is found_prev_hh_member_in_gap, which is set to 1 if a member is found in the current wave
* or if a member had already been found by the previous wave.  found_prev_hh_member_in_gap gets
* set to missing for a wave in which ego has data, so the propagation stops at the beginning of a gap.
*
* And do the same for previous SHHADID.
gen found_prev_hh_member$first_wave = 0
gen found_prev_hh_member_in_gap$first_wave = 0
gen found_prev_hh_child$first_wave = 0
gen found_prev_hh_child_in_gap$first_wave = 0
gen found_prev_hh_adult$first_wave = 0
gen found_prev_hh_adult_in_gap$first_wave = 0
gen found_prev_SHHADID$first_wave = .
forvalues wave = $final_wave (-1) $second_wave {
    gen found_prev_hh_member`wave' = 0 if (missing(SHHADID`wave'))
    gen found_prev_hh_member_in_gap`wave' = 0 if (missing(SHHADID`wave'))
    gen found_prev_hh_child`wave' = 0 if (missing(SHHADID`wave'))
    gen found_prev_hh_child_in_gap`wave' = 0 if (missing(SHHADID`wave'))
    gen found_prev_hh_adult`wave' = 0 if (missing(SHHADID`wave'))
    gen found_prev_hh_adult_in_gap`wave' = 0 if (missing(SHHADID`wave'))

    * Go ahead and copy the fact that we already know we found someone in the gap if we know that.
    if (`wave' < $final_wave) {
        local next_wave = `wave' + 1
        replace found_prev_hh_member_in_gap`wave' = 1 if ((missing(SHHADID`wave')) & (found_prev_hh_member_in_gap`next_wave' == 1))
        replace found_prev_hh_child_in_gap`wave' = 1 if ((missing(SHHADID`wave')) & (found_prev_hh_child_in_gap`next_wave' == 1))
        replace found_prev_hh_adult_in_gap`wave' = 1 if ((missing(SHHADID`wave')) & (found_prev_hh_adult_in_gap`next_wave' == 1))
    }

    forvalues my_hh_member_num = 1/`=overall_max_shhadid_members' {
        gen my_hh_member = word(prev_hh_members`wave', `my_hh_member_num') if (missing(SHHADID`wave'))
        replace my_hh_member = "X" if missing(my_hh_member)
        replace found_prev_hh_member`wave' = 1 if ((missing(SHHADID`wave')) & (strpos(ssuid_members`wave', " " + my_hh_member + " ") != 0))
        replace found_prev_hh_member_in_gap`wave' = 1 if ((missing(SHHADID`wave')) & (strpos(ssuid_members`wave', " " + my_hh_member + " ") != 0))
        drop my_hh_member
    }

    forvalues my_hh_child_num = 1/`=overall_max_shhadid_members' {
        gen my_hh_child = word(prev_hh_children`wave', `my_hh_child_num') if (missing(SHHADID`wave'))
        replace my_hh_child = "X" if missing(my_hh_child)
        replace found_prev_hh_child`wave' = 1 if ((missing(SHHADID`wave')) & (strpos(ssuid_members`wave', " " + my_hh_child + " ") != 0))
        replace found_prev_hh_child_in_gap`wave' = 1 if ((missing(SHHADID`wave')) & (strpos(ssuid_members`wave', " " + my_hh_child + " ") != 0))
        drop my_hh_child
    }

    forvalues my_hh_adult_num = 1/`=overall_max_shhadid_members' {
        gen my_hh_adult = word(prev_hh_adults`wave', `my_hh_adult_num') if (missing(SHHADID`wave'))
        replace my_hh_adult = "X" if missing(my_hh_adult)
        replace found_prev_hh_adult`wave' = 1 if ((missing(SHHADID`wave')) & (strpos(ssuid_members`wave', " " + my_hh_adult + " ") != 0))
        replace found_prev_hh_adult_in_gap`wave' = 1 if ((missing(SHHADID`wave')) & (strpos(ssuid_members`wave', " " + my_hh_adult + " ") != 0))
        drop my_hh_adult
    }

    gen found_prev_SHHADID`wave' = 0 if (missing(SHHADID`wave'))
    gen found_prev_SHHADID_in_gap`wave' = 0 if (missing(SHHADID`wave'))
    replace found_prev_SHHADID`wave' = 1 if ((missing(SHHADID`wave')) & (strpos(ssuid_shhadid`wave', " " + string(prev_SHHADID`wave') + " ") != 0))
    replace found_prev_SHHADID_in_gap`wave' = 1 if ((missing(SHHADID`wave')) & (strpos(ssuid_shhadid`wave', " " + string(prev_SHHADID`wave') + " ") != 0))
    if (`wave' < $final_wave) {
        local next_wave = `wave' + 1
        replace found_prev_SHHADID_in_gap`wave' = 1 if ((missing(SHHADID`wave')) & (found_prev_SHHADID_in_gap`next_wave' == 1))
    }
}


* Similarly, walk forward through the waves doing the same sort of computation for future
* HH members and SHHADID.
gen found_future_hh_member$final_wave = 0
gen found_future_hh_member_in_gap$final_wave = 0
gen found_future_hh_child$final_wave = 0
gen found_future_hh_child_in_gap$final_wave = 0
gen found_future_hh_adult$final_wave = 0
gen found_future_hh_adult_in_gap$final_wave = 0
gen found_future_SHHADID$final_wave = .
forvalues wave = $first_wave/$penultimate_wave {
    gen found_future_hh_member`wave' = 0 if (missing(SHHADID`wave'))
    gen found_future_hh_member_in_gap`wave' = 0 if (missing(SHHADID`wave'))
    gen found_future_hh_child`wave' = 0 if (missing(SHHADID`wave'))
    gen found_future_hh_child_in_gap`wave' = 0 if (missing(SHHADID`wave'))
    gen found_future_hh_adult`wave' = 0 if (missing(SHHADID`wave'))
    gen found_future_hh_adult_in_gap`wave' = 0 if (missing(SHHADID`wave'))

    * Go ahead and copy the fact that we already know we found someone in the gap if we know that.
    if (`wave' > $first_wave) {
        local prev_wave = `wave' - 1
        replace found_future_hh_member_in_gap`wave' = 1 if ((missing(SHHADID`wave')) & (found_future_hh_member_in_gap`prev_wave' == 1))
        replace found_future_hh_child_in_gap`wave' = 1 if ((missing(SHHADID`wave')) & (found_future_hh_child_in_gap`prev_wave' == 1))
        replace found_future_hh_adult_in_gap`wave' = 1 if ((missing(SHHADID`wave')) & (found_future_hh_adult_in_gap`prev_wave' == 1))
    }

    forvalues my_hh_member_num = 1/`=overall_max_shhadid_members' {
        gen my_hh_member = word(future_hh_members`wave', `my_hh_member_num') if (missing(SHHADID`wave'))
        replace found_future_hh_member`wave' = 1 if ((missing(SHHADID`wave')) & (strpos(ssuid_members`wave', " " + my_hh_member + " ") != 0))
        replace found_future_hh_member_in_gap`wave' = 1 if ((missing(SHHADID`wave')) & (strpos(ssuid_members`wave', " " + my_hh_member + " ") != 0))
        drop my_hh_member
    }

    forvalues my_hh_child_num = 1/`=overall_max_shhadid_members' {
        gen my_hh_child = word(future_hh_children`wave', `my_hh_child_num') if (missing(SHHADID`wave'))
        replace found_future_hh_child`wave' = 1 if ((missing(SHHADID`wave')) & (strpos(ssuid_members`wave', " " + my_hh_child + " ") != 0))
        replace found_future_hh_child_in_gap`wave' = 1 if ((missing(SHHADID`wave')) & (strpos(ssuid_members`wave', " " + my_hh_child + " ") != 0))
        drop my_hh_child
    }

    forvalues my_hh_adult_num = 1/`=overall_max_shhadid_members' {
        gen my_hh_adult = word(future_hh_adults`wave', `my_hh_adult_num') if (missing(SHHADID`wave'))
        replace found_future_hh_adult`wave' = 1 if ((missing(SHHADID`wave')) & (strpos(ssuid_members`wave', " " + my_hh_adult + " ") != 0))
        replace found_future_hh_adult_in_gap`wave' = 1 if ((missing(SHHADID`wave')) & (strpos(ssuid_members`wave', " " + my_hh_adult + " ") != 0))
        drop my_hh_adult
    }

    gen found_future_SHHADID`wave' = 0 if (missing(SHHADID`wave'))
    gen found_future_SHHADID_in_gap`wave' = 0 if (missing(SHHADID`wave'))
    replace found_future_SHHADID`wave' = 1 if ((missing(SHHADID`wave')) & (strpos(ssuid_shhadid`wave', " " + string(future_SHHADID`wave') + " ") != 0))
    replace found_future_SHHADID_in_gap`wave' = 1 if ((missing(SHHADID`wave')) & (strpos(ssuid_shhadid`wave', " " + string(future_SHHADID`wave') + " ") != 0))
    if (`wave' > $first_wave) {
        local prev_wave = `wave' - 1
        replace found_future_SHHADID_in_gap`wave' = 1 if ((missing(SHHADID`wave')) & (found_future_SHHADID_in_gap`prev_wave' == 1))
    }
}


* Compute composition change.
forvalues wave = $first_wave/$penultimate_wave {
    local next_wave = `wave' + 1

    *** Start by assuming this wave is not interesting.
    gen comp_change`wave' = .
    gen comp_change_reason`wave' = 0

    gen child_change`wave' = .
    gen adult_change`wave' = .

    gen child_enter`wave' = .
    gen adult_enter`wave' = .
    gen child_exit`wave' = .
    gen adult_exit`wave' = .

    gen num_child_enter`wave' = 0
    gen num_adult_enter`wave' = 0
    gen num_child_exit`wave' = 0
    gen num_adult_exit`wave' = 0


    *** If we have data in both waves, just compare HH members.
    replace comp_change`wave' = (shhadid_members`wave' != shhadid_members`next_wave') if ((!missing(SHHADID`wave')) & (!missing(SHHADID`next_wave')))
    replace comp_change_reason`wave' = comp_change_reason`wave' + 1 if ((shhadid_members`wave' != shhadid_members`next_wave') & (!missing(SHHADID`wave')) & (!missing(SHHADID`next_wave')))
    gen comp_change_case = ((shhadid_members`wave' != shhadid_members`next_wave') & (!missing(SHHADID`wave')) & (!missing(SHHADID`next_wave')))

    forvalues my_hh_member_num = 1/`=max_shhadid_members`wave'' {
        gen my_hh_member = word(shhadid_members`wave', `my_hh_member_num') if (comp_change_case == 1)
        * This is a bit lazy but prevents having to check for missing my_hh_member in all the places below, so overall it's easier to read.
        replace my_hh_member = "XXXX" if missing(my_hh_member)

        * A child leaves if they do not apepar in the next wave and they are a child in this wave.
        replace child_change`wave' = 1 if ((comp_change_case == 1) & (strpos(shhadid_members`next_wave', " " + my_hh_member + " ") == 0) & (strpos(shhadid_children`wave', " " + my_hh_member + " ") != 0))
        replace child_exit`wave' = 1 if ((comp_change_case == 1) & (strpos(shhadid_members`next_wave', " " + my_hh_member + " ") == 0) & (strpos(shhadid_children`wave', " " + my_hh_member + " ") != 0))
        replace num_child_exit`wave' = (num_child_exit`wave' + 1) if ((comp_change_case == 1) & (strpos(shhadid_members`next_wave', " " + my_hh_member + " ") == 0) & (strpos(shhadid_children`wave', " " + my_hh_member + " ") != 0))

        * An adult leaves if they do not appear in the next wave and they are an adult in this wave.
        replace adult_change`wave' = 1 if ((comp_change_case == 1) & (strpos(shhadid_members`next_wave', " " + my_hh_member + " ") == 0) & (strpos(shhadid_adults`wave', " " + my_hh_member + " ") != 0))
        replace adult_exit`wave' = 1 if ((comp_change_case == 1) & (strpos(shhadid_members`next_wave', " " + my_hh_member + " ") == 0) & (strpos(shhadid_adults`wave', " " + my_hh_member + " ") != 0))
        replace num_adult_exit`wave' = (num_adult_exit`wave' + 1) if ((comp_change_case == 1) & (strpos(shhadid_members`next_wave', " " + my_hh_member + " ") == 0) & (strpos(shhadid_adults`wave', " " + my_hh_member + " ") != 0))

        drop my_hh_member
    }

    forvalues my_hh_member_num = 1/`=max_shhadid_members`next_wave'' {
        gen my_hh_member = word(shhadid_members`next_wave', `my_hh_member_num') if (comp_change_case == 1)
        replace my_hh_member = "XXXX" if missing(my_hh_member)

        * A child enters if they do not appear in this wave and they are a child in the next wave.
        replace child_change`wave' = 1 if ((comp_change_case == 1) & (strpos(shhadid_members`wave', " " + my_hh_member + " ") == 0) & (strpos(shhadid_children`next_wave', " " + my_hh_member + " ") != 0))
        replace child_enter`wave' = 1 if ((comp_change_case == 1) & (strpos(shhadid_members`wave', " " + my_hh_member + " ") == 0) & (strpos(shhadid_children`next_wave', " " + my_hh_member + " ") != 0))
        replace num_child_enter`wave' = (num_child_enter`wave' + 1) if ((comp_change_case == 1) & (strpos(shhadid_members`wave', " " + my_hh_member + " ") == 0) & (strpos(shhadid_children`next_wave', " " + my_hh_member + " ") != 0))

        * An adult enters if they do not appear in this wave and they are an adult in the next wave.
        replace adult_change`wave' = 1 if ((comp_change_case == 1) & (strpos(shhadid_members`wave', " " + my_hh_member + " ") == 0) & (strpos(shhadid_adults`next_wave', " " + my_hh_member + " ") != 0))
        replace adult_enter`wave' = 1 if ((comp_change_case == 1) & (strpos(shhadid_members`wave', " " + my_hh_member + " ") == 0) & (strpos(shhadid_adults`next_wave', " " + my_hh_member + " ") != 0))
        replace num_adult_enter`wave' = (num_adult_enter`wave' + 1) if ((comp_change_case == 1) & (strpos(shhadid_members`wave', " " + my_hh_member + " ") == 0) & (strpos(shhadid_adults`next_wave', " " + my_hh_member + " ") != 0))

        drop my_hh_member
    }

    drop comp_change_case



    *** If next wave is ego's first and it's not a birth (age > 0), it's a change.
    * We also need to populate age and weight from the next wave since ego has no data in this wave.
    replace comp_change`wave' = 1 if ((`next_wave' == my_first_wave) & (adj_age`next_wave' > 0))
    replace comp_change_reason`wave' = comp_change_reason`wave' + 2 if ((`next_wave' == my_first_wave) & (adj_age`next_wave' > 0))
    replace adj_age`wave' = adj_age`next_wave' if ((`next_wave' == my_first_wave) & (adj_age`next_wave' > 0))
    replace WPFINWGT`wave' = WPFINWGT`next_wave' if ((`next_wave' == my_first_wave) & (adj_age`next_wave' > 0))

    * We look at the "gap" from first wave to this wave to see if anyone from the future HH shows up and set changes accordingly.
    replace child_change`wave' = 1 if ((`next_wave' == my_first_wave) & (adj_age`next_wave' > 0) & (found_future_hh_child_in_gap`wave' == 1))
    replace child_enter`wave' = 1 if ((`next_wave' == my_first_wave) & (adj_age`next_wave' > 0) & (found_future_hh_child_in_gap`wave' == 1))
    replace num_child_enter`wave' = (num_child_enter`wave' + 1) if ((`next_wave' == my_first_wave) & (adj_age`next_wave' > 0) & (found_future_hh_child_in_gap`wave' == 1))
    replace adult_change`wave' = 1 if ((`next_wave' == my_first_wave) & (adj_age`next_wave' > 0) & (found_future_hh_adult_in_gap`wave' == 1))
    replace adult_enter`wave' = 1 if ((`next_wave' == my_first_wave) & (adj_age`next_wave' > 0) & (found_future_hh_adult_in_gap`wave' == 1))
    replace num_adult_enter`wave' = (num_adult_enter`wave' + 1) if ((`next_wave' == my_first_wave) & (adj_age`next_wave' > 0) & (found_future_hh_adult_in_gap`wave' == 1))

    * At one time we would just count an adult_enter for my initial non-birth appearance.
    * Keep this variable so we can compare to the new results.
    gen non_birth_adult_enter`wave' = 1 if ((`next_wave' == my_first_wave) & (adj_age`next_wave' > 0))



    *** If we are moving from a wave in which ego is missing to one in which ego is present
    * there is a composition change if we have seen any member of the future household in gap during which ego was missing.
    * Again, we also need to populate age and weight from the next wave since ego has no data in this wave.
    replace comp_change`wave' = 1 if ((missing(SHHADID`wave')) & (!missing(SHHADID`next_wave')) & (`next_wave' > my_first_wave) & (found_future_hh_member_in_gap`wave' == 1))
    replace comp_change_reason`wave' = comp_change_reason`wave' + 4 if ((missing(SHHADID`wave')) & (!missing(SHHADID`next_wave')) & (`next_wave' > my_first_wave) & (found_future_hh_member_in_gap`wave' == 1))
    replace adj_age`wave' = adj_age`next_wave' if ((missing(SHHADID`wave')) & (!missing(SHHADID`next_wave')) & (`next_wave' > my_first_wave) & (found_future_hh_member_in_gap`wave' == 1))
    replace WPFINWGT`wave' = WPFINWGT`next_wave' if ((missing(SHHADID`wave')) & (!missing(SHHADID`next_wave')) & (`next_wave' > my_first_wave) & (found_future_hh_member_in_gap`wave' == 1))

    * Child/adult change is similar.
    replace child_change`wave' = 1 if ((missing(SHHADID`wave')) & (!missing(SHHADID`next_wave')) & (`next_wave' > my_first_wave) & (found_future_hh_child_in_gap`wave' == 1))
    replace child_enter`wave' = 1 if ((missing(SHHADID`wave')) & (!missing(SHHADID`next_wave')) & (`next_wave' > my_first_wave) & (found_future_hh_child_in_gap`wave' == 1))
    replace num_child_enter`wave' = (num_child_enter`wave' + 1) if ((missing(SHHADID`wave')) & (!missing(SHHADID`next_wave')) & (`next_wave' > my_first_wave) & (found_future_hh_child_in_gap`wave' == 1))
    replace adult_change`wave' = 1 if ((missing(SHHADID`wave')) & (!missing(SHHADID`next_wave')) & (`next_wave' > my_first_wave) & (found_future_hh_adult_in_gap`wave' == 1))
    replace adult_enter`wave' = 1 if ((missing(SHHADID`wave')) & (!missing(SHHADID`next_wave')) & (`next_wave' > my_first_wave) & (found_future_hh_adult_in_gap`wave' == 1))
    replace num_adult_enter`wave' = (num_adult_enter`wave' + 1) if ((missing(SHHADID`wave')) & (!missing(SHHADID`next_wave')) & (`next_wave' > my_first_wave) & (found_future_hh_adult_in_gap`wave' == 1))


    *** If we are moving from a wave in which ego is present to one in which ego is missing
    * there is a composition change if we have seen any member of the current household in gap 
    * during which ego is missing as we look forward.
    replace comp_change`wave' = 1 if ((!missing(SHHADID`wave')) & (missing(SHHADID`next_wave')) & (found_prev_hh_member_in_gap`next_wave' == 1))
    replace comp_change_reason`wave' = comp_change_reason`wave' + 8 if ((!missing(SHHADID`wave')) & (missing(SHHADID`next_wave')) & (found_prev_hh_member_in_gap`next_wave' == 1))

    replace child_change`wave' = 1 if ((!missing(SHHADID`wave')) & (missing(SHHADID`next_wave')) & (found_prev_hh_child_in_gap`next_wave' == 1))
    replace child_exit`wave' = 1 if ((!missing(SHHADID`wave')) & (missing(SHHADID`next_wave')) & (found_prev_hh_child_in_gap`next_wave' == 1))
    replace num_child_exit`wave' = (num_child_exit`wave' + 1) if ((!missing(SHHADID`wave')) & (missing(SHHADID`next_wave')) & (found_prev_hh_child_in_gap`next_wave' == 1))
    replace adult_change`wave' = 1 if ((!missing(SHHADID`wave')) & (missing(SHHADID`next_wave')) & (found_prev_hh_adult_in_gap`next_wave' == 1))
    replace adult_exit`wave' = 1 if ((!missing(SHHADID`wave')) & (missing(SHHADID`next_wave')) & (found_prev_hh_adult_in_gap`next_wave' == 1))
    replace num_adult_exit`wave' = (num_adult_exit`wave' + 1) if ((!missing(SHHADID`wave')) & (missing(SHHADID`next_wave')) & (found_prev_hh_adult_in_gap`next_wave' == 1))


    *** If we are moving from a wave in which ego is present to one in which ego is missing
    * and we do not see any member of the current household  or any member of the future
    * household in the gap looking forward,
    * we compare the current household to the future household as if we move into the
    * future household in the first missing wave unless there is no future HH
    * (ego's last appearance).
    replace comp_change`wave' = (shhadid_members`wave' != future_hh_members`next_wave') if ((!missing(SHHADID`wave')) & (missing(SHHADID`next_wave')) & (!missing(future_hh_members`next_wave')) & (found_prev_hh_member_in_gap`next_wave' != 1) & (found_future_hh_member_in_gap`next_wave' != 1))
    replace comp_change_reason`wave' = comp_change_reason`wave' + 16 if ((shhadid_members`wave' != future_hh_members`next_wave') & (!missing(SHHADID`wave')) & (missing(SHHADID`next_wave')) & (!missing(future_hh_members`next_wave')) & (found_prev_hh_member_in_gap`next_wave' != 1) & (found_future_hh_member_in_gap`next_wave' != 1))

    gen comp_change_case = ((shhadid_members`wave' != future_hh_members`next_wave') & (!missing(SHHADID`wave')) & (missing(SHHADID`next_wave')) & (!missing(future_hh_members`next_wave')) & (found_prev_hh_member_in_gap`next_wave' != 1) & (found_future_hh_member_in_gap`next_wave' != 1))

    forvalues my_hh_member_num = 1/`=max_shhadid_members`wave'' {
        gen my_hh_member = word(shhadid_members`wave', `my_hh_member_num') if (comp_change_case == 1)
        * This is a bit lazy but prevents having to check for missing my_hh_member in all the places below, so overall it's easier to read.
        replace my_hh_member = "XXXX" if missing(my_hh_member)

        * A child leaves if they do not apepar in the next wave and they are a child in this wave.
        replace child_change`wave' = 1 if ((comp_change_case == 1) & (strpos(future_hh_members`next_wave', " " + my_hh_member + " ") == 0) & (strpos(shhadid_children`wave', " " + my_hh_member + " ") != 0))
        replace child_exit`wave' = 1 if ((comp_change_case == 1) & (strpos(future_hh_members`next_wave', " " + my_hh_member + " ") == 0) & (strpos(shhadid_children`wave', " " + my_hh_member + " ") != 0))
        replace num_child_exit`wave' = (num_child_exit`wave' + 1) if ((comp_change_case == 1) & (strpos(future_hh_members`next_wave', " " + my_hh_member + " ") == 0) & (strpos(shhadid_children`wave', " " + my_hh_member + " ") != 0))

        * An adult leaves if they do not appear in the next wave and they are an adult in this wave.
        replace adult_change`wave' = 1 if ((comp_change_case == 1) & (strpos(future_hh_members`next_wave', " " + my_hh_member + " ") == 0) & (strpos(shhadid_adults`wave', " " + my_hh_member + " ") != 0))
        replace adult_exit`wave' = 1 if ((comp_change_case == 1) & (strpos(future_hh_members`next_wave', " " + my_hh_member + " ") == 0) & (strpos(shhadid_adults`wave', " " + my_hh_member + " ") != 0))
        replace num_adult_exit`wave' = (num_adult_exit`wave' + 1) if ((comp_change_case == 1) & (strpos(future_hh_members`next_wave', " " + my_hh_member + " ") == 0) & (strpos(shhadid_adults`wave', " " + my_hh_member + " ") != 0))

        drop my_hh_member
    }

    forvalues my_hh_member_num = 1/`=overall_max_shhadid_members' {
        gen my_hh_member = word(future_hh_members`next_wave', `my_hh_member_num') if (comp_change_case == 1)
        replace my_hh_member = "XXXX" if missing(my_hh_member)

        * A child enters if they do not appear in this wave and they are a child in the next wave.
        replace child_change`wave' = 1 if ((comp_change_case == 1) & (strpos(shhadid_members`wave', " " + my_hh_member + " ") == 0) & (strpos(future_hh_children`next_wave', " " + my_hh_member + " ") != 0))
        replace child_enter`wave' = 1 if ((comp_change_case == 1) & (strpos(shhadid_members`wave', " " + my_hh_member + " ") == 0) & (strpos(future_hh_children`next_wave', " " + my_hh_member + " ") != 0))
        replace num_child_enter`wave' = (num_child_enter`wave' + 1) if ((comp_change_case == 1) & (strpos(shhadid_members`wave', " " + my_hh_member + " ") == 0) & (strpos(future_hh_children`next_wave', " " + my_hh_member + " ") != 0))

        * An adult enters if they do not appear in this wave and they are an adult in the next wave.
        replace adult_change`wave' = 1 if ((comp_change_case == 1) & (strpos(shhadid_members`wave', " " + my_hh_member + " ") == 0) & (strpos(future_hh_adults`next_wave', " " + my_hh_member + " ") != 0))
        replace adult_enter`wave' = 1 if ((comp_change_case == 1) & (strpos(shhadid_members`wave', " " + my_hh_member + " ") == 0) & (strpos(future_hh_adults`next_wave', " " + my_hh_member + " ") != 0))
        replace num_adult_enter`wave' = (num_adult_enter`wave' + 1) if ((comp_change_case == 1) & (strpos(shhadid_members`wave', " " + my_hh_member + " ") == 0) & (strpos(future_hh_adults`next_wave', " " + my_hh_member + " ") != 0))

        drop my_hh_member
    }

    drop comp_change_case

    * Add zeros for comp_change if needed.  We need to confirm this is what we want.  We set to zero if comp_change and ego was present this wave and this is not ego's last wave.
    replace comp_change`wave' = 0 if (missing(comp_change`wave') & (!missing(SHHADID`wave') & (`wave' != my_last_wave)))
    * Fixing up adult/child change is easier.  They need a value if comp_change has one.
    replace child_change`wave' = 0 if (missing(child_change`wave') & (!missing(comp_change`wave')))
    replace child_enter`wave' = 0 if (missing(child_enter`wave') & (!missing(comp_change`wave')))
    replace num_child_enter`wave' = 0 if (missing(num_child_enter`wave') & (!missing(comp_change`wave')))
    replace child_exit`wave' = 0 if (missing(child_exit`wave') & (!missing(comp_change`wave')))
    replace num_child_exit`wave' = 0 if (missing(num_child_exit`wave') & (!missing(comp_change`wave')))
    replace adult_change`wave' = 0 if (missing(adult_change`wave') & (!missing(comp_change`wave')))
    replace adult_enter`wave' = 0 if (missing(adult_enter`wave') & (!missing(comp_change`wave')))
    replace num_adult_enter`wave' = 0 if (missing(num_adult_enter`wave') & (!missing(comp_change`wave')))
    replace adult_exit`wave' = 0 if (missing(adult_exit`wave') & (!missing(comp_change`wave')))
    replace num_adult_exit`wave' = 0 if (missing(num_adult_exit`wave') & (!missing(comp_change`wave')))

    assert ((child_change`wave' == 1) | (adult_change`wave' == 1)) if (comp_change`wave' == 1)
    assert ((child_change`wave' == 0) & (adult_change`wave' == 0)) if (comp_change`wave' == 0)
    assert (missing(child_change`wave') & missing(adult_change`wave')) if missing(comp_change`wave')

    display "Counts for wave `wave'"
    count if (comp_change`wave' == 1)
    count if (child_change`wave' == 1) | (adult_change`wave' == 1) 
    count if ((child_change`wave' == 1) | (adult_change`wave' == 1)) & (comp_change`wave' != 1)
    count if ((child_change`wave' != 1) & (adult_change`wave' != 1)) & (comp_change`wave' == 1)


    * Check the new adult/child results compared to the old hack of adult change on my non-birth appearance.
    tab adult_change`wave' non_birth_adult_enter`wave', m
    tab child_change`wave' non_birth_adult_enter`wave', m

    label values comp_change_reason`wave' comp_change_reason
}



* Compute address change.
forvalues wave = $first_wave/$penultimate_wave {
    local next_wave = `wave' + 1

    * Start by assuming this wave is not interesting.
    gen addr_change`wave' = .

    * If we have data in both waves, just compare HH members.
    replace addr_change`wave' = (SHHADID`wave' != SHHADID`next_wave') if ((!missing(SHHADID`wave')) & (!missing(SHHADID`next_wave')))

    * If we are moving from a wave in which ego is missing to one in which ego is present
    * there is an address change if we have seen the future SHHADID in the gap during which ego was missing
    * UNLESS this is ego's birth.
    * We also need to populate age and weight from the next wave since ego has no data in this wave.
    replace addr_change`wave' = 1 if ((missing(SHHADID`wave')) & (!missing(SHHADID`next_wave')) & (found_future_SHHADID_in_gap`wave' == 1))
    replace adj_age`wave' = adj_age`next_wave' if ((missing(SHHADID`wave')) & (!missing(SHHADID`next_wave')) & (found_future_SHHADID_in_gap`wave' == 1))
    replace WPFINWGT`wave' = WPFINWGT`next_wave' if ((missing(SHHADID`wave')) & (!missing(SHHADID`next_wave')) & (found_future_SHHADID_in_gap`wave' == 1))
    * Undo those changes if this is birth.
    replace addr_change`wave' = . if ((`next_wave' == my_first_wave) & (adj_age`next_wave' == 0))
    replace adj_age`wave' = . if ((`next_wave' == my_first_wave) & (adj_age`next_wave' == 0))
    replace WPFINWGT`wave' = . if ((`next_wave' == my_first_wave) & (adj_age`next_wave' == 0))

    * If we are moving from a wave in which ego is present to one in which ego is missing
    * there is an address change if we have seen the current SHHADID in the gap 
    * during which ego is missing as we look forward.
    replace addr_change`wave' = 1 if ((!missing(SHHADID`wave')) & (missing(SHHADID`next_wave')) & (found_prev_SHHADID_in_gap`next_wave' == 1))

    * If we are moving from a wave in which ego is present to one in which ego is missing
    * and we do not see the current SHHADID in the gap looking forward,
    * we compare the current SHHADID to the future SHHADID as if we move into the
    * future household in the first missing wave, unless there is no future SHHADID
    * (ego's last appearance).
    replace addr_change`wave' = (SHHADID`wave' != future_SHHADID`next_wave') if ((!missing(SHHADID`wave')) & (missing(SHHADID`next_wave')) & (!missing(future_SHHADID`next_wave')) & (found_prev_SHHADID_in_gap`next_wave' != 1))


    * Tab "original" addr_change and comp_change variables.
    tab addr_change`wave' comp_change`wave', m

    * Now fix them up to have the same denominator.  Set to zero if missing and the other variable is not missing.
    replace addr_change`wave' = 0 if (missing(addr_change`wave') & (!missing(comp_change`wave')))
    replace comp_change`wave' = 0 if (missing(comp_change`wave') & (!missing(addr_change`wave')))

    tab addr_change`wave' comp_change`wave', m
}



* In the old Robert/PAA/hh_analysis.do we have code to compute some
* normalized education variables.  May want to resurrect that but as
* far as I know we don't care right now and certainly don't know if
* what we did then is what we want now.  Deleting it from this version.

* Similarly we had some code to normalize mom's immigrant status
* by taking the first reported status (I think).  Deleting that, too.

save "$tempdir/hh_change", $replace
