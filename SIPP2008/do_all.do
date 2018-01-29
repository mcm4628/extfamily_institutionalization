* The following is executed without being logged.  We can't use do_and_log
* because we need the macros for temp dir and log dir to pass to it.
* It's all ok, really, because we list all macros when we use do_and_log later.
do "$childhh_base_code/SIPP2008/project_macros"

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


* We check to make sure the required directories exist.
capture confirmdir "$sipp2008_logs"
if `r(confirmdir)' {
    display as error "The sipp2008_logs macro specifies a directory that does not exist:  $sipp2008_logs"
    exit
}

capture confirmdir "$sipp2008_code"
if `r(confirmdir)' {
    display as error "The sipp2008_code macro specifies a directory that does not exist:  $sipp2008_code"
    exit
}



do "$childhh_base_code/do_and_log" "$sipp2008_code" "$sipp2008_logs" merge_waves
do "$childhh_base_code/do_and_log" "$sipp2008_code" "$sipp2008_logs" make_auxiliary_datasets
do "$childhh_base_code/do_and_log" "$sipp2008_code" "$sipp2008_logs" convert_to_wide
do "$childhh_base_code/do_and_log" "$sipp2008_code" "$sipp2008_logs" normalize_ages
do "$childhh_base_code/do_and_log" "$sipp2008_code" "$sipp2008_logs" compute_base_relationships

do "$childhh_base_code/do_and_log" "$sipp2008_code" "$sipp2008_logs" compute_secondary_relationships
* do "$childhh_base_code/do_and_log" "$sipp2008_code" "$sipp2008_logs" who_changes
* do "$childhh_base_code/do_and_log" "$sipp2008_code" "$sipp2008_logs" who_changes_long
* do "$childhh_base_code/do_and_log" "$sipp2008_code" "$sipp2008_logs" who_changes_analysis


do "$childhh_base_code/do_and_log" "$sipp2008_code" "$sipp2008_logs" pairs
do "$childhh_base_code/do_and_log" "$sipp2008_code" "$sipp2008_logs" pair_analysis
