
shinyUI(fluidPage(
  
  # Application title
  tabsetPanel(
    tabPanel("Model 1", 
             titlePanel("Drug Sensitivity"),
             
             # Sidebar with a slider input for the number of bins
             sidebarLayout(
               sidebarPanel(
                 
                 selectInput("organ", "Choose an area:",
                             selectize=T,#multiple=T,
                             choices = organs,selected="bone"),
                 sliderInput("threshold","Choose a threshold:",value=-1,
                             min = 0,max=1,step=0.1)
               ),
               mainPanel(
                 plotlyOutput("vfsperf")
               )
             )
    ),#End tabPanel 1
    tabPanel("Model 2",
      titlePanel("Drug Sensitivity"),
      
      # Sidebar with a slider input for the number of bins
      sidebarLayout(
        sidebarPanel(
          selectInput("dataset", "Choose a dataset:",
                      choices =drugs,selectize=T),
          
          selectInput("disease", "Choose an area:",
                      choices = diseases,selectize=T,multiple=T,
                      selected = "BRCA"),
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
    ), # End Model 2 Tab Panel
    

    tabPanel("Model 3", 
             titlePanel("Drug Sensitivity"),
             
             # Sidebar with a slider input for the number of bins
             sidebarLayout(
               sidebarPanel(
                 
                 selectInput("diseaseArea", "Choose an area:",
                             selectize=T,#multiple=T,
                             choices = diseases,selected="BRCA")
               ),
               mainPanel(
                 plotlyOutput("drugRho")
               )
             )
    )#End tabPanel 3
  )
))