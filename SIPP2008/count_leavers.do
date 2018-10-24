//==============================================================================
//===== Children's Household Instability Project
//===== Dataset: SIPP2008
//===== Purpose:  Generate a measure of the number of people leaving ego's household
//==============================================================================

use "$tempdir/hh_leavers", clear

destring leaver, replace

collapse (count) leaver, by(SSUID EPPPNUM SWAVE)

rename leaver num_leavers

save "$tempdir/counted_leavers", $replace
