shinyServer(function(input, output,session) {
  
  ##How do you look at it from different perspectives
  #Multiple drug, one disease
  #Multiple diseases, one drug
  #Filters based on performance
  vds <- reactive({
    rho <- vdsRho[,unlist(input$organ)]
    rho <- as.data.frame(rho)
    rho$names = row.names(vdsRho)
    rho <- rho[order(rho$rho),]
    rho <- rho[rho$rho>=input$threshold,]
    rho
  })
  
  output$vfsperf <- renderPlotly({
  
    rho <- vds()
    
    #print(head(rho))
    # note how size is automatically scaled and added as hover text
    plot_ly(rho,x=names,y=rho, mode="markers")%>%
      layout(xaxis = list(title="Drug"),
             yaxis = list(title="Rho"))
    
  })
  
  # Generate a dataframe of medianValues of drugs for each disease area
  vds2 <- reactive({
    medianValues <- lapply(input$diseaseArea, function(x) {
      diseaseRho <- drugRho[[x]]
      medianVal <- unlist(lapply(diseaseRho, function(x) {
        values <- unlist(strsplit(x, ","))
        values <- values[values != "NA"]
        values <- as.numeric(values)
        median(values,na.rm = T)
      }))
      temp <- data.frame(drug = row.names(drugRho), medianVal, disease = x)
      #temp <- temp[order(temp$medianVal),]
      return(temp)
    })
    
    # sort the medianValues according to the order of first df
    index <- order(medianValues[[1]]$medianVal)
    for (i in c(1:length(medianValues))){
      medianValues[[i]] <- medianValues[[i]][index,]
      # filter values according to the median threshold 
      if(input$thresholdmedian > 0){
        tempDf <-medianValues[[i]]
        threshold <- input$thresholdmedian
        medianValues[[i]] <- medianValues[[i]][tempDf$medianVal>=threshold,]
      }
    }
    
    medianValues <- do.call(rbind,medianValues)
    medianValues
  })
  
  output$drugRho <- renderPlotly({
    withProgress(message = 'Calculation in progress',
                 detail = 'This may take a while...',  value = 0,{
      
      medianValues <- vds2()

      #frame = data.frame()
      #for (i in c(1:length(diseaseRho))) {
      #  values <- unlist(strsplit(diseaseRho[i], ","))
      #  values <- values[values != "NA"]
      #  values <- as.numeric(values)
      #  temp <- data.frame(drug = row.names(drugRho)[i],values = values)  
      #  frame = rbind(frame, temp)
      #}
      #frame <- as.data.frame(frame,stringsAsFactors=F)
      plot_ly(medianValues, x=drug, y= medianVal,color=disease, mode="markers") #%>% #,type = "box") %>%
        #add_trace(y = fitted(loess(values ~ as.numeric(drug))))# %>%
        #layout(yaxis = list(range=c(-0.5,1)))
    })
    
  })

  # Update choices
  observe({
    #finalChoices = intersection of vds()$names + vds2()$drug
    drugChoices1 <- vds()$names
    drugChoices2 <- as.character(vds2()$drug)
    finalChoices <- intersect(drugChoices1,drugChoices2)
    
    totalChoices <- length(finalChoices)
    cat("choices from model 1:" ,length(drugChoices1), sep="\n")
    cat("choices from model 3:" ,length(drugChoices2), sep="\n")
    cat("intersection total: ", totalChoices, sep="\n")
    
#     validate(
#       need(totalChoices != 0, "Please choose valid thresholds")
#     )

    updateSelectInput(session, "dataset", label = "Choose a drug:", choices = sort(finalChoices))
  })
  
  # Output disease area input
  output$diseaseAreaOutput <- renderText({
    paste(input$diseaseArea, collapse = ', ')    
  })
  
  output$coolPlot <- renderPlotly({
    withProgress(message = 'Calculation in progress',
                 detail = 'This may take a while...',  value = 0,{
      incProgress(session= session)
      R = vdsRdf[vdsRdf$drug == input$dataset,]
      
      #May have multiple diseases, so loop through and gather top 20 freqCounts of each 
      #disease area
      data = lapply(input$diseaseArea, function(x) {
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
    
    data = lapply(input$diseaseArea, function(x) {
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




