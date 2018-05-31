//=========================================================================================//
//===== Children's Household Instability Project               
//===== Dataset: SIPP2008                                      
//===== Purpose: This file tabulates household characteristics 
//=========================================================================================//

use "$tempdir/person_wide_adjusted_ages"


//========================================================================================//
//======== ATTENTION 
//======== I am not including weight because I'm going to end up with households, not people and I have no idea what to do about that.
//======== We probably need income but it's not in the dataset I'm using.  Do we have it in the base data?
//=======================================================================================//



keep SSUID EPPPNUM SHHADID* adj_age*


reshape long SHHADID adj_age, i(SSUID EPPPNUM) j(SWAVE)



*********************************************************************************
** Function: Drop people who were not present in a wave.
*********************************************************************************
assert (missing(SHHADID) == missing(adj_age)) /*confirms that we're not missing any ages when data is present.*/
drop if missing(adj_age)




*********************************************************************************
** Function: Now merge with the base data to get the income variable. 
********************************************************************************* 
merge 1:1 SWAVE SSUID EPPPNUM using "$tempdir/allwaves", keepusing(THTOTINC) /* THTOTINC: total household income */
assert (_merge == 3)
drop _merge



//================================================================================================
//== Purpose: Count the number of adults and children in each household in each wave.
//================================================================================================
 
local max_child_age 16



*********************************************************************************
** Function: Generate flags variables indicating child or adult.
*********************************************************************************
gen child_flag = (adj_age <= `max_child_age')
gen adult_flag = (adj_age > `max_child_age')



*********************************************************************************
** Function: Create variables indicating the number of adults and children in each household
**
** Logic: Retain the income variable (it's the same for all records in a HH in any given wave, so we just take the value in the first record).
**********************************************************************************
collapse (sum) num_children=child_flag num_adults=adult_flag  (firstnm) THTOTINC, by(SWAVE SSUID SHHADID)


* simple tabulations to get the HH characteristics. 
tab num_children
tab num_adults

tab num_children SWAVE
tab num_adults SWAVE

tab num_children num_adults

summ THTOTINC, detail


save "$tempdir/hh_wave_characteristics", $replace




//================================================================================================
//== Purpose: Collapse to one record per household
//================================================================================================
 
**********************************************************************************
** Function: Create variables indicating median number of adults and children in households.  
**           Create a varaible indicating a count of number of waves of appearance. 
**           (It's OK to count occurrences of num_adults or num_children because neither is ever missing).
************************************************************************************
collapse (median) num_children num_adults  (count) num_waves=num_adults, by(SSUID SHHADID)


* Simple tabulations.
tab num_waves

tab num_children
tab num_adults

tab num_children num_waves
tab num_adults num_waves

tab num_children num_adults


save "$tempdir/hh_characteristics", $replace
