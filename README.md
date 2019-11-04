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
