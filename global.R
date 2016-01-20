library(synapseClient)
library(shiny)
library(plotly)
synapseLogin()

##R data frame file (Model 2)
#vdsRdf <- synGet("syn5520037")
#vdsRdf <- read.csv(vdsRdf@filePath,stringsAsFactors = F)
 
##Rho values (Cell line drug sensitivity)
#vdsRho <- synGet("syn5520030")
#vdsRho <- read.csv(vdsRho@filePath,stringsAsFactors = F)
#vdsRho.names <- remapDrugName(vdsRho$X)
#vdsRho[vdsRho.names[,1],]$X <- vdsRho.names[,2]
#row.names(vdsRho) = vdsRho$X
#vdsRho <- vdsRho[,-1]
 
##Disease drug sensitivity
#drugRho <- synGet("syn5578061")
#drugRho <- read.csv(drugRho@filePath, stringsAsFactors = F, sep="\t")
 
## Drug metadata
#drugData <- read.csv('metadata/drug_metadata.csv', header=TRUE,sep=",", stringsAsFactors = F)
 
## Cell line metadata
#cellLineData <- read.csv('metadata/cell_line_metadata.csv', header=TRUE,sep=",", stringsAsFactors = F)

## Re-map drug names
#remapDrugName <- function(oldNames){
#  numbersOnly.index <- grep("^\\d+$",oldNames)
#  correctName <- sapply(oldNames[numbersOnly.index],function(x){
#    return(drugData[drugData$master_cpd_id == x,]$cpd_name)
#  })
#  return (cbind(numbersOnly.index,correctName))
#}
 
#vdsRdf.names <- remapDrugName(vdsRdf$drug)
#vdsRdf[vdsRdf.names[,1],]$drug <- vdsRdf.names[,2]

organs <- colnames(vdsRho)
diseases <- unique(vdsRdf$disease)

drugs <- unique(vdsRdf$drug)
drugs <- sort(drugs)

cellLines <- unique(cellLineData$ccle_primary_site)
cellLines <- sort(as.character(cellLines[cellLines != ""]))

totalList <- sapply(diseases, function(x){
  total <- length(vdsRdf[vdsRdf$disease == x,]$disease) 
  return (total)
})


totalDf <- data.frame(totalList)

showtable <- c("disease","genes","effect",#"effectSD",
               "freqCounts","freqEvents"#,"drug",
               )

drugTableCol <- c("master_cpd_id","broad_cpd_id","cpd_status","gene_symbol_of_protein_target",
               "target_or_activity_of_compound","source_name","source_catalog_id")

cellLineTableCol <- c("ccl_name", "ccl_availability","ccle_primary_hist", "ccle_hist_subtype_1")

