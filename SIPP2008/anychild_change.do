* Create an indicator for whether one of the arrivers/leavers is a parent (relationship==child)

use "$tempdir/simpler_leaver_and_arriver_rels", clear

keep if from_age < $adult_age

rename relfrom EPPPNUM

* Use rel_is_confused, rel_is_ever_child, rel_is_ever_sibling to sort confused into sibling (17) and child (23).
* This makes estimate of percentage of "other" (i.e. non-parent, non-sibling) people in HH conservative.

gen diff_age=to_age-from_age

replace simplified_rel=17 if rel_is_confused==1 & rel_is_ever_sibling==1 & abs(diff_age) < 20
replace simplified_rel=23 if rel_is_confused==1 & rel_is_ever_parent==1 & diff_age >= 12

gen anychild=1 if simplified_rel==23
replace anychild=0 if missing(anychild)

sort SSUID EPPPNUM SWAVE

collapse (max) anychild, by(SSUID EPPPNUM SWAVE)

tab anychild

save "$tempdir/anychild_change", $replace

