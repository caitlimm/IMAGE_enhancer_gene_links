# IMAGE_enhancer_gene_links

Generating eQTL enhancer-gene links:

Download and open eQTL files from GTEx at https://storage.googleapis.com/gtex_analysis_v7/single_tissue_eqtl_data/GTEx_Analysis_v7_eQTL.tar.gz

Split the file by chromosome if desired:

$ perl split.pl Colon_Sigmoid.v7.signif_variant_gene_pairs.txt

Output: chr[1-22,X,Y]Colon_Sigmoid.v7.signif_variant_gene_pairs.txt
