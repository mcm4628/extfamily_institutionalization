*** We also need a dataset of reference persons.
use "$SIPP14keep/allmonths14"
keep SSUID PNUM SHHADID ERELRP ESEX panelmonth EEDUC
keep if ((ERELRP == 1) | (ERELRP == 2))
drop ERELRP

duplicates report SSUID SHHADID panelmonth // each address has one reference person per month


recode EEDUC (31/38 = 1)  (39 = 2)  (40/42 = 3)  (43/46 = 4), gen (educ)

rename PNUM ref_person
rename ESEX ref_person_sex
rename educ ref_person_educ

label values ref_person_educ educ

drop EEDUC

save "$tempdir/ref_person_long", $replace

*reshape wide ref_person ref_person_sex ref_person_educ, i(SSUID SHHADID) j(panelmonth)
save "$tempdir/ref_person_wide", $replace
