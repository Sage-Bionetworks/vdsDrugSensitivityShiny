shinyServer(function(input, output) {
  
  ##How do you look at it from different perspectives
  #Multiple drug, one disease
  #Multiple diseases, one drug
  #Filters based on performance
  
  output$vfsperf <- renderPlotly({

    rho <- vdsRho[[input$organ]]
    rho <- as.data.frame(rho)
    rho$names = row.names(vdsRho)
    if (input$sort) 
      rho <- rho[order(rho$rho),]
    
    # note how size is automatically scaled and added as hover text
    plot_ly(rho,x=names,y=rho)%>%
      layout(xaxis = list(title="Drug"),
             yaxis = list(title="Rho"))
    
  })

  output$coolPlot <- renderPlotly({

    R = vdsRdf[vdsRdf$drug == input$dataset,]
    diseaseArea=R[R$disease == input$disease,]
    
    #Filter by freqCounts and freqEvents
    filtered = diseaseArea[diseaseArea$freqCounts > 0.05,]
    filtered = filtered[filtered$freqEvents > 0.01,]

    # note how size is automatically scaled and added as hover text
    plot_ly(filtered, x = effect, y = freqCounts, 
            text = paste("Molecular Trait: ",genes),
            size = freqEvents, mode = "markers") %>%
      layout(xaxis = list(title="Effect Magnitude"),
              yaxis = list(title="Feature Stability"))
      
  })
  
  output$mytable = renderDataTable({
    R = vdsRdf[vdsRdf$drug == input$dataset,]
    diseaseArea=R[R$disease == input$disease,input$show_vars]
    
    #Filter by freqCounts and freqEvents
    filtered = diseaseArea[diseaseArea$freqCounts > 0.05,]
    filtered = filtered[filtered$freqEvents > 0.01,]
    return(filtered)
  })

  
})




