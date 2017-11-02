*** TODO:  Is it more efficient to use categories?

use "$tempdir/base_relationships"

rename relfrom relative2
rename relationship relationship2
tempfile relmerge
save `relmerge'


use "$tempdir/base_relationships"
rename relto relative2
rename relationship relationship1

joinby SSUID SHHADID SWAVE relative2 using `relmerge'

* We don't care to keep (or validate correctness of) relationship of self to self.
drop if (relfrom == relto)

tab relationship1 relationship2

save "$tempdir/relationship_pairs_tc1", $replace


gen relationship = ""
replace relationship = "GRANDCHILD" if ((relationship1 == "CHILD") & (relationship2 == "CHILD"))
replace relationship = "GREATGRANDCHILD" if ((relationship1 == "CHILD") & (relationship2 == "GRANDCHILD"))
replace relationship = "GREATGRANDCHILD" if ((relationship1 == "GRANDCHILD") & (relationship2 == "CHILD"))
replace relationship = "SIBLING" if ((relationship1 == "CHILD") & (relationship2 == "PARENT"))
replace relationship = "CHILDOFPARTNER" if ((relationship1 == "CHILD") & (relationship2 == "PARTNER"))
replace relationship = "AUNTUNCLE" if ((relationship1 == "CHILD") & (relationship2 == "SIBLING"))
replace relationship = "CHILD" if ((relationship1 == "CHILD") & (relationship2 == "SPOUSE"))

keep if (!missing(relationship))

* We force the drop because we don't care about the details if the end result is the same.
duplicates drop SSUID SHHADID SWAVE relfrom relto relationship, force

sort SSUID SHHADID SWAVE relfrom relto
by SSUID SHHADID SWAVE relfrom relto:  gen n = _N

* List anomalies in case we want to try to understand and recover them.
list if (n > 1)

* And then get rid of them, for now.
drop if (n > 1)

drop n
drop relative2 relationship1 relationship2
save "$tempdir/relationships_tc1", $replace


*** Append the new relationships to the old ones.
* Also, keep track of where we discovered the realtionships.
use "$tempdir/base_relationships"
gen relationship_source = "base"
append "$tempdir/relationships_tc1"
replace relationship_source = "tc1" if (missing(relationship_source))

* The only duplicates should be due to finding the same relationship in base and tc1.
duplicates drop SSUID SHHADID SWAVE relfrom relto relationship, force

* See if we have generated conflicting relationships by adding in tc1.
sort SSUID SHHADID SWAVE relfrom relto
by SSUID SHHADID SWAVE relfrom relto:  gen n = _N

* List anomalies in case we want to try to understand and recover them.
list if (n > 1)

* For now, we'll prefer the original relationship in case of conflicts.
drop if ((n > 1) & (relationship_source != "base"))

drop n

save "$tempdir/relationships", $replace
