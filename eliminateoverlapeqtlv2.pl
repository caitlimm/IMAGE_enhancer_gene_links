#!/usr/local/bin/perl -w
use strict;

#eliminateoverlapeqtlv2.pl

#ARGV[0] is Whole_Blood_PANTHeqtls
#ARGV[1] is exons_genes.txt
#ARGV[2] is Whole_Blood_eqtl2
#ARGV[3] is overlaps
#ARGV[4] is unmatched

use Time::HiRes qw(usleep ualarm gettimeofday tv_interval nanosleep clock_gettime clock_getres clock_nanosleep clock stat);

my $start_time = [Time::HiRes::gettimeofday()];

use POSIX qw(ceil floor);

my ($chr, $start, $end, $ensg, %hash, $count1, $count2, $one, $two, $three, $four, $five, $lock, $key, %out, %owt);

open OUT, "> $ARGV[2]" or die $!; #e.g. Whole_Blood_eqtl2
open OWT, "> $ARGV[3]" or die $!; #e.g. overlaps
open OTT, "> $ARGV[4]" or die $!; #e.g. unmatched

#head exons_genes.txt
#chr1    10002682        10002826        -       ENSG00000162441.7       protein_coding  KNOWN   LZIC
open (TWO,'<',$ARGV[1]) or die $!; #exons_genes.txt
#chr1    10002682        10002826        -       ENSG00000162441.7       protein_coding  KNOWN   LZIC
while (my $line=<TWO>){
	chomp $line;
	($chr, $start, $end, $ensg)=((split /\t/, $line)[0,1,2,4]);
	$ensg=((split /\./, $ensg)[0]);
	$line="$chr\t$start\t$end\t$ensg";
	$hash{$ensg}{$line}=1;
}
close TWO;

open (ONE,'<',$ARGV[0]) or die $!; #Whole_Blood_PANTHeqtls
#chr1	100200184	100200184	1_100200184_C_T_b37	ENSG00000156869.8_Whole_Blood
while (my $line=<ONE>){
	chomp $line;
	($one, $two, $three, $four, $five)=(split /\t/, $line);
	$key=((split /\./, $five)[0]);
	if ($key ~~ %hash){
		#
		foreach my $lock (sort keys %{$hash{$key}}){
		#$lock=$hash{$key};
		($chr, $start, $end, $ensg)=(split /\t/, $lock);
		if ($two<$start){
			$count1++;
			#print OUT "$line\n";
			$out{$line}=1;
			#chr1	100000827	100000827	1_100000827_C_T_b37	ENSG00000122435.5_0.773221_Liver
		}
		elsif($two>$end){
		$count2++;
			#print OUT "$line\n";
			$out{$line}=1;
		}
		else{
			#print OWT "$line\n";
			$owt{$line}=1;
		}
		#
		}
		#
	}
	else {
		print OTT "$line\n";
	}
}

foreach my $keys (sort keys %out){
	print OUT "$keys\n";
}
foreach my $keys (sort keys %owt){
	print OWT "$keys\n";
}
close ONE;
close OUT;
close OWT;
close OTT;
my $diff = Time::HiRes::tv_interval($start_time);

print "count1: $count1 count2: $count2\n\n$diff\n";