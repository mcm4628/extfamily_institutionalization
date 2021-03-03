* Create Family Institutionalization results

* must have run setup_childhh_environment

do "$childhh_base_code/SIPP2008/allmonths/HouseholdType/faminst_prepdata.do"
do "$childhh_base_code/SIPP2008/allmonths/HouseholdType/faminst_results.do"

do "$childhh_base_code/SIPP2014/allmonths/HouseholdType/faminst_prepdata.do"
do "$childhh_base_code/SIPP2014/allmonths/HouseholdType/faminst_results.do"
