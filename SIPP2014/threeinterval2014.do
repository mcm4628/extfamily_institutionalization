*************************************************************
* This file calls programs to creates threeinterval2014.dta *
*************************************************************
*************************************************************
* The resulting data file describes change in household composition 
* in three intervals: Jan-April, April-August, August-December.
*
* Four month intervals were created to parallel analyses with the 
* SIPP 2008. Of course, it would be possible to do one-month intervals,
* but I doubt the results would be much different.
*
* The reference year in SIPP2014 Wave 1 is 2013.
*
************************************************************************

************************************************************************
*  
* Prep creates strings of variables describing individual's households 
* in each month. allHHX has the person-numbers for each person in the 
* household in month X. srrel_pnum* are the person-numbers in string form 
* but not concatenated.
*
* Prep then merges month 8 to month 12 to create a combined data file. 
* Similar process for other two intervals 8 to 4, 4 to 1.
*
* The anydiffXXX programs compares the household composition in the two waves
* using the strpos command.
*
* hhldr creates a dummy indicator for whether this individual is 
* the householder.
*
* pchangehc creates indicators of whether this person had any cohabiting partner
* or spouse during the reference period. And whether this person experienced
* a change in spouse/partner in the reference period.
*
* idpartner.do is a file that creates person number of partner 
* I will merge this onto the child record after childrenHH14 creates biomom_pnum
* Will only work if mom is in the household at interview
*
* t2parentw.do creates variables identifying whether there is a type-2 
* biological mother in the household each month. 
* 
* childrenHH14 identifies whether an individual is living with his or her 
* type 1 or type 2) biological mother in each of the reference months. 
* Checking EPNPAR1, EPNPAR2, EPAR1TYP, and EPAR2TYP gets biological mothers 
* living with the respondent at the time of the SIPP 2014 Survey (i.e. type 1 
* household members). People in the household during the reference period 
* but not at time of [Wave 1] interview are called "type 2." 
*
* Combine_intervals merges together all three intervals

capture log close
log using "$logdir/threeinterval2014", text $replace


* I would love to turn off line wrap so the state is a single
* continuous string.  This seems not to be possible.  The best
* we can do is set the line length to 255.  That's about 20 times
* too short so why bother.
*
* Also, I considered saving the state as a note in the dataset
* but this generic do file can't assume there is a dataset at all.
display "Starting random number generator state"
display "`c(rngstate)'"

set varabbrev off

macro list

pwd

do "$projcode\SIPP2014\prep.do"

do "$projcode\SIPP2014\anydiff812w.do"
do "$projcode\SIPP2014\anydiff48w.do"
do "$projcode\SIPP2014\anydiff14w.do"

do "$projcode\SIPP2014\hhldrw.do"

do "$projcode\SIPP2014\pchangehc.do"

do "$projcode\SIPP2014\idpartner.do"

do "$projcode\SIPP2014\t2parentw.do"

do "$projcode\SIPP2014\childrenHH14.do"

do "$projcode\SIPP2014\combine_intervals.do"

display "Ending random number generator state"
display "`c(rngstate)'"
log close
