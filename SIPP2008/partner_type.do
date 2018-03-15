* Compute partner type for young women,
* using the directly derived relationships (TC0),
* and the first pass of secondary relationships (TC1).

* Define the age range for "young" women.
local min_age 17
local max_age 25

forvalues tc = 0/1 {
    use "$tempdir/person_wide_adjusted_ages"

    keep SSUID EPPPNUM SHHADID* adj_age* my_sex

    reshape long SHHADID adj_age, i(SSUID EPPPNUM) j(SWAVE)


    * This just drops people who were not present in a wave.
    * The assert confirms that we're not missing any ages when data is present.
    assert (missing(SHHADID) == missing(adj_age))
    drop if missing(adj_age)


    * Keep young women.
    keep if ((my_sex == 2) & (adj_age >= `min_age') & (adj_age <= `max_age'))
    * TODO:  my_sex is unlabled.  Sigh.  Go fix that where we generate it.
    

    * Now grab the relationship variable.
    gen relfrom = EPPPNUM
    merge 1:m SWAVE SSUID relfrom using "$tempdir/relationships_tc`tc'_resolved", keepusing(relationship)
    keep if (_merge != 2)
    drop relfrom


* Compute partner type, giving precedence to spouse,
* then partner.  If we don't have any relationship data
* for the person at all we mark partner type as missing.
#delim ;
    gen partner_type = cond(relationship == "SPOUSE":relationship, 2,
                       cond(relationship == "PARTNER":relationship, 1,
                       cond(_merge == 1, .,
                       0)));
#delim cr

    drop _merge

    * Take the max partner type, so this gives precedenct to spouse, 
    * then partner.
    collapse  (max) partner_type  (first) adj_age, by(SWAVE SSUID EPPPNUM)

    label variable partner_type "Spouse, partner, or none"
#delim ;
    label define partner_type 
        2 "spouse"
        1 "partner"
        0 "none"
        ;
#delim cr
    label values partner_type partner_type

    tab partner_type, m
    tab partner_type adj_age, m
    tab partner_type adj_age, m col

    * And save the TC`tc' young women's partnership data.
    save "$tempdir/partner_type_tc`tc'", $replace
}
