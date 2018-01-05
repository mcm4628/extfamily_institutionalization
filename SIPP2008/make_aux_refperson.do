*** We also need a dataset of reference persons.
use "$tempdir/allwaves"
keep SSUID EPPPNUM SHHADID ERRP ESEX SWAVE
keep if ((ERRP == 1) | (ERRP == 2))
drop ERRP
rename EPPPNUM ref_person
rename ESEX ref_person_sex
duplicates drop
save "$tempdir/ref_person_long", $replace

reshape wide ref_person, i(SSUID SHHADID) j(SWAVE)
save "$tempdir/ref_person_wide", $replace
