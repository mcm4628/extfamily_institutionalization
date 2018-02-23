*** DO NOT USE!!!  Still under development.

/*
hh_change does most of what we need, but instead of needing to know if we found someone in the gap
we need to know who we found.  This is considerably harder because we have to compute a set.
And I think we may want that set in order.  Hmmm.

So, maybe start with the full list of candidates who might show up,
mark the ones that actually do, then remove the unmarked ones and
then remove the marks?  This preserves order.

So once I have those things, what?

How about characterizing each current member as leaver, or stayer?  They can't be an arriver.
Anyone who appears in the gap is a leaver.
Anyone who does not appear in the return wave is a leaver.  It does not matter if they are also a leaver by the above rule.

And the characteristics of future members?
Anyone who appears in the gap is an arriver.
Anyone who does not appear in the current HH is an arriver.  It doesn't matter if they also fit the above rule.

Maybe it would be better not to bother with computing sets of people in the gap and instead use the simple rules above?

TODO:  I'm not sure the "set in a string" paradigm is best any more, but I don't know of anything Stata supports that works better.
Mata?
Wide format using inlist (but I don't think inlist works this way.  MAybe it does, or maybe there's an alternative.
*/




use "$tempdir/person_wide_adjusted_ages"


* In the interest of expediency, try to speed things up by keeping only people who are
* children at some point in their SIPP existence.
gen is_ever_child = 0
forvalues wave = $first_wave/$final_wave {
    replace is_ever_child = 1 if (adj_age`wave' < $adult_age)
}
keep if is_ever_child
drop is_ever_child



* Propagate shhadid_members forward into prev_hh_members for missing waves.  Similar for SHHADID.
gen prev_hh_members$first_wave = ""
forvalues wave = $second_wave/$final_wave {
    local prev_wave = `wave' - 1
    gen prev_hh_members`wave' = shhadid_members`prev_wave' if (missing(SHHADID`wave') & missing(prev_hh_members`prev_wave'))
    replace prev_hh_members`wave' = prev_hh_members`prev_wave' if (missing(SHHADID`wave') & (!missing(prev_hh_members`prev_wave')))
}

* Propagate shhadid_members backward into future_hh_members for missing waves.  Similar for SHHADID.
gen future_hh_members$final_wave = ""
forvalues wave = $penultimate_wave (-1) $first_wave {
    local next_wave = `wave' + 1
    gen future_hh_members`wave' = shhadid_members`next_wave' if (missing(SHHADID`wave') & missing(future_hh_members`next_wave'))
    replace future_hh_members`wave' = future_hh_members`next_wave' if (missing(SHHADID`wave') & (!missing(future_hh_members`next_wave')))
}


* Walk backward through the waves and for each wave in which ego is missing
* compare prev_hh_members to ssuid_members to see if we find anyone.
* Also, once a member is found propagate this fact down to the first missing wave in the gap.
* This is found_prev_hh_member_in_gap, which is set to 1 if a member is found in the current wave
* or if a member had already been found by the previous wave.  found_prev_hh_member_in_gap gets
* set to missing for a wave in which ego has data, so the propagation stops at the beginning of a gap.
gen found_prev_hh_member_in_gap$first_wave = ""
forvalues wave = $final_wave (-1) $second_wave {
    gen found_prev_hh_member_in_gap`wave' = " " * strlen(prev_hh_members`wave') if (missing(SHHADID`wave'))

    * Go ahead and copy what we've found so far.
    if (`wave' < $final_wave) {
        local next_wave = `wave' + 1
        replace found_prev_hh_member_in_gap`wave' = found_prev_hh_member_in_gap`next_wave' if (missing(SHHADID`wave'))
    }

    forvalues my_hh_member_num = 1/`=overall_max_shhadid_members' {
        gen my_hh_member = word(prev_hh_members`wave', `my_hh_member_num') if (missing(SHHADID`wave'))
        replace my_hh_member = "X" if missing(my_hh_member)
        tempvar position
        gen `position' = strpos(prev_hh_members`wave', " " + my_hh_member + " ") if ((missing(SHHADID`wave')) & (strpos(ssuid_members`wave', " " + my_hh_member + " ") != 0))
        replace found_prev_hh_member_in_gap`wave' = substr(found_prev_hh_member_in_gap`wave', 1, `position' - 1) + "1" + substr(found_prev_hh_member_in_gap`wave', `position' + 1, .) if (!missing(`position'))
        drop my_hh_member
    }
}


stop here

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
