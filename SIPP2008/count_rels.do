*** This computes the number of relationships, for everyone
* and then for kids.  This is total number across all waves,
* without regard to whether there is a composition change.

* The way this works is that it uses the lists of HH members we've previously
* computed (for each wave), and builds a list of people EPPPNUM ever lives
* with.  We have also previously computed the maximum number of HH members
* in any household in each wave.  We use that to determine how many people
* we have to loop through (in each wave), and happily the way word() works
* is that if we ask for the 10th person in a HH when there are less than ten
* total, we get back missing.

use "$tempdir/person_wide_adjusted_ages"


keep SSUID EPPPNUM shhadid_members* max_shhadid_members*

gen potential_rels = " "
forvalues wave = $first_wave/$final_wave {
    forvalues my_hh_member_num = 1/`=max_shhadid_members`wave'' {
        gen my_hh_member = word(shhadid_members`wave', `my_hh_member_num')
        replace my_hh_member = "X" if missing(my_hh_member)

        * We add this HH member to the list if:  1) they exist (not "X"); 
        * 2) they are not ego; and 3) they aren't already in the list.
        * (strpos(potential_rels, " " + my_hh_member + " ") == 0) is an idiom
        * that asks if my_hh_member is already in the list.
        replace potential_rels = potential_rels + my_hh_member + " " if ((my_hh_member != "X") & (my_hh_member != string(EPPPNUM)) & (strpos(potential_rels, " " + my_hh_member + " ") == 0))
        drop my_hh_member
    }
}

* wordcount tells us how many people are in the list.
gen num_potential_rels = wordcount(potential_rels)

* This gets N and mean so we can compute number of relationships.
summ num_potential_rels
display "Number of relationships:  `r(N)' * `r(mean)'"
display "Note that this includes both directions of each relationship,"
display "e.g., if A relates to B we also have the B to A relationship."

save "$tempdir/potential_rels", $replace




* Now repeat the above, but only for kids as the "source"
* of the relationship.  We make this restriction by checking
* adj_age at each wave.
use "$tempdir/person_wide_adjusted_ages"

keep SSUID EPPPNUM shhadid_members* max_shhadid_members* adj_age*

gen potential_rels = " "
forvalues wave = $first_wave/$final_wave {
    forvalues my_hh_member_num = 1/`=max_shhadid_members`wave'' {
        gen my_hh_member = word(shhadid_members`wave', `my_hh_member_num')
        replace my_hh_member = "X" if missing(my_hh_member)
        replace potential_rels = potential_rels + my_hh_member + " " if ((my_hh_member != "X") & (my_hh_member != string(EPPPNUM)) & (strpos(potential_rels, " " + my_hh_member + " ") == 0) & (adj_age`wave' < $adult_age))
        drop my_hh_member
    }
}

gen num_potential_rels = wordcount(potential_rels)

summ num_potential_rels
display "Number of relationships:  `r(N)' * `r(mean)'"
display "Note that this includes only relationships where the 'source'"
display "is a child, so we have bidirectional relationships only"
display "when both A and B are children."

save "$tempdir/child_potential_rels", $replace




