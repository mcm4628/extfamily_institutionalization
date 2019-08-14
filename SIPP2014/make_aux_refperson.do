*** We also need a dataset of reference persons.
use "$tempdir/allwaves"
keep SSUID PNUM SHHADID ERELRP ESEX SWAVE EEDUC
keep if ((ERELRP == 1) | (ERELRP == 2))
drop ERELRP

recode EEDUC (31/38 = 1)  (39 = 2)  (40/42 = 3)  (43/46 = 4), gen (educ)

rename PNUM ref_person
rename ESEX ref_person_sex
rename educ ref_person_educ

label values ref_person_educ educ

drop EEDUC

duplicates drop
save "$tempdir/ref_person_long", $replace

reshape wide ref_person ref_person_sex ref_person_educ, i(SSUID SHHADID) j(SWAVE)
save "$tempdir/ref_person_wide", $replace
