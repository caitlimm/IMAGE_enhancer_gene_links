# IMAGE_enhancer_gene_links

Generating eQTL enhancer-gene links:

Download and open eQTL files from GTEx at https://storage.googleapis.com/gtex_analysis_v7/single_tissue_eqtl_data/GTEx_Analysis_v7_eQTL.tar.gz

Split the file by chromosome if desired:
``
$ perl split.pl Colon_Sigmoid.v7.signif_variant_gene_pairs.txt  
``
Output: chr[1-22,X,Y]Colon_Sigmoid.v7.signif_variant_gene_pairs.txt

Trim these files to have the following columns (newdata.txt):<br/>
              variant              gene pval_nominal        tissue<br/>
 1 13_19725266_A_G_b37 ENSG00000196199.9  6.41011e-06 Colon_Sigmoid<br/>
 2 13_19725770_T_C_b37 ENSG00000196199.9  6.41011e-06 Colon_Sigmoid<br/>
 3 13_19729840_A_G_b37 ENSG00000196199.9  6.41011e-06 Colon_Sigmoid<br/>
 4 13_19736675_A_G_b37 ENSG00000196199.9  6.41011e-06 Colon_Sigmoid<br/>
 5 13_19744133_T_C_b37 ENSG00000196199.9  6.41011e-06 Colon_Sigmoid<br/>
 6 13_19779235_T_G_b37 ENSG00000196199.9  7.48995e-06 Colon_Sigmoid<br/>

Rearrange the file into bed format:
``
perl eqtlprocessv2.pl newdata.txt chr13Colon_Sigmoid_eqtl
``

Remove any genes not found in PANTHER:
``
perl pantherIDweed.pl chr13Colon_Sigmoid_eqtl pantherGeneList.txt chr13Colon_Sigmoid_eqtls leftovers 
``

Eliminate any eQTL that are found in exons of their own genes (You must have a file formatted as exons_gene.txt is here, that gives the coordinates and names of genes):
``
perl eliminateoverlapeqtlv2.pl chr13Colon_Sigmoid_eqtls exons_genes.txt chr13Colon_Sigmoid_eqtl2 overlaps unmatched 

head exons_genes.txt
chr1    10002682        10002826        -       ENSG00000162441.7       protein_coding  KNOWN   LZIC
chr1    10002682        10002840        -       ENSG00000162441.7       protein_coding  KNOWN   LZIC
chr1    10002739        10002840        -       ENSG00000162441.7       protein_coding  KNOWN   LZIC
chr1    10003307        10003387        -       ENSG00000162441.7       protein_coding  KNOWN   LZIC
``
See if any of the eQTL intersect with the enhancers:
``
bedtools intersect -wa -wb -a CREbedDBenhancers_10092018 -b chr13Colon_Sigmoid_eqtl2 > chr13Colon_Sigmoid_intersect 
``
Replace the ENSG IDs with PANTHER long IDs and replace tissue names with tissue IDs:
``
perl eqtllinks.pl chr13Colon_Sigmoid_intersect links_chr13Colon_Sigmoid_eqtl tissuetable_10092018.txt pantherGeneList.txt 
``
Create linksnum_chr13Colon_Sigmoid which summarizes the eQTL information for each link:
``
perl linksDBeqtl.pl links_chr13Colon_Sigmoid_eqtl linksnum_chr13Colon_Sigmoid_eqtl 
``
Concatenate these files at the end to get:
``
head linksDBeqtl
enhancer        gene    eQTL  tissue  assay
10      HUMAN|HGNC=329|UniProtKB=O00468 1_1004957_G_A_b37       2       2
10      HUMAN|HGNC=329|UniProtKB=O00468 1_1004980_G_A_b37       2       2
10      HUMAN|HGNC=26062|UniProtKB=Q96HA4       1_1004957_G_A_b37       1       2
10      HUMAN|HGNC=26062|UniProtKB=Q96HA4       1_1004957_G_A_b37       2       2
``and``
$ head linksDBnumeqtl
enhancer        gene    tissue  number_of_eQTL  assay
10      HUMAN|HGNC=329|UniProtKB=O00468 2       2       2
10      HUMAN|HGNC=329|UniProtKB=O00468 27      2       2
10      HUMAN|HGNC=329|UniProtKB=O00468 34      2       2
10      HUMAN|HGNC=329|UniProtKB=O00468 45      2       2
``
