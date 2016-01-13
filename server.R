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
    rho
  })
  
  # Filtered cell line drug sensitivity data
  filtered.vds <- reactive({
    rho <- vds()
    rho <- rho[rho$rho>=input$threshold,]
    #rho$color <- 'drug sensitivity'
    rho
  })
  
  # Annonate selected drugs
  drugAnnonates <- reactive({
    a <- list()
    rho <- filtered.vds()
    selectedDrug <- input$drugList
    
    if(length(selectedDrug) != 0){
      for (i in c(1:length(selectedDrug))){
        m <- rho[rho$names %in% selectedDrug,]
        a[[i]] <- list(
          x = m$names[i],
          y = m$rho[i],
          text = m$names[i],
          showarrow = TRUE,
          arrowhead = 7,
          ax = 20,
          ay = -40
        )
      }
    }
    a
  })
  # Plot Model 1
  output$vfsperf <- renderPlotly({
    rho <- filtered.vds()
    a <- drugAnnonates()

    # note how size is automatically scaled and added as hover text
    plot_ly(rho, x=names, y=rho, mode="markers")%>%
      layout(xaxis = list(title="Drug"),
             yaxis = list(title="Rho"),
             annotations = a)
    
  })
  
  # Generate a list medianValues of drugs for each disease area
  drugMedianValues <- reactive({
    validate(
      need(try(input$diseaseArea != ""), "Please choose at least one area")
    )
    medianValues <- lapply(input$diseaseArea, function(x) {
      diseaseRho <- drugRho[[x]]
      medianVal <- unlist(lapply(diseaseRho, function(x) {
        values <- unlist(strsplit(x, ","))
        values <- values[values != "NA"]
        values <- as.numeric(values)
        median(values,na.rm = T)
      }))
      temp <- data.frame(drug = row.names(drugRho), medianVal, disease = x)
      return(temp)
    })
    medianValues
  })
  
  # Generate a dataframe of median values. Filtered by threshold, sorted
  filtered.drugMedianValues <- reactive({
    medianValues <- drugMedianValues()
    threshold <- input$thresholdmedian
    df1 <- medianValues[[1]]
    
    # filter f1 according to the median threshold, 
    # then sort by medianVal 
    # get the rownames of the order
    valueIndex <- which(df1$medianVal>=threshold)
    df_filter <- medianValues[[1]][valueIndex,]
    df_sort <- df_filter[order(df_filter$medianVal),]
    ordered.threshold <- as.numeric(rownames(df_sort))
    
    for (i in c(1:length(medianValues))){
      medianValues[[i]] <- medianValues[[i]][ordered.threshold,]
    }
    
    medianValues <- do.call(rbind,medianValues)
    medianValues
  })
  
  # Plot drug sensitivity (Model 3)
  output$drugRho <- renderPlotly({
    withProgress(message = 'Calculation in progress',
                 detail = 'This may take a while...',  value = 0,{
      
      medianValues <-  filtered.drugMedianValues()

      plot_ly(medianValues, x=drug, y= medianVal,color=disease, mode="markers")
    })
    
  })
  
  # Return intersections of model 1 and model 3 drug choices
  finalChoices <- reactive({
    #finalChoices: intersection of filtered.vds()$names + filtered.drugMedianValues()$drug
    drugChoices1 <- filtered.vds()$names
    drugChoices2 <- as.character(filtered.drugMedianValues()$drug)
    choices <- intersect(drugChoices1,drugChoices2)

    choices
  })
  
  # Update choices
  observe({
    # Model 1 drug list update
    updateSelectInput(session, "drugList", choices = sort(filtered.vds()$names), selected = input$drugList)
    
    # Model 2 drug choices update
    finalChoices <- finalChoices()
    updateSelectInput(session, "dataset", choices = sort(finalChoices))
    
    # Model 2 disease area auto fill
    updateSelectInput(session, "diseaseList", selected = input$diseaseArea)
  })
  
  # Model 2 Plot
  output$coolPlot <- renderPlotly({
    withProgress(message = 'Calculation in progress',
                 detail = 'This may take a while...',  value = 0,{
      incProgress(session= session)
      R = vdsRdf[vdsRdf$drug == input$dataset,]
      
      #May have multiple diseases, so loop through and gather top 20 freqCounts of each 
      #disease area
      data = lapply(input$diseaseList, function(x) {
        diseaseArea=R[R$disease == x,]
        filtered = diseaseArea[order(diseaseArea$freqCounts,decreasing = T)[1:20],]
        
        return(filtered)
      })
      data = do.call(rbind, data)
      
      #filtered = diseaseArea[diseaseArea$freqCounts > 0.05,]
      #filtered = filtered[filtered$freqEvents > 0.01,]
      
      # note how size is automatically scaled and added as hover text
      plot_ly(data, x = effect, y = freqCounts, 
              text = paste("Molecular Trait: ",genes,
                           "</br>Feature Stability: ", freqCounts,
                           "</br>Effect Magnitude: ", format(effect,digits = 3),
                           "</br>Disease: ", disease, 
                           "</br>Drug: ", drug,
                           "</br>Event frequency: ", format(freqEvents*100,digits = 2),"%"),
              size = sqrt(freqEvents),color = disease, 
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




