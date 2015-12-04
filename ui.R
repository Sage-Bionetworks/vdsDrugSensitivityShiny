library(shiny)
library(plotly)
library(shiny)
shinyUI(fluidPage(
  
  # Application title
  tabsetPanel(
    tabPanel("Model 2",
      titlePanel("Drug Sensitivity"),
      
      # Sidebar with a slider input for the number of bins
      sidebarLayout(
        sidebarPanel(
          selectInput("dataset", "Choose a dataset:",
                      choices =list.files("out",full.names = T)),
          
          selectInput("disease", "Choose an area:",
                      choices = c("BLCA", "BRCA", "CESC","COAD", "ESCA", "GBM",  "HNSC", "KIRC", "KIRP", "LGG",  "LIHC",
                                  "LUAD", "LUSC", "OV", "PAAD", "PCPG", "PRAD", "SARC", "SKCM",
                                  "STAD", "TGCT", "THCA", "THYM")),
          textOutput("drug")
          
         # selectInput("disease", "Choose an area:",
          #            choices = names(R))
        ),
        
        # Show a plot of the generated distribution
        mainPanel(
          plotlyOutput("coolPlot")
        )
      )
    ), # End Model 2 Tab Panel
    tabPanel("Mdoel 1", 
      selectInput("organ", "Choose an area:",
                  choices = c("ALL", "autonomic_ganglia", "bone","breast", 
                              "central_nervous_system", "endometrium",  "kidney", 
                              "large_intestine", "liver", "lung",  "oesophagus",
                              "ovary", "pancreas", "skin", "soft_tissue", "stomach", 
                              "thyroid", "upper_aerodigestive_tract", "urinary_tract")),
      plotlyOutput("vfsperf"))
  )
))