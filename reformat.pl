#!/usr/local/bin/perl -w
#use strict;

#reformat.pl
#takes out_1 and gives an output file with format enhancerID\tPANTHERgene\ttissueID\tassay\tp-value\n

use Time::HiRes qw(usleep ualarm gettimeofday tv_interval nanosleep clock_gettime clock_getres clock_nanosleep clock stat);

my $start_time = [Time::HiRes::gettimeofday()];

use POSIX qw(ceil floor);

#ARGV[0] is out_1
#ARGV[1] is the out file e.g. intTADlinks_hES_1e-4

open (INT,'<',$ARGV[0]) or die $!; 
open OUT, "> $ARGV[1]" or die $!; 

my ($echr, $estart, $eend, $enhID, $pchr, $pstart, $pend, $gene, $pval, $tissue, $break, %hash);

while (my $line=<INT>){
#chr1	100000188	100000393	1	chr1	100000000	100040000	HUMAN|HGNC=321|UniProtKB=P35573	2e-06	hES
	chomp $line;
	($echr, $estart, $eend, $enhID, $pchr, $pstart, $pend, $gene, $pval, $tissue)=(split /\t/, $line); 
	$break="$echr\t$estart\t$eend\t$enhID\t$gene\t$tissue\tTADinteractions\t$pval";
	$hash{$break}=1;
}

close INT;

foreach my $key (sort keys %hash){
	print OUT "$key\n";
}

close OUT;

my $diff = Time::HiRes::tv_interval($start_time);

print "\n$diff\n";