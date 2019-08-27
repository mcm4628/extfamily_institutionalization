//==============================================================================//
//===== Relationship formation
//===== Dataset: SIPP2008
//===== Purpose: Executes do files to create core datafiles:
//===== 

//=========================================================================//
//== Purpose: Preparation for running the program.
//== 
//== Note: This program requires the mdesc and confirmdir packages. If you do not have this, type ssc install mdesc/confirmdir before running.
//=========================================================================//

***************************************************************************
** Section: The following code attempts to make sure these packages are installed before allowing execution.
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
** Section: Creates macros for wave, age, month, relationships
***************************************************************************
global first_wave 1
global final_wave 16
global second_wave = ${first_wave} + 1
global penultimate_wave = ${final_wave} - 1

global adult_age 18

***************************************************************************
** Section: Check to make sure the required directories exist.
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

********************************************************************************
* Execute scripts to process data.
********************************************************************************
** Extracts data from NBER download and formats it for our scripts
do marriage_extract_and_format.do

** Combines all the waves into a long file where every person-wave is a record. 
do merge_waves  

