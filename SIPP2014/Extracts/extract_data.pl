#!/usr/bin/perl

use strict;

use Text::CSV;

my $csv = Text::CSV->new ( { binary => 1 } )  
                 or die "Cannot use CSV: ".Text::CSV->error_diag ();

if ($#ARGV != 0) {
    print "Usage:  $0 file_of_fields\n";
    exit(1);
}

my $field_list_filename = shift;

open(my $fh, "<", $field_list_filename) or die "Can't open $field_list_filename\n";

my @header;
my @start_col;
my @end_col;

while (<$fh>) {
    chomp();
    my @inline = split ' ', $_;

    # Skip blank lines.
    next if ($#inline == -1);

    die "ERROR:  Too many fields in line:  $_\n" if ($#inline > 2);
    die "ERROR:  Too few fields in line:  $_\n" if ($#inline < 1);

    push @header, $inline[0];
    push @start_col, $inline[1];
    push @end_col, $inline[$#inline];
}
close($fh);


my $status = $csv->combine(@header);
print $csv->string() . "\n";


while (<>) {
    chomp();

    my @values;

    for my $i (0 .. $#start_col) {
        my $val_length = $end_col[$i] - $start_col[$i] + 1;
        # The columns are numbered from 1.  Perl starts at zero.
        my $actual_col = $start_col[$i] - 1;
        $values[$i] = substr($_, $actual_col, $val_length);
    }

    my $status = $csv->combine(@values);
    print $csv->string() . "\n";
}
