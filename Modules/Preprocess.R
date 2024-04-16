tmp <- list()

# Drugs-omics pairs analysis----
## Search ----
### Omics ----
tmp$omics_search_CNV <- data.frame(
  omics = c(rownames(ccle_cnv),
            rownames(gdsc_cnv),
            rownames(gCSI_cnv)
  ),
  type = "cnv"
) %>% unique()


tmp$omics_search_mRNA <- data.frame(
  omics = c(rownames(ccle_exp),
            rownames(gdsc_exp)),
  type = "mRNA"
) %>% unique()

tmp$omics_search_meth <- data.frame(
  omics = c(rownames(ccle_meth)),
  type = "meth"
) %>% unique()

tmp$omics_search_protein <- data.frame(
  omics = c(rownames(ccle_protein)),
  type = "protein"
) %>% unique()

tmp$omics_search_mutgenes <- data.frame(
  omics = c(ccle_mut$genes,
            gdsc_mut$genes,
            gCSI_mut$genes
  ),
  type = "mutation_gene"
) %>% unique()

tmp$omics_search_mutsites <- data.frame(
  omics = c(ccle_mut$genes_muts,
            gdsc_mut$genes_muts
  ),
  type = "mutation_site"
) %>% unique()
tmp$omics_search_mutsites <- tmp$omics_search_mutsites[!grepl("noinfo",tmp$omics_search_mutsites$omics),]

tmp$omics_search_fusion <- data.frame(
  omics = c(ccle_fusion$fusion
  ),
  type = "fusion"
) %>% unique()

omics_search <- rbind(
  tmp$omics_search_CNV,
  tmp$omics_search_mRNA,
  tmp$omics_search_meth,
  tmp$omics_search_protein,
  tmp$omics_search_fusion,
  tmp$omics_search_mutgenes,
  tmp$omics_search_mutsites
)
omics_search <- unique(omics_search)

### Drugs----
# tmp$drugs_search_CNV <- data.frame(
#   omics = c(rownames(ctrp1_drug),
#             rownames(ctrp2_drug),
#             rownames(gdsc1_drug),
#             rownames(gdsc2_drug),
#             rownames(gCSI_drug)
#   ),
#   type = "cnv"
# ) %>% unique()

drugs_search <- data.frame(
  drugs = c(rownames(ctrp1_drug),
            rownames(ctrp2_drug),
            rownames(prism_drug),
            rownames(gdsc1_drug),
            rownames(gdsc2_drug),
            rownames(gCSI_drug)
  ),
  type = "all"
) %>% unique()

# With each database 
drugs_search2 <- data.frame(
  drugs = c(rownames(ctrp1_drug),
            rownames(ctrp2_drug),
            rownames(prism_drug),
            rownames(gdsc1_drug),
            rownames(gdsc2_drug),
            rownames(gCSI_drug)
  ),
  type = c(
    rep("CTRP1", nrow(ctrp1_drug)),
    rep("CTRP2", nrow(ctrp2_drug)),
    rep("Prism", nrow(prism_drug)),
    rep("GDSC1", nrow(gdsc1_drug)),
    rep("GDSC2", nrow(gdsc2_drug)),
    rep("gCSI", nrow(gCSI_drug))
  )
) %>% unique()

## Omics data ----
### Continuous ----
tmp$omic_sel <- c("exp", "meth", "protein", "cnv")
tmp$tmp1 <- ls()[grepl("_drug$", ls())]
tmp$drug_vec <- gsub("_drug", "", tmp$tmp1[!grepl("^p_", tmp$tmp1)])
omics_search_list1 <- list()

for(i in tmp$omic_sel){
  i2 <- paste0("_", i)
  tmp$omic_vec <- gsub(i2, "", ls()[grepl(i2, ls())])
  tmp_list <- list()
  for(x in tmp$omic_vec){
    # x = tmp$omic_vec[1]
    for(y in tmp$drug_vec){
      # y = tmp$drug_vec[1]
      # select identical cells
      omic <- base::get(paste0(x, i2))
      drug <- base::get(paste0(y, "_drug"))
      intersected_cells <- intersect(colnames(omic), colnames(drug))
      omic <- omic[,match(intersected_cells, colnames(omic))]
      drug <- drug[,match(intersected_cells, colnames(drug))]
      tmp_list[[paste0(x, "_", y)]] <- list(
        "omic" = omic,
        "drug" = drug
      )
    }
  }
  omics_search_list1[[i]] <- tmp_list
}
names(omics_search_list1)[names(omics_search_list1) %in% "exp"] <- "mRNA"

### Discrete ----
# Remake mutation_gene and mutation_site
tmp$tmp2 <- ls()[grepl("_mut$", ls())]
gCSI_mut$mutation <- NA
gCSI_mut$genes_muts <- NA
for(i in tmp$tmp2){
  omic <- base::get(i)
  omic_gene <- omic[,c(1,2)] %>% unique()
  omic_site <- omic[,c(4,2)] %>% unique()
  i2 <- paste0(gsub("mut", "", i), "mutation_gene")
  i3 <- paste0(gsub("mut", "", i), "mutation_site")
  assign(i2, omic_gene)
  assign(i3, omic_site)
}
rm(gCSI_mutation_site)

# Make
tmp$omic_sel2 <- c("mutation_gene", "mutation_site", "fusion")
tmp$tmp1 <- ls()[grepl("_drug$", ls())]
tmp$drug_vec <- gsub("_drug", "", tmp$tmp1[!grepl("^p_", tmp$tmp1)])
omics_search_list2 <- list()
for(i in tmp$omic_sel2){
  i2 <- paste0("_", i)
  tmp$omic_vec <- gsub(i2, "", ls()[grepl(i2, ls())])
  tmp_list <- list()
  for(x in tmp$omic_vec){
    # x = tmp$omic_vec[1]
    for(y in tmp$drug_vec){
      # y = tmp$drug_vec[1]
      # select identical cells
      omic <- base::get(paste0(x, i2))
      drug <- base::get(paste0(y, "_drug"))
      intersected_cells <- intersect(omic$cells, colnames(drug))
      omic <- omic[omic$cells %in% intersected_cells,]
      drug <- drug[,colnames(drug) %in% intersected_cells]
      tmp_list[[paste0(x, "_", y)]] <- list(
        "omic" = omic,
        "drug" = drug
      )
    }
  }
  omics_search_list2[[i]] <- tmp_list
}

# Features across different types ----
tmp$drug <- gsub("_drug", "", ls()[grepl("_drug", ls())]) 
tmp$drug <- tmp$drug[!grepl("^p_", tmp$drug)]
profile_vec_list <- list(
  # Continuous
  cnv = gsub("_cnv", "", ls()[grepl("_cnv", ls())]),
  protein = gsub("_protein", "", ls()[grepl("_protein", ls())]),
  meth = gsub("_meth", "", ls()[grepl("_meth", ls())]),
  mRNA = gsub("_exp", "", ls()[grepl("_exp", ls())]),
  drug = tmp$drug,
  # Discrete
  mutation_gene = gsub("_mutation_gene", "", ls()[grepl("_mutation_gene", ls())]),
  mutation_site = gsub("_mutation_site", "", ls()[grepl("_mutation_site", ls())]),
  fusion = gsub("_fusion", "", ls()[grepl("_fusion", ls())])
)

