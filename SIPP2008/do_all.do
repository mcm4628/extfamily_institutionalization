
global first_wave 1
global final_wave 15
global second_wave = ${first_wave} + 1
global penultimate_wave = ${final_wave} - 1

global adult_age 18

global refmon 4

* We require that the user define macros telling us where
* to find the project code and where to put the logs.
if ("$sipp2008_code" == "") {
    display as error "sipp2008_code macro not set."
    display as error "This macro tells us where to find the project code."
    exit
}

if ("$sipp2008_logs" == "") {
    display as error "sipp2008_logs macro not set."
    display as error "This macro tells us where to put the log files."
    exit
}


* Possible to-do:  We could create the log directory if it doesn't exist.
* Alternatively, we could check to make sure they do exist.
* For now, you're on your own.



do "$childhh_base_code/do_and_log" "$sipp2008_code" "$sipp2008_logs" merge_waves
do "$childhh_base_code/do_and_log" "$sipp2008_code" "$sipp2008_logs" make_auxiliary_datasets
do "$childhh_base_code/do_and_log" "$sipp2008_code" "$sipp2008_logs" convert_to_wide
do "$childhh_base_code/do_and_log" "$sipp2008_code" "$sipp2008_logs" normalize_ages
do "$childhh_base_code/do_and_log" "$sipp2008_code" "$sipp2008_logs" compute_base_relationships

* The number of transitive closure passes we want to do.
global max_tc 3

do "$childhh_base_code/do_and_log" "$sipp2008_code" "$sipp2008_logs" compute_secondary_relationships
do "$childhh_base_code/do_and_log" "$sipp2008_code" "$sipp2008_logs" who_changes
do "$childhh_base_code/do_and_log" "$sipp2008_code" "$sipp2008_logs" who_changes_long
do "$childhh_base_code/do_and_log" "$sipp2008_code" "$sipp2008_logs" who_changes_analysis
