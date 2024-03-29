# Global setting ---------------------------------------------------------
options(shiny.fullstacktrace=TRUE)
xena.runMode <- getOption("xena.runMode", default = "client")
message("Run mode: ", xena.runMode)

if (is.null(getOption("xena.cacheDir"))) {
  options(xena.cacheDir = switch(xena.runMode,
                                 client = file.path(tempdir(), "UCSCXenaShiny"), 
                                 server = "~/.xenashiny"
  ))
}

# Path for storing dataset files
XENA_DEST <- path.expand(file.path(getOption("xena.cacheDir"), "datasets"))

if (!dir.exists(XENA_DEST)) {
  dir.create(XENA_DEST, recursive = TRUE)
}

# Set default path for saving extra-data downloaded from https://zenodo.org
if (xena.runMode == "server") {
  if (is.null(getOption("xena.zenodoDir"))) options(xena.zenodoDir = XENA_DEST)
}

# Load necessary packages ----------------------------------
message("Checking depedencies...")

if (!requireNamespace("pacman")) {
  install.packages("pacman", repos = "http://cran.r-project.org")
}
library(pacman)

if (!requireNamespace("gganatogram")) {
  pacman::p_load(remotes)
  tryCatch(
    remotes::install_github("jespermaag/gganatogram"),
    error = function(e) {
      remotes::install_git("https://gitee.com/XenaShiny/gganatogram")
    }
  )
}

if (!requireNamespace("ggradar")) {
  pacman::p_load(remotes)
  tryCatch(
    remotes::install_github("ricardo-bion/ggradar"),
    error = function(e) {
      remotes::install_git("https://gitee.com/XenaShiny/ggradar")
    }
  )
}

if (packageVersion("UCSCXenaTools") < "1.4.4") {
  tryCatch(
    install.packages("UCSCXenaTools", repos = "http://cran.r-project.org"),
    error = function(e) {
      warning("UCSCXenaTools <1.4.4, this shiny has a known issue (the download button cannot be used) to work with it. Please upate this package!",
        immediate. = TRUE
      )
    }
  )
}

pacman::p_load(
  purrr,
  tidyr,
  stringr,
  magrittr,
  R.utils,
  data.table,
  dplyr,
  ggplot2,
  UpSetR,
  cowplot,
  patchwork,
  ggpubr,
  plotly,
  UCSCXenaTools,
  UCSCXenaShiny,
  shiny,
  shinyBS,
  shinyjs,
  shinyWidgets,
  shinyalert,
  shinyFiles,
  shinyFeedback,
  shinythemes,
  shinyhelper,
  survival,
  survminer,
  ezcox,
  waiter,
  colourpicker,
  DT,
  fs,
  RColorBrewer,
  gganatogram,
  ggcorrplot,
  ggstatsplot,
  ggradar,
  zip
)

options(shiny.maxRequestSize=1024*1024^2)
message("Starting...")

# Put data here -----------------------------------------------------------
data("XenaData", package = "UCSCXenaTools", envir = environment())
xena_table <- XenaData[, c(
  "XenaDatasets", "XenaHostNames", "XenaCohorts",
  "SampleCount", "DataSubtype", "Label", "Unit"
)]
xena_table$SampleCount <- as.integer(xena_table$SampleCount)
colnames(xena_table)[c(1:3)] <- c("Dataset ID", "Hub", "Cohort")

# Used in TCGA survival module
TCGA_datasets <- xena_table %>%
  dplyr::filter(Hub == "tcgaHub") %>%
  dplyr::select("Cohort") %>%
  unique() %>%
  dplyr::mutate(
    id = stringr::str_match(Cohort, "\\((\\w+?)\\)")[, 2],
    des = stringr::str_match(Cohort, "(.*)\\s+\\(")[, 2]
  ) %>%
  dplyr::arrange(id)

# Used in genecor and pancan-search-cancer module script
tcga_cancer_choices <- c(
  "SKCM", "THCA", "SARC", "PRAD", "PCPG", "PAAD", "HNSC", "ESCA",
  "COAD", "CESC", "BRCA", "TGCT", "KIRP", "KIRC", "LAML", "READ",
  "OV", "LUAD", "LIHC", "UCEC", "GBM", "LGG", "UCS", "THYM", "STAD",
  "DLBC", "LUSC", "MESO", "KICH", "UVM", "BLCA", "CHOL", "ACC"
)

TCGA_cli_merged <- dplyr::full_join(
  load_data("tcga_clinical"),
  load_data("tcga_surv"),
  by = "sample"
)

pancan_identifiers <- readRDS(
  system.file(
    "extdata", "pancan_identifier_list.rds",
    package = "UCSCXenaShiny"
  )
)
all_preload_identifiers <- c("NONE", as.character(unlist(pancan_identifiers)))
tryCatch(
  load_data("transcript_identifier"),
  error = function(e) {
    stop("Load data failed, please run load_data('transcript_identifier') by hand before restarting the Shiny.")
  }
)

phenotype_datasets <- UCSCXenaTools::XenaData %>%
  dplyr::filter(Type == "clinicalMatrix") %>%
  dplyr::pull(XenaDatasets)


themes_list <- list(
  "cowplot" = cowplot::theme_cowplot(),
  "Light" = theme_light(),
  "Minimal" = theme_minimal(),
  "Classic" = theme_classic(),
  "Gray" = theme_gray(),
  "half_open" = cowplot::theme_half_open(),
  "minimal_grid" = cowplot::theme_minimal_grid()
)


## 通路基因
PW_meta <- load_data("tcga_PW_meta")
PW_meta <- PW_meta %>% 
  dplyr::arrange(Name) %>%
  dplyr::mutate(size = purrr::map_int(Gene, function(x){
    x_ids = strsplit(x, "/", fixed = TRUE)[[1]]
    length(x_ids)
  }), .before = 5) %>% 
  dplyr::mutate(display = paste0(Name, " (", size, ")"), .before = 6)


## TCGA/PCAWG/CCLE value & id for general analysis
general_value_id = UCSCXenaShiny:::query_general_id()
# id
tcga_id_option = general_value_id[["id"]][[1]]
pcawg_id_option = general_value_id[["id"]][[2]]
ccle_id_option = general_value_id[["id"]][[3]]
# value
tcga_value_option = general_value_id[["value"]][[1]]
tcga_index_value = tcga_value_option[["Tumor index"]]
tcga_immune_value = tcga_value_option[["Immune Infiltration"]]
tcga_pathway_value = tcga_value_option[["Pathway activity"]]
tcga_phenotype_value = tcga_value_option[["Phenotype data"]]

pcawg_value_option = general_value_id[["value"]][[2]]
pcawg_index_value = pcawg_value_option[["Tumor index"]]
pcawg_immune_value = pcawg_value_option[["Immune Infiltration"]]
pcawg_pathway_value = pcawg_value_option[["Pathway activity"]]
pcawg_phenotype_value = pcawg_value_option[["Phenotype data"]]

ccle_value_option = general_value_id[["value"]][[3]]
ccle_index_value = ccle_value_option[["Tumor index"]]
ccle_phenotype_value = ccle_value_option[["Phenotype data"]]

TIL_signatures = lapply(tcga_id_option$`Immune Infiltration`, function(x) {
  x$all
}) %>% reshape2::melt() %>% 
  dplyr::mutate(x = paste0(value,"_",L1)) %>%
  dplyr::pull(x)

# Help → ID reference
tcga_id_referrence = load_data("pancan_identifier_help")
pcawg_id_referrence = load_data("pcawg_identifier")
ccle_id_referrence = load_data("ccle_identifier")



code_types = list("NT"= "NT (normal tissue)",
          "TP"= "TP (primary tumor)",
          "TR"= "TR (recurrent tumor)",
          "TB"= "TB (blood derived tumor)",
          "TAP"="TAP (additional primary)",
          "TM"= "TM (metastatic tumor)",
          "TAM"="TAM (additional metastatic)")

# CCLE tissues for drug analysis
# "ALL" means all tissues
ccle_drug_related_tissues <- c(
  "ALL", "prostate", "central_nervous_system", "urinary_tract", "haematopoietic_and_lymphoid_tissue",
  "kidney", "thyroid", "soft_tissue", "skin", "salivary_gland",
  "ovary", "lung", "bone", "endometrium", "pancreas", "breast",
  "large_intestine", "upper_aerodigestive_tract", "autonomic_ganglia",
  "stomach", "liver", "biliary_tract", "pleura", "oesophagus"
)

# Data summary
Data_hubs_number <- length(unique(xena_table$Hub))
Cohorts_number <- length(unique(xena_table$Cohort))
Datasets_number <- length(unique(xena_table$`Dataset ID`))
Samples_number <- "~2,000,000"
Primary_sites_number <- "~37"
Data_subtypes_number <- "~45"
Xena_summary <- dplyr::group_by(xena_table, Hub) %>%
  dplyr::summarise(
    n_cohort = length(unique(.data$Cohort)),
    n_dataset = length(unique(.data$`Dataset ID`)), .groups = "drop"
  )

# PCAWG project info
pcawg_items = sort(unique(pcawg_info_fine$Project)) #30
dcc_project_code_choices <- c(
  "BLCA-US", "BRCA-US", "OV-AU", "PAEN-AU", "PRAD-CA", "PRAD-US", "RECA-EU", "SKCM-US", "STAD-US",
  "THCA-US", "KIRP-US", "LIHC-US", "PRAD-UK", "LIRI-JP", "PBCA-DE", "CESC-US", "PACA-AU", "PACA-CA",
  "LAML-KR", "COAD-US", "ESAD-UK", "LINC-JP", "LICA-FR", "CLLE-ES", "HNSC-US", "EOPC-DE", "BRCA-UK",
  "BOCA-UK", "MALY-DE", "CMDI-UK", "BRCA-EU", "ORCA-IN", "BTCA-SG", "SARC-US", "KICH-US", "MELA-AU",
  "DLBC-US", "GACA-CN", "PAEN-IT", "GBM-US", "KIRC-US", "LAML-US", "LGG-US", "LUAD-US", "LUSC-US",
  "OV-US", "READ-US", "UCEC-US"
)

## PharmacoGenomics ----
### load data
## mut
OP_mut <- UCSCXenaShiny::load_data("OP_mut")
ccle_mut <- OP_mut$ccle
gdsc_mut <- OP_mut$gdsc
gCSI_mut <- OP_mut$gCSI

## cnv
OP_cnv <- UCSCXenaShiny::load_data("OP_cnv")
ccle_cnv <- OP_cnv$ccle
gdsc_cnv <- OP_cnv$gdsc
gCSI_cnv <- OP_cnv$gCSI

## mRNA,exp
OP_exp <- UCSCXenaShiny::load_data("OP_exp")
ccle_exp <- OP_exp$ccle
gdsc_exp <- OP_exp$gdsc

## meth
OP_meth <- UCSCXenaShiny::load_data("OP_meth")
ccle_meth <- OP_meth$ccle

## fusion
OP_fusion <- UCSCXenaShiny::load_data("OP_fusion")
ccle_fusion <- OP_fusion$ccle

## protein
OP_protein <- UCSCXenaShiny::load_data("OP_protein")
ccle_protein <- OP_protein$ccle

## drug,anno
OP_drug <- UCSCXenaShiny::load_data("OP_drug")
ctrp1_drug <- OP_drug$ctrp1
ctrp2_drug <- OP_drug$ctrp2
gCSI_drug <- OP_drug$gCSI
gdsc1_drug <- OP_drug$gdsc1
gdsc2_drug <- OP_drug$gdsc2
prism_drug <- OP_drug$prism

OP_anno <- UCSCXenaShiny::load_data("OP_anno")
cell_anno <- OP_anno$cell
drug_anno <- OP_anno$drug

## plot
OP_stat_plot <- UCSCXenaShiny::load_data("OP_stat_plot")
p_count_drugandcell <- OP_stat_plot$count_drugandcell
p_count_subtype <- OP_stat_plot$count_subtype
p_overlap_cell <- OP_stat_plot$overlap_cell
p_overlap_drug <- OP_stat_plot$overlap_drug

OP_drug_sens_plot <- UCSCXenaShiny::load_data("OP_drug_sens_plot")
p_ms_gdsc1 <- OP_drug_sens_plot$ms_gdsc1
p_ms_gdsc2 <- OP_drug_sens_plot$ms_gdsc2
p_ms_prism <- OP_drug_sens_plot$ms_prism
p_ms_gCSI <- OP_drug_sens_plot$ms_gCSI
p_ms_ctrp1 <- OP_drug_sens_plot$ms_ctrp1
p_ms_ctrp2 <- OP_drug_sens_plot$ms_ctrp2
p_tsne_gdsc1 <- OP_drug_sens_plot$tsne_gdsc1
p_tsne_gdsc2 <- OP_drug_sens_plot$tsne_gdsc2
p_tsne_prism <- OP_drug_sens_plot$tsne_prism
p_tsne_gCSI <- OP_drug_sens_plot$tsne_gCSI
p_tsne_ctrp1 <- OP_drug_sens_plot$tsne_ctrp1
p_tsne_ctrp2 <- OP_drug_sens_plot$tsne_ctrp2

## misc and preprocess
# source("inst/shinyapp/modules/PharmacoGenomics/Preprocess.R")
OP_misc <- UCSCXenaShiny::load_data("OP_misc")
omics_search <- OP_misc$omics_search
drugs_search <- OP_misc$drugs_search
drugs_search2 <- OP_misc$drugs_search2
profile_vec_list <- OP_misc$profile_vec_list

# Put modules here --------------------------------------------------------
modules_path <- system.file("shinyapp", "modules", package = "UCSCXenaShiny", mustWork = TRUE)
modules_file <- dir(modules_path, pattern = "\\.R$", full.names = TRUE, recursive = TRUE)
sapply(modules_file, function(x, y) source(x, local = y), y = environment())


# Put page UIs here -----------------------------------------------------
pages_path <- system.file("shinyapp", "ui", package = "UCSCXenaShiny", mustWork = TRUE)
pages_file <- dir(pages_path, pattern = "\\.R$", full.names = TRUE, recursive = TRUE)
sapply(pages_file, function(x, y) source(x, local = y), y = environment())


# Obtain path to individual server code parts ----------------------------
server_file <- function(x) {
  server_path <- system.file("shinyapp", "server",
    package = "UCSCXenaShiny", mustWork = TRUE
  )
  file.path(server_path, x)
}


# Set utility functions ---------------------------------------------------
QUERY_CACHE <- dplyr::tibble()
xe_query_url <- function(data, use_cache = TRUE) {
  if (use_cache) {
    if (nrow(QUERY_CACHE) == 0) {
      non_exist_idx <- !data$XenaDatasets %in% NULL
    } else {
      non_exist_idx <- !data$XenaDatasets %in% QUERY_CACHE$datasets
    }
    if (any(non_exist_idx)) {
      non_exist_query <- xe_query_url(data[non_exist_idx, , drop = FALSE], use_cache = FALSE)
      QUERY_CACHE <<- dplyr::bind_rows(
        QUERY_CACHE,
        non_exist_query
      )
    }

    xe_query <- dplyr::filter(QUERY_CACHE, QUERY_CACHE$datasets %in% data$XenaDatasets)
  } else {
    xe <-
      UCSCXenaTools::XenaGenerate(subset = XenaDatasets %in% data$XenaDatasets)

    xe_query <- UCSCXenaTools::XenaQuery(xe)
    xe_query$browse <- purrr::map2(
      xe_query$datasets, xe_query$hosts,
      ~ utils::URLencode(
        paste0(
          "https://xenabrowser.net/datapages/?",
          "dataset=", .x, "&host=", .y
        )
      )
    ) %>% unlist()
  }

  return(xe_query)
}

get_data_df <- function(dataset, id) {
  if (dataset == "custom_phenotype_dataset") {
    message("Loading custom phenotype data.")
    df <- readRDS(file.path(tempdir(), "custom_phenotype_data.rds"))
  } else {
    message("Querying data of identifier ", id, " from dataset ", dataset)
    id_value <- if (dataset == "custom_feature_dataset") {
      UCSCXenaShiny:::query_custom_feature_value(id)
    } else {
      UCSCXenaShiny::query_molecule_value(dataset, id)
    }
    df <- dplyr::tibble(
      sample = names(id_value),
      X = as.numeric(id_value)
    )
    colnames(df)[2] <- id 
  }
  df
}

# UI part ----------------------------------------------------------------------
ui <- tagList(
  tags$head(
    tags$title("XenaShiny"),
    tags$style(
      HTML(".shiny-notification {
              height: 100px;
              width: 800px;
              position:fixed;
              top: calc(50% - 50px);;
              left: calc(50% - 400px);;
            }")
    ),
    tags$style(
      '[data-value = "Sole Analysis for Single Cancer"] {
        width: 400px;
       background-color: #bdbdbd;
      }
       [data-value = "Sole Analysis for Multiple Cancers"] {
        width: 400px;
       background-color: #525252;
      }
       [data-value = "Batch Analysis for Single Cancer"] {
        width: 400px;
       background-color: #525252;
      }
       [data-value = "Sole Analysis for Cell Lines"] {
        width: 400px;
       background-color: #bdbdbd;
      }
       [data-value = "Batch Analysis for Cell Lines"] {
        width: 400px;
       background-color: #525252;
      }
      .tab-pane {
        background-color: transparent;
        width: 100%;
        }
      .nav-tabs {font-size: 20px}   
      '
    )
  ),
  shinyjs::useShinyjs(),
  autoWaiter(html = spin_loader(), color = transparent(0.5)), # change style https://shiny.john-coene.com/waiter/
  navbarPage(
    id = "navbar",
    title = div(
      img(src = "xena_shiny-logo_white.png", height = 49.6, style = "margin:-20px -15px -15px -15px")
    ),
    windowTitle = "UCSCXenaShiny",
    # inst/shinyapp/ui
    ui.page_home(),
    ui.page_repository(),
    ui.page_general_analysis(),
    ui.page_pancan_tcga(),
    # ui.page_pancan_pcawg(),
    # ui.page_pancan_ccle(),
    ui.page_pancan_quick(),
    ui.page_PharmacoGenomics(),
    ui.page_download(),
    # ui.page_global(),
    ui.page_help(),
    ui.page_developers(),
    footer = ui.footer(),
    collapsible = TRUE,
    theme = tryCatch(shinythemes::shinytheme("flatly"),
                     error = function(e) {
                       "Theme 'flatly' is not available, use default."
                       NULL
                     })
  )
)

# Server Part ---------------------------------------------------------------
server <- function(input, output, session) {
  message("Shiny app run successfully! Enjoy it!\n")
  message("               --  Xena shiny team\n")

  # inst/shinyapp/server
  source(server_file("home.R"), local = TRUE)
  source(server_file("repository.R"), local = TRUE)
  source(server_file("modules.R"), local = TRUE)
  # source(server_file("global.R"), local = TRUE)
  source(server_file("general-analysis.R"), local = TRUE)
  observe_helpers(help_dir ="helper")

}

# Run web app -------------------------------------------------------------
shiny::shinyApp(
  ui = ui,
  server = server
)
