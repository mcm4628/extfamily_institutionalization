//====================================================================//
//===== Children's Household Instability Project                    
//===== Dataset: SIPP2008                                           
//===== Purpose: Merge all the waves.  
//=====================================================================//

*******************************************************
** Function: Load first wave dataset into STATA. 
*******************************************************
use "$SIPP2008/wave${first_wave}_extract"




*******************************************************
** Function: Keep records from the reference month.
*******************************************************
keep if SREFMON == ${refmon}



*******************************************************
** Function: Combine all the waves using 'append', make sure to keep only the records from the reference month.
*******************************************************
forvalues wave = $second_wave/$final_wave {
    append using "$SIPP2008/wave`wave'_extract"
    keep if SREFMON == ${refmon} 
}



save "$tempdir/allwaves", $replace
