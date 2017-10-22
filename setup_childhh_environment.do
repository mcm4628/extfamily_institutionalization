* Set up the base ChildHH (Children's Households) environment.

* If you pass an argument it must be "usebox"
* indicating that you want to use the default Box directory
* for the project.  Currently we don't have one, so this will
* cause the script to halt.

* The default behavior is to assume the current directory
* is the one with the base ChildHH code.

* We expect to find your setup file, named setup_<username>.do
* in the base ChildHH directory (as defined above).

args usebox


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


if ("`usebox'" == "") {
    global childhh_base_code "`c(pwd)'"
}
else {
    if ("`usebox'" == "usebox") {
        display "TODO:  Decide what the Box location is going to be if we have one."
        exit
        global child_base_code ""
        cd $childhh_base_code
    }
    else {
        display "Unrecognized argument:  `usebox'"
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
if ("$logdir" == "") {
    display as error "logdir macro not set."
    exit
}
if ("$boxdir" == "") {
    display as error "boxdir macro not set."
    exit
}


* Files created from original data to be used by other project members or 
* to support analyses in papers are put in the "shared" directory.
* If a file is in the shared directory, there should be code that takes us from
* an original data file to the shared data file. The name of the file with 
* that code should be the same name as the shared data file.
global SIPP2008 "$boxdir/SIPP/data/SIPP2008"
global SIPP2014 "$boxdir/SIPP/data/SIPP2014"
global sharedata "$boxdir/SIPP/data/shared"
