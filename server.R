shinyServer(function(input, output) {
  
  ##How do you look at it from different perspectives
  #Multiple drug, one disease
  #Multiple diseases, one drug
  #Filters based on performance
  
  output$vfsperf <- renderPlotly({
   # load(input$dataset)
    
    rho <- sapply(list.files("out",full.names = T), function(Robject) {
      load(Robject)
      organ=vds$perf[[input$organ]]
      #organ=vds$perf[["bone"]]
      
      return(organ$rho$estimate)
    }) 
    
  
    rho <- as.data.frame(rho)
    rho$names = row.names(rho)
  
    # note how size is automatically scaled and added as hover text
    plot_ly(rho,x=names,y=rho)%>%
      layout(xaxis = list(title="Drug"),
             yaxis = list(title="Rho"))
    
  })

  output$coolPlot <- renderPlotly({
    # filter by freqCounts
    load(input$dataset)
    
    diseaseArea=R[[input$disease]]
    temp <- diseaseArea$df
    #Filter by freqEvents
    filtered = temp[temp$freqCounts > 0.05,]
    # filter by effect magnitude
    #filtered = temp[temp$effect >0.01]
    
    # note how size is automatically scaled and added as hover text
    plot_ly(filtered, x = effect, y = freqCounts, 
            text = paste("Molecular Trait: ",genes),
            size = freqEvents, mode = "markers") %>%
      layout(xaxis = list(title="Effect Magnitude"),
              yaxis = list(title="Feature Stability"))
      
  })
  
  output$drug <- renderText({
    load(input$dataset)
    paste("Drug:",drug)
  })
  
})




