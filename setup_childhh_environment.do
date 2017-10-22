* Set up the base ChildHH (Children's Households) environment.

* If you pass no arguments we will look for your project name
* in default_project.txt in your home directory.
* If there is no such file, we quit.

* If you pass one argument, it is the name of your project.

* If you pass two arguments, the first is the name of your project
* and the second can be anything, but tells us that you do not want
* us to assume that you are working in the lab in the normal
* environment.  Instead, we assume that you are in the directory
* you want to be considered the SIPP base.

* We expect to find your project setup file, named
* setup_`project_name'.do
* in the base SIPP directory (whether that is the default
* directory or the one you establish by providing the second argument.

args project basehere


* Find my home directory, depending on OS.
if ("$S_OS" == "Windows") {
    local temp_drive : env HOMEDRIVE
    local temp_dir : env HOMEPATH
    global homedir "`temp_drive'`temp_dir'"
    macro drop _temp_drive _temp_dir
}
else {
    global homedir : env HOME
}


if ("`basehere'" == "") {
    global sipp_base_code "$homedir/Box Sync/SIPP/code/SIPP2008/RaleySIPP/BaseProjectCode"
    cd "$sipp_base_code"
}
else {
    global sipp_base_code "`c(pwd)'"
}


* Project default is that we don't write over existing files.
* Change this in your project setup file if you really want,
* but for archiving replace is (generally) not allowed.
global replace ""




* If no project was specified, look for a specification of the
* default project in the home directory.
if ("`project'" == "") {
    capture confirm file "$homedir/default_project.txt"
    if (_rc == 0) {
        file open def_file using "$homedir/default_project.txt", read
        file read def_file project
        file close def_file
    }
}

if ("`project'" != "") {
    * It would be nice to check that the setup file exists.
    do setup_`project'
}
else {
    display as error "No project specified on the command line and no default project file found."
    exit
}



* We require that logdir be set.
* Maybe we'll require some others as well.
if ("$logdir" == "") {
    display as error "logdir macro not set."
    exit
}
if ("$projdir" == "") {
    display as error "projdir macro not set."
    exit
}
if ("$boxdir" == "") {
    display as error "boxdir macro not set."
    exit
}


* Consider an all-encomapssing named log file.
* Or at least show how it can be done.

* since 2008 was our original data file, it has this name. We 
* could change to SIPP2008 to be parallel to the other sources
* The named data file directories are from original data
* extracted directly from Census files.
*
* Files created from original data to be used by other project members or 
* to support analyses in papers are put in the "shared" directory.
* If a file is in the shared directory, there should be code that takes us from
* an original data file to the shared data file. The name of the file with 
* that code should be the same name as the shared data file.
global origdatadir "$boxdir/SIPP/data/SIPP2008"
global sharedata "$boxdir/SIPP/data/shared"
global SIPP2014 "$boxdir/SIPP/data/SIPP2014"
