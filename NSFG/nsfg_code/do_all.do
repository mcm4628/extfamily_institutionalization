* The following is executed without being logged.  We can't use do_and_log
* because we need the macros for temp dir and log dir to pass to it.
* It's all ok, really, because we list all macros when we use do_and_log later.

* We require that the user define macros telling us where
* to find the project code and where to put the logs.
if ("$nsfg_base" == "") {
    display as error "nsfg_base macro not set."
    display as error "This macro tells us where to find the project code."
    exit
}

* I think we need to rename this to nsfg_logs but just to get things going without
* breaking existing setup files let's leave it as is.
if ("$logdir" == "") {
    display as error "logdir macro not set."
    display as error "This macro tells us where to put the log files."
    exit
}


* We also currently require childhh_base_code to be defined because
* that's where the infrastructure code lives.
if ("$childhh_base_code" == "") {
    display as error "childhh_base_code macro not set."
    display as error "This macro tells us where to find the infrastructure files."
    exit
}


* We check to make sure the required directories exist.
capture confirmdir "$logdir"
if `r(confirmdir)' {
    display as error "The logdir macro specifies a directory that does not exist:  $logdir"
    exit
}

capture confirmdir "$nsfg_base"
if `r(confirmdir)' {
    display as error "The nsfg_base macro specifies a directory that does not exist:  $nsfg_base"
    exit
}


do "$childhh_base_code/do_and_log" "$NSFG_code" "$logdir" union_create
do "$childhh_base_code/do_and_log" "$NSFG_code" "$logdir" union_analysis
do "$childhh_base_code/do_and_log" "$NSFG_code" "$logdir" pyunion_analysis
