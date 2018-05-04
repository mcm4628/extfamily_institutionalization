//========================================================================================//
//===========Children's Household Instability Project=====================================//
//===========Dataset: SIPP2008============================================================//
//===========Purpose: This file executes all do-files for the project=====================//
//=======================================================================================//


/**********************Preparation for running the program*******************************/ 
** NOTE:
*  This program requires the mdesc package. If you do not have this, type ssc install mdesc before running.
*  This program also requires the confirmdir package. If you do not have this, type ssc install confirmdir before running.

** Function: The following code is an attempt to make sure these packages are installed before allowing execution.

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

** Function: The following is executed without being logged.  
*  We can't use do_and_log, because we need the macros for temp dir and log dir to pass to it.

do "$childhh_base_code/SIPP2008/project_macros" /* this do-file contains macros of wave, age, month, relationships */

** Note: We require that the user define macros telling us where to find the project code and where to put the logs.
** Function: check to make sure the required directories exist.

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

/******************************Running the Programs********************************************/

do "$childhh_base_code/do_and_log" "$sipp2008_code" "$sipp2008_logs" merge_waves  /** this do-file combines all the waves **/
do "$childhh_base_code/do_and_log" "$sipp2008_code" "$sipp2008_logs" make_auxiliary_datasets /** this do-file makes sub-datasets for analyses **/
do "$childhh_base_code/do_and_log" "$sipp2008_code" "$sipp2008_logs" convert_to_wide /** this do-file generates a wide dataset by person (includes demographic information) **/
do "$childhh_base_code/do_and_log" "$sipp2008_code" "$sipp2008_logs" normalize_ages /** this do-file makes sure ages are consistent in all the waves **/

do "$childhh_base_code/do_and_log" "$sipp2008_code" "$sipp2008_logs" hh_characteristics /** this do-file contains tabulations of household characteristics **/

do "$childhh_base_code/do_and_log" "$sipp2008_code" "$sipp2008_logs" compute_base_relationships /** this do-file computes biderectional base relationships (mom, dad, child) **/

do "$childhh_base_code/do_and_log" "$sipp2008_code" "$sipp2008_logs" compute_secondary_relationships /** this do file computes secondary relationships? I need to work on it more to confirm later **/

/*Question: why are these do-files excluded from the program? */
* do "$childhh_base_code/do_and_log" "$sipp2008_code" "$sipp2008_logs" who_changes
* do "$childhh_base_code/do_and_log" "$sipp2008_code" "$sipp2008_logs" who_changes_long
* do "$childhh_base_code/do_and_log" "$sipp2008_code" "$sipp2008_logs" who_changes_analysis


* do "$childhh_base_code/do_and_log" "$sipp2008_code" "$sipp2008_logs" pairs
* do "$childhh_base_code/do_and_log" "$sipp2008_code" "$sipp2008_logs" pair_analysis


do "$childhh_base_code/do_and_log" "$sipp2008_code" "$sipp2008_logs" hh_change /** this do-file computes composition change and address change **/
do "$childhh_base_code/do_and_log" "$sipp2008_code" "$sipp2008_logs" hh_change_for_relationships /** to be completed **/
do "$childhh_base_code/do_and_log" "$sipp2008_code" "$sipp2008_logs" hh_change_with_relationships /** this program computes unified relationships **/
do "$childhh_base_code/do_and_log" "$sipp2008_code" "$sipp2008_logs" examine_households /** this do-file creates a pairwise dataset with every pair of people living together **/

do "$childhh_base_code/do_and_log" "$sipp2008_code" "$sipp2008_logs" changer_rels /** to be completed **/

do "$childhh_base_code/do_and_log" "$sipp2008_code" "$sipp2008_logs" count_rels /** this do-file computes the number of relations **/

do "$childhh_base_code/do_and_log" "$sipp2008_code" "$sipp2008_logs" partner_type /** this do-file computes partner type for young women(17-25) **/
