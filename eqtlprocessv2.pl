#!/usr/local/bin/perl -w
#use strict;

#eqtlprocessv2.pl updated 2/1/2018

#ARGV[0] is input eqtl file e.g. newdata
#ARGV[1] is out file e.g. Whole_Blood_eqtl

use Time::HiRes qw(usleep ualarm gettimeofday tv_interval nanosleep clock_gettime clock_getres clock_nanosleep clock stat);

my $start_time = [Time::HiRes::gettimeofday()];

use POSIX qw(ceil floor);

my ($variant_id, $gene_id, $tss_distance, $ma_samples, $ma_count, $maf, $pval_nominal, $slope, $slope_se, $pval_nominal_threshold, $min_pval_nominal, $pval_beta, %out, $key, $chr, $start, $count);
open (EQTL,'<',$ARGV[0]) or die $!; #		eqtl file	
#variant	gene	pval_nominal	tissue
#13_19020095_C_T_b37	ENSG00000228797.2	0.673039	Heart_Left_Ventricle

open OUT, "> $ARGV[1]" or die $!; #e.g. Whole_Blood_eqtl

while (my $line=<EQTL>){
	chomp $line;
	$count++;
	next if ($count==1);
	($variant_id, $gene_id, $pval_nominal, $tissue)=(split /\t/, $line); 
	($chr, $start)=((split /\_/,$variant_id)[0,1]);
	$chr="chr$chr";
	$key="$chr\t$start\t$start\t$variant_id\t$gene_id\_$pval_nominal";
	$out{$key}=1;
}
foreach my $key (sort keys %out){
	print OUT "$key\_$tissue\n";
}
close OUT;

my $diff = Time::HiRes::tv_interval($start_time);

print "\n$diff\n";