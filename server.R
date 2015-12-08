shinyServer(function(input, output,session) {
  
  ##How do you look at it from different perspectives
  #Multiple drug, one disease
  #Multiple diseases, one drug
  #Filters based on performance
  
  output$vfsperf <- renderPlotly({

    rho <- vdsRho[,unlist(input$organ)]
    rho <- as.data.frame(rho)
    rho$names = row.names(vdsRho)
    if (input$sort) 
      rho <- rho[order(rho$rho),]
    
    # note how size is automatically scaled and added as hover text
    plot_ly(rho,x=names,y=rho)%>%
      layout(xaxis = list(title="Drug"),
             yaxis = list(title="Rho"))
    
  })
  
#### Fix below as when you select multiple drugs/diseases this will fail
  
  output$coolPlot <- renderPlotly({
    withProgress(message = 'Calculation in progress',
                 detail = 'This may take a while...',  value = 0,{
      incProgress(session= session)
      R = vdsRdf[vdsRdf$drug == input$dataset,]
      diseaseArea=R[R$disease == unlist(input$disease),]
      
      #Filter by freqCounts and freqEvents
      filtered = diseaseArea[diseaseArea$freqCounts > 0.05,]
      filtered = filtered[filtered$freqEvents > 0.01,]
    
      # note how size is automatically scaled and added as hover text
      plot_ly(filtered, x = effect, y = freqCounts, 
              text = paste("Molecular Trait: ",genes),
              size = freqEvents,color = disease, mode = "markers") %>%
        layout(xaxis = list(title="Effect Magnitude"),
                yaxis = list(title="Feature Stability"))
    })
      
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




