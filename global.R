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
#row.names(vdsRho) = vdsRho$X
#vdsRho <- vdsRho[,-1]

##Disease drug sensitivity
#drugRho <- synGet("syn5578061")
#drugRho <- read.csv(drugRho@filePath, stringsAsFactors = F, sep="\t")

organs <- colnames(vdsRho)
diseases <- unique(vdsRdf$disease)
drugs <- unique(vdsRdf$drug)
drugs <- sort(drugs)


showtable <- c("genes","effect",#"effectSD",
               "freqCounts","freqEvents","drug","disease")

