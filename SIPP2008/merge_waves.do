//====================================================================//
//===== Children's Household Instability Project                    
//===== Dataset: SIPP2008                                           
//===== Purpose: This code megers all waves of SIPP2008 data into a long form dataset. 
//               It keeps only observations in the reference month (4).  
//=====================================================================//


use "$SIPP2008/wave${first_wave}_extract"

keep if SREFMON == ${refmon}


forvalues wave = $second_wave/$final_wave {
    append using "$SIPP2008/wave`wave'_extract"
    keep if SREFMON == ${refmon} 
}


save "$tempdir/allwaves", $replace
