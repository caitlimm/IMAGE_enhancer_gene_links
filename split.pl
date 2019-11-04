#!/usr/local/bin/perl -w
#use strict;

#splitv4.pl
#splits input file by chromosome

#ARGV[0] is the input file e.g. Artery_Aorta.allpairs

use Time::HiRes qw(usleep ualarm gettimeofday tv_interval nanosleep clock_gettime clock_getres clock_nanosleep clock stat);

my $start_time = [Time::HiRes::gettimeofday()];

use POSIX qw(ceil floor);
my $base="$ARGV[0]";	
open OAT, "> chr1$base" or die $!;
open OBT, "> chr2$base" or die $!;
open OCT, "> chr3$base" or die $!;
open ODT, "> chr4$base" or die $!;
open OET, "> chr5$base" or die $!;
open OFT, "> chr6$base" or die $!;
open OGT, "> chr7$base" or die $!;
open OHT, "> chr8$base" or die $!;
open OIT, "> chr9$base" or die $!;
open OJT, "> chr10$base" or die $!;
open OKT, "> chr11$base" or die $!;
open OLT, "> chr12$base" or die $!;
open OMT, "> chr13$base" or die $!;
open ONT, "> chr14$base" or die $!;
open OOT, "> chr15$base" or die $!;
open OPT, "> chr16$base" or die $!;
open OQT, "> chr17$base" or die $!;
open ORT, "> chr18$base" or die $!;
open OST, "> chr19$base" or die $!;
open OTT, "> chr20$base" or die $!;
open OUT, "> chr21$base" or die $!;
open OVT, "> chr22$base" or die $!;
open OWT, "> chrX$base" or die $!;
open OXT, "> chrY$base" or die $!;
my ($chr, $start, $end, $thickstart, $thickend, $total, $location, %names, %enhancer, $celltype, $evidence, $source, $bin1, $bin2, $bins, $enhs);
open (ENH,'<',$ARGV[0]) or die $!; 
	
#ENSG00000113396.8	5_128105597_A_G_b37	-75676	153	194	0.431111	7.6057e-10
while (my $line=<ENH>){
	$variant_id=((split /\t/, $line)[0]);
	($chr, $start)=((split /\_/,$variant_id)[0,1]);
	$chr="chr$chr";
	chomp $line;
	if ($chr eq "chr1"){
		print OAT "$line\n";
	}
	elsif ($chr eq "chr2"){
		print OBT "$line\n";
	}
	elsif ($chr eq "chr3"){
		print OCT "$line\n";
	}
	elsif ($chr eq "chr4"){
		print ODT "$line\n";
	}
	elsif ($chr eq "chr5"){
		print OET "$line\n";
	}
	elsif ($chr eq "chr6"){
		print OFT "$line\n";
	}
	elsif ($chr eq "chr7"){
		print OGT "$line\n";
	}
	elsif ($chr eq "chr8"){
		print OHT "$line\n";
	}
	elsif ($chr eq "chr9"){
		print OIT "$line\n";
	}
	elsif ($chr eq "chr10"){
		print OJT "$line\n";
	}
	elsif ($chr eq "chr11"){
		print OKT "$line\n";
	}
	elsif ($chr eq "chr12"){
		print OLT "$line\n";
	}
	elsif ($chr eq "chr13"){
		print OMT "$line\n";
	}
	elsif ($chr eq "chr14"){
		print ONT "$line\n";
	}
	elsif ($chr eq "chr15"){
		print OOT "$line\n";
	}
	elsif ($chr eq "chr16"){
		print OPT "$line\n";
	}
	elsif ($chr eq "chr17"){
		print OQT "$line\n";
	}
	elsif ($chr eq "chr18"){
		print ORT "$line\n";
	}
	elsif ($chr eq "chr19"){
		print OST "$line\n";
	}
	elsif ($chr eq "chr20"){
		print OTT "$line\n";
	}
	elsif ($chr eq "chr21"){
		print OUT "$line\n";
	}
	elsif ($chr eq "chr22"){
		print OVT "$line\n";
	}
	elsif ($chr eq "chrX"){
		print OWT "$line\n";
	}
	elsif ($chr eq "chrY"){
		print OXT "$line\n";
	}
	else{
		$count++;
	}
}

print "$count\n";

my $diff = Time::HiRes::tv_interval($start_time);

print "\n\n$diff\n";