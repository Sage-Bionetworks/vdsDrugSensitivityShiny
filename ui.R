
shinyUI(fluidPage(
  
  # Application title
  tabsetPanel(
    tabPanel("Model 2",
      titlePanel("Drug Sensitivity"),
      
      # Sidebar with a slider input for the number of bins
      sidebarLayout(
        sidebarPanel(
          selectInput("dataset", "Choose a dataset:",
                      choices =drugs),
          
          selectInput("disease", "Choose an area:",
                      choices = diseases)
          

        ),
        
        # Show a plot of the generated distribution
        mainPanel(
          plotlyOutput("coolPlot")
        )
      )
    ), # End Model 2 Tab Panel
    tabPanel("Model 1", 
      selectInput("organ", "Choose an area:",
                  choices = organ),
      checkboxInput("sort", "Sort Rho values", FALSE),
      plotlyOutput("vfsperf"))
  )
))