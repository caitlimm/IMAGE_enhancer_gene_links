#!/usr/local/bin/perl -w
#use strict;

#linksDBeqtl.pl

#ARGV[0] is linkseqtl
#ARGV[1] is linksDBnumeqtl

use Time::HiRes qw(usleep ualarm gettimeofday tv_interval nanosleep clock_gettime clock_getres clock_nanosleep clock stat);

my $start_time = [Time::HiRes::gettimeofday()];

use POSIX qw(ceil floor);

my ($enhID, $panthID, $eqtl, $tissue, $assay, %hash, $key, $pval);

open OUT, "> $ARGV[1]" or die $!; #e.g. linksDBnumeqtl

open (ONE,'<',$ARGV[0]) or die $!;
#199997	HUMAN|HGNC=30085|UniProtKB=Q9H7M9	10_73601274_G_A_b37	6	2	
while (my $line=<ONE>){
	chomp $line;
	($enhID, $panthID, $eqtl, $tissue, $assay)=(split /\t/, $line);
	$hash{$enhID}{$panthID}{$tissue}{$eqtl}=1;
}
close ONE;

print OUT "enhancer\tgene\ttissue\tnumber_of_eQTL\tassay\n";
foreach my $enh (sort keys %hash){
	foreach my $gene (keys %{$hash{$enh}}){
		foreach my $tis (sort keys %{$hash{$enh}{$gene}}){
			$count=0;
			foreach my $snp (keys %{$hash{$enh}{$gene}{$tis}}){
				$count++;
			}
			print OUT "$enh\t$gene\t$tis\t$count\t$assay\n";
		}
	}
}
close OUT;

my $diff = Time::HiRes::tv_interval($start_time);

print "\n$diff\n";