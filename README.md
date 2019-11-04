# IMAGE_enhancer_gene_links

## Generating enhancer-gene links from eQTL data:

Download and open eQTL files from GTEx at https://storage.googleapis.com/gtex_analysis_v7/single_tissue_eqtl_data/GTEx_Analysis_v7_eQTL.tar.gz

Split the file by chromosome if desired:  
```
$ perl split.pl Colon_Sigmoid.v7.signif_variant_gene_pairs.txt
```
Output: chr[1-22,X,Y]Colon_Sigmoid.v7.signif_variant_gene_pairs.txt  

Trim these files to have the following columns (newdata.txt):  
```
              variant              gene pval_nominal        tissue
 1 13_19725266_A_G_b37 ENSG00000196199.9  6.41011e-06 Colon_Sigmoid
 2 13_19725770_T_C_b37 ENSG00000196199.9  6.41011e-06 Colon_Sigmoid
 3 13_19729840_A_G_b37 ENSG00000196199.9  6.41011e-06 Colon_Sigmoid
 4 13_19736675_A_G_b37 ENSG00000196199.9  6.41011e-06 Colon_Sigmoid
 5 13_19744133_T_C_b37 ENSG00000196199.9  6.41011e-06 Colon_Sigmoid
 6 13_19779235_T_G_b37 ENSG00000196199.9  7.48995e-06 Colon_Sigmoid
```
Rearrange the file into bed format:  
```
$ perl eqtlprocessv2.pl newdata.txt chr13Colon_Sigmoid_eqtl  
```
Remove any genes not found in PANTHER:  
```
$ perl pantherIDweed.pl chr13Colon_Sigmoid_eqtl pantherGeneList.txt chr13Colon_Sigmoid_eqtls leftovers  
```
Eliminate any eQTL that are found in exons of their own genes (You must have a file formatted as exons_gene.txt is here, that gives the coordinates and names of genes):  
```
$ perl eliminateoverlapeqtlv2.pl chr13Colon_Sigmoid_eqtls exons_genes.txt chr13Colon_Sigmoid_eqtl2 overlaps unmatched  
$ head exons_genes.txt  
chr1    10002682        10002826        -       ENSG00000162441.7       protein_coding  KNOWN   LZIC  
chr1    10002682        10002840        -       ENSG00000162441.7       protein_coding  KNOWN   LZIC  
chr1    10002739        10002840        -       ENSG00000162441.7       protein_coding  KNOWN   LZIC  
chr1    10003307        10003387        -       ENSG00000162441.7       protein_coding  KNOWN   LZIC  
```
See if any of the eQTL intersect with the enhancers:  
```
$ bedtools intersect -wa -wb -a CREbedDBenhancers_10092018 -b chr13Colon_Sigmoid_eqtl2 > chr13Colon_Sigmoid_intersect  
```
Replace the ENSG IDs with PANTHER long IDs and replace tissue names with tissue IDs:  
```
$ perl eqtllinks.pl chr13Colon_Sigmoid_intersect links_chr13Colon_Sigmoid_eqtl tissuetable_10092018.txt pantherGeneList.txt  
```
Create linksnum_chr13Colon_Sigmoid which summarizes the eQTL information for each link:  
```
$ perl linksDBeqtl.pl links_chr13Colon_Sigmoid_eqtl linksnum_chr13Colon_Sigmoid_eqtl  
```
Concatenate these files at the end to get:  
```
$ head linksDBeqtl  
enhancer        gene    eQTL  tissue  assay  
10      HUMAN|HGNC=329|UniProtKB=O00468 1_1004957_G_A_b37       2       2  
10      HUMAN|HGNC=329|UniProtKB=O00468 1_1004980_G_A_b37       2       2  
10      HUMAN|HGNC=26062|UniProtKB=Q96HA4       1_1004957_G_A_b37       1       2  
10      HUMAN|HGNC=26062|UniProtKB=Q96HA4       1_1004957_G_A_b37       2       2  
```
and  
```
$ head linksDBnumeqtl  
enhancer        gene    tissue  number_of_eQTL  assay  
10      HUMAN|HGNC=329|UniProtKB=O00468 2       2       2  
10      HUMAN|HGNC=329|UniProtKB=O00468 27      2       2  
10      HUMAN|HGNC=329|UniProtKB=O00468 34      2       2  
10      HUMAN|HGNC=329|UniProtKB=O00468 45      2       2  
```

## Generating enhancer-gene links from hierarchical TAD data:  

Download files from https://www.cs.huji.ac.il/~tommy/PSYCHIC/  

```
$ head lib25_K562.enh_1e-4.bed
chr1    525000  550000  LOC100288069:-175Kb:0:0:6.7e+02:1.1e+03
chr1    575000  600000  LINC00115:-175Kb:4e-06:1.2e-07:3.4e+02:6.1e+02
chr1    575000  600000  LOC100288069:-125Kb:6.1e-10:1.8e-11:6.7e+02:1e+03
```
Rid our files of any putative enhancer coordinates that include negative values so that bedtools can run the intersect command:  
```
$ perl nonegvalues.pl hES.enh_1e-4.bed nn_hES.enh_1e-4.bed out
$ bedtools intersect -wa -wb -f 0.9 -a CREbedDBenhancers -b nn_hES.enh_1e-4.bed > nn_hES.enh_1e-4_intersect
```
Transform these gene names to ENSG>PANTHERlongID format:  
The file results.txt is HGNC gene ID information.  
```
$ head resultsHGNC.txt
HGNC ID Status  Approved symbol Approved name   UniProt accession       Ensembl gene ID Previous name   Alias name
HGNC:5  Approved        A1BG    alpha-1-B glycoprotein  P04217  ENSG00000121410
HGNC:37133      Approved        A1BG-AS1        A1BG antisense RNA 1            ENSG00000268895 non-protein coding RNA 181
HGNC:37133      Approved        A1BG-AS1        A1BG antisense RNA 1            ENSG00000268895 A1BG antisense RNA (non-protein coding)
HGNC:37133      Approved        A1BG-AS1        A1BG antisense RNA 1            ENSG00000268895 A1BG antisense RNA 1 (non-protein coding)
HGNC:24086      Approved        A1CF    APOBEC1 complementation factor  Q9NQ94  ENSG00000148584

$ perl HGNC2PANTH.pl nn_hES.enh_1e-4_intersect results.txt pantherGeneList.txt out_1 owt_1 hES
```
Record the p-value of the association and reformat the link to enhancerID\tPANTHERgene\ttissueID\tassay\tp-value\n. Sort by enhancer then gene.  
```
$ perl reformat.pl out_1 intTADlinks_hES_1e-4
chr1	100125400	100125601	66387	HUMAN|HGNC=15846|UniProtKB=Q9NP74	GM12878	TADinteractions	4.1e-06
chr1	100126086	100126457	EH37E0105510	HUMAN|HGNC=15846|UniProtKB=Q9NP74	GM12878	TADinteractions	4.1e-06
chr1	100127349	100127788	EH37E0105511	HUMAN|HGNC=15846|UniProtKB=Q9NP74	GM12878	TADinteractions	4.1e-06
$ perl reformat.pl PSYCHIClinks tissuetable_10092018.txt PSYCHIClinksDB
EH37E0105481	HUMAN|HGNC=15846|UniProtKB=Q9NP74	49	5.4e-14	4
EH37E0105482	HUMAN|HGNC=15846|UniProtKB=Q9NP74	49	5.4e-14	4
EH37E0105483	HUMAN|HGNC=15846|UniProtKB=Q9NP74	49	5.4e-14	4
```

## Generating enhancer-gene links from ChIA-PET data:  

Run the raw fastq files from the ChIA-PET experiments from ENCODE (https://www.encodeproject.org/matrix/?type=Experiment&status=released&searchTerm=chia-pet&biosample_ontology.classification=cell+line&assembly=hg19) through Mango. Output file format is K562.interactions.fdr.mango.  
```
$head K562.interactions.fdr.mango
chr1	28843710	28847368	chr1	28905534	28909433	68	1.19571806767109e-05
chr1	28843710	28847368	chr1	28973949	28976946	48	1.19176621106095e-05
chr1	28878616	28880932	chr1	28905534	28909433	71	1.11787481232535e-09
```
The two regions are interacting and the integer value is the number of PETs that support the interaction. The last column is the p-value.  
Give the regions their own lines and then, in order to preserve their interaction, assign a name column chr1:start1..end1-chr1:start2..end2  
Add a column with the cell type, target protein, and p-value.  
```
$ perl celltypev2.pl HCT116_POLR2A.interactions.fdr.mango HCT116-POLR2A aHCT116_POLR2A.interactions.fdr.mango
$ head aHCT116_POLR2A.interactions.fdr.mango
chr1    204097807       204099318       chr1:203830001..203831938-chr1:204097807..204099318     HCT116-POLR2A_0.0469616680625812
chr1    226308706       226311164       chr1:226308706..226311164-chr1:226734990..226736359     HCT116-POLR2A_0.0290136268822468
chr1    226734990       226736359       chr1:226308706..226311164-chr1:226734990..226736359     HCT116-POLR2A_0.0290136268822468
```
Overlap the enhancers with the regions in this file:  
```
$ bedtools intersect -wa -wb -F 0.5 -f 0.5 -e -a CREbedDBenhancers -b aHCT116_POLR2A.interactions.fdr.mango > chiaHCT116POLR2Aenhancers
chr1    204098794       204099127       2356    chr1    204097807       204099318       chr1:203830001..203831938-chr1:204097807..204099318     HCT116-POLR2A_0.0469616680625812
chr10   125754916       125755682       6624    chr10   125753470       125756187       chr10:125753470..125756187-chr10:126076780..126078800   HCT116-POLR2A_0.00088931675469528
chr13   44817306        44817618        16497   chr13   44816437        44819352        chr13:44816437..44819352-chr13:45008690..45012042       HCT116-POLR2A_0.00152464038594458
```
Search for overlap between the ChIA-PET region and the gene’s promoter. Here we restrict the promoter to the 600bp immediately upstream of the gene TSS.  
```
$ head hg19genes.txt
Gene stable ID	Transcription start site (TSS)	Gene end (bp)	Gene start (bp)	Strand	Chromosome/scaffold name
ENSG00000228927	9237436	9307357	9236030	1	Y	
ENSG00000012817	21878581	21906825	21865751	-1	Y
$ perl chiageneTSS.pl hg19genes.txt pantherGeneList.txt TSSgenesbed
$ head TSSgenesbed
chrY	21906825	21907425	ENSG00000012817
chrY	9236836	9237436	ENSG00000228927
$ bedtools intersect -wa -wb -F 0.5 -f 0.5 -e -a TSSgenesbed -b aHCT116_POLR2A.interactions.fdr.mango > chiaHCT116POLR2Agenes
chr1    155532598       155533198       ENSG00000116539 chr1    155531658       155533964       chr1:155531658..155533964-chr1:155657522..155659682     HCT116-POLR2A_0.00543703324418981
chr1    155658110       155658710       ENSG00000163374 chr1    155657522       155659682       chr1:155531658..155533964-chr1:155657522..155659682     HCT116-POLR2A_0.00543703324418981
chr13   20437776        20438376        ENSG00000132950 chr13   20436687        20439647        chr13:20436687..20439647-chr13:20531878..20535015       HCT116-POLR2A_5.72698186651621e-07
```
Use these overlap files to generate enhancer-gene links:
```
$ perl chiagenesenhancers.pl chiaHCT116POLR2Aenhancers chiaHCT116POLR2Agenes linksHCT116POLR2Achia pantherGeneList.txt tissuetable_10092018.txt
$ head linksHCT116POLR2Achia
29719   HUMAN|HGNC=25112|UniProtKB=Q96IR2       59      6.33270007314538e-05    1
50016   HUMAN|HGNC=24164|UniProtKB=O94811       59      0.00426355355394808     1
50085   HUMAN|HGNC=15831|UniProtKB=P81877       59      0.0108232752605979      1
```
Concatenating these files to get linkschia. Order the links with:
```
$ perl orderlinks.pl linkschia linksDBchia
$ head linksDBchia
enhancer	gene	tissue 	p-value	assay
29719   HUMAN|HGNC=25112|UniProtKB=Q96IR2       59      6.33270007314538e-05    1
50016   HUMAN|HGNC=24164|UniProtKB=O94811       59      0.00426355355394808     1
50085   HUMAN|HGNC=15831|UniProtKB=P81877       59      0.0108232752605979      1
```

## Generating enhancer-gene links from TAD data:  

Download TAD data from ENCODE:  
https://www.encodeproject.org/matrix/?type=Experiment&status=released&replicates.library.biosample.donor.organism.scientific_name=Homo+sapiens&searchTerm=domain&assembly=hg19&assay_slims=3D+chromatin+structure  

```
$ perl bTADoverlap.pl ENCFF274VJU.bed bTADorder Caki2

$ head bTADorder
chr1    100260000       101420001       boundary.112|hg19|chr1:100240001-100280000___boundary.113|hg19|chr1:101400001-101440000 1.02548199993|Caki2
chr1    100260000       101940001       boundary.112|hg19|chr1:100240001-100280000___boundary.114|hg19|chr1:101920001-101960000 1.39932214488|Caki2
chr1    101420000       101940001       boundary.113|hg19|chr1:101400001-101440000___boundary.114|hg19|chr1:101920001-101960000 0.837228629863|Caki2
```
Or for the other format:  
```
$ perl tTADoverlap.pl ENCFF588KUZ.bed tTADorder Caki2

$ head tTADorder
chr10   1160001 1680000 tad0|hg19|chr10:1160001-1680000 1000|Caki2
chr10   1720001 1760000 tad1|hg19|chr10:1720001-1760000 1000|Caki2
chr10   1800001 3160000 tad2|hg19|chr10:1800001-3160000 1000|Caki2

```

TSSgenesbed is a file containing what functions as the promoters of the genes of interest. Here we restricted to the 600bp upstream of the TSS according to Ensembl. Use bedtools intersect to find which TADs contain at least 90% of a gene's promoter or at least 90% of an enhancer:  
```
$ bedtools intersect -wa -wb -f 0.9 -a TSSgenesbed -b bTADorder > TSSbTAD

$ head TSSbTAD
chr1	10002826	10003426	ENSG00000162441	chr1	9740000	10460001	boundary.8|hg19|chr1:9720001-9760000___boundary.9|hg19|chr1:10440001-10480000	0.439979917398|T47D
chr1	10002826	10003426	ENSG00000162441	chr1	9740000	10460001	boundary.9|hg19|chr1:9720001-9760000___boundary.10|hg19|chr1:10440001-10480000	0.531498384312|NCI-H460
chr1	10002826	10003426	ENSG00000162441	chr1	9780000	10460001	boundary.9|hg19|chr1:9760001-9800000___boundary.10|hg19|chr1:10440001-10480000	0.378754612218|RPMI-7951

$ bedtools intersect -wa -wb -f 0.9 -a CREbedDBenhancers_10092018 -b bTADorder > enhancersbTAD
$ head enhancersbTAD
chr1    100000188       100000393       1       chr1    95660000        100220001       boundary.106|hg19|chr1:95640001-95680000___boundary.110|hg19|chr1:100200001-100240000   1.4498397245|T47D
chr1    100000188       100000393       1       chr1    95700000        100220001       boundary.111|hg19|chr1:95680001-95720000___boundary.116|hg19|chr1:100200001-100240000   1.07741353366|LNCap_clone_FGC
chr1    100000188       100000393       1       chr1    95700000        100260001       boundary.101|hg19|chr1:95680001-95720000___boundary.106|hg19|chr1:100240001-100280000   0.958030390125|Panc1
```
Then split the enhancersbTAD and TSSbTAD files by chromosome to ease the computational burden if desired. (The tTAD data did not require trimming.) The output files were named in the pattern of chr2enhancersbTAD and chr2TSSbTAD.  
Trim down to a file showing just the gene>enhancer>cell>assay.  
```
$ perl TADlinks.pl chr2TSSbTAD chr2enhancersbTAD chr2linksbTAD pantherGeneList.txt
$ head chr1linksbTAD
1	HUMAN|Ensembl=ENSG00000271810|UniProtKB=U3KQV3	A549	3
```
Replace the tissues and cell types with their codes:  
```
$ perl tissues.pl chr2linksbTAD tissuetable_10092018.txt chr2linksbTADtissues 
$ head chr1linksTADtissues
1	HUMAN|Ensembl=ENSG00000271810|UniProtKB=U3KQV3	117	3
```
Concatenating these two files linksbTADtissues and linkstTADtissues gives the file linksTAD.  
But we only want to include the TAD links that support existing links from ChIA-PET or eQTL data:  
```
$ perl cutdowntad.pl linksDBchia linksDBnumeqtl PSYCHIClinksDB linkstTADtissues selecttTAD
Number of TAD links found in TADintxn, eQTL, or ChIA: 12068775
Number of links found only in TAD data: 116597612

$ perl cutdowntad.pl linksDBchia linksDBnumeqtl PSYCHIClinksDB chr21linksbTADtissues selectb21TAD
```
Now concatenate these files into selectTAD and eliminate any duplicates with orderlinks.pl:  
```
$ perl orderlinks.pl selectTAD linksDBtad
$ head linksDBtad
1       HUMAN|HGNC=15846|UniProtKB=Q9NP74       64      3
1       HUMAN|HGNC=15846|UniProtKB=Q9NP74       65      3
1       HUMAN|HGNC=15846|UniProtKB=Q9NP74       66      3
```
