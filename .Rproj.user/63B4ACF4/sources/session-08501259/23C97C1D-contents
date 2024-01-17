# Preparation ----
library(shiny)
library(waiter) # wait while running
library(DT)
# library(shinydashboard)
library(config)

# Manipulate data
library(dplyr)
library(data.table)

# Plot
library(UpSetR)
library(ggpubr)
library(plotly)
library(ggrepel)
library(patchwork)

# Multithreads
library(snowfall)

## Debug
# library(reactlog)

# Load ----
config <- config::get(
  # config = "test"
  # Default is production mode
)

## Data----
source("Modules/LoadData.R")

## Modules----
source("Modules/DrugOmicPair.R")
source("Modules/FeatureAcrossType.R")
source("Modules/ProfileDrugSens.R")
source("Modules/FeatureDatabaseSig_singlethread.R")
source("Modules/StatAnno.R")

# Preprocess ----
source("Script/Preprocess.R")
env <- environment()
# Welcome notification
str1 <- "Nice to meet you."
str2 <- "Very welcome to my version 1.0. —24/01/17"
modal_notification <- modalDialog(
  # p("Nice to meet you. \n, test"),
  HTML(paste(str1, str2, sep = '<br/>')),
  title = "Update Notification",
  footer = tagList(
    actionButton("close_modal", "Close")
  )
)

# UI ----
ui <- tagList(
  tags$head(
    tags$title("OmicsPharDB (mugpeng@foxmail.com)"),
  ),
  autoWaiter(html = spin_loader(), color = transparent(0.5)),
  navbarPage("OmicsPharDB (mugpeng@foxmail.com)",
             ## Drugs-omics pairs analysis ----
             tabPanel("Drugs-omics pairs Analysis",
                      uiDrugOmicPair("DrugOmicPair")
             ),
             ## Profiles Display ----
             navbarMenu("Profiles Display",
                        ### Features across different types ----
                        tabPanel("Features across different types",
                                 uiFeatureAcrossType("FeatureAcrossType")
                        ),
                        ### Profile of drug sensitivity ----
                        tabPanel("Profile of drug sensitivity",
                                 uiProfileDrugSens("ProfileDrugSens")  
                        ),
             ),
             ## Features database significant analysis ----
             tabPanel("Features database significant analysis",
                      uiFeatureDatabaseSig("FeatureDatabaseSig")
             ),
             ## Statistics and Annotations ----
             tabPanel("Statistics and Annotations",
                      uiStatAnno("StatAnno")
             ),
             ## Contact ----
             tabPanel("Contact",
                      fluidPage(
                        strong("Feel free to talk with me if you find any bugs or have any suggestions. :)"),
                        p(""),
                        p("Email: mugpeng@foxmail.com"),
                        p("github: https://github.com/mugpeng")
                      ))
  )
)


# Server ----
server <- function(input, output, session) {
  # Some setup ----
  showModal(modal_notification) # notification
  observeEvent(input$close_modal, {
    removeModal()
  })
  # stop warn
  storeWarn <- getOption("warn")
  options(warn = -1) 
  # Drugs-omics pairs analysis ----
  callModule(serverDrugOmicPair, "DrugOmicPair")
  # Features across different types ----
  callModule(serverFeatureAcrossType, "FeatureAcrossType")
  # Profile of drug sensitivity ----
  callModule(serverProfileDrugSens, "ProfileDrugSens")
  # Features database significant analysis ----
  callModule(serverFeatureDatabaseSig, "FeatureDatabaseSig")
  # Statistics and Annotations ----
  callModule(serverStatAnno, "StatAnno")
}


# Run ----
shinyApp(ui = ui, server = server)
