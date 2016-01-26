shinyUI(fluidPage(
  
  # Application title
  tabsetPanel(
    tabPanel("Model 1 & 3",
             # Model 1
             titlePanel("Cell Line Drug Sensitivity"),
             # Sidebar with a slider input for the number of bins
             fluidRow(
               column(4,
                 
                 selectInput("organ", "Choose an organ:",
                             selectize=T,#multiple=T,
                             choices = organs,selected="ALL"),
                 sliderInput("threshold","Choose a threshold Rho value:",value=-1,
                             min = 0,max=1,step=0.1),
                 selectInput("drugList1", "Highlight a drug:",
                             selectize=T,multiple=T,
                             choices = drugs)
                 
               ),
               column(8,
                 plotlyOutput("vfsperf")
               )
             ),
             
             # Model 3
             br(),
             titlePanel("Disease Performance Drug Sensitivity"),
             fluidRow(
               column(4,
                 selectInput("diseaseArea", "Choose an area:",
                            selectize=T,multiple=T,
                            choices = diseases,selected="BRCA"),
                 sliderInput("thresholdMedian","Choose a threshold median Rho value:",value=-1,
                             min = 0,max=1,step=0.1),
                 selectInput("drugList2", "Highlight a drug:",
                             selectize=T,multiple=T,
                             choices = drugs)
                ),
               column(8,
                  plotlyOutput("drugRho")
                )
             )
             
    ),#End tabPanel 1
    
    tabPanel("Model 2",
      titlePanel("Drug Sensitivity"),
      
      # Sidebar with a slider input for the number of bins
      fluidRow(
        column(4,
               span("Selected organ: ", style="font-size:14px;font-weight:700"),
               textOutput("selectedOrgan"),
               br(),
               selectInput("drugList3", "Choose a drug:",
                           choices = drugs,selectize=T),
               span("Selected area: ", style="font-size:14px;font-weight:700"),
               textOutput("selectedArea"),
               br(),
               selectInput("otherDiseaseList", "Compare with other area:",
                           selectize=T,multiple=T,
                           choices = diseases),
               sliderInput("thresholdEM","Choose a threshold Effect Magnitude:",value=-1,
                           min = 0,max=0.02,step=0.001)
        ),
        # Show a plot of the generated distribution
        column(8,
               plotlyOutput("dsPlot")
        )
      ),
      
      br(),
      br(),
      br(),
      fluidRow(
        column(4,
               checkboxGroupInput('show_vars', 'Columns to show:',
                                  showtable, selected = showtable)
        ),
        column(8,
               dataTableOutput('dsDataTable')
        )
      )
    )# End Model 2 Tab Panel
  )
))