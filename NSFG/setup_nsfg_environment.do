* Set up the base NSFG environment.

* The current directory is assumed to be the root NSFG directory (e.g. T:\data\NSFG).
* go to the root NSFG directory before executing this setup

* We expect to find your a file, named setup_<username>.do
* in the base directory (as defined above).

set varabbrev off, permanent

* Find my home directory, depending on OS.
if ("`c(os)'" == "Windows") {
    local temp_drive : env HOMEDRIVE
    local temp_dir : env HOMEPATH
    global homedir "`temp_drive'`temp_dir'"
    macro drop _temp_drive _temp_dir`
}
else {
    if ("`c(os)'" == "MacOSX") {
        global homedir : env HOME
    }
    else {
        display "Unknown operating system:  `c(os)'"
        exit
    }
}



* Project default is that we don't write over existing files.
* Change this in your project setup file if you really want,
* but for archiving replace is (generally) not allowed.
global replace ""




* It would be nice to check that the setup file exists.
do setup_`c(username)'



* We require that logdir and boxdir be set.
* Maybe we'll require some others as well.
*
* We are transitioning to requiring a logdir for each project,
* perhaps, but for now let's keep the overall logdir as well.
if ("$logdir" == "") {
    display as error "logdir macro not set."
    exit
}
if ("$boxdir" == "") {
    display as error "boxdir macro not set."
    exit
}


global nsfg_base "`c(pwd)'"
global nsfg_data "$boxdir/NSFG"

* This is a super-annoying consequence of having NSFG under the ChildHH umbrella
* but having ChildHH really mean both the overall project and be somewhat SIPP specific.
* We will want to rethink this but for now I think this will work.
global childhh_base_code "$nsfg_base/.."


* Files created from original data to be used by other project members or 
* to support analyses in papers are put in the "shared" directory.
* If a file is in the shared directory, there should be code that takes us from
* an original data file to the shared data file. The name of the file with 
* that code should be the same name as the shared data file.
global NSFG1995 "$nsfg_data/NSFG95"
global NSFG2002 "$nsfg_data/NSFG02"
global NSFG0610 "$nsfg_data/NSFG06"
global NSFG1113 "$nsfg_data/NSFG11_13"
global NSFG1315 "$nsfg_data/NSFG13_15"
global combined_data "$nsfg_data/combined_data"

global NSFG_code "$nsfg_base/nsfg_code"
