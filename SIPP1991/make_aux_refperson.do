*** We also need a dataset of reference persons.
local panel="91"
use "$tempdir/allwaves`panel'", clear

keep SSUID EPPPNUM SHHADID ERRP ESEX SWAVE EEDUC
keep if ((ERRP == 1) | (ERRP == 2))

recode EEDUC (31/38 = 1)  (39 = 2)  (40/43 = 3)  (44/47 = 4), gen (educ)

rename EPPPNUM ref_person
rename ESEX ref_person_sex
rename educ ref_person_educ
rename ERRP ref_person_type

label values ref_person_educ educ

drop EEDUC

duplicates tag SSUID SHHADID SWAVE, gen(dupe) 

tab dupe

drop if dupe >= 1 & ref_person_type==2

save "$tempdir/ref_person_long", $replace

reshape wide ref_person ref_person_type ref_person_sex ref_person_educ, i(SSUID SHHADID) j(SWAVE)
save "$tempdir/ref_person_wide", $replace
