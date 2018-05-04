//============================================================================================//
//===========Children's Household Instability Project                    ====================//
//===========Dataset: SIPP2008                                           ====================//
//===========Purpose: This file contains programs to merge all the waves ====================//
//===========================================================================================//

** Function: to load first wave dataset into STATA 
use "$SIPP2008/wave${first_wave}_extract"

** Function: keep records from the 4th reference month
keep if SREFMON == ${refmon}

** Function: combine all the waves using 'append', make sure to keep only the records from the 4th reference month.
forvalues wave = $second_wave/$final_wave {
    append using "$SIPP2008/wave`wave'_extract"
    keep if SREFMON == ${refmon} 
}
** Output: save the combined dataset into temporary working directory
save "$tempdir/allwaves", $replace
