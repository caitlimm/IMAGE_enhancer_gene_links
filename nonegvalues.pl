#!/usr/local/bin/perl -w
use strict;

#nonegvalues.pl

#ARGV[0] is the bed file that is to be screened for negative coordinate values e.g. hES.enh_1e-4.bed
#ARGV[1] is the bed file with all negative coordinate valued lines tossed out e.g. nn_hES.enh_1e-4.bed
#ARGV[2] is the lines that were tossed out for having negative coordinate values e.g. out

use Time::HiRes qw(usleep ualarm gettimeofday tv_interval nanosleep clock_gettime clock_getres clock_nanosleep clock stat);

my $start_time = [Time::HiRes::gettimeofday()];

use POSIX qw(ceil floor);

my ($chr, $start, $end, @rest);
open OUT, "> $ARGV[1]" or die $!;
open NEG, "> $ARGV[2]" or die $!;
open (FAN,'<',$ARGV[0]) or die $!;
#chrX    152480000       152520000       ZNF275:-80Kb:5.4e-14:1.1e-15:16:54
while (my $line=<FAN>){
	chomp $line;
	($chr, $start, $end, @rest)=(split /\t/, $line);
	if (($start < 0) || ($end < 0)){
		print NEG "$line\n";
	}
	else {
		print OUT "$line\n";
	}
}
close FAN;
close NEG;
close OUT;

my $diff = Time::HiRes::tv_interval($start_time);

print "\n\n$diff\n";