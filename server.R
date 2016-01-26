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
    
    rho
  })
  
  # Annonate selected drugs for Model 1
  drugAnnonates1 <- reactive({
    a <- list()
    rho <- filtered.vds()
    selectedDrug <- input$drugList1
    
    if(length(selectedDrug) != 0){
      for (i in c(1:length(selectedDrug))){
        m <- rho[rho$names %in% selectedDrug,]
        a[[i]] <- list(
          x = m$names[i],
          y = m$rho[i],
          text = m$names[i],
          showarrow = TRUE,
          arrowhead = 7,
          ax = 0,
          ay = -100
        )
      }
    }
    a
  })
  
  # Plot Model 1
  output$vfsperf <- renderPlotly({
    rho <- filtered.vds()
    a <- drugAnnonates1()
    
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
    threshold <- input$thresholdMedian
    df1 <- medianValues[[1]]
    
    # filter f1 according to the median threshold and drug choices from Model 1
    # then sort by medianVal 
    # get the rownames of the order
    valueIndex <- which(df1$medianVal>=threshold)
    df_filter <- medianValues[[1]][valueIndex,]
    drugChoices1 <- filtered.vds()$names
    drugChoices2 <- df_filter$drug
    newDrugChoices2 <- intersect(drugChoices1,drugChoices2)
    
    df_filter <- medianValues[[1]][medianValues[[1]]$drug %in% newDrugChoices2,]
    
    df_sort <- df_filter[order(df_filter$medianVal),]
    ordered.threshold <- as.numeric(rownames(df_sort))
    
    for (i in c(1:length(medianValues))){
      medianValues[[i]] <- medianValues[[i]][ordered.threshold,]
    }
    
    medianValues <- do.call(rbind,medianValues)
    medianValues
  })
  
  # Annonate selected drugs for Model 3 
  drugAnnonates2 <- reactive({
    a <- list()
    rho <- drugMedianValues()[[1]]
    selectedDrug <- input$drugList2
   
    if(length(selectedDrug) != 0){
      for (i in c(1:length(selectedDrug))){
        m <- rho[rho$drug %in% selectedDrug,]
        a[[i]] <- list(
          x = m$drug[i],
          y = m$medianVal[i],
          text = m$drug[i],
          showarrow = TRUE,
          arrowhead = 7,
          ax = 0,
          ay = -150
        )
      }
    }
    a
  })
  
  # Plot drug sensitivity (Model 3)
  output$drugRho <- renderPlotly({
    withProgress(message = 'Calculation in progress',
                 detail = 'This may take a while...',  value = 0,{
      
      medianValues <-  filtered.drugMedianValues()
      a <- drugAnnonates2()
      plot_ly(medianValues, x=drug, y= medianVal,color=disease, mode="markers")%>%
        layout(annotations = a)
    })
    
  })
  
  # Update choices
  observe({
    # Model 1 drug list update
    updateSelectInput(session, "drugList1", choices = sort(filtered.vds()$names), selected = input$drugList1)
    
    filteredDrugChoices <- as.character(filtered.drugMedianValues()$drug)
    filteredDrugChoices <- sort(filteredDrugChoices)
    
    # Model 3 drug list update
    updateSelectInput(session, "drugList2", choices = filteredDrugChoices, selected = input$drugList2)
    
    # Model 2 drug choices update
    updateSelectInput(session, "drugList3", choices = filteredDrugChoices,selected = input$drugList3)
    
    # Model 2 other disease area update
    otherDiseaseArea <- diseases[!(diseases %in% input$diseaseArea[1])]
    updateSelectInput(session, "otherDiseaseList", choices = otherDiseaseArea ,selected = input$otherDiseaseList)
    
    # Model 2 sliderMax
    EM <- top20Data()$effect
    resultEM <- max(abs(max(EM)),abs(min(EM)))
    updateSliderInput(session, "thresholdEM", max = floor(resultEM*1000)/1000)
  })
  
  # Outputs selected organ from Model 1 in Model 2
  output$selectedOrgan <- renderText({
    input$organ
  })
  
  # Outputs selected disease area from Model 1 in Model 2
  output$selectedArea <- renderText({
    input$diseaseArea[1]
  })
  
  # Generates Model 2 data
  top20Data <- reactive({
    validate(
      need(input$drugList3 != '', "Please choose a drug")
      #need(length(input$otherDiseaseList) > 0, "Please choose at least one disease area")
    )
    R = vdsRdf[vdsRdf$drug == input$drugList3,]
  
    #May have multiple diseases, so loop through and gather top 20 freqCounts of each 
    #disease area
    diseaseList <- union(input$otherDiseaseList,input$diseaseArea[1])
    diseaseList <- sort(diseaseList)
    data = lapply(diseaseList, function(x) {
      diseaseArea=R[R$disease == x,]
      
      filtered = diseaseArea[order(diseaseArea$freqCounts,decreasing = T)[1:20],]
      filtered = filtered[abs(filtered$effect)>=input$thresholdEM,]
      return(filtered)
    })
    data = do.call(rbind, data)
    data
  })
  
  # Model 2 Plot
  output$dsPlot <- renderPlotly({
    withProgress(message = 'Calculation in progress',
                 detail = 'This may take a while...',  value = 0,{
      incProgress(session= session)
      data <- top20Data()
      
      #filtered = diseaseArea[diseaseArea$freqCounts > 0.05,]
      #filtered = filtered[filtered$freqEvents > 0.01,]
      
      # note how size is automatically scaled and added as hover text
      
      size <- normalize.vector((data$freqEvents)^2)
      size <- as.numeric(format(size,digits = 3))
      total <- sampleSizeData[data$disease,input$drugList3]
      
      plot_ly(data, x = effect, y = freqCounts,hoverinfo="text",
              text = paste("Molecular Trait: ",genes,
                           "</br>Feature Stability: ", freqCounts,
                           "</br>Effect Magnitude: ", effect,
                           "</br>Disease: ", disease, 
                           "</br>Drug: ", drug,
                           "</br>Event frequency: ", format(freqEvents*100,digits = 2),"% out of",total),
              size = size,color = disease, 
              mode = "markers") %>%
        layout(xaxis = list(title="Effect Magnitude"),
                yaxis = list(title="Feature Stability"))
    })
      
  })
  
  # Model 2 table
  output$dsDataTable = renderDataTable({
    withProgress(message = 'Calculation in progress',
                 detail = 'This may take a while...',  value = 0,{
                   incProgress(session= session)
      data <- top20Data()
      show.column <- input$show_vars
      
      #Filter by freqCounts and freqEvents
      #filtered = diseaseArea[diseaseArea$freqCounts > 0.05,]
      #filtered = filtered[filtered$freqEvents > 0.01,]
      datatable(
        data[,show.column],
        rownames = FALSE,
        filter = 'top',
        options = list(
          searching = TRUE
        )
      )
    })
  })
})



