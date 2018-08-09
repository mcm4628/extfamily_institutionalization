//============================================================================================================================//
//===== Children's Household Instability Project                                                    
//===== Dataset: SIPP2008                                                                               
//===== Purpose: Create a wide database by person (SSUID EPPPNUM) including variables describing parental characteristics, race and sex. 
//===== Logic: This file generates variables indicating the first and last wave numbers in which this person is encountered.
//=====        Also, generates a single value for race and sex even though for some people reports vary across waves.
//============================================================================================================================//
 
use "$tempdir/allwaves", clear  

merge m:1 SSUID SHHADID SWAVE using "$tempdir/shhadid_members" 
assert _merge == 3
drop _merge

********************************************************************************
* Function: create variables describing mother's and father's education and mother's
*           immigration status by merging to person_pdemo 
*           (created in make_auxiliary_datasets)using pdemo_eppnum as key
********************************************************************************

* rename EPNMOM to educ_eppnum for merging
recode EPNMOM (9999 = .), gen(pdemo_epppnum)
merge m:1 SSUID pdemo_epppnum SWAVE using "$tempdir/person_pdemo"
assert missing(pdemo_epppnum) if (_merge == 1)
drop if _merge == 2
drop _merge
drop pdemo_epppnum
rename educ mom_educ
rename immigrant mom_immigrant

label var mom_educ "Mother's educational level"
label var mom_immigrant "Mother's immigration status"

* rename EPNMOM to educ_eppnum for merging
recode EPNDAD (9999 = .), gen(pdemo_epppnum)
merge m:1 SSUID pdemo_epppnum SWAVE using "$tempdir/person_pdemo"
assert missing(pdemo_epppnum) if (_merge == 1)
drop if _merge == 2
drop _merge
drop pdemo_epppnum
rename educ dad_educ
rename immigrant dad_immigrant

label var dad_educ "Father's educational level"
label var mom_immigrant "Father's immigration status"

*Make the dataset wide by wave (15 waves).

local i_vars "SSUID EPPPNUM"
local j_vars "SWAVE"
local wide_vars "SHHADID EPNMOM EPNDAD ETYPMOM ETYPDAD EPNSPOUS TAGE EMS ERRP WPFINWGT ERACE ESEX EORIGIN EBORNUS mom_educ dad_educ mom_immigrant shhadid_member_ages shhadid_members max_shhadid_members shhadid_adults max_shhadid_adults shhadid_children max_shhadid_children"
local extra_vars "overall_max_shhadid_members overall_max_shhadid_adults overall_max_shhadid_children"
keep `i_vars' `j_vars' `wide_vars' `extra_vars'
reshape wide `wide_vars', i(`i_vars') j(`j_vars')

***********************************************************************
* Function: Create Race/Ethnicity variables (2 versions) and set my_race 
*           (and my_race_v2) equal to first observation. 
***********************************************************************

#delimit ;
label define race   1 "NH white"
                    2 "black"
                    3 "non-black Hispanic"
                    4 "NH Asian"
                    5 "NH other";

label define race2  1 "NH white"
					2 "NH black"
					3 "Hispanic"
					4 "NH Asian"
					5 "NH Other";
#delimit cr

* there was a variable for race in each wave
forvalues wave = $first_wave/$final_wave {
    recode ERACE`wave' (1=1) (2=2) (3=4) (4=5), generate (race`wave')
    replace race`wave' = 3 if ((EORIGIN`wave' == 1) & (ERACE`wave' != 2)) /* non-black Hispanic */
	recode ERACE`wave' (1=1)(2=2)(3=4)(4=5), generate(race2`wave')
	replace race2`wave' = 3 if EORIGIN`wave'==1 /*All Hispanic */
    label values race`wave' race
}

* use the race value in the first observation.
gen my_race = race$first_wave
gen my_race2 = race2$first_wave
forvalues wave = $second_wave/$final_wave {
    replace my_race = race`wave' if (missing(my_race))
	replace my_race2=race2`wave' if (missing(my_race2))
}
label values my_race race 
label values my_race2 race2 

* Create flag variables (race_diff*) for difference between reported race and my_race throughout the 15 waves.
* Use the 15 flag variables to create an indicator variable (any_race_diff) to indicate if there's any different reported race and my_race in any wave. 
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

*************************************************************************
* Function: Create sex variable. Set value of my_sex to the value at first observation. 
*************************************************************************

gen my_sex = ESEX$first_wave
forvalues wave = $second_wave/$final_wave {
    replace my_sex = ESEX`wave' if (missing(my_sex))
}

#delimit ;
label define sex    1 "male"
                    2 "female"
					;

#delimit cr

label values my_sex sex

* Create flag variables (sex_diff*) to indicate whether sex information is the same as reported in the first wave.
* Use these flag variables to generate an indicator (any_sex_diff) for any different sex value through out waves. 
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


* Merge in file with information on number of persons in sampling unit per wave and overall (make_auxiliary_datasets)
merge m:1 SSUID using "$tempdir/ssuid_members_wide"
assert _merge == 3
drop _merge

* Merge in file with information on number of addresses in sampling unit per wave and overall (make_auxiliary_datasets)
merge m:1 SSUID using "$tempdir/ssuid_shhadid_wide"
assert _merge == 3
drop _merge

* Create variables identifying first and last wave of appearance for each person(which is often the same as the whole household).
* Note: SHHADID is never missing in the base data, so we can assume here that a missing SHHADID means the person was absent from that wave.
gen my_last_wave = ${first_wave} if (!missing(SHHADID${first_wave}))
forvalues wave = $second_wave/$final_wave {
    replace my_last_wave = `wave' if (!missing(SHHADID`wave'))
}

gen my_first_wave = ${final_wave} if (!missing(SHHADID${final_wave}))
forvalues wave = $penultimate_wave (-1) $first_wave {
    replace my_first_wave = `wave' if (!missing(SHHADID`wave'))
}

* Note: Keep a temp version with all the original data so we can confirm correctness of our normalizing computations.
save "$tempdir/person_wide_debug", $replace

drop ERACE* race* ESEX*
drop any_race_diff any_sex_diff sex*
drop EBORNUS* EORIGIN*

save "$tempdir/person_wide", $replace




