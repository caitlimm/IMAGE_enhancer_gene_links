#!/usr/local/bin/perl -w
#use strict;

#TADlinks.pl
#takes TSSbTAD and enhancersbTAD and determines the links between them via TAD

#ARGV[0] is the gene input file e.g. TSSbTAD
#ARGV[1] is enhancersbTAD
#ARGV[2] is the output file containing the links e.g. linksbTAD
#ARGV[3] is pantherGenelist.txt

use Time::HiRes qw(usleep ualarm gettimeofday tv_interval nanosleep clock_gettime clock_getres clock_nanosleep clock stat);

use POSIX qw(ceil floor);

my $start_time = [Time::HiRes::gettimeofday()];

my ($chr, $start, $end, $geneID, $one, $two, $three, $tad, $cell, %tadgenes, $tissue);

open (TSS,'<',$ARGV[0]) or die $!; #TSSbTAD
#chr1	10002826	10003426	ENSG00000162441	chr1	9740000	10460001	boundary.8|hg19|chr1:9720001-9760000___boundary.9|hg19|chr1:10440001-10480000	0.439979917398|T47D
while(my $line=<TSS>){
	chomp $line;
	($chr, $start, $end, $geneID, $one, $two, $three, $tad, $tissue)=(split /\t/, $line);
	$cell=((split /\|/, $tissue)[1]);
	$tad="$tad\t$cell";
	$tadgenes{$tad}{$geneID}=1;
}
close TSS;

my ($enhID, %tadenh, $panth, $ensg, %panther, %tissues, $tissueID, %final, $panthID, $cellID);

open (ENH,'<',$ARGV[1]) or die $!; #enhancersbTAD
#chr1    100138994       100139323       5       chr1    97500000        100220001       boundary.123|hg19|chr1:97480001-97520000___boundary.125|hg19|chr1:100200001-100240000   1.0529716799|G401
while(my $line=<ENH>){
	chomp $line;
	($chr, $start, $end, $enhID, $one, $two, $three, $tad, $tissue)=(split /\t/, $line);
	$cell=((split /\|/, $tissue)[1]);
	$tad="$tad\t$cell";
	$tadenh{$enhID}{$tad}=1;
}
close ENH;

open (PAN,'<',$ARGV[3]) or die $!; #or pantherGenelist.txt
#HUMAN|HGNC=24745|UniProtKB=Q8NA69	ENSG00000198723	Uncharacterized protein C19orf45;C19orf45;ortholog	MCG11564 (PTHR34828:SF1)		Homo sapiens
while(my $line=<PAN>){
	chomp $line;
	($panth, $ensg)=((split /\t/, $line)[0,1]);
	$panther{$ensg}=$panth;
}

open OUT, "> $ARGV[2]" or die $!; #linksbTAD

my ($count1, $count2, $count3, $count4);
#enhancer gene tissue assay
foreach my $enh (sort keys %tadenh){
	$count1++;
	foreach my $tad (sort keys %{$tadenh{$enh}}){
		$count2++;
		if ($tad ~~ %tadgenes){
			$count3++;
			foreach my $geen (sort keys %{$tadgenes{$tad}}){
				$count4++;
				$panthID=$panther{$geen};
				$cell=((split /\t/, $tad)[1]);
				$final{$enh}{$panthID}{$cell}=1;
			}
		}
	}
}

foreach my $one (sort keys %final){
	foreach my $two (sort keys %{$final{$one}}){
		foreach my $three (sort keys %{$final{$one}{$two}}){
			print OUT "$one\t$two\t$three\t3\n";
			#11412	HUMAN|HGNC=17840|UniProtKB=Q9BSY4	55	1
		}
	}
}
close OUT;

print " $count1 $count2 $count3 $count4";

my $diff = Time::HiRes::tv_interval($start_time);

print "\n\n$diff\n";