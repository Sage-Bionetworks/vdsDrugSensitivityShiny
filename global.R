library(synapseClient)
library(shiny)
library(plotly)
synapseLogin()

#vdsRdf <- synGet("syn5520037")

#vdsRho <- synGet("syn5520030")


#vdsRdf <- read.csv(vdsRdf@filePath)

#vdsRho <- read.csv(vdsRho@filePath)
#row.names(vdsRho) = vdsRho$X
#vdsRho <- vdsRho[,-1]

organs <- colnames(vdsRho)
diseases <- levels(vdsRdf$disease)
drugs <- levels(vdsRdf$drug)

showtable <- c("genes","effect","effectSD","freqCounts","freqEvents","drug","disease")

