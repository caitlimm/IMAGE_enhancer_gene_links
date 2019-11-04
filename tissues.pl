#!/usr/local/bin/perl -w
#use strict;

#tissues.pl
#takes TSSbTAD and enhancersbTAD and determines the links between them via TAD

#ARGV[0] is linkstTAD
#ARGV[1] is tissuetable
#ARGV[2] is the output file containing the links e.g. linkstTADtissues

use Time::HiRes qw(usleep ualarm gettimeofday tv_interval nanosleep clock_gettime clock_getres clock_nanosleep clock stat);

use POSIX qw(ceil floor);

my $start_time = [Time::HiRes::gettimeofday()];

my ($enhID, $panthID, $assay, $tissueID, $tissue, %tissues, $tiss);

open (TISS,'<',$ARGV[1]) or die $!; #tissuetable
while (my $line=<TISS>){
#6	Artery Tibial
	chomp $line;
	($tissueID, $tissue)=(split /\t/, $line); 
	#$tissue =~ s/\-//g;
	$tissue =~ s/\s/\_/g;
	$tissues{$tissue}=$tissueID;
}
close TISS;
open OUT, "> $ARGV[2]" or die $!; #linksbTADtissues
open (TSS,'<',$ARGV[0]) or die $!; #linkstTAD
#1       HUMAN|Gene=LPPR4|UniProtKB=Q7Z2D5       A549    3
while(my $line=<TSS>){
	chomp $line;
	($enhID, $panthID, $tiss, $assay)=(split /\t/, $line);
	$cell=$tissues{$tiss};
	print OUT "$enhID\t$panthID\t$cell\t$assay\n";
}
close TSS;
close OUT;

my $diff = Time::HiRes::tv_interval($start_time);

print "\n\n$diff\n";