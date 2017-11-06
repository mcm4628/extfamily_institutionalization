#!/bin/bash

if [ $# -lt 1 ]
then
    echo "Usage:  $0 <field_list_file> [<SIPP2014_data_file>]"
    echo ""
    echo "   Optionoally, provide a second parameter specifying the"
    echo "   location of the SIPP 2014 data file."
    echo "   In the absernce of a second parameter the location"
    echo "   defaults to the zip file in our shared data directory,"
    echo "   which means this script will unzip it first."
    echo ""
    echo "   At present, the unzipped file is left in this directory."
    echo "   So don't forget to delete it if you don't want it eating your disl space."
    echo ""
    echo "   The format of the <field_list_file> should be"
    echo "   one variable per line, with the variable name first"
    echo "   and then the column range specified as two integers"
    echo "   separated by a hyphen.  It's ok to just list the"
    echo "   column once if the field is a single column, but"
    echo "   it's also ok to list it as a range, e.g. '22 - 22'"
    echo ""
    echo "   Example:"
    echo "      SSUID 	1 - 12"
    echo "      SHHADID	13 - 15"
    echo "      PNUM	21 - 23"
    echo "      ERACE	111 - 111"
    echo "     or"
    echo "      ERACE	111"
    exit 1
fi

if [ $# -gt 1 ]
then
    datafile=$2
else
    unzip "/Users/Robert/Box Sync/SIPP/data/SIPP2014/pu2014w1_dat.zip"
    datafile=./pu2014w1.dat
fi


infile="$1"

sed -e 's/\$//' -e "s/\-/ /" < "$infile" > $$.fields

# echo "FIELDS" 
# cat $$.fields
# exit 1

./extract_data.pl $$.fields < $datafile

rm $$.fields
