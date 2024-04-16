# Omics data ----
if(config_list$test_mode == "T"){
  # Test files
  load("Input/03/exp.Rda")
  load("Input/03/cnv.Rda")
  load("Input/03/meth.Rda")
} else{
  load("Input/01/exp.Rda")
  load("Input/01/cnv.Rda")
  load("Input/01/meth.Rda")
}

# Small file
load("Input/01/protein.Rda")
load("Input/01/fusion.Rda")
load("Input/01/mut.Rda")

# Drug and annotation data ----
load("Input/02/drug2.Rda")
load("Input/04/anno.Rda")

# Finished Plot or preplot obj ----
load("Input/04/stat_plot.Rda")
load("Input/05/drug_sens_profile.Rda")

# Function ----
plotMADandMedian <- function(ms, dataset){
  ms$Dataset <- dataset
  p <- ggplot(data = ms, 
              aes(text = Name, x = Mad,
                  y = Median, label = Target, label2 = Dataset)) +
    geom_point(alpha=0.4, size=3.5, 
               aes(color=Phase)) + theme_bw() + 
    scale_color_manual(values = paletteer::paletteer_d("ggsci::default_igv")) + 
    labs(x = "MAD", y = "Median") + 
    theme(
      axis.title = element_text(size = 15),
      title = element_text(size = 15, face = "bold"),
      axis.text = element_text(size = 12), 
      legend.text = element_text(size = 12)
    )
  return(p)
}

plotTSNE <- function(df, dataset){
  df$Dataset <- dataset
  p <- ggplot(data = df, 
              aes(text = Name, x = TSNE1,
                  y = TSNE2, label = Target, label2 = Dataset)) +
    geom_point(alpha=0.4, size=3.5, 
               aes(color=Phase)) + theme_bw() + 
    scale_color_manual(values = paletteer::paletteer_d("ggsci::default_igv")) + 
    labs(x = "TSNE1", y = "TSNE2") + 
    theme(
      axis.title = element_text(size = 15),
      title = element_text(size = 15, face = "bold"),
      axis.text = element_text(size = 12), 
      legend.text = element_text(size = 12)
    )
  return(p)
}
