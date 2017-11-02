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
duplicates drop SSUID SWAVE relfrom relto relationship, force

clear
