//==============================================================================//
//===== Children's Household Instability Project
//===== Dataset: SIPP2008
//===== Purpose: Executes do files to create base datafiles:
//===== allwaves, shhadid_members (necessary?), adjusted_ages_long, and unified_rel



//=========================================================================//
//== Purpose: Preparation for running the program.
//== 
//== Note: This program requires the mdesc and confirmdir packages. If you do not have this, type ssc install mdesc/confirmdir before running.
//=========================================================================//

***************************************************************************
** Function: The following code attempts to make sure these packages are installed before allowing execution.
***************************************************************************
capture findfile mdesc.ado
if ("`r(fn)'" == "") {
    display as error "It appears the mdesc package is not installed."
    display as error "Try 'ssc install mdesc' to acquire it."
    exit
}

capture findfile confirmdir.ado
if ("`r(fn)'" == "") {
    display as error "It appears the confirmdir package is not installed."
    display as error "Try 'ssc install confirmdir' to acquire it."
    exit
}

***************************************************************************
** Function: Creates macros for wave, age, month, relationships
***************************************************************************
do "$childhh_base_code/SIPP2008/project_macros" /* this do-file contains macros of wave, age, month, relationships */

***************************************************************************
** Function: Check to make sure the required directories exist.
**
** Note: We require that the user define macros telling us where to find the project code and where to put the logs.
***************************************************************************


if ("$sipp2008_code" == "") {
    display as error "sipp2008_code macro not set."
    display as error "This macro tells us where to find the project code."
    exit
}

if ("$sipp2008_logs" == "") {
    display as error "sipp2008_logs macro not set."
    display as error "This macro tells us where to put the log files."
    exit
}

confirmdir "$sipp2008_logs"
if `r(confirmdir)' {
    display as error "The sipp2008_logs macro specifies a directory that does not exist:  $sipp2008_logs"
    exit
}

confirmdir "$sipp2008_code"
if `r(confirmdir)' {
    display as error "The sipp2008_code macro specifies a directory that does not exist:  $sipp2008_code"
    exit
}

//=========================================================================//
//== Purpose: Run the Programs.
//=========================================================================//

** This do-file combines all the waves. 
do "$childhh_base_code/do_and_log" "$sipp2008_code" "$sipp2008_logs" merge_waves  

** This do-file makes sub-datasets for analyses.
do "$childhh_base_code/do_and_log" "$sipp2008_code" "$sipp2008_logs" make_auxiliary_datasets 

/*
** This do-file generates a wide dataset by person (includes demographic information). 
do "$childhh_base_code/do_and_log" "$sipp2008_code" "$sipp2008_logs" convert_to_wide 

** This do-file makes sure ages are consistent in all the waves. 
do "$childhh_base_code/do_and_log" "$sipp2008_code" "$sipp2008_logs" normalize_ages 

** This do-file computes biderectional base relationships (mom, dad, child) 
do "$childhh_base_code/do_and_log" "$sipp2008_code" "$sipp2008_logs" compute_base_relationships 

** This do file computes secondary relationships. 
do "$childhh_base_code/do_and_log" "$sipp2008_code" "$sipp2008_logs" compute_secondary_relationships 

/** to be completed **/
do "$childhh_base_code/do_and_log" "$sipp2008_code" "$sipp2008_logs" hh_change_for_relationships 

** This program computes unified relationships. 
do "$childhh_base_code/do_and_log" "$sipp2008_code" "$sipp2008_logs" hh_change_with_relationships 

