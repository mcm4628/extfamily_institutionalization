//====================================================================//
//===== Relationship formation
//===== Dataset: SIPP2008                                           
//===== Purpose: This code append all waves of SIPP2008 original data into a long form dataset. 
//=====================================================================//

** Import first wave. 
use "$SIPP08keep/wave${first_wave}_mar_extract", clear 

** Append the first wave with waves from the second to last
forvalues wave = $second_wave/$final_wave {
    append using "$SIPP08keep/wave`wave'_mar_extract"
}

** allwaves.dta is a long-form datasets include all the waves from SIPP2008
save "$tempdir/allmonths", $replace
