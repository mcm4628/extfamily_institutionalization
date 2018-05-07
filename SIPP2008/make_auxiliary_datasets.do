*** TODO:  Maybe some/all of these should go to shared data?

*** TODO:  Can these three very similar sets of code be unified into a single repeated block?

//===================================================================================================//
//===========Children's Household Instability Project                           =====================//
//===========Dataset: SIPP2008                                                  ======================//
//===========Purpose: This file creates databases                                =====================//
//===================================================================================================//


/************************** Purpose I: Make the shhadid member database************************/
use "$tempdir/allwaves"

** Function: Create 2 local macros.  
*  Note: One is for Sample Unit Id and Household Addr ID. One is for Wave.  
local i_vars "SSUID SHHADID" 
local j_vars "SWAVE"

** Function: Sort by EPPPNUM (Person Number) to get a sorted list in the concatenation.
keep `i_vars' `j_vars' EPPPNUM TAGE
sort `i_vars' `j_vars' EPPPNUM TAGE

** Function: Number the people in the household for each wave.
by `i_vars' `j_vars':  gen pnum = _n  

** Function: Generate the maximum number of people in any household in any wave.
egen maxpnum = max(pnum)

** Function: Generate a macro to get the value of maxpnum for some arbitrary observation 
*  Note: it is fine becaue it's constant across all observations.
local maxpn = `=maxpnum'


/* I'm not sure if I'll use the age-person thing or the child/adult concatenations.
 Probably don't need both. */
 
** Function: Build variables numbered 1 to maxpn. 
*            Generate a horizontal list of people in the household at each wave.
*  Note: After this loop we've set variable #n for the nth person in the household in this wave.

forvalues pn = 1/`maxpn' {
    gen for_concat_person`pn' = string(EPPPNUM) if (pnum == `pn')
    gen for_concat_child`pn' = string(EPPPNUM) if ((pnum == `pn') & (TAGE < $adult_age))
    gen for_concat_adult`pn' = string(EPPPNUM) if ((pnum == `pn') & (TAGE >= $adult_age))
    gen for_concat_age_person`pn' = string(TAGE) + "-" + string(EPPPNUM) if (pnum == `pn')
}

drop pnum

** Function: Prepare to collapse the data.
keep `i_vars' `j_vars' for_concat_person* for_concat_child* for_concat_adult* for_concat_age_person*

* Note: We take the first non-missing of the variables we built above.  
*       There is in fact exactly one non-missing -- only the nth person in the household in this wave got a value set for variable #n.
collapse (firstnm) for_concat_child* (firstnm) for_concat_adult* (firstnm) for_concat_person* (firstnm) for_concat_age*, by (`i_vars' `j_vars')

** Function: Concatenate all those variables created.
* This makes a list of people in the household, separated by blanks, and a similar list of "age-epppnum" of those people.
egen shhadid_members = concat(for_concat_person*), punct(" ")
egen shhadid_children = concat(for_concat_child*), punct(" ")
egen shhadid_adults = concat(for_concat_adult*), punct(" ")
egen shhadid_member_ages = concat(for_concat_age_person*), punct(" ")

drop for_concat_person* for_concat_age_person* for_concat_child* for_concat_adult*

* Strip out extra spaces.
replace shhadid_members = strtrim(shhadid_members)
replace shhadid_children = strtrim(shhadid_children)
replace shhadid_adults = strtrim(shhadid_adults)
replace shhadid_member_ages = strtrim(shhadid_member_ages)

* Add a space at the beginning and end of the string to make sure every person appears surrounded by spaces.
replace shhadid_members = " " + shhadid_members + " "
replace shhadid_children = " " + shhadid_children + " "
replace shhadid_adults = " " + shhadid_adults + " "
replace shhadid_member_ages = " " + shhadid_member_ages + " "

** Function: Compute max number of members by wave and overall.
sort SWAVE
gen n_shhadid_members = wordcount(shhadid_members)
by SWAVE:  egen max_shhadid_members = max(n_shhadid_members)
egen overall_max_shhadid_members = max(n_shhadid_members)
drop n_shhadid_members

gen n_shhadid_children = wordcount(shhadid_children)
by SWAVE:  egen max_shhadid_children = max(n_shhadid_children)
egen overall_max_shhadid_children = max(n_shhadid_children)
drop n_shhadid_children

gen n_shhadid_adults = wordcount(shhadid_adults)
by SWAVE:  egen max_shhadid_adults = max(n_shhadid_adults)
egen overall_max_shhadid_adults = max(n_shhadid_adults)
drop n_shhadid_adults

compress /* reduce memory */

macro drop i_vars j_vars /* drop macros */

** Output: Shhadid_member database
save "$tempdir/shhadid_members", $replace


/*********************************Purpose II: Make the ssuid member database**************************/
use "$tempdir/allwaves"

** Function: Create two local macros: one is for sample unit ID, one is for wave 
local i_vars "SSUID"
local j_vars "SWAVE"

** Function: by EPPPNUM to get a sorted list in the concatenation.
keep `i_vars' `j_vars' EPPPNUM
sort `i_vars' `j_vars' EPPPNUM

** Function: Number the people in the household for each wave.
by `i_vars' `j_vars':  gen pnum = _n

** Function: Create the maximum number of people in any household in any wave.
egen maxpnum = max(pnum)

** Function: Create a macro to get the value of maxpnum for some arbitrary observation
*  Note: it is fine becaue it's constant across all observations.
local maxpn = `=maxpnum'


** Function: Build variables numbered 1 to maxpn, 
*            We're preparing to generate a horizontal list of people in the household at each wave.
*            After this loop we've set variable #n for the nth person in the household in this wave.
forvalues pn = 1/`maxpn' {
    gen for_concat_person`pn' = string(EPPPNUM) if (pnum == `pn')
}

drop pnum


* Prepare to collapse the data.
keep `i_vars' `j_vars' for_concat_person*

* Note: We take the first non-missing of the variables we built above.  
*       There is in fact exactly one non-missing -- only the nth person in the household in this wave got a value set for variable #n.

collapse (firstnm) for_concat_person*, by (`i_vars' `j_vars')

** Function: Concatenate all those variables created.
* This makes a list of people in the household, separated by blanks.
egen ssuid_members = concat(for_concat_person*), punct(" ")

drop for_concat_person*

* Strip out extra space to save space.
replace ssuid_members = strtrim(ssuid_members)

* Add a space at the beginning and end of the string so we are sure every person appears surrounded by spaces.
replace ssuid_members = " " + ssuid_members + " "


* Compute max number of members by wave and overall.
sort SWAVE
gen n_ssuid_members = wordcount(ssuid_members)
by SWAVE:  egen max_ssuid_members = max(n_ssuid_members)
egen overall_max_ssuid_members = max(n_ssuid_members)
drop n_ssuid_members

compress /* reduce memory */

reshape wide ssuid_members max_ssuid_members, i(`i_vars') j(`j_vars')

macro drop i_vars j_vars

** Output: Ssuid_members_wide database
save "$tempdir/ssuid_members_wide", $replace



/***************************** Purpose III: Make the ssuid SHHADID database*************************/
use "$tempdir/allwaves"

** Function: Create two local macros: one is for sample unit ID, one is for wave 
local i_vars "SSUID"
local j_vars "SWAVE"

** Function: Sort by SHHADID to get a sorted list in the concatenation.
keep `i_vars' `j_vars' SHHADID
sort `i_vars' `j_vars' SHHADID
duplicates drop

** Function: Number the addresses in the household for each wave.
by `i_vars' `j_vars':  gen anum = _n

** Function: Generate the maximum number of addresses in any household in any wave.
egen maxanum = max(anum)

** Function:  Create a macro to get the value of maxpnum for some arbitrary observation.
local maxan = `=maxanum'


** Function: Build variables numbered 1 to maxan, 
*            We're preparing to generate a horizontal list of addresses in the household at each wave.
*            After this loop we've set variable #n for the nth addresses in the household in this wave.

forvalues an = 1/`maxan' {
    gen for_concat_address`an' = string(SHHADID) if (anum == `an')
}

drop anum


keep `i_vars' `j_vars' for_concat_address* /* Prepare to collapse the data */

** Note: We take the first non-missing of the variables built above.  
*       There is in fact exactly one non-missing -- only the nth address in the household in this wave got a value set for variable #n.
collapse (firstnm) for_concat_address*, by (`i_vars' `j_vars')

** Function: Concatenate all those variables we created.
* This makes a list of addresses in the household, separated by blanks.
egen ssuid_shhadid = concat(for_concat_address*), punct(" ")

drop for_concat_address*

* Save space by stripping out extra spaces.
replace ssuid_shhadid = strtrim(ssuid_shhadid)

* Add a space at the beginning and end of the string so we are sure every person appears surrounded by spaces.
replace ssuid_shhadid = " " + ssuid_shhadid + " "


** Function: Compute max number of members by wave and overall.
sort SWAVE
gen n_ssuid_shhadid = wordcount(ssuid_shhadid)
by SWAVE:  egen max_ssuid_shhadid = max(n_ssuid_shhadid)
egen overall_max_ssuid_shhadid = max(n_ssuid_shhadid)
drop n_ssuid_shhadid

compress /*save memory */

reshape wide ssuid_shhadid max_ssuid_shhadid, i(`i_vars') j(`j_vars')

macro drop i_vars j_vars

** Output: ssuid_shhadid_wide database
save "$tempdir/ssuid_shhadid_wide", $replace



/******************* Purpose: Create a merging dataset that has education (EEDUCATE) under a different name ****************************/
* Note: merge without worrying about whether EEDUCATE for ego is in the dataset.
*       EPPPNUM needs to be named something different so I can merge on a different person number (EPNMOM, e.g.)
*      The known use for this merge is to get parents' educ in the analysis dataset.

use "$tempdir/allwaves"

local i_vars "SSUID EPPPNUM"
local j_vars "SWAVE"

* I'm sorting by EPPPNUM to get a sorted list in the concatenation.
keep `i_vars' `j_vars' EEDUCATE


*** Label for recoded education.
#delimit ;
label define educ   1 "lths"
                    2 "hs"
                    3 "ltcol"
                    4 "coll";
#delimit cr


*** Recode education into fewer categories.

recode EEDUCATE (31/38 = 1)  (39 = 2)  (40/43 = 3)  (44/47 = 4), gen (educ)
label values educ educ

drop EEDUCATE

rename EPPPNUM educ_epppnum

save "$tempdir/person_educ", $replace



*** Now I just want a merging dataset that has education (EBORNUS) under a different
* name so I can merge without worrying about whether EEDUCATE for ego is in the dataset.
*
* I also need EPPPNUM named something different so I can merge on a different
* person number (EPNMOM, e.g.)
*
* The known use for this merge is to get mom's immigrant status in the analysis dataset.
use "$tempdir/allwaves"

** Function: Create 2 local macros.  
*  Note: One is for Sample Unit Id and Household Addr ID. One is for Wave.  
local i_vars "SSUID EPPPNUM"
local j_vars "SWAVE"

** Function: Sort by EPPPNUM to get a sorted list in the concatenation.
keep `i_vars' `j_vars' EBORNUS
sort `i_vars' `j_vars' EBORNUS

**Function: Recode EBORNUS into a flag.

recode EBORNUS (1 = 0)  (2 = 1) , gen (immigrant)

drop EBORNUS

rename EPPPNUM immigrant_epppnum

** Output: person/immigrant database
save "$tempdir/person_immigrant", $replace



** Function: the following do-file creates a dataset of reference persons.
do "$childhh_base_code/SIPP2008/make_aux_refperson"


/************************** Purpose IV: Create a dataset of partners of reference persons ********************************/
use "$tempdir/allwaves"
keep SSUID EPPPNUM SHHADID ERRP SWAVE
gen partner_is_married = 1 if (ERRP == 3) /* generate a variable indicating married */
gen partner_is_unmarried = 1 if (ERRP == 10) /* generate a variable indicating cohabitating */
keep if ((ERRP == 3) | (ERRP == 10))
drop ERRP
rename EPPPNUM partner_of_ref_person 
** Output: long format database
duplicates drop
save "$tempdir/partner_of_ref_person_long", $replace
** Output: wide format database
reshape wide partner_of_ref_person partner_is_married partner_is_unmarried, i(SSUID SHHADID) j(SWAVE)
save "$tempdir/partner_of_ref_person_wide", $replace
