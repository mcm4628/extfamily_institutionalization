//============================================================================================================================//
//===== Children's Household Instability Project                                                    
//===== Dataset: SIPP2008                                                                               
//===== Purpose: Create a wide database by person (SSUID EPPPNUM) including charactersitics such as parental characteristics, race and sex. 
//===== Logic: This file generates variables indicating the first and last wave numbers in which this person is encountered.
//=====        Also, generates a normalized variable for race and sex, in other words, generate a single value we'll use for
//=====        the individual even though for some people reports vary across waves. It also created flags to indicate whether race/sex are consistent cross waves (i.e.dfferent from 
//=====        the first wave. 
//============================================================================================================================//
 
 
 
//==========================================================================================================//
//== Purpose: Generate variables indicating parental education and immigration status 
//=========================================================================================================//



***************************************************************************************
** Function: Use household ID and wave to merge in household member information in shhadid_members dataset.  
**
** Logic: Merge in all waves first and generate parents' education later.
***************************************************************************************
use "$tempdir/allwaves", clear  

merge m:1 SSUID SHHADID SWAVE using "$tempdir/shhadid_members" 
assert _merge == 3
drop _merge




************************************************************************************
** Function: Merge with the dataset that contains person's education and find mother'e education based on mother's person number.
**
** Logic: EPNMOM - Person number of mother.  9999 - "no mother in household", replace 9999 to missing. 
************************************************************************************
recode EPNMOM (9999 = .), gen(educ_epppnum)
merge m:1 SSUID educ_epppnum SWAVE using "$tempdir/person_educ"
assert missing(educ_epppnum) if (_merge == 1)
drop if _merge == 2
drop _merge

drop educ_epppnum
rename educ mom_educ

label var mom_educ "Mother's educational level"




************************************************************************************
** Function: Merge with the dataset that contains person's education and find father'e education based on father's person number.
**
** Logic: EPNDAD - Person number of father.  9999 - "no father in household", replace 9999 to missing. 
************************************************************************************* 
recode EPNDAD (9999 = .), gen(educ_epppnum)
merge m:1 SSUID educ_epppnum SWAVE using "$tempdir/person_educ"
assert missing(educ_epppnum) if (_merge == 1)
drop if _merge == 2
drop _merge

drop educ_epppnum
rename educ dad_educ

label var dad_educ "Father's educational level"




************************************************************************************
** Function: Merge with the dataset that contains person's immigration status and find mother'e immigration status based on mother's person number.
**
** Logic: EPNMOM - Person number of mother.  9999 - "no mother in household", replace 9999 to missing. 
************************************************************************************
recode EPNMOM (9999 = .), gen(immigrant_epppnum)
merge m:1 SSUID immigrant_epppnum SWAVE using "$tempdir/person_immigrant"
assert missing(immigrant_epppnum) if (_merge == 1)
drop if _merge == 2
drop _merge

drop immigrant_epppnum
rename immigrant mom_immigrant

label var mom_immigrant "Mother's immigration status"




********************************************************
** Function: The dataset currently is in long-form. Make the dataset wide by wave (15 waves).
**
** Logic: There are so many variables, making local macros is convenient.   
**        We categorize variables change each wave (wide_vars) and variables do not change (extra_vars).  
********************************************************
local i_vars "SSUID EPPPNUM"
local j_vars "SWAVE"
local wide_vars "SHHADID EPNMOM EPNDAD ETYPMOM ETYPDAD EPNSPOUS TAGE EMS ERRP WPFINWGT ERACE ESEX EORIGIN EBORNUS mom_educ dad_educ mom_immigrant shhadid_member_ages shhadid_members max_shhadid_members shhadid_adults max_shhadid_adults shhadid_children max_shhadid_children"
local extra_vars "overall_max_shhadid_members overall_max_shhadid_adults overall_max_shhadid_children"
keep `i_vars' `j_vars' `wide_vars' `extra_vars'
reshape wide `wide_vars', i(`i_vars') j(`j_vars')




//===============================================================================================
//== Purpose: Recode Race/Ethnicity. 
//==
//== Logic: Recode non-black Hispanic.  Find out if reported race/ethnicity are constant in waves.  
//================================================================================================

***********************************************************************
** Function: Label race.
***********************************************************************
#delimit ;
label define race   1 "white"
                    2 "black"
                    3 "hispanic"
                    4 "asian"
                    5 "other";
#delimit cr


**********************************************************************
** Function: Generate RACE in each wave.
**
** Logic: Loop through waves 1-15 and recode non-black Hispanic in each wave.  
**********************************************************************
forvalues wave = $first_wave/$final_wave {
    recode ERACE`wave' (1=1) (2=2) (3=4) (4=5), generate (race`wave')
    replace race`wave' = 3 if ((EORIGIN`wave' == 1) & (ERACE`wave' != 2)) /* Non-Black Hispanic */
    label values race`wave' race
}


**********************************************************************
** Function: Create a variable (myrace) and use the race value in the first wave.  If race information is missing in the first wave, we use later waves information instead.
**
** Logic: Clean up race by taking the first reported race.
**********************************************************************
gen my_race = race$first_wave
forvalues wave = $second_wave/$final_wave {
    replace my_race = race`wave' if (missing(my_race))
}
label values my_race race 



************************************************************************
** Function: Create flag variables (race_diff*) for difference between reported race and my_race throughout the 15 waves.
**           Use the 15 flag variables to create an indicator variable (any_race_diff) to indicate if there's any different reported race and my_race in any wave. 
************************************************************************
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



//==================================================================================================
//== Purpose: Recode Sex. 
//==
//== Logic: Find out if sex is reported the same throughout waves and create a flag for the different reported sex. 
//===================================================================================================

*************************************************************************
** Function: Generate a varaible my_sex and use the sex value in the first wave. 
** 
** Logic: Clean up sex by taking the first reported sex. If sex information is missing in the first wave, we use later waves information on sex. 
*************************************************************************
gen my_sex = ESEX$first_wave
forvalues wave = $second_wave/$final_wave {
    replace my_sex = ESEX`wave' if (missing(my_sex))
}


*************************************************************************
** Function: Create flag variables (sex_diff*) to indicate whether sex information is the same as reported in the first wave.
**           Use these flag variables to generate an indicator (any_sex_diff) for any different sex value through out waves. 
*************************************************************************
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


//========================================================================================================
//== Purpose: Create a wide database by person (SSUID EPPPNUM) including race and sex.
//==
//== Logic: We need to do this after going wide because if we merge earlier we end up with missing data for the waves the individual was not present.
//=========================================================================================================

******************************************************************************************** 
** Function: Merge the SSUID Dataset that each unit is a household. 
** 
** Logic: uusid-members_wide and ssuid_shhadid_wide contains houseold member information. 
********************************************************************************************
merge m:1 SSUID using "$tempdir/ssuid_members_wide"
assert _merge == 3
drop _merge

merge m:1 SSUID using "$tempdir/ssuid_shhadid_wide"
assert _merge == 3
drop _merge

*******************************************************************************************************
** Function: Figure out first and last wave of appearance for each person(which is often the same as the whole household).
**
** Note: SHHADID is never missing in the base data, so we can assume here that a missing SHHADID means the person was absent from that wave.
********************************************************************************************************
gen my_last_wave = ${first_wave} if (!missing(SHHADID${first_wave}))
forvalues wave = $second_wave/$final_wave {
    replace my_last_wave = `wave' if (!missing(SHHADID`wave'))
}

gen my_first_wave = ${final_wave} if (!missing(SHHADID${final_wave}))
forvalues wave = $penultimate_wave (-1) $first_wave {
    replace my_first_wave = `wave' if (!missing(SHHADID`wave'))
}



*********************************************************************************************************
** Note: Keep a temp version with all the original data so we can confirm correctness of our normalizing computations.
*********************************************************************************************************
save "$tempdir/person_wide_debug", $replace


** Drop the variables we don't need any more because we computed my_race and my_sex.

drop ERACE* race* ESEX*
drop any_race_diff any_sex_diff sex*
drop EBORNUS* EORIGIN*


save "$tempdir/person_wide", $replace




