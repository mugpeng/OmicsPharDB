# module1 ----
profile <- base::get(paste0("ccle", "_", "mutation_gene"))
sel_profile <- profile[profile[[1]] %in% "ABCC3",]
if(nrow(sel_profile) == 0){ return(NULL) }
## If cells in sel_profile, label "yes"
sel_profile_df1 <- data.frame(
  cells = sel_profile$cells,
  events = "yes"
)
sel_profile_df2 <- data.frame(
  cells = profile$cells[!profile$cells %in% sel_profile$cells],
  events = "no"
) %>% unique()
sel_profile_df <- rbind(sel_profile_df1, sel_profile_df2)
sel_profile_df <- base::merge(sel_profile_df, cell_anno[,1:2],
                              by.x = "cells", by.y = "Name")
sel_profile_fq <- as.data.frame(prop.table(table(sel_profile_df$events, sel_profile_df$Type), margin = 2))
colnames(sel_profile_fq) <- c("events", "Type", "Freq")
# Plot
pval <- chisq.test(table(sel_profile_df$events, sel_profile_df$Type))$p.value %>% round(4)
pval <- case_when(
  pval < 0.01 ~ "< 0.01",
  pval < 0.05 ~ "< 0.05",
  T ~ "> 0.05"
)
sel_profile_fq$Type <- factor(sel_profile_fq$Type)
p <- ggplot(sel_profile_fq) + 
  geom_bar(aes(x = Type, y= Freq*100, fill = events), color = "white",stat = "identity",width = 0.7,linewidth = 0.5)+ 
  theme_bw() + scale_fill_manual(values = c("#BEBADAFF", "#FB8072FF")) + 
  theme(
    axis.title.x = element_blank(), 
    axis.title.y = element_text(size = 15),
    plot.title = element_text(size = 15, face = "bold"),
    axis.text = element_text(size = 12),
    axis.text.x = element_text(angle = 60, vjust = 1, hjust = 1),
    legend.title = element_text(size = 15, face = "bold"),
    legend.text = element_text(size = 15)
  ) + scale_x_discrete(limit =levels(factor(unique(cell_anno$Type)))) + 
  labs(x='',y = 'Percentage(%)',
       title = x, 
       subtitle = paste0("Chi-Squared, p ", pval)) 

# module3 point ----
omics_search_list1_sel <- omics_search_list1[["mRNA"]]
x <- 2
omics_sel <- omics_search_list1_sel[[x]][[1]]
drugs_sel <- omics_search_list1_sel[[x]][[2]]

select_specific_drug <- "YM-155"
select_specific_omic <- "ABCC3"

sel_omics <- omics_sel[rownames(omics_sel) %in% select_specific_omic,] %>% as.numeric()
# sel_omics <- omics_sel[rownames(omics_sel) %in% "TSPAN6",] %>% as.numeric()
sel_drugs <- drugs_sel[rownames(drugs_sel) %in% select_specific_drug,] %>% as.numeric()
# sel_drugs <- drugs_sel[rownames(drugs_sel) %in% "YM-155",] %>% as.numeric()
if(length(na.omit(sel_omics)) == 0 | length(na.omit(sel_drugs)) == 0){ return(NULL) }
cor_df <- data.frame(
  genes = sel_omics,
  drugs = sel_drugs
)
p <- ggscatter(cor_df, x = "genes", y = "drugs",
               alpha = 0.2) + 
  stat_cor(size = 6, method = "spearman") + stat_smooth(formula = y ~ x,method = "lm") + theme_bw() + 
  theme(
    axis.title = element_blank(),
    title = element_text(size = 15, face = "bold"),
    axis.text = element_text(size = 12)
  ) + ggtitle(names(omics_search_list1_sel)[[x]])
p
p_list <- list(p,p,p,p,p,p,p,p,p)
wrap_plots(p_list, ncol = 3)

# module3 box ----
omics_search_list2_sel <- omics_search_list2[["mutation_gene"]]
x <- 4
omics_sel <- omics_search_list2_sel[[x]][[1]]
drugs_sel <- omics_search_list2_sel[[x]][[2]]

select_specific_drug <- "YM-155"
select_specific_omic <- "ABCC3"

sel_omics <- omics_sel$cells[omics_sel[[1]] %in% select_specific_omic] %>% unique()
# sel_omics <- omics_sel$cells[omics_sel[[1]] %in% "TP53"] %>% unique()
sel_drugs <- drugs_sel[rownames(drugs_sel) %in% select_specific_drug,] %>% as.numeric()
# sel_drugs <- drugs_sel[rownames(drugs_sel) %in% "YM-155",] %>% as.numeric()
yes_drugs <- sel_drugs[colnames(drugs_sel) %in% sel_omics] %>% na.omit()
no_drugs <- sel_drugs[!colnames(drugs_sel) %in% sel_omics] %>% na.omit()
if(length(yes_drugs) == 0 | length(no_drugs) == 0){ return(NULL) }
box_df <- data.frame(
  drugs = c(no_drugs, yes_drugs),
  events = rep(c("no","yes"), times = c(length(no_drugs), length(yes_drugs))))
p <- ggboxplot(data = box_df, x = "events", y = "drugs",
               fill = "events", palette = c("#BEBADAFF", "#FB8072FF"),
               add = "jitter", add.params = list(alpha = 0.2)) + 
  stat_compare_means(size = 6, label.x = 0.8) + theme_bw() + 
  theme(
    axis.title = element_blank(),
    title = element_text(size = 15, face = "bold"),
    axis.text = element_text(size = 12),
    axis.text.x = element_text(size = 15),
    legend.position = "none"
  ) + coord_cartesian(ylim = c(0, max(box_df$drugs) + max(box_df$drugs)/20)) +  
  ggtitle(names(omics_search_list2_sel)[[x]])
p
p_list <- list(p,p,p,p,p,p,p,p,p)

# module4 ----
select_features1 <- "fusion"
select_specific_feature <- "RARG--AAAS"
select_features2 <- "drug"


profile_vec1 <- profile_vec_list[[select_features1]]
profile_vec2 <- profile_vec_list[[select_features2]]
profile_comb <- expand.grid(profile_vec1, profile_vec2)

re_list <- list()
# nrow(profile_comb)
for(index in 1:nrow(profile_comb)){
  # index = 1
  # Prepare
  select_features1_2 <- select_features1
  if(select_features1_2 == "mRNA") select_features1_2 <- "exp"
  profile1 <- base::get(paste0(profile_comb[index,1], "_", select_features1_2), envir = env)
  select_features2_2 <- select_features2
  if(select_features2_2 == "mRNA") select_features2_2 <- "exp"
  profile2 <- base::get(paste0(profile_comb[index,2], "_", select_features2_2), envir = env)
  # Calculate significant in different cases
  # con vs con ----
  if(select_features1 %in% c("drug", "cnv",
                               "protein",
                               "meth",
                               "mRNA") & 
     select_features2 %in% c("drug", "cnv",
                             "protein",
                             "meth",
                             "mRNA")){
    # Select specific feature and all features data
    intersected_cells <- intersect(colnames(profile1), colnames(profile2))
    fea <- profile1[rownames(profile1) %in% select_specific_feature,
                    match(intersected_cells, colnames(profile1))] %>% as.numeric()
    db <- profile2[,match(intersected_cells, colnames(profile2))]
    db <- db[!rownames(db) %in% select_specific_feature,]
    fea_nrow <- profile1[rownames(profile1) %in% select_specific_feature,match(intersected_cells, colnames(profile1))] %>% nrow()
    if(fea_nrow == 0 | length(intersected_cells) == 0){next}
    sfInit(parallel = TRUE, cpus = 4)
    sfExport("db", "fea")
    re <- sfLapply(1:nrow(db), function(x){
      re2 <- tryCatch(cor.test(fea, as.numeric(db[x,])),
                      error = function(x){NA})
      if(all(is.na(re2))){
        re3 <- data.frame(
          p = NA,
          effect = NA
        )
      } else {
        re3 <- data.frame(
          p = re2$p.value,
          effect = re2$estimate)
      }
    })
    sfStop()
    re <- do.call(rbind, re)
    re$fea <- rownames(db)
    re <- na.omit(re)
    # dis vs dis ----
  } else if(!select_features1 %in% c("drug", "cnv",
                                    "protein",
                                    "meth",
                                    "mRNA") & 
            !select_features2 %in% c("drug", "cnv",
                                    "protein",
                                    "meth",
                                    "mRNA")){
    intersected_cells <- intersect(profile1[[2]], profile2[[2]]) %>% unique()
    fea <- profile1[profile1[[1]] %in% select_specific_feature,]
    db <- profile2[profile2[[2]] %in% intersected_cells,]
    db <- db[!db[[1]] %in% select_specific_feature,]
    db_feas <- unique(db[[1]])
    if(nrow(fea) == 0 | length(intersected_cells) == 0){next}
    sfInit(parallel = TRUE, cpus = 4)
    sfExport("db", "db_feas", "fea", "intersected_cells")
    re <- sfLapply(1:length(db_feas), function(x){
      fea_cells <- unique(as.data.frame(fea)[,2])
      sel_cells <- unique(as.data.frame(db[db[[1]] %in% db_feas[x],])[,2])
      yes_yes <- length(intersected_cells[intersected_cells %in% intersect(fea_cells, sel_cells)])
      yes_no <- length(intersected_cells[intersected_cells %in% fea_cells & !(intersected_cells %in% sel_cells)])
      no_yes <- length(intersected_cells[intersected_cells %in% sel_cells & !(intersected_cells %in% fea_cells)])
      no_no <- length(intersected_cells[!intersected_cells %in% c(fea_cells, sel_cells)])
      chi_df <- t(data.frame(
        yes = c(yes_yes, yes_no),
        no = c(no_yes, no_no)
      ))
      re2 <- tryCatch(
        chisq.test(chi_df),
        error = function(x){NA}
      )
      if(all(is.na(re2))){
        re3 <- data.frame(
          p = NA,
          effect = NA
        )
      } else {
        re3 <- data.frame(
          p = re2$p.value,
          effect = re2$statistic
        )
      }
      re3
    })
    sfStop()
    re <- do.call(rbind, re)
    re$fea <- db_feas
    re <- na.omit(re)
    # con vs dis ----
  } else if(select_features1 %in% c("drug", "cnv",
                                     "protein",
                                     "meth",
                                     "mRNA") & 
            !select_features2 %in% c("drug", "cnv",
                                     "protein",
                                     "meth",
                                     "mRNA")){
    intersected_cells <- intersect(colnames(profile1), profile2[[2]]) %>% unique()
    fea <- profile1[rownames(profile1) %in% select_specific_feature,
                    match(intersected_cells, colnames(profile1))]
    db <- profile2[profile2[[2]] %in% intersected_cells,]
    db_feas <- unique(db[[1]])
    if(nrow(fea) == 0 | length(intersected_cells) == 0){next}
    sfInit(parallel = TRUE, cpus = 4)
    sfExport("db", "db_feas", "fea", "db_feas")
    re <- sfLapply(1:length(db_feas), function(x){
      sel_cells <- as.data.frame(db[db[[1]] %in% db_feas[x],2])
      sel_cells <- sel_cells[,1]
      yes_drugs <- na.omit(as.numeric(fea[,colnames(fea) %in% sel_cells]))
      no_drugs <- na.omit(as.numeric(fea[,!colnames(fea) %in% sel_cells]))
      re2 <- tryCatch(
        wilcox.test(yes_drugs, no_drugs),
        error = function(x){NA}
      )
      if(all(is.na(re2))){
        re3 <- data.frame(
          p = NA,
          effect = NA
        )
      } else {
        re3 <- data.frame(
          p = re2$p.value,
          effect = log2(median(yes_drugs)/median(no_drugs))
        )
      }
      re3
    })
    sfStop()
    re <- do.call(rbind, re)
    re$fea <- db_feas
    re <- na.omit(re)
    # dis vs con ----
  } else if(!select_features1 %in% c("drug", "cnv",
                                    "protein",
                                    "meth",
                                    "mRNA") & 
           select_features2 %in% c("drug", "cnv",
                                    "protein",
                                    "meth",
                                    "mRNA")){
    intersected_cells <- intersect(profile1[[2]], colnames(profile2)) %>% unique()
    db <- profile2[,colnames(profile2) %in% intersected_cells]
    sel_omics <- profile1$cells[profile1[[1]] %in% select_specific_feature] %>% unique()
    if(length(intersected_cells) == 0 | length(sel_omics) == 0){next}
    sfInit(parallel = TRUE, cpus = 4)
    sfExport("db", "sel_omics")
    re <- sfLapply(1:nrow(db), function(x){
      # x = 1
      yes_drugs <- na.omit(as.numeric(db[x,colnames(db) %in% sel_omics]))
      no_drugs <- na.omit(as.numeric(db[x,!colnames(db) %in% sel_omics]))
      re2 <- tryCatch(
        wilcox.test(yes_drugs, no_drugs),
        error = function(x){NA}
      )
      if(all(is.na(re2))){
        re3 <- data.frame(
          p = NA,
          effect = NA
        )
      } else {
        re3 <- data.frame(
          p = re2$p.value,
          effect = log2(mean(yes_drugs)/mean(no_drugs))
          )
      }
    })
    sfStop()
    re <- do.call(rbind, re)
    re$fea <- rownames(db)
    re <- na.omit(re)
  }
  if(nrow(re) == 0){ next }
  re$sig <- "no"
  # re$sig[re$R > quantiles_80 | re$R < quantiles_20] <- "sig"
  re$sig[abs(re$effect) > .2 & re$p < .05] <- "sig"
  # add name
  re$database <- paste0(profile_comb$Var1[index], "_", profile_comb$Var2[index])
  rownames(re) <- NULL
  print("finish!")
  re_list[[index]] <- re
}
# names(re_list) <- paste0(profile_comb$Var1, "_", profile_comb$Var2)
re_list <- re_list[!sapply(re_list, is.null)]
re_df <- do.call(rbind, re_list)

re_name_list1 <- lapply(re_list, function(x){
  x$fea
})
re_name_list2 <- lapply(re_list, function(x){
  # x$sig2 <- "no"
  # x$sig2[abs(x$R) > .2] <- "sig"
  # quantiles_80 <- quantile(x$R, probs = c(0.1, 0.9))[2]
  # quantiles_20 <- quantile(x$R, probs = c(0.1, 0.9))[1]
  # x$sig2 <- "no"
  # x$sig2[x$R > quantiles_80 | x$R < quantiles_20] <- "sig"
  x$fea[x$sig %in% "sig"]
})


test1 <- unlist(re_name_list1, use.names = F) 
test1 <- as.data.frame(table(test1))
colnames(test1)[1] <- "Name"
test2 <- unlist(re_name_list2, use.names = F)
test2 <- as.data.frame(table(test2))
colnames(test2)[1] <- "Name"
test2_2 <- data.frame(
  Name = test1$Name[!test1$Name %in% test2$Name],
  Freq = 0
)
test2 <- rbind(test2, test2_2)
test2 <- test2[match(test1$Name,test2$Name),]
test <- test2
test$Prop <- test2$Freq/test1$Freq
test <- test[order(test$Prop, test$Freq, decreasing = T),]

sel_name <- test[1,1]
re_sel <- lapply(re_list, function(x){
  x[x$fea %in% sel_name,]
})
re_sel <- do.call(rbind, re_sel)
# re_sel <- re[re$fea %in% sel_name,]

# Plot
p_overlap_drug <- upset(fromList(re_name_list), nsets = length(re_name_list), mainbar.y.label = "Overlap significant feature counts", text.scale = 2)
p_overlap_drug
