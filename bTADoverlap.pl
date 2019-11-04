#!/usr/local/bin/perl -w
#use strict;

#bTADoverlap.pl
#prepares TADs (boundary.8|hg19|chr10:7600001-7640000___boundary.9|hg19|chr10:8480001-8520000) to be overlapped with enhancers via bedtools

#ARGV[0] is the TAD input file e.g. bTAD
#ARGV[1] is the output file containing the bed formatted bTAD regions to be overlapped i.e. bTADorder
#ARGV[2] is the cell type e.g. SK-MEL-5

use Time::HiRes qw(usleep ualarm gettimeofday tv_interval nanosleep clock_gettime clock_getres clock_nanosleep clock stat);

use POSIX qw(ceil floor);

my $start_time = [Time::HiRes::gettimeofday()];

my ($line, $chr, $start1, $end1, $location, $pval, $score, $one, $two, $three, $four, $five, $six, $s1, $s2, $e1, $e2, $start, $end, $total, %hash);

my $chunk=(1000000);
my $tadcell=$ARGV[2];
open (FH,'<',$ARGV[0]); #or @ARGV[0]
#chr10	7600001	8520000	boundary.8|hg19|chr10:7600001-7640000___boundary.9|hg19|chr10:8480001-8520000	0.818515985355
open OUT, "> $ARGV[1]" or die $!; 

while(my $line=<FH>){
	chomp $line;
	($chr, $start1, $end1, $location, $pval)=(split /\t/, $line);
	$score="$pval\|$tadcell";
	($one, $two)=((split /\_\_\_/, $location)[0,1]); #one: boundary.8|hg19|chr10:7600001-7640000 two: boundary.9|hg19|chr10:8480001-8520000
	$three=((split /\|/, $one)[2]); #chr10:7600001-7640000
	$four=((split /\|/, $two)[2]);
	$five=((split /\:/, $three)[1]); #7600001-7640000
	$six=((split /\:/, $four)[1]);
	($s1, $s2)=(split /\-/, $five); #7600001 7640000
	($e1, $e2)=(split /\-/, $six);
	$start = (floor(($s1 + $s2)/2));
	$end=(ceil(($e1 + $e2)/2));
	$total="$chr\t$start\t$end\t$location\t$score";
	$hash{$total}=1;
}

foreach my $key (sort keys %hash){
	print OUT "$key\n";
}

close OUT;

my $diff = Time::HiRes::tv_interval($start_time);

print "\n\n$diff\n";