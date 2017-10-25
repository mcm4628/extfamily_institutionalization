* This file executes do files, but first executes
* standard startup boilerplate and last executes
* standard completion boilerplate.

* It also assumes the existence of $projdir
* which indicates the location of project do files.
* 
* It takes a single parameter, the basename of the
* do file.  This is used as the basename of the log file.
* "Basename" just means the name without the .do on the end.



args fname


do "$childhh_base_code/childhh_prolog" "`fname'"


do "$projdir/`fname'"


do "$childhh_base_code/childhh_epilog" "`fname'"
