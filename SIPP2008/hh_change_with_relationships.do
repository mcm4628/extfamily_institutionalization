
use "$tempdir/hh_change_for_relationships"

keep SSUID EPPPNUM SHHADID* adj_age* arrivers* leavers* stayers* comp_change* comp_change_reason* my_race my_sex 


reshape long SHHADID adj_age arrivers leavers stayers comp_change comp_change_reason, i(SSUID EPPPNUM) j(SWAVE)

gen have_arrivers = (indexnot(arrivers, " ") != 0)
gen have_leavers = (indexnot(leavers, " ") != 0)

gen have_changers = (have_arrivers | have_leavers)

tab comp_change have_changers

assert (have_changers == 0) if (comp_change == 0)
assert (have_changers == 0) if missing(comp_change)

* It shouldbe the case that comp_change == 1 means have_changers == 1,
* but it's not so let's debug it.

list if (comp_change == 1) & (have_changers == 0)

save "$tempdir/hh_change_with_relationships", $replace
