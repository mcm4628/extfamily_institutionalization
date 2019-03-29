//==============================================================================
//===== Children's Household Instability Project                                                    
//===== Dataset: SIPP1991                                                                            
//===== Purpose: Create a wide database by person (SSUID EPPPNUM) including variables describing parental characteristics, race and sex. 
//===== Logic: This file generates variables indicating the first and last wave numbers in which this person is encountered.
//=====        Also, generates a single value for race and sex even though for some people reports vary across waves.
//==============================================================================
 local panel="91"
use "$tempdir/allwaves`panel'", clear  

merge m:1 SSUID SHHADID SWAVE using "$tempdir/shhadid_members" 
assert _merge == 3
drop _merge


* Add characteristics of reference person
merge m:1 SSUID SHHADID SWAVE using "$tempdir/ref_person_long"

*assert _merge == 3
*keep if _merge==3 // there are 450 cases with no household reference person (really!?)
drop _merge


********************************************************************************
* Section: create variables describing mother's and father's education and mother's
*           immigration status by merging to person_pdemo 
*           (created in make_auxiliary_datasets)using pdemo_eppnum as key
********************************************************************************

recode EPNPNT (0=.)(999 = .), gen(pdemo_epppnum)
merge m:1 SSUID SHHADID pdemo_epppnum SWAVE using "$tempdir/person_pdemo"
assert missing(pdemo_epppnum) if (_merge == 1)
* Not everyone has a parent, but everyone who has a valid value on EPNPNT is 
* matched in person_pdemo.

drop if _merge == 2
drop _merge
drop pdemo_epppnum
rename educ parent_educ
rename page parent_age

label var parent_educ "Parent's educational level (this wave)"
label var parent_age "Parent's Age (uncleaned)"

********************************************************************************
* Section: Make the dataset wide by wave (8 waves).
********************************************************************************

local i_vars "SSUID EPPPNUM"
local j_vars "SWAVE"
local wide_vars "SHHADID EPNPNT EPNSPOUS TAGE EMS ERRP parent_educ parent_age shhadid_members max_shhadid_members ref_person ref_person_sex ref_person_educ"
local extra_vars "overall_max_shhadid_members ERACE ESEX EORIGIN pnlwgt fnlwgt*"

keep `i_vars' `j_vars' `wide_vars' `extra_vars'
reshape wide `wide_vars', i(`i_vars') j(`j_vars')

***********************************************************************
* Section: Create Race/Ethnicity variables (2 versions) 
***********************************************************************

#delimit ;
label define race   1 "NH white"
                    2 "black"
                    3 "non-black Hispanic"
                    4 "NH Asian"
                    5 "NH other";

label define racealt  1 "NH white"
					2 "NH black"
					3 "Hispanic"
					4 "NH Asian"
					5 "NH Other";
#delimit cr

recode ERACE (1=1) (2=2) (3=4) (4=5), generate(my_race)
replace my_race = 3 if ((EORIGIN == 1) & (ERACE != 2)) /* non-black Hispanic */
recode ERACE (1=1)(2=2)(3=4)(4=5), generate(my_racealt)
replace my_racealt = 3 if EORIGIN==1 /*All Hispanic */

label values my_race race
label values my_racealt racealt

********************************************************************************
* Section: Create sex variable. Set value of my_sex to the value at first observation. 
********************************************************************************

gen my_sex = ESEX

label values my_sex sex

gen par_ed_first=parent_educ$first_wave
forvalues wave = $second_wave/$final_wave {
	replace par_ed_first=parent_educ`wave' if missing(par_ed_first)
}

********************************************************************************
* Section: Add variables for other members of sampling unit and other members who 
*          ever share an address
********************************************************************************

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

drop ERACE ESEX

save "$tempdir/person_wide", $replace




