//=================================================================================//
//====== Children's Household Instability Project                          
//====== Dataset: SIPP2008                                               
//====== Purpose: Creates sub-databases                               
//=================================================================================//


//================================================================================//
//== Purpose: Make the shhadid member database with a single string variable containing a list of all EPPPNUMs in a household in a wave
//== This file will be used for normalize ages and so it includes a string variable with list of all ages of household members with EPPPNUM
//================================================================================//
use "$tempdir/allwaves"

local i_vars "SSUID SHHADID" 
local j_vars "SWAVE"


keep `i_vars' `j_vars' EPPPNUM TAGE
sort `i_vars' `j_vars' EPPPNUM TAGE


by `i_vars' `j_vars':  gen pnum = _n  /* Number the people in the household in each wave. */

egen maxpnum = max(pnum) /* max n of people in any household in any wave. */
local maxpn = `=maxpnum' /* to use below in forvalues loop */


//======================= Attention! =======================//
/* I'm not sure if I'll use the age-person thing or the child/adult concatenations.
 Probably don't need both. */
//==========================================================//

*******************************************************************
** Function: Generate a horizontal list of people in the household at each wave.
********************************************************************

* Create for_concat* variables equal to string value of pn's EPPPNUM for for_contact_*[pn] and missing otherwise
* and for_concat_age_* variables equal to string value of TAGE-EPPPNUM
forvalues pn = 1/`maxpn' {
    gen for_concat_person`pn' = string(EPPPNUM) if (pnum == `pn')
    gen for_concat_child`pn' = string(EPPPNUM) if ((pnum == `pn') & (TAGE < $adult_age))
    gen for_concat_adult`pn' = string(EPPPNUM) if ((pnum == `pn') & (TAGE >= $adult_age))
    gen for_concat_age_person`pn' = string(TAGE) + "-" + string(EPPPNUM) if (pnum == `pn')
}

drop pnum

* Collapse to take the first non-missing of the variables we built above.  
* There is exactly one non-missing -- only the nth person in the household in this wave got a value set for variable #n.
keep `i_vars' `j_vars' for_concat_person* for_concat_child* for_concat_adult* for_concat_age_person*

collapse (firstnm) for_concat_child* (firstnm) for_concat_adult* (firstnm) for_concat_person* (firstnm) for_concat_age*, by (`i_vars' `j_vars')

* Concatenate all for_concat* variables into a single string where each person number is separated by a blank.
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

********************************************************************
** Function: Compute number of household members by wave and overall.
********************************************************************
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

compress 

macro drop i_vars j_vars 


save "$tempdir/shhadid_members", $replace


//================================================================================//
//== Purpose: Make the ssuid member database
//== The logic is similar for the shhadid database, but here we are going to collapse
//== by sample unit (SSUID) instead of address (SSUID SHHADID) to create variables
//== describing number of sample unit members across all waves
//================================================================================//

use "$tempdir/allwaves"

local i_vars "SSUID"
local j_vars "SWAVE"

keep `i_vars' `j_vars' EPPPNUM
sort `i_vars' `j_vars' EPPPNUM

by `i_vars' `j_vars':  gen pnum = _n  /* Number the people in the sampling unit in each wave. */

egen maxpnum = max(pnum) /* max n of people in sampling unit in any wave. */
local maxpn = `=maxpnum' /* to use below in forvalues loop */

*******************************************************************
** Function: Generate a horizontal list of people in the SSUID (original sampling unit).
********************************************************************

* Create for_concat* variable equal to string value of pn's EPPPNUM for for_contact_*[pn] and missing otherwise
forvalues pn = 1/`maxpn' {
    gen for_concat_person`pn' = string(EPPPNUM) if (pnum == `pn')
}

drop pnum

keep `i_vars' `j_vars' for_concat_person*

* Collapse to take the first non-missing of the variables we built above.  
* There is exactly one non-missing -- only the nth person in the household in this wave got a value set for variable #n.
collapse (firstnm) for_concat_person*, by (`i_vars' `j_vars')

*Concatenate all person-numbers into a single string.
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

compress 

reshape wide ssuid_members max_ssuid_members, i(`i_vars') j(`j_vars')

macro drop i_vars j_vars

save "$tempdir/ssuid_members_wide", $replace

//================================================================================//
//== Purpose: Make the ssuid SHHADID database with information on the number of addresses (SHHADID)
//== in the sampling unit (SSUID) in each wave and overall.
//================================================================================//

use "$tempdir/allwaves"

local i_vars "SSUID"
local j_vars "SWAVE"

keep `i_vars' `j_vars' SHHADID
sort `i_vars' `j_vars' SHHADID
duplicates drop


by `i_vars' `j_vars':  gen anum = _n /* Number the addresses in the household for each wave. */

* maximum number of addresses in any household in any wave.
egen maxanum = max(anum)
local maxan = `=maxanum'

*******************************************************************
** Function: Generate a horizontal list of addresses in the SSUID (original sampling unit).
********************************************************************

* Create for_concat* variable equal to string value of address's SHHADID for for_contact_*[an] and missing otherwise
forvalues an = 1/`maxan' {
    gen for_concat_address`an' = string(SHHADID) if (anum == `an')
}

drop anum

keep `i_vars' `j_vars' for_concat_address* 

* Collapse to take the first non-missing of the variables we built above.  
* There is exactly one non-missing -- only the nth address in the household in this wave got a value set for variable #n.
collapse (firstnm) for_concat_address*, by (`i_vars' `j_vars')


*Concatenate all "addresses" into a single string.
egen ssuid_shhadid = concat(for_concat_address*), punct(" ")

drop for_concat_address*

* Save space by stripping out extra spaces.
replace ssuid_shhadid = strtrim(ssuid_shhadid)

* Add a space at the beginning and end of the string so we are sure every person appears surrounded by spaces.
replace ssuid_shhadid = " " + ssuid_shhadid + " "

* Compute max number of addresses by wave and overall.

sort SWAVE
gen n_ssuid_shhadid = wordcount(ssuid_shhadid)
by SWAVE:  egen max_ssuid_shhadid = max(n_ssuid_shhadid)
egen overall_max_ssuid_shhadid = max(n_ssuid_shhadid)
drop n_ssuid_shhadid

compress 

reshape wide ssuid_shhadid max_ssuid_shhadid, i(`i_vars') j(`j_vars')

macro drop i_vars j_vars

save "$tempdir/ssuid_shhadid_wide", $replace


//================================================================================//
//== Purpose: Create a dataset with education and immigration status for merging 
//== 
//== Logic: Rename EPPPNUM to later merge onto person number of mother (EPNMOM) 
//==        and father (EPNDAD) to get parents' educ and immigration status in the analysis dataset.
//================================================================================//

use "$tempdir/allwaves"

local i_vars "SSUID EPPPNUM"
local j_vars "SWAVE"


keep `i_vars' `j_vars' EEDUCATE EBORNUS
sort `i_vars' `j_vars' EEDUCATE EBORNUS


** Label recoded education.
#delimit ;
label define educ   1 "lths"
                    2 "hs"
                    3 "ltcol"
                    4 "coll";
#delimit cr

recode EEDUCATE (31/38 = 1)  (39 = 2)  (40/43 = 3)  (44/47 = 4), gen (educ)
label values educ educ

recode EBORNUS (1 = 0)  (2 = 1) , gen (immigrant)

drop EEDUCATE EBORNUS

* demo_epppnum will be key to merge with epnmom and epndad to get parent education onto
* ego's record
rename EPPPNUM pdemo_epppnum

save "$tempdir/person_pdemo", $replace

* create a dataset of household reference persons.
do "$childhh_base_code/SIPP2008/make_aux_refperson"

* Create a dataset of partners of reference persons
use "$tempdir/allwaves"
keep SSUID EPPPNUM SHHADID ERRP SWAVE
gen partner_is_married = 1 if (ERRP == 3) /* generate a variable indicating married */
gen partner_is_unmarried = 1 if (ERRP == 10) /* generate a variable indicating cohabitating */
keep if ((ERRP == 3) | (ERRP == 10))
drop ERRP
rename EPPPNUM partner_of_ref_person 


duplicates drop
save "$tempdir/partner_of_ref_person_long", $replace


reshape wide partner_of_ref_person partner_is_married partner_is_unmarried, i(SSUID SHHADID) j(SWAVE)
save "$tempdir/partner_of_ref_person_wide", $replace
