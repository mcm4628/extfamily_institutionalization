//====================================================================//
//===== Children's Household Instability Project                    
//===== Dataset: SIPP2008                                           
//===== Purpose: This code append all waves of SIPP2008 original data into a long form dataset. 
//=====================================================================//

** Import first wave. 
use "$SIPP08keep/wave${first_wave}_extract", clear 

** Append the first wave with waves from the second to last, also keep only observations from the reference month. 
forvalues wave = $second_wave/$final_wave {
    append using "$SIPP08keep/wave`wave'_extract"
}

gen panelmonth=(SWAVE-1)*4+SREFMON

** allwaves.dta is a long-form datasets include all the waves from SIPP2008, all months
save "$tempdir/allmonths", $replace
