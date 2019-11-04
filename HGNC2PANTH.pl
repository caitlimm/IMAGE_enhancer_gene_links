#!/usr/local/bin/perl -w
#use strict;

#HGNC2PANTH.pl
#takes HGNC names from intersect files (e.g. nn_hES.enh_1e-4_intersect) and outputs them with PANTHlongIDs

use Time::HiRes qw(usleep ualarm gettimeofday tv_interval nanosleep clock_gettime clock_getres clock_nanosleep clock stat);

my $start_time = [Time::HiRes::gettimeofday()];

use POSIX qw(ceil floor);

#ARGV[0] is the intersect file e.g. nn_hES.enh_1e-4_intersect
#ARGV[1] is the HGNC name and ID file results.txt
#ARGV[2] is pantherGeneList.txt
#ARGV[3] is the out file with PANTHER matches
#ARGV[4] is the out file with lines that did not have PANTHER matches
#ARGV[5] is the tissue name or cell type e.g. hES

my ($echr, $estart, $eend, $enhID, $pchr, $pstart, $pend, $mix, $count, $hgnc, $symbol, $uniprot, $ensg, $hgncid, %hash1, %hash2, %hash3);
open (INT,'<',$ARGV[0]) or die $!; 
open (HGNC,'<',$ARGV[1]) or die $!; 
open (PAN,'<',$ARGV[2]) or die $!; 
open OUT, "> $ARGV[3]" or die $!; 
open OWT, "> $ARGV[4]" or die $!;

while (my $line=<HGNC>){
#HGNC ID Status  Approved symbol Approved name   UniProt accession       Ensembl gene ID Previous name   Alias name
#HGNC:5  Approved        A1BG    alpha-1-B glycoprotein  P04217  ENSG00000121410
#HGNC:37133      Approved        A1BG-AS1        A1BG antisense RNA 1            ENSG00000268895 non-protein coding RNA 181
	chomp $line;
	$count++;
	next if ($count==1);
	($hgnc, $symbol, $uniprot, $ensg)=((split /\t/, $line)[0,2,4,5]); 
	($hgncid)=((split /\:/, $hgnc)[1]);
	$hgncid="HGNC=$hgncid";
	$hash1{$symbol}=$hgncid;
	$hash2{$symbol}=$uniprot;
	$hash3{$symbol}=$ensg;
}
close HGNC;

my($longID, $ENSG, $HGNC, $uniprotkb, %panth, $gene, $pvalue, $break, $hgncID, $uniProt, $ensG);

while (my $line=<PAN>){
#HUMAN|HGNC=11393|UniProtKB=O14965	ENSG00000087586	Aurora kinase A;AURKA;ortholog	AURORA KINASE A (PTHR24350:SF5)	non-receptor serine/threonine protein kinase(PC00167)	Homo sapiens
	chomp $line;
	($longID, $ENSG)=((split /\t/, $line)[0,1]);
	($HGNC, $uniprotkb)=((split /\|/, $longID)[1,2]);
	$uniprotkb=((split /\=/, $uniprotkb)[1]);
	$panth{$HGNC}=$longID;
	$panth{$uniprotkb}=$longID;
	$panth{$ENSG}=$longID;
}
close PAN;

my ($cownt);
while (my $line=<INT>){
#chr1    1060905 1061095 106     chr1    1040000 1080000 B3GALT6:-120Kb:1.8e-06:4e-08:21:85
	chomp $line;
	($echr, $estart, $eend, $enhID, $pchr, $pstart, $pend, $mix)=(split /\t/, $line); 
	($gene, $pvalue)=((split /\:/, $mix)[0,2]);
	if ($gene ~~ %hash1){
	#$cownt++; 50493
		$hgncID=$hash1{$gene};
		if ($hgncID ~~ %panth){
		#$cownt++; 41530
			$panthid=$panth{$hgncID};
			print OUT "$echr\t$estart\t$eend\t$enhID\t$pchr\t$pstart\t$pend\t$panthid\t$pvalue\t$ARGV[5]\n";
		}
		else {
		#$cownt++; 8963
			print OWT "1\t$line\n";
		}
	}
	elsif ($gene ~~ %hash2){
	#$cownt++; 0
		$uniProt=$hash2{$gene};
		if ($uniProt ~~ %panth){
			$panthid=$panth{$uniProt};
			print OUT "$echr\t$estart\t$eend\t$enhID\t$pchr\t$pstart\t$pend\t$panthid\t$pvalue\t$ARGV[5]\n";
		}
		else {
			print OWT "1\t$line\n";
		}
	}
	elsif ($gene ~~%hash3){
	#$cownt++; 0
		$ensG=$hash3{$gene};
		if ($ensG ~~ %panth){
			$panthid=$panth{$ensG};
			print OUT "$echr\t$estart\t$eend\t$enhID\t$pchr\t$pstart\t$pend\t$panthid\t$pvalue\t$ARGV[5]\n";
		}
		else {
			print OWT "1\t$line\n";
		}
	}
	else {
	#$cownt++; 4766
		print OWT "2\t$line\n";
	}
}
#print $cownt;
close INT;

close OUT;

close OWT;

my $diff = Time::HiRes::tv_interval($start_time);

print "\n$diff\n";