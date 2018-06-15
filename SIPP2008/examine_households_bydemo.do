//========================================================================================================//
//===== Children's Household Instability Project                                     
//===== Dataset: SIPP2008                                                            
//===== Purpose: Tabulates child relationships by demographic groups (i.e. education, race)
//========================================================================================================//

use "$tempdir/examine_hh", clear


***************************************************************
** Function: Tabulate ultra simple relationships and unified relationships for child.
***************************************************************
tab ultra_simple_rel if (from_age < $adult_age), m sort

tab unified_rel if (from_age < $adult_age), m sort




***************************************************************
** Function: Merge with dataset in order to get person demographic information.
***************************************************************
rename relfrom EPPPNUM

sort SSUID EPPPNUM SWAVE

merge m:1 SSUID EPPPNUM SWAVE using "$tempdir/demoperson08.dta"


tab TAGE _merge

keep if _merge==3

drop _merge





***************************************************************
** Function: Merge with dataset in order to get household demographic information.
***************************************************************

sort SSUID SHHADID SWAVE

merge m:1 SSUID SHHADID SWAVE using "$tempdir/demoHH08.dta"

keep if _merge==3





***************************************************************
** Function: Tabulate child relationships.
***************************************************************

tab ultra_simple_rel if (from_age < $adult_age), m sort

sort raceth 
by raceth: tab ultra_simple_rel if (from_age < $adult_age), m sort

sort hheduc
by hheduc: tab ultra_simple_rel if (from_age < $adult_age), m sort

preserve

keep if hheduc==4 & raceth==1

tab ultra_simple_rel if (from_age < $adult_age), m sort

restore
