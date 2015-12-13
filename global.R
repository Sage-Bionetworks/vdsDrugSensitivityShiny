library(synapseClient)
library(shiny)
library(plotly)
synapseLogin()

#vdsRdf <- synGet("syn5520037")

#vdsRho <- synGet("syn5520030")


#vdsRdf <- read.csv(vdsRdf@filePath,stringsAsFactors = F)

#vdsRho <- read.csv(vdsRho@filePath,stringsAsFactors = F)
#row.names(vdsRho) = vdsRho$X
#vdsRho <- vdsRho[,-1]

organs <- colnames(vdsRho)
diseases <- unique(vdsRdf$disease)
drugs <- unique(vdsRdf$drug)
#Three significant Digits
vdsRdf$effect <- signif(vdsRdf$effect,3)
vdsRdf$freqEvents <- signif(vdsRdf$freqEvents,3)
showtable <- c("genes","effect",#"effectSD",
               "freqCounts","freqEvents","drug","disease")

