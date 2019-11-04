#!/usr/local/bin/perl -w
#use strict;

#tTADoverlap.pl
#prepares TADs (chr1    71080001        71560000        tad83|hg19|chr1:71080001-71560000       1000    ACHN) to be overlapped with enhancers via bedtools

#ARGV[0] is the TAD input file e.g. tTAD
#ARGV[1] is the output file containing the bed formatted TAD regions to be overlapped with TADs i.e. tTADorder
#ARGV[2] is the cell type e.g. ACHN

use Time::HiRes qw(usleep ualarm gettimeofday tv_interval nanosleep clock_gettime clock_getres clock_nanosleep clock stat);

use POSIX qw(ceil floor);

my $start_time = [Time::HiRes::gettimeofday()];

my ($line, $chr, $start, $end, $location, $name, $build, $pval);

my $chunk=(1000000);

my $tadcell=$ARGV[2];

open (FH,'<',$ARGV[0]); #or @ARGV[0]
#chr1    71080001        71560000        tad83|hg19|chr1:71080001-71560000       1000
open OUT, "> $ARGV[1]" or die $!; 

while(my $line=<FH>){
	chomp $line;
	($chr, $start, $end, $location, $pval)=(split /\t/, $line);
	$score="$pval\|$tadcell";
	print OUT "$chr\t$start\t$end\t$location\t$score\n";
}

close OUT;

my $diff = Time::HiRes::tv_interval($start_time);

print "\n\n$diff\n";