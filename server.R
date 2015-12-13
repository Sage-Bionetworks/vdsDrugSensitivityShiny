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
  

  output$coolPlot <- renderPlotly({
    withProgress(message = 'Calculation in progress',
                 detail = 'This may take a while...',  value = 0,{
      incProgress(session= session)
      R = vdsRdf[vdsRdf$drug == input$dataset,]
      
      #May have multiple diseases, so loop through and gather top 20 freqCounts of each 
      #disease area
      data = lapply(input$disease, function(x) {
        diseaseArea=R[R$disease == x,]
        filtered = diseaseArea[order(diseaseArea$freqCounts,decreasing = T)[1:20],]
        return(filtered)
      })
      data = do.call(rbind, data)
      #filtered = diseaseArea[diseaseArea$freqCounts > 0.05,]
      #filtered = filtered[filtered$freqEvents > 0.01,]
      
      # note how size is automatically scaled and added as hover text
      plot_ly(data, x = effect, y = freqCounts, 
              text = paste("Feature Stability: ", freqCounts,
                           "</br>Molecular Trait: ",genes,"</br>Effect Magnitude: ", effect,
                           "</br>Disease: ",disease, "</br>Drug: ",drug,
                           "</br>Event frequency: ", freqEvents),
              size = freqEvents,color = disease, 
              mode = "markers") %>%
        layout(xaxis = list(title="Effect Magnitude"),
                yaxis = list(title="Feature Stability"))
    })
      
  })
  
  output$mytable = renderDataTable({
    R = vdsRdf[vdsRdf$drug == input$dataset,]
    
    data = lapply(input$disease, function(x) {
      diseaseArea=R[R$disease == x,input$show_vars]
      filtered = diseaseArea[order(diseaseArea$freqCounts,decreasing = T)[1:20],]
      return(filtered)
    })
    data = do.call(rbind, data)

    #Filter by freqCounts and freqEvents
    #filtered = diseaseArea[diseaseArea$freqCounts > 0.05,]
    #filtered = filtered[filtered$freqEvents > 0.01,]
    return(data)
  })

  
})




