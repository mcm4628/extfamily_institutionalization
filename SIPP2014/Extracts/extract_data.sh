#!/bin/bash

if [ $# -ne 1 ]
then
    echo "Usage:  $0 <field_list_file>"
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


infile=$1

sed -e 's/\$//' -e "s/\-/ /" < $infile > $$.fields

# echo "FIELDS" 
# cat $$.fields
# exit 1

./extract_data.pl $$.fields < ./pu2014w1.dat

rm $$.fields
