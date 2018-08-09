//========================================================================================================================//
//=================== Children's Household Instability Project                    ========================================//
//=================== Dataset: SIPP2008                                           ========================================//
//=================== Purpose: This file fixes up age so the waves are consistent ========================================//
//========================================================================================================================//
use "$tempdir/person_wide"

gen num_ages = 0
forvalues wave = $first_wave/$final_wave {
    replace num_ages = num_ages + 1 if (!missing(TAGE`wave'))
}

*** We sometimes need to know if this person ever reports a zero age.
gen has_zero_age = 0
forvalues wave = $first_wave/$final_wave {
    replace has_zero_age = 1 if (TAGE`wave' == 0)
}

* Generate variables indicating numbers of waves observed at adult/child ages
gen num_child_ages = 0
gen num_adult_ages = 0
forvalues wave = $first_wave/$final_wave {
    replace num_child_ages = num_child_ages + 1 if (!missing(TAGE`wave') & (TAGE`wave' < $adult_age))
    replace num_adult_ages = num_adult_ages + 1 if (!missing(TAGE`wave') & (TAGE`wave' >= $adult_age))
} 

******************************************************************************
*Function: create expected age variables based on age at first observation and 
*          aging the person one year every 3 observations or based on last observation
*          and decrementing one year every 3 observations 
******************************************************************************

*** We make a simple projection of expected age from the first reported age
* and from the last reported age.  
gen expected_age_fwd = TAGE$first_wave
gen expected_age_fwd$first_wave = expected_age_fwd
gen num_curr_age = 0
replace num_curr_age = 1 if (!missing(expected_age_fwd))
forvalues wave = $second_wave/$final_wave {
    * Increment counter of age runs if we have established an age.
    * Set the counter to 1 if we are just now establishing an age.
    replace num_curr_age = num_curr_age + 1 if (!missing(expected_age_fwd))
    replace num_curr_age = 1 if ((!missing(TAGE`wave')) & (missing(expected_age_fwd)))
    replace expected_age_fwd = TAGE`wave' if ((!missing(TAGE`wave')) & (missing(expected_age_fwd)))

    * Increment the age if we've already used it three times.
    replace expected_age_fwd = expected_age_fwd + 1 if (num_curr_age > 3)
    replace num_curr_age = 1 if (num_curr_age > 3)

    gen expected_age_fwd`wave' = expected_age_fwd
}
drop num_curr_age expected_age_fwd


* backward projection.
gen expected_age_bkwd = TAGE$final_wave
gen expected_age_bkwd$final_wave = expected_age_bkwd
gen num_curr_age = 0
replace num_curr_age = 1 if (!missing(expected_age_bkwd))
forvalues wave = $penultimate_wave (-1) $first_wave {
    * Increment counter of age runs if we have established an age.
    * Set the counter to 1 if we are just now establishing an age.
    replace num_curr_age = num_curr_age + 1 if (!missing(expected_age_bkwd))
    replace num_curr_age = 1 if ((!missing(TAGE`wave')) & (missing(expected_age_bkwd)))
    replace expected_age_bkwd = TAGE`wave' if ((!missing(TAGE`wave')) & (missing(expected_age_bkwd)))

    * Decrement the age if we've already used it three times.
    replace expected_age_bkwd = expected_age_bkwd - 1 if (num_curr_age > 3)
    replace num_curr_age = 1 if (num_curr_age > 3)

    gen expected_age_bkwd`wave' = expected_age_bkwd
}
drop num_curr_age expected_age_bkwd

********************************************************************************
* Function: Check backwards and forwards projections against what is coded
********************************************************************************

*** Count the number of times age matches each projection (within one, in the correct direction).
gen num_fwd_matches = 0
gen num_bkwd_matches = 0
forvalues wave = $first_wave/$final_wave {
    gen fwd_match`wave' = ((!missing(TAGE`wave')) & (TAGE`wave' >= expected_age_fwd`wave') & (TAGE`wave' <= expected_age_fwd`wave' + 1))
    replace num_fwd_matches = num_fwd_matches + 1 if (fwd_match`wave' == 1)
    gen bkwd_match`wave' = ((!missing(TAGE`wave')) & (TAGE`wave' <= expected_age_bkwd`wave') & (TAGE`wave' >= expected_age_bkwd`wave' - 1))
    replace num_bkwd_matches = num_bkwd_matches + 1 if (bkwd_match`wave' == 1)
}

*** TODO:  Probably here but not sure.
* TODO:  For #adult == 1 & #child == 1 & not matching the projected age, set child-age to 999.
* TODO:  Be sure we're not taking first age replacement with too little evidence (too few ages).
* TODO:  If all child on left, all adult on right and 17-18 transition and no 0 age, just take it as is.

*******************************************************************************
*  Function: Check whether projections match recorded values +/- 1
*           In 124,138 cases of 130,851 they do
*******************************************************************************
gen fwd_match_all_good = 1
gen bkwd_match_all_good = 1
gen both_match_all_good = 1
gen bkwd_match_good_leading_zero = 0
gen bkwd_match_good_leading_nz = 0
forvalues wave = $first_wave/$final_wave {
    replace fwd_match_all_good = 0 if ((!missing(TAGE`wave')) & (fwd_match`wave' != 1))

}
forvalues wave = $final_wave (-1) $first_wave {
    replace bkwd_match_good_leading_zero = 1 if ((bkwd_match_all_good == 1) & (my_first_wave == `wave') & (TAGE`wave' == 0))
    replace bkwd_match_good_leading_nz = 1 if ((bkwd_match_all_good == 1) & (my_first_wave == `wave') & (TAGE`wave' != 0))

    replace bkwd_match_all_good = 0 if ((!missing(TAGE`wave')) & (bkwd_match`wave' != 1))
    replace both_match_all_good = 0 if ((!missing(TAGE`wave')) & ((bkwd_match`wave' != 1) | (fwd_match`wave' != 1)))

}
tab fwd_match_all_good bkwd_match_all_good

********************************************************************************
* Function: adjust age to projection if backwards and forwards projection are within 1
********************************************************************************

gen adj_age$first_wave = TAGE$first_wave
forvalues wave = $second_wave/$final_wave {
    gen adj_age`wave' = TAGE`wave'
    replace adj_age`wave' = expected_age_fwd`wave' if ((!missing(TAGE`wave')) & (fwd_match`wave' == 0) & (bkwd_match`wave' == 0) & (abs(expected_age_fwd`wave' - expected_age_bkwd`wave') <= 1))
}

*** Count the number of times adjusted age matches each projection (within one, in the correct direction).
gen num_adjfwd_matches = 0
gen num_adjbkwd_matches = 0
forvalues wave = $first_wave/$final_wave {
    gen adjfwd_match`wave' = ((!missing(adj_age`wave')) & (adj_age`wave' >= expected_age_fwd`wave') & (adj_age`wave' <= expected_age_fwd`wave' + 1))
    replace num_adjfwd_matches = num_adjfwd_matches + 1 if (adjfwd_match`wave' == 1)
    gen adjbkwd_match`wave' = ((!missing(adj_age`wave')) & (adj_age`wave' <= expected_age_bkwd`wave') & (adj_age`wave' >= expected_age_bkwd`wave' - 1))
    replace num_adjbkwd_matches = num_adjbkwd_matches + 1 if (adjbkwd_match`wave' == 1)
}

*******************************************************************************
*  Function: Check whether after adjustment projections match recorded values +/- 1
*           In 124,581 cases of 130,851 they do (6270 still off)
*******************************************************************************
gen adjfwd_match_all_good = 1
gen adjbkwd_match_all_good = 1
gen adjboth_match_all_good = 1
gen adjbkwd_match_good_leading_zero = 0
gen adjbkwd_match_good_leading_nz = 0
forvalues wave = $first_wave/$final_wave {
    replace adjfwd_match_all_good = 0 if ((!missing(adj_age`wave')) & (adjfwd_match`wave' != 1))
}
forvalues wave = $final_wave (-1) $first_wave {
    replace adjbkwd_match_good_leading_zero = 1 if ((adjbkwd_match_all_good == 1) & (my_first_wave == `wave') & (adj_age`wave' == 0))
    replace adjbkwd_match_good_leading_nz = 1 if ((adjbkwd_match_all_good == 1) & (my_first_wave == `wave') & (adj_age`wave' != 0))

    replace adjbkwd_match_all_good = 0 if ((!missing(adj_age`wave')) & (adjbkwd_match`wave' != 1))
    replace adjboth_match_all_good = 0 if ((!missing(adj_age`wave')) & ((adjbkwd_match`wave' != 1) | (adjfwd_match`wave' != 1)))
}

tab adjfwd_match_all_good adjbkwd_match_all_good

gen stillbad=0
replace stillbad=1 if adjfwd_match_all_good !=1 | adjbkwd_match_all_good !=1

gen monotonic = 1
gen curr_age = adj_age$first_wave
forvalues wave = $second_wave/$final_wave {
    replace monotonic = 0 if ((!missing(adj_age`wave')) & (!missing(curr_age)) & (adj_age`wave' < curr_age))
    replace curr_age = adj_age`wave' if (!missing(adj_age`wave'))
}

tab monotonic stillbad

tab num_ages if stillbad==1

drop curr_age
drop expected_age_bkwd* expected_age_fwd*
drop adjbkwd* adjfwd*
drop bkwd* fwd*
drop both_match_all_good
drop adjboth_match_all_good
drop has_zero_age
drop monotonic
drop num_adjbkwd_matches num_adjfwd_matches 
drop TAGE*



save "$tempdir/person_wide_adjusted_ages", $replace

keep SSUID EPPPNUM adj_age*
reshape long adj_age, i(SSUID EPPPNUM) j(SWAVE)

label variable adj_age "Adjusted Age"
save "$tempdir/adjusted_ages_long", $replace
