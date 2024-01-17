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


# Load ----
config <- config::get(
  config = "test"
  # Default is production mode
)

## Data----
source("Modules/LoadData.R")

## Modules----
source("Test/Test_Module/TEST.R")

# Preprocess ----
source("Script/Preprocess.R")
env <- environment()
## Welcome notification
# str1 <- "Nice to meet you."
# str2 <- "Very welcome to my version 2.0. —22/05/16"
# modal_notification <- modalDialog(
#   # p("Nice to meet you. \n, test"),
#   HTML(paste(str1, str2, sep = '<br/>')),
#   title = "Update Notification",
#   footer = tagList(
#     actionButton("close_modal", "Close")
#   )
# )

# UI ----
ui <- tagList(
  autoWaiter(html = spin_loader(), color = transparent(0.5)),
  navbarPage("OmicsPharDB (mugpeng@foxmail.com)",
                 ## Contact ----
                 tabPanel("Contact",
                         fluidPage(
                           strong("Feel free to talk with me if you find any bugs or have any suggestions. :)"),
                           p(""),
                           p("Email: mugpeng@foxmail.com"),
                           p("github: https://github.com/mugpeng")
                         )),
                 ## Features database significant analysis ----
                 tabPanel("Features database significant analysis",
                          uiFeatureDatabaseSig("FeatureDatabaseSig")
                 )
  )
)

# Server ----
server <- function(input, output, session) {
  # showModal(modal_notification)
  # Features database significant analysis ----
  callModule(serverFeatureDatabaseSig, "FeatureDatabaseSig")
}

# Run ----
shinyApp(ui = ui, server = server)
