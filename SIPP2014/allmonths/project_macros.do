//================================================================================================//
//===== Children's Household Instability Project                                               
//===== Dataset: SIPP2014                                                                    
//===== Purpose: Create macros of waves, age, month, relationships. 
//===== Also, create program executed by multiple do files to reduce number of relationship categories.
//================================================================================================//

global first_wave 1
global final_wave 4
global first_month 1
global final_month = 4*12
global second_wave = ${first_wave} + 1
global penultimate_wave = ${final_wave} - 1
global second_month=$first_month + 1
global penultimate_month = $final_month - 1

global adult_age 18

global refmon1 4
global refmon2 8
global refmon3 12



** A global macro for the number of transitive closure passes we want to do.
global max_tc 1

