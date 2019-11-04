#!/usr/local/bin/perl -w
#use strict;

#eqtllinks.pl updated 10/4/2018
#takes eqtl enhancer files and outputs the gene/enhancer links

use Time::HiRes qw(usleep ualarm gettimeofday tv_interval nanosleep clock_gettime clock_getres clock_nanosleep clock stat);

my $start_time = [Time::HiRes::gettimeofday()];

use POSIX qw(ceil floor);

#ARGV[0] is the enhancer file e.g. CREbedDBenhancers
#ARGV[1] is the eqtl enhancer file e.g. Esophagus_Muscularis_intersectU
#ARGV[2] is the out file giving the enhancer/gene links i.e. links_Esophagus_Muscularis_eqtlU
#ARGV[3] is tissuetable
#ARGV[4] is pantherGeneList.txt

my ($chr, $start, $end, $snp, $gene, $geee, $enhancer, @tissue, $tissue, $enhID, $build, $source, %match, %enh, %tissues, $tissueID, $one, $two, $three, $four, $five, $pval);
open (EQTL,'<',$ARGV[0]) or die $!; #Esophagus_Muscularis_intersectU	
#open (ENH,'<',$ARGV[0]) or die $!; #CREbedDBenhancers
open (TISS,'<',$ARGV[2]) or die $!; #tissuetable
open (PAN,'<',$ARGV[3]) or die $!; #pantherGeneList.txt
open OUT, "> $ARGV[1]" or die $!; #e.g. links_Esophagus_Muscularis_eqtlU

while (my $line=<EQTL>){
#chr1    111733520       111733879       317     chr1    111733724       111733724       1_111733724_G_C_b37     ENSG00000156171.10_3.41733e-14_Whole_Blood
chomp $line;
	($chr, $start, $end, $enhID, $three, $four, $five, $snp, $geee)=(split /\t/, $line); 
	$gene=((split /\./, $geee)[0]); #ENSG00000156171.10_3.41733e-14_Whole_Blood
	@tissue=(split /\_/, $geee);
	shift @tissue;
	$pval=shift @tissue;
	$tissue=join( '_', @tissue);
	$match{$enhID}{$gene}{$snp}{$pval}{$tissue}=1;
}
close EQTL;

while (my $line=<TISS>){
#6	Artery Tibial
	chomp $line;
	($tissueID, $tissue)=(split /\t/, $line); 
	$tissue =~ s/\s/\_/g;
	$tissues{$tissue}=$tissueID;
}
close TISS;
my ($panthID, $ensID, $six, %panther);
while (my $line=<PAN>){
#HUMAN|HGNC=23304|UniProtKB=Q96NZ9	ENSG00000165828	Proline-rich acidic protein 1;PRAP1;ortholog	PROLINE-RICH ACIDIC PROTEIN 1 (PTHR37861:SF1)		Homo sapiens
	chomp $line;
	($panthID, $ensID)=((split /\t/, $line)[0,1]); 
	$panther{$ensID}=$panthID;
}
close PAN;
foreach my $enhance (sort keys %match){
	foreach my $ens (keys %{$match{$enhance}}){
		$panthID=$panther{$ens};
		foreach my $snp (keys %{$match{$enhance}{$ens}}){
			foreach my $pvalue (keys %{$match{$enhance}{$ens}{$snp}}){
				foreach my $tissue (keys %{$match{$enhance}{$ens}{$snp}{$pvalue}}){
					$tiss=$tissues{$tissue};
					print OUT "$enhance\t$panthID\t$snp\t$pvalue\t$tiss\t2\n"; #2 is the assay ID for eqtl
				}
			}
		}
	}
}

close OUT;

my $diff = Time::HiRes::tv_interval($start_time);

print "\n$diff\n";