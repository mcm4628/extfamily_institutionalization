*** Fix up age so the waves are consistent with each other.

*** TODO:  Document our decisions.

use "$tempdir/person_wide"

gen num_child_ages = 0
gen num_adult_ages = 0
forvalues wave = $first_wave/$final_wave {
    replace num_child_ages = num_child_ages + 1 if (!missing(TAGE`wave') & (TAGE`wave' < $adult_age))
    replace num_adult_ages = num_adult_ages + 1 if (!missing(TAGE`wave') & (TAGE`wave' >= $adult_age))
}

count if (num_adult_ages == 0)
count if (num_child_ages == 0)


gen num_zero_ages = 0
gen num_one_ages = 0
forvalues wave = $first_wave/$final_wave {
    replace num_zero_ages = num_zero_ages + 1 if (TAGE`wave' == 0)
    replace num_one_ages = num_one_ages + 1 if (TAGE`wave' == 1)
}
tab num_zero_ages
tab num_one_ages
tab num_zero_ages num_one_ages

gen max_age = TAGE$first_wave
gen min_age = TAGE$first_wave
gen regressing_zero_ages = 0
gen regressing_one_ages = 0
gen regressing_17_ages = 0
gen regressing_age = 0
gen regressing_adult_to_child = 0
forvalues wave = $second_wave/$final_wave {
    replace max_age = TAGE`wave' if (missing(max_age) | (!missing(TAGE`wave') & (TAGE`wave' > max_age)))
    replace regressing_age = 1 if ((!missing(TAGE`wave') & (TAGE`wave' < min_age)))
    replace min_age = TAGE`wave' if (missing(min_age) | (!missing(TAGE`wave') & (TAGE`wave' < min_age)))
    replace regressing_zero_ages = regressing_zero_ages + 1 if ((TAGE`wave' == 0) & (max_age > 0))
    replace regressing_one_ages = regressing_one_ages + 1 if ((TAGE`wave' == 1) & (max_age > 1))
    replace regressing_17_ages = regressing_17_ages + 1 if ((TAGE`wave' == 17) & (max_age > 17))
    replace regressing_adult_to_child = regressing_adult_to_child + 1 if ((TAGE`wave' < $adult_age) & (max_age >= $adult_age))
}
tab regressing_zero_ages
tab regressing_one_ages
tab regressing_17_ages
tab regressing_age
tab regressing_adult_to_child
tab regressing_zero_ages regressing_one_ages

gen curr_age = TAGE$first_wave
gen regressing_zero_ages_v2 = 0
gen regressing_one_ages_v2 = 0
gen regressing_17_ages_v2 = 0
gen regressing_one_to_zero = 0
gen regressing_to_zero = 0
forvalues wave = $second_wave/$final_wave {
    replace regressing_zero_ages_v2 = regressing_zero_ages_v2 + 1 if ((TAGE`wave' == 0) & (!missing(curr_age)) & (curr_age > 0))
    replace regressing_one_ages_v2 = regressing_one_ages_v2 + 1 if ((TAGE`wave' == 1) & (!missing(curr_age)) & (curr_age > 1))
    replace regressing_17_ages_v2 = regressing_17_ages_v2 + 1 if ((TAGE`wave' == 17) & (!missing(curr_age)) & (curr_age > 17))
    replace regressing_one_to_zero = regressing_one_to_zero + 1 if ((TAGE`wave' == 0) & (!missing(curr_age)) & (curr_age == 1))
    replace regressing_to_zero = regressing_to_zero + 1 if ((TAGE`wave' == 0) & (!missing(curr_age)) & (curr_age > 0))
    replace curr_age = TAGE`wave' if (!missing(TAGE`wave'))
}
drop curr_age

tab regressing_zero_ages_v2
tab regressing_one_ages_v2
tab regressing_17_ages_v2
tab regressing_one_to_zero
tab regressing_to_zero
tab regressing_zero_ages_v2 regressing_one_ages_v2

tab regressing_zero_ages regressing_zero_ages_v2
tab regressing_one_ages regressing_one_ages_v2
tab regressing_17_ages regressing_17_ages_v2

display "Mostly adult"
count if (num_child_ages == 1) & (num_adult_ages > 1)
tab min_age if (num_child_ages == 1) & (num_adult_ages > 1)

display "One adult, one child"
count if (num_child_ages == 1) & (num_adult_ages == 1)
tab min_age if (num_child_ages == 1) & (num_adult_ages == 1)
tab max_age if (num_child_ages == 1) & (num_adult_ages == 1)
tab min_age max_age if (num_child_ages == 1) & (num_adult_ages == 1)

display "Suspect age reporting"
count if (max_age - min_age > 5)
count if (max_age - min_age > 5) & (num_child_ages > 0)
count if (max_age - min_age > 10)
count if (max_age - min_age > 10) & (num_child_ages > 0)

display "Birth with adult age"
count if (min_age == 0) & (max_age > 17)

display "Suspect birth"
count if (min_age == 0) & (max_age > 7)


*** Do a simple forward-looking check of reasonable age progression.
gen curr_age = TAGE$first_wave
gen first_age = 1 if (!missing(curr_age))
gen long_run = 0
gen short_run = 0
gen unexpected_age = 0
gen num_curr_age = 0
replace num_curr_age = 1 if (!missing(curr_age))
forvalues wave = $second_wave/$final_wave {
    * Mark short runs (less than three).
    replace short_run = 1 if ((first_age == 0) & (!missing(TAGE`wave')) & (TAGE`wave' != curr_age) & (num_curr_age < 3))

    * Count runs of age and flag long ones (more than three).
    replace num_curr_age = num_curr_age + 1 if ((!missing(TAGE`wave')) & (TAGE`wave' == curr_age))
    replace num_curr_age = 1 if ((!missing(TAGE`wave')) & (TAGE`wave' != curr_age))
    replace long_run = 1 if (num_curr_age > 3)

    * If age is missing, count as if it were as expected and increment age when we see the fourth.
    replace num_curr_age = num_curr_age + 1 if ((num_curr_age > 0) & (missing(TAGE`wave')))
    replace curr_age = curr_age + 1 if ((num_curr_age > 3) & (missing(TAGE`wave')))
    replace num_curr_age = 1 if ((num_curr_age > 3) & (missing(TAGE`wave')))

    * Mark ages that jump more than one year or regress.
    replace unexpected_age = 1 if ((!missing(TAGE`wave')) & (!missing(curr_age)) & ((TAGE`wave' < curr_age) | (TAGE`wave' > curr_age + 1)))

    replace first_age = 0 if ((first_age == 1) & (!missing(TAGE`wave')) & (TAGE`wave' != curr_age))
    replace first_age = 1 if ((missing(first_age)) & (!missing(TAGE`wave')))
    replace curr_age = TAGE`wave' if (!missing(TAGE`wave'))
}
drop first_age curr_age num_curr_age

tab long_run
tab long_run if num_child_ages > 0
tab short_run
tab short_run if num_child_ages > 0
tab unexpected_age
tab unexpected_age if num_child_ages > 0


*** Do a simple backward-looking check of reasonable age progression.
gen curr_age = TAGE$final_wave
gen first_age = 1 if (!missing(curr_age))
gen long_run_rev = 0
gen short_run_rev = 0
gen unexpected_age_rev = 0
gen num_curr_age = 0
replace num_curr_age = 1 if (!missing(curr_age))
forvalues wave = $penultimate_wave (-1) $first_wave {
    * Mark short runs (less than three).
    replace short_run_rev = 1 if ((first_age == 0) & (!missing(TAGE`wave')) & (TAGE`wave' != curr_age) & (num_curr_age < 3))

    * Count runs of age and flag long ones (more than three).
    replace num_curr_age = num_curr_age + 1 if ((!missing(TAGE`wave')) & (TAGE`wave' == curr_age))
    replace num_curr_age = 1 if ((!missing(TAGE`wave')) & (TAGE`wave' != curr_age))
    replace long_run_rev = 1 if (num_curr_age > 3)

    * If age is missing, count as if it were as expected and decrement age when we see the fourth.
    replace num_curr_age = num_curr_age + 1 if ((num_curr_age > 0) & (missing(TAGE`wave')))
    replace curr_age = curr_age - 1 if ((num_curr_age > 3) & (missing(TAGE`wave')))
    replace num_curr_age = 1 if ((num_curr_age > 3) & (missing(TAGE`wave')))

    * Mark ages that jump more than one year or regress.
    replace unexpected_age_rev = 1 if ((!missing(TAGE`wave')) & (!missing(curr_age)) & ((TAGE`wave' > curr_age) | (TAGE`wave' < curr_age - 1)))

    replace first_age = 0 if ((first_age == 1) & (!missing(TAGE`wave')) & (TAGE`wave' != curr_age))
    replace first_age = 1 if ((missing(first_age)) & (!missing(TAGE`wave')))
    replace curr_age = TAGE`wave' if (!missing(TAGE`wave'))
}
drop first_age curr_age num_curr_age

tab long_run_rev
tab long_run_rev if num_child_ages > 0
tab short_run_rev
tab short_run_rev if num_child_ages > 0
tab unexpected_age_rev
tab unexpected_age_rev if num_child_ages > 0


*** Do a simple check for expected age progression.
gen min_expected_age = TAGE$first_wave
gen max_expected_age = min_expected_age + 1 if !missing(min_expected_age)
gen bad_age = 0

forvalues wave = $second_wave/$final_wave {
    replace min_expected_age = min_expected_age + 1.0 / 3.0 if !missing(min_expected_age)
    replace min_expected_age = TAGE`wave' if (missing(min_expected_age) & !missing(TAGE`wave'))
    replace max_expected_age = min_expected_age + 1 if !missing(min_expected_age)
    replace bad_age = 1 if (!missing(TAGE`wave') & ((TAGE`wave' < int(min_expected_age)) | (TAGE`wave' > int(max_expected_age))))
}
tab bad_age
tab bad_age if num_child_ages > 0


#delim ;
gen age_class = (regressing_age == 1) + 
    (regressing_zero_ages > 0) * 2 + 
    (regressing_one_ages > 0) * 4 + 
    (regressing_17_ages > 0) * 8 + 
    (regressing_adult_to_child > 0) * 16 + 
    (regressing_zero_ages_v2 > 0) * 32 + 
    (regressing_one_ages_v2 > 0) * 64 + 
    (regressing_17_ages_v2 > 0) * 128 + 
    (regressing_one_to_zero > 0) * 256 + 
    (regressing_to_zero > 0) * 512 + 
    (long_run == 1) * 1024 + 
    (short_run == 1) * 2048 + 
    (unexpected_age == 1) * 4096 + 
    (long_run_rev == 1) * 8192 + 
    (short_run_rev == 1) * 16384 + 
    (unexpected_age_rev == 1) * 32768 + 
    (bad_age == 1) * 65536
    ;
#delim cr

tab age_class
tab age_class if (num_child_ages > 0)


*** Lists that may be useful.
list TAGE* if num_zero_ages > 3, nolabel
list TAGE* if num_one_ages > 3, nolabel
list TAGE* if regressing_zero_ages > 0, nolabel
list TAGE* if regressing_one_ages > 0, nolabel
list TAGE* if (regressing_one_ages > 0) & (regressing_one_ages_v2 == 0), nolabel
list TAGE* if regressing_one_to_zero > 0, nolabel
list TAGE* if regressing_zero_ages > 0, nolabel
list TAGE* if regressing_17_ages > 0, nolabel
list TAGE* if regressing_age > 0, nolabel
list TAGE* if (regressing_age > 0) & (num_child_ages > 0), nolabel
list TAGE* if regressing_adult_to_child > 0, nolabel
list TAGE* if (num_child_ages == 1) & (num_adult_ages > 1) & (min_age < 17), nolabel
list TAGE* if (num_child_ages == 1) & (num_adult_ages > 1) & (min_age == 17), nolabel
list TAGE* if (max_age - min_age > 10) & (num_child_ages > 0), nolabel
list TAGE* if (min_age == 0) & (max_age > 17), nolabel
list TAGE* if (min_age == 0) & (max_age > 7), nolabel
list TAGE* if (long_run > 0) & (num_child_ages > 0), nolabel
list TAGE* if (short_run > 0) & (num_child_ages > 0), nolabel
list TAGE* if (unexpected_age > 0) & (num_child_ages > 0), nolabel
list TAGE* if (long_run_rev > 0) & (num_child_ages > 0), nolabel
list TAGE* if (short_run_rev > 0) & (num_child_ages > 0), nolabel
list TAGE* if (unexpected_age_rev > 0) & (num_child_ages > 0), nolabel


save "$tempdir/check_age_more_debug", $replace

drop bad_age
drop unexpected_age unexpected_age_rev
drop age_class
drop long_run long_run_rev short_run short_run_rev
drop min_age max_age min_expected_age max_expected_age
drop num_zero_ages num_one_ages
drop regressing*



*** We sometimes need to know if this person ever reports a zero age.
gen has_zero_age = 0
forvalues wave = $first_wave/$final_wave {
    replace has_zero_age = 1 if (TAGE`wave' == 0)
}



gen record_disposition = .

*** We'll take anyone who is always an adult, regardless of oddness in age sequence.
gen good_record = 1 if (num_child_ages == 0)
replace record_disposition = 1 if (num_child_ages == 0)

count if (good_record == 1)


*** We'll take anyone who always reports as a child and never reports age 0.
* Later we'll accept children for whom the zero age report makes sense.
replace record_disposition = 2 if (missing(good_record) & (num_adult_ages == 0) & (has_zero_age == 0))
replace good_record = 1 if ((num_adult_ages == 0) & (has_zero_age == 0))

count if (good_record == 1)


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


* Here's the bit for the backward projection.
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


*** 
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

replace record_disposition = 3 if (missing(good_record) & (both_match_all_good == 1))
replace good_record = 1 if (both_match_all_good == 1)
count if (good_record == 1)

replace record_disposition = 4 if (missing(good_record) & (fwd_match_all_good == 1))
replace good_record = 1 if (fwd_match_all_good == 1)
count if (good_record == 1)

replace record_disposition = 5 if (missing(good_record) & (bkwd_match_all_good == 1))
replace good_record = 1 if (bkwd_match_all_good == 1)
count if (good_record == 1)

replace record_disposition = 6 if (missing(good_record) & (bkwd_match_good_leading_zero == 1) & (num_child_ages + num_adult_ages >= 4))
replace good_record = 1 if ((bkwd_match_good_leading_zero == 1) & (num_child_ages + num_adult_ages >= 4))
count if (good_record == 1)

replace record_disposition = 7 if (missing(good_record) & (bkwd_match_good_leading_zero == 1) & (num_child_ages + num_adult_ages >= 3))
replace good_record = 1 if ((bkwd_match_good_leading_zero == 1) & (num_child_ages + num_adult_ages >= 3))
count if (good_record == 1)

replace record_disposition = 15 if (missing(good_record) & (bkwd_match_good_leading_nz == 1) & (num_child_ages + num_adult_ages >= 3))
replace good_record = 1 if ((bkwd_match_good_leading_nz == 1) & (num_child_ages + num_adult_ages >= 3))
count if (good_record == 1)


*** Now fix up ages when the age is out of line but the projected ages are close to each other.
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


*** 
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


replace record_disposition = 9 if (missing(good_record) & (adjboth_match_all_good == 1))
replace good_record = 1 if (adjboth_match_all_good == 1)
count if (good_record == 1)

replace record_disposition = 10 if (missing(good_record) & (adjfwd_match_all_good == 1))
replace good_record = 1 if (adjfwd_match_all_good == 1)
count if (good_record == 1)

replace record_disposition = 11 if (missing(good_record) & (adjbkwd_match_all_good == 1))
replace good_record = 1 if (adjbkwd_match_all_good == 1)
count if (good_record == 1)

replace record_disposition = 12 if (missing(good_record) & (adjbkwd_match_good_leading_zero == 1) & (num_child_ages + num_adult_ages >= 4))
replace good_record = 1 if ((adjbkwd_match_good_leading_zero == 1) & (num_child_ages + num_adult_ages >= 4))
count if (good_record == 1)

replace record_disposition = 13 if (missing(good_record) & (adjbkwd_match_good_leading_zero == 1) & (num_child_ages + num_adult_ages >= 3))
replace good_record = 1 if ((adjbkwd_match_good_leading_zero == 1) & (num_child_ages + num_adult_ages >= 3))
count if (good_record == 1)

replace record_disposition = 16 if (missing(good_record) & (adjbkwd_match_good_leading_nz == 1) & (num_child_ages + num_adult_ages >= 3))
replace good_record = 1 if ((adjbkwd_match_good_leading_nz == 1) & (num_child_ages + num_adult_ages >= 3))
count if (good_record == 1)


*** Deal with people who have only one child age and only one adult age.  Make them adult.
* Note than any such sets of consistent ages have already been marked good so we don't adjust them.
forvalues wave = $first_wave/$final_wave {
    replace record_disposition = 17 if (missing(good_record) & (num_child_ages == 1) & (num_adult_ages == 1) & (adj_age`wave' < $adult_age))
    replace adj_age`wave' = 999 if (missing(good_record) & (num_child_ages == 1) & (num_adult_ages == 1) & (adj_age`wave' < $adult_age))
}
replace good_record = 1 if (record_disposition == 17)


*** Need stats sepcific to child ages and adult ages.
* Also on whether the ages monotonically increase.
gen last_child_age = $first_wave if ((!missing(adj_age$first_wave)) & (adj_age$first_wave < $adult_age))
gen first_adult_age = $first_wave if ((!missing(adj_age$first_wave)) & (adj_age$first_wave >= $adult_age))

gen max_child_age = adj_age$first_wave if ((!missing(adj_age$first_wave)) & (adj_age$first_wave < $adult_age))
gen min_child_age = adj_age$first_wave if ((!missing(adj_age$first_wave)) & (adj_age$first_wave < $adult_age))
gen max_adult_age = adj_age$first_wave if ((!missing(adj_age$first_wave)) & (adj_age$first_wave >= $adult_age))
gen min_adult_age = adj_age$first_wave if ((!missing(adj_age$first_wave)) & (adj_age$first_wave >= $adult_age))
gen monotonic = 1
gen curr_age = adj_age$first_wave
forvalues wave = $second_wave/$final_wave {
    replace last_child_age = `wave' if (!missing(adj_age`wave')  & (adj_age`wave' < $adult_age))
    replace first_adult_age = `wave' if (missing(first_adult_age) & (!missing(adj_age`wave')) & (adj_age`wave' >= $adult_age))

    replace max_child_age = adj_age`wave' if ((!missing(adj_age`wave') & (adj_age`wave' < $adult_age)) & ((adj_age`wave' > max_child_age) | (missing(max_child_age))))
    replace min_child_age = adj_age`wave' if ((!missing(adj_age`wave') & (adj_age`wave' < $adult_age)) & ((adj_age`wave' < min_child_age) | (missing(min_child_age))))
    replace max_adult_age = adj_age`wave' if ((!missing(adj_age`wave') & (adj_age`wave' >= $adult_age)) & ((adj_age`wave' > max_adult_age) | (missing(max_adult_age))))
    replace min_adult_age = adj_age`wave' if ((!missing(adj_age`wave') & (adj_age`wave' >= $adult_age)) & ((adj_age`wave' < min_adult_age) | (missing(min_adult_age))))
    replace monotonic = 0 if ((!missing(adj_age`wave')) & (!missing(curr_age)) & (adj_age`wave' < curr_age))
    replace curr_age = adj_age`wave' if (!missing(adj_age`wave'))
}
drop curr_age


*** Now mark any 17-18 transitions that have all monotonically increasing ages.
* This isn't actually what I meant to do.  But there's no great reason to remove it.
replace record_disposition = 18 if (missing(good_record) & (monotonic == 1) & (max_child_age == 17) & (min_adult_age == 18))
replace good_record = 1 if ((monotonic == 1) & (max_child_age == 17) & (min_adult_age == 18))
count if (good_record == 1)


*** Do what I meant to do.  Take anything with a 17-18 transition where all ages to the left are
* child ages and all ages to the right are adult ages.
replace record_disposition = 19 if (missing(good_record) & (max_child_age >= 16) & (min_adult_age <= 19) & (last_child_age < first_adult_age))
replace good_record = 1 if ((max_child_age >= 16) & (min_adult_age <= 19) & (last_child_age < first_adult_age))
count if (good_record == 1)



count if (good_record != 1)

#delimit ;
label define record_disposition
    1 "always adult"
    2 "always child with no zero"
    3 "both age projections"
    4 "forward age projection"
    5 "backward age projection"
    6 "leading zero >= 4 ages"
    7 "leading zero >= 3 ages"
    9 "both adj age projections"
   10 "forward adj age projection"
   11 "backward adj age projection"
   12 "leading zero >= 4 adj ages"
   13 "leading zero >= 3 adj ages"
   15 "leading non-zero >= 3 ages"
   16 "leading non-zero >= 3 adj ages"
   17 "one adult one child"
   18 "monotonic 17-18"
   19 "17-18 child-adult"
    ;
#delimit cr

label values record_disposition record_disposition

tab record_disposition, m
tab record_disposition if (missing(good_record)) , m

set linesize 250
list adj_age* if missing(record_disposition) & num_adult_ages + num_child_ages > 10, nolabel
list adj_age* if missing(record_disposition) & num_adult_ages + num_child_ages <= 10, nolabel


tab num_child_ages num_adult_ages if (missing(good_record))

forvalues i = 2/15 {
    list adj_age* if missing(record_disposition) & (num_adult_ages + num_child_ages == `i'), nolabel
}

save "$tempdir/person_wide_adjusted_ages_debug", $replace

drop expected_age_bkwd* expected_age_fwd*
drop adjbkwd* adjfwd*
drop bkwd* fwd*
drop both_match_all_good
drop last_child_age first_adult_age
drop good_record
drop adjboth_match_all_good
drop has_zero_age
drop min_adult_age max_adult_age min_child_age max_child_age
drop monotonic
drop num_adjbkwd_matches num_adjfwd_matches num_bkwd_matches num_fwd_matches
drop record_disposition
drop TAGE*

save "$tempdir/person_wide_adjusted_ages", $replace

keep SSUID EPPPNUM adj_age*
reshape long adj_age, i(SSUID EPPPNUM) j(SWAVE)
save "$tempdir/adjusted_ages_long", $replace
