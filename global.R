library(synapseClient)
library(shiny)
library(plotly)
synapseLogin()

#vdsRdf <- synGet("syn5520037")

#vdsRho <- synGet("syn5520030")


#vdsRdf <- read.csv(vdsRdf@filePath,stringsAsFactors = F)

#vdsRho <- read.csv(vdsRho@filePath,stringsAsFactors = F)

#vdsRdf <- read.csv("shortened_vdsRdf.csv",stringsAsFactors = F)
#vdsRho <- read.csv("vdsRhoEstimates.csv",stringsAsFactors = F)
#drugRho <- read.csv("RdrugRho.tsv",stringsAsFactors = F,sep="\t")
#row.names(vdsRho) = vdsRho$X
#vdsRho <- vdsRho[,-1]

organs <- colnames(vdsRho)
diseases <- unique(vdsRdf$disease)
drugs <- unique(vdsRdf$drug)
drugs <- sort(drugs)


showtable <- c("genes","effect",#"effectSD",
               "freqCounts","freqEvents","drug","disease")