#!/usr/local/bin/perl -w
#use strict;

#pantherIDweed.pl

#ARGV[0] is Whole_Blood_eqtl
#ARGV[1] is pantherGeneList.txt
#ARGV[2] is Whole_Blood_PANTHeqtls
#ARGV[3] is the leftovers that didn't match ENSGs to PANTHER IDs
use Time::HiRes qw(usleep ualarm gettimeofday tv_interval nanosleep clock_gettime clock_getres clock_nanosleep clock stat);

my $start_time = [Time::HiRes::gettimeofday()];

use POSIX qw(ceil floor);

my ($panth, $ensg, %hash, $count1, $count2, $thr33, $one, $two, $three, $four, $five, %did, %didnt);

open OUT, "> $ARGV[2]" or die $!; #e.g. Whole_Blood_PANTHeqtls
open OWT, "> $ARGV[3]" or die $!; #e.g. leftovers

open (TWO,'<',$ARGV[1]) or die $!;
#HUMAN|HGNC=18442|UniProtKB=Q0VAF6	ENSG00000179751	Syncollin;SYCN;ortholog	SYNCOLLIN (PTHR17503:SF0)		Homo sapiens
while (my $line=<TWO>){
	chomp $line;
	($panth, $ensg)=((split /\t/, $line)[0,1]);
	$hash{$ensg}=$panth;
}
close TWO;

open (ONE,'<',$ARGV[0]) or die $!;
#chr1	1001177	1001177	1_1001177_G_C_b37	ENSG00000217801.5_Whole_Blood

while (my $line=<ONE>){
	chomp $line;
	($one, $two, $three, $four, $five)=(split /\t/, $line);
	$three=((split /\./, $five)[0]);
	if ($three ~~ %hash){
		$count1++;
		$thr33=$hash{$three};
		print OUT "$one\t$two\t$two\t$four\t$five\n";
		$did{$three}=1;
	}
	else {
		$count2++;
		print OWT "$line\n";
		$didnt{$three}=1;
	}
}
close ONE;
close OWT;
close OUT;
print "Number of matched ENSG IDs to PANTHER IDs links: $count1\nNumber of links that did not match a PANTHER ID: $count2\n";
print scalar keys %did;
print ": Number of ENSGs that did map to a PANTHER ID\nNumber of ENSGs that did not map to a PANTHER ID: ";
print scalar keys %didnt;
my $diff = Time::HiRes::tv_interval($start_time);

print "\n\n$diff\n";