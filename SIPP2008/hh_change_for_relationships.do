//==============================================================================
//===== Children's Household Instability Project
//===== Dataset: SIPP2008
//===== Purpose:  Compute household changes for children.  We compute not just the fact of a chance, but who
//=====           changed so that we can examine relationships for those responsible for the changes.
//=====           We segregate leavers from arrivers in case this distinction is relevant.
//=====           We also compute who stays in the household so we can look at the attributes of stayers.
//==============================================================================

use "$tempdir/person_wide_adjusted_ages"

drop my_race* my_sex*

********************************************************************************
** Function:  Propagate shhadid_members forward into prev_hh_members for missing waves.  This allows us to
**            know who was in the household with the respondent in the most recent wave during which the
**            respondent was present.

** Logic:   Walk forward through the waves, starting with the second (there's nothing we could propagate
**			forward into the first wave).  When the respondent is missing, SHHADID will be missing.
**          For the first wave of a gap, prev_hh_members for the previous wave will be missing, and we.
**          copy shhadid_members for the previous wave into prev_hh_members for this wave.
**	       	For subsequent waves of a continuous gap prev_hh_members for the previous wave will exist
**        	so we just copy this into prev_hh_members for this wave.
********************************************************************************

gen prev_hh_members$first_wave = ""
forvalues wave = $second_wave/$final_wave {
    local prev_wave = `wave' - 1
    gen prev_hh_members`wave' = shhadid_members`prev_wave' if (missing(SHHADID`wave') & missing(prev_hh_members`prev_wave'))
    replace prev_hh_members`wave' = prev_hh_members`prev_wave' if (missing(SHHADID`wave') & (!missing(prev_hh_members`prev_wave')))
}

********************************************************************************
** Purpose:  Propagate shhadid_members backward into future_hh_members for missing waves.  This allows us to
**          know who will be in the household with the respondent in wave in which the respondent reappears.
**
** Logic:  Very similar to the logic for prev_hh_members except that we walk backward from the penultimate wave.
********************************************************************************

gen future_hh_members$final_wave = ""
forvalues wave = $penultimate_wave (-1) $first_wave {
    local next_wave = `wave' + 1
    gen future_hh_members`wave' = shhadid_members`next_wave' if (missing(SHHADID`wave') & missing(future_hh_members`next_wave'))
    replace future_hh_members`wave' = future_hh_members`next_wave' if (missing(SHHADID`wave') & (!missing(future_hh_members`next_wave')))
}

********************************************************************************
** Function:  Compute flags indicating if each previous household member is found anywhere during a contiguous
**          gap in which the respondent is missing.  The flags are encoded in found_prev_hh_member_in_gap:
**           if we find a previous household member is found we place a 1 in found_prev_hh_member_in_gap at
**          the same position as the previous household member is found in prev_hh_members.
**           For example, if prev_hh_members5 is " 102 104 303 " and we have found 102 and 303 in the gap
**          found_prev_hh_member_in_gap5 will be "1       1    ".  Note the off-by-one positioning
**           due to the fact that we search for " 102 " when we are looking for 102.  See notes on
**           implementation below.
**
**          Note that found_prev_hh_member_in_gap may not be fully populated for waves other than
**          the first wave of a gap (and the last wave before the gap, just because we copy it there).
**          For example, if 102 is found in wave 7 and 303 is found in wave 4, the flags for waves
**           5-7 will show only 102 because that's all we've seen so far.  Wave 4 will show both.
**
** Logic:  Walk backward through the waves (we stop at the second because the first wave can't have any
**         previous members).  Copy the flags discovered so far if this is not the last wave of a gap
**        (since we're walking backward, the last wave of the gap is the first wave we encounter).
**         If this wave is part of a gap (the respondent is missing), for each previous household member
**         look to see if that person appears in this wave.  If so, put a 1 at the appropriate position
**         in found_prev_hh_member_in_gap for this wave.  Note that it doesn't hurt to put a 1 there
**         even if one is already present -- the resulting string is identical to what it already was.

**         Some notes on implementation:
**             The notation " " * strlen(x) creates a string of blanks whose length is the same as
**                 the length of x.
**             We loop through overall_max_shhadid_members possible previous household members.  Since the
**                 has to work for all observations, we have to loop through the most members any household
**                 may have.  That's fine because for households with fewer members word(prev_hh_members, n)
**                 is null for n > the number of prev_hh_members who actually exist for this household.
**             Setting my_hh_member = "X" isn't really necessary but it's safer for the future and maybe a
**                 little easier to read.  If we left my_hh_member empty ("") it currently works fine because
**                 we end up searching for "  ", which never occurs in prev_hh_members.  But it's safer not
**                 to depend on the fact that we don't have redundant spaces.
**             We copy found_prev_hh_member_in_gap into the wave before the gap begins.  I don't think we
**                 actually make use of this, but it doesn't hurt.
**             The idiom of searching for " " + my_hh_member + " ", for example that would be " 102 " for 
**                 member 102, prevents incorrectly finding 1102 when you're looking for 102.
********************************************************************************

gen found_prev_hh_member_in_gap$first_wave = ""
forvalues wave = $final_wave (-1) $second_wave {
    display "Wave `wave'"
    gen found_prev_hh_member_in_gap`wave' = " " * strlen(prev_hh_members`wave') if (missing(SHHADID`wave'))

    * This copies the flags we've found so far (from the next wave to this one) except of course we don't try to copy
    * anything into the final wave since there is no succeeding wave.
    if (`wave' < $final_wave) {
        local next_wave = `wave' + 1
        replace found_prev_hh_member_in_gap`wave' = found_prev_hh_member_in_gap`next_wave' if (missing(SHHADID`next_wave'))
    }

    forvalues my_hh_member_num = 1/`=overall_max_shhadid_members' {
        gen my_hh_member = word(prev_hh_members`wave', `my_hh_member_num') if (missing(SHHADID`wave'))
        replace my_hh_member = "X" if missing(my_hh_member)

        * position is computed only if there is a previous member to search for (my_hh_member != "X"),
        * respondent is missing this wave, and previous member is found somewhere in this wave (the strpos
        * looks for my_hh_member in ssuid_members).
        tempvar position
        gen `position' = strpos(prev_hh_members`wave', " " + my_hh_member + " ") if ((my_hh_member != "X") & (missing(SHHADID`wave')) & (strpos(ssuid_members`wave', " " + my_hh_member + " ") != 0))

        * Now if position is set we know we found the member and we know at what position in the string.  
        * Remember that we search for " 102 " when we want to find 102, so the position of the 1 in found_prev_hh_member_in_gap
        * is at the poistion of the first space of " 102 " in prev_hh_members.
        replace found_prev_hh_member_in_gap`wave' = substr(found_prev_hh_member_in_gap`wave', 1, `position' - 1) + "1" + substr(found_prev_hh_member_in_gap`wave', `position' + 1, .) if (!missing(`position'))
        drop my_hh_member
    }
}

********************************************************************************
** Function:  Compute flags indicating if each future household member is found anywhere during a contiguous
**           gap in which the respondent is missing.  The flags are encoded in found_future_hh_member_in_gap
**           in the same way as found_prev_hh_member in gap.  See above.
********************************************************************************

gen found_future_hh_member_in_gap$final_wave = ""
forvalues wave = $first_wave/$penultimate_wave {
    display "Wave `wave'"
    gen found_future_hh_member_in_gap`wave' = " " * strlen(future_hh_members`wave') if (missing(SHHADID`wave'))

    * Go ahead and copy what we've found so far (except at the first missing wave).
    if (`wave' > $first_wave) {
        local prev_wave = `wave' - 1
        replace found_future_hh_member_in_gap`wave' = found_future_hh_member_in_gap`prev_wave' if (missing(SHHADID`prev_wave'))
    }

    forvalues my_hh_member_num = 1/`=overall_max_shhadid_members' {
        gen my_hh_member = word(future_hh_members`wave', `my_hh_member_num') if (missing(SHHADID`wave'))
        replace my_hh_member = "X" if missing(my_hh_member)
        tempvar position
        gen `position' = strpos(future_hh_members`wave', " " + my_hh_member + " ") if ((my_hh_member != "X") & (missing(SHHADID`wave')) & (strpos(ssuid_members`wave', " " + my_hh_member + " ") != 0))
        replace found_future_hh_member_in_gap`wave' = substr(found_future_hh_member_in_gap`wave', 1, `position' - 1) + "1" + substr(found_future_hh_member_in_gap`wave', `position' + 1, .) if (!missing(`position'))
        drop my_hh_member
    }
}

********************************************************************************
** Purpose:  Compute composition change.  Outputs for each wave are:
**           comp_change, a flag indicating whether or not there is any composition change;
**           comp_change_reason, an indicator of why we believe there is a change;
**           leavers, a string containing the person numbers of those who leave from the child's perspective;
**          arrivers, a string containing the person numbers of those who arrive from the child's perspective;
**           stayers, a string containing the person numbers of those who stay from the child's perspective;

**           In general, changes are marked on the first of the two waves that differ.  Thus, when respondent
**           appears at age greater than 0, the change in marked in the wave before respondent appears.
**
** Logic:  The major cases are:
**         1) Respondent is present in adjacent waves.
**         2) Respondent's first appearance is after wave 1, but age is non-zero (non-birth).

**         For each possible case we compute a flag, comp_change_case, indicating whether or not this
**         observation satisfies the conditions to be such a case.  This is for convenience so we don't
**         have to replicate the complicated if condition throughout the code for this case.
**
**         For details about string manipulations and other fancy Stata use, see 
**=         "Some notes in implementation" in earlier comments in this file.
********************************************************************************

forvalues wave = $first_wave/$penultimate_wave {
    local next_wave = `wave' + 1

    display "Computing comp change for wave `wave'"

    *** Start by assuming this wave is not interesting.
    gen comp_change`wave' = .
    gen comp_change_reason`wave' = 0

	gen leavers`wave' = " "
    gen arrivers`wave' = " "
    gen stayers`wave' = " "


    ********************************************************************************
    ** Function:  Compute composition change when respondent is present in adjacent waves.
    ********************************************************************************

    *** If we have data in both waves, just compare HH members.
    replace comp_change`wave' = (shhadid_members`wave' != shhadid_members`next_wave') if ((!missing(SHHADID`wave')) & (!missing(SHHADID`next_wave')))
    replace comp_change_reason`wave' = comp_change_reason`wave' + 1 if ((shhadid_members`wave' != shhadid_members`next_wave') & (!missing(SHHADID`wave')) & (!missing(SHHADID`next_wave')))
    gen comp_change_case = ((shhadid_members`wave' != shhadid_members`next_wave') & (!missing(SHHADID`wave')) & (!missing(SHHADID`next_wave')))

    display "Computing comp change for waves with adjacent data"
    * Since we have adjacent data, you're a leaver if you're in this HH but not the next and a stayer otherwise.
    forvalues my_hh_member_num = 1/`=max_shhadid_members`wave'' {
        gen my_hh_member = word(shhadid_members`wave', `my_hh_member_num') if (comp_change_case == 1)
        * This is a bit lazy but prevents having to check for missing my_hh_member in all the places below, so overall it's easier to read.
        replace my_hh_member = "XXXX" if missing(my_hh_member)

        replace leavers`wave' = leavers`wave' + my_hh_member + " " if ((comp_change_case == 1) & (my_hh_member != "XXXX") & (strpos(shhadid_members`next_wave', " " + my_hh_member + " ") == 0))
        replace stayers`wave' = stayers`wave' + my_hh_member + " " if ((comp_change_case == 1) & (strpos(shhadid_members`next_wave', " " + my_hh_member + " ") != 0))

        drop my_hh_member
    }

    * Since we have adjacent data, you're an arriver if you're in the next HH but not this one.  We already took care of stayers.
    forvalues my_hh_member_num = 1/`=max_shhadid_members`next_wave'' {
        gen my_hh_member = word(shhadid_members`next_wave', `my_hh_member_num') if (comp_change_case == 1)
        replace my_hh_member = "XXXX" if missing(my_hh_member)

        replace arrivers`wave' = arrivers`wave' + my_hh_member + " " if ((comp_change_case == 1) & (my_hh_member != "XXXX") & (strpos(shhadid_members`wave', " " + my_hh_member + " ") == 0))

        drop my_hh_member
    }

    drop comp_change_case

    *******************************************************************************
    ** Purpose:  Compute composition change for respondent's first appearance when not a birth.
    **           The change is marked in this wave if the appearance is in the following wave,
    **           consistent with our choice of marking a change of state in the first wave of the two that differ.
    **
    **           Note that we propagate age and weight back from the wave in which respondent appears to the
    **           wave at which we mark the change.  This is necessary because there is no age and weight data
    **           in the wave where respondent is missing.  It's not ideal, but it's adequate.
    *******************************************************************************

    *** If next wave is ego's first and it's not a birth (age > 0), it's a change.
    * We also need to populate age and weight from the next wave since ego has no data in this wave.
    replace comp_change`wave' = 1 if ((`next_wave' == my_first_wave) & (adj_age`next_wave' > 0))
    replace comp_change_reason`wave' = comp_change_reason`wave' + 2 if ((`next_wave' == my_first_wave) & (adj_age`next_wave' > 0))
    gen comp_change_case = ((`next_wave' == my_first_wave) & (adj_age`next_wave' > 0))
    replace adj_age`wave' = adj_age`next_wave' if (comp_change_case == 1)
    replace WPFINWGT`wave' = WPFINWGT`next_wave' if (comp_change_case == 1)

    display "Computing comp change for non-child ego's first wave."
    * We look at the "gap" from first wave to this wave to see if anyone from the future HH shows up and set changes accordingly.
    * For anyone we see in the "gap" they arrive from our perspective.  Others we don't know so we assume we were already together.
    forvalues my_hh_member_num = 1/`=max_shhadid_members`next_wave'' {
        gen my_hh_member = word(shhadid_members`next_wave', `my_hh_member_num') if (comp_change_case == 1)
        * This is a bit lazy but prevents having to check for missing my_hh_member in all the places below, so overall it's easier to read.
        replace my_hh_member = "XXXX" if missing(my_hh_member)
        gen my_pos = strpos(future_hh_members`wave', " " + my_hh_member + " ") if (comp_change_case == 1)
        replace arrivers`wave' = arrivers`wave' + my_hh_member + " " if ((comp_change_case == 1) & (my_pos != 0) & (substr(found_future_hh_member_in_gap`wave', my_pos, 1) == "1"))
        drop my_pos

        drop my_hh_member
    }

    drop comp_change_case


    display "Computing comp change for ego moving from missing to present."
    *** If we are moving from a wave in which ego is missing to one in which ego is present
    * there is a composition change if we have seen any member of the future household in gap during which ego was missing.
    * Again, we also need to populate age and weight from the next wave since ego has no data in this wave.
    replace comp_change`wave' = 1 if ((missing(SHHADID`wave')) & (!missing(SHHADID`next_wave')) & (`next_wave' > my_first_wave) & (indexnot(found_future_hh_member_in_gap`wave', " ") != 0))
    replace comp_change_reason`wave' = comp_change_reason`wave' + 4 if ((missing(SHHADID`wave')) & (!missing(SHHADID`next_wave')) & (`next_wave' > my_first_wave) & (indexnot(found_future_hh_member_in_gap`wave', " ") != 0))
    gen comp_change_case = ((missing(SHHADID`wave')) & (!missing(SHHADID`next_wave')) & (`next_wave' > my_first_wave) & (indexnot(found_future_hh_member_in_gap`wave', " ") != 0))
    replace adj_age`wave' = adj_age`next_wave' if (comp_change_case == 1)
    replace WPFINWGT`wave' = WPFINWGT`next_wave' if (comp_change_case == 1)

    * For anyone we see in the "gap" they arrive from our perspective.  Others we don't know so we assume we were already together.
    forvalues my_hh_member_num = 1/`=max_shhadid_members`next_wave'' {
        gen my_hh_member = word(shhadid_members`next_wave', `my_hh_member_num') if (comp_change_case == 1)
        * This is a bit lazy but prevents having to check for missing my_hh_member in all the places below, so overall it's easier to read.
        replace my_hh_member = "XXXX" if missing(my_hh_member)
        gen my_pos = strpos(future_hh_members`wave', " " + my_hh_member + " ") if (comp_change_case == 1)
        replace arrivers`wave' = arrivers`wave' + my_hh_member + " " if ((comp_change_case == 1) & (my_pos != 0) & (substr(found_future_hh_member_in_gap`wave', my_pos, 1) == "1"))
        drop my_pos

        drop my_hh_member 
    } 
    drop comp_change_case


    display "Computing comp change for ego moving from present to missing."
    *** If we are moving from a wave in which ego is present to one in which ego is missing
    * there is a composition change if we have seen any member of the current household in gap 
    * during which ego is missing as we look forward.
    replace comp_change`wave' = 1 if ((!missing(SHHADID`wave')) & (missing(SHHADID`next_wave')) & (indexnot(found_prev_hh_member_in_gap`next_wave', " ") != 0))
    replace comp_change_reason`wave' = comp_change_reason`wave' + 8 if ((!missing(SHHADID`wave')) & (missing(SHHADID`next_wave')) & (indexnot(found_prev_hh_member_in_gap`next_wave', " ") != 0))
    gen comp_change_case = ((!missing(SHHADID`wave')) & (missing(SHHADID`next_wave')) & (indexnot(found_prev_hh_member_in_gap`next_wave', " ") != 0))

    * For anyone we see in the "gap" they depart from our perspective.  Others we don't know so we assume we stay together.
    forvalues my_hh_member_num = 1/`=max_shhadid_members`wave'' {
        gen my_hh_member = word(shhadid_members`wave', `my_hh_member_num') if (comp_change_case == 1)
        * This is a bit lazy but prevents having to check for missing my_hh_member in all the places below, so overall it's easier to read.
        replace my_hh_member = "XXXX" if missing(my_hh_member)
        gen my_pos = strpos(prev_hh_members`next_wave', " " + my_hh_member + " ") if (comp_change_case == 1)
        replace leavers`wave' = leavers`wave' + my_hh_member + " " if ((comp_change_case == 1) & (my_pos != 0) & (substr(found_prev_hh_member_in_gap`next_wave', my_pos, 1) == "1"))
        drop my_pos

        drop my_hh_member
    }

    drop comp_change_case



    display "Computing comp change for ego missing in a gap in which all past and future HH members are also missing."
    *** If we are moving from a wave in which ego is present to one in which ego is missing
    * and we do not see any member of the current household  or any member of the future
    * household in the gap looking forward,
    * we compare the current household to the future household as if we move into the
    * future household in the first missing wave unless there is no future HH
    * (ego's last appearance).
    replace comp_change`wave' = (shhadid_members`wave' != future_hh_members`next_wave') if ((!missing(SHHADID`wave')) & (missing(SHHADID`next_wave')) & (indexnot(future_hh_members`next_wave', " ") != 0) & (indexnot(found_prev_hh_member_in_gap`next_wave', " ") == 0) & (indexnot(found_future_hh_member_in_gap`next_wave', " ") == 0))
    replace comp_change_reason`wave' = comp_change_reason`wave' + 16 if ((shhadid_members`wave' != future_hh_members`next_wave') & (!missing(SHHADID`wave')) & (missing(SHHADID`next_wave')) & (indexnot(future_hh_members`next_wave', " ") != 0) & (indexnot(found_prev_hh_member_in_gap`next_wave', " ") == 0) & (indexnot(found_future_hh_member_in_gap`next_wave', " ") == 0))

    gen comp_change_case = ((shhadid_members`wave' != future_hh_members`next_wave') & (!missing(SHHADID`wave')) & (missing(SHHADID`next_wave')) & (indexnot(future_hh_members`next_wave', " ") != 0) & (indexnot(found_prev_hh_member_in_gap`next_wave', " ") == 0) & (indexnot(found_future_hh_member_in_gap`next_wave', " ") == 0))

    forvalues my_hh_member_num = 1/`=max_shhadid_members`wave'' {
        gen my_hh_member = word(shhadid_members`wave', `my_hh_member_num') if (comp_change_case == 1)
        * This is a bit lazy but prevents having to check for missing my_hh_member in all the places below, so overall it's easier to read.
        replace my_hh_member = "XXXX" if missing(my_hh_member)

        replace leavers`wave' = leavers`wave' + my_hh_member + " " if ((comp_change_case == 1) & (my_hh_member != "XXXX") & (strpos(future_hh_members`next_wave', " " + my_hh_member + " ") == 0))
        replace stayers`wave' = stayers`wave' + my_hh_member + " " if ((comp_change_case == 1) & (strpos(future_hh_members`next_wave', " " + my_hh_member + " ") != 0))

        drop my_hh_member
    }

    forvalues my_hh_member_num = 1/`=overall_max_shhadid_members' {
        gen my_hh_member = word(future_hh_members`next_wave', `my_hh_member_num') if (comp_change_case == 1)
        replace my_hh_member = "XXXX" if missing(my_hh_member)

        replace arrivers`wave' = arrivers`wave' + my_hh_member + " " if ((comp_change_case == 1) & (my_hh_member != "XXXX") & (strpos(shhadid_members`wave', " " + my_hh_member + " ") == 0))

        drop my_hh_member
    }



    * Add zeros for comp_change if needed.  We need to confirm this is what we want.  We set to zero if comp_change and ego was present this wave and this is not ego's last wave.
    replace comp_change`wave' = 0 if (missing(comp_change`wave') & (!missing(SHHADID`wave') & (`wave' != my_last_wave)))

    label values comp_change_reason`wave' comp_change_reason
	
	drop comp_change_case
}

keep SSUID EPPPNUM SHHADID* arrivers* leavers* stayers* comp_change* comp_change_reason* adj_age* 

save "$tempdir/hh_change_for_relationships", $replace


*** TODO:  Fix bugs:
* Omit self from lists of stayers, arrivers, leavers.
* Catch the arrival case in #19.  Make sure thiw was computed correctly in hh_change -- and why?
* Catch similar cases when people show up in the gap.
* Make sure the flags for who shows up in the gap are correct.
* There seeem to be a bunch of temp variables in the dataset.  Get rid of them.  How are they still there???

*** TODO:  Check data.
* One thing in particular is getting the same person in a set twice.
* Basic correctness, too.
* Make sure we never do a bogus comparison against the "" in first wave and last wave for prev and future, respectively.
