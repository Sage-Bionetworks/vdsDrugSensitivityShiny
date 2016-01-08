
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
                             choices = organs,selected="bone")
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
                            choices = diseases,selected="BRCA")
                ),
               column(8,
                  plotlyOutput("drugRho")
                )
             )
             
    ),#End tabPanel 1
    tabPanel("Model 2",
      titlePanel("Drug Sensitivity"),
      
      # Sidebar with a slider input for the number of bins
      sidebarLayout(
        sidebarPanel(
          sliderInput("threshold","Choose a threshold Rho value:",value=-1,
                      min = 0,max=1,step=0.1),
          sliderInput("thresholdmedian","Choose a threshold median Rho value:",value=-1,
                      min = 0,max=1,step=0.1),
          
          selectInput("dataset", "Choose a drug:",
                      choices =drugs,selectize=T),
          h5("Disease area selected:", style="font-weight:700"),
          textOutput("diseaseAreaOutput"),
          checkboxInput('show_dt', 'Show data values', value = FALSE),
          
          conditionalPanel("input.show_dt",
                           checkboxGroupInput('show_vars', 'Columns to show:',
                              showtable, selected = showtable))
        ),
        
        # Show a plot of the generated distribution
        mainPanel(
          conditionalPanel("input.show_dt", dataTableOutput('mytable')),
          conditionalPanel("!input.show_dt",plotlyOutput("coolPlot"))
        )
      )
    )# End Model 2 Tab Panel
  
  )
))