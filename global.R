library(synapseClient)
library(shiny)
library(plotly)
library(pracma)
library(DT)
synapseLogin()

drugData <- synGet("syn5599746")
load(drugData@filePath)
