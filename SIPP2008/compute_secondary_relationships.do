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
append using "$tempdir/relationships_tc1"
replace relationship_source = "tc1" if (missing(relationship_source))

* The only duplicates should be due to finding the same relationship in base and tc1.
duplicates drop SSUID SHHADID SWAVE relfrom relto relationship, force

* See if we have generated conflicting relationships by adding in tc1.
sort SSUID SHHADID SWAVE relfrom relto
by SSUID SHHADID SWAVE relfrom relto:  gen n = _N

* How many anomalies?
count if (n > 1)
tab n

* There are some "conflicts" that aren't really conflicting.
* We need more complicated code if we get more than two relationships to consider.
assert n <= 2
* Copy the second relationship into the first record  and the first into the second so we can figure out what we want.
by SSUID SHHADID SWAVE relfrom relto:  gen relationship_2 = relationship[_n + 1] if ((n == 2) & (_n == 1))
by SSUID SHHADID SWAVE relfrom relto:  replace relationship_2 = relationship[_n - 1] if ((n == 2) & (_n == 2))
* We drop the record that has the less desirable relationship.
drop if ((n == 2) & (relationship == "CHILDOFPARTNER") & (relationship_2 == "CHILD"))
drop if ((n == 2) & (relationship == "OTHER_REL") & (relationship_2 == "AUNTUNCLE"))

* Surprising these were coded as OTHER_REL in the first place.
drop if ((n == 2) & (relationship == "OTHER_REL") & (relationship_2 == "SIBLING"))
drop if ((n == 2) & (relationship == "OTHER_REL") & (relationship_2 == "GRANDCHILD"))
drop if ((n == 2) & (relationship == "OTHER_REL") & (relationship_2 == "GREATGRANDCHILD"))

* OK?
drop if ((n == 2) & (relationship == "OTHER_REL") & (relationship_2 == "CHILDOFPARTNER"))
drop if ((n == 2) & (relationship == "NOREL") & (relationship_2 == "CHILDOFPARTNER"))
drop n relationship_2

* List anomalies in case we want to try to understand and recover them.
by SSUID SHHADID SWAVE relfrom relto:  gen n = _N
count if (n > 1)
tab n
list if (n > 1)

* For now, we'll prefer the original relationship in case of conflicts.
drop if ((n > 1) & (relationship_source != "base"))

drop n

save "$tempdir/relationships", $replace
