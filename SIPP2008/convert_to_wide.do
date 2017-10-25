*** Now generate a wide dataset by person (SSUID EPPPNUM),
*** and generate variables indicating the first and last
*** wave numbers in which this person is encountered.

*** Also, generate a normalized variable for race and sex,
*** in other words, generate a single value we'll use for
*** the individual even though for some people reports vary
*** across waves.


use "$tempdir/allwaves"

merge m:1 SSUID SHHADID SWAVE using "$tempdir/shhadid_members"
assert _merge == 3
drop _merge


*** Now get mom and dad education.  We'll just merge in all waves
* and sort out our definition of parents' education later.
recode EPNMOM (9999 = .), gen(educ_epppnum)
merge m:1 SSUID educ_epppnum SWAVE using "$tempdir/person_educ"
assert missing(educ_epppnum) if (_merge == 1)
drop if _merge == 2
drop _merge

drop educ_epppnum
rename educ mom_educ

* And now dad
recode EPNDAD (9999 = .), gen(educ_epppnum)
merge m:1 SSUID educ_epppnum SWAVE using "$tempdir/person_educ"
assert missing(educ_epppnum) if (_merge == 1)
drop if _merge == 2
drop _merge

drop educ_epppnum
rename educ dad_educ


*** Now get mom's immigrant status.
recode EPNMOM (9999 = .), gen(immigrant_epppnum)
merge m:1 SSUID immigrant_epppnum SWAVE using "$tempdir/person_immigrant"
assert missing(immigrant_epppnum) if (_merge == 1)
drop if _merge == 2
drop _merge

drop immigrant_epppnum
rename immigrant mom_immigrant


*** Make it wide.
local i_vars "SSUID EPPPNUM"
local j_vars "SWAVE"
local wide_vars "SHHADID EPNMOM EPNDAD ETYPMOM ETYPDAD EPNSPOUS TAGE EMS ERRP WPFINWGT ERACE ESEX EORIGIN EBORNUS mom_educ dad_educ mom_immigrant shhadid_member_ages shhadid_members max_shhadid_members shhadid_adults max_shhadid_adults shhadid_children max_shhadid_children"
local extra_vars "overall_max_shhadid_members overall_max_shhadid_adults overall_max_shhadid_children"
keep `i_vars' `j_vars' `wide_vars' `extra_vars'
reshape wide `wide_vars', i(`i_vars') j(`j_vars')



*** Recode race to separate out Hispanic.  We leave those reporting black as black.
#delimit ;
label define race   1 "white"
                    2 "black"
                    3 "hispanic"
                    4 "asian"
                    5 "other";
#delimit cr

forvalues wave = $first_wave/$final_wave {
    recode ERACE`wave' (1=1) (2=2) (3=4) (4=5), generate (race`wave')
    replace race`wave' = 3 if ((EORIGIN`wave' == 1) & (ERACE`wave' != 2))
    label values race`wave' race
}

*** Clean up race by taking the first reported race.
gen my_race = race$first_wave
forvalues wave = $second_wave/$final_wave {
    replace my_race = race`wave' if (missing(my_race))
}
label values my_race race

* Flag for difference between reported race and my_race.
gen race_diff$first_wave = .
forvalues wave = $second_wave/$final_wave {
    gen race_diff`wave' = .
    replace race_diff`wave' = 1 if ((!missing(my_race)) & (!missing(race`wave')) & (race`wave' != my_race))
    replace race_diff`wave' = 0 if ((!missing(my_race)) & (!missing(race`wave')) & (race`wave' == my_race))
    tab race_diff`wave'
    tab my_race race`wave' if (race_diff`wave' == 1)
}
egen any_race_diff = rowmax(race_diff*)
tab any_race_diff



***
* Do something similar for sex.
gen my_sex = ESEX$first_wave
forvalues wave = $second_wave/$final_wave {
    replace my_sex = ESEX`wave' if (missing(my_sex))
}

* Flag for difference between reported sex and my_sex.
gen sex_diff$first_wave = .
forvalues wave = $second_wave/$final_wave {
    gen sex_diff`wave' = .
    replace sex_diff`wave' = 1 if ((!missing(my_sex)) & (!missing(ESEX`wave')) & (ESEX`wave' != my_sex))
    replace sex_diff`wave' = 0 if ((!missing(my_sex)) & (!missing(ESEX`wave')) & (ESEX`wave' == my_sex))
    tab sex_diff`wave'
    tab my_sex ESEX`wave' if (sex_diff`wave' == 1)
}
egen any_sex_diff = rowmax(sex_diff*)
tab any_sex_diff



*** Now merge the SSUID datasets.  We need to do this after going wide
* because if we merge earlier we end up with missing data for the waves
* the individual was not present.
merge m:1 SSUID using "$tempdir/ssuid_members_wide"
assert _merge == 3
drop _merge

merge m:1 SSUID using "$tempdir/ssuid_shhadid_wide"
assert _merge == 3
drop _merge


* Figure out first and last wave of appearance for each person
* (which is probably the same as the whole household).
* TODO - CHECK that SHHADID is never missing in the base data;
* we assume here that a missing SHHADID means the person was absent
* from that wave.

gen my_last_wave = ${first_wave} if (!missing(SHHADID${first_wave}))
forvalues wave = $second_wave/$final_wave {
    replace my_last_wave = `wave' if (!missing(SHHADID`wave'))
}

gen my_first_wave = ${final_wave} if (!missing(SHHADID${final_wave}))
forvalues wave = $penultimate_wave (-1) $first_wave {
    replace my_first_wave = `wave' if (!missing(SHHADID`wave'))
}

* Keep a temp version with all the original data so we can confirm
* correctness of our normalizing computations.
save "$tempdir/person_wide_debug", $replace



* Drop the variables we don't need any more because we computed my_race and my_sex.
drop ERACE* race* ESEX*
drop any_race_diff any_sex_diff sex*


* Also drop some other variables we don't need any more.
drop EBORNUS* EORIGIN*

save "$tempdir/person_wide", $replace




