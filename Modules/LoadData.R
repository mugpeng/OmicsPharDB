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

# Finished Plot obj ----
load("Input/04/stat_plot.Rda")
load("Input/05/drug_sens_plot.Rda")
