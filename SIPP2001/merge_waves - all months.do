//====================================================================//
//===== Children's Household Instability Project                    
//===== Dataset: SIPP2001                                           
//===== Purpose: This code append all waves of SIPP2001 original data into a long form dataset. 
//               It keeps only observations in the reference month (4).  
//=====================================================================//

** Import first wave. 
use "$SIPP01keep/wave${first_wave}_extract", clear 

** Keep only observations in the reference month. 
*keep if SREFMON == ${refmon}

** Append the first wave with waves from the second to last, also keep only observations from the reference month. 
forvalues wave = $second_wave/$final_wave {
    append using "$SIPP01keep/wave`wave'_extract"
    *keep if SREFMON == ${refmon} 
}

// Appending only worked when I inserted the full folder address - it didin't recognized the global

** allwaves.dta is a long-form datasets include all the waves from SIPP2001, month 4 data. 
save "$tempdir/allwaves", $replace
