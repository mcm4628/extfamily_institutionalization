global replace "replace"
log using "$logdir/who_changes_long", text $replace

use "$tempdir/who_changes"

drop shhadid_members* max_shhadid_members*
reshape long SHHADID addr_change comp_change leavers stayers arrivers adj_age, i(SSUID EPPPNUM) j(SWAVE)

drop if (missing(comp_change) & missing(addr_change))

save "$tempdir/who_changes_long", $replace


capture program drop convert_to_long
program define convert_to_long
    args person_type

    if ("`person_type'" == "leaver") {
        drop stayers arrivers
    }
    if ("`person_type'" == "arriver") {
        drop stayers leavers
    }
    if ("`person_type'" == "stayer") {
        drop leavers arrivers
    }

    gen n_`person_type's = wordcount(`person_type's)
    egen max_`person_type's = max(n_`person_type's)
    forvalues my_hh_member_num = 1/`=max_`person_type's' {
        gen my_hh_member = word(`person_type's, `my_hh_member_num')
        gen `person_type'_epppnum`my_hh_member_num' = real(my_hh_member)
        drop my_hh_member
    }
    
    reshape long `person_type'_epppnum, i(SSUID EPPPNUM SWAVE) j(`person_type'_num)

    drop `person_type's
    drop if missing(`person_type'_epppnum)

    save "$tempdir/`person_type's_long", $replace
end


use "$tempdir/who_changes_long"
convert_to_long leaver
use "$tempdir/who_changes_long"
convert_to_long arriver
use "$tempdir/who_changes_long"
convert_to_long stayer

log close
