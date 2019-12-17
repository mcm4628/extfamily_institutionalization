***
*
* USE RREL and RRELPUM variables to describe each person's relationship to every other person in the household by month
* 
* The RREL variables RREL1-RREL20 are for type 1 persons and RREL21-RREL30 are for type 2 persons

use "$SIPP14keep/demo_long_interviews_am.dta", clear

keep SSUID ERESIDENCEID PNUM panelmonth adj_age my_sex my_race* educ

save "$tempdir/onehalf", $replace

rename PNUM from_num
rename adj_age from_age
rename my_sex from_sex
rename my_race from_race
rename educ from_educ

joinby SSUID ERESIDENCEID panelmonth using "$tempdir/onehalf"

rename PNUM to_num
rename adj_age to_age
rename my_sex to_sex
rename my_race to_race
rename educ to_educ

sort SSUID ERESIDENCEID panelmonth from_num to_num

drop if from_num==to_num

save "$tempdir/allpairs", $replace

* want to merge this onto the relationship_pairs data to refine relationship variables
