*** We also need a dataset of reference persons.
use "$tempdir/allmonths"
keep SSUID EPPPNUM SHHADID ERRP ESEX EEDUCATE SWAVE

keep if ((ERRP == 1) | (ERRP == 2))

drop ERRP

* can the household reference person vary within address within wave? Seems like the answer should be no
duplicates report SSUID SHHADID SWAVE // yes, but we will fix that below

recode EEDUCATE (31/38 = 1)  (39 = 2)  (40/43 = 3)  (44/47 = 4), gen (educ)

rename EPPPNUM ref_person
rename ESEX ref_person_sex
rename educ ref_person_educ

label values ref_person_educ educ

drop EEDUCATE

bysort SSUID SHHADID SWAVE: keep if _n==1 // keep one observation per address per wave

save "$tempdir/ref_person_long_am", $replace

// below is not guaranteed to work right. removing to make sure I fix it if I try to use wide file
// the issue is that j is SWAVE and not panelmonth
*reshape wide ref_person ref_person_sex ref_person_educ, i(SSUID SHHADID) j(SWAVE)
*save "$tempdir/ref_person_wide_am", $replace
*rm "$tempdir/ref_person_wide_am.dta"
