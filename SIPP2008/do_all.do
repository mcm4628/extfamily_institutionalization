
global first_wave 1
global final_wave 15
global second_wave = ${first_wave} + 1
global penultimate_wave = ${final_wave} - 1

global adult_age 18

global refmon 4



global projdir "/Users/Robert/ChildHH/SIPP2008"


do "$childhh_base_code/do_and_log" merge_waves
do "$childhh_base_code/do_and_log" make_auxiliary_datasets
do "$childhh_base_code/do_and_log" convert_to_wide
do "$childhh_base_code/do_and_log" normalize_ages
do "$childhh_base_code/do_and_log" compute_relationships
